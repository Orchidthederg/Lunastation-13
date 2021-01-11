//NOTE: A decent amount of this code was stolen from /carbon/monkey/combat.dm
#define MAX_RANGE_FIND_K 32

/mob/living/carbon/kobold
	var/aggressive=0 // set to 1 using VV for an angry kobold
	var/frustration=0
	var/pickupTimer=0
	var/list/enemies = list()
	var/mob/living/target
	var/obj/item/pickupTarget
	var/mode = KOBOLD_IDLE
	var/list/myPath = list()
	var/list/blacklistItems = list()
	var/maxStepsTick = 6
	var/best_force = 0
	var/martial_art = new/datum/martial_art
	var/resisting = FALSE
	var/pickpocketing = FALSE
	var/disposing_body = FALSE
	var/obj/machinery/disposal/bodyDisposal = null
	var/next_battle_screech = 0
	var/battle_screech_cooldown = 50

/mob/living/carbon/kobold/proc/IsStandingStill()
	return resisting || pickpocketing || disposing_body

// blocks
// taken from /mob/living/carbon/human/interactive
/mob/living/carbon/kobold/proc/walk2derpless(target)
	if(!target || IsStandingStill())
		return 0

	if(myPath.len <= 0)
		myPath = get_path_to(src, get_turf(target), /turf/proc/Distance, MAX_RANGE_FIND_K + 1, 250,1)

	if(myPath)
		if(myPath.len > 0)
			for(var/i = 0; i < maxStepsTick; ++i)
				if(!IsDeadOrIncap())
					if(myPath.len >= 1)
						walk_to(src,myPath[1],0,5)
						myPath -= myPath[1]
			return 1

// taken from /mob/living/carbon/human/interactive
/mob/living/carbon/kobold/proc/IsDeadOrIncap(checkDead = TRUE)
	if(!CHECK_MOBILITY(src, MOBILITY_MOVE))
		return TRUE
	if(health <= 0 && checkDead)
		return TRUE
	return FALSE

/mob/living/carbon/kobold/proc/battle_screech()
	if(next_battle_screech < world.time)
		emote(pick("hiss","growl"))
		for(var/mob/living/carbon/kobold/K in view(7,src))
			K.next_battle_screech = world.time + battle_screech_cooldown

/mob/living/carbon/kobold/proc/equip_item(var/obj/item/I)

	if(I.loc == src)
		return TRUE

	if(I.anchored || !put_in_hands(I))
		blacklistItems[I] ++
		return FALSE

	if(I.force >= best_force)
		best_force = I.force
	else
		addtimer(CALLBACK(src, .proc/pickup_and_wear, I), 5)

	return TRUE

/mob/living/carbon/kobold/proc/pickup_and_wear(obj/item/I)
	if(QDELETED(I) || I.loc != src)
		return
	equip_to_appropriate_slot(I)

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

/mob/living/carbon/kobold/proc/should_target(var/mob/living/L)
	if(HAS_TRAIT(src, TRAIT_PACIFISM))
		return FALSE

	if(enemies[L])
		return TRUE

	// target non-kobold mobs when aggressive, with a small probability of kobold v kobold
	if(aggressive && (!istype(L, /mob/living/carbon/kobold/) || prob(KOBOLD_AGGRESSIVE_KVK_PROB)))
		return TRUE

	return FALSE

/mob/living/carbon/kobold/proc/handle_combat()
	if(pickupTarget)
		if(restrained() || blacklistItems[pickupTarget] || HAS_TRAIT(pickupTarget, TRAIT_NODROP))
			pickupTarget = null
		else if(!isobj(loc) || istype(loc, /obj/item/clothing/head/mob_holder))
			pickupTimer++
			if(pickupTimer >= 4)
				blacklistItems[pickupTarget] ++
				pickupTarget = null
				pickupTimer = 0
			else
				INVOKE_ASYNC(src, .proc/walk2derpless, pickupTarget.loc)
				if(Adjacent(pickupTarget) || Adjacent(pickupTarget.loc)) // next to target
					drop_all_held_items() // who cares about these items, i want that one!
					if(isturf(pickupTarget.loc)) // on floor
						equip_item(pickupTarget)
						pickupTarget = null
						pickupTimer = 0
					else if(ismob(pickupTarget.loc)) // in someones hand
						if(istype(pickupTarget, /obj/item/clothing/head/mob_holder))
							return//dont let them pickpocket themselves or hold other kobblers.
						var/mob/K = pickupTarget.loc
						if(!pickpocketing)
							pickpocketing = TRUE
							K.visible_message("[src] starts trying to take [pickupTarget] from [K]", "[src] tries to take [pickupTarget]!")
							INVOKE_ASYNC(src, .proc/pickpocket, K)
			return TRUE

/mob/living/carbon/kobold/proc/pickpocket(var/mob/K)
	if(do_mob(src, K, KOBOLD_ITEM_SNATCH_DELAY) && pickupTarget)
		for(var/obj/item/I in K.held_items)
			if(I == pickupTarget)
				K.visible_message("<span class='danger'>[src] snatches [pickupTarget] from [K].</span>", "<span class='userdanger'>[src] snatched [pickupTarget]!</span>")
				if(K.temporarilyRemoveItemFromInventory(pickupTarget) && !QDELETED(pickupTarget))
					if(!equip_item(pickupTarget))
						dropItemToGround(pickupTarget)
				else
					K.visible_message("<span class='danger'>[src] tried to snatch [pickupTarget] from [K], but failed!</span>", "<span class='userdanger'>[src] tried to grab [pickupTarget]!</span>")
	pickpocketing = FALSE
	pickupTarget = null
	pickupTimer = 0

/mob/living/carbon/kobold/proc/stuff_mob_in()
	if(bodyDisposal && target && Adjacent(bodyDisposal))
		bodyDisposal.stuff_mob_in(target, src)
	disposing_body = FALSE
	back_to_idle()

/mob/living/carbon/kobold/proc/back_to_idle()

	if(pulling)
		stop_pulling()

	mode = KOBOLD_IDLE
	target = null
	a_intent = INTENT_HELP
	frustration = 0
	walk_to(src,0)

// attack using a held weapon otherwise bite the enemy, then if we are angry there is a chance we might calm down a little
/mob/living/carbon/kobold/proc/kobold_attack(mob/living/L)
	var/obj/item/Weapon = locate(/obj/item) in held_items

	// attack with weapon if we have one
	if(Weapon)
		L.attackby(Weapon, src)
	else
		L.attack_paw(src)

	// no de-aggro
	if(aggressive)
		return

	// if we arn't enemies, we were likely recruited to attack this target, jobs done if we calm down so go back to idle
	if(!enemies[L])
		if( target == L && prob(KOBOLD_HATRED_REDUCTION_PROB) )
			back_to_idle()
		return // already de-aggroed

	if(prob(KOBOLD_HATRED_REDUCTION_PROB))
		enemies[L] --

	// if we are not angry at our target, go back to idle
	if(enemies[L] <= 0)
		enemies.Remove(L)
		if( target == L )
			back_to_idle()

// get angry are a mob
/mob/living/carbon/kobold/proc/retaliate(mob/living/L)
	mode = KOBOLD_HUNT
	target = L
	if(L != src)
		enemies[L] += KOBOLD_HATRED_AMOUNT

	if(a_intent != INTENT_HARM)
		battle_screech()
		a_intent = INTENT_HARM

/mob/living/carbon/kobold/attack_hand(mob/living/L)
	if(L.a_intent == INTENT_HARM && prob(KOBOLD_RETALIATE_HARM_PROB))
		retaliate(L)
	else if(L.a_intent == INTENT_DISARM && prob(KOBOLD_RETALIATE_DISARM_PROB))
		retaliate(L)
	return ..()

/mob/living/carbon/kobold/attack_alien(mob/living/carbon/alien/humanoid/K)
	if(K.a_intent == INTENT_HARM && prob(KOBOLD_RETALIATE_HARM_PROB))
		retaliate(K)
	else if(K.a_intent == INTENT_DISARM && prob(KOBOLD_RETALIATE_DISARM_PROB))
		retaliate(K)
	return ..()

/mob/living/carbon/kobold/attack_larva(mob/living/carbon/alien/larva/L)
	if(L.a_intent == INTENT_HARM && prob(KOBOLD_RETALIATE_HARM_PROB))
		retaliate(L)
	return ..()

/mob/living/carbon/kobold/attack_hulk(mob/living/carbon/human/user, does_attack_animation = FALSE)
	if(user.a_intent == INTENT_HARM && prob(KOBOLD_RETALIATE_HARM_PROB))
		retaliate(user)
	return ..()

/mob/living/carbon/kobold/attack_paw(mob/living/L)
	if(L.a_intent == INTENT_HARM && prob(KOBOLD_RETALIATE_HARM_PROB))
		retaliate(L)
	else if(L.a_intent == INTENT_DISARM && prob(KOBOLD_RETALIATE_DISARM_PROB))
		retaliate(L)
	return ..()

/mob/living/carbon/kobold/attackby(obj/item/W, mob/user, params)
	..()
	if((W.force) && (!target) && (W.damtype != STAMINA) )
		retaliate(user)

/mob/living/carbon/kobold/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj , /obj/item/projectile/beam)||istype(Proj, /obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health && isliving(Proj.firer))
				retaliate(Proj.firer)
	return ..()

/mob/living/carbon/kobold/proc/koboldDrop(var/obj/item/A)
	if(A)
		dropItemToGround(A, TRUE)
		update_icons()

/mob/living/carbon/kobold/grabbedby(mob/living/carbon/user)
	. = ..()
	if(!IsDeadOrIncap() && pulledby && (mode != KOBOLD_IDLE || prob(KOBOLD_PULL_AGGRO_PROB))) // nuh uh you don't pull me!
		if(Adjacent(pulledby))
			a_intent = INTENT_DISARM
			kobold_attack(pulledby)
			retaliate(pulledby)
			return TRUE

#undef MAX_RANGE_FIND_K
