/obj/item/weapon/ranged/bullet/magazine/rifle/pdw
	name = "\improper 5.56 PDW"
	desc = "For personel defense!"
	desc_extended = "A small, lightweight personal defense weapon chambered in 5.56. Shoots fast, but isn't that accurate."
	icon = 'icons/obj/item/weapons/ranged/rifle/nanotrasen/556_5.dmi'
	icon_state = "inventory"
	value = 200

	shoot_delay = 1.3

	automatic = TRUE

	shoot_sounds = list('sound/weapons/223/shoot_alt.ogg')

	can_wield = TRUE

	view_punch = 9

	slowdown_mul_held = HELD_SLOWDOWN_RIFLE

	size = SIZE_3

	heat_per_shot = 0.06
	heat_max = 0.12

	bullet_length_min = 40
	bullet_length_best = 45
	bullet_length_max = 46

	bullet_diameter_min = 5.5
	bullet_diameter_best = 5.56
	bullet_diameter_max = 5.6

	ai_heat_sensitivity = 0.5

	attachment_whitelist = list(
		/obj/item/attachment/barrel/charger = TRUE,
		/obj/item/attachment/barrel/compensator = TRUE,
		/obj/item/attachment/barrel/extended = TRUE,
		/obj/item/attachment/barrel/suppressor = TRUE,
		/obj/item/attachment/sight/laser_sight = TRUE,
		/obj/item/attachment/sight/quickfire_adapter = TRUE,
		/obj/item/attachment/sight/red_dot = TRUE,
		/obj/item/attachment/undermount/burst_adapter = TRUE,
		/obj/item/attachment/undermount/vertical_grip = TRUE
	)

	attachment_barrel_offset_x = 30 - 16
	attachment_barrel_offset_y = 20 - 16

	attachment_sight_offset_x = 18 - 16
	attachment_sight_offset_y = 21 - 16

	attachment_undermount_offset_x = 26 - 16
	attachment_undermount_offset_y = 16 - 16

	dan_mode = TRUE


/obj/item/weapon/ranged/bullet/magazine/rifle/pdw/get_static_spread() //Base spread
	if(wielded)
		return 0.01
	return 0.015

/obj/item/weapon/ranged/bullet/magazine/rifle/pdw/get_skill_spread(var/mob/living/L) //Base spread
	if(!heat_current)
		return 0
	return max(0,0.02 - (0.06 * L.get_skill_power(SKILL_RANGED)))