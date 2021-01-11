//Kobold defines, placed here so they can be read by other things!

//Mode defines
#define KOBOLD_IDLE 			0	// idle
#define KOBOLD_HUNT 			1	// found target, hunting
#define KOBOLD_FLEE 			2	// free from enemies
#define KOBOLD_DISPOSE 			3	// dump body in disposals

#define KOBOLD_FLEE_HEALTH 					75	// below this health value the kobold starts to flee from enemies
#define KOBOLD_ENEMY_VISION 				9	// how close an enemy must be to trigger aggression
#define KOBOLD_FLEE_VISION					7	// how close an enemy must be before it triggers flee
#define KOBOLD_ITEM_SNATCH_DELAY 			10	// How long does it take the item to be taken from a mobs hand
#define KOBOLD_CUFF_RETALIATION_PROB		50  // Probability kobold will aggro when cuffed
#define KOBOLD_SYRINGE_RETALIATION_PROB		20  // Probability kobold will aggro when syringed

// Probability per Life tick that the kobold will:
#define KOBOLD_RESIST_PROB 					50	// resist out of restraints
												// when the kobold is idle
#define KOBOLD_PULL_AGGRO_PROB 				5		// aggro against the mob pulling it
#define KOBOLD_SHENANIGAN_PROB 				5		// chance of getting into mischief, i.e. finding/stealing items
												// when the kobold is hunting
#define KOBOLD_ATTACK_DISARM_PROB 			50		// disarm an armed attacker
#define KOBOLD_WEAPON_PROB 					20		// if not currently getting an item, search for a weapon around it
#define KOBOLD_RECRUIT_PROB 				25		// recruit a kobold near it
#define KOBOLD_SWITCH_TARGET_PROB 			25		// switch targets if it sees another enemy

#define KOBOLD_RETALIATE_HARM_PROB 			75	// probability for the kobold to aggro when attacked with harm intent
#define KOBOLD_RETALIATE_DISARM_PROB 		50 	// probability for the kobold to aggro when attacked with disarm intent

#define KOBOLD_HATRED_AMOUNT 				4	// amount of aggro to add to an enemy when they attack user
#define KOBOLD_HATRED_REDUCTION_PROB 		50	// probability of reducing aggro by one when the kobold attacks

// how many Life ticks the kobold will fail to:
#define KOBOLD_HUNT_FRUSTRATION_LIMIT 		10	// Chase after an enemy before giving up
#define KOBOLD_DISPOSE_FRUSTRATION_LIMIT 	20 	// Dispose of a body before giving up

#define KOBOLD_AGGRESSIVE_KVK_PROB			5	// If you mass edit kobblers to be aggressive. there is a small chance of in-fighting
