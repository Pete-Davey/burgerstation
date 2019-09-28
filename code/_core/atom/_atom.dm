/atom/

	name = "atom"
	desc = "What the fuck is this?"
	desc_extended = "Such a strange object. I bet not even the gods themselves know what this thing is. Who knows what mysteries it can hold?"
	id = null

	plane = PLANE_OBJ

	density = FALSE //DEPCRECATED

	var/health_max = 0
	var/health_current = 0
	var/health_regeneration = 0

	var/list/damage = list(BRUTE = 0, BURN = 0, TOX = 0, OXY = 0)
	var/list/damage_soft = list(BRUTE = 0, BURN = 0, TOX = 0, OXY = 0)

	var/damage_soft_total = 0

	var/throw_speed = 8 //How far the object travels in pixels per decisecond, when thrown

	var/damage_type //The id of the damage type of the weapon, if any.

	var/list/resistance = list(BRUTE = 0, BURN = 0, TOX = 0, OXY = 0) //How much to subtract damage

	var/attack_range = 1 //If it's a melee weapon, it needs a range. TODO: MOVE TO ITEM

	var/initialized = FALSE

	var/list/additional_blends = list()

	var/override_icon = FALSE

	var/wound/wounds = list()

	var/doing_progress = FALSE

	var/collision_flags = FLAG_COLLISION_NONE
	var/collision_bullet_flags = FLAG_COLLISION_BULLET_NONE

	var/interact_distance = 1
	var/interact_delay_base = 4
	var/interact_last = 0

	var/attack_last = -1

	var/thinks = FALSE

	var/reagent_container/reagents

	var/object_size = 1 //This-1 is added to attack range.

	var/corner_icons = FALSE
	var/corner_category = "none"

/atom/proc/should_smooth_with(var/atom/A)
	return (A.corner_category == corner_category) || (is_unsimulated(A))

/atom/destroy()
	if(reagents)
		qdel(reagents)
	invisibility = 101
	if(thinks)
		all_thinkers -= src
	return ..()

/atom/proc/can_collide_with(var/atom/A)
	return A.collision_flags & src.collision_flags

/atom/Cross(var/atom/A)

	if(A.can_collide_with(src))
		return FALSE

	return ..()

/atom/proc/Initialize()
	initialized = TRUE
	return TRUE

/atom/New()

	. = ..()

	if(opacity && isturf(loc))
		var/turf/T = loc
		T.has_opaque_atom = TRUE // No need to recalculate it in this case, it's guaranteed to be on afterwards anyways.

	if(thinks)
		all_thinkers += src

	if(reagents)
		reagents = new reagents(src)

	return .

/atom/proc/defer_click_on_object()
	return src

/atom/proc/get_xp_multiplier() //How much XP should this object give for interacting with it.
	return 0

/atom/proc/can_be_attacked(var/atom/attacker)
	return TRUE

/atom/proc/can_be_grabbed(var/atom/grabber)
	return FALSE

/atom/proc/on_progress_bar_completed(var/id,var/list/callback_list)
	return TRUE

/atom/proc/on_progress_bar_failed(var/id,var/list/callback_list)
	return TRUE

/atom/proc/think()
	return TRUE //Return false to remove from thinking.