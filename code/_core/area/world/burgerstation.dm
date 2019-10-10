/area/world/burgerstation //4,4
	name = "burgerstation"
	id = "burgerstation"
	safe = TRUE

/area/world/burgerstation/interior
	name = "burgerstation interior"
	area_light_power = DEFAULT_BRIGHTNESS_MUL_INTERIOR
	icon_state = "green"

/area/world/burgerstation/interior/shuttle
	name = "shuttle"


/area/world/burgerstation/interior/home
	name = "home"
	singleplayer = TRUE

/area/world/burgerstation/interior/nothing
	name = "nothing"
	singleplayer = TRUE


/area/world/burgerstation/exterior
	name = "burgerstation exterior"
	icon_state = "red"
	area_light_power = DEFAULT_BRIGHTNESS_MUL_EXTERIOR


/area/world/burgerstation/exterior/space
	name = "space"
	icon_state = "blue"

	sunlight_freq = 2

	desired_light_range = 2
	desired_light_power = 1
	desired_light_color = "#CCD9E8"