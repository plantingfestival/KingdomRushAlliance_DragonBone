-- chunkname: @./kr5/data/levels/level306_data.lua

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
				x = -59,
				y = 471
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -57,
				y = 404
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -53,
				y = 521
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 859,
				y = 51
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 589,
				y = 724
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 543,
				y = 263
			},
			["tower.default_rally_pos"] = {
				x = 535,
				y = 203
			}
		},
		{
			["tower.holder_id"] = "18",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "18",
			pos = {
				x = 702,
				y = 272
			},
			["tower.default_rally_pos"] = {
				x = 701,
				y = 206
			}
		},
		{
			["tower.holder_id"] = "30",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "30",
			pos = {
				x = 312,
				y = 276
			},
			["tower.default_rally_pos"] = {
				x = 316,
				y = 217
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "16",
			pos = {
				x = 850,
				y = 278
			},
			["tower.default_rally_pos"] = {
				x = 892,
				y = 226
			}
		},
		{
			["tower.holder_id"] = "34",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "34",
			pos = {
				x = 929,
				y = 358
			},
			["tower.default_rally_pos"] = {
				x = 1021,
				y = 364
			}
		},
		{
			["tower.holder_id"] = "26",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "26",
			pos = {
				x = 348,
				y = 380
			},
			["tower.default_rally_pos"] = {
				x = 441,
				y = 391
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 235,
				y = 411
			},
			["tower.default_rally_pos"] = {
				x = 140,
				y = 453
			}
		},
		{
			["tower.holder_id"] = "32",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "32",
			pos = {
				x = 876,
				y = 424
			},
			["tower.default_rally_pos"] = {
				x = 937,
				y = 497
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "22",
			pos = {
				x = 559,
				y = 488
			},
			["tower.default_rally_pos"] = {
				x = 634,
				y = 545
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "20",
			pos = {
				x = 356,
				y = 499
			},
			["tower.default_rally_pos"] = {
				x = 379,
				y = 568
			}
		},
		{
			["tower.holder_id"] = "28",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "28",
			pos = {
				x = 152,
				y = 575
			},
			["tower.default_rally_pos"] = {
				x = 222,
				y = 529
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
		[14] = {},
		[16] = {},
		[18] = {},
		[20] = {},
		[22] = {},
		[24] = {},
		[26] = {},
		[28] = {},
		[30] = {},
		[32] = {},
		[34] = {}
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
