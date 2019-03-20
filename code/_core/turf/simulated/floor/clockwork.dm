/turf/simulated/floor/clockwork/
	name = "clockwork floor"
	icon = 'icons/turf/floor/clockwork.dmi'
	icon_state = "floor1"

/turf/simulated/floor/clockwork/alt1/
	icon_state = "floor2"

/turf/simulated/floor/clockwork/alt2/
	icon_state = "floor3"

/turf/simulated/floor/clockwork/alt3/
	icon_state = "floor4"

/turf/simulated/floor/clockwork/special/New(var/desired_loc)
	..()
	if(x % 2 == y % 2)
		icon_state = "floor2"
	else
		icon_state = "floor4"
	update_icon()

/turf/simulated/floor/clockwork/vent
	name = "clockwork vent"
	icon = 'icons/turf/floor/clockwork.dmi'
	icon_state = "vent_on"


