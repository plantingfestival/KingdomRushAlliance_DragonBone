-- chunkname: @./kr5/data/levels/level307_data.lua

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
				x = 318,
				y = 44
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 721,
				y = 46
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 257,
				y = 40
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 783,
				y = 41
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 662,
				y = 42
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 381,
				y = 45
			}
		},
		{
			["editor.r"] = 1.5725416560469,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 213,
				y = 675
			}
		},
		{
			["editor.r"] = 1.5725416560469,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 815,
				y = 679
			}
		},
		{
			["tower.holder_id"] = "60",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "60",
			pos = {
				x = 521,
				y = 196
			},
			["tower.default_rally_pos"] = {
				x = 429,
				y = 238
			}
		},
		{
			["tower.holder_id"] = "46",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "46",
			pos = {
				x = 309,
				y = 264
			},
			["tower.default_rally_pos"] = {
				x = 373,
				y = 333
			}
		},
		{
			["tower.holder_id"] = "48",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "48",
			pos = {
				x = 720,
				y = 266
			},
			["tower.default_rally_pos"] = {
				x = 641,
				y = 320
			}
		},
		{
			["tower.holder_id"] = "58",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "58",
			pos = {
				x = 518,
				y = 359
			},
			["tower.default_rally_pos"] = {
				x = 521,
				y = 300
			}
		},
		{
			["tower.holder_id"] = "62",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "62",
			pos = {
				x = 315,
				y = 420
			},
			["tower.default_rally_pos"] = {
				x = 281,
				y = 375
			}
		},
		{
			["tower.holder_id"] = "64",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "64",
			pos = {
				x = 712,
				y = 426
			},
			["tower.default_rally_pos"] = {
				x = 791,
				y = 393
			}
		},
		{
			["tower.holder_id"] = "52",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "52",
			pos = {
				x = 854,
				y = 531
			},
			["tower.default_rally_pos"] = {
				x = 750,
				y = 510
			}
		},
		{
			["tower.holder_id"] = "50",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "50",
			pos = {
				x = 172,
				y = 537
			},
			["tower.default_rally_pos"] = {
				x = 283,
				y = 509
			}
		},
		{
			["tower.holder_id"] = "30",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "30",
			pos = {
				x = 364,
				y = 574
			},
			["tower.default_rally_pos"] = {
				x = 366,
				y = 509
			}
		},
		{
			["tower.holder_id"] = "28",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "28",
			pos = {
				x = 658,
				y = 574
			},
			["tower.default_rally_pos"] = {
				x = 660,
				y = 508
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
		[28] = {},
		[30] = {},
		[46] = {},
		[48] = {},
		[50] = {},
		[52] = {},
		[58] = {},
		[60] = {},
		[62] = {},
		[64] = {}
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
