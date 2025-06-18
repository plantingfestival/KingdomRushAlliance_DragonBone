-- chunkname: @./kr5/data/levels/level502_data.lua

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
				y = 356
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -90,
				y = 272
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -90,
				y = 419
			}
		},
		{
			["editor.r"] = -9.5132235422568e-15,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 164,
			pos = {
				x = 1095,
				y = 161
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
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 736,
				y = 175
			},
			["tower.default_rally_pos"] = {
				x = 748,
				y = 259
			}
		},
		{
			["tower.holder_id"] = "25",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "25",
			pos = {
				x = 459,
				y = 276
			},
			["tower.default_rally_pos"] = {
				x = 447,
				y = 216
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "21",
			pos = {
				x = 136,
				y = 280
			},
			["tower.default_rally_pos"] = {
				x = 132,
				y = 360
			}
		},
		{
			["tower.holder_id"] = "26",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "26",
			pos = {
				x = 847,
				y = 317
			},
			["tower.default_rally_pos"] = {
				x = 804,
				y = 243
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 701,
				y = 332
			},
			["tower.default_rally_pos"] = {
				x = 720,
				y = 409
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 347,
				y = 334
			},
			["tower.default_rally_pos"] = {
				x = 258,
				y = 393
			}
		},
		{
			["tower.holder_id"] = "24",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 46,
				y = 421
			},
			["tower.default_rally_pos"] = {
				x = 41,
				y = 360
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 514,
				y = 426
			},
			["tower.default_rally_pos"] = {
				x = 503,
				y = 505
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 164,
				y = 427
			},
			["tower.default_rally_pos"] = {
				x = 198,
				y = 370
			}
		},
		{
			["tower.holder_id"] = "17",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "17",
			pos = {
				x = 847,
				y = 466
			},
			["tower.default_rally_pos"] = {
				x = 897,
				y = 410
			}
		},
		{
			spawn_wave = 6,
			template = "trees_arborean_sages",
			leave_wave = 8,
			pos = {
				x = 349,
				y = 161
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_towers = {
				"tower_archer_balance_3",
				"tower_paladin_covenant_lvl3",
				"tower_big_bertha_lvl3",
				"tower_mage_balance_3"
			}
		},
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
		[25] = {},
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
		"go_enemies_sea_of_trees",
		"go_stages_sea_of_trees",
		"go_hero_king_denas"
	}
}
