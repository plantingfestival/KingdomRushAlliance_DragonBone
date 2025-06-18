-- chunkname: @./kr5/data/achievements_data.lua

local features = require("features")
local t = {
	{
		reward = 30,
		name = "LEARNING_THE_ROPES",
		icon = 4,
		order = "01"
	},
	{
		reward = 30,
		name = "TIPPING_THE_SCALES",
		icon = 15,
		order = "02"
	},
	{
		reward = 30,
		name = "FIELD_TRIP_RUINER",
		icon = 38,
		order = "03"
	},
	{
		reward = 50,
		name = "ITS_A_SECRET_TO_EVERYONE",
		goal = 5,
		censored_cn = true,
		icon = 16,
		order = "04"
	},
	{
		reward = 30,
		name = "CIRCLE_OF_LIFE",
		icon = 28,
		order = "05"
	},
	{
		reward = 30,
		name = "PLAYFUL_FRIENDS",
		icon = 29,
		order = "06"
	},
	{
		reward = 30,
		name = "MOST_DELICIOUS",
		icon = 31,
		order = "07"
	},
	{
		reward = 50,
		name = "NATURES_WRATH",
		goal = 30,
		icon = 25,
		order = "08"
	},
	{
		reward = 50,
		name = "MIGHTY_I",
		goal = 500,
		icon = 5,
		order = "09"
	},
	{
		reward = 30,
		name = "GREENLIT_ALLIES",
		goal = 10,
		icon = 12,
		order = "10"
	},
	{
		reward = 30,
		name = "OVER_THE_EDGE",
		icon = 39,
		order = "11"
	},
	{
		reward = 30,
		name = "CLEANUP_IS_OPTIONAL",
		icon = 34,
		order = "12"
	},
	{
		reward = 30,
		name = "RUNEQUEST",
		goal = 63,
		icon = 13,
		order = "13"
	},
	{
		reward = 50,
		name = "NONE_SHALL_PASS",
		icon = 41,
		order = "14"
	},
	{
		reward = 30,
		name = "CRAFTING_IN_THE_MINES",
		icon = 14,
		order = "15"
	},
	{
		reward = 50,
		name = "PORKS_OFF_THE_MENU",
		icon = 2,
		order = "16"
	},
	{
		reward = 50,
		name = "OUTBACK_BARBEQUICK",
		icon = 54,
		order = "17"
	},
	{
		reward = 50,
		name = "SAVIOUR_OF_THE_GREEN",
		goal = 6,
		icon = 3,
		order = "18"
	},
	{
		reward = 30,
		name = "NOT_A_MOMENT_TO_WASTE",
		goal = 15,
		icon = 9,
		order = "19"
	},
	{
		reward = 30,
		name = "SILVER_FOR_MONSTERS",
		censored_cn = true,
		icon = 30,
		order = "20"
	},
	{
		reward = 30,
		name = "CROW_SCARER",
		icon = 33,
		order = "21"
	},
	{
		reward = 50,
		name = "WE_RE_NOT_GONNA_TAKE_IT",
		goal = 15,
		icon = 42,
		order = "22"
	},
	{
		reward = 50,
		name = "BREAKER_OF_CHAINS",
		icon = 35,
		order = "23"
	},
	{
		reward = 30,
		name = "GEM_SPILLER",
		icon = 40,
		order = "24"
	},
	{
		reward = 50,
		name = "UNBOUND_VICTORY",
		icon = 43,
		order = "25"
	},
	{
		reward = 30,
		name = "GET_THE_PARTY_STARTED",
		censored_cn = true,
		icon = 36,
		order = "26"
	},
	{
		reward = 50,
		name = "WAR_MASONRY",
		goal = 100,
		icon = 8,
		order = "27"
	},
	{
		reward = 50,
		name = "PROMOTION_DENIED",
		goal = 30,
		icon = 44,
		order = "28"
	},
	{
		reward = 30,
		name = "STARLIGHT",
		icon = 32,
		order = "29"
	},
	{
		reward = 100,
		name = "CLEANSE_THE_KING",
		icon = 11,
		order = "30"
	},
	{
		reward = 50,
		name = "YOU_SHALL_NOT_CAST",
		icon = 53,
		order = "31"
	},
	{
		reward = 100,
		name = "CRYSTAL_CLEAR",
		goal = 5,
		icon = 21,
		order = "32"
	},
	{
		reward = 100,
		name = "MIGHTY_II",
		goal = 3000,
		icon = 6,
		order = "33"
	},
	{
		reward = 50,
		name = "ALL_THE_SMALL_THINGS",
		goal = 182,
		icon = 10,
		order = "34"
	},
	{
		reward = 30,
		name = "THE_CAVALRY_IS_HERE",
		goal = 1000,
		icon = 22,
		order = "35"
	},
	{
		reward = 30,
		name = "WEIRDER_THINGS",
		icon = 60,
		order = "36"
	},
	{
		reward = 50,
		name = "OVINE_JOURNALISM",
		goal = 7,
		icon = 63,
		order = "37"
	},
	{
		reward = 50,
		name = "ONE_SHOT_TOWER",
		icon = 45,
		order = "38"
	},
	{
		reward = 50,
		name = "CROWD_CONTROL",
		icon = 46,
		order = "39"
	},
	{
		reward = 30,
		name = "WOBBA_LUBBA_DUB_DUB",
		censored_cn = true,
		icon = 62,
		order = "40"
	},
	{
		reward = 30,
		name = "PEST_CONTROL",
		goal = 300,
		icon = 58,
		order = "41"
	},
	{
		reward = 50,
		name = "TURN_A_BLIND_EYE",
		goal = 100,
		icon = 55,
		order = "42"
	},
	{
		reward = 30,
		name = "TAKE_ME_HOME",
		icon = 61,
		order = "43"
	},
	{
		reward = 50,
		name = "BUTTERTENTACLES",
		icon = 47,
		order = "44"
	},
	{
		reward = 100,
		name = "BYE_BYE_BEAUTIFUL",
		icon = 56,
		order = "45"
	},
	{
		reward = 150,
		name = "CONJUNTIVICTORY",
		icon = 57,
		order = "46"
	},
	{
		reward = 150,
		name = "CONQUEROR_OF_THE_VOID",
		goal = 5,
		icon = 48,
		order = "47"
	},
	{
		reward = 50,
		name = "LINIREAN_RESISTANCE",
		icon = 51,
		order = "48"
	},
	{
		reward = 50,
		name = "DARK_RUTHLESSNESS",
		icon = 52,
		order = "49"
	},
	{
		reward = 50,
		name = "UNENDING_RICHES",
		goal = 150000,
		icon = 59,
		order = "50"
	},
	{
		reward = 30,
		name = "SIGNATURE_TECHNIQUES",
		goal = 500,
		icon = 23,
		order = "51"
	},
	{
		reward = 50,
		name = "ROYAL_CAPTAIN",
		icon = 18,
		order = "52"
	},
	{
		reward = 50,
		name = "DARK_LIEUTENANT",
		icon = 17,
		order = "53"
	},
	{
		reward = 50,
		name = "FOREST_PROTECTOR",
		icon = 20,
		order = "54"
	},
	{
		reward = 50,
		name = "UNTAMED_BEAST",
		icon = 19,
		order = "55"
	},
	{
		reward = 150,
		name = "MIGHTY_III",
		goal = 10000,
		icon = 7,
		order = "56"
	},
	{
		reward = 500,
		name = "AGE_OF_HEROES",
		goal = 32767,
		icon = 24,
		order = "57"
	},
	{
		reward = 500,
		name = "IRONCLAD",
		goal = 32767,
		icon = 26,
		order = "58"
	},
	{
		reward = 100,
		name = "SEASONED_GENERAL",
		goal = 65535,
		icon = 49,
		order = "59"
	},
	{
		reward = 250,
		name = "MASTER_TACTICIAN",
		goal = 65535,
		icon = 50,
		order = "60"
	},
	{
		reward = 30,
		name = "TREE_HUGGER",
		icon = 65,
		order = "61"
	},
	{
		reward = 30,
		name = "RUST_IN_PEACE",
		icon = 67,
		order = "62"
	},
	{
		reward = 50,
		name = "WE_ARE_ALL_MAD_HERE",
		goal = 7,
		censored_cn = true,
		icon = 66,
		order = "63"
	},
	{
		reward = 30,
		name = "ROCK_BEATS_ROCK",
		icon = 68,
		order = "64"
	},
	{
		reward = 50,
		name = "SPECTRAL_FURY",
		icon = 64,
		order = "65"
	},
	{
		reward = 50,
		name = "SAVIOUR_OF_THE_FOREST",
		icon = 69,
		order = "66"
	},
	{
		reward = 30,
		name = "SMOOTH_OPER_GATOR",
		icon = 70,
		order = "67"
	},
	{
		reward = 50,
		name = "SEE_YA_LATER_ALLIGATOR",
		icon = 71,
		order = "68"
	},
	{
		reward = 50,
		name = "HAIL_TO_THE_K_BABY",
		icon = 72,
		order = "69"
	},
	{
		reward = 30,
		name = "SCRAMBLED_EGGS",
		goal = 50,
		icon = 73,
		order = "70"
	},
	{
		reward = 30,
		name = "MECHANICAL_BURNOUT",
		dlc = "dlc_1",
		icon = 74,
		order = "71"
	},
	{
		reward = 50,
		name = "FACTORY_STRIKE",
		dlc = "dlc_1",
		icon = 75,
		order = "72"
	},
	{
		reward = 30,
		name = "DOMO_ARIGATO",
		dlc = "dlc_1",
		goal = 20,
		icon = 76,
		order = "73"
	},
	{
		reward = 30,
		name = "KEPT_YOU_WAITING",
		dlc = "dlc_1",
		icon = 77,
		order = "74"
	},
	{
		reward = 30,
		name = "GIFT_OF_LIFE",
		dlc = "dlc_1",
		icon = 78,
		order = "75"
	},
	{
		reward = 50,
		name = "GARBAGE_DISPOSAL",
		dlc = "dlc_1",
		goal = 10,
		icon = 79,
		order = "76"
	},
	{
		reward = 30,
		name = "DISTURBING_THE_PEACE",
		dlc = "dlc_1",
		icon = 80,
		order = "77"
	},
	{
		reward = 50,
		name = "OBLITERATE",
		dlc = "dlc_1",
		goal = 31,
		icon = 81,
		order = "78"
	},
	{
		reward = 50,
		name = "SHUT_YOUR_MOUTH",
		dlc = "dlc_1",
		icon = 82,
		order = "79"
	},
	{
		reward = 50,
		name = "DLC1_WIN_BOSS",
		dlc = "dlc_1",
		icon = 83,
		order = "80"
	},
	{
		reward = 30,
		name = "INTO_THE_OGREVERSE",
		icon = 84,
		order = "81"
	},
	{
		reward = 50,
		name = "A_COON_OF_SURPRISES",
		icon = 85,
		order = "82"
	},
	{
		reward = 50,
		name = "LUCAS_SPIDER",
		icon = 86,
		order = "83"
	},
	{
		reward = 30,
		name = "NO_FLY_ZONE",
		goal = 50,
		icon = 87,
		order = "84"
	},
	{
		reward = 50,
		name = "ARACHNED",
		icon = 88,
		order = "85"
	}
}

for i = #t, 1, -1 do
	do
		local targets = t[i].targets

		if targets then
			for _, target in pairs(targets) do
				if target == KR_TARGET then
					goto label_0_0
				end
			end

			table.remove(t, i)
		end

		if features.censored_cn and t[i].censored_cn then
			table.remove(t, i)
		end
	end

	::label_0_0::
end

return t
