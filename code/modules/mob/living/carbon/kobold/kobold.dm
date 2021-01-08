/mob/living/carbon/kobold
	name = "kobold"
	desc = "A cute anthro lizard. Very small."
	icon = 'icons/mob/kobold_parts_greyscale.dmi'
	icon_state = ""
	verb_say = list("hisses")
	initial_language_holder = /datum/language_holder/kobold
	gender = NEUTER
	health = 40
	maxHealth = 40
	faction = list("lizard")
	unique_name = FALSE
	//exotic_bloodtype = "L"
	//Edit bloodtype later
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard = 1, /obj/item/stack/sheet/animalhide/lizard = 1)
	type_of_meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/lizard
	gib_type = /obj/effect/decal/cleanable/blood/gibs
	ventcrawler = VENTCRAWLER_NUDE
	bodyparts = list(/obj/item/bodypart/chest/kobold, /obj/item/bodypart/head/kobold, /obj/item/bodypart/l_arm/kobold,
					 /obj/item/bodypart/r_arm/kobold, /obj/item/bodypart/r_leg/kobold, /obj/item/bodypart/l_leg/kobold)

	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST, MOB_REPTILE)

/mob/living/carbon/kobold/create_internal_organs() //You might want to hold onto these.
	internal_organs += new /obj/item/organ/appendix
	internal_organs += new /obj/item/organ/lungs/kobold //special tiny lizard lungs! For special atmos.
	internal_organs += new /obj/item/organ/heart
	internal_organs += new /obj/item/organ/brain //gets smart but your head gets dumb.
	internal_organs += new /obj/item/organ/tongue
	internal_organs += new /obj/item/organ/eyes
	internal_organs += new /obj/item/organ/ears
	internal_organs += new /obj/item/organ/liver
	internal_organs += new /obj/item/organ/stomach
	internal_organs += new /obj/item/organ/tail/lizard //You better not do what I think you're going to.
	..()


	create_dna(src)

/mob/living/carbon/kobold/Initialize()
		//initialize limbs//
	create_bodyparts() //makes sure our little lizard has a body
	create_internal_organs() //might need those too
	. = ..()
	gender = pick(MALE, FEMALE, NEUTER)
		//color code(?)//
	var/koboldcolor = pick("#6be4ff", "#d62121", "#9cfd8f", "#7112b1", "#fca624", "#ffffff")
	color = koboldcolor

/mob/living/carbon/kobold/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Intent: [a_intent]")
		stat(null, "Move Mode: [m_intent]")
		if(client && mind)
			var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
			if(changeling)
				stat("Chemical Storage", "[changeling.chem_charges]/[changeling.chem_storage]")
				stat("Absorbed DNA", changeling.absorbedcount)
	return

/*OLD COLOR CODE (keep in case of emergency)
/mob/living/carbon/kobold/proc/hidecolor() // proc since it wasn't defined in parent
  var/list/colours = list("red", "blue", "green")
  var/picked = pick(colours)
  icon_state = "[initial(icon_state)]_[picked]" // example: we picked red, so the icon state is set to kobold_red

/mob/living/carbon/kobold/Initialize()
  ..() // call the parent's Initialize, just to make sure we don't break shit
  hidecolor()*/ // now call hidecolor(), so we set our color correctly



