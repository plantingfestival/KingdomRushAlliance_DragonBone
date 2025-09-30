local GS = {}

-- customization
GS.extra_levels = {
	[115] = {},
	[122] = {},
	[123] = {},
	[124] = {},
	[125] = {},
	[126] = {},
	[219] = {},
	[220] = {},
	[221] = {},
	[426] = {},
	[427] = {},
}
-- customization
GS.gameplay_tips_count = 2
GS.early_wave_reward_per_second = 1
GS.early_wave_reward_per_second_default = 1
GS.claimable_achievements = true
GS.health_bar_colors = {
	black = {
		0,
		0,
		0,
		255
	},
	bg = {
		208,
		0,
		23,
		255
	},
	fg = {
		0,
		186,
		0,
		255
	}
}
GS.max_difficulty = DIFFICULTY_IMPOSSIBLE
GS.difficulty_enemy_hp_max_factor = {
	0.7,
	0.8,
	1,
	1.2
}
GS.difficulty_enemy_speed_factor = {
	0.8,
	1,
	1,
	1.2
}
GS.main_campaign_levels = 16
GS.expansions_unlock_level = {
	{
		default = 6,
		arachnophobia = 11
	},
	["com.ironhidegames.kingdomrush.alliance.universal.premium"] = {
		default = 6,
		colossal_dwarfare = 11,
		arachnophobia = 11,
		wukong = 11
	}
}
GS.dlcs_unlock_level = {
	1,
	["com.ironhidegames.kingdomrush.alliance.universal.premium"] = 11
}
GS.last_level = 35
GS.endless_levels_count = 1
GS.level_ranges = {
	{
		1,
		16
	},
	{
		17,
		19
	},
	{
		20,
		22
	},
	{
		23,
		27
	},
	{
		28,
		30
	},
	{
		31,
		35
	}
}
GS.level_range_names = {
	"base",
	"undying_fury",
	"ancient_hunger",
	"colossal_dwarfare",
	"arachnophobia",
	"wukong"
}
GS.dlc_names = {
	{
		id = "dlc_1",
		name = "colossal_dwarfare"
	},
	{
		id = "dlc_2",
		name = "wukong"
	}
}
GS.debug_levels = {}
GS.level_areas = {
	{
		1,
		4
	},
	{
		5,
		6
	},
	{
		7,
		11
	},
	{
		12,
		16
	},
	{
		17,
		19
	},
	{
		20,
		22
	},
	{
		23,
		27
	},
	{
		28,
		30
	},
	{
		31,
		35
	}
}
GS.campaign_only_levels = {
	16
}
GS.max_stars = GS.last_level * 3
GS.stars_per_mode = 0
GS.seasons = {
	"halloween",
	"christmas"
}
GS.default_hero = "hero_elves_archer"
GS.default_team = {
	"hero_vesper",
	"hero_raelyn"
}
GS.hero_xp_thresholds = {
	1300,
	5300,
	11300,
	19300,
	31800,
	46800,
	64300,
	88300,
	115300
}
GS.hero_level_expected = {
	1,
	2,
	3,
	3,
	4,
	4,
	5,
	5,
	6,
	7,
	8,
	9,
	9,
	10,
	10,
	10,
	9,
	9,
	10,
	9,
	9,
	10,
	9,
	9,
	10,
	10,
	10,
	9,
	9,
	10,
	9,
	9,
	10,
	10,
	10
}
GS.hero_level_expected[81] = 1
GS.hero_level_expected[82] = 1
GS.hero_level_expected_multipliers_below = {
	1,
	2
}
GS.hero_level_expected_multipliers_above = {
	0.5,
	0.25
}
GS.hero_xp_gain_per_difficulty_mode = {
	[DIFFICULTY_EASY] = 3,
	[DIFFICULTY_NORMAL] = 2,
	[DIFFICULTY_HARD] = 1.5,
	[DIFFICULTY_IMPOSSIBLE] = 1
}
GS.skill_points_for_hero_level = {
	0,
	4,
	8,
	12,
	16,
	20,
	24,
	28,
	32,
	36
}
GS.default_hero_ultimate_level = 1
GS.max_hero_ultimate_level = 4
GS.default_towers = {
	"royal_archers",
	"paladin_covenant",
	"arcane_wizard"
}
GS.default_items = {
	"cluster_bomb",
	"deaths_touch",
	"winter_age"
}
GS.relic_lvl_steps = {
	1,
	1,
	2,
	2,
	2,
	3,
	3,
	3,
	3,
	4
}
GS.relic_order = {
	"relic_none",
	"relic_banner_of_command",
	"relic_locket_of_the_unforgiven",
	"relic_guardian_orb",
	"relic_hammer_of_the_blessed"
}
GS.endless_gems_for_wave = 1
GS.gems_factor_per_mode = {
	1,
	1.2,
	1.2
}
GS.gems_per_level = {
	40,
	70,
	80,
	100,
	120,
	180,
	120,
	120,
	130,
	150,
	230,
	160,
	160,
	180,
	300,
	250,
	150,
	150,
	200,
	150,
	150,
	200,
	100,
	150,
	100,
	150,
	200,
	150,
	150,
	200,
	150,
	200,
	150,
	200,
	300
}
GS.encyclopedia_tower_fmt = "encyclopedia_towers_00%02i"
GS.encyclopedia_tower_thumb_fmt = "encyclopedia_tower_thumbs_00%02i"
GS.encyclopedia_enemy_fmt = "encyclopedia_creeps_00%02i"
GS.encyclopedia_enemy_thumb_fmt = "encyclopedia_creep_thumbs_00%02i"
GS.encyclopedia_enemies = {
	{
		always_shown = true,
		name = "enemy_hog_invader"
	},
	{
		always_shown = false,
		name = "enemy_tusked_brawler"
	},
	{
		always_shown = false,
		name = "enemy_cutthroat_rat"
	},
	{
		always_shown = false,
		name = "enemy_bear_vanguard"
	},
	{
		always_shown = false,
		name = "enemy_turtle_shaman"
	},
	{
		always_shown = false,
		name = "enemy_surveyor_harpy"
	},
	{
		always_shown = false,
		name = "enemy_dreadeye_viper"
	},
	{
		always_shown = false,
		name = "enemy_hyena5"
	},
	{
		always_shown = false,
		name = "enemy_skunk_bombardier"
	},
	{
		always_shown = false,
		name = "enemy_bear_woodcutter"
	},
	{
		always_shown = false,
		name = "enemy_rhino"
	},
	{
		always_shown = false,
		name = "boss_pig"
	},
	{
		always_shown = false,
		name = "enemy_acolyte"
	},
	{
		always_shown = false,
		name = "enemy_acolyte_tentacle"
	},
	{
		always_shown = false,
		name = "enemy_small_stalker"
	},
	{
		always_shown = false,
		name = "enemy_lesser_sister"
	},
	{
		always_shown = false,
		name = "enemy_lesser_sister_nightmare"
	},
	{
		always_shown = false,
		name = "enemy_spiderling"
	},
	{
		always_shown = false,
		name = "enemy_unblinded_priest"
	},
	{
		always_shown = false,
		name = "enemy_unblinded_abomination"
	},
	{
		always_shown = false,
		name = "enemy_unblinded_abomination_stage_8"
	},
	{
		always_shown = false,
		name = "enemy_armored_nightmare"
	},
	{
		always_shown = false,
		name = "enemy_unblinded_shackler"
	},
	{
		always_shown = false,
		name = "enemy_corrupted_stalker"
	},
	{
		always_shown = false,
		name = "enemy_stage_11_cult_leader_illusion"
	},
	{
		always_shown = false,
		name = "enemy_blinker"
	},
	{
		always_shown = false,
		name = "enemy_crystal_golem"
	},
	{
		always_shown = false,
		name = "enemy_glareling"
	},
	{
		always_shown = false,
		name = "boss_corrupted_denas"
	},
	{
		always_shown = false,
		name = "enemy_mindless_husk"
	},
	{
		always_shown = false,
		name = "enemy_vile_spawner"
	},
	{
		always_shown = false,
		name = "enemy_lesser_eye"
	},
	{
		always_shown = false,
		name = "enemy_noxious_horror"
	},
	{
		always_shown = false,
		name = "enemy_hardened_horror"
	},
	{
		always_shown = false,
		name = "enemy_amalgam"
	},
	{
		always_shown = false,
		name = "enemy_evolving_scourge"
	},
	{
		always_shown = false,
		name = "boss_cult_leader"
	},
	{
		always_shown = false,
		name = "controller_stage_16_overseer"
	},
	{
		always_shown = false,
		name = "enemy_corrupted_elf"
	},
	{
		always_shown = false,
		name = "enemy_specter"
	},
	{
		always_shown = false,
		name = "enemy_bane_wolf"
	},
	{
		always_shown = false,
		name = "enemy_dust_cryptid"
	},
	{
		always_shown = false,
		name = "enemy_deathwood"
	},
	{
		always_shown = false,
		name = "enemy_revenant_soulcaller"
	},
	{
		always_shown = false,
		name = "enemy_animated_armor"
	},
	{
		always_shown = false,
		name = "enemy_revenant_harvester"
	},
	{
		always_shown = false,
		name = "boss_navira"
	},
	{
		always_shown = false,
		name = "enemy_crocs_basic"
	},
	{
		always_shown = false,
		name = "enemy_crocs_basic_egg"
	},
	{
		always_shown = false,
		name = "enemy_crocs_ranged"
	},
	{
		always_shown = false,
		name = "enemy_crocs_flier"
	},
	{
		always_shown = false,
		name = "enemy_killertile"
	},
	{
		always_shown = false,
		name = "enemy_quickfeet_gator"
	},
	{
		always_shown = false,
		name = "enemy_crocs_egg_spawner"
	},
	{
		always_shown = false,
		name = "enemy_crocs_shaman"
	},
	{
		always_shown = false,
		name = "enemy_crocs_hydra"
	},
	{
		always_shown = false,
		name = "enemy_crocs_tank"
	},
	{
		always_shown = false,
		name = "boss_crocs_lvl1"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_hammerer"
	},
	{
		always_shown = false,
		name = "enemy_scrap_speedster"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_shielder"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_guardian"
	},
	{
		always_shown = false,
		name = "enemy_surveillance_sentry"
	},
	{
		always_shown = false,
		name = "enemy_rolling_sentry"
	},
	{
		always_shown = false,
		name = "enemy_brute_welder"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_fist"
	},
	{
		always_shown = false,
		name = "enemy_machinist"
	},
	{
		always_shown = false,
		name = "enemy_mad_tinkerer"
	},
	{
		always_shown = false,
		name = "enemy_scrap_drone"
	},
	{
		always_shown = false,
		name = "boss_machinist"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_anvil"
	},
	{
		always_shown = false,
		name = "enemy_common_clone"
	},
	{
		always_shown = false,
		name = "enemy_darksteel_hulk"
	},
	{
		always_shown = false,
		name = "enemy_deformed_grymbeard_clone"
	},
	{
		always_shown = false,
		name = "boss_grymbeard"
	},
	{
		always_shown = false,
		name = "enemy_ballooning_spider"
	},
	{
		always_shown = false,
		name = "enemy_glarenwarden"
	},
	{
		always_shown = false,
		name = "enemy_spider_sister"
	},
	{
		always_shown = false,
		name = "enemy_spider_priest"
	},
	{
		always_shown = false,
		name = "enemy_drainbrood"
	},
	{
		always_shown = false,
		name = "enemy_cultbrood"
	},
	{
		always_shown = false,
		name = "enemy_spidead"
	},
	{
		always_shown = false,
		name = "boss_spider_queen"
	},
	{
		always_shown = false,
		name = "enemy_flame_guard"
	},
	{
		always_shown = false,
		name = "enemy_blaze_raider"
	},
	{
		always_shown = false,
		name = "enemy_fire_fox"
	},
	{
		always_shown = false,
		name = "enemy_fire_phoenix"
	},
	{
		always_shown = false,
		name = "enemy_nine_tailed_fox"
	},
	{
		always_shown = false,
		name = "enemy_wuxian"
	},
	{
		always_shown = false,
		name = "enemy_burning_treant"
	},
	{
		always_shown = false,
		name = "enemy_ash_spirit"
	},
	{
		always_shown = false,
		name = "boss_redboy_teen"
	},
	{
		always_shown = false,
		name = "enemy_citizen_1"
	},
	{
		always_shown = false,
		name = "enemy_citizen_2"
	},
	{
		always_shown = false,
		name = "enemy_citizen_3"
	},
	{
		always_shown = false,
		name = "enemy_citizen_4"
	},
	{
		always_shown = false,
		name = "enemy_gale_warrior"
	},
	{
		always_shown = false,
		name = "enemy_water_spirit"
	},
	{
		always_shown = false,
		name = "enemy_storm_spirit"
	},
	{
		always_shown = false,
		name = "enemy_storm_elemental"
	},
	{
		always_shown = false,
		name = "enemy_qiongqi"
	},
	{
		always_shown = false,
		name = "enemy_water_sorceress"
	},
	{
		always_shown = false,
		name = "enemy_palace_guard"
	},
	{
		always_shown = false,
		name = "enemy_fan_guard"
	},
	{
		always_shown = false,
		name = "boss_princess_iron_fan"
	},
	{
		always_shown = false,
		name = "enemy_doom_bringer"
	},
	{
		always_shown = false,
		name = "enemy_demon_minotaur"
	},
	{
		always_shown = false,
		name = "enemy_golden_eyed"
	},
	{
		always_shown = false,
		name = "enemy_hellfire_warlock"
	},
	{
		always_shown = false,
		name = "boss_bull_king"
	},
	{
		always_shown = false,
		name = "enemy_tower_ray_sheep"
	},
	{
		always_shown = false,
		name = "enemy_pumpkin_witch_flying"
	}
}

for i = #GS.encyclopedia_enemies, 1, -1 do
	if GS.encyclopedia_enemies[i].target and GS.encyclopedia_enemies[i].target ~= KR_TARGET then
		table.remove(GS.encyclopedia_enemies, i)
	end
end

GS.items_required_exoskeletons = {}
GS.items_required_exoskeletons.portable_coil = {
	"item_portable_coilDef",
	"item_portable_coil_hitDef"
}
GS.items_required_exoskeletons.veznan_wrath = {
	"veznan_wrath_exoskeleton"
}
GS.tower_order = {
	{
		always_shown = true,
		name = "tower_royal_archers"
	},
	{
		always_shown = false,
		name = "tower_paladin_covenant"
	},
	{
		always_shown = false,
		name = "tower_arcane_wizard"
	},
	{
		always_shown = false,
		name = "tower_tricannon"
	},
	{
		always_shown = false,
		name = "tower_ballista"
	},
	{
		always_shown = false,
		name = "tower_arborean_emissary"
	},
	{
		always_shown = false,
		name = "tower_demon_pit"
	},
	{
		always_shown = false,
		name = "tower_flamespitter"
	},
	{
		always_shown = false,
		name = "tower_rocket_gunners"
	},
	{
		always_shown = false,
		name = "tower_ray"
	},
	{
		always_shown = false,
		name = "tower_barrel"
	},
	{
		always_shown = false,
		name = "tower_sand"
	},
	{
		always_shown = false,
		name = "tower_dark_elf"
	},
	{
		always_shown = false,
		name = "tower_dwarf"
	},
	{
		always_shown = false,
		name = "tower_elven_stargazers"
	},
	{
		always_shown = false,
		name = "tower_hermit_toad"
	},
	{
		always_shown = false,
		name = "tower_sparking_geode"
	},
	{
		always_shown = false,
		name = "tower_necromancer"
	},
	{
		always_shown = false,
		name = "tower_ghost"
	},
	{
		always_shown = false,
		name = "tower_pandas"
	}
}

if version and version.bundle_id and (version.bundle_id == "com.east2west.kingdomrush5" or version.bundle_id == "com.ironhidegames.android.kingdomrush.alliance.e2w") then
	local features = require("features")

	if features.only_dlc_1 then
		GS.dlc_names = {
			{
				id = "dlc_1",
				name = "colossal_dwarfare"
			},
			{
				id = "dlc_2",
				name = "wukong",
				hidden = true
			}
		}
		GS.last_level = 30
		GS.max_stars = GS.last_level * 3
	end

	if features.custom_health_bar_colors then
		GS.health_bar_colors = features.custom_health_bar_colors
	end
end

return GS
