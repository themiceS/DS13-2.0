#define BRUTE_FRONT_ARMOUR "brutefront"
#define BRUTE_SIDE_ARMOUR "bruteside"
#define BRUTE_BACK_ARMOUR "bruteback"

/mob/living/carbon/human/necromorph/brute
	maxHealth = 510
	class = /datum/necro_class/brute
	necro_species = /datum/species/necromorph/brute
	pixel_x = -16
	base_pixel_x = -16
	status_flags = CANSTUN|CANUNCONSCIOUS
	///Brute has armor ontop of armor, reducing or potentially negating most damage from the front.
	var/list/facing_modifiers = list(BRUTE_FRONT_ARMOUR = 65, BRUTE_SIDE_ARMOUR = 10, BRUTE_BACK_ARMOUR = -40)
	move_force = MOVE_FORCE_OVERPOWERING
	move_resist = MOVE_FORCE_OVERPOWERING
	pull_force = MOVE_FORCE_OVERPOWERING


/mob/living/carbon/human/necromorph/brute/play_necro_sound(audio_type, volume, vary, extra_range)
	playsound(src, pick(GLOB.brute_sounds[audio_type]), volume, vary, extra_range)

//Brute gets his own UnarmedAttack, which is basically a extension of attack_necro with special flinging
/mob/living/carbon/human/necromorph/brute/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	Brute_Attack(src, A, modifiers)
	changeNext_move(25) //A little longer then CLICK_CD_RESIST, which is 20. If 25 is too long then switch it to that
	return

/mob/living/carbon/human/necromorph/brute/proc/Brute_Attack(mob/living/carbon/human/necromorph/brute/user, atom/target, modifiers)
	if(!user.combat_mode)
		return
	user.play_necro_sound(SOUND_ATTACK, VOLUME_MID, 1, 3)
	if(isliving(target) && get_turf(target) != get_turf(user))
		var/mob/living/our_target = target
		var/throw_dir = pick(
			user.dir,
			turn(user.dir, 45),
			turn(user.dir, -45),
			) //Throwing them somewhere ahead of us
		var/throw_dist = rand(2,5)

		var/throw_x = our_target.x
		if(throw_dir & WEST)
			throw_x += throw_dist
		else if(throw_dir & EAST)
			throw_x -= throw_dist

		var/throw_y = our_target.y
		if(throw_dir & NORTH)
			throw_y += throw_dist
		else if(throw_dir & SOUTH)
			throw_y -= throw_dist

		throw_x = clamp(throw_x, 1, world.maxx)
		throw_y = clamp(throw_y, 1, world.maxy)

		our_target.safe_throw_at(locate(throw_x, throw_y, our_target.z), throw_dist, 1, user, TRUE)
	target.attack_necromorph(user) //We let attack_necro do the rest of the lifting

	return

//Shamelessly stolen from mech code
/mob/living/carbon/human/necromorph/brute/proc/get_armour_facing(relative_dir)
	switch(relative_dir)
		if(180) // BACKSTAB!
			return facing_modifiers[BRUTE_BACK_ARMOUR]
		if(0, 45) // direct or 45 degrees off
			return facing_modifiers[BRUTE_FRONT_ARMOUR]
	return facing_modifiers[BRUTE_SIDE_ARMOUR] //if its not a front hit or back hit then assume its from the side

//Switched from species to mob due to code improvements
/mob/living/carbon/human/necromorph/brute/apply_damage(damage, damagetype, def_zone, blocked, forced, spread_damage, sharpness, attack_direction, attacking_item)
	var/mob/living/carbon/human/necromorph/brute/H = src
	if(attack_direction)
		var/facing_modifier = get_armour_facing(abs(dir2angle(dir) - dir2angle(attack_direction)))
		H.physiology?.damage_resistance += facing_modifier
	return ..()

/datum/necro_class/brute
	display_name = "Brute"
	desc = "A powerful linebreaker and assault specialist, the brute can smash through almost any obstacle, and its tough \
	frontal armor makes it perfect for assaulting entrenched positions.\nVery vulnerable to flanking attacks"
	ui_icon = 'deadspace/icons/necromorphs/brute.dmi'
	necromorph_type_path = /mob/living/carbon/human/necromorph/brute
	tier = 3
	biomass_cost = 360
	biomass_spent_required = 950
	melee_damage_lower = 24
	melee_damage_upper = 28
	armor = list(BLUNT = 30, PUNCTURE = 80, SLASH = 55, LASER = 0, ENERGY = 0, BOMB = 45, BIO = 50, FIRE = 10, ACID = 80)
	actions = list(
		/datum/action/cooldown/necro/slam,
		/datum/action/cooldown/necro/long_charge/brute,
		/datum/action/cooldown/necro/shoot/brute,
	)
	minimap_icon = "brute"
	implemented = TRUE

/datum/species/necromorph/brute
	name = "Brute"
	id = SPECIES_NECROMORPH_BRUTE
	burnmod = 0.75
	stunmod = 0.15
	speedmod = 4
	species_mob_size = MOB_SIZE_LARGE
	special_step_sounds = list(
		'deadspace/sound/effects/footstep/brute_step_1.ogg',
		'deadspace/sound/effects/footstep/brute_step_2.ogg',
		'deadspace/sound/effects/footstep/brute_step_3.ogg',
		'deadspace/sound/effects/footstep/brute_step_4.ogg',
		'deadspace/sound/effects/footstep/brute_step_5.ogg',
		'deadspace/sound/effects/footstep/brute_step_6.ogg'
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/necromorph/brute,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/necromorph/brute,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/necromorph/brute,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/necromorph/brute,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/necromorph/brute,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/necromorph/brute,
	)

/datum/species/necromorph/brute/get_scream_sound(mob/living/carbon/human/necromorph/brute)
	return pick(
		'deadspace/sound/effects/creatures/necromorph/brute/brute_pain_1.ogg',
		'deadspace/sound/effects/creatures/necromorph/brute/brute_pain_2.ogg',
		'deadspace/sound/effects/creatures/necromorph/brute/brute_pain_3.ogg',
		'deadspace/sound/effects/creatures/necromorph/brute/brute_pain_extreme.ogg',
	)

/datum/species/necromorph/brute/get_deathgasp_sound(mob/living/carbon/human/H)
	return 'deadspace/sound/effects/creatures/necromorph/brute/brute_death.ogg'

#define WINDUP_TIME 1.25 SECONDS

/datum/action/cooldown/necro/shoot/brute
	name = "Bio-bomb"
	desc = "A moderate-strength projectile for longrange shooting."
	cooldown_time = 12 SECONDS
	windup_time = WINDUP_TIME
	projectiletype = /obj/projectile/bullet/biobomb/brute

/datum/action/cooldown/necro/shoot/brute/pre_fire(atom/target)
	var/x_direction = 0
	if (target.x > owner.x)
		x_direction = -1
	else if (target.x < owner.x)
		x_direction = 1

	//We do the windup animation. This involves the user slowly rising into the air, and tilting back if striking horizontally
	animate(
		owner,
		transform = turn(matrix(), 25*x_direction),
		pixel_x = owner.base_pixel_x + 8*x_direction,
		time = WINDUP_TIME,
		flags = ANIMATION_PARALLEL
	)

	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, src)

/datum/action/cooldown/necro/shoot/brute/post_fire()
	sleep(0.4 SECONDS)
	animate(owner, transform = matrix(), pixel_x = owner.base_pixel_x, time = 0.8 SECOND, flags = ANIMATION_PARALLEL)
	sleep(0.8 SECONDS)
	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, src)

#undef WINDUP_TIME

/obj/projectile/bullet/biobomb/brute
	name = "acid bolt"
	icon = 'deadspace/icons/obj/projectiles.dmi'
	icon_state = "acid_large"

	damage = 10
	speed = 0.8
	pixel_speed_multiplier = 0.5

/obj/projectile/bullet/biobomb/brute/on_hit(atom/target, blocked, pierce_hit)
	. = ..()
	if(. == BULLET_ACT_HIT)
		if(isliving(target))
			var/mob/living/M = target
			M.adjust_timed_status_effect(30 SECONDS, /datum/status_effect/bioacid)
