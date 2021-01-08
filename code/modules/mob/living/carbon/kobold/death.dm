/mob/living/carbon/kobold/death(gibbed)
	walk(src,0) // Stops dead kobolds from fleeing their attacker or climbing out from inside His Grace
	. = ..()