-- chunkname: @./kr3/data/levels/level18_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		{
			pos = {
				x = 501,
				y = 80
			}
		},
		{
			pos = {
				x = 712,
				y = 80
			}
		}
	},
	custom_start_pos = {
		zoom = 1.3,
		pos = {
			x = 512,
			y = 384
		}
	},
	entities_list = {
		{
			template = "background_sounds",
			sounds = {
				"ElvenWoodsAmbienceSound"
			}
		},
		{
			template = "crystal_unstable",
			pos = {
				x = 836,
				y = 460
			}
		},
		{
			["render.sprites[1].sort_y"] = 455,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage18_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage18_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 676,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage18_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 719,
				y = 73
			}
		},
		{
			["editor.exit_id"] = 3,
			template = "decal_defend_point",
			pos = {
				x = 501,
				y = 75
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 48,
				y = 173
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 419,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 581,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 644,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 798,
				y = 53
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 33,
				y = 99
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 33,
				y = 224
			}
		},
		{
			template = "decal_hr_crystal_skull",
			["render.sprites[1].flip_x"] = true,
			["delayed_play.achievement_flag"] = {
				"MITCHELL_HEDGES",
				4
			},
			pos = {
				x = 757,
				y = 578
			}
		},
		{
			template = "decal_s18_boss_head",
			["editor.game_mode"] = 2,
			pos = {
				x = 718,
				y = 608
			}
		},
		{
			template = "decal_s18_boss_head",
			["editor.game_mode"] = 3,
			pos = {
				x = 718,
				y = 608
			}
		},
		{
			template = "decal_s18_flag_head",
			pos = {
				x = 816,
				y = 616
			}
		},
		{
			template = "decal_s18_roadrunner_bush",
			pos = {
				x = 461,
				y = 470
			}
		},
		{
			template = "decal_s18_statue",
			pos = {
				x = 73,
				y = 295
			}
		},
		{
			["editor.r"] = 0.10471975511973,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 982,
				y = 494
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 316,
				y = 633
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 286,
				y = 675
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 345,
				y = 675
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 527,
				y = 717
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 576,
				y = 717
			}
		},
		{
			["spawner.name"] = "trail0",
			template = "gnoll_bush_spawner",
			spawn_node_offset = 3,
			["spawner.pi"] = 9,
			["render.sprites[1].name"] = "stage_18_bushes2",
			pos = {
				x = 110,
				y = 365
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.14285714285714285
			},
			["spawner.pos_offset"] = {
				x = -40,
				y = 15
			}
		},
		{
			["spawner.name"] = "trail1",
			template = "gnoll_bush_spawner",
			spawn_node_offset = 3,
			["spawner.pi"] = 8,
			["render.sprites[1].name"] = "stage_18_bushes1",
			pos = {
				x = 463,
				y = 483
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.3783783783783784
			}
		},
		{
			template = "mega_spawner",
			load_file = "level318_spawner"
		},
		{
			template = "taunts_s18_defeated_controller",
			["editor.game_mode"] = 2
		},
		{
			template = "taunts_s18_defeated_controller",
			["editor.game_mode"] = 3
		},
		{
			["tower.holder_id"] = "02",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "02",
			pos = {
				x = 521,
				y = 181
			},
			["tower.default_rally_pos"] = {
				x = 612,
				y = 218
			}
		},
		{
			["tower.holder_id"] = "09",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "09",
			pos = {
				x = 904,
				y = 181
			},
			["tower.default_rally_pos"] = {
				x = 818,
				y = 218
			}
		},
		{
			["tower.holder_id"] = "08",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "08",
			pos = {
				x = 363,
				y = 183
			},
			["tower.default_rally_pos"] = {
				x = 309,
				y = 137
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 716,
				y = 230
			},
			["tower.default_rally_pos"] = {
				x = 717,
				y = 171
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 157,
				y = 269
			},
			["tower.default_rally_pos"] = {
				x = 170,
				y = 216
			}
		},
		{
			["tower.holder_id"] = "07",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "07",
			pos = {
				x = 367,
				y = 283
			},
			["tower.default_rally_pos"] = {
				x = 273,
				y = 302
			}
		},
		{
			["tower.holder_id"] = "05",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "05",
			pos = {
				x = 775,
				y = 317
			},
			["tower.default_rally_pos"] = {
				x = 870,
				y = 322
			}
		},
		{
			["tower.holder_id"] = "06",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "06",
			pos = {
				x = 574,
				y = 337
			},
			["tower.default_rally_pos"] = {
				x = 513,
				y = 289
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 205,
				y = 364
			},
			["tower.default_rally_pos"] = {
				x = 309,
				y = 408
			}
		},
		{
			["tower.holder_id"] = "03",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "03",
			pos = {
				x = 409,
				y = 425
			},
			["tower.default_rally_pos"] = {
				x = 406,
				y = 366
			}
		},
		{
			["tower.holder_id"] = "04",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "04",
			pos = {
				x = 337,
				y = 508
			},
			["tower.default_rally_pos"] = {
				x = 239,
				y = 520
			}
		},
		{
			["tower.holder_id"] = "01",
			["tower.terrain_style"] = 304,
			template = "tower_holder_hulking_rage",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "01",
			pos = {
				x = 439,
				y = 532
			},
			["tower.default_rally_pos"] = {
				x = 540,
				y = 543
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{},
		{},
		{
			locked_towers = {
				"tower_build_rock_thrower",
				"tower_build_mage"
			}
		}
	},
	nav_mesh = {
		{
			5,
			nil,
			4,
			3
		},
		{
			10,
			6,
			8
		},
		{
			6,
			4,
			12,
			7
		},
		{
			1,
			nil,
			12,
			3
		},
		{
			9,
			nil,
			6,
			10
		},
		{
			5,
			1,
			3,
			2
		},
		{
			6,
			3,
			12,
			8
		},
		{
			2,
			7,
			11
		},
		{
			nil,
			5,
			10
		},
		{
			9,
			5,
			2
		},
		{
			8,
			12
		},
		{
			7,
			4,
			nil,
			11
		}
	},
	pan_extension = {
		bottom = 0,
		top = 0
	},
	required_sounds = {
		"music_stage318",
		"ElvesLevelHRSounds",
		"ElvesUnstableCrystalSounds",
		"ElvenWoodsAmbienceSounds",
		"ElvesRoadRunnerSpecialSounds",
		"ElvesCreepHyena",
		"ElvesBossBramSounds"
	},
	required_textures = {
		"go_enemies_elven_woods",
		"go_enemies_ancient_metropolis",
		"go_stage318",
		"go_stage318_bg",
		"go_decals-2",
		"go_stages_hulking_rage"
	}
}
