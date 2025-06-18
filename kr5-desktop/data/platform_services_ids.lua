-- chunkname: @./kr5-desktop/data/platform_services_ids.lua

require("constants")
require("version")

local ids = {}

ids.gamecenter = {}
ids.gamecenter.achievements = {
	ROCK_BEATS_ROCK = "kr5mac.ROCK_BEATS_ROCK",
	GEM_SPILLER = "kr5mac.GEM_SPILLER",
	WE_ARE_ALL_MAD_HERE = "kr5mac.WE_ARE_ALL_MAD_HERE",
	ROYAL_CAPTAIN = "kr5mac.ROYAL_CAPTAIN",
	CRAFTING_IN_THE_MINES = "kr5mac.CRAFTING_IN_THE_MINES",
	NATURES_WRATH = "kr5mac.NATURES_WRATH",
	AGE_OF_HEROES = "kr5mac.AGE_OF_HEROES",
	KEPT_YOU_WAITING = "kr5mac.KEPT_YOU_WAITING",
	FOREST_PROTECTOR = "kr5mac.FOREST_PROTECTOR",
	CONJUNTIVICTORY = "kr5mac.CONJUNTIVICTORY",
	BREAKER_OF_CHAINS = "kr5mac.BREAKER_OF_CHAINS",
	ITS_A_SECRET_TO_EVERYONE = "kr5mac.ITS_A_SECRET_TO_EVERYONE",
	PORKS_OFF_THE_MENU = "kr5mac.PORKS_OFF_THE_MENU",
	OVINE_JOURNALISM = "kr5mac.OVINE_JOURNALISM",
	NOT_A_MOMENT_TO_WASTE = "kr5mac.NOT_A_MOMENT_TO_WASTE",
	SILVER_FOR_MONSTERS = "kr5mac.SILVER_FOR_MONSTERS",
	UNBOUND_VICTORY = "kr5mac.UNBOUND_VICTORY",
	GREENLIT_ALLIES = "kr5mac.GREENLIT_ALLIES",
	CROW_SCARER = "kr5mac.CROW_SCARER",
	SIGNATURE_TECHNIQUES = "kr5mac.SIGNATURE_TECHNIQUES",
	FIELD_TRIP_RUINER = "kr5mac.FIELD_TRIP_RUINER",
	CLEANSE_THE_KING = "kr5mac.CLEANSE_THE_KING",
	SPECTRAL_FURY = "kr5mac.SPECTRAL_FURY",
	SMOOTH_OPER_GATOR = "kr5mac.SMOOTH_OPER_GATOR",
	CONQUEROR_OF_THE_VOID = "kr5mac.CONQUEROR_OF_THE_VOID",
	UNENDING_RICHES = "kr5mac.UNENDING_RICHES",
	MECHANICAL_BURNOUT = "kr5mac.MECHANICAL_BURNOUT",
	HAIL_TO_THE_K_BABY = "kr5mac.HAIL_TO_THE_K_BABY",
	NO_FLY_ZONE = "kr5mac.NO_FLY_ZONE",
	DOMO_ARIGATO = "kr5mac.DOMO_ARIGATO",
	DARK_RUTHLESSNESS = "kr5mac.DARK_RUTHLESSNESS",
	PEST_CONTROL = "kr5mac.PEST_CONTROL",
	OBLITERATE = "kr5mac.OBLITERATE",
	SEE_YA_LATER_ALLIGATOR = "kr5mac.SEE_YA_LATER_ALLIGATOR",
	MOST_DELICIOUS = "kr5mac.MOST_DELICIOUS",
	CRYSTAL_CLEAR = "kr5mac.CRYSTAL_CLEAR",
	NONE_SHALL_PASS = "kr5mac.NONE_SHALL_PASS",
	YOU_SHALL_NOT_CAST = "kr5mac.YOU_SHALL_NOT_CAST",
	RUNEQUEST = "kr5mac.RUNEQUEST",
	PLAYFUL_FRIENDS = "kr5mac.PLAYFUL_FRIENDS",
	SAVIOUR_OF_THE_FOREST = "kr5mac.SAVIOUR_OF_THE_FOREST",
	SHUT_YOUR_MOUTH = "kr5mac.SHUT_YOUR_MOUTH",
	DLC1_WIN_BOSS = "kr5mac.DLC1_WIN_BOSS",
	A_COON_OF_SURPRISES = "kr5mac.A_COON_OF_SURPRISES",
	WEIRDER_THINGS = "kr5mac.WEIRDER_THINGS",
	LUCAS_SPIDER = "kr5mac.LUCAS_SPIDER",
	FACTORY_STRIKE = "kr5mac.FACTORY_STRIKE",
	ARACHNED = "kr5mac.ARACHNED",
	MIGHTY_II = "kr5mac.MIGHTY_II",
	SAVIOUR_OF_THE_GREEN = "kr5mac.SAVIOUR_OF_THE_GREEN",
	IRONCLAD = "kr5mac.IRONCLAD",
	TAKE_ME_HOME = "kr5mac.TAKE_ME_HOME",
	TIPPING_THE_SCALES = "kr5mac.TIPPING_THE_SCALES",
	THE_CAVALRY_IS_HERE = "kr5mac.THE_CAVALRY_IS_HERE",
	OUTBACK_BARBEQUICK = "kr5mac.OUTBACK_BARBEQUICK",
	ONE_SHOT_TOWER = "kr5mac.ONE_SHOT_TOWER",
	OVER_THE_EDGE = "kr5mac.OVER_THE_EDGE",
	STARLIGHT = "kr5mac.STARLIGHT",
	BUTTERTENTACLES = "kr5mac.BUTTERTENTACLES",
	INTO_THE_OGREVERSE = "kr5mac.INTO_THE_OGREVERSE",
	PROMOTION_DENIED = "kr5mac.PROMOTION_DENIED",
	RUST_IN_PEACE = "kr5mac.RUST_IN_PEACE",
	WAR_MASONRY = "kr5mac.WAR_MASONRY",
	MIGHTY_I = "kr5mac.MIGHTY_I",
	MIGHTY_III = "kr5mac.MIGHTY_III",
	ALL_THE_SMALL_THINGS = "kr5mac.ALL_THE_SMALL_THINGS",
	LEARNING_THE_ROPES = "kr5mac.LEARNING_THE_ROPES",
	LINIREAN_RESISTANCE = "kr5mac.LINIREAN_RESISTANCE",
	SEASONED_GENERAL = "kr5mac.SEASONED_GENERAL",
	DISTURBING_THE_PEACE = "kr5mac.DISTURBING_THE_PEACE",
	GARBAGE_DISPOSAL = "kr5mac.GARBAGE_DISPOSAL",
	GET_THE_PARTY_STARTED = "kr5mac.GET_THE_PARTY_STARTED",
	TREE_HUGGER = "kr5mac.TREE_HUGGER",
	DARK_LIEUTENANT = "kr5mac.DARK_LIEUTENANT",
	BYE_BYE_BEAUTIFUL = "kr5mac.BYE_BYE_BEAUTIFUL",
	GIFT_OF_LIFE = "kr5mac.GIFT_OF_LIFE",
	UNTAMED_BEAST = "kr5mac.UNTAMED_BEAST",
	TURN_A_BLIND_EYE = "kr5mac.TURN_A_BLIND_EYE",
	WE_RE_NOT_GONNA_TAKE_IT = "kr5mac.WE_RE_NOT_GONNA_TAKE_IT",
	CLEANUP_IS_OPTIONAL = "kr5mac.CLEANUP_IS_OPTIONAL",
	CROWD_CONTROL = "kr5mac.CROWD_CONTROL",
	WOBBA_LUBBA_DUB_DUB = "kr5mac.WOBBA_LUBBA_DUB_DUB",
	MASTER_TACTICIAN = "kr5mac.MASTER_TACTICIAN",
	SCRAMBLED_EGGS = "kr5mac.SCRAMBLED_EGGS",
	CIRCLE_OF_LIFE = "kr5mac.CIRCLE_OF_LIFE"
}
ids.gamecenter.achievements_metadata = {
	LEARNING_THE_ROPES = {
		5,
		false
	},
	TIPPING_THE_SCALES = {
		5,
		false
	},
	FIELD_TRIP_RUINER = {
		5,
		false
	},
	ITS_A_SECRET_TO_EVERYONE = {
		5,
		false
	},
	CIRCLE_OF_LIFE = {
		5,
		false
	},
	PLAYFUL_FRIENDS = {
		5,
		false
	},
	MOST_DELICIOUS = {
		5,
		false
	},
	NATURES_WRATH = {
		5,
		false
	},
	MIGHTY_I = {
		5,
		false
	},
	GREENLIT_ALLIES = {
		5,
		false
	},
	OVER_THE_EDGE = {
		5,
		false
	},
	CLEANUP_IS_OPTIONAL = {
		5,
		false
	},
	RUNEQUEST = {
		5,
		false
	},
	NONE_SHALL_PASS = {
		5,
		false
	},
	CRAFTING_IN_THE_MINES = {
		5,
		false
	},
	PORKS_OFF_THE_MENU = {
		5,
		false
	},
	OUTBACK_BARBEQUICK = {
		5,
		false
	},
	SAVIOUR_OF_THE_GREEN = {
		5,
		false
	},
	NOT_A_MOMENT_TO_WASTE = {
		5,
		false
	},
	SILVER_FOR_MONSTERS = {
		5,
		false
	},
	CROW_SCARER = {
		5,
		false
	},
	WE_RE_NOT_GONNA_TAKE_IT = {
		5,
		false
	},
	BREAKER_OF_CHAINS = {
		5,
		false
	},
	GEM_SPILLER = {
		5,
		false
	},
	UNBOUND_VICTORY = {
		5,
		false
	},
	GET_THE_PARTY_STARTED = {
		5,
		false
	},
	WAR_MASONRY = {
		5,
		false
	},
	PROMOTION_DENIED = {
		5,
		false
	},
	STARLIGHT = {
		5,
		false
	},
	CLEANSE_THE_KING = {
		10,
		false
	},
	YOU_SHALL_NOT_CAST = {
		5,
		false
	},
	CRYSTAL_CLEAR = {
		10,
		false
	},
	MIGHTY_II = {
		10,
		false
	},
	ALL_THE_SMALL_THINGS = {
		5,
		false
	},
	THE_CAVALRY_IS_HERE = {
		5,
		false
	},
	WEIRDER_THINGS = {
		5,
		false
	},
	OVINE_JOURNALISM = {
		5,
		false
	},
	ONE_SHOT_TOWER = {
		5,
		false
	},
	CROWD_CONTROL = {
		5,
		false
	},
	WOBBA_LUBBA_DUB_DUB = {
		5,
		false
	},
	PEST_CONTROL = {
		5,
		false
	},
	TURN_A_BLIND_EYE = {
		5,
		false
	},
	TAKE_ME_HOME = {
		5,
		false
	},
	BUTTERTENTACLES = {
		5,
		false
	},
	BYE_BYE_BEAUTIFUL = {
		10,
		false
	},
	CONJUNTIVICTORY = {
		10,
		false
	},
	CONQUEROR_OF_THE_VOID = {
		10,
		false
	},
	LINIREAN_RESISTANCE = {
		5,
		false
	},
	DARK_RUTHLESSNESS = {
		5,
		false
	},
	UNENDING_RICHES = {
		5,
		false
	},
	SIGNATURE_TECHNIQUES = {
		5,
		false
	},
	ROYAL_CAPTAIN = {
		5,
		false
	},
	DARK_LIEUTENANT = {
		5,
		false
	},
	FOREST_PROTECTOR = {
		5,
		false
	},
	UNTAMED_BEAST = {
		5,
		false
	},
	MIGHTY_III = {
		10,
		false
	},
	AGE_OF_HEROES = {
		30,
		false
	},
	IRONCLAD = {
		30,
		false
	},
	SEASONED_GENERAL = {
		10,
		false
	},
	MASTER_TACTICIAN = {
		30,
		false
	},
	TREE_HUGGER = {
		5,
		false
	},
	RUST_IN_PEACE = {
		5,
		false
	},
	WE_ARE_ALL_MAD_HERE = {
		5,
		false
	},
	ROCK_BEATS_ROCK = {
		5,
		false
	},
	SPECTRAL_FURY = {
		10,
		false
	},
	SAVIOUR_OF_THE_FOREST = {
		5,
		false
	},
	SMOOTH_OPER_GATOR = {
		5,
		false
	},
	SEE_YA_LATER_ALLIGATOR = {
		10,
		false
	},
	HAIL_TO_THE_K_BABY = {
		5,
		false
	},
	SCRAMBLED_EGGS = {
		5,
		false
	},
	MECHANICAL_BURNOUT = {
		5,
		false
	},
	FACTORY_STRIKE = {
		5,
		false
	},
	DOMO_ARIGATO = {
		5,
		false
	},
	KEPT_YOU_WAITING = {
		5,
		false
	},
	GIFT_OF_LIFE = {
		5,
		false
	},
	GARBAGE_DISPOSAL = {
		5,
		false
	},
	DISTURBING_THE_PEACE = {
		5,
		false
	},
	OBLITERATE = {
		5,
		false
	},
	SHUT_YOUR_MOUTH = {
		5,
		false
	},
	DLC1_WIN_BOSS = {
		10,
		false
	},
	INTO_THE_OGREVERSE = {
		5,
		false
	},
	A_COON_OF_SURPRISES = {
		5,
		false
	},
	LUCAS_SPIDER = {
		5,
		false
	},
	NO_FLY_ZONE = {
		5,
		false
	},
	ARACHNED = {
		10,
		false
	}
}

return ids
