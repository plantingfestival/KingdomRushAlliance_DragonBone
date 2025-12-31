-- chunkname: @./kr3/data/levels/level05_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		{
			pos = {
				x = 67,
				y = 440
			}
		},
		{
			pos = {
				x = 67,
				y = 190
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
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage05_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_bambi",
			pos = {
				x = 60,
				y = 559
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			},
			run_offset = {
				x = 164,
				y = 96
			}
		},
		{
			template = "decal_bambi",
			["render.sprites[1].flip_x"] = true,
			pos = {
				x = 258,
				y = 586
			}
		},
		{
			template = "decal_bush_statue",
			statue_id = 2,
			pos = {
				x = 721,
				y = 77
			}
		},
		{
			template = "decal_bush_statue",
			statue_id = 1,
			pos = {
				x = 336,
				y = 457
			}
		},
		{
			template = "decal_bush_statue",
			statue_id = 3,
			pos = {
				x = 798,
				y = 470
			}
		},
		{
			["editor.exit_id"] = 2,
			template = "decal_defend_point",
			pos = {
				x = 41,
				y = 190
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 41,
				y = 434
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 37,
				y = 107
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 37,
				y = 254
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 37,
				y = 355
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 37,
				y = 487
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s05_cascade_2",
			pos = {
				x = 348,
				y = 748
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s05_cascade_3",
			pos = {
				x = 348,
				y = 748
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s05_cascade_splash",
			pos = {
				x = 348,
				y = 748
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s05_cascade_waves",
			pos = {
				x = 348,
				y = 748
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s05_cascade_1",
			pos = {
				x = 348,
				y = 748
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_loop",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_s05_cascade_splashes",
			pos = {
				x = 348,
				y = 748
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_rabbit",
			pos = {
				x = 108,
				y = 356
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 441,
				y = -42
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 583,
				y = -42
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 441,
				y = -13
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 583,
				y = -13
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 931,
				y = 2
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 969,
				y = 2
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1007,
				y = 2
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1100,
				y = 2
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1140,
				y = 2
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 441,
				y = 12
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 583,
				y = 12
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1112,
				y = 184
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1150,
				y = 184
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1188,
				y = 184
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1093,
				y = 322
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1093,
				y = 352
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1053,
				y = 382
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1093,
				y = 382
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1133,
				y = 382
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1113,
				y = 652
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1153,
				y = 652
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 1193,
				y = 652
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 541,
				y = 665
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 688,
				y = 665
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 541,
				y = 694
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 688,
				y = 694
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 541,
				y = 723
			}
		},
		{
			template = "decal_s05_tree_pine",
			pos = {
				x = 688,
				y = 723
			}
		},
		{
			template = "decal_s05_tree_round",
			pos = {
				x = 380,
				y = -14
			}
		},
		{
			template = "decal_s05_tree_round",
			pos = {
				x = 253,
				y = 31
			}
		},
		{
			template = "decal_s05_tree_round",
			pos = {
				x = 19,
				y = 292
			}
		},
		{
			template = "decal_s05_tree_round",
			pos = {
				x = -24,
				y = 312
			}
		},
		{
			template = "decal_s05_tree_round",
			pos = {
				x = 137,
				y = 577
			}
		},
		{
			template = "decal_s05_tree_round",
			pos = {
				x = 176,
				y = 587
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 515,
				y = 86
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 977,
				y = 120
			}
		},
		{
			["editor.r"] = 0,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 977,
				y = 500
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 615,
				y = 726
			}
		},
		{
			template = "plant_magic_blossom",
			["ui.nav_mesh_id"] = "24",
			pos = {
				x = 432,
				y = 220
			}
		},
		{
			template = "plant_magic_blossom",
			["ui.nav_mesh_id"] = "25",
			pos = {
				x = 928,
				y = 272
			}
		},
		{
			template = "plant_magic_blossom",
			["ui.nav_mesh_id"] = "26",
			pos = {
				x = 175,
				y = 305
			}
		},
		{
			["tower.holder_id"] = "22",
			template = "tower_elven_barrack_lvl2",
			["editor.game_mode"] = 3,
			["tower.terrain_style"] = 301,
			["ui.nav_mesh_id"] = "22",
			["barrack.rally_pos"] = {
				x = 714,
				y = 346
			},
			pos = {
				x = 750,
				y = 255
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 346
			}
		},
		{
			["tower.holder_id"] = "21",
			template = "tower_elven_barrack_lvl2",
			["editor.game_mode"] = 3,
			["tower.terrain_style"] = 301,
			["ui.nav_mesh_id"] = "21",
			["barrack.rally_pos"] = {
				x = 462,
				y = 437
			},
			pos = {
				x = 426,
				y = 502
			},
			["tower.default_rally_pos"] = {
				x = 462,
				y = 437
			}
		},
		{
			["tower.holder_id"] = "23",
			template = "tower_elven_barrack_lvl2",
			["editor.game_mode"] = 1,
			["tower.terrain_style"] = 301,
			["ui.nav_mesh_id"] = "23",
			["barrack.rally_pos"] = {
				x = 553,
				y = 303
			},
			pos = {
				x = 554,
				y = 359
			},
			["tower.default_rally_pos"] = {
				x = 553,
				y = 303
			}
		},
		{
			["tower.holder_id"] = "23",
			template = "tower_elven_barrack_lvl2",
			["editor.game_mode"] = 2,
			["tower.terrain_style"] = 301,
			["ui.nav_mesh_id"] = "23",
			["barrack.rally_pos"] = {
				x = 553,
				y = 303
			},
			pos = {
				x = 554,
				y = 359
			},
			["tower.default_rally_pos"] = {
				x = 553,
				y = 303
			}
		},
		{
			["tower.holder_id"] = "19",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "19",
			pos = {
				x = 414,
				y = 97
			},
			["tower.default_rally_pos"] = {
				x = 514,
				y = 98
			}
		},
		{
			["tower.holder_id"] = "17",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "17",
			pos = {
				x = 710,
				y = 181
			},
			["tower.default_rally_pos"] = {
				x = 616,
				y = 243
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 347,
				y = 207
			},
			["tower.default_rally_pos"] = {
				x = 381,
				y = 300
			}
		},
		{
			["tower.holder_id"] = "18",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "18",
			pos = {
				x = 516,
				y = 207
			},
			["tower.default_rally_pos"] = {
				x = 528,
				y = 147
			}
		},
		{
			["tower.holder_id"] = "15",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 164,
				y = 216
			},
			["tower.default_rally_pos"] = {
				x = 166,
				y = 154
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "22",
			pos = {
				x = 750,
				y = 255
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 346
			}
		},
		{
			["tower.holder_id"] = "22",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "22",
			pos = {
				x = 750,
				y = 255
			},
			["tower.default_rally_pos"] = {
				x = 714,
				y = 346
			}
		},
		{
			["tower.holder_id"] = "23",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 3,
			["ui.nav_mesh_id"] = "23",
			pos = {
				x = 554,
				y = 359
			},
			["tower.default_rally_pos"] = {
				x = 553,
				y = 303
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 353,
				y = 360
			},
			["tower.default_rally_pos"] = {
				x = 350,
				y = 300
			}
		},
		{
			["tower.holder_id"] = "16",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "16",
			pos = {
				x = 164,
				y = 398
			},
			["tower.default_rally_pos"] = {
				x = 172,
				y = 488
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 846,
				y = 406
			},
			["tower.default_rally_pos"] = {
				x = 846,
				y = 346
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 746,
				y = 408
			},
			["tower.default_rally_pos"] = {
				x = 760,
				y = 346
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 1,
			["ui.nav_mesh_id"] = "21",
			pos = {
				x = 426,
				y = 502
			},
			["tower.default_rally_pos"] = {
				x = 462,
				y = 437
			}
		},
		{
			["tower.holder_id"] = "21",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 2,
			["ui.nav_mesh_id"] = "21",
			pos = {
				x = 426,
				y = 502
			},
			["tower.default_rally_pos"] = {
				x = 462,
				y = 437
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 622,
				y = 506
			},
			["tower.default_rally_pos"] = {
				x = 613,
				y = 452
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_towers = {
				"tower_silver",
				"tower_forest",
				"tower_wild_magus",
				"tower_high_elven",
				"tower_druid",
				"tower_entwood"
			}
		},
		{
			max_upgrade_level = 2,
			locked_towers = {
				"tower_silver",
				"tower_forest",
				"tower_wild_magus",
				"tower_high_elven",
				"tower_druid",
				"tower_entwood"
			}
		},
		{
			max_upgrade_level = 2,
			locked_towers = {
				"tower_silver",
				"tower_forest",
				"tower_wild_magus",
				"tower_high_elven",
				"tower_druid",
				"tower_entwood",
				"tower_build_barrack",
				"tower_build_rock_thrower"
			}
		}
	},
	nav_mesh = {
		[10] = {
			24,
			11,
			15,
			19
		},
		[11] = {
			23,
			21,
			26,
			10
		},
		[12] = {
			14,
			nil,
			21,
			23
		},
		[13] = {
			[3] = 14,
			[4] = 25
		},
		[14] = {
			13,
			12,
			23,
			22
		},
		[15] = {
			10,
			26,
			nil,
			19
		},
		[16] = {
			21,
			nil,
			nil,
			26
		},
		[17] = {
			25,
			22,
			18,
			19
		},
		[18] = {
			17,
			23,
			24,
			19
		},
		[19] = {
			17,
			10,
			15
		},
		[21] = {
			12,
			nil,
			16,
			11
		},
		[22] = {
			25,
			14,
			23,
			17
		},
		[23] = {
			14,
			12,
			11,
			18
		},
		[24] = {
			18,
			11,
			10,
			19
		},
		[25] = {
			nil,
			13,
			22
		},
		[26] = {
			11,
			16,
			nil,
			15
		}
	},
	pan_extension = {
		bottom = 0,
		top = 0
	},
	required_sounds = {
		"music_stage305",
		"ElvenWoodsAmbienceSounds",
		"ElvesHeroAlleria",
		"ElvesLevelFiveSounds",
		"ElvesPlants",
		"ElvesCreepHyena"
	},
	required_textures = {
		"go_enemies_elven_woods",
		"go_enemies_common-3",
		"go_towers_elven_stargazers",
		"go_stage305",
		"go_stage305_bg",
		"go_stages_elven_woods"
	}
}
