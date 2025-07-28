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
				x = 950,
				y = 438
			}
		},
		{
			pos = {
				x = 950,
				y = 212
			}
		},
	},
	entities_list = {
		{
			template = "controller_teleport_enemies",
			path = 3,
			start_ni = 97,
			end_ni = 114,
			duration = 0.5,
		},
		{
			template = "decal_background",
			["render.sprites[1].z"] = 1000,
			["render.sprites[1].name"] = "stage_426",
			pos = {
				x = 512,
				y = 384
			},
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 860,
				y = 510
			},
			["tower.default_rally_pos"] = {
				x = 764,
				y = 486
			},
			["ui.nav_mesh_id"] = "1",
			["tower.holder_id"] = "1",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 590,
				y = 622
			},
			["tower.default_rally_pos"] = {
				x = 556,
				y = 555
			},
			["ui.nav_mesh_id"] = "2",
			["tower.holder_id"] = "2",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 615,
				y = 457
			},
			["tower.default_rally_pos"] = {
				x = 657,
				y = 542
			},
			["ui.nav_mesh_id"] = "3",
			["tower.holder_id"] = "3",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 486,
				y = 462
			},
			["tower.default_rally_pos"] = {
				x = 467,
				y = 555
			},
			["ui.nav_mesh_id"] = "4",
			["tower.holder_id"] = "4",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 124,
				y = 352
			},
			["tower.default_rally_pos"] = {
				x = 119,
				y = 438
			},
			["ui.nav_mesh_id"] = "5",
			["tower.holder_id"] = "5",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 815,
				y = 357
			},
			["tower.default_rally_pos"] = {
				x = 848,
				y = 449
			},
			["ui.nav_mesh_id"] = "6",
			["tower.holder_id"] = "6",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 435,
				y = 617
			},
			["tower.default_rally_pos"] = {
				x = 337,
				y = 594
			},
			["ui.nav_mesh_id"] = "7",
			["tower.holder_id"] = "7",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 256,
				y = 552
			},
			["tower.default_rally_pos"] = {
				x = 311,
				y = 507
			},
			["ui.nav_mesh_id"] = "8",
			["tower.holder_id"] = "8",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 700,
				y = 219
			},
			["tower.default_rally_pos"] = {
				x = 753,
				y = 167
			},
			["ui.nav_mesh_id"] = "9",
			["tower.holder_id"] = "9",
		},
		{
			template = "holder_roots_lands_blocked",
			["tower.terrain_style"] = 408,
			pos = {
				x = 609,
				y = 197
			},
			["tower.default_rally_pos"] = {
				x = 600,
				y = 127
			},
			["ui.nav_mesh_id"] = "10",
			["tower.holder_id"] = "10",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 167,
				y = 195
			},
			["tower.default_rally_pos"] = {
				x = 166,
				y = 298
			},
			["ui.nav_mesh_id"] = "11",
			["tower.holder_id"] = "11",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 818,
				y = 270
			},
			["tower.default_rally_pos"] = {
				x = 850,
				y = 212
			},
			["ui.nav_mesh_id"] = "12",
			["tower.holder_id"] = "12",
		},
		{
			template = "tower_holder",
			["tower.terrain_style"] = 408,
			pos = {
				x = 280,
				y = 187
			},
			["tower.default_rally_pos"] = {
				x = 284,
				y = 292
			},
			["ui.nav_mesh_id"] = "13",
			["tower.holder_id"] = "13",
		},
		{
			["editor.r"] = 1.5791294672350324,
			["editor.path_id"] = 1,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = 284,
				y = 715
			},
		},
		{
			["editor.r"] = 3.141592653589793,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = -116,
				y = 462
			},
		},
		{
			["editor.r"] = 3.141592653589793,
			["editor.path_id"] = 3,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = -116,
				y = 419
			},
		},
		{
			["editor.r"] = 3.141592653589793,
			["editor.path_id"] = 4,
			template = "editor_wave_flag",
			["editor.len"] = 200,
			pos = {
				x = -116,
				y = 283
			},
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = -155,
				y = 735
			},
			["render.sprites[1].anchor.x"] = 0.47,
			["render.sprites[1].anchor.y"] = 0.242,
			["render.sprites[1].scale.x"] = 1.16,
			["render.sprites[1].scale.y"] = 1.942,
			["render.sprites[1].name"] = "swamp_bubble_run",
			["render.sprites[1].animated"] = true,
			max_delay = 10,
			min_delay = 0,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 1124,
				y = 750
			},
			["render.sprites[1].anchor.x"] = 0.47,
			["render.sprites[1].anchor.y"] = 0.242,
			["render.sprites[1].scale.x"] = 1.16,
			["render.sprites[1].scale.y"] = 1.942,
			["render.sprites[1].name"] = "swamp_bubble_run",
			["render.sprites[1].animated"] = true,
			max_delay = 10,
			min_delay = 0,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 1070,
				y = 716
			},
			["render.sprites[1].anchor.x"] = 0.47,
			["render.sprites[1].anchor.y"] = 0.242,
			["render.sprites[1].scale.x"] = 1.16,
			["render.sprites[1].scale.y"] = 1.942,
			["render.sprites[1].name"] = "swamp_bubble_run",
			["render.sprites[1].animated"] = true,
			max_delay = 10,
			min_delay = 0,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 1100,
				y = 741
			},
			["render.sprites[1].anchor.x"] = 0.47,
			["render.sprites[1].anchor.y"] = 0.242,
			["render.sprites[1].scale.x"] = 1.16,
			["render.sprites[1].scale.y"] = 1.942,
			["render.sprites[1].name"] = "swamp_bubble_run",
			["render.sprites[1].animated"] = true,
			max_delay = 10,
			min_delay = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 960,
				y = 497
			},
			["render.sprites[1].z"] = Z_DECALS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 960,
				y = 366
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 960,
				y = 273
			},
			["render.sprites[1].z"] = Z_OBJECTS,
			["editor.flip"] = 0,
			["editor.tag"] = 0,
		},
		{
			template = "decal_defense_flag5",
			pos = {
				x = 960,
				y = 151
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
				x = 950,
				y = 438
			},
		},
		{
			template = "decal_defend_point5",
			["editor.flip"] = 0,
			["editor.exit_id"] = 1,
			["editor.alpha"] = 10,
			["editor.orientation"] = 1,
			pos = {
				x = 950,
				y = 212
			},
		},
		{
			template = "veznan_crystal",
			pos = {
				x = 350,
				y = 177
			},
		},
		{
			template = "veznan_crystal",
			pos = {
				x = 838,
				y = 118
			},
		},
		{
			template = "veznan_crystal",
			pos = {
				x = 686,
				y = 595
			},
		},
		{
			template = "veznan_crystal",
			pos = {
				x = 764,
				y = 404
			},
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 325,
				y = 321
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0,
			["render.sprites[1].name"] = "Stage_26_mask_1_1",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 400,
				y = 303
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0,
			["render.sprites[1].name"] = "Stage_26_mask_1",
			["render.sprites[1].animated"] = false,
		},
		{
			template = "fx_repeat_forever",
			pos = {
				x = 520,
				y = 233
			},
			["render.sprites[1].anchor.x"] = 0.5,
			["render.sprites[1].anchor.y"] = 0,
			["render.sprites[1].name"] = "Stage_26_mask_2",
			["render.sprites[1].animated"] = false,
		},
	},
	nav_mesh = {
		{ nil, nil, 3, 6 },
		{ 1, nil, 7, 3 },
		{ 6, 2, 4, 9 },
		{ 3, 7, 8, 10 },
		{ 4, 8, nil, 11 },
		{ nil, 1, 3, 12 },
		{ 2, nil, 8, 4 },
		{ 7, nil, nil, 5 },
		{ 12, 6, 10, nil },
		{ 9, 3, 13, nil },
		{ 13, 5, nil, nil },
		{ nil, 6, 9, nil },
		{ 10, 5, 11, nil },
	},
	invalid_path_ranges = {
		{
			from = 97,
			to = 114,
			path_id = 3,
		},
	},
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
		"sounds_stage426",
		"HalloweenSounds",
	},
	required_textures = {
		"go_enemies_halloween",
		"go_enemies_rotten",
		"go_stage426",
	}
}