-- chunkname: @./kr5/data/levels/level501_data.lua

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
				x = -90,
				y = 334
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -90,
				y = 266
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -90,
				y = 398
			}
		},
		{
			["editor.r"] = -2.8102520310824e-15,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 220,
			pos = {
				x = 1166,
				y = 270
			}
		},
		{
			["tower.holder_id"] = "40",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "40",
			pos = {
				x = 393,
				y = 297
			},
			["tower.default_rally_pos"] = {
				x = 308,
				y = 359
			}
		},
		{
			["tower.holder_id"] = "38",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "38",
			pos = {
				x = 783,
				y = 309
			},
			["tower.default_rally_pos"] = {
				x = 717,
				y = 392
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "08",
			pos = {
				x = 865,
				y = 349
			},
			["tower.default_rally_pos"] = {
				x = 847,
				y = 445
			}
		},
		{
			["tower.holder_id"] = "32",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "32",
			pos = {
				x = 70,
				y = 399
			},
			["tower.default_rally_pos"] = {
				x = 34,
				y = 330
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 206,
				y = 408
			},
			["tower.default_rally_pos"] = {
				x = 220,
				y = 338
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 299,
				y = 469
			},
			["tower.default_rally_pos"] = {
				x = 376,
				y = 414
			}
		},
		{
			["tower.holder_id"] = "26",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "26",
			pos = {
				x = 717,
				y = 471
			},
			["tower.default_rally_pos"] = {
				x = 784,
				y = 418
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 511,
				y = 491
			},
			["tower.default_rally_pos"] = {
				x = 411,
				y = 482
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 839,
				y = 536
			},
			["tower.default_rally_pos"] = {
				x = 902,
				y = 478
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "02",
			pos = {
				x = 679,
				y = 578
			},
			["tower.default_rally_pos"] = {
				x = 770,
				y = 657
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_powers = {
				true,
				true,
				true
			},
			locked_towers = {
				"tower_archer_balance_2",
				"tower_paladin_covenant_lvl2",
				"tower_big_bertha_lvl2",
				"tower_mage_balance_2"
			}
		},
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
		[24] = {},
		[26] = {},
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
		"go_enemies_sea_of_trees",
		"go_stages_sea_of_trees",
		"go_hero_king_denas"
	}
}
