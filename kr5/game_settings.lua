local GS = {}

-- customization
GS.extra_levels = {
	[115] = {},
	[122] = {},
	[123] = {},
	[124] = {},
	[125] = {},
	[126] = {},
	[417] = {},
	[426] = {},
	[427] = {},
}
-- customization
GS.gameplay_tips_count = 2
GS.early_wave_reward_per_second = 1
GS.early_wave_reward_per_second_default = 1
GS.claimable_achievements = true
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
	default = 6,
	arachnophobia = 11
}
GS.dlcs_unlock_level = 1
GS.last_level = 30
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
	}
}
GS.level_range_names = {
	"base",
	"undying_fury",
	"ancient_hunger",
	"colossal_dwarfare",
	"arachnophobia"
}
GS.dlc_names = {
	{
		id = "dlc_1",
		name = "colossal_dwarfare"
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
	200
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
		always_shown = true,
		name = "enemy_tusked_brawler"
	},
	{
		always_shown = true,
		name = "enemy_turtle_shaman"
	},
	{
		always_shown = true,
		name = "enemy_bear_vanguard"
	},
	{
		always_shown = true,
		name = "enemy_cutthroat_rat"
	},
	{
		always_shown = true,
		name = "enemy_dreadeye_viper"
	},
	{
		always_shown = true,
		name = "enemy_surveyor_harpy"
	},
	{
		always_shown = true,
		name = "enemy_skunk_bombardier"
	},
	{
		always_shown = true,
		name = "enemy_hyena5"
	},
	{
		always_shown = true,
		name = "enemy_rhino"
	},
	{
		always_shown = false,
		name = "enemy_acolyte"
	},
	{
		always_shown = false,
		name = "enemy_lesser_sister"
	},
	{
		always_shown = false,
		name = "enemy_corrupted_stalker"
	},
	{
		always_shown = false,
		name = "enemy_crystal_golem"
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

return GS
