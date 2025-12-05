-- chunkname: @./kr5-desktop/data/director_data.lua

local d = {}

d.item_props = {
	splash = {
		src = "screen_splash",
		next = "splash_message",
		type = "screen"
	},
	splash_message = {
		src = "screen_splash_message",
		skip_check = "check_skip_splash_message",
		next = "consent",
		type = "screen"
	},
	consent = {
		src = "screen_consent",
		skip_check = "check_skip_consent",
		next = "slots",
		type = "screen"
	},
	slots = {
		src = "screen_slots",
		show_loading = true,
		type = "screen"
	},
	credits = {
		src = "screen_credits",
		show_loading = true,
		next = "map",
		type = "screen"
	},
	map = {
		src = "screen_map",
		show_loading = true,
		type = "screen"
	},
	game = {
		show_loading = true,
		next = "map",
		type = "game"
	},
	kr5_end = {
		src = "screen_kr5_end",
		next = "map",
		type = "screen"
	},
	tutorial_end = {
		src = "screen_tutorial_end",
		next = "map",
		type = "screen"
	},
	boss_fight_1_end = {
		src = "screen_boss_fight_1_end",
		next = "map",
		type = "screen"
	},
	boss_fight_2_end = {
		src = "screen_boss_fight_2_end",
		next = "map",
		type = "screen"
	},
	boss_fight_3_end = {
		src = "screen_boss_fight_3_end",
		next = "map",
		type = "screen"
	},
	boss_fight_5_end = {
		src = "screen_boss_fight_5_end",
		next = "map",
		type = "screen"
	},
	boss_fight_6_end = {
		src = "screen_boss_fight_6_end",
		next = "map",
		type = "screen"
	},
	boss_fight_7_end = {
		src = "screen_boss_fight_7_end",
		next = "map",
		type = "screen"
	},
	boss_fight_8_end = {
		src = "screen_boss_fight_8_end",
		next = "map",
		type = "screen"
	},
	boss_fight_9_end = {
		src = "screen_boss_fight_9_end",
		next = "map",
		type = "screen"
	},
	boss_fight_10_end = {
		src = "screen_boss_fight_10_end",
		next = "map",
		type = "screen"
	},
	comic = {
		show_loading = false,
		next = "map",
		type = "comic"
	},
	game_editor = {
		src = "game_editor",
		show_loading = false,
		scissor = false,
		type = "screen"
	},
	tester = {
		src = "screen_tester",
		show_loading = false,
		type = "screen"
	}
}
d.loading_image_name = {
	{
		"loading_01_2",
		{
			1,
			2,
			3,
			4,
			5,
			6
		}
	},
	{
		"loading_02_1",
		{
			7,
			8,
			9,
			10,
			11
		}
	},
	{
		"loading_03_1",
		{
			12,
			13,
			14,
			15,
			16
		}
	},
	{
		"loading_04_1",
		{
			17,
			18,
			19
		}
	},
	{
		"loading_05_1",
		{
			20,
			21,
			22
		}
	},
	{
		"loading_06_1",
		{
			23,
			24,
			25,
			26,
			27
		}
	},
	{
		"loading_07_1",
		{
			28,
			29,
			30
		}
	},
	{
		"loading_08_1",
		{
			31,
			32,
			33,
			34,
			35
		}
	},
	{
		"loading_101_1",
		{
			101,
			102,
			103,
			104,
			105,
			106,
			114,
			116,
			117
		}
	},
	{
		"loading_102_1",
		{
			107,
			108,
			109,
			113,
			118,
			119
		}
	},
	{
		"loading_103_1",
		{
			110,
			111,
			112,
			115,
			120,
			121,
			122
		}
	},
	{
		"loading_104_1",
		{
			123,
			124,
			125,
			126
		}
	},
	{
		"loading_201_1",
		{
			201,
			202,
			203,
			204,
			205,
			206
		}
	},
	{
		"loading_202_1",
		{
			207,
			208,
			209,
			210,
			211
		}
	},
	{
		"loading_203_1",
		{
			212,
			213,
			214,
			215,
			222
		}
	},
	{
		"loading_204_1",
		{
			216,
			217,
			218
		}
	},
	{
		"loading_205_1",
		{
			219,
			220,
			221
		}
	},
	{
		"loading_301_1",
		{
			301,
			302,
			303,
			304,
			305,
			306
		}
	},
	{
		"loading_302_1",
		{
			307,
			308,
			309,
			310,
			311
		}
	},
	{
		"loading_303_1",
		{
			312,
			313,
			314,
			315
		}
	},
	{
		"loading_304_1",
		{
			316,
			317,
			318
		}
	},
	{
		"loading_305_1",
		{
			319,
			320
		}
	},
	{
		"loading_306_1",
		{
			321,
			322
		}
	},
	default = "loading_00_1"
}

return d
