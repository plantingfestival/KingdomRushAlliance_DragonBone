-- chunkname: @./kr5/data/levels/level309_data.lua

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
				x = 511,
				y = 713
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 581,
				y = 704
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 443,
				y = 705
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 286,
				y = 203
			},
			["tower.default_rally_pos"] = {
				x = 292,
				y = 294
			}
		},
		{
			["tower.holder_id"] = "18",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "18",
			pos = {
				x = 820,
				y = 210
			},
			["tower.default_rally_pos"] = {
				x = 735,
				y = 203
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 527,
				y = 354
			},
			["tower.default_rally_pos"] = {
				x = 638,
				y = 358
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "16",
			pos = {
				x = 739,
				y = 354
			},
			["tower.default_rally_pos"] = {
				x = 713,
				y = 301
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 315,
				y = 358
			},
			["tower.default_rally_pos"] = {
				x = 414,
				y = 364
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			pos = {
				x = 188,
				y = 373
			},
			["tower.default_rally_pos"] = {
				x = 189,
				y = 302
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			pos = {
				x = 917,
				y = 407
			},
			["tower.default_rally_pos"] = {
				x = 950,
				y = 334
			}
		},
		{
			["tower.holder_id"] = "20",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "20",
			pos = {
				x = 311,
				y = 499
			},
			["tower.default_rally_pos"] = {
				x = 216,
				y = 501
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "22",
			pos = {
				x = 769,
				y = 519
			},
			["tower.default_rally_pos"] = {
				x = 870,
				y = 530
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 512,
				y = 552
			},
			["tower.default_rally_pos"] = {
				x = 513,
				y = 631
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
