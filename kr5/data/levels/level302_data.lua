-- chunkname: @./kr5/data/levels/level302_data.lua

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
			["editor.r"] = -3.2959746043559e-15,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 124,
			pos = {
				x = 1149,
				y = 165
			}
		},
		{
			["tower.holder_id"] = "32",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "32",
			pos = {
				x = 524,
				y = 174
			},
			["tower.default_rally_pos"] = {
				x = 434,
				y = 221
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 172,
				y = 176
			},
			["tower.default_rally_pos"] = {
				x = 266,
				y = 194
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "04",
			pos = {
				x = 347,
				y = 228
			},
			["tower.default_rally_pos"] = {
				x = 350,
				y = 162
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 589,
				y = 259
			},
			["tower.default_rally_pos"] = {
				x = 562,
				y = 343
			}
		},
		{
			["tower.holder_id"] = "38",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "38",
			pos = {
				x = 845,
				y = 264
			},
			["tower.default_rally_pos"] = {
				x = 914,
				y = 312
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "08",
			pos = {
				x = 411,
				y = 352
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
			["tower.holder_id"] = "40",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "40",
			pos = {
				x = 637,
				y = 423
			},
			["tower.default_rally_pos"] = {
				x = 641,
				y = 354
			}
		},
		{
			["tower.holder_id"] = "32",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "32",
			pos = {
				x = 32,
				y = 432
			},
			["tower.default_rally_pos"] = {
				x = 62,
				y = 363
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 481,
				y = 485
			},
			["tower.default_rally_pos"] = {
				x = 366,
				y = 487
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "02",
			pos = {
				x = 306,
				y = 562
			},
			["tower.default_rally_pos"] = {
				x = 321,
				y = 655
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
