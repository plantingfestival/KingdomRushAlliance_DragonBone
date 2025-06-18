return {
	locked_hero = false,
	level_terrain_type = 1,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		{
			pos = {
				x = 564,
				y = 75
			}
		},
		{
			pos = {
				x = 800,
				y = 350
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
			template = "background_sounds_blackburn",
			sounds = {
				"BlackburnAmbienceBlackburn"
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "CB_tree",
			pos = {
				x = 714,
				y = 56
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.14
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "blue_flag",
			pos = {
				x = 475,
				y = 87
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.17
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "blue_flag",
			pos = {
				x = 650,
				y = 87
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.17
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1400,
			["render.sprites[1].name"] = "CB_tree",
			pos = {
				x = 758,
				y = 119
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0.14
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_125",
			pos = {
				x = 512,
				y = 384
			}
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 3000,
			["render.sprites[1].name"] = "CB_Stg25_witchHouse",
			pos = {
				x = 399,
				y = 534
			},
			["render.sprites[1].anchor"] = {
				x = 0.5,
				y = 0
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_1",
			["delayed_play.max_delay"] = 20,
			snapping = "top left",
			pos = {
				x = -7.74,
				y = 618.5
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_2",
			["delayed_play.max_delay"] = 20,
			snapping = "top",
			pos = {
				x = 502.46,
				y = 774.14
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_3",
			["delayed_play.max_delay"] = 20,
			snapping = "top right",
			pos = {
				x = 1031.49,
				y = 454.02
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_4",
			["delayed_play.max_delay"] = 20,
			snapping = "bottom right",
			pos = {
				x = 1028.54,
				y = 116.61
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_5",
			["delayed_play.max_delay"] = 20,
			snapping = "bottom",
			pos = {
				x = 687.1,
				y = -12.1
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 5,
			["render.sprites[1].r"] = 0,
			template = "decal_bat_flying_6",
			["delayed_play.max_delay"] = 20,
			snapping = "bottom left",
			pos = {
				x = -12.86,
				y = 155.9
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = 0,
			template = "decal_blackburn_bubble",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 345,
				y = 13
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = 0,
			template = "decal_blackburn_bubble",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 329,
				y = 87
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = 0,
			template = "decal_blackburn_bubble",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 358,
				y = 142
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = 0,
			template = "decal_blackburn_bubble",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 312,
				y = 480
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = 0,
			template = "decal_blackburn_bubble",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 116,
				y = 569
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = 0,
			template = "decal_blackburn_bubble",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 247,
				y = 606
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["delayed_play.min_delay"] = 0,
			["render.sprites[1].r"] = 0,
			template = "decal_blackburn_bubble",
			["delayed_play.max_delay"] = 1,
			pos = {
				x = 458,
				y = 714
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_blackburn_smoke",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_smoke_jump",
			pos = {
				x = 382,
				y = 63
			},
			["render.sprites[1].scale"] = {
				x = 1.2,
				y = 1.2
			}
		},
		{
			template = "decal_blackburn_smoke",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_smoke_jump",
			pos = {
				x = 271,
				y = 546
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_blackburn_smoke",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_smoke_jump",
			pos = {
				x = 284,
				y = 596
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_blackburn_smoke",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_smoke_jump",
			pos = {
				x = 36,
				y = 603
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_blackburn_smoke",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_smoke_jump",
			pos = {
				x = 485,
				y = 705
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_blackburn_smoke",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_smoke_jump",
			pos = {
				x = 103,
				y = 719
			},
			["render.sprites[1].scale"] = {
				x = 1.2,
				y = 1.2
			}
		},
		{
			template = "decal_blackburn_smoke",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_smoke_jump",
			pos = {
				x = 258,
				y = 736
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_blackburn_smoke",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_smoke_jump",
			pos = {
				x = -49,
				y = 752
			},
			["render.sprites[1].scale"] = {
				x = 1.2,
				y = 1.2
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 291,
				y = 60
			},
			["render.sprites[1].scale"] = {
				x = 1.2,
				y = 1.2
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 420,
				y = 101
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 308,
				y = 135
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 313,
				y = 143
			},
			["render.sprites[1].scale"] = {
				x = 1.2,
				y = 1.2
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 454,
				y = 384
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 468,
				y = 393
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["render.sprites[1].z"] = 1400,
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].flip"] = true,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 640,
				y = 470
			},
			["render.sprites[1].scale"] = {
				x = 0.5,
				y = 0.5
			}
		},
		{
			["render.sprites[1].z"] = 1400,
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 186,
				y = 471
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 620,
				y = 489
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 603,
				y = 497
			},
			["render.sprites[1].scale"] = {
				x = -0.9,
				y = 0.9
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 302,
				y = 509
			},
			["render.sprites[1].scale"] = {
				x = -0.9,
				y = 0.9
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 293,
				y = 515
			},
			["render.sprites[1].scale"] = {
				x = -1.2,
				y = 1.2
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 202,
				y = 541
			},
			["render.sprites[1].scale"] = {
				x = -1.2,
				y = 1.2
			}
		},
		{
			["render.sprites[1].z"] = 1400,
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 219,
				y = 544
			},
			["render.sprites[1].scale"] = {
				x = 0.9,
				y = 0.9
			}
		},
		{
			["render.sprites[1].z"] = 1400,
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 8,
				y = 550
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["render.sprites[1].z"] = 1400,
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].flip"] = true,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 17,
				y = 555
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			["render.sprites[1].z"] = 1400,
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].flip"] = true,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = -86,
				y = 650
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			["render.sprites[1].z"] = 1400,
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 166,
				y = 669
			},
			["render.sprites[1].scale"] = {
				x = 0.9,
				y = 0.9
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 225,
				y = 679
			},
			["render.sprites[1].scale"] = {
				x = 0.9,
				y = 0.9
			}
		},
		{
			["render.sprites[1].z"] = 1400,
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 34,
				y = 685
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 214,
				y = 688
			},
			["render.sprites[1].scale"] = {
				x = -1.2,
				y = 1.2
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 574,
				y = 707
			},
			["render.sprites[1].scale"] = {
				x = 0.8,
				y = 0.8
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 301,
				y = 725
			},
			["render.sprites[1].scale"] = {
				x = 1,
				y = 1
			}
		},
		{
			template = "decal_blackburn_weed",
			["render.sprites[1].r"] = 0,
			["render.sprites[1].name"] = "decal_blackburn_weed_idle",
			pos = {
				x = 280,
				y = 732
			},
			["render.sprites[1].scale"] = {
				x = -1.2,
				y = 1.2
			}
		},
		{
			["editor.exit_id"] = 1,
			template = "decal_defend_point",
			pos = {
				x = 564,
				y = 75
			}
		},
		{
			template = "decal_s25_nessie",
			pos = {
				x = 169,
				y = 459
			}
		},
		{
			["editor.r"] = -0.13962634015954,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = 985,
				y = 195
			}
		},
		{
			["editor.r"] = 4.2935099599061,
			["editor.path_id"] = 5,
			template = "editor_wave_flag",
			["editor.len"] = 32,
			pos = {
				x = 395,
				y = 231
			}
		},
		{
			["editor.r"] = 0.97738438111688,
			["editor.path_id"] = 6,
			template = "editor_wave_flag",
			["editor.len"] = 32,
			pos = {
				x = 327,
				y = 357
			}
		},
		{
			["editor.r"] = 3.1415926535898,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 250,
			pos = {
				x = 40,
				y = 371
			}
		},
		{
			["editor.r"] = 2.3736477827123,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 32,
			pos = {
				x = 495,
				y = 498
			}
		},
		{
			["editor.r"] = 3.4208453339089,
			["editor.path_id"] = 7,
			template = "editor_wave_flag",
			["editor.len"] = 32,
			pos = {
				x = 504,
				y = 643
			}
		},
		{
			["editor.r"] = 1.5707963267949,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 60,
			pos = {
				x = 662,
				y = 720
			}
		},
		{
			["tower.holder_id"] = "11",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "11",
			pos = {
				x = 473,
				y = 133
			},
			["tower.default_rally_pos"] = {
				x = 557,
				y = 77
			}
		},
		{
			["tower.holder_id"] = "10",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "10",
			pos = {
				x = 783,
				y = 168
			},
			["tower.default_rally_pos"] = {
				x = 644,
				y = 182
			}
		},
		{
			["tower.holder_id"] = "12",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "12",
			pos = {
				x = 540,
				y = 179
			},
			["tower.default_rally_pos"] = {
				x = 596,
				y = 124
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 287,
				y = 212
			},
			["tower.default_rally_pos"] = {
				x = 289,
				y = 312
			}
		},
		{
			["tower.holder_id"] = "13",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "13",
			pos = {
				x = 203,
				y = 243
			},
			["tower.default_rally_pos"] = {
				x = 221,
				y = 337
			}
		},
		{
			["tower.holder_id"] = "5",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "5",
			pos = {
				x = 813,
				y = 245
			},
			["tower.default_rally_pos"] = {
				x = 910,
				y = 254
			}
		},
		{
			["tower.holder_id"] = "9",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "9",
			pos = {
				x = 716,
				y = 267
			},
			["tower.default_rally_pos"] = {
				x = 638,
				y = 215
			}
		},
		{
			["tower.holder_id"] = "7",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "7",
			pos = {
				x = 427,
				y = 306
			},
			["tower.default_rally_pos"] = {
				x = 435,
				y = 244
			}
		},
		{
			["tower.holder_id"] = "2",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "2",
			pos = {
				x = 525,
				y = 343
			},
			["tower.default_rally_pos"] = {
				x = 526,
				y = 277
			}
		},
		{
			["tower.holder_id"] = "6",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "6",
			pos = {
				x = 914,
				y = 386
			},
			["tower.default_rally_pos"] = {
				x = 879,
				y = 312
			}
		},
		{
			["tower.holder_id"] = "8",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "8",
			pos = {
				x = 267,
				y = 393
			},
			["tower.default_rally_pos"] = {
				x = 259,
				y = 326
			}
		},
		{
			["tower.holder_id"] = "1",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "1",
			pos = {
				x = 706,
				y = 426
			},
			["tower.default_rally_pos"] = {
				x = 716,
				y = 362
			}
		},
		{
			["tower.holder_id"] = "4",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "4",
			pos = {
				x = 761,
				y = 483
			},
			["tower.default_rally_pos"] = {
				x = 802,
				y = 409
			}
		},
		{
			["tower.holder_id"] = "3",
			["tower.terrain_style"] = 108,
			template = "tower_holder_blackburn",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "3",
			pos = {
				x = 831,
				y = 529
			},
			["tower.default_rally_pos"] = {
				x = 860,
				y = 463
			}
		}
	},
	invalid_path_ranges = {
		{
			path_id = 7,
			from = 1,
			flags = NF_RALLY
		}
	},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 5,
			available_towers = {
				"tower_build_flamespitter",
				"tower_build_arcane_wizard"
			}
		}
	},
	nav_mesh = {
		{
			6,
			4,
			2,
			9
		},
		{
			1,
			nil,
			7,
			12
		},
		{
			[3] = 4,
			[4] = 6
		},
		{
			3,
			3,
			1,
			1
		},
		{
			6,
			6,
			9,
			10
		},
		{
			nil,
			3,
			1,
			5
		},
		{
			2,
			nil,
			8,
			11
		},
		{
			7,
			nil,
			13,
			14
		},
		{
			5,
			1,
			12,
			10
		},
		{
			5,
			9,
			12
		},
		{
			12,
			7,
			14
		},
		{
			10,
			2,
			11
		},
		{
			14,
			8
		},
		{
			11,
			8,
			13
		}
	},
	required_sounds = {
		"kr1_common",
		"music_stage125",
		"HalloweenSounds"
	},
	required_textures = {
		"kr1_enemies_common",
		"go_enemies_kr2_halloween",
		"go_stages_blackburn",
		"go_stage125",
		"go_stage125_bg"
	}
}