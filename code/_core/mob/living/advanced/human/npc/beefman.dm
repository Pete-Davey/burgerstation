/mob/living/advanced/npc/beefman
	name = "anomaly"
	enable_AI = TRUE
	ai = /ai/advanced/
	species = "beefman"
	class = "ashwalker"
	iff_tag = "beefman"
	loyalty_tag = "beefman"

/mob/living/advanced/npc/beefman/Initialize()

	. = ..()

	update_all_blends()

	return .

/mob/living/advanced/npc/borgman
	name = "borgman"
	enable_AI = TRUE
	ai = /ai/advanced/
	species = "cyborg"
	class = "ashwalker"

/mob/living/advanced/npc/borgman/Initialize()

	. = ..()

	update_all_blends()

	return .