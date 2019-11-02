/reagent_container/
	name = "Reagent Container"
	desc = "The basic description of the reagent container."
	desc_extended = "The extended description of the reagent container, usually a detailed note of how much it can hold."

	var/list/stored_reagents = list()
	var/list/stored_reagents_temperature = list()

	var/volume_current = 0
	var/volume_max = 1000
	var/color = "#FFFFFF"

	var/average_temperature = T0C + 20

	var/flags_metabolism = REAGENT_METABOLISM_NONE
	var/flags_temperature = REAGENT_TEMPERATURE_NONE

	var/atom/owner

	var/should_update_owner = FALSE //Should a change in reagents update the owner?

/reagent_container/destroy()
	owner = null
	all_reagent_containers -= src
	return ..()

/reagent_container/proc/get_contents_english()

	var/returning_text = list()

	for(var/r_id in stored_reagents)
		var/reagent/R = all_reagents[r_id]
		var/volume = stored_reagents[r_id]
		returning_text += "[volume] units of [R.name]"

	return "It contains [english_list(returning_text)]. The temperature reads [average_temperature] kelvin."

/reagent_container/New(var/atom/desired_owner,var/desired_volume_max)

	. = ..()

	if(desired_owner)
		owner = desired_owner

	if(desired_volume_max)
		volume_max = desired_volume_max

	all_reagent_containers += src

	return .

/reagent_container/proc/metabolize()

	if(!volume_current)
		return

	if(!owner)
		return

	for(var/r_id in stored_reagents)

		if(!flags_metabolism)
			continue

		var/volume = stored_reagents[r_id]

		if(!volume)
			continue


		var/reagent/R = all_reagents[r_id]

		var/atom/owner_to_use = owner

		if(owner && is_organ(owner) && owner.loc && flags_metabolism & REAGENT_METABOLISM_INGEST)
			owner_to_use = owner.loc

		if(!owner_to_use)
			continue

		remove_reagent(r_id,R.metabolize(owner_to_use,src,volume),FALSE)

	update_container()


/reagent_container/proc/process_temperature()

	if(!owner)
		return FALSE

	if(!volume_current)
		return FALSE

	var/area/A = get_area(owner)
	var/area_temperature = A.ambient_temperature
	var/area_temperature_mod = AIR_TEMPERATURE_MOD

	if(is_inventory(owner.loc))
		var/obj/hud/inventory/I = owner.loc
		area_temperature += I.inventory_temperature
		area_temperature_mod *= I.inventory_temperature_mod

	if(area_temperature == average_temperature)
		return TRUE

	var/temperature_mod = 0

	for(var/r_id in stored_reagents)
		temperature_mod += stored_reagents[r_id] * all_reagents[r_id].temperature_mod

	var/temperature_diff = area_temperature - average_temperature

	if(average_temperature > area_temperature)
		average_temperature = max(area_temperature,average_temperature + (temperature_diff * (AIR_TEMPERATURE_MOD/temperature_mod)))
	else
		average_temperature = min(area_temperature,average_temperature + (temperature_diff * (AIR_TEMPERATURE_MOD/temperature_mod)))

	for(var/r_id in stored_reagents_temperature)
		stored_reagents_temperature[r_id] = average_temperature

	process_recipes()

	return TRUE


/reagent_container/proc/update_container()

	var/red = 0
	var/green = 0
	var/blue = 0

	volume_current = 0
	average_temperature = 0

	var/list/temperature_math_01 = list()

	var/list/temperature_math_02 = list()
	var/math_02_total = 0

	for(var/r_id in stored_reagents)
		var/reagent/R = all_reagents[r_id]

		var/volume = stored_reagents[r_id]
		var/temperature = stored_reagents_temperature[r_id] ? stored_reagents_temperature[r_id] : T0C + 20

		if(volume <= 0)
			stored_reagents -= r_id
			stored_reagents_temperature -= r_id
			continue

		red += GetRedPart(R.color) * volume
		green += GetGreenPart(R.color) * volume
		blue += GetBluePart(R.color) * volume
		volume_current += volume

		temperature_math_01[r_id] = temperature
		temperature_math_02[r_id] = volume * R.temperature_mod
		math_02_total += temperature_math_02[r_id]

	for(var/r_id in temperature_math_01)
		average_temperature += temperature_math_01[r_id] * (temperature_math_02[r_id] / math_02_total)

	var/total_reagents = length(stored_reagents)

	if(total_reagents)
		color = rgb(red/volume_current,green/volume_current,blue/volume_current)
	else
		color = "#FFFFFF"
		average_temperature = T0C+20

	if(owner && should_update_owner)
		owner.update_icon()

	return TRUE


/reagent_container/proc/process_recipes()

	var/list/c_id_to_volume = list() //What is in the reagent container, but in a nice id = volume form
	var/list/c_id_to_temperature = list()

	for(var/reagent_id in stored_reagents)
		c_id_to_volume[reagent_id] = stored_reagents[reagent_id]
		c_id_to_temperature[reagent_id] = stored_reagents_temperature[reagent_id]

	var/reagent_recipe/found_recipe = null

	for(var/k in all_reagent_recipes)

		var/reagent_recipe/recipe = all_reagent_recipes[k]

		if(!length(recipe.required_reagents))
			continue

		var/good_recipe = TRUE

		for(var/reagent_id in recipe.required_reagents)
			if(!c_id_to_volume[reagent_id] || c_id_to_volume[reagent_id] < recipe.required_reagents[reagent_id]) //if our container doesn't have what is required, then lets fuck off.
				good_recipe = FALSE
				break

			if(recipe.required_temperature_min[reagent_id] && c_id_to_temperature[reagent_id] < recipe.required_temperature_min[reagent_id])
				good_recipe = FALSE
				break

			if(recipe.required_temperature_max[reagent_id] && c_id_to_temperature[reagent_id] > recipe.required_temperature_max[reagent_id])
				good_recipe = FALSE
				break


		if(!good_recipe) //This recipe doesn't work. Onto the next recipe.
			continue

		found_recipe = recipe
		break

	if(!found_recipe)
		return FALSE

	//Okay now we figure out math bullshit.

	var/portions_to_make

	for(var/k in found_recipe.required_reagents)
		var/required_amount = found_recipe.required_reagents[k]
		var/current_volume = c_id_to_volume[k]
		var/math_to_do = current_volume / required_amount

		if(!portions_to_make)
			portions_to_make = math_to_do
			continue

		portions_to_make = min(portions_to_make,math_to_do)

	var/amount_removed = 0

	var/desired_temperature = average_temperature

	world.log << "We're going to be making [portions_to_make] portions."

	for(var/k in found_recipe.required_reagents)
		var/required_amount = found_recipe.required_reagents[k]
		var/amount_to_remove = portions_to_make * required_amount
		remove_reagent(k,amount_to_remove,FALSE,FALSE)
		amount_removed += amount_to_remove
		world.log << "Removing: [k] [amount_to_remove]"

	update_container()

	for(var/k in found_recipe.results)
		var/v = found_recipe.results[k] * portions_to_make
		add_reagent(k,v,desired_temperature,FALSE,FALSE)
		world.log << "Adding: [k] [v]"

	update_container()

	if(found_recipe.result && owner && !istype(owner,found_recipe.result))
		while(volume_current > 0)
			var/obj/item/A = new found_recipe.result(get_turf(owner))
			if(!A.reagents)
				break
			transfer_reagents_to(A.reagents,min(A.reagents.volume_max - A.reagents.volume_current,volume_current))

	return TRUE

/reagent_container/proc/add_reagent(var/reagent_id,var/amount=0, var/temperature = TNULL, var/should_update = TRUE,var/check_recipes = TRUE)

	if(!all_reagents[reagent_id])
		LOG_ERROR("Reagent Error: Tried to add/remove a null reagent ([reagent_id]) (ID) to [owner]!")
		return 0

	if(amount == 0)
		LOG_ERROR("Reagent Error: Tried to add/remove 0 units of [reagent_id] (ID) to [owner]!")
		return 0

	if(temperature == TNULL)
		if(owner)
			var/area/A = get_area(owner)
			temperature = A.ambient_temperature
		else
			temperature = T0C + 20

	var/previous_amount = stored_reagents[reagent_id] ? stored_reagents[reagent_id] : 0
	var/previous_temp = stored_reagents_temperature[reagent_id] ? stored_reagents_temperature[reagent_id] : 0

	if(volume_current + amount > volume_max)
		amount = volume_max - volume_current

	if(amount == 0)
		return 0

	if(stored_reagents[reagent_id])
		stored_reagents[reagent_id] += amount
	else
		stored_reagents[reagent_id] = amount

	if(amount > 0)
		if(stored_reagents_temperature[reagent_id] && stored_reagents[reagent_id])
			stored_reagents_temperature[reagent_id] = ( (previous_amount*previous_temp) + (amount*temperature) ) / (stored_reagents[reagent_id])
		else
			stored_reagents_temperature[reagent_id] = temperature

	if(check_recipes)
		process_recipes()

	if(should_update)
		update_container()

	return amount

/reagent_container/proc/remove_reagent(var/reagent_id,var/amount=0,var/should_update = TRUE,var/check_recipes = TRUE)
	return -add_reagent(reagent_id,-amount,TNULL,should_update,check_recipes)

/reagent_container/proc/transfer_reagent_to(var/reagent_container/target_container,var/reagent_id,var/amount=0,var/should_update = TRUE, var/check_recipes = TRUE) //Transfer a single reagent by id.
	var/old_temperature = stored_reagents_temperature[reagent_id] ? stored_reagents_temperature[reagent_id] : T0C + 20
	return target_container.add_reagent(reagent_id,remove_reagent(reagent_id,amount,should_update,check_recipes),old_temperature,should_update,check_recipes)

/reagent_container/proc/transfer_reagents_to(var/reagent_container/target_container,var/amount=0,var/should_update=TRUE,var/check_recipes = TRUE) //Transfer all the reagents.

	if(amount == 0)
		return FALSE

	if(amount < 0)
		return -target_container.transfer_reagents_to(src,-amount,should_update,check_recipes)

	amount = min(amount,volume_current)

	var/total_amount_transfered = 0

	var/old_volume = volume_current

	for(var/r_id in stored_reagents)
		var/volume = stored_reagents[r_id]
		var/ratio = volume / old_volume
		var/temp = stored_reagents_temperature[r_id]

		var/amount_transfered = target_container.add_reagent(r_id,ratio*amount,temp,FALSE,FALSE)
		remove_reagent(r_id,amount_transfered,FALSE)
		total_amount_transfered += amount_transfered

	if(check_recipes)
		src.process_recipes()
		target_container.process_recipes()

	if(should_update)
		src.update_container()
		target_container.update_container()

	return total_amount_transfered



/reagent_container/proc/get_flavor()

	var/list/flavor_profile = list()

	var/total_flavor = 0

	for(var/r_id in stored_reagents)
		var/reagent/R = all_reagents[r_id]
		flavor_profile[R.flavor] += R.flavor_strength
		total_flavor += R.flavor_strength

	InsertionSort(flavor_profile)

	var/list/english_flavor_profile = list()

	for(var/i=1,i<=min(3,length(flavor_profile)),i++)
		var/k = flavor_profile[i]
		var/v = flavor_profile[k] / total_flavor
		var/flavor_text
		switch(v)
			if(0 to 0.25)
				flavor_text = "a hint of [k]"
			if(0.25 to 0.5)
				flavor_text = "a little bit of [k]"
			if(0.5 to 1)
				flavor_text = k
			if(1 to 2)
				flavor_text = "a strong amount of [k]"
			if(2 to INFINITY)
				flavor_text = "an overwhelming amount of [k]"

		english_flavor_profile += flavor_text

	return english_list(english_flavor_profile)