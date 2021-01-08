#define MAX_RANGE_FIND 32

/mob/living/carbon/kobold
	var/mob/living/target
	var/obj/item/pickupTarget
	var/list/myPath = list()
	var/list/blacklistItems = list()
	var/maxStepsTick = 6
	var/resisting = FALSE
	var/pickpocketing = FALSE

/mob/living/carbon/kobold/proc/IsStandingStill()
	return resisting || pickpocketing

// blocks
// taken from /mob/living/carbon/human/interactive/
/mob/living/carbon/kobold/proc/walk2derpless(target)
	if(!target || IsStandingStill())
		return 0

	if(myPath.len <= 0)
		myPath = get_path_to(src, get_turf(target), /turf/proc/Distance, MAX_RANGE_FIND + 1, 250,1)

	if(myPath)
		if(myPath.len > 0)
			for(var/i = 0; i < maxStepsTick; ++i)
				if(!IsDeadOrIncap())
					if(myPath.len >= 1)
						walk_to(src,myPath[1],0,5)
						myPath -= myPath[1]
			return 1

	// failed to path correctly so just try to head straight for a bit
	walk_to(src,get_turf(target),0,5)
	sleep(1)
	walk_to(src,0)

	return 0

// taken from /mob/living/carbon/human/interactive/
/mob/living/carbon/kobold/proc/IsDeadOrIncap(checkDead = TRUE)
	if(!canmove)
		return 1
	if(health <= 0 && checkDead)
		return 1
	if(IsUnconscious())
		return 1
	if(IsStun() || IsKnockdown())
		return 1
	if(stat)
		return 1
	return 0

/mob/living/carbon/kobold/resist_restraints()
	var/obj/item/I = null
	if(handcuffed)
		I = handcuffed
	else if(legcuffed)
		I = legcuffed
	if(I)
		changeNext_move(CLICK_CD_BREAKOUT)
		last_special = world.time + CLICK_CD_BREAKOUT
		cuff_resist(I)

#undef MAX_RANGE_FIND
