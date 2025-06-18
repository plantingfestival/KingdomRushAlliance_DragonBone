-- chunkname: @./kr5/data/levels/level99_data.lua

return {
	locked_hero = false,
	level_terrain_type = 5,
	max_upgrade_level = 5,
	custom_spawn_pos = {
		{
			pos = {
				x = 736,
				y = 62
			}
		},
		{
			pos = {
				x = 685,
				y = 62
			}
		}
	},
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
				x = 712,
				y = 59
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 650,
				y = 50
			}
		},
		{
			["editor.tag"] = 0,
			template = "decal_defense_flag",
			pos = {
				x = 780,
				y = 54
			}
		},
		{
			["editor.r"] = 3.1590459461097,
			["editor.path_id"] = 2,
			template = "editor_wave_flag",
			["editor.len"] = 240,
			pos = {
				x = -139,
				y = 507
			}
		},
		{
			["tower.holder_id"] = "14",
			["tower.terrain_style"] = 1,
			template = "tower_holder_sea_of_trees",
			["editor.game_mode"] = 0,
			["ui.nav_mesh_id"] = "14",
			pos = {
				x = 232,
				y = 397
			},
			["tower.default_rally_pos"] = {
				x = 232,
				y = 329
			}
		}
	},
	invalid_path_ranges = {},
	level_mode_overrides = {
		{
			max_upgrade_level = 5,
			locked_powers = {},
			locked_towers = {}
		},
		{},
		{}
	},
	nav_mesh = {
		[14] = {}
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
