-- chunkname: @./kr5/data/levels/level201_data.lua

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
				0
			},
			["path_debug.path_color"] = {
				168,
				199,
				169,
				0
			},
			pos = {
				x = -300,
				y = 868
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage201_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = -137,
				y = 254
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = -137,
				y = 432
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -140,
				y = 182
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -141,
				y = 303
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -136,
				y = 369
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = -139,
				y = 482
			}
		},
		{
			["editor.r"] = 0.034906585039887,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 172,
			pos = {
				x = 1165,
				y = 284
			}
		},
		{
			["editor.r"] = 0.034906585039887,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 172,
			pos = {
				x = 1142,
				y = 331
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 172,
			pos = {
				x = 1023,
				y = 719
			}
		},
		{
			["tower.holder_id"] = "01",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "01",
			pos = {
				x = 268,
				y = 199
			},
			["tower.default_rally_pos"] = {
				x = 389,
				y = 233
			}
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "02",
			pos = {
				x = 504,
				y = 234
			},
			["tower.default_rally_pos"] = {
				x = 463,
				y = 168
			}
		},
		{
			["tower.holder_id"] = "03",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "03",
			pos = {
				x = 656,
				y = 235
			},
			["tower.default_rally_pos"] = {
				x = 709,
				y = 169
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "04",
			pos = {
				x = 51,
				y = 266
			},
			["tower.default_rally_pos"] = {
				x = 98,
				y = 200
			}
		},
		{
			["tower.holder_id"] = "05",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "05",
			pos = {
				x = 449,
				y = 322
			},
			["tower.default_rally_pos"] = {
				x = 324,
				y = 300
			}
		},
		{
			["tower.holder_id"] = "06",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "06",
			pos = {
				x = 876,
				y = 331
			},
			["tower.default_rally_pos"] = {
				x = 868,
				y = 231
			}
		},
		{
			["tower.holder_id"] = "07",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "07",
			pos = {
				x = 55,
				y = 347
			},
			["tower.default_rally_pos"] = {
				x = -5,
				y = 433
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "08",
			pos = {
				x = 175,
				y = 369
			},
			["tower.default_rally_pos"] = {
				x = 285,
				y = 403
			}
		},
		{
			["tower.holder_id"] = "09",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "09",
			pos = {
				x = 1014,
				y = 477
			},
			["tower.default_rally_pos"] = {
				x = 934,
				y = 539
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 325,
				y = 491
			},
			["tower.default_rally_pos"] = {
				x = 274,
				y = 570
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 572,
				y = 522
			},
			["tower.default_rally_pos"] = {
				x = 626,
				y = 605
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 446,
				y = 525
			},
			["tower.default_rally_pos"] = {
				x = 452,
				y = 610
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 95,
				y = 529
			},
			["tower.default_rally_pos"] = {
				x = 152,
				y = 458
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 818,
				y = 601
			},
			["tower.default_rally_pos"] = {
				x = 772,
				y = 538
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			locked_towers = {}
		},
		{
			locked_towers = {}
		},
		{
			locked_towers = {}
		}
	},
	nav_mesh = {
		{},
		{
			4,
			6,
			nil,
			1
		},
		{},
		{
			8,
			6,
			2,
			1
		},
		{},
		{},
		{},
		{},
		{
			nil,
			10,
			12,
			12
		},
		{
			nil,
			7,
			11,
			9
		},
		{
			10,
			5,
			15,
			12
		},
		{
			9,
			11,
			13
		},
		{
			12,
			14,
			1
		},
		{
			15,
			8,
			1,
			13
		}
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
		"go_stage201_bg"
	}
}
