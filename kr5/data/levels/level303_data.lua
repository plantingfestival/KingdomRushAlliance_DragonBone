-- chunkname: @./kr5/data/levels/level303_data.lua

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
				x = -88,
				y = 356
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -89,
				y = 272
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -84,
				y = 419
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 110,
			pos = {
				x = 1022,
				y = 72
			}
		},
		{
			["editor.r"] = 0.017453292519941,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 140,
			pos = {
				x = 1122,
				y = 593
			}
		},
		{
			["tower.holder_id"] = "26",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "26",
			pos = {
				x = 738,
				y = 178
			},
			["tower.default_rally_pos"] = {
				x = 804,
				y = 243
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "21",
			pos = {
				x = 77,
				y = 273
			},
			["tower.default_rally_pos"] = {
				x = 90,
				y = 363
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 844,
				y = 317
			},
			["tower.default_rally_pos"] = {
				x = 835,
				y = 419
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 340,
				y = 325
			},
			["tower.default_rally_pos"] = {
				x = 258,
				y = 393
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 680,
				y = 325
			},
			["tower.default_rally_pos"] = {
				x = 720,
				y = 409
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 497,
				y = 386
			},
			["tower.default_rally_pos"] = {
				x = 498,
				y = 471
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 123,
				y = 423
			},
			["tower.default_rally_pos"] = {
				x = 122,
				y = 359
			}
		},
		{
			["tower.holder_id"] = "17",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "17",
			pos = {
				x = 902,
				y = 475
			},
			["tower.default_rally_pos"] = {
				x = 897,
				y = 410
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 332,
				y = 487
			},
			["tower.default_rally_pos"] = {
				x = 370,
				y = 436
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
		[7] = {},
		[9] = {},
		[11] = {},
		[13] = {},
		[15] = {},
		[17] = {},
		[21] = {},
		[24] = {},
		[26] = {}
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
