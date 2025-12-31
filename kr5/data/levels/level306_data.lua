-- chunkname: @./kr3/data/levels/level06_data.lua

return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		{
			pos = {
				x = 554,
				y = 480
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
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "Stage06_0001",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 474,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage06_0002",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["render.sprites[1].sort_y"] = 375,
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "Stage06_0003",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 557,
				y = 472
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 501,
				y = 457
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 616,
				y = 457
			}
		},
		{
			template = "decal_rabbit",
			pos = {
				x = 192,
				y = 124
			}
		},
		{
			template = "decal_s06_boxed_boss",
			["editor.game_mode"] = 2,
			pos = {
				x = 575,
				y = 681
			}
		},
		{
			template = "decal_s06_boxed_boss",
			["editor.game_mode"] = 3,
			pos = {
				x = 575,
				y = 681
			}
		},
		{
			template = "decal_s06_eagle",
			["editor.game_mode"] = 1,
			pos = {
				x = 567,
				y = 705
			}
		},
		{
			["editor.r"] = -1.5707963267949,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 572,
				y = 68
			}
		},
		{
			["editor.r"] = -3.1415926535898,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 45,
				y = 490
			}
		},
		{
			["editor.r"] = 0.34906585039887,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 990,
				y = 551
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 348,
				y = 733
			}
		},
		{
			template = "plant_magic_blossom",
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 758,
				y = 206
			}
		},
		{
			template = "plant_magic_blossom",
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 508,
				y = 360
			}
		},
		{
			template = "plant_magic_blossom",
			["ui.nav_mesh_id"] = "15",
			pos = {
				x = 363,
				y = 391
			}
		},
		{
			template = "soldier_gryphon_guard_lower",
			pos = {
				x = 459,
				y = 563
			}
		},
		{
			template = "soldier_gryphon_guard_upper",
			["nav_rally.center"] = {
				x = 460,
				y = 640
			},
			["nav_rally.pos"] = {
				x = 460,
				y = 640
			},
			pos = {
				x = 460,
				y = 640
			}
		},
		{
			template = "soldier_gryphon_guard_upper",
			["nav_rally.center"] = {
				x = 450,
				y = 700
			},
			["nav_rally.pos"] = {
				x = 450,
				y = 700
			},
			pos = {
				x = 450,
				y = 700
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 665,
				y = 135
			},
			["tower.default_rally_pos"] = {
				x = 663,
				y = 230
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 474,
				y = 138
			},
			["tower.default_rally_pos"] = {
				x = 436,
				y = 221
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 330,
				y = 217
			},
			["tower.default_rally_pos"] = {
				x = 321,
				y = 160
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 388,
				y = 278
			},
			["tower.default_rally_pos"] = {
				x = 286,
				y = 310
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 499,
				y = 278
			},
			["tower.default_rally_pos"] = {
				x = 499,
				y = 226
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 600,
				y = 278
			},
			["tower.default_rally_pos"] = {
				x = 600,
				y = 220
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 793,
				y = 301
			},
			["tower.default_rally_pos"] = {
				x = 696,
				y = 324
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 199,
				y = 324
			},
			["tower.default_rally_pos"] = {
				x = 286,
				y = 356
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 144,
				y = 391
			},
			["tower.default_rally_pos"] = {
				x = 239,
				y = 442
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 672,
				y = 417
			},
			["tower.default_rally_pos"] = {
				x = 663,
				y = 357
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 317,
				y = 481
			},
			["tower.default_rally_pos"] = {
				x = 206,
				y = 486
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 301,
			template = "tower_holder_elven_woods",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 860,
				y = 510
			},
			["tower.default_rally_pos"] = {
				x = 771,
				y = 486
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
				"tower_high_elven",
				"tower_druid",
				"tower_entwood"
			}
		},
		{
			max_upgrade_level = 3,
			locked_towers = {
				"tower_silver",
				"tower_forest",
				"tower_high_elven",
				"tower_druid",
				"tower_entwood"
			}
		},
		{
			max_upgrade_level = 3,
			locked_towers = {
				"tower_build_archer",
				"tower_build_barrack",
				"tower_high_elven",
				"tower_druid",
				"tower_entwood"
			}
		}
	},
	nav_mesh = {
		{
			13,
			6,
			2
		},
		{
			1,
			5,
			3
		},
		{
			2,
			4,
			8
		},
		{
			5,
			15,
			8,
			3
		},
		{
			6,
			14,
			4,
			2
		},
		{
			7,
			10,
			5,
			1
		},
		{
			nil,
			12,
			6,
			13
		},
		{
			4,
			9,
			nil,
			3
		},
		{
			11,
			11,
			nil,
			8
		},
		{
			12,
			nil,
			14,
			6
		},
		{
			10,
			nil,
			9,
			15
		},
		{
			nil,
			nil,
			10,
			7
		},
		{
			nil,
			7,
			1,
			1
		},
		{
			10,
			11,
			15,
			5
		},
		{
			14,
			11,
			8,
			4
		}
	},
	pan_extension = {
		bottom = 0,
		top = 0
	},
	required_sounds = {
		"music_stage306",
		"ElvenWoodsAmbienceSounds",
		"ElvesHeroAlleria",
		"ElvesGryphon",
		"ElvesHyena",
		"ElvesPlants",
		"ElvesCreepHyena"
	},
	required_textures = {
		"go_enemies_elven_woods",
		"go_stage306",
		"go_stage306_bg",
		"go_stages_elven_woods"
	}
}
