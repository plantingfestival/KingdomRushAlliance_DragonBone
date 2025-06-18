-- chunkname: @./kr5/data/levels/level301_data.lua

return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	entities_list = {
		{
			template = "debug_path_renderer",
			["path_debug.background_color"] = {
				46,
				193,
				142,
				255
			},
			["path_debug.path_color"] = {
				168,
				199,
				169,
				255
			},
			pos = {
				x = -300,
				y = 868
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = -118,
				y = 345
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -113,
				y = 277
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -113,
				y = 398
			}
		},
		{
			["editor.r"] = -2.8102520310824e-15,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 124,
			pos = {
				x = 1138,
				y = 175
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 152,
				y = 182
			},
			["tower.default_rally_pos"] = {
				x = 252,
				y = 191
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "04",
			pos = {
				x = 341,
				y = 209
			},
			["tower.default_rally_pos"] = {
				x = 322,
				y = 142
			}
		},
		{
			["tower.holder_id"] = "38",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "38",
			pos = {
				x = 832,
				y = 214
			},
			["tower.default_rally_pos"] = {
				x = 900,
				y = 272
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 623,
				y = 278
			},
			["tower.default_rally_pos"] = {
				x = 562,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "08",
			pos = {
				x = 414,
				y = 353
			},
			["tower.default_rally_pos"] = {
				x = 511,
				y = 331
			}
		},
		{
			["tower.holder_id"] = "06",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "06",
			pos = {
				x = 214,
				y = 375
			},
			["tower.default_rally_pos"] = {
				x = 138,
				y = 448
			}
		},
		{
			["tower.holder_id"] = "32",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "32",
			pos = {
				x = 19,
				y = 425
			},
			["tower.default_rally_pos"] = {
				x = 62,
				y = 363
			}
		},
		{
			["tower.holder_id"] = "40",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "40",
			pos = {
				x = 635,
				y = 438
			},
			["tower.default_rally_pos"] = {
				x = 650,
				y = 374
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "02",
			pos = {
				x = 291,
				y = 552
			},
			["tower.default_rally_pos"] = {
				x = 303,
				y = 634
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 479,
				y = 570
			},
			["tower.default_rally_pos"] = {
				x = 383,
				y = 560
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{},
		{},
		{}
	},
	nav_mesh = {
		[2] = {
			4,
			6,
			nil,
			1
		},
		[4] = {
			8,
			6,
			2,
			1
		},
		[6] = {
			16,
			nil,
			nil,
			8
		},
		[8] = {
			3,
			6,
			4,
			14
		},
		[11] = {
			10,
			5,
			15,
			12
		},
		[14] = {
			15,
			8,
			1,
			13
		},
		[32] = {},
		[38] = {},
		[40] = {}
	},
	required_sounds = {
		"music_stage19",
		"ElvesDrizzt",
		"ElvesCreepServant",
		"ElvesWhiteTree",
		"MetropolisAmbienceSounds",
		"ElvesCreepEvoker",
		"ElvesCreepGolem",
		"ElvesScourger",
		"ElvesCreepAvenger",
		"ElvesCreepMountedAvenger",
		"ElvesCreepScreecher"
	},
	required_textures = {
		"go_enemies_sea_of_trees"
	}
}
