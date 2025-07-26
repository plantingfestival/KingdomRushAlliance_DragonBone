return {
	level_terrain_type = 408,
	locked_hero = false,
	max_upgrade_level = 5,
	custom_start_pos = {
		zoom = 1.3,
		pos = {x = 512, y = 384}
	},
	custom_spawn_pos = {
		{
			pos = {
				x = 50,
				y = 483
			}
		},
		{
			pos = {
				x = 50,
				y = 270
			}
		}
	},
	entities_list = {
		{
			template = "swamp_controller",
			["graveyard.pi"] = 1,
			["graveyard.spawn_pos"] = {
				{
					x = 300,
					y = 672
				}
			},
			pos = {
				x = 300,
				y = 672
			}
		},
		{
			template = "decal_spider_rotten_egg_shooter",
			pos = {
				x = 386,
				y = 81
			},
			["spawner.pi"] = 4,
			["spawner.name"] = "shooter1",
			["editor.game_mode"] = 1,
		},
		{
			template = "decal_spider_rotten_egg_shooter",
			pos = {
				x = 300,
				y = 672
			},
			["spawner.pi"] = 1,
			["spawner.name"] = "shooter2",
			["editor.game_mode"] = 1,
		},
		{
			template = "swamp_spawner",
			pos = {
				x = 386,
				y = 81
			},
			["spawner.pi"] = 1,
			["spawner.name"] = "object1",
			["editor.game_mode"] = 1,
		},
		{
			template = "swamp_spawner",
			pos = {
				x = 300,
				y = 672
			},
			["spawner.pi"] = 1,
			["spawner.name"] = "object2",
			["editor.game_mode"] = 1,
		},
		{
			template = "mega_spawner",
			load_file = "level427campaign_spawner",
			["editor.game_mode"] = 1,
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_427",
			pos = {
				x = 512,
				y = 384
			},
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 137,
				y = 386
			},
			["tower.default_rally_pos"] = {
				x = 149,
				y = 471
			},
			["ui.nav_mesh_id"] = "1",
			["tower.holder_id"] = "1",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 526,
				y = 579
			},
			["tower.default_rally_pos"] = {
				x = 424,
				y = 587
			},
			["ui.nav_mesh_id"] = "2",
			["tower.holder_id"] = "2",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 672,
				y = 417
			},
			["tower.default_rally_pos"] = {
				x = 749,
				y = 386
			},
			["ui.nav_mesh_id"] = "3",
			["tower.holder_id"] = "3",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 771,
				y = 536
			},
			["tower.default_rally_pos"] = {
				x = 844,
				y = 494
			},
			["ui.nav_mesh_id"] = "4",
			["tower.holder_id"] = "4",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 901,
				y = 258
			},
			["tower.default_rally_pos"] = {
				x = 871,
				y = 200
			},
			["ui.nav_mesh_id"] = "5",
			["tower.holder_id"] = "5",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 830,
				y = 325
			},
			["tower.default_rally_pos"] = {
				x = 762,
				y = 264
			},
			["ui.nav_mesh_id"] = "6",
			["tower.holder_id"] = "6",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 384,
				y = 478
			},
			["tower.default_rally_pos"] = {
				x = 404,
				y = 422
			},
			["ui.nav_mesh_id"] = "7",
			["tower.holder_id"] = "7",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 305,
				y = 460
			},
			["tower.default_rally_pos"] = {
				x = 249,
				y = 408
			},
			["ui.nav_mesh_id"] = "8",
			["tower.holder_id"] = "8",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 484,
				y = 319
			},
			["tower.default_rally_pos"] = {
				x = 481,
				y = 244
			},
			["ui.nav_mesh_id"] = "9",
			["tower.holder_id"] = "9",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 554,
				y = 399
			},
			["tower.default_rally_pos"] = {
				x = 475,
				y = 462
			},
			["ui.nav_mesh_id"] = "10",
			["tower.holder_id"] = "10",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 387,
				y = 161
			},
			["tower.default_rally_pos"] = {
				x = 376,
				y = 247
			},
			["ui.nav_mesh_id"] = "11",
			["tower.holder_id"] = "11",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 594,
				y = 182
			},
			["tower.default_rally_pos"] = {
				x = 550,
				y = 261
			},
			["ui.nav_mesh_id"] = "12",
			["tower.holder_id"] = "12",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 215,
				y = 167
			},
			["tower.default_rally_pos"] = {
				x = 225,
				y = 264
			},
			["ui.nav_mesh_id"] = "13",
			["tower.holder_id"] = "13",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 683,
				y = 212
			},
			["tower.default_rally_pos"] = {
				x = 627,
				y = 286
			},
			["ui.nav_mesh_id"] = "14",
			["tower.holder_id"] = "14",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 137,
				y = 535
			},
			["tower.default_rally_pos"] = {
				x = 149,
				y = 471
			},
			["ui.nav_mesh_id"] = "15",
			["tower.holder_id"] = "15",
		},
		{
			["editor.r"] = 1.0921685650267206,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 555,
				y = 723
			},
		},
		{
			["editor.r"] = -0.008333140440135918,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 1140,
				y = 562
			},
		},
		{
			["editor.r"] = -0.008333140440135918,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 1140,
				y = 193
			},
		},
		{
			["editor.r"] = -1.5707963267948966,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 575,
				y = 60
			},
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 40,
				y = 548
			},
			["render.sprites[1].z"] = Z_DECALS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 40,
				y = 420
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 40,
				y = 320
			},
			["render.sprites[1].z"] = Z_DECALS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 40,
				y = 205
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defend_point5",
			["editor.flip"] = 0,
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			["editor.orientation"] = 1,
			pos = {
				x = 50,
				y = 483
			},
		},
		{
			template = "decal_defend_point5",
			["editor.flip"] = 0,
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			["editor.orientation"] = 1,
			pos = {
				x = 50,
				y = 270
			},
		},
		{
			template = "veznan_crystal",
			pos = {
				x = 267,
				y = 327
			},
		},
		{
			template = "veznan_crystal",
			pos = {
				x = 389,
				y = 328
			},
		},
		{
			template = "veznan_crystal",
			pos = {
				x = 590,
				y = 357
			},
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 345,
				y = 665
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0.5,
			["render.sprites[1].z"] = Z_DECALS,
			["render.sprites[1].name"] = "kr4_level27_wharf",
			["render.sprites[1].animated"] = false,
		},
	},
	nav_mesh = {
		{ 8, 13, nil, 15 },
		{ 4, 10, 7, nil },
		{ 6, 14, 10, 4 },
		{ nil, 3, 2, nil },
		{ nil, nil, 6, 4 },
		{ 5, nil, 3, 4 },
		{ 2, 9, 8, nil },
		{ 7, 13, 1, nil },
		{ 3, 12, 8, 10 },
		{ 3, 9, 7, 2 },
		{ 12, nil, 13, 9 },
		{ 14, nil, 11, 9 },
		{ 11, nil, nil, 1 },
		{ 6, nil, 12, 3 },
		{ 8, 1, nil, nil },
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		[3] = {
			locked_hero = false,
			max_upgrade_level = 5,
			available_towers = {
				"tower_build_warmongers_barrack",
				"tower_build_royal_archers"
			}
		}
	},
	required_sounds = {
		"kr1_common",
		"sounds_stage427",
		"HalloweenSounds",
	},
	required_textures = {
		"go_enemies_halloween",
		"go_enemies_rotten",
		"go_enemies_kr2_halloween",
		"go_stage427",
		"go_stage115",
	}
}