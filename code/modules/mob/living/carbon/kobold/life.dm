/mob/living/carbon/kobold


/mob/living/carbon/kobold/Life()
	set invisibility = 0

	if (notransform)
		return

	if(..() && !IsInStasis())

		if(!client)
			if(stat == CONSCIOUS)
				if(on_fire || buckled || restrained() || (resting && canmove)) //CIT CHANGE - makes it so monkeys attempt to resist if they're resting)
					if(!resisting && prob(MONKEY_RESIST_PROB))
						resisting = TRUE
						walk_to(src,0)
						resist()
				else if(resisting)
					resisting = FALSE
	. = ..()

/mob/living/carbon/kobold/proc/get_cold_protection()
	

/mob/living/carbon/kobold/handle_environment(datum/gas_mixture/environment)
	if(!environment)
		return

	var/loc_temp = get_temperature(environment)

	if(stat != DEAD)
		adjust_bodytemperature(natural_bodytemperature_stabilization())

	if(!on_fire) //If you're on fire, you do not heat up or cool down based on surrounding gases
		if(loc_temp < bodytemperature)
			adjust_bodytemperature(max((loc_temp - bodytemperature) / BODYTEMP_COLD_DIVISOR, BODYTEMP_COOLING_MAX))
		else
			adjust_bodytemperature(min((loc_temp - bodytemperature) / BODYTEMP_HEAT_DIVISOR, BODYTEMP_HEATING_MAX))

/mob/living/carbon/kobold/handle_fire()
	. = ..()
	if(on_fire)

		//the fire tries to damage the exposed clothes and items
		var/list/burning_items = list()
		//HEAD//
		var/obj/item/clothing/head_clothes = null
		if(wear_mask)
			head_clothes = wear_mask
		if(wear_neck)
			head_clothes = wear_neck
		if(head)
			burning_items += head_clothes

		for(var/X in burning_items)
			var/obj/item/I = X
			if(!(I.resistance_flags & FIRE_PROOF))
				I.take_damage(fire_stacks, BURN, "fire", 0)


/mob/living/carbon/kobold/breathe()
	if(!dna.species.breathe(src))
		..()

/mob/living/carbon/kobold/check_breath(datum/gas_mixture/breath)

	var/L = getorganslot(ORGAN_SLOT_LUNGS)

	if(!L)
		if(health >= crit_threshold)
			adjustOxyLoss(HUMAN_MAX_OXYLOSS + 1)
		else if(!HAS_TRAIT(src, TRAIT_NOCRITDAMAGE))
			adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		failed_last_breath = 1

		var/datum/species/S = dna.species

		if(S.breathid == "o2")
			throw_alert("not_enough_oxy", /obj/screen/alert/not_enough_oxy)
		else if(S.breathid == "tox")
			throw_alert("not_enough_tox", /obj/screen/alert/not_enough_tox)
		else if(S.breathid == "co2")
			throw_alert("not_enough_co2", /obj/screen/alert/not_enough_co2)
		else if(S.breathid == "n2")
			throw_alert("not_enough_nitro", /obj/screen/alert/not_enough_nitro)

		return FALSE
	else
		if(istype(L, /obj/item/organ/lungs/kobold))
			var/obj/item/organ/lungs/lung = L
			lung.check_breath(breath,src)

/mob/living/carbon/kobold/handle_environment(datum/gas_mixture/environment)
	dna.species.handle_environment(environment, src)