-- chunkname: @./kr5/data/levels/level308_data.lua

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
				x = 712,
				y = 59
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 650,
				y = 50
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 780,
				y = 54
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 107,
				y = 704
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 955,
				y = 707
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 751,
				y = 166
			},
			["tower.default_rally_pos"] = {
				x = 682,
				y = 123
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 614,
				y = 227
			},
			["tower.default_rally_pos"] = {
				x = 524,
				y = 187
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "22",
			pos = {
				x = 427,
				y = 265
			},
			["tower.default_rally_pos"] = {
				x = 418,
				y = 215
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 218,
				y = 328
			},
			["tower.default_rally_pos"] = {
				x = 123,
				y = 340
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 887,
				y = 381
			},
			["tower.default_rally_pos"] = {
				x = 918,
				y = 449
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "20",
			pos = {
				x = 664,
				y = 389
			},
			["tower.default_rally_pos"] = {
				x = 667,
				y = 314
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 352,
				y = 497
			},
			["tower.default_rally_pos"] = {
				x = 449,
				y = 503
			}
		},
		{
			["tower.holder_id"] = "18",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "18",
			pos = {
				x = 548,
				y = 529
			},
			["tower.default_rally_pos"] = {
				x = 650,
				y = 560
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "16",
			pos = {
				x = 749,
				y = 538
			},
			["tower.default_rally_pos"] = {
				x = 728,
				y = 484
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
		[8] = {},
		[10] = {},
		[12] = {},
		[14] = {},
		[16] = {},
		[18] = {},
		[20] = {},
		[22] = {},
		[24] = {}
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
