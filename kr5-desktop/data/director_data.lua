-- chunkname: @./kr5-desktop/data/director_data.lua

local d = {}

d.item_props = {
	splash = {
		src = "screen_splash",
		next = "china_advise",
		type = "screen"
	},
	china_advise = {
		src = "screen_china_advise",
		skip_check = "check_skip_china_advise",
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
	default = "loading_00_1"
}

return d
