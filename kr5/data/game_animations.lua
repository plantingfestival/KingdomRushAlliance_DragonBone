-- chunkname: @./kr5/data/game_animations.lua

local a = {
	tower_build_dust = {
		prefix = "effect_buildSmoke",
		to = 12,
		from = 1
	},
	tower_sell_dust = {
		prefix = "effect_sellSmoke",
		to = 12,
		from = 1
	},
	blood_pool_red = {
		prefix = "decal_blood",
		to = 1,
		from = 1
	},
	blood_pool_green = {
		prefix = "decal_blood",
		to = 2,
		from = 2
	},
	blood_pool_violet = {
		prefix = "decal_blood",
		to = 3,
		from = 3
	},
	blood_pool_gray = {
		prefix = "decal_blood",
		to = 4,
		from = 4
	},
	blood_pool_orange = {
		prefix = "decal_blood",
		to = 5,
		from = 5
	},
	bleeding_small_red = {
		prefix = "bleeding_small_red",
		to = 12,
		from = 1
	},
	bleeding_small_gray = {
		prefix = "bleeding_small_gray",
		to = 12,
		from = 1
	},
	bleeding_small_green = {
		prefix = "bleeding_small_green",
		to = 12,
		from = 1
	},
	bleeding_small_violet = {
		prefix = "bleeding_small_violet",
		to = 12,
		from = 1
	},
	bleeding_small_orange = {
		prefix = "bleeding_small_orange",
		to = 12,
		from = 1
	},
	bleeding_big_red = {
		prefix = "bleeding_big_red",
		to = 12,
		from = 1
	},
	bleeding_big_gray = {
		prefix = "bleeding_big_gray",
		to = 12,
		from = 1
	},
	bleeding_big_green = {
		prefix = "bleeding_big_green",
		to = 12,
		from = 1
	},
	bleeding_big_violet = {
		prefix = "bleeding_big_violet",
		to = 12,
		from = 1
	},
	bleeding_big_orange = {
		prefix = "bleeding_big_orange",
		to = 12,
		from = 1
	},
	explode_small = {
		prefix = "states_small",
		to = 32,
		from = 22
	},
	explode_big = {
		prefix = "states_big",
		to = 32,
		from = 22
	},
	fx_teleport_blue = {
		prefix = "mage_teleport_lightBlue_big",
		to = 10,
		from = 1
	},
	fx_teleport_orange = {
		prefix = "mage_teleport_orange_big",
		to = 10,
		from = 1
	},
	fx_teleport_violet = {
		prefix = "mage_teleport_violet_big",
		to = 10,
		from = 1
	},
	fx_rock_explosion = {
		prefix = "artillery_thrower_explosion",
		to = 19,
		from = 1
	},
	fx_rock_druid_launch = {
		prefix = "artillery_henge_stoneLaunch",
		to = 10,
		from = 1
	},
	fx_arrow_arcane_hit = {
		prefix = "archer_arcane_proy",
		to = 9,
		from = 2
	},
	arcane_burst_explosion = {
		prefix = "archer_arcane_special_explosion",
		to = 14,
		from = 1
	},
	arcane_slumber_explosion = {
		prefix = "archer_arcane_sleep_explosion",
		to = 14,
		from = 1
	},
	arcane_slumber_bubbles_loop = {
		prefix = "archer_arcane_sleep_bubbles",
		to = 21,
		from = 1
	},
	arcane_slumber_z_loop = {
		prefix = "archer_arcane_sleep_z",
		to = 50,
		from = 1
	},
	fx_arrow_silver_mark_hit = {
		prefix = "archer_silver_mark_explotion",
		to = 9,
		from = 1
	},
	arrow_silver_mark_particle_1 = {
		prefix = "archer_silver_mark_particle1",
		to = 10,
		from = 1
	},
	arrow_silver_mark_particle_2 = {
		prefix = "archer_silver_mark_particle2",
		to = 10,
		from = 1
	},
	fx_arrow_silver_sentence_hit = {
		prefix = "archer_silver_instaKillFx",
		to = 10,
		from = 1
	},
	fx_arrow_silver_sentence_shot = {
		prefix = "archer_silver_instaKill_over",
		to = 10,
		from = 1
	},
	coin_jump = {
		prefix = "nextwave_coin",
		to = 14,
		from = 1
	},
	fx_coin_jump = {
		prefix = "fx_coin_jump",
		to = 14,
		from = 1
	},
	fire_medium = {
		prefix = "fire_big",
		to = 10,
		from = 1
	},
	fire_small = {
		prefix = "fire_small",
		to = 10,
		from = 1
	},
	fire_large = {
		prefix = "fire_boss_type1",
		to = 10,
		from = 1
	},
	stun_big_loop = {
		prefix = "stun_big",
		to = 26,
		from = 1
	},
	stun_small_loop = {
		prefix = "stun_small",
		to = 26,
		from = 1
	},
	fx_power_thunder_rain_splash = {
		prefix = "lightning_storm_rain_splash",
		to = 10,
		from = 1
	},
	fx_power_thunder_explosion_half = {
		prefix = "ray_explosion_half",
		to = 16,
		from = 1
	},
	decal_power_thunder_explosion = {
		prefix = "ray_explosion_decal",
		to = 20,
		from = 1
	},
	decal_user_power_teleport = {
		prefix = "teleport_decal",
		to = 14,
		from = 1
	},
	fx_user_power_teleport_bubbles = {
		prefix = "teleport_bubble",
		to = 24,
		from = 1
	},
	fx_user_power_teleport = {
		prefix = "teleport_fx_medium",
		to = 10,
		from = 1
	},
	fx_wrath_of_elynia_creep_explosion = {
		prefix = "elynia_creepExplosion",
		to = 25,
		from = 1
	},
	fx_wrath_of_elynia_creep_explosion_ashes = {
		prefix = "elynia_creepExplosion_ashes",
		to = 25,
		from = 1
	},
	decal_elynia_ray_hit = {
		prefix = "elynia_rayDecal",
		to = 6,
		from = 1
	},
	fx_elynia_particle = {
		prefix = "elynia_particles",
		to = 12,
		from = 1
	},
	decal_horn_heroism_guy_layerX = {
		layer_to = 2,
		from = 1,
		layer_prefix = "hornOfHeroism_guy_layer%i",
		to = 41,
		layer_from = 1
	},
	mod_horn_heroism_soldier = {
		prefix = "hornOfHeroism_soldierBuff",
		to = 9,
		from = 1
	},
	mod_horn_heroism_tower_left = {
		prefix = "hornOfHeroism_towerBuff_bottomFx",
		to = 9,
		from = 1
	},
	mod_horn_heroism_tower_flame = {
		prefix = "hornOfHeroism_towerBuff_fire",
		to = 10,
		from = 1
	},
	bullet_rod_dragon_fire_idle = {
		prefix = "rodOfDragonfire_proy",
		to = 10,
		from = 1
	},
	bullet_rod_dragon_fire_explosion = {
		prefix = "rodOfDragonfire_explosion",
		to = 14,
		from = 1
	},
	ps_rod_dragon_fire_particle = {
		prefix = "rodOfDragonfire_proyParticle",
		to = 10,
		from = 1
	},
	rod_dragon_fire_start = {
		prefix = "rodOfDragonfire_totem",
		to = 12,
		from = 1
	},
	rod_dragon_fire_end = {
		prefix = "rodOfDragonfire_totem",
		to = 41,
		from = 13
	},
	rod_dragon_fire_flame = {
		prefix = "rodOfDragonfire_totem_fire",
		to = 10,
		from = 1
	},
	tower_archer_shooter_idleDown = {
		prefix = "archer_shooter",
		to = 10,
		from = 10
	},
	tower_archer_shooter_idleUp = {
		prefix = "archer_shooter",
		to = 20,
		from = 20
	},
	tower_archer_shooter_shootingDown = {
		prefix = "archer_shooter",
		to = 9,
		from = 1
	},
	tower_archer_shooter_shootingUp = {
		prefix = "archer_shooter",
		to = 19,
		from = 11
	},
	tower_arcane_shooter_idleDown = {
		prefix = "archer_arcane_shooter",
		to = 9,
		from = 9
	},
	tower_arcane_shooter_shootDown = {
		prefix = "archer_arcane_shooter",
		to = 9,
		from = 1
	},
	tower_arcane_shooter_idleUp = {
		prefix = "archer_arcane_shooter",
		to = 18,
		from = 18
	},
	tower_arcane_shooter_shootUp = {
		prefix = "archer_arcane_shooter",
		to = 18,
		from = 10
	},
	tower_arcane_shooter_specialDown = {
		prefix = "archer_arcane_shooter",
		to = 41,
		from = 19
	},
	tower_arcane_shooter_specialUp = {
		prefix = "archer_arcane_shooter",
		to = 64,
		from = 42
	},
	tower_arcane_bubbles = {
		prefix = "archer_arcane_decos",
		to = 21,
		from = 1
	},
	tower_silver_shooter_idleDown = {
		prefix = "archer_silver_shooter",
		to = 12,
		from = 1
	},
	tower_silver_shooter_idleUp = {
		prefix = "archer_silver_shooter",
		to = 24,
		from = 13
	},
	tower_silver_shooter_shootDown = {
		prefix = "archer_silver_shooter",
		to = 58,
		from = 41
	},
	tower_silver_shooter_shootUp = {
		prefix = "archer_silver_shooter",
		to = 76,
		from = 59
	},
	tower_silver_shooter_shootShortDown = {
		prefix = "archer_silver_shooter",
		to = 32,
		from = 25
	},
	tower_silver_shooter_shootShortUp = {
		prefix = "archer_silver_shooter",
		to = 40,
		from = 33
	},
	tower_silver_shooter_shootSpecialDown = {
		prefix = "archer_silver_shooter",
		to = 100,
		from = 77
	},
	tower_silver_shooter_shootSpecialUp = {
		prefix = "archer_silver_shooter",
		to = 124,
		from = 101
	},
	tower_silver_shooter_shootSpecialShortDown = {
		prefix = "archer_silver_shooter",
		to = 148,
		from = 125
	},
	tower_silver_shooter_shootSpecialShortUp = {
		prefix = "archer_silver_shooter",
		to = 172,
		from = 149
	},
	tower_silver_shooter_instakillDown = {
		prefix = "archer_silver_shooter",
		to = 196,
		from = 173
	},
	tower_silver_shooter_instakillUp = {
		prefix = "archer_silver_shooter",
		to = 220,
		from = 197
	},
	tower_mage_1_platform_shoot = {
		prefix = "mage_towers_layer2",
		to = 31,
		from = 1
	},
	tower_mage_1_platform_idle = {
		prefix = "mage_towers_layer2",
		to = 32,
		from = 32
	},
	tower_mage_2_platform_shoot = {
		prefix = "mage_towers_layer2",
		to = 63,
		from = 33
	},
	tower_mage_2_platform_idle = {
		prefix = "mage_towers_layer2",
		to = 64,
		from = 64
	},
	tower_mage_3_platform_shoot = {
		prefix = "mage_towers_layer2",
		to = 95,
		from = 65
	},
	tower_mage_3_platform_idle = {
		prefix = "mage_towers_layer2",
		to = 96,
		from = 96
	},
	tower_mage_shooter_shootingDown = {
		prefix = "mage_tower_shooter",
		to = 31,
		from = 1
	},
	tower_mage_shooter_idleDown = {
		prefix = "mage_tower_shooter",
		to = 32,
		from = 32
	},
	tower_mage_shooter_shootingUp = {
		prefix = "mage_tower_shooter",
		to = 63,
		from = 33
	},
	tower_mage_shooter_idleUp = {
		prefix = "mage_tower_shooter",
		to = 64,
		from = 64
	},
	bolt_elves_travel = {
		prefix = "mage_proy",
		to = 15,
		from = 1
	},
	bolt_elves_hit = {
		prefix = "mage_proy",
		to = 25,
		from = 16
	},
	tower_wild_magus_shooter_idleDown = {
		prefix = "mage_wild_shooter",
		to = 1,
		from = 1
	},
	tower_wild_magus_shooter_idleUp = {
		prefix = "mage_wild_shooter",
		to = 2,
		from = 2
	},
	tower_wild_magus_shooter_rh_shootDown = {
		prefix = "mage_wild_shooter",
		to = 10,
		from = 3
	},
	tower_wild_magus_shooter_lh_shootDown = {
		prefix = "mage_wild_shooter",
		to = 18,
		from = 11
	},
	tower_wild_magus_shooter_rh_shootUp = {
		prefix = "mage_wild_shooter",
		to = 26,
		from = 19
	},
	tower_wild_magus_shooter_lh_shootUp = {
		prefix = "mage_wild_shooter",
		to = 34,
		from = 27
	},
	tower_wild_magus_shooter_rayDown = {
		prefix = "mage_wild_shooter",
		to = 68,
		from = 35
	},
	tower_wild_magus_shooter_rayUp = {
		prefix = "mage_wild_shooter",
		to = 102,
		from = 69
	},
	tower_wild_magus_shooter_wardDown = {
		prefix = "mage_wild_shooter",
		to = 134,
		from = 103
	},
	tower_wild_magus_shooter_wardUp = {
		prefix = "mage_wild_shooter",
		to = 166,
		from = 135
	},
	tower_wild_magus_ward_rune = {
		prefix = "mage_wild_shooter",
		to = 193,
		from = 169
	},
	bolt_wild_magus_flying = {
		prefix = "mage_wild_proy",
		to = 8,
		from = 1
	},
	bolt_wild_magus_hit = {
		prefix = "mage_wild_proy",
		to = 32,
		from = 9
	},
	ray_wild_magus = {
		prefix = "mage_wild_ray",
		to = 16,
		from = 1
	},
	fx_ray_wild_magus_hit = {
		prefix = "mage_wild_ray_head",
		to = 14,
		from = 1
	},
	mod_eldritch = {
		prefix = "mage_wild_creepFx",
		to = 12,
		from = 1
	},
	fx_eldritch_explosion = {
		prefix = "mage_wild_explosion",
		to = 19,
		from = 1
	},
	mod_ward_decal = {
		prefix = "mage_wild_silence_decal",
		to = 15,
		from = 1
	},
	tower_high_elven_shooter_idleDown = {
		prefix = "mage_highElven_shooter",
		to = 1,
		from = 1
	},
	tower_high_elven_shooter_idleUp = {
		prefix = "mage_highElven_shooter",
		to = 2,
		from = 2
	},
	tower_high_elven_shooter_shootDown = {
		prefix = "mage_highElven_shooter",
		to = 40,
		from = 3
	},
	tower_high_elven_shooter_shootUp = {
		prefix = "mage_highElven_shooter",
		to = 78,
		from = 41
	},
	tower_high_elven_shooter_timeLapseDown = {
		prefix = "mage_highElven_shooter",
		to = 108,
		from = 79
	},
	tower_high_elven_shooter_timeLapseUp = {
		prefix = "mage_highElven_shooter",
		to = 138,
		from = 109
	},
	bolt_high_elven_weak_travel = {
		prefix = "mage_highElven_proy",
		to = 15,
		from = 1
	},
	bolt_high_elven_weak_hit = {
		prefix = "mage_highElven_proy",
		to = 25,
		from = 16
	},
	bolt_high_elven_strong_travel = {
		prefix = "mage_highElven_proyBig",
		to = 1,
		from = 1
	},
	bolt_high_elven_strong_hit = {
		prefix = "mage_highElven_proyBig",
		to = 17,
		from = 2
	},
	mod_timelapse_start = {
		prefix = "mage_highElven_energyBall",
		to = 28,
		from = 1
	},
	mod_timelapse_loop = {
		prefix = "mage_highElven_energyBall",
		to = 44,
		from = 29
	},
	mod_timelapse_end = {
		prefix = "mage_highElven_energyBall",
		to = 52,
		from = 45
	},
	high_elven_sentinel_small = {
		prefix = "mage_highElven_balls",
		to = 1,
		from = 1
	},
	high_elven_sentinel_big = {
		prefix = "mage_highElven_balls",
		to = 19,
		from = 2
	},
	high_elven_sentinel_shoot = {
		prefix = "mage_highElven_balls",
		to = 34,
		from = 21
	},
	high_elven_sentinel_particle = {
		prefix = "mage_highElven_balls",
		to = 20,
		from = 20
	},
	ray_high_elven_sentinel = {
		prefix = "mage_highElven_balls_ray",
		to = 4,
		from = 1
	},
	fx_ray_high_elven_sentinel_hit = {
		prefix = "mage_highElven_balls_hitFx_big",
		to = 10,
		from = 1
	},
	tower_rock_thrower_shooter_l1_idleDown = {
		prefix = "artillery_thrower",
		to = 1,
		from = 1
	},
	tower_rock_thrower_shooter_l1_loadDown = {
		prefix = "artillery_thrower",
		to = 49,
		from = 2
	},
	tower_rock_thrower_shooter_l1_shootDown = {
		prefix = "artillery_thrower",
		to = 73,
		from = 50
	},
	tower_rock_thrower_shooter_l1_idleUp = {
		prefix = "artillery_thrower",
		to = 74,
		from = 74
	},
	tower_rock_thrower_shooter_l1_loadUp = {
		prefix = "artillery_thrower",
		to = 122,
		from = 75
	},
	tower_rock_thrower_shooter_l1_shootUp = {
		prefix = "artillery_thrower",
		to = 145,
		from = 123
	},
	tower_rock_thrower_shooter_l2_idleDown = {
		prefix = "artillery_thrower_lvl2",
		to = 1,
		from = 1
	},
	tower_rock_thrower_shooter_l2_loadDown = {
		prefix = "artillery_thrower_lvl2",
		to = 49,
		from = 2
	},
	tower_rock_thrower_shooter_l2_shootDown = {
		prefix = "artillery_thrower_lvl2",
		to = 73,
		from = 50
	},
	tower_rock_thrower_shooter_l2_idleUp = {
		prefix = "artillery_thrower_lvl2",
		to = 74,
		from = 74
	},
	tower_rock_thrower_shooter_l2_loadUp = {
		prefix = "artillery_thrower_lvl2",
		to = 122,
		from = 75
	},
	tower_rock_thrower_shooter_l2_shootUp = {
		prefix = "artillery_thrower_lvl2",
		to = 145,
		from = 123
	},
	tower_rock_thrower_shooter_l3_idleDown = {
		prefix = "artillery_thrower_lvl3",
		to = 1,
		from = 1
	},
	tower_rock_thrower_shooter_l3_loadDown = {
		prefix = "artillery_thrower_lvl3",
		to = 49,
		from = 2
	},
	tower_rock_thrower_shooter_l3_shootDown = {
		prefix = "artillery_thrower_lvl3",
		to = 73,
		from = 50
	},
	tower_rock_thrower_shooter_l3_idleUp = {
		prefix = "artillery_thrower_lvl3",
		to = 74,
		from = 74
	},
	tower_rock_thrower_shooter_l3_loadUp = {
		prefix = "artillery_thrower_lvl3",
		to = 122,
		from = 75
	},
	tower_rock_thrower_shooter_l3_shootUp = {
		prefix = "artillery_thrower_lvl3",
		to = 145,
		from = 123
	},
	tower_rock_thrower_loading_stones_play = {
		prefix = "artillery_thrower_stones",
		to = 26,
		from = 1
	},
	tower_druid_shooter_idleDown = {
		prefix = "artillery_henge_druid1",
		to = 1,
		from = 1
	},
	tower_druid_shooter_castDown = {
		prefix = "artillery_henge_druid1",
		to = 29,
		from = 2
	},
	tower_druid_shooter_shootDown = {
		prefix = "artillery_henge_druid1",
		to = 51,
		from = 30
	},
	tower_druid_shooter_idleUp = {
		prefix = "artillery_henge_druid1",
		to = 52,
		from = 52
	},
	tower_druid_shooter_castUp = {
		prefix = "artillery_henge_druid1",
		to = 80,
		from = 53
	},
	tower_druid_shooter_shootUp = {
		prefix = "artillery_henge_druid1",
		to = 102,
		from = 81
	},
	tower_druid_shooter_nature_cast = {
		prefix = "artillery_henge_druid3",
		to = 57,
		from = 1
	},
	tower_druid_shooter_nature_idle = {
		prefix = "artillery_henge_druid3",
		to = 57,
		from = 57
	},
	tower_druid_shooter_sylvan_cast = {
		prefix = "artillery_henge_druid2",
		to = 46,
		from = 1
	},
	tower_druid_shooter_sylvan_idle = {
		prefix = "artillery_henge_druid2",
		to = 46,
		from = 46
	},
	mod_druid_sylvan_small = {
		prefix = "artillery_henge_curse_small",
		to = 22,
		from = 1
	},
	mod_druid_sylvan_big = {
		prefix = "artillery_henge_curse_big",
		to = 22,
		from = 1
	},
	mod_druid_sylvan_affected_small = {
		prefix = "artillery_henge_affected_small",
		to = 18,
		from = 1
	},
	mod_druid_sylvan_affected_big = {
		prefix = "artillery_henge_affected_big",
		to = 18,
		from = 1
	},
	ray_druid_sylvan = {
		prefix = "artillery_henge_curse_ray",
		to = 12,
		from = 1
	},
	druid_stone1_load = {
		prefix = "artillery_henge_chargeStone",
		to = 13,
		from = 1
	},
	druid_stone1_travel = {
		prefix = "artillery_henge_chargeStone",
		to = 13,
		from = 13
	},
	druid_stone2_load = {
		prefix = "artillery_henge_chargeStone",
		to = 26,
		from = 14
	},
	druid_stone2_travel = {
		prefix = "artillery_henge_chargeStone",
		to = 26,
		from = 26
	},
	druid_stone3_load = {
		prefix = "artillery_henge_chargeStone",
		to = 39,
		from = 27
	},
	druid_stone3_travel = {
		prefix = "artillery_henge_chargeStone",
		to = 39,
		from = 39
	},
	soldier_druid_bear_idle = {
		prefix = "artillery_henge_bear",
		to = 1,
		from = 1
	},
	soldier_druid_bear_walk = {
		prefix = "artillery_henge_bear",
		to = 13,
		from = 2
	},
	soldier_druid_bear_attack = {
		prefix = "artillery_henge_bear",
		to = 40,
		from = 18
	},
	soldier_druid_bear_idle2stance = {
		prefix = "artillery_henge_bear",
		to = 17,
		from = 14
	},
	soldier_druid_bear_stance2idle = {
		prefix = "artillery_henge_bear",
		to = 45,
		from = 41
	},
	soldier_druid_bear_spawn = {
		prefix = "artillery_henge_bear",
		to = 90,
		from = 46
	},
	soldier_druid_bear_death = {
		prefix = "artillery_henge_bear",
		to = 172,
		from = 121
	},
	fx_druid_bear_spawn_rune = {
		prefix = "artillery_henge_bear",
		to = 99,
		from = 91
	},
	fx_druid_bear_spawn_effect = {
		prefix = "artillery_henge_bear",
		to = 115,
		from = 100
	},
	fx_druid_bear_spawn_decal = {
		prefix = "artillery_henge_bear",
		to = 116,
		from = 116
	},
	fx_druid_bear_death_rune = {
		prefix = "artillery_henge_bear",
		to = 182,
		from = 173
	},
	fx_druid_bear_death_effect = {
		prefix = "artillery_henge_bear",
		to = 198,
		from = 183
	},
	decal_fiery_nut_scorched = {
		prefix = "artillery_tree_scorched",
		to = 20,
		from = 1
	},
	fx_fiery_nut_explosion = {
		prefix = "rodOfDragonfire_explosion",
		to = 14,
		from = 1
	},
	fx_clobber_smoke = {
		prefix = "EarthquakeTower_HitSmoke",
		to = 14,
		from = 1
	},
	fx_clobber_smoke_ring = {
		prefix = "artillery_tree_smoke",
		to = 10,
		from = 1
	},
	tower_entwood_blink = {
		prefix = "artillery_tree_blink",
		to = 8,
		from = 1
	},
	tower_entwood_layer1_idle = {
		prefix = "artillery_tree_layer1",
		to = 1,
		from = 1
	},
	tower_entwood_layer2_idle = {
		prefix = "artillery_tree_layer2",
		to = 1,
		from = 1
	},
	tower_entwood_layer3_idle = {
		prefix = "artillery_tree_layer3",
		to = 1,
		from = 1
	},
	tower_entwood_layer4_idle = {
		prefix = "artillery_tree_layer4",
		to = 1,
		from = 1
	},
	tower_entwood_layer5_idle = {
		prefix = "artillery_tree_layer5",
		to = 1,
		from = 1
	},
	tower_entwood_layer6_idle = {
		prefix = "artillery_tree_layer6",
		to = 1,
		from = 1
	},
	tower_entwood_layer7_idle = {
		prefix = "artillery_tree_layer7",
		to = 1,
		from = 1
	},
	tower_entwood_layer8_idle = {
		prefix = "artillery_tree_layer8",
		to = 1,
		from = 1
	},
	tower_entwood_layer9_idle = {
		prefix = "artillery_tree_layer9",
		to = 1,
		from = 1
	},
	tower_entwood_layer1_attack1 = {
		prefix = "artillery_tree_layer1",
		to = 58,
		from = 39
	},
	tower_entwood_layer2_attack1 = {
		prefix = "artillery_tree_layer2",
		to = 58,
		from = 39
	},
	tower_entwood_layer3_attack1 = {
		prefix = "artillery_tree_layer3",
		to = 58,
		from = 39
	},
	tower_entwood_layer4_attack1 = {
		prefix = "artillery_tree_layer4",
		to = 58,
		from = 39
	},
	tower_entwood_layer5_attack1 = {
		prefix = "artillery_tree_layer5",
		to = 58,
		from = 39
	},
	tower_entwood_layer6_attack1 = {
		prefix = "artillery_tree_layer6",
		to = 58,
		from = 39
	},
	tower_entwood_layer7_attack1 = {
		prefix = "artillery_tree_layer7",
		to = 58,
		from = 39
	},
	tower_entwood_layer8_attack1 = {
		prefix = "artillery_tree_layer8",
		to = 58,
		from = 39
	},
	tower_entwood_layer9_attack1 = {
		prefix = "artillery_tree_layer9",
		to = 58,
		from = 39
	},
	tower_entwood_layer1_special1 = {
		prefix = "artillery_tree_layer1",
		to = 115,
		from = 95
	},
	tower_entwood_layer2_special1 = {
		prefix = "artillery_tree_layer2",
		to = 115,
		from = 95
	},
	tower_entwood_layer3_special1 = {
		prefix = "artillery_tree_layer3",
		to = 115,
		from = 95
	},
	tower_entwood_layer4_special1 = {
		prefix = "artillery_tree_layer4",
		to = 115,
		from = 95
	},
	tower_entwood_layer5_special1 = {
		prefix = "artillery_tree_layer5",
		to = 115,
		from = 95
	},
	tower_entwood_layer6_special1 = {
		prefix = "artillery_tree_layer6",
		to = 115,
		from = 95
	},
	tower_entwood_layer7_special1 = {
		prefix = "artillery_tree_layer7",
		to = 115,
		from = 95
	},
	tower_entwood_layer8_special1 = {
		prefix = "artillery_tree_layer8",
		to = 115,
		from = 95
	},
	tower_entwood_layer9_special1 = {
		prefix = "artillery_tree_layer9",
		to = 115,
		from = 95
	},
	tower_entwood_layer1_special2 = {
		prefix = "artillery_tree_layer1",
		to = 153,
		from = 116
	},
	tower_entwood_layer2_special2 = {
		prefix = "artillery_tree_layer2",
		to = 153,
		from = 116
	},
	tower_entwood_layer3_special2 = {
		prefix = "artillery_tree_layer3",
		to = 153,
		from = 116
	},
	tower_entwood_layer4_special2 = {
		prefix = "artillery_tree_layer4",
		to = 153,
		from = 116
	},
	tower_entwood_layer5_special2 = {
		prefix = "artillery_tree_layer5",
		to = 153,
		from = 116
	},
	tower_entwood_layer6_special2 = {
		prefix = "artillery_tree_layer6",
		to = 153,
		from = 116
	},
	tower_entwood_layer7_special2 = {
		prefix = "artillery_tree_layer7",
		to = 153,
		from = 116
	},
	tower_entwood_layer8_special2 = {
		prefix = "artillery_tree_layer8",
		to = 153,
		from = 116
	},
	tower_entwood_layer9_special2 = {
		prefix = "artillery_tree_layer9",
		to = 153,
		from = 116
	},
	tower_entwood_layer1_attack1_charge = {
		prefix = "artillery_tree_layer1",
		to = 38,
		from = 2
	},
	tower_entwood_layer2_attack1_charge = {
		prefix = "artillery_tree_layer2",
		to = 38,
		from = 2
	},
	tower_entwood_layer3_attack1_charge = {
		prefix = "artillery_tree_layer3",
		to = 38,
		from = 2
	},
	tower_entwood_layer4_attack1_charge = {
		prefix = "artillery_tree_layer4",
		to = 38,
		from = 2
	},
	tower_entwood_layer5_attack1_charge = {
		prefix = "artillery_tree_layer5",
		to = 38,
		from = 2
	},
	tower_entwood_layer6_attack1_charge = {
		prefix = "artillery_tree_layer6",
		to = 38,
		from = 2
	},
	tower_entwood_layer7_attack1_charge = {
		prefix = "artillery_tree_layer7",
		to = 38,
		from = 2
	},
	tower_entwood_layer8_attack1_charge = {
		prefix = "artillery_tree_layer8",
		to = 38,
		from = 2
	},
	tower_entwood_layer9_attack1_charge = {
		prefix = "artillery_tree_layer9",
		to = 38,
		from = 2
	},
	tower_entwood_layer1_special1_charge = {
		prefix = "artillery_tree_layer1",
		to = 94,
		from = 59
	},
	tower_entwood_layer2_special1_charge = {
		prefix = "artillery_tree_layer2",
		to = 94,
		from = 59
	},
	tower_entwood_layer3_special1_charge = {
		prefix = "artillery_tree_layer3",
		to = 94,
		from = 59
	},
	tower_entwood_layer4_special1_charge = {
		prefix = "artillery_tree_layer4",
		to = 94,
		from = 59
	},
	tower_entwood_layer5_special1_charge = {
		prefix = "artillery_tree_layer5",
		to = 94,
		from = 59
	},
	tower_entwood_layer6_special1_charge = {
		prefix = "artillery_tree_layer6",
		to = 94,
		from = 59
	},
	tower_entwood_layer7_special1_charge = {
		prefix = "artillery_tree_layer7",
		to = 94,
		from = 59
	},
	tower_entwood_layer8_special1_charge = {
		prefix = "artillery_tree_layer8",
		to = 94,
		from = 59
	},
	tower_entwood_layer9_special1_charge = {
		prefix = "artillery_tree_layer9",
		to = 94,
		from = 59
	},
	tower_barrack_1_door_open = {
		prefix = "barracks_towers_layer2",
		to = 5,
		from = 1
	},
	tower_barrack_1_door_close = {
		prefix = "barracks_towers_layer2",
		to = 25,
		from = 22
	},
	tower_barrack_2_door_open = {
		prefix = "barracks_towers_layer2",
		to = 30,
		from = 26
	},
	tower_barrack_2_door_close = {
		prefix = "barracks_towers_layer2",
		to = 50,
		from = 47
	},
	tower_barrack_3_door_open = {
		prefix = "barracks_towers_layer2",
		to = 55,
		from = 51
	},
	tower_barrack_3_door_close = {
		prefix = "barracks_towers_layer2",
		to = 75,
		from = 72
	},
	tower_blade_door_open = {
		prefix = "barracks_towers_layer2",
		to = 80,
		from = 76
	},
	tower_blade_door_close = {
		prefix = "barracks_towers_layer2",
		to = 100,
		from = 97
	},
	tower_forest_door_open = {
		prefix = "barracks_towers_layer2",
		to = 101,
		from = 101
	},
	tower_forest_door_close = {
		prefix = "barracks_towers_layer2",
		to = 101,
		from = 101
	},
	tower_ewok_door_open = {
		prefix = "ewok_hut",
		to = 6,
		from = 3
	},
	tower_ewok_door_close = {
		prefix = "ewok_hut",
		to = 27,
		from = 24
	},
	tower_faerie_dragon_egg_idle = {
		prefix = "fairy_dragon_egg",
		to = 1,
		from = 1
	},
	tower_faerie_dragon_egg_open = {
		prefix = "fairy_dragon_egg",
		to = 16,
		from = 1
	},
	tower_drow_door_open = {
		prefix = "mercenaryDraw_tower_layer2",
		to = 7,
		from = 1
	},
	tower_drow_door_close = {
		prefix = "mercenaryDraw_tower_layer2",
		to = 25,
		from = 21
	},
	soldier_barrack_1_idle = {
		prefix = "soldiers_123",
		to = 1,
		from = 1
	},
	soldier_barrack_1_attack = {
		prefix = "soldiers_123",
		to = 22,
		from = 7
	},
	soldier_barrack_1_running = {
		prefix = "soldiers_123",
		to = 6,
		from = 2
	},
	soldier_barrack_1_death = {
		prefix = "soldiers_123",
		to = 31,
		from = 23
	},
	soldier_barrack_1_ranged_attack = {
		prefix = "soldiers_123",
		to = 64,
		from = 50
	},
	soldier_barrack_2_idle = {
		prefix = "soldiers_123",
		to = 32,
		from = 32
	},
	soldier_barrack_2_attack = {
		prefix = "soldiers_123",
		to = 49,
		from = 38
	},
	soldier_barrack_2_running = {
		prefix = "soldiers_123",
		to = 37,
		from = 33
	},
	soldier_barrack_2_death = {
		prefix = "soldiers_123",
		to = 73,
		from = 65
	},
	soldier_barrack_2_ranged_attack = {
		prefix = "soldiers_123",
		to = 64,
		from = 50
	},
	soldier_barrack_3_idle = {
		prefix = "soldiers_123",
		to = 74,
		from = 74
	},
	soldier_barrack_3_attack = {
		prefix = "soldiers_123",
		to = 97,
		from = 80
	},
	soldier_barrack_3_running = {
		prefix = "soldiers_123",
		to = 79,
		from = 75
	},
	soldier_barrack_3_death = {
		prefix = "soldiers_123",
		to = 120,
		from = 113
	},
	soldier_barrack_3_ranged_attack = {
		prefix = "soldiers_123",
		to = 112,
		from = 98
	},
	fx_soldier_barrack_revive = {
		prefix = "hero_priest_revive",
		to = 17,
		from = 1
	},
	soldier_blade_idle = {
		prefix = "bladeSinger",
		to = 1,
		from = 1
	},
	soldier_blade_running = {
		prefix = "bladeSinger",
		to = 6,
		from = 2
	},
	soldier_blade_attack1 = {
		prefix = "bladeSinger",
		to = 23,
		from = 7
	},
	soldier_blade_attack2 = {
		prefix = "bladeSinger",
		to = 41,
		from = 24
	},
	soldier_blade_attack3 = {
		prefix = "bladeSinger",
		to = 62,
		from = 42
	},
	soldier_blade_dance_out = {
		prefix = "bladeSinger",
		to = 73,
		from = 63
	},
	soldier_blade_dance_hit1 = {
		prefix = "bladeSinger",
		to = 83,
		from = 74
	},
	soldier_blade_dance_hit2 = {
		prefix = "bladeSinger",
		to = 94,
		from = 84
	},
	soldier_blade_dance_hit3 = {
		prefix = "bladeSinger",
		to = 110,
		from = 95
	},
	soldier_blade_dance_in = {
		prefix = "bladeSinger",
		to = 118,
		from = 112
	},
	soldier_blade_death = {
		prefix = "bladeSinger",
		to = 125,
		from = 119
	},
	soldier_blade_perfect_parry = {
		prefix = "bladeSinger",
		to = 133,
		from = 126
	},
	soldier_forest_idle = {
		prefix = "forestKeeper",
		to = 1,
		from = 1
	},
	soldier_forest_running = {
		prefix = "forestKeeper",
		to = 8,
		from = 2
	},
	soldier_forest_attack = {
		prefix = "forestKeeper",
		to = 24,
		from = 9
	},
	soldier_forest_ranged_attack = {
		prefix = "forestKeeper",
		to = 42,
		from = 25
	},
	soldier_forest_death = {
		prefix = "forestKeeper",
		to = 62,
		from = 43
	},
	soldier_forest_circle = {
		prefix = "forestKeeper",
		to = 95,
		from = 63
	},
	soldier_forest_oak_attack = {
		prefix = "forestKeeper",
		to = 121,
		from = 96
	},
	soldier_forest_eerie = {
		prefix = "forestKeeper",
		to = 153,
		from = 122
	},
	decal_mod_forest_circle = {
		prefix = "forestKeeper_soldierBuff_decal",
		to = 8,
		from = 1
	},
	decal_eerie_roots_1_start = {
		prefix = "forestKeeper_roots",
		to = 10,
		from = 1
	},
	decal_eerie_roots_1_end = {
		prefix = "forestKeeper_roots",
		to = 29,
		from = 11
	},
	decal_eerie_roots_1_loop = {
		prefix = "forestKeeper_roots",
		to = 45,
		from = 30
	},
	decal_eerie_roots_2_start = {
		prefix = "forestKeeper_roots2",
		to = 10,
		from = 1
	},
	decal_eerie_roots_2_end = {
		prefix = "forestKeeper_roots2",
		to = 29,
		from = 11
	},
	decal_eerie_roots_2_loop = {
		prefix = "forestKeeper_roots2",
		to = 45,
		from = 30
	},
	fx_spear_forest_oak_hit = {
		prefix = "forestKeeper_proySpecial_hit",
		to = 9,
		from = 1
	},
	soldier_ewok_idle = {
		prefix = "ewok",
		to = 1,
		from = 1
	},
	soldier_ewok_running = {
		prefix = "ewok",
		to = 17,
		from = 2
	},
	soldier_ewok_attack = {
		prefix = "ewok",
		to = 29,
		from = 18
	},
	soldier_ewok_shield_start = {
		prefix = "ewok",
		to = 40,
		from = 30
	},
	soldier_ewok_shield_hit = {
		prefix = "ewok",
		to = 50,
		from = 41
	},
	soldier_ewok_shield_end = {
		prefix = "ewok",
		to = 55,
		from = 51
	},
	soldier_ewok_shoot = {
		prefix = "ewok",
		to = 72,
		from = 56
	},
	soldier_ewok_death = {
		prefix = "ewok",
		to = 80,
		from = 73
	},
	bullet_soldier_ewok = {
		prefix = "ewok_proy",
		to = 11,
		from = 1
	},
	faerie_dragon_idle = {
		prefix = "fairy_dragon",
		to = 18,
		from = 1
	},
	faerie_dragon_fly = {
		prefix = "fairy_dragon",
		to = 18,
		from = 1
	},
	faerie_dragon_rise = {
		prefix = "fairy_dragon",
		to = 78,
		from = 55
	},
	faerie_dragon_shoot = {
		prefix = "fairy_dragon",
		to = 53,
		from = 19
	},
	faerie_dragon_shoot_fx = {
		prefix = "fairy_dragon",
		to = 113,
		from = 79
	},
	faerie_dragon_proy_flying = {
		prefix = "fairy_dragon_proy",
		to = 1,
		from = 1
	},
	faerie_dragon_proy_hit = {
		prefix = "fairy_dragon_proy",
		to = 9,
		from = 2
	},
	mod_faerie_dragon_ground_start = {
		prefix = "fairy_dragon_freeze",
		to = 7,
		from = 1
	},
	mod_faerie_dragon_ground_end = {
		prefix = "fairy_dragon_freeze",
		to = 23,
		from = 8
	},
	mod_faerie_dragon_air_start = {
		prefix = "fairy_dragon_freeze_flying",
		to = 9,
		from = 1
	},
	mod_faerie_dragon_air_end = {
		prefix = "fairy_dragon_freeze_flying",
		to = 21,
		from = 10
	},
	soldier_drow_idle = {
		prefix = "mercenaryDraw",
		to = 1,
		from = 1
	},
	soldier_drow_running = {
		prefix = "mercenaryDraw",
		to = 6,
		from = 2
	},
	soldier_drow_healAttack = {
		prefix = "mercenaryDraw",
		to = 34,
		from = 7
	},
	soldier_drow_attack = {
		prefix = "mercenaryDraw",
		to = 57,
		from = 35
	},
	soldier_drow_shoot_start = {
		prefix = "mercenaryDraw",
		to = 67,
		from = 58
	},
	soldier_drow_shoot_loop = {
		prefix = "mercenaryDraw",
		to = 68,
		from = 68
	},
	soldier_drow_shoot_end = {
		prefix = "mercenaryDraw",
		to = 80,
		from = 69
	},
	soldier_drow_death = {
		prefix = "mercenaryDraw",
		to = 95,
		from = 81
	},
	soldier_drow_heal = {
		prefix = "mercenaryDraw",
		to = 115,
		from = 96
	},
	soldier_drow_blade_mail_decal = {
		prefix = "mercenaryDraw_decal",
		to = 30,
		from = 1
	},
	fx_dagger_drow_hit = {
		prefix = "mercenaryDraw_proyHit",
		to = 8,
		from = 1
	},
	dagger_drow_particle = {
		prefix = "mercenaryDraw_proyParticle",
		to = 8,
		from = 1
	},
	hero_alleria_idle = {
		prefix = "hero_alleria",
		to = 1,
		from = 1
	},
	hero_alleria_walk = {
		prefix = "hero_alleria",
		to = 6,
		from = 2
	},
	hero_alleria_shoot = {
		prefix = "hero_alleria",
		to = 24,
		from = 7
	},
	hero_alleria_attack = {
		prefix = "hero_alleria",
		to = 51,
		from = 25
	},
	hero_alleria_shootSpecial = {
		prefix = "hero_alleria",
		to = 74,
		from = 52
	},
	hero_alleria_death = {
		prefix = "hero_alleria",
		to = 88,
		from = 75
	},
	hero_alleria_respawn = {
		prefix = "hero_alleria",
		to = 112,
		from = 89
	},
	alleria_wildcat_idle = {
		prefix = "hero_alleria_wildcat",
		to = 1,
		from = 1
	},
	alleria_wildcat_walk = {
		prefix = "hero_alleria_wildcat",
		to = 11,
		from = 2
	},
	alleria_wildcat_attack = {
		prefix = "hero_alleria_wildcat",
		to = 57,
		from = 12
	},
	alleria_wildcat_scared = {
		prefix = "hero_alleria_wildcat",
		to = 61,
		from = 58
	},
	alleria_wildcat_toSad = {
		prefix = "hero_alleria_wildcat",
		to = 73,
		from = 62
	},
	alleria_wildcat_sadIdle = {
		prefix = "hero_alleria_wildcat",
		to = 74,
		from = 74
	},
	alleria_wildcat_sadSigh = {
		prefix = "hero_alleria_wildcat",
		to = 90,
		from = 75
	},
	alleria_wildcat_toStand = {
		prefix = "hero_alleria_wildcat",
		to = 102,
		from = 91
	},
	baby_malik_idle = {
		prefix = "malikAfro",
		to = 1,
		from = 1
	},
	baby_malik_walk = {
		prefix = "malikAfro",
		to = 6,
		from = 2
	},
	baby_malik_attack = {
		prefix = "malikAfro",
		to = 26,
		from = 7
	},
	baby_malik_attack2 = {
		prefix = "malikAfro",
		to = 45,
		from = 27
	},
	baby_malik_jumpSmash = {
		prefix = "malikAfro",
		to = 80,
		from = 46
	},
	baby_malik_smash = {
		prefix = "malikAfro",
		to = 111,
		from = 81
	},
	baby_malik_levelup = {
		prefix = "malikAfro",
		to = 130,
		from = 112
	},
	baby_malik_respawn = {
		prefix = "malikAfro",
		to = 130,
		from = 112
	},
	baby_malik_death = {
		prefix = "malikAfro",
		to = 137,
		from = 131
	},
	decal_baby_malik_ring = {
		prefix = "malikAfro_ring",
		to = 11,
		from = 1
	},
	decal_baby_malik_earthquake = {
		prefix = "malikAfro_rocks",
		to = 17,
		from = 1
	},
	decal_baby_malik_free = {
		prefix = "malikAfro_freedom",
		to = 114,
		from = 1
	},
	decal_baby_malik_idle = {
		prefix = "malikAfro_slave",
		to = 1,
		from = 1
	},
	decal_baby_malik_walkingRightLeft = {
		prefix = "malikAfro_slave",
		to = 6,
		from = 2
	},
	decal_baby_malik_work = {
		prefix = "malikAfro_slave",
		to = 22,
		from = 7
	},
	hero_bolverk_idle = {
		prefix = "bolverk_hero",
		to = 1,
		from = 1
	},
	hero_bolverk_walk = {
		prefix = "bolverk_hero",
		to = 8,
		from = 2
	},
	hero_bolverk_attack = {
		prefix = "bolverk_hero",
		to = 36,
		from = 9
	},
	hero_bolverk_hit = {
		prefix = "bolverk_hero",
		to = 62,
		from = 37
	},
	hero_bolverk_scream = {
		prefix = "bolverk_hero",
		to = 104,
		from = 63
	},
	hero_bolverk_death = {
		prefix = "bolverk_hero",
		to = 128,
		from = 105
	},
	hero_bolverk_respawn = {
		prefix = "bolverk_hero",
		to = 146,
		from = 129
	},
	mod_weakness_small = {
		prefix = "weakness_small",
		to = 11,
		from = 1
	},
	mod_weakness_big = {
		prefix = "weakness_big",
		to = 11,
		from = 1
	},
	hero_elves_archer_idle = {
		prefix = "archer_hero",
		to = 18,
		from = 1
	},
	hero_elves_archer_walk = {
		prefix = "archer_hero",
		to = 23,
		from = 19
	},
	hero_elves_archer_bow2sword = {
		prefix = "archer_hero",
		to = 29,
		from = 24
	},
	hero_elves_archer_idle_sword = {
		prefix = "archer_hero",
		to = 47,
		from = 30
	},
	hero_elves_archer_sword2bow = {
		prefix = "archer_hero",
		to = 53,
		from = 48
	},
	hero_elves_archer_shoot_start = {
		prefix = "archer_hero",
		to = 57,
		from = 54
	},
	hero_elves_archer_shoot_loop = {
		prefix = "archer_hero",
		to = 69,
		from = 64
	},
	hero_elves_archer_shoot_final = {
		prefix = "archer_hero",
		to = 73,
		from = 70
	},
	hero_elves_archer_shoot_end = {
		prefix = "archer_hero",
		to = 79,
		from = 74
	},
	hero_elves_archer_attack = {
		prefix = "archer_hero",
		to = 96,
		from = 80
	},
	hero_elves_archer_double_strike = {
		prefix = "archer_hero",
		to = 122,
		from = 97
	},
	hero_elves_archer_nimble_fencer = {
		prefix = "archer_hero",
		to = 138,
		from = 123
	},
	hero_elves_archer_death = {
		prefix = "archer_hero",
		to = 150,
		from = 139
	},
	hero_elves_archer_levelup = {
		prefix = "archer_hero",
		to = 167,
		from = 151
	},
	hero_elves_archer_respawn = {
		prefix = "archer_hero",
		to = 167,
		from = 151
	},
	hero_elves_archer_shoot = {
		prefix = "archer_hero",
		ranges = {
			{
				54,
				63
			},
			{
				74,
				79
			}
		}
	},
	decal_hero_elves_archer_ultimate = {
		prefix = "archer_hero_arrows_decal",
		to = 11,
		from = 1
	},
	fx_hero_elves_archer_ultimate_smoke = {
		prefix = "archer_hero_arrows_smokeDecal",
		to = 11,
		from = 1
	},
	hero_elves_denas_idle = {
		prefix = "denas_hero",
		to = 1,
		from = 1
	},
	hero_elves_denas_walk = {
		prefix = "denas_hero",
		to = 17,
		from = 2
	},
	hero_elves_denas_attack = {
		prefix = "denas_hero",
		to = 53,
		from = 18
	},
	hero_elves_denas_attack2 = {
		prefix = "denas_hero",
		to = 79,
		from = 54
	},
	hero_elves_denas_eat = {
		prefix = "denas_hero",
		to = 139,
		from = 80
	},
	hero_elves_denas_showOff = {
		prefix = "denas_hero",
		to = 217,
		from = 140
	},
	hero_elves_denas_specialAttack = {
		prefix = "denas_hero",
		to = 271,
		from = 218
	},
	hero_elves_denas_coinThrow = {
		prefix = "denas_hero",
		to = 391,
		from = 355
	},
	hero_elves_denas_death = {
		prefix = "denas_hero",
		to = 332,
		from = 307
	},
	hero_elves_denas_respawn = {
		prefix = "denas_hero",
		to = 354,
		from = 333
	},
	hero_elves_denas_levelup = {
		prefix = "denas_hero",
		to = 354,
		from = 333
	},
	hero_elves_denas_shieldThrow = {
		prefix = "denas_hero",
		to = 306,
		from = 272
	},
	fx_elves_denas_heal = {
		prefix = "denas_hero_healFx",
		to = 25,
		from = 1
	},
	fx_elves_denas_flash = {
		prefix = "denas_hero_flash",
		to = 3,
		from = 1
	},
	shield_elves_denas_loop = {
		prefix = "hero_denas_proy",
		to = 8,
		from = 1
	},
	shield_elves_denas_particle = {
		prefix = "hero_denas_proyParticle",
		to = 8,
		from = 1
	},
	fx_shield_elves_denas_hit = {
		prefix = "hero_denas_proyHit",
		to = 7,
		from = 1
	},
	elves_denas_guard_idle = {
		prefix = "denas_hero_guard",
		to = 1,
		from = 1
	},
	elves_denas_guard_running = {
		prefix = "denas_hero_guard",
		to = 6,
		from = 2
	},
	elves_denas_guard_attack = {
		prefix = "denas_hero_guard",
		to = 28,
		from = 7
	},
	elves_denas_guard_attack2 = {
		prefix = "denas_hero_guard",
		to = 52,
		from = 29
	},
	elves_denas_guard_death = {
		prefix = "denas_hero_guard",
		to = 60,
		from = 53
	},
	elves_denas_guard_respawn = {
		prefix = "denas_hero_guard",
		to = 79,
		from = 61
	},
	elves_denas_guard_raise = {
		prefix = "denas_hero_guard",
		to = 79,
		from = 61
	},
	hero_arivan_idle = {
		prefix = "arivan_hero",
		to = 1,
		from = 1
	},
	hero_arivan_walk = {
		prefix = "arivan_hero",
		to = 17,
		from = 2
	},
	hero_arivan_attack = {
		prefix = "arivan_hero",
		to = 43,
		from = 18
	},
	hero_arivan_rayShoot = {
		prefix = "arivan_hero",
		to = 75,
		from = 44
	},
	hero_arivan_freezeBall = {
		prefix = "arivan_hero",
		to = 108,
		from = 76
	},
	hero_arivan_multiShootStart = {
		prefix = "arivan_hero",
		to = 127,
		from = 109
	},
	hero_arivan_multiShootLoop = {
		prefix = "arivan_hero",
		to = 147,
		from = 128
	},
	hero_arivan_multiShootEnd = {
		prefix = "arivan_hero",
		to = 157,
		from = 148
	},
	hero_arivan_stoneCast = {
		prefix = "arivan_hero",
		to = 193,
		from = 158
	},
	hero_arivan_levelup = {
		prefix = "arivan_hero",
		to = 217,
		from = 194
	},
	hero_arivan_respawn = {
		prefix = "arivan_hero",
		to = 217,
		from = 194
	},
	hero_arivan_death = {
		prefix = "arivan_hero",
		to = 243,
		from = 218
	},
	hero_arivan_shoot = {
		prefix = "arivan_hero",
		to = 268,
		from = 244
	},
	arivan_ray_simple = {
		prefix = "arivan_hero_ray_simple",
		to = 12,
		from = 1
	},
	arivan_ray_simple_hit = {
		prefix = "arivan_hero_ray_simple_hit",
		to = 6,
		from = 1
	},
	arivan_fireball_idle = {
		prefix = "arivan_hero_fire_proy",
		to = 10,
		from = 1
	},
	arivan_fireball_travel = {
		prefix = "arivan_hero_fire_proy",
		to = 10,
		from = 1
	},
	arivan_fireball_hit = {
		prefix = "arivan_hero_fire_explosion",
		to = 14,
		from = 1
	},
	arivan_fireball_particle_1 = {
		prefix = "arivan_hero_fire_particle",
		to = 10,
		from = 1
	},
	arivan_fireball_particle_2 = {
		prefix = "arivan_hero_fire_particle2",
		to = 10,
		from = 1
	},
	arivan_lightning = {
		prefix = "arivan_hero_ray",
		to = 10,
		from = 1
	},
	arivan_lightning_hit = {
		prefix = "arivan_hero_ray_hit",
		to = 6,
		from = 1
	},
	arivan_freeze_idle = {
		prefix = "arivan_hero_freeze_proy",
		to = 1,
		from = 1
	},
	arivan_freeze_flying = {
		prefix = "arivan_hero_freeze_proy",
		to = 3,
		from = 1
	},
	arivan_freeze_hit = {
		prefix = "arivan_hero_freeze_hitFx",
		to = 16,
		from = 1
	},
	arivan_freeze_particle = {
		prefix = "arivan_hero_freeze_proy_particle",
		to = 6,
		from = 1
	},
	arivan_shield = {
		prefix = "arivan_hero_shield",
		to = 8,
		from = 1
	},
	arivan_stone_1 = {
		prefix = "arivan_stone_1",
		to = 13,
		from = 1
	},
	arivan_stone_2 = {
		prefix = "arivan_stone_2",
		to = 13,
		from = 1
	},
	arivan_stone_3 = {
		prefix = "arivan_stone_3",
		to = 13,
		from = 1
	},
	arivan_stone_explosion = {
		prefix = "arivan_stone_explosion",
		to = 12,
		from = 1
	},
	arivan_twister_start = {
		prefix = "arivan_hero_twister",
		to = 12,
		from = 1
	},
	arivan_twister_travel = {
		prefix = "arivan_hero_twister",
		to = 20,
		from = 13
	},
	arivan_twister_end = {
		prefix = "arivan_hero_twister",
		to = 28,
		from = 21
	},
	arivan_twister_ray = {
		prefix = "arivan_hero_twister_ray",
		to = 10,
		from = 1
	},
	arivan_twister_ray_hit = {
		prefix = "arivan_hero_twister_creepFx_big",
		to = 6,
		from = 1
	},
	hero_regson_idle = {
		prefix = "regson_hero",
		to = 1,
		from = 1
	},
	hero_regson_run = {
		prefix = "regson_hero",
		to = 8,
		from = 2
	},
	hero_regson_attack1 = {
		prefix = "regson_hero",
		to = 26,
		from = 9
	},
	hero_regson_attack2 = {
		prefix = "regson_hero",
		to = 43,
		from = 27
	},
	hero_regson_attack3 = {
		prefix = "regson_hero",
		to = 60,
		from = 44
	},
	hero_regson_whirlwind = {
		prefix = "regson_hero",
		to = 78,
		from = 61
	},
	hero_regson_respawn = {
		prefix = "regson_hero",
		to = 94,
		from = 79
	},
	hero_regson_levelup = {
		prefix = "regson_hero",
		to = 94,
		from = 79
	},
	hero_regson_death = {
		prefix = "regson_hero",
		to = 107,
		from = 95
	},
	hero_regson_berserk_idle = {
		prefix = "regson_hero",
		to = 121,
		from = 108
	},
	hero_regson_berserk_run = {
		prefix = "regson_hero",
		to = 128,
		from = 122
	},
	hero_regson_berserk_attack = {
		prefix = "regson_hero",
		to = 158,
		from = 129
	},
	hero_regson_goBerserk = {
		prefix = "regson_hero",
		to = 175,
		from = 159
	},
	regson_heal_ball_travel = {
		prefix = "regson_hero_soulProy",
		to = 5,
		from = 1
	},
	fx_regson_heal_ball_spawn = {
		prefix = "regson_hero_soulFx",
		to = 12,
		from = 1
	},
	fx_regson_heal = {
		prefix = "regson_hero_soulHeal",
		to = 25,
		from = 1
	},
	fx_regson_slash = {
		prefix = "regson_hero_whirlwindFx",
		to = 11,
		from = 1
	},
	fx_regson_ultimate = {
		prefix = "regson_hero_ultimate",
		to = 25,
		from = 1
	},
	hero_faustus_idle = {
		prefix = "faustus_hero",
		to = 18,
		from = 1
	},
	hero_faustus_attackBase = {
		prefix = "faustus_hero",
		to = 48,
		from = 19
	},
	hero_faustus_silence = {
		prefix = "faustus_hero",
		to = 66,
		from = 49
	},
	hero_faustus_altAttackBase = {
		prefix = "faustus_hero",
		to = 102,
		from = 67
	},
	hero_faustus_teleport = {
		prefix = "faustus_hero",
		to = 138,
		from = 103
	},
	hero_faustus_rayShoot = {
		prefix = "faustus_hero",
		to = 174,
		from = 139
	},
	hero_faustus_death = {
		prefix = "faustus_hero",
		to = 200,
		from = 175
	},
	hero_faustus_respawn = {
		prefix = "faustus_hero",
		to = 232,
		from = 201
	},
	hero_faustus_shadow = {
		prefix = "faustus_hero",
		to = 233,
		from = 233
	},
	fx_faustus_attack = {
		prefix = "faustus_hero_attackFx",
		to = 30,
		from = 1
	},
	bolt_faustus_travel = {
		prefix = "faustus_hero_proy",
		to = 1,
		from = 1
	},
	bolt_faustus_hit = {
		prefix = "faustus_hero_proy",
		to = 9,
		from = 2
	},
	bolt_faustus_particle = {
		prefix = "faustus_hero_proy_particle",
		to = 8,
		from = 1
	},
	bolt_lance_faustus_flying = {
		prefix = "faustus_hero_rayHit_big",
		to = 1,
		from = 1
	},
	bolt_lance_faustus_particle = {
		prefix = "faustus_hero_rayProy",
		to = 8,
		from = 1
	},
	fx_bolt_lance_faustus_hit_big = {
		prefix = "faustus_hero_rayHit_big",
		to = 10,
		from = 1
	},
	fx_bolt_lance_faustus_hit_small = {
		prefix = "faustus_hero_rayHit_small",
		to = 10,
		from = 1
	},
	aura_teleport_faustus = {
		prefix = "faustus_hero_teleportDecal",
		to = 15,
		from = 1
	},
	fx_teleport_faustus = {
		prefix = "faustus_hero_teleport_big",
		to = 10,
		from = 1
	},
	mod_enervation_faustus_big = {
		prefix = "faustus_hero_silenceFx_big",
		to = 10,
		from = 1
	},
	mod_enervation_faustus_small = {
		prefix = "faustus_hero_silenceFx_small",
		to = 10,
		from = 1
	},
	fx_faustus_start_liquid_fire = {
		prefix = "faustus_hero_attackGlow",
		to = 30,
		from = 1
	},
	bullet_liquid_fire_faustus_particle = {
		prefix = "faustus_hero_magicFire_proy",
		to = 6,
		from = 1
	},
	fx_bullet_liquid_fire_faustus_hit = {
		prefix = "faustus_hero_magicFire_hit",
		to = 10,
		from = 1
	},
	aura_liquid_fire_flame_faustus = {
		prefix = "faustus_hero_magicFire_fire",
		to = 14,
		from = 1
	},
	mod_liquid_fire_faustus_small = {
		prefix = "faustus_hero_creep_fire_effect_small",
		to = 11,
		from = 1
	},
	mod_liquid_fire_faustus_big = {
		prefix = "faustus_hero_creep_fire_effect_big",
		to = 11,
		from = 1
	},
	minidragon_faustus_l1_idle = {
		prefix = "faustus_hero_rage",
		to = 18,
		from = 1
	},
	minidragon_faustus_l2_idle = {
		prefix = "faustus_hero_rage",
		to = 36,
		from = 19
	},
	minidragon_faustus_l1_fire = {
		prefix = "faustus_hero_rage",
		to = 18,
		from = 1
	},
	minidragon_faustus_l2_fire = {
		prefix = "faustus_hero_rage",
		to = 54,
		from = 37
	},
	hero_bravebark_idle = {
		prefix = "bravebark_hero",
		to = 1,
		from = 1
	},
	hero_bravebark_running = {
		prefix = "bravebark_hero",
		to = 26,
		from = 2
	},
	hero_bravebark_teleport_out = {
		prefix = "bravebark_hero",
		to = 50,
		from = 27
	},
	hero_bravebark_teleport_in = {
		prefix = "bravebark_hero",
		to = 83,
		from = 51
	},
	hero_bravebark_rootSpikes = {
		prefix = "bravebark_hero",
		to = 119,
		from = 84
	},
	hero_bravebark_oakSeeds = {
		prefix = "bravebark_hero",
		to = 139,
		from = 120
	},
	hero_bravebark_branchBall = {
		prefix = "bravebark_hero",
		to = 185,
		from = 140
	},
	hero_bravebark_springsap_start = {
		prefix = "bravebark_hero",
		to = 196,
		from = 186
	},
	hero_bravebark_springsap_loop = {
		prefix = "bravebark_hero",
		to = 216,
		from = 197
	},
	hero_bravebark_springsap_end = {
		prefix = "bravebark_hero",
		to = 219,
		from = 217
	},
	hero_bravebark_levelup = {
		prefix = "bravebark_hero",
		to = 239,
		from = 220
	},
	hero_bravebark_attack = {
		prefix = "bravebark_hero",
		to = 265,
		from = 240
	},
	hero_bravebark_death = {
		prefix = "bravebark_hero",
		to = 312,
		from = 266
	},
	hero_bravebark_respawn = {
		prefix = "bravebark_hero",
		to = 331,
		from = 313
	},
	bravebark_springSapBubbles = {
		prefix = "bravebark_hero_springSapBubbles",
		to = 16,
		from = 1
	},
	bravebark_spike_out = {
		prefix = "bravebark_hero_spike",
		to = 14,
		from = 13
	},
	bravebark_spike_in = {
		prefix = "bravebark_hero_spike",
		to = 12,
		from = 1
	},
	bravebark_paralyzeRoots = {
		prefix = "bravebark_hero_paralyzeRoots",
		to = 28,
		from = 1
	},
	bravebark_teleportOutFx = {
		prefix = "bravebark_hero_teleportOutFx",
		to = 44,
		from = 1
	},
	bravebark_teleportInFx = {
		prefix = "bravebark_hero_teleportInFx",
		to = 44,
		from = 1
	},
	bravebark_spikedRoots_spawnFx = {
		prefix = "bravebark_hero_spikedRoots_spawnFx",
		to = 24,
		from = 1
	},
	bravebark_superHit = {
		prefix = "bravebark_hero_superHit",
		to = 6,
		from = 1
	},
	bravebark_levelUpLeaves = {
		prefix = "bravebark_hero_levelUpLeaves",
		to = 29,
		from = 1
	},
	bravebark_spikedRoots1_in = {
		prefix = "bravebark_hero_spikedRoots1",
		to = 3,
		from = 1
	},
	bravebark_spikedRoots1_out = {
		prefix = "bravebark_hero_spikedRoots1",
		to = 28,
		from = 20
	},
	bravebark_spikedRoots2_in = {
		prefix = "bravebark_hero_spikedRoots2",
		to = 3,
		from = 1
	},
	bravebark_spikedRoots2_out = {
		prefix = "bravebark_hero_spikedRoots2",
		to = 27,
		from = 18
	},
	bravebark_spikedRoots3_in = {
		prefix = "bravebark_hero_spikedRoots3",
		to = 3,
		from = 1
	},
	bravebark_spikedRoots3_out = {
		prefix = "bravebark_hero_spikedRoots3",
		to = 24,
		from = 16
	},
	bravebark_hitSmoke = {
		prefix = "bravebark_hero_hitSmoke",
		to = 18,
		from = 1
	},
	bravebark_mignon_raise = {
		prefix = "bravebark_hero_mignon",
		to = 18,
		from = 1
	},
	bravebark_mignon_idle = {
		prefix = "bravebark_hero_mignon",
		to = 19,
		from = 19
	},
	bravebark_mignon_attack = {
		prefix = "bravebark_hero_mignon",
		to = 38,
		from = 20
	},
	bravebark_mignon_running = {
		prefix = "bravebark_hero_mignon",
		to = 48,
		from = 39
	},
	bravebark_mignon_death = {
		prefix = "bravebark_hero_mignon",
		to = 85,
		from = 49
	},
	hero_xin_idle = {
		prefix = "xin_hero",
		to = 1,
		from = 1
	},
	hero_xin_running = {
		prefix = "xin_hero",
		to = 23,
		from = 2
	},
	hero_xin_death = {
		prefix = "xin_hero",
		to = 47,
		from = 24
	},
	hero_xin_levelup = {
		prefix = "xin_hero",
		to = 88,
		from = 48
	},
	hero_xin_attack2 = {
		prefix = "xin_hero",
		to = 117,
		from = 89
	},
	hero_xin_attack = {
		prefix = "xin_hero",
		to = 154,
		from = 118
	},
	hero_xin_drink = {
		prefix = "xin_hero",
		to = 199,
		from = 155
	},
	hero_xin_buttStrike = {
		prefix = "xin_hero",
		to = 235,
		from = 200
	},
	hero_xin_inspire = {
		prefix = "xin_hero",
		to = 294,
		from = 247
	},
	hero_xin_respawn = {
		prefix = "xin_hero",
		to = 318,
		from = 295
	},
	hero_xin_teleport_out = {
		prefix = "xin_hero",
		to = 338,
		from = 319
	},
	hero_xin_teleport_hit = {
		prefix = "xin_hero",
		to = 366,
		from = 355
	},
	hero_xin_teleport_hit2 = {
		prefix = "xin_hero",
		to = 388,
		from = 367
	},
	hero_xin_teleport_hit_out = {
		prefix = "xin_hero",
		to = 338,
		from = 332
	},
	hero_xin_teleport_in = {
		prefix = "xin_hero",
		to = 430,
		from = 401
	},
	hero_xin_death_staff = {
		prefix = "xin_hero_death_staff",
		to = 23,
		from = 1
	},
	xin_shadow_raise = {
		prefix = "xin_hero_shadow",
		to = 10,
		from = 1
	},
	xin_shadow_attack = {
		prefix = "xin_hero_shadow",
		to = 20,
		from = 11
	},
	xin_shadow_attack2 = {
		prefix = "xin_hero_shadow",
		to = 32,
		from = 21
	},
	xin_shadow_attack3 = {
		prefix = "xin_hero_shadow",
		to = 42,
		from = 33
	},
	xin_shadow_attack4 = {
		prefix = "xin_hero_shadow",
		to = 51,
		from = 43
	},
	xin_shadow_death = {
		prefix = "xin_hero_shadow",
		to = 82,
		from = 52
	},
	xin_shadow_idle = {
		prefix = "xin_hero_shadow",
		to = 9,
		from = 9
	},
	fx_xin_smoke_teleport_in = {
		prefix = "xin_hero_teleport_smoke",
		to = 112,
		from = 83
	},
	fx_xin_smoke_teleport_out = {
		prefix = "xin_hero_teleport_smoke",
		to = 36,
		from = 1
	},
	fx_xin_smoke_teleport_hit = {
		prefix = "xin_hero_teleport_smoke",
		to = 82,
		from = 37
	},
	fx_xin_smoke_teleport_hit_out = {
		prefix = "xin_hero_teleport_smoke",
		to = 36,
		from = 14
	},
	fx_xin_drink_bubbles = {
		prefix = "xin_hero_drink_bubbles",
		to = 22,
		from = 1
	},
	fx_xin_panda_style_smoke = {
		prefix = "xin_hero_buttStrike_smoke",
		to = 18,
		from = 1
	},
	mod_xin_inspire = {
		prefix = "xin_hero_scream_soldierDecal",
		to = 24,
		from = 1
	},
	hero_catha_idle = {
		prefix = "catha_hero",
		to = 14,
		from = 1
	},
	hero_catha_attack = {
		prefix = "catha_hero",
		to = 40,
		from = 15
	},
	hero_catha_shoot = {
		prefix = "catha_hero",
		to = 56,
		from = 41
	},
	hero_catha_shootUp = {
		prefix = "catha_hero",
		to = 72,
		from = 57
	},
	hero_catha_running = {
		prefix = "catha_hero",
		to = 88,
		from = 73
	},
	hero_catha_death = {
		prefix = "catha_hero",
		to = 112,
		from = 89
	},
	hero_catha_levelup = {
		prefix = "catha_hero",
		to = 138,
		from = 113
	},
	hero_catha_respawn = {
		prefix = "catha_hero",
		to = 138,
		from = 113
	},
	hero_catha_cloudSpell = {
		prefix = "catha_hero",
		to = 176,
		from = 139
	},
	hero_catha_cloneSpell = {
		prefix = "catha_hero",
		to = 221,
		from = 177
	},
	hero_catha_explode = {
		prefix = "catha_hero",
		to = 245,
		from = 222
	},
	hero_catha_reAppear = {
		prefix = "catha_hero",
		to = 255,
		from = 246
	},
	hero_catha_dashStart = {
		prefix = "catha_hero",
		to = 373,
		from = 368
	},
	hero_catha_dashLoop = {
		prefix = "catha_hero",
		to = 388,
		from = 374
	},
	hero_catha_dashHit = {
		prefix = "catha_hero",
		to = 411,
		from = 389
	},
	hero_catha_ultimate = {
		prefix = "catha_hero",
		to = 452,
		from = 412
	},
	soldier_catha_idle = {
		prefix = "catha_hero",
		to = 269,
		from = 256
	},
	soldier_catha_attack = {
		prefix = "catha_hero",
		to = 295,
		from = 270
	},
	soldier_catha_shoot = {
		prefix = "catha_hero",
		to = 311,
		from = 296
	},
	soldier_catha_shootUp = {
		prefix = "catha_hero",
		to = 327,
		from = 312
	},
	soldier_catha_running = {
		prefix = "catha_hero",
		to = 343,
		from = 328
	},
	soldier_catha_death = {
		prefix = "catha_hero",
		to = 367,
		from = 344
	},
	soldier_catha_raise = {
		prefix = "catha_hero",
		frames = {
			453,
			453,
			453,
			453,
			453,
			453,
			453
		}
	},
	mod_catha_curse_loop = {
		prefix = "catha_hero_sleep",
		to = 50,
		from = 1
	},
	mod_catha_soul = {
		prefix = "catha_hero_healFx",
		to = 25,
		from = 1
	},
	fx_knife_catha_hit = {
		prefix = "catha_hero_proy",
		to = 7,
		from = 2
	},
	fx_catha_soul = {
		prefix = "catha_hero_cloud",
		to = 14,
		from = 1
	},
	fx_catha_ultimate = {
		prefix = "catha_hero_cloud_decal",
		to = 14,
		from = 1
	},
	veznan_hero_idle = {
		prefix = "veznan_hero",
		to = 1,
		from = 1
	},
	veznan_hero_stand = {
		prefix = "veznan_hero",
		to = 35,
		from = 2
	},
	veznan_hero_running = {
		prefix = "veznan_hero",
		to = 51,
		from = 36
	},
	veznan_hero_shoot = {
		prefix = "veznan_hero",
		to = 78,
		from = 52
	},
	veznan_hero_death = {
		prefix = "veznan_hero",
		to = 102,
		from = 79
	},
	veznan_hero_respawn = {
		prefix = "veznan_hero",
		to = 121,
		from = 103
	},
	veznan_hero_levelup = {
		prefix = "veznan_hero",
		to = 121,
		from = 103
	},
	veznan_hero_soulBurnStart = {
		prefix = "veznan_hero",
		to = 132,
		from = 122
	},
	veznan_hero_soulBurnLoop = {
		prefix = "veznan_hero",
		to = 138,
		from = 133
	},
	veznan_hero_soulBurnEnd = {
		prefix = "veznan_hero",
		to = 159,
		from = 139
	},
	veznan_hero_shackles = {
		prefix = "veznan_hero",
		to = 183,
		from = 160
	},
	veznan_hero_arcaneNova = {
		prefix = "veznan_hero",
		to = 219,
		from = 184
	},
	veznan_hero_teleport_out = {
		prefix = "veznan_hero",
		to = 237,
		from = 220
	},
	veznan_hero_teleport_in = {
		prefix = "veznan_hero",
		to = 255,
		from = 238
	},
	veznan_hero_attack = {
		prefix = "veznan_hero",
		to = 274,
		from = 256
	},
	veznan_hero_bolt_flying = {
		prefix = "veznan_hero_proy",
		to = 2,
		from = 1
	},
	veznan_hero_bolt_hit = {
		prefix = "veznan_hero_proy",
		to = 10,
		from = 3
	},
	veznan_hero_soulBurn_proy_spawn_big = {
		prefix = "veznan_hero_soulBurn_Fx_big",
		to = 6,
		from = 1
	},
	veznan_hero_soulBurn_proy_spawn_small = {
		prefix = "veznan_hero_soulBurn_Fx_small",
		to = 6,
		from = 1
	},
	veznan_hero_soulBurn_proy_fly = {
		prefix = "veznan_hero_soulBurn_proy",
		to = 9,
		from = 1
	},
	veznan_hero_soulBurn_proy_hit = {
		prefix = "veznan_hero_soulBurn_proy",
		to = 17,
		from = 10
	},
	veznan_hero_soulBurn_desintegrate_big = {
		prefix = "veznan_hero_soulBurn_big",
		to = 16,
		from = 1
	},
	veznan_hero_soulBurn_desintegrate_small = {
		prefix = "veznan_hero_soulBurn_small",
		to = 16,
		from = 1
	},
	veznan_hero_shackles_big_start = {
		prefix = "veznan_hero_shackles_big",
		to = 11,
		from = 1
	},
	veznan_hero_shackles_big_loop = {
		prefix = "veznan_hero_shackles_big",
		to = 33,
		from = 12
	},
	veznan_hero_shackles_big_end = {
		prefix = "veznan_hero_shackles_big",
		to = 41,
		from = 34
	},
	veznan_hero_shackles_small_start = {
		prefix = "veznan_hero_shackles_small",
		to = 11,
		from = 1
	},
	veznan_hero_shackles_small_loop = {
		prefix = "veznan_hero_shackles_small",
		to = 33,
		from = 12
	},
	veznan_hero_shackles_small_end = {
		prefix = "veznan_hero_shackles_small",
		to = 41,
		from = 34
	},
	fx_veznan_arcanenova = {
		prefix = "veznan_hero_arcaneNova",
		to = 16,
		from = 1
	},
	fx_veznan_arcanenova_terrain = {
		prefix = "veznan_hero_arcaneNova_decal",
		to = 14,
		from = 1
	},
	veznan_demon_raise = {
		prefix = "veznan_hero_demon",
		to = 28,
		from = 1
	},
	veznan_demon_idle = {
		prefix = "veznan_hero_demon",
		to = 29,
		from = 29
	},
	veznan_demon_running = {
		prefix = "veznan_hero_demon",
		to = 45,
		from = 30
	},
	veznan_demon_attack = {
		prefix = "veznan_hero_demon",
		to = 67,
		from = 46
	},
	veznan_demon_shoot = {
		prefix = "veznan_hero_demon",
		to = 92,
		from = 68
	},
	veznan_demon_death = {
		prefix = "veznan_hero_demon",
		to = 113,
		from = 93
	},
	fx_fireball_veznan_demon_hit = {
		prefix = "veznan_hero_demon_proyHit",
		to = 13,
		from = 1
	},
	fx_fireball_veznan_demon_hit_air = {
		prefix = "veznan_hero_demon_proyHit_air",
		to = 18,
		from = 1
	},
	fireball_veznan_demon = {
		prefix = "veznan_hero_demon_proy",
		to = 12,
		from = 1
	},
	hero_rag_layerX_idle = {
		layer_to = 2,
		from = 1,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 1,
		layer_from = 1
	},
	hero_rag_layerX_running = {
		layer_to = 2,
		from = 2,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 25,
		layer_from = 1
	},
	hero_rag_layerX_attack = {
		layer_to = 2,
		from = 26,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 52,
		layer_from = 1
	},
	hero_rag_layerX_shoot = {
		layer_to = 2,
		from = 53,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 73,
		layer_from = 1
	},
	hero_rag_layerX_polymorph = {
		layer_to = 2,
		from = 74,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 104,
		layer_from = 1
	},
	hero_rag_layerX_rabbitCall = {
		layer_to = 2,
		from = 105,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 135,
		layer_from = 1
	},
	hero_rag_layerX_rabbitCallEnd = {
		layer_to = 2,
		from = 136,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 148,
		layer_from = 1
	},
	hero_rag_layerX_hammer_start = {
		layer_to = 2,
		from = 149,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 170,
		layer_from = 1
	},
	hero_rag_layerX_hammer_idle = {
		layer_to = 2,
		from = 171,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 180,
		layer_from = 1
	},
	hero_rag_layerX_hammer_walk = {
		layer_to = 2,
		from = 181,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 200,
		layer_from = 1
	},
	hero_rag_layerX_hammer_end = {
		layer_to = 2,
		from = 201,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 209,
		layer_from = 1
	},
	hero_rag_layerX_throw_bolso = {
		layer_to = 2,
		from = 210,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 239,
		layer_from = 1
	},
	hero_rag_layerX_throw_anchor = {
		layer_to = 2,
		from = 240,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 269,
		layer_from = 1
	},
	hero_rag_layerX_throw_fungus = {
		layer_to = 2,
		from = 270,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 299,
		layer_from = 1
	},
	hero_rag_layerX_throw_pan = {
		layer_to = 2,
		from = 300,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 329,
		layer_from = 1
	},
	hero_rag_layerX_throw_chair = {
		layer_to = 2,
		from = 330,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 361,
		layer_from = 1
	},
	hero_rag_layerX_death = {
		layer_to = 2,
		from = 362,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 386,
		layer_from = 1
	},
	hero_rag_layerX_respawn = {
		layer_to = 2,
		from = 387,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 411,
		layer_from = 1
	},
	hero_rag_layerX_levelup = {
		layer_to = 2,
		from = 387,
		layer_prefix = "razzAndRaggs_hero_layer%i",
		to = 411,
		layer_from = 1
	},
	fx_bullet_rag_hit = {
		prefix = "razzAndRaggs_hero_proy_hit",
		to = 7,
		from = 1
	},
	ray_rag = {
		prefix = "razzAndRaggs_hero_ray",
		to = 14,
		from = 1
	},
	rag_polymorphed_idle = {
		prefix = "razzAndRaggs_hero_polymorph",
		to = 1,
		from = 1
	},
	rag_polymorphed_running = {
		prefix = "razzAndRaggs_hero_polymorph",
		to = 13,
		from = 2
	},
	rag_polymorphed_attack = {
		prefix = "razzAndRaggs_hero_polymorph",
		to = 40,
		from = 14
	},
	rag_polymorphed_fx = {
		prefix = "razzAndRaggs_hero_polymorph",
		to = 56,
		from = 41
	},
	rag_polymorphed_death = {
		prefix = "razzAndRaggs_hero_polymorph",
		to = 1,
		from = 1
	},
	bullet_kamihare = {
		prefix = "rabbit",
		to = 5,
		from = 1
	},
	fx_rabbit_kamihare_explode = {
		prefix = "razzAndRaggs_rabbit_explosion",
		to = 21,
		from = 1
	},
	fx_rag_ultimate = {
		prefix = "razzAndRaggs_hero_ultimateFx",
		to = 21,
		from = 1
	},
	decal_rag_ultimate = {
		prefix = "razzAndRaggs_hero_ultimateFx_decal",
		to = 12,
		from = 1
	},
	durax_hero_idle = {
		prefix = "durax_hero",
		to = 1,
		from = 1
	},
	durax_hero_running = {
		prefix = "durax_hero",
		to = 21,
		from = 2
	},
	durax_hero_attack = {
		prefix = "durax_hero",
		to = 37,
		from = 22
	},
	durax_hero_attack2 = {
		prefix = "durax_hero",
		to = 54,
		from = 38
	},
	durax_hero_armblade = {
		prefix = "durax_hero",
		to = 96,
		from = 55
	},
	durax_hero_crystallites = {
		prefix = "durax_hero",
		to = 120,
		from = 97
	},
	durax_hero_shardseed = {
		prefix = "durax_hero",
		to = 142,
		from = 121
	},
	durax_hero_lethalPrismStart = {
		prefix = "durax_hero",
		to = 148,
		from = 143
	},
	durax_hero_lethalPrismLoop = {
		prefix = "durax_hero",
		to = 179,
		from = 149
	},
	durax_hero_lethalPrismEnd = {
		prefix = "durax_hero",
		to = 187,
		from = 180
	},
	durax_hero_respawn = {
		prefix = "durax_hero",
		to = 215,
		from = 188
	},
	durax_hero_levelup = {
		prefix = "durax_hero",
		to = 215,
		from = 188
	},
	durax_hero_specialwalkLoop = {
		prefix = "durax_hero",
		to = 223,
		from = 216
	},
	durax_hero_death = {
		prefix = "durax_hero",
		to = 256,
		from = 224
	},
	fx_shardseed_hit = {
		prefix = "durax_hero_proy_explosion",
		to = 15,
		from = 1
	},
	ray_durax = {
		prefix = "durax_hero_lethalprism_ray",
		to = 25,
		from = 1
	},
	fx_ray_durax_hit = {
		prefix = "durax_hero_lethalprism_ray_hit",
		to = 8,
		from = 1
	},
	aura_durax = {
		prefix = "durax_hero_aura_floor",
		to = 16,
		from = 1
	},
	ps_durax_transfer = {
		prefix = "durax_hero_particle",
		to = 6,
		from = 1
	},
	fx_durax_ultimate_fang_1 = {
		prefix = "durax_hero_saphirefangultimate_single",
		to = 29,
		from = 1
	},
	fx_durax_ultimate_fang_2 = {
		prefix = "durax_hero_saphirefangultimate_multiple",
		to = 29,
		from = 1
	},
	fx_durax_ultimate_fang_extra_1 = {
		prefix = "durax_hero_saphirefangultimate_complement_1",
		to = 29,
		from = 1
	},
	fx_durax_ultimate_fang_extra_2 = {
		prefix = "durax_hero_saphirefangultimate_complement_2",
		to = 29,
		from = 1
	},
	hero_lilith_idle = {
		prefix = "fallen_angel_hero",
		to = 24,
		from = 1
	},
	hero_lilith_running = {
		prefix = "fallen_angel_hero",
		to = 48,
		from = 25
	},
	hero_lilith_attack = {
		prefix = "fallen_angel_hero",
		to = 73,
		from = 49
	},
	hero_lilith_attack2 = {
		prefix = "fallen_angel_hero",
		to = 89,
		from = 74
	},
	hero_lilith_reapersHarvest = {
		prefix = "fallen_angel_hero",
		to = 149,
		from = 90
	},
	hero_lilith_infernalWheel = {
		prefix = "fallen_angel_hero",
		to = 189,
		from = 150
	},
	hero_lilith_respawn = {
		prefix = "fallen_angel_hero",
		to = 203,
		from = 190
	},
	hero_lilith_levelup = {
		prefix = "fallen_angel_hero",
		to = 203,
		from = 190
	},
	hero_lilith_resurrection = {
		prefix = "fallen_angel_hero",
		to = 219,
		from = 204
	},
	hero_lilith_death = {
		prefix = "fallen_angel_hero",
		to = 234,
		from = 220
	},
	hero_lilith_throw = {
		prefix = "fallen_angel_hero",
		to = 267,
		from = 235
	},
	fx_lilith_ranged_hit = {
		prefix = "fallen_angel_hero_proy_hit",
		to = 7,
		from = 1
	},
	lilith_infernal_base_decal_loop = {
		prefix = "fallen_angel_hero_infernal_base_decal",
		to = 24,
		from = 1
	},
	lilith_infernal_base_fireIn_loop = {
		prefix = "fallen_angel_hero_infernal_base_fireIn",
		to = 22,
		from = 1
	},
	lilith_infernal_fx_anim = {
		prefix = "fallen_angel_hero_infernal_fx",
		to = 5,
		from = 1
	},
	lilith_reapers_harvest_decal_anim = {
		prefix = "fallen_angel_hero_reapers_harvest_decal",
		to = 12,
		from = 1
	},
	lilith_soul_eater_ball_loop = {
		prefix = "fallen_angel_hero_soul_eater_ball",
		to = 6,
		from = 1
	},
	lilith_soul_eater_decal_loop = {
		prefix = "fallen_angel_hero_soul_eater_decal",
		to = 30,
		from = 1
	},
	lilith_soul_eater_explosion_anim = {
		prefix = "fallen_angel_hero_soul_eater_explosion",
		to = 9,
		from = 1
	},
	lilith_ultimate_angel_raise = {
		prefix = "fallen_angel_hero_ultimate_angel",
		to = 14,
		from = 1
	},
	lilith_ultimate_angel_idle = {
		prefix = "fallen_angel_hero_ultimate_angel",
		to = 15,
		from = 15
	},
	lilith_ultimate_angel_attack = {
		prefix = "fallen_angel_hero_ultimate_angel",
		to = 24,
		from = 15
	},
	lilith_ultimate_angel_death = {
		prefix = "fallen_angel_hero_ultimate_angel",
		to = 44,
		from = 35
	},
	lilith_ultimate_meteor_explosion = {
		prefix = "arivan_hero_fire_explosion",
		to = 14,
		from = 1
	},
	hero_bruce_idle = {
		prefix = "bruce_hero",
		to = 1,
		from = 1
	},
	hero_bruce_walk = {
		prefix = "bruce_hero",
		to = 17,
		from = 2
	},
	hero_bruce_attack = {
		prefix = "bruce_hero",
		to = 41,
		from = 18
	},
	hero_bruce_attack2 = {
		prefix = "bruce_hero",
		to = 57,
		from = 42
	},
	hero_bruce_attack3 = {
		prefix = "bruce_hero",
		to = 74,
		from = 58
	},
	hero_bruce_eat = {
		prefix = "bruce_hero",
		to = 110,
		from = 75
	},
	hero_bruce_specialAttack = {
		prefix = "bruce_hero",
		to = 143,
		from = 111
	},
	hero_bruce_death = {
		prefix = "bruce_hero",
		to = 183,
		from = 144
	},
	hero_bruce_respawn = {
		prefix = "bruce_hero",
		to = 207,
		from = 184
	},
	hero_bruce_levelup = {
		prefix = "bruce_hero",
		to = 207,
		from = 184
	},
	mod_bruce_kings_roar_loop = {
		prefix = "bruce_hero_stars",
		to = 10,
		from = 1
	},
	bruce_ultimate_walkingRightLeft = {
		prefix = "bruce_hero_ultimate",
		to = 8,
		from = 1
	},
	bruce_ultimate_walkingUp = {
		prefix = "bruce_hero_ultimate",
		to = 16,
		from = 9
	},
	bruce_ultimate_walkingDown = {
		prefix = "bruce_hero_ultimate",
		to = 24,
		from = 17
	},
	bruce_ultimate_boom = {
		prefix = "bruce_hero_ultimate",
		to = 41,
		from = 25
	},
	bruce_ultimate_twister_start = {
		prefix = "bruce_hero_ultimate_twister",
		to = 6,
		from = 1
	},
	bruce_ultimate_twister_loop = {
		prefix = "bruce_hero_ultimate_twister",
		to = 14,
		from = 7
	},
	bruce_ultimate_twister_end = {
		prefix = "bruce_hero_ultimate_twister",
		to = 24,
		from = 15
	},
	hero_lynn_idle = {
		prefix = "lynn_hero",
		to = 1,
		from = 1
	},
	hero_lynn_walk = {
		prefix = "lynn_hero",
		to = 6,
		from = 2
	},
	hero_lynn_hexfury = {
		prefix = "lynn_hero",
		to = 35,
		from = 7
	},
	hero_lynn_attack = {
		prefix = "lynn_hero",
		to = 58,
		from = 36
	},
	hero_lynn_attack2 = {
		prefix = "lynn_hero",
		to = 79,
		from = 59
	},
	hero_lynn_death = {
		prefix = "lynn_hero",
		to = 123,
		from = 80
	},
	hero_lynn_levelup = {
		prefix = "lynn_hero",
		to = 144,
		from = 124
	},
	hero_lynn_respawn = {
		prefix = "lynn_hero",
		to = 144,
		from = 124
	},
	hero_lynn_curseOfDespair = {
		prefix = "lynn_hero",
		to = 192,
		from = 145
	},
	hero_lynn_weakeningCurse = {
		prefix = "lynn_hero",
		to = 240,
		from = 193
	},
	mod_lynn_despair = {
		prefix = "lynn_hero_despair_fx_above",
		to = 26,
		from = 1
	},
	mod_lynn_despair_decal_loop = {
		prefix = "lynn_hero_despair_fx_decal",
		to = 34,
		from = 9
	},
	mod_lynn_ultimate = {
		prefix = "lynn_hero_ultimate_fx_above",
		to = 28,
		from = 1
	},
	mod_lynn_ultimate_decal_loop = {
		prefix = "lynn_hero_ultimate_fx_decal",
		to = 34,
		from = 9
	},
	mod_lynn_ultimate_over = {
		prefix = "lynn_hero_ultimate_fx_over",
		to = 12,
		from = 1
	},
	mod_lynn_weakening = {
		prefix = "lynn_hero_weakening_fx_above",
		to = 27,
		from = 1
	},
	mod_lynn_weakening_decal_loop = {
		prefix = "lynn_hero_weakening_fx_decal",
		to = 34,
		from = 9
	},
	fx_lynn_explosion = {
		prefix = "lynn_explosion",
		to = 21,
		from = 1
	},
	hero_phoenix_idle = {
		prefix = "phoenix_hero",
		to = 18,
		from = 1
	},
	hero_phoenix_attack = {
		prefix = "phoenix_hero",
		to = 54,
		from = 19
	},
	hero_phoenix_birdThrow = {
		prefix = "phoenix_hero",
		to = 78,
		from = 55
	},
	hero_phoenix_suicide = {
		prefix = "phoenix_hero",
		to = 116,
		from = 79
	},
	hero_phoenix_death = {
		prefix = "phoenix_hero",
		to = 138,
		from = 117
	},
	hero_phoenix_egg_spawn = {
		prefix = "phoenix_hero",
		to = 155,
		from = 139
	},
	hero_phoenix_egg_idle = {
		prefix = "phoenix_hero",
		to = 169,
		from = 156
	},
	hero_phoenix_respawn = {
		prefix = "phoenix_hero",
		to = 191,
		from = 170
	},
	hero_phoenix_shadow = {
		prefix = "phoenix_hero",
		to = 192,
		from = 192
	},
	hero_phoenix_explosion = {
		prefix = "phoenix_hero",
		to = 210,
		from = 193
	},
	ray_phoenix = {
		prefix = "phoenix_hero_proy",
		to = 12,
		from = 1
	},
	fx_ray_phoenix_hit = {
		prefix = "phoenix_hero_proy_hit",
		to = 16,
		from = 1
	},
	ps_missile_phoenix = {
		prefix = "phoenix_hero_bird_particle",
		to = 8,
		from = 1
	},
	decal_flaming_path_fire = {
		prefix = "phoenix_hero_towerBurn_towerFire",
		to = 14,
		from = 1
	},
	fx_flaming_path_start = {
		prefix = "phoenix_hero_towerBurn_fire_in",
		to = 10,
		from = 1
	},
	fx_flaming_path_end = {
		prefix = "phoenix_hero_towerBurn_fire_out",
		to = 8,
		from = 1
	},
	phoenix_ultimate_place = {
		prefix = "phoenix_hero_egg",
		to = 6,
		from = 1
	},
	phoenix_ultimate_activate = {
		prefix = "phoenix_hero_egg",
		to = 15,
		from = 7
	},
	hero_wilbur_layerX_idle = {
		layer_to = 4,
		from = 1,
		layer_prefix = "hero_wilburg_layer%i",
		to = 12,
		layer_from = 1
	},
	hero_wilbur_layerX_projectile = {
		layer_to = 4,
		from = 13,
		layer_prefix = "hero_wilburg_layer%i",
		to = 28,
		layer_from = 1
	},
	hero_wilbur_layerX_shoot = {
		layer_to = 4,
		from = 45,
		layer_prefix = "hero_wilburg_layer%i",
		to = 56,
		layer_from = 1
	},
	hero_wilbur_layerX_smokeStart = {
		layer_to = 4,
		from = 57,
		layer_prefix = "hero_wilburg_layer%i",
		to = 80,
		layer_from = 1
	},
	hero_wilbur_layerX_smokeLoop = {
		layer_to = 4,
		from = 81,
		layer_prefix = "hero_wilburg_layer%i",
		to = 89,
		layer_from = 1
	},
	hero_wilbur_layerX_smokeEnd = {
		layer_to = 4,
		from = 90,
		layer_prefix = "hero_wilburg_layer%i",
		to = 95,
		layer_from = 1
	},
	hero_wilbur_layerX_box = {
		layer_to = 4,
		from = 96,
		layer_prefix = "hero_wilburg_layer%i",
		to = 129,
		layer_from = 1
	},
	hero_wilbur_layerX_death = {
		layer_to = 4,
		from = 130,
		layer_prefix = "hero_wilburg_layer%i",
		to = 159,
		layer_from = 1
	},
	hero_wilbur_layerX_respawn = {
		layer_to = 4,
		from = 160,
		layer_prefix = "hero_wilburg_layer%i",
		to = 181,
		layer_from = 1
	},
	fx_shot_wilbur_flash = {
		prefix = "hero_wilburg_flash_shoot",
		to = 6,
		from = 1
	},
	fx_shot_wilbur_hit = {
		prefix = "hero_wilburg_shoot_floor",
		to = 12,
		from = 1
	},
	missile_wilbur_flying = {
		prefix = "hero_wilburg_missile",
		to = 3,
		from = 1
	},
	fx_wilbur_smoke_start = {
		prefix = "hero_wilburg_smoke",
		to = 12,
		from = 1
	},
	decal_wilbur_smoke = {
		prefix = "hero_wilburg_bomb_decal",
		to = 27,
		from = 1
	},
	box_wilbur_open = {
		prefix = "hero_wilburg_box_hit",
		to = 13,
		from = 1
	},
	fx_box_wilbur_smoke_a = {
		prefix = "hero_wilburg_box_hit_smoke_a",
		to = 11,
		from = 1
	},
	fx_box_wilbur_smoke_b = {
		prefix = "hero_wilburg_box_hit_smoke_b",
		to = 8,
		from = 1
	},
	bomb_wilbur_idle = {
		prefix = "hero_wilburg_bomb_box",
		to = 1,
		from = 1
	},
	bomb_wilbur_walkingRightLeft = {
		prefix = "hero_wilburg_bomb_box",
		to = 9,
		from = 1
	},
	bomb_wilbur_walkingUp = {
		prefix = "hero_wilburg_bomb_box",
		to = 18,
		from = 10
	},
	bomb_wilbur_walkingDown = {
		prefix = "hero_wilburg_bomb_box",
		to = 27,
		from = 19
	},
	bomb_wilbur_death = {
		prefix = "hero_wilburg_bomb_box",
		to = 48,
		from = 28
	},
	wilbur_drone_idle = {
		prefix = "hero_wilburg_drones",
		to = 14,
		from = 1
	},
	wilbur_drone_shoot = {
		prefix = "hero_wilburg_drones",
		to = 29,
		from = 15
	},
	gnoll_reaver_walkingRightLeft = {
		prefix = "gnoll_reaver",
		to = 21,
		from = 1
	},
	gnoll_reaver_walkingDown = {
		prefix = "gnoll_reaver",
		to = 43,
		from = 22
	},
	gnoll_reaver_walkingUp = {
		prefix = "gnoll_reaver",
		to = 65,
		from = 44
	},
	gnoll_reaver_idle = {
		prefix = "gnoll_reaver",
		to = 66,
		from = 66
	},
	gnoll_reaver_attack = {
		prefix = "gnoll_reaver",
		to = 83,
		from = 67
	},
	gnoll_reaver_death = {
		prefix = "gnoll_reaver",
		to = 99,
		from = 84
	},
	gnoll_reaver_respawn = {
		prefix = "gnoll_reaver",
		to = 66,
		from = 66
	},
	gnoll_burner_walkingRightLeft = {
		prefix = "gnoll_burner",
		to = 22,
		from = 1
	},
	gnoll_burner_walkingDown = {
		prefix = "gnoll_burner",
		to = 44,
		from = 23
	},
	gnoll_burner_walkingUp = {
		prefix = "gnoll_burner",
		to = 66,
		from = 45
	},
	gnoll_burner_idle = {
		prefix = "gnoll_burner",
		to = 78,
		from = 67
	},
	gnoll_burner_shoot = {
		prefix = "gnoll_burner",
		to = 100,
		from = 79
	},
	gnoll_burner_death = {
		prefix = "gnoll_burner",
		to = 126,
		from = 101
	},
	gnoll_burner_attack = {
		prefix = "gnoll_burner",
		to = 148,
		from = 127
	},
	gnoll_burner_respawn = {
		prefix = "gnoll_burner",
		to = 78,
		from = 67
	},
	torch_gnoll_burner = {
		prefix = "gnoll_burner_proy",
		to = 4,
		from = 1
	},
	fx_torch_gnoll_burner_explosion = {
		prefix = "Inferno_Flareon_Explosion",
		to = 13,
		from = 1
	},
	gnoll_gnawer_walkingRightLeft = {
		prefix = "gnoll_gnawer",
		to = 22,
		from = 1
	},
	gnoll_gnawer_walkingDown = {
		prefix = "gnoll_gnawer",
		to = 44,
		from = 23
	},
	gnoll_gnawer_walkingUp = {
		prefix = "gnoll_gnawer",
		to = 66,
		from = 45
	},
	gnoll_gnawer_idle = {
		prefix = "gnoll_gnawer",
		to = 67,
		from = 67
	},
	gnoll_gnawer_attack = {
		prefix = "gnoll_gnawer",
		to = 89,
		from = 68
	},
	gnoll_gnawer_death = {
		prefix = "gnoll_gnawer",
		to = 110,
		from = 90
	},
	gnoll_gnawer_drop = {
		prefix = "gnoll_gnawer",
		to = 128,
		from = 111
	},
	gnoll_gnawer_respawn = {
		prefix = "gnoll_gnawer",
		to = 67,
		from = 67
	},
	mod_gnoll_gnawer = {
		prefix = "gnoll_gnawer",
		to = 186,
		from = 171
	},
	gnoll_gnawer_flying_idle = {
		prefix = "gnoll_gnawer",
		to = 142,
		from = 129
	},
	gnoll_gnawer_flying_walkingRightLeft = {
		prefix = "gnoll_gnawer",
		to = 142,
		from = 129
	},
	gnoll_gnawer_flying_walkingDown = {
		prefix = "gnoll_gnawer",
		to = 156,
		from = 143
	},
	gnoll_gnawer_flying_walkingUp = {
		prefix = "gnoll_gnawer",
		to = 170,
		from = 157
	},
	gnoll_gnawer_flying_death = {
		prefix = "gnoll_gnawer",
		to = 128,
		from = 111
	},
	gnoll_blighter_idle = {
		prefix = "gnoll_blighter",
		to = 1,
		from = 1
	},
	gnoll_blighter_walkingRightLeft = {
		prefix = "gnoll_blighter",
		to = 31,
		from = 2
	},
	gnoll_blighter_walkingDown = {
		prefix = "gnoll_blighter",
		to = 61,
		from = 32
	},
	gnoll_blighter_walkingUp = {
		prefix = "gnoll_blighter",
		to = 91,
		from = 62
	},
	gnoll_blighter_attack = {
		prefix = "gnoll_blighter",
		to = 114,
		from = 92
	},
	gnoll_blighter_shoot = {
		prefix = "gnoll_blighter",
		to = 138,
		from = 115
	},
	gnoll_blighter_energy = {
		prefix = "gnoll_blighter",
		to = 168,
		from = 139
	},
	gnoll_blighter_death = {
		prefix = "gnoll_blighter",
		to = 183,
		from = 169
	},
	gnoll_blighter_attackPlants = {
		prefix = "gnoll_blighter",
		to = 206,
		from = 184
	},
	gnoll_blighter_respawn = {
		prefix = "gnoll_blighter",
		to = 1,
		from = 1
	},
	gnoll_blighter_energy_travel = {
		prefix = "gnoll_blighter_energy",
		to = 7,
		from = 1
	},
	gnoll_blighter_energy_travelUp = {
		prefix = "gnoll_blighter_energy",
		to = 17,
		from = 11
	},
	gnoll_blighter_energy_travelDown = {
		prefix = "gnoll_blighter_energy",
		to = 23,
		from = 18
	},
	gnoll_blighter_energy_hitUpDown = {
		prefix = "gnoll_blighter_energy",
		to = 26,
		from = 24
	},
	mod_gnoll_blighter = {
		prefix = "gnoll_blighter_plantBlock",
		to = 12,
		from = 1
	},
	hyena_idle = {
		prefix = "hyena",
		to = 1,
		from = 1
	},
	hyena_walkingRightLeft = {
		prefix = "hyena",
		to = 11,
		from = 2
	},
	hyena_walkingUp = {
		prefix = "hyena",
		to = 21,
		from = 12
	},
	hyena_walkingDown = {
		prefix = "hyena",
		to = 31,
		from = 22
	},
	hyena_runningRightLeft = {
		prefix = "hyena",
		to = 38,
		from = 32
	},
	hyena_runningUp = {
		prefix = "hyena",
		to = 45,
		from = 39
	},
	hyena_runningDown = {
		prefix = "hyena",
		to = 52,
		from = 46
	},
	hyena_death = {
		prefix = "hyena",
		to = 71,
		from = 53
	},
	ettin_idle = {
		prefix = "ettin",
		to = 1,
		from = 1
	},
	ettin_walkingRightLeft = {
		prefix = "ettin",
		to = 29,
		from = 2
	},
	ettin_walkingDown = {
		prefix = "ettin",
		to = 57,
		from = 30
	},
	ettin_walkingUp = {
		prefix = "ettin",
		to = 84,
		from = 58
	},
	ettin_attack = {
		prefix = "ettin",
		to = 108,
		from = 85
	},
	ettin_insaneStart = {
		prefix = "ettin",
		to = 142,
		from = 109
	},
	ettin_insaneLoop = {
		prefix = "ettin",
		to = 162,
		from = 143
	},
	ettin_death = {
		prefix = "ettin",
		to = 186,
		from = 163
	},
	perython_idle = {
		prefix = "perython",
		to = 14,
		from = 1
	},
	perython_walkingRightLeft = {
		prefix = "perython",
		to = 14,
		from = 1
	},
	perython_walkingDown = {
		prefix = "perython",
		to = 28,
		from = 15
	},
	perython_walkingUp = {
		prefix = "perython",
		to = 42,
		from = 29
	},
	perython_death = {
		prefix = "perython",
		to = 60,
		from = 43
	},
	perython_shadow = {
		prefix = "perython",
		to = 61,
		from = 61
	},
	harraser_idle = {
		prefix = "harraser",
		to = 1,
		from = 1
	},
	harraser_walkingRightLeft = {
		prefix = "harraser",
		to = 23,
		from = 2
	},
	harraser_attack = {
		prefix = "harraser",
		to = 48,
		from = 24
	},
	harraser_shoot_start = {
		prefix = "harraser",
		to = 58,
		from = 49
	},
	harraser_shoot_loop = {
		prefix = "harraser",
		to = 67,
		from = 63
	},
	harraser_shoot_end = {
		prefix = "harraser",
		to = 82,
		from = 72
	},
	harraser_shadow_shot = {
		prefix = "harraser",
		ranges = {
			{
				49,
				58
			},
			{
				63,
				67
			},
			{
				72,
				82
			}
		}
	},
	harraser_jumpOut = {
		prefix = "harraser",
		to = 96,
		from = 83
	},
	harraser_jumpIn = {
		prefix = "harraser",
		to = 110,
		from = 97
	},
	harraser_death = {
		prefix = "harraser",
		to = 123,
		from = 111
	},
	harraser_walkingUp = {
		prefix = "harraser",
		to = 145,
		from = 124
	},
	harraser_walkingDown = {
		prefix = "harraser",
		to = 167,
		from = 146
	},
	catapult_running = {
		prefix = "catapult-f",
		to = 15,
		from = 1
	},
	catapult_idle = {
		prefix = "catapult-f",
		to = 16,
		from = 16
	},
	catapult_shoot = {
		prefix = "catapult-f",
		to = 97,
		from = 17
	},
	catapult_death = {
		prefix = "catapult-f",
		to = 116,
		from = 98
	},
	bandersnatch_idle = {
		prefix = "bandersnatch",
		to = 1,
		from = 1
	},
	bandersnatch_idle2ball = {
		prefix = "bandersnatch",
		to = 9,
		from = 2
	},
	bandersnatch_ball2idle = {
		prefix = "bandersnatch",
		to = 17,
		from = 10
	},
	bandersnatch_walkingRightLeft = {
		prefix = "bandersnatch",
		to = 41,
		from = 18
	},
	bandersnatch_walkingUp = {
		prefix = "bandersnatch",
		to = 65,
		from = 42
	},
	bandersnatch_walkingDown = {
		prefix = "bandersnatch",
		to = 89,
		from = 66
	},
	bandersnatch_attack = {
		prefix = "bandersnatch",
		to = 114,
		from = 90
	},
	bandersnatch_spineAttack = {
		prefix = "bandersnatch",
		to = 179,
		from = 115
	},
	bandersnatch_death = {
		prefix = "bandersnatch",
		to = 196,
		from = 180
	},
	bandersnatch_spine_ground = {
		prefix = "bandersnatch_spine",
		to = 7,
		from = 1
	},
	bandersnatch_spines_blood = {
		prefix = "bandersnatch_spines_blood",
		to = 8,
		from = 1
	},
	fungusRider_small_idle = {
		prefix = "fungusRider_small",
		to = 1,
		from = 1
	},
	fungusRider_small_walkingRightLeft = {
		prefix = "fungusRider_small",
		to = 19,
		from = 2
	},
	fungusRider_small_walkingDown = {
		prefix = "fungusRider_small",
		to = 37,
		from = 20
	},
	fungusRider_small_walkingUp = {
		prefix = "fungusRider_small",
		to = 55,
		from = 38
	},
	fungusRider_small_death = {
		prefix = "fungusRider_small",
		to = 86,
		from = 56
	},
	fungusRider_small_raise = {
		prefix = "fungusRider_small",
		to = 133,
		from = 112
	},
	fungusRider_medium_idle = {
		prefix = "fungusRider_medium",
		to = 1,
		from = 1
	},
	fungusRider_medium_walkingRightLeft = {
		prefix = "fungusRider_medium",
		to = 14,
		from = 2
	},
	fungusRider_medium_walkingDown = {
		prefix = "fungusRider_medium",
		to = 27,
		from = 15
	},
	fungusRider_medium_walkingUp = {
		prefix = "fungusRider_medium",
		to = 40,
		from = 28
	},
	fungusRider_medium_attack = {
		prefix = "fungusRider_medium",
		to = 62,
		from = 41
	},
	fungusRider_medium_death = {
		prefix = "fungusRider_medium",
		to = 119,
		from = 63
	},
	fungusRider_idle = {
		prefix = "fungusRider",
		to = 16,
		from = 1
	},
	fungusRider_walkingRightLeft = {
		prefix = "fungusRider",
		to = 34,
		from = 17
	},
	fungusRider_walkingDown = {
		prefix = "fungusRider",
		to = 52,
		from = 35
	},
	fungusRider_walkingUp = {
		prefix = "fungusRider",
		to = 70,
		from = 53
	},
	fungusRider_attack = {
		prefix = "fungusRider",
		to = 96,
		from = 71
	},
	fungusRider_cast = {
		prefix = "fungusRider",
		to = 132,
		from = 97
	},
	fungusRider_death = {
		prefix = "fungusRider",
		to = 176,
		from = 133
	},
	gloomy_idle = {
		prefix = "gloomy",
		to = 1,
		from = 1
	},
	gloomy_walkingRightLeft = {
		prefix = "gloomy",
		to = 16,
		from = 1
	},
	gloomy_walkingDown = {
		prefix = "gloomy",
		to = 32,
		from = 17
	},
	gloomy_walkingUp = {
		prefix = "gloomy",
		to = 48,
		from = 33
	},
	gloomy_death = {
		prefix = "gloomy",
		to = 60,
		from = 49
	},
	gloomy_castClone = {
		prefix = "gloomy",
		to = 74,
		from = 61
	},
	gloomy_spawnClone = {
		prefix = "gloomy",
		to = 89,
		from = 75
	},
	gloomy_shadow = {
		prefix = "gloomy",
		to = 90,
		from = 90
	},
	gloomy_idle = {
		prefix = "gloomy",
		to = 106,
		from = 91
	},
	redcap_idle = {
		prefix = "redcap",
		to = 1,
		from = 1
	},
	redcap_walkingRightLeft = {
		prefix = "redcap",
		to = 23,
		from = 2
	},
	redcap_walkingUp = {
		prefix = "redcap",
		to = 45,
		from = 24
	},
	redcap_walkingDown = {
		prefix = "redcap",
		to = 67,
		from = 46
	},
	redcap_attack = {
		prefix = "redcap",
		to = 91,
		from = 68
	},
	redcap_special = {
		prefix = "redcap",
		to = 123,
		from = 92
	},
	redcap_death = {
		prefix = "redcap",
		to = 148,
		from = 124
	},
	fx_redcap_death_blow = {
		prefix = "redcap_hitFx",
		to = 15,
		from = 1
	},
	satyr_idle = {
		prefix = "satyr",
		to = 1,
		from = 1
	},
	satyr_walkingRightLeft = {
		prefix = "satyr",
		to = 21,
		from = 2
	},
	satyr_walkingDown = {
		prefix = "satyr",
		to = 41,
		from = 22
	},
	satyr_walkingUp = {
		prefix = "satyr",
		to = 61,
		from = 42
	},
	satyr_attack = {
		prefix = "satyr",
		to = 82,
		from = 62
	},
	satyr_shoot = {
		prefix = "satyr",
		to = 104,
		from = 83
	},
	satyr_shoot_start = {
		prefix = "satyr",
		to = 83,
		from = 83
	},
	satyr_shoot_loop = {
		prefix = "satyr",
		to = 104,
		from = 83
	},
	satyr_shoot_end = {
		prefix = "satyr",
		to = 104,
		from = 104
	},
	satyr_death = {
		prefix = "satyr",
		to = 119,
		from = 105
	},
	satyr_raise = {
		prefix = "satyr",
		to = 133,
		from = 120
	},
	fx_knife_satyr_hit = {
		prefix = "proy_mirage",
		to = 8,
		from = 2
	},
	satyrHoplite_idle = {
		prefix = "satyrHoplite",
		to = 1,
		from = 1
	},
	satyrHoplite_walkingRightLeft = {
		prefix = "satyrHoplite",
		to = 23,
		from = 2
	},
	satyrHoplite_walkingDown = {
		prefix = "satyrHoplite",
		to = 45,
		from = 24
	},
	satyrHoplite_walkingUp = {
		prefix = "satyrHoplite",
		to = 67,
		from = 46
	},
	satyrHoplite_attack = {
		prefix = "satyrHoplite",
		to = 92,
		from = 68
	},
	satyrHoplite_cast = {
		prefix = "satyrHoplite",
		to = 147,
		from = 93
	},
	satyrHoplite_death = {
		prefix = "satyrHoplite",
		to = 163,
		from = 148
	},
	twilight_avenger_idle = {
		prefix = "twilight_avenger",
		to = 1,
		from = 1
	},
	twilight_avenger_walkingRightLeft = {
		prefix = "twilight_avenger",
		to = 23,
		from = 2
	},
	twilight_avenger_walkingDown = {
		prefix = "twilight_avenger",
		to = 45,
		from = 24
	},
	twilight_avenger_walkingUp = {
		prefix = "twilight_avenger",
		to = 67,
		from = 46
	},
	twilight_avenger_attack = {
		prefix = "twilight_avenger",
		to = 92,
		from = 68
	},
	twilight_avenger_cast = {
		prefix = "twilight_avenger",
		to = 125,
		from = 93
	},
	twilight_avenger_death = {
		prefix = "twilight_avenger",
		to = 163,
		from = 126
	},
	mod_twilight_avenger_last_service_big = {
		prefix = "twilight_avenger_effect_big",
		to = 20,
		from = 1
	},
	mod_twilight_avenger_last_service_small = {
		prefix = "twilight_avenger_effect_small",
		to = 20,
		from = 1
	},
	fx_twilight_avenger_explosion = {
		prefix = "twilight_avenger_explosion",
		to = 21,
		from = 1
	},
	scourger_walkingRightLeft = {
		prefix = "scourger",
		to = 20,
		from = 1
	},
	scourger_walkingDown = {
		prefix = "scourger",
		to = 40,
		from = 21
	},
	scourger_walkingUp = {
		prefix = "scourger",
		to = 60,
		from = 41
	},
	scourger_idle = {
		prefix = "scourger",
		to = 61,
		from = 61
	},
	scourger_death = {
		prefix = "scourger",
		to = 74,
		from = 62
	},
	scourger_special = {
		prefix = "scourger",
		to = 103,
		from = 75
	},
	scourger_attack = {
		prefix = "scourger",
		to = 127,
		from = 104
	},
	scourger_shadow_idle = {
		prefix = "scourger_shadow",
		to = 1,
		from = 1
	},
	scourger_shadow_walkingRightLeft = {
		prefix = "scourger_shadow",
		to = 20,
		from = 1
	},
	scourger_shadow_walkingDown = {
		prefix = "scourger_shadow",
		to = 40,
		from = 21
	},
	scourger_shadow_walkingUp = {
		prefix = "scourger_shadow",
		to = 60,
		from = 41
	},
	scourger_shadow_death = {
		prefix = "scourger_shadow",
		to = 74,
		from = 61
	},
	scourger_shadow_particle = {
		prefix = "scourger_shadow_particle",
		to = 10,
		from = 1
	},
	mod_twilight_scourger_lash_big = {
		prefix = "scourger_buff_big",
		to = 12,
		from = 1
	},
	mod_twilight_scourger_lash_small = {
		prefix = "scourger_buff_small",
		to = 12,
		from = 1
	},
	fx_twilight_scourger_lash = {
		prefix = "scourger_special",
		to = 16,
		from = 1
	},
	mod_twilight_scourger_banshee_base = {
		prefix = "scourger_towerDebuff",
		to = 9,
		from = 1
	},
	mod_twilight_scourger_banshee_fx = {
		prefix = "scourger_towerDebuff_fx",
		to = 12,
		from = 1
	},
	fx_twilight_scourger_banshee_end = {
		prefix = "scourger_towerDebuff_end",
		to = 6,
		from = 1
	},
	webspitting_spider_idle = {
		prefix = "webspitterSpider",
		to = 1,
		from = 1
	},
	webspitting_spider_walkingRightLeft = {
		prefix = "webspitterSpider",
		to = 10,
		from = 2
	},
	webspitting_spider_walkingDown = {
		prefix = "webspitterSpider",
		to = 20,
		from = 11
	},
	webspitting_spider_walkingUp = {
		prefix = "webspitterSpider",
		to = 30,
		from = 21
	},
	webspitting_spider_attack = {
		prefix = "webspitterSpider",
		to = 49,
		from = 31
	},
	webspitting_spider_spitWeb = {
		prefix = "webspitterSpider",
		to = 72,
		from = 50
	},
	webspitting_spider_death = {
		prefix = "webspitterSpider",
		to = 85,
		from = 73
	},
	mod_spider_web_start = {
		prefix = "webspitterSpider_web-f",
		to = 9,
		from = 1
	},
	mod_spider_web_loop = {
		prefix = "webspitterSpider_web-f",
		to = 10,
		from = 10
	},
	mod_spider_web_end = {
		prefix = "webspitterSpider_web-f",
		to = 16,
		from = 11
	},
	sword_spider_walkingRightLeft = {
		prefix = "sword_spider",
		to = 9,
		from = 1
	},
	sword_spider_walkingDown = {
		prefix = "sword_spider",
		to = 18,
		from = 10
	},
	sword_spider_walkingUp = {
		prefix = "sword_spider",
		to = 27,
		from = 19
	},
	sword_spider_idle = {
		prefix = "sword_spider",
		to = 28,
		from = 28
	},
	sword_spider_attack = {
		prefix = "sword_spider",
		to = 45,
		from = 29
	},
	sword_spider_death = {
		prefix = "sword_spider",
		to = 60,
		from = 46
	},
	rabbit_idle = {
		prefix = "rabbit",
		to = 8,
		from = 8
	},
	rabbit_walkingRightLeft = {
		prefix = "rabbit",
		to = 11,
		from = 1
	},
	rabbit_walkingUp = {
		prefix = "rabbit",
		to = 22,
		from = 12
	},
	rabbit_walkingDown = {
		prefix = "rabbit",
		to = 33,
		from = 23
	},
	rabbit_death = {
		prefix = "rabbit",
		to = 44,
		from = 34
	},
	twilight_evoker_idle = {
		prefix = "twilight_evoker",
		to = 1,
		from = 1
	},
	twilight_evoker_walkingRightLeft = {
		prefix = "twilight_evoker",
		to = 17,
		from = 2
	},
	twilight_evoker_walkingDown = {
		prefix = "twilight_evoker",
		to = 33,
		from = 18
	},
	twilight_evoker_walkingUp = {
		prefix = "twilight_evoker",
		to = 49,
		from = 34
	},
	twilight_evoker_death = {
		prefix = "twilight_evoker",
		to = 75,
		from = 50
	},
	twilight_evoker_shoot = {
		prefix = "twilight_evoker",
		to = 94,
		from = 76
	},
	twilight_evoker_attack = {
		prefix = "twilight_evoker",
		to = 115,
		from = 95
	},
	twilight_evoker_heal = {
		prefix = "twilight_evoker",
		to = 144,
		from = 116
	},
	twilight_evoker_towerAttack = {
		prefix = "twilight_evoker",
		to = 181,
		from = 145
	},
	bullet_twilight_evoker_hit = {
		prefix = "twilight_evoker_bolt",
		to = 9,
		from = 2
	},
	mod_twilight_evoker_silence_1 = {
		prefix = "twilight_evoker_towerFx1",
		to = 18,
		from = 1
	},
	mod_twilight_evoker_silence_2 = {
		prefix = "twilight_evoker_towerFx2",
		to = 14,
		from = 1
	},
	mod_twilight_evoker_heal_big = {
		prefix = "twilight_evoker_healFx_big",
		to = 25,
		from = 1
	},
	mod_twilight_evoker_heal_small = {
		prefix = "twilight_evoker_healFx_small",
		to = 25,
		from = 1
	},
	twilight_golem_idle = {
		prefix = "gollem",
		to = 30,
		from = 1
	},
	twilight_golem_walkingRightLeft = {
		prefix = "gollem",
		to = 30,
		from = 1
	},
	twilight_golem_walkingDown = {
		prefix = "gollem",
		to = 60,
		from = 31
	},
	twilight_golem_walkingUp = {
		prefix = "gollem",
		to = 90,
		from = 61
	},
	twilight_golem_attack = {
		prefix = "gollem",
		to = 118,
		from = 91
	},
	twilight_golem_death = {
		prefix = "gollem",
		to = 146,
		from = 119
	},
	twilight_heretic_idle = {
		prefix = "twilight_heretic",
		to = 16,
		from = 1
	},
	twilight_heretic_walkingRightLeft = {
		prefix = "twilight_heretic",
		to = 36,
		from = 17
	},
	twilight_heretic_walkingDown = {
		prefix = "twilight_heretic",
		to = 56,
		from = 37
	},
	twilight_heretic_walkingUp = {
		prefix = "twilight_heretic",
		to = 76,
		from = 57
	},
	twilight_heretic_attack = {
		prefix = "twilight_heretic",
		to = 90,
		from = 77
	},
	twilight_heretic_shoot = {
		prefix = "twilight_heretic",
		to = 113,
		from = 91
	},
	twilight_heretic_death = {
		prefix = "twilight_heretic",
		to = 148,
		from = 114
	},
	twilight_heretic_consumeStart = {
		prefix = "twilight_heretic",
		to = 168,
		from = 149
	},
	twilight_heretic_consumeLoop = {
		prefix = "twilight_heretic",
		to = 178,
		from = 169
	},
	twilight_heretic_consumeEnd = {
		prefix = "twilight_heretic",
		to = 197,
		from = 179
	},
	twilight_heretic_shadowCast = {
		prefix = "twilight_heretic",
		to = 224,
		from = 198
	},
	twilight_heretic_flyingRightLeft = {
		prefix = "twilight_heretic",
		to = 244,
		from = 225
	},
	twilight_heretic_flyingDown = {
		prefix = "twilight_heretic",
		to = 264,
		from = 245
	},
	twilight_heretic_flyingUp = {
		prefix = "twilight_heretic",
		to = 284,
		from = 265
	},
	twilight_heretic_fire = {
		prefix = "twilight_heretic",
		to = 300,
		from = 285
	},
	fx_bullet_twilight_heretic_hit = {
		prefix = "twilight_heretic_proy",
		to = 9,
		from = 2
	},
	mod_twilight_heretic_servant_start = {
		prefix = "twilight_heretic_shadow",
		to = 16,
		from = 1
	},
	mod_twilight_heretic_servant_loop = {
		prefix = "twilight_heretic_shadow",
		to = 34,
		from = 17
	},
	bullet_twilight_heretic_particle_1 = {
		prefix = "twilight_heretic_proy_particle1",
		to = 8,
		from = 1
	},
	bullet_twilight_heretic_particle_2 = {
		prefix = "twilight_heretic_proy_particle2",
		to = 8,
		from = 1
	},
	fx_twilight_heretic_consume = {
		prefix = "twilight_heretic_consumeFx",
		to = 14,
		from = 1
	},
	twilight_heretic_consume_ball_particle = {
		prefix = "twilight_heretic_consumeProy_particle",
		to = 6,
		from = 1
	},
	drider_idle = {
		prefix = "drider",
		to = 1,
		from = 1
	},
	drider_walkingRightLeft = {
		prefix = "drider",
		to = 10,
		from = 2
	},
	drider_walkingDown = {
		prefix = "drider",
		to = 19,
		from = 11
	},
	drider_walkingUp = {
		prefix = "drider",
		to = 28,
		from = 20
	},
	drider_attack = {
		prefix = "drider",
		to = 47,
		from = 29
	},
	drider_death = {
		prefix = "drider",
		to = 65,
		from = 48
	},
	drider_raise = {
		prefix = "drider",
		to = 81,
		from = 66
	},
	drider_poison = {
		prefix = "drider",
		to = 106,
		from = 82
	},
	mod_drider_poison = {
		prefix = "drider_creepFx",
		to = 12,
		from = 1
	},
	decal_drider_cocoon_start = {
		prefix = "drider_cocoon_big",
		to = 30,
		from = 1
	},
	decal_drider_cocoon_end = {
		prefix = "drider_cocoon_big",
		to = 34,
		from = 30
	},
	mantaray_walkingRightLeft = {
		prefix = "mantaray",
		to = 32,
		from = 1
	},
	mantaray_walkingDown = {
		prefix = "mantaray",
		to = 64,
		from = 33
	},
	mantaray_walkingUp = {
		prefix = "mantaray",
		to = 96,
		from = 65
	},
	mantaray_idle = {
		prefix = "mantaray",
		to = 126,
		from = 97
	},
	mantaray_prepareToFly = {
		prefix = "mantaray",
		to = 128,
		from = 127
	},
	mantaray_jump = {
		prefix = "mantaray",
		to = 130,
		from = 129
	},
	mantaray_bite = {
		prefix = "mantaray",
		to = 146,
		from = 131
	},
	mantaray_explode = {
		prefix = "mantaray",
		to = 160,
		from = 147
	},
	mantaray_death = {
		prefix = "mantaray",
		to = 174,
		from = 161
	},
	mantaray_raise = {
		prefix = "mantaray",
		to = 202,
		from = 175
	},
	mantaray_spawnToWalking = {
		prefix = "mantaray",
		to = 210,
		from = 203
	},
	fx_mantaray_spawn = {
		prefix = "mantaray",
		to = 224,
		from = 211
	},
	razorboar_idle = {
		prefix = "razorboar",
		to = 1,
		from = 1
	},
	razorboar_walkingRightLeft = {
		prefix = "razorboar",
		to = 17,
		from = 2
	},
	razorboar_walkingDown = {
		prefix = "razorboar",
		to = 33,
		from = 18
	},
	razorboar_walkingUp = {
		prefix = "razorboar",
		to = 49,
		from = 34
	},
	razorboar_attack = {
		prefix = "razorboar",
		to = 65,
		from = 50
	},
	razorboar_death = {
		prefix = "razorboar",
		to = 82,
		from = 66
	},
	razorboar_runningRightLeft = {
		prefix = "razorboar",
		to = 90,
		from = 83
	},
	razorboar_runningDown = {
		prefix = "razorboar",
		to = 98,
		from = 91
	},
	razorboar_runningUp = {
		prefix = "razorboar",
		to = 106,
		from = 99
	},
	mod_razorboar_rampage = {
		prefix = "razorboar_hitFx",
		to = 25,
		from = 1
	},
	razorboar_rampage_particle = {
		prefix = "razorboar_fire_particle",
		to = 10,
		from = 1
	},
	arachnomancer_idle = {
		prefix = "arachnomancer",
		to = 1,
		from = 1
	},
	arachnomancer_walkingRightLeft = {
		prefix = "arachnomancer",
		to = 17,
		from = 2
	},
	arachnomancer_walkingDown = {
		prefix = "arachnomancer",
		to = 33,
		from = 18
	},
	arachnomancer_walkingUp = {
		prefix = "arachnomancer",
		to = 49,
		from = 34
	},
	arachnomancer_attack = {
		prefix = "arachnomancer",
		to = 73,
		from = 50
	},
	arachnomancer_summon = {
		prefix = "arachnomancer",
		to = 109,
		from = 74
	},
	arachnomancer_death = {
		prefix = "arachnomancer",
		to = 147,
		from = 110
	},
	arachnomancer_webspawn_big = {
		prefix = "arachnomancer_webSpawn_big",
		to = 16,
		from = 1
	},
	arachnomancer_webspawn_small = {
		prefix = "arachnomancer_webSpawn_small",
		to = 16,
		from = 1
	},
	arachnomancer_mini_spider_idle = {
		prefix = "arachnomancer_miniSpider",
		to = 1,
		from = 1
	},
	arachnomancer_mini_spider_walkingRightLeft = {
		prefix = "arachnomancer_miniSpider",
		to = 11,
		from = 2
	},
	arachnomancer_mini_spider_walkingDown = {
		prefix = "arachnomancer_miniSpider",
		to = 21,
		from = 12
	},
	arachnomancer_mini_spider_walkingUp = {
		prefix = "arachnomancer_miniSpider",
		to = 31,
		from = 22
	},
	arachnomancer_mini_spider_death = {
		prefix = "arachnomancer_miniSpider",
		to = 41,
		from = 32
	},
	arachnomancer_spider_idle = {
		prefix = "arachnomancer_spider",
		to = 1,
		from = 1
	},
	arachnomancer_spider_walkingRightLeft = {
		prefix = "arachnomancer_spider",
		to = 10,
		from = 2
	},
	arachnomancer_spider_walkingDown = {
		prefix = "arachnomancer_spider",
		to = 19,
		from = 11
	},
	arachnomancer_spider_walkingUp = {
		prefix = "arachnomancer_spider",
		to = 28,
		from = 20
	},
	arachnomancer_spider_attack = {
		prefix = "arachnomancer_spider",
		to = 43,
		from = 29
	},
	arachnomancer_spider_death = {
		prefix = "arachnomancer_spider",
		to = 53,
		from = 44
	},
	arachnomancer_spider_raise = {
		prefix = "arachnomancer_spider",
		to = 59,
		from = 54
	},
	son_of_mactans_idle = {
		prefix = "son_of_mactans",
		to = 1,
		from = 1
	},
	son_of_mactans_walkingRightLeft = {
		prefix = "son_of_mactans",
		to = 10,
		from = 2
	},
	son_of_mactans_walkingDown = {
		prefix = "son_of_mactans",
		to = 19,
		from = 11
	},
	son_of_mactans_walkingUp = {
		prefix = "son_of_mactans",
		to = 28,
		from = 20
	},
	son_of_mactans_attack = {
		prefix = "son_of_mactans",
		to = 49,
		from = 29
	},
	son_of_mactans_death = {
		prefix = "son_of_mactans",
		to = 62,
		from = 50
	},
	son_of_mactans_netDescend = {
		prefix = "son_of_mactans",
		to = 72,
		from = 63
	},
	son_of_mactans_raise = {
		prefix = "son_of_mactans",
		to = 92,
		from = 73
	},
	son_of_mactans_thread_1_idle = {
		prefix = "son_of_mactans_particles",
		to = 1,
		from = 1
	},
	son_of_mactans_thread_1_dissolve = {
		prefix = "son_of_mactans_particles",
		to = 9,
		from = 1
	},
	son_of_mactans_thread_2_idle = {
		prefix = "son_of_mactans_particles",
		to = 10,
		from = 10
	},
	son_of_mactans_thread_2_dissolve = {
		prefix = "son_of_mactans_particles",
		to = 18,
		from = 10
	},
	bloodsydianWarlock_idle = {
		prefix = "bloodsydianWarlock",
		to = 1,
		from = 1
	},
	bloodsydianWarlock_walkingRightLeft = {
		prefix = "bloodsydianWarlock",
		to = 25,
		from = 2
	},
	bloodsydianWarlock_walkingDown = {
		prefix = "bloodsydianWarlock",
		to = 49,
		from = 26
	},
	bloodsydianWarlock_walkingUp = {
		prefix = "bloodsydianWarlock",
		to = 73,
		from = 50
	},
	bloodsydianWarlock_attack = {
		prefix = "bloodsydianWarlock",
		to = 101,
		from = 74
	},
	bloodsydianWarlock_convert = {
		prefix = "bloodsydianWarlock",
		to = 138,
		from = 102
	},
	bloodsydianWarlock_death = {
		prefix = "bloodsydianWarlock",
		to = 180,
		from = 139
	},
	bloodsydianGnoll_respawn_start = {
		prefix = "bloodsydianGnoll",
		to = 117,
		from = 102
	},
	bloodsydianGnoll_respawn_end = {
		prefix = "bloodsydianGnoll",
		to = 140,
		from = 118
	},
	bloodsydianGnoll_idle = {
		prefix = "bloodsydianGnoll",
		to = 1,
		from = 1
	},
	bloodsydianGnoll_walkingRightLeft = {
		prefix = "bloodsydianGnoll",
		to = 17,
		from = 2
	},
	bloodsydianGnoll_walkingDown = {
		prefix = "bloodsydianGnoll",
		to = 33,
		from = 18
	},
	bloodsydianGnoll_walkingUp = {
		prefix = "bloodsydianGnoll",
		to = 49,
		from = 34
	},
	bloodsydianGnoll_attack = {
		prefix = "bloodsydianGnoll",
		to = 66,
		from = 50
	},
	bloodsydianGnoll_death = {
		prefix = "bloodsydianGnoll",
		to = 101,
		from = 67
	},
	perython_rock_idle = {
		prefix = "perython_rock",
		to = 14,
		from = 1
	},
	perython_rock_walkingUp = {
		prefix = "perython_rock",
		to = 42,
		from = 29
	},
	perython_rock_walkingDown = {
		prefix = "perython_rock",
		to = 28,
		from = 15
	},
	perython_rock_walkingRightLeft = {
		prefix = "perython_rock",
		to = 14,
		from = 1
	},
	perython_rock_death = {
		prefix = "perython_rock",
		to = 43,
		from = 43
	},
	perython_rock_drop = {
		prefix = "perython_rock",
		to = 49,
		from = 43
	},
	ogre_mage_idle = {
		prefix = "ogre_mage",
		to = 1,
		from = 1
	},
	ogre_mage_walkingRightLeft = {
		prefix = "ogre_mage",
		to = 29,
		from = 2
	},
	ogre_mage_walkingDown = {
		prefix = "ogre_mage",
		to = 57,
		from = 30
	},
	ogre_mage_walkingUp = {
		prefix = "ogre_mage",
		to = 85,
		from = 58
	},
	ogre_mage_attack = {
		prefix = "ogre_mage",
		to = 121,
		from = 86
	},
	ogre_mage_death = {
		prefix = "ogre_mage",
		to = 143,
		from = 122
	},
	ogre_mage_aura = {
		prefix = "ogre_mage_aura",
		to = 23,
		from = 1
	},
	ogre_mage_proy_flying = {
		prefix = "ogre_mage_proy",
		to = 2,
		from = 1
	},
	ogre_mage_shield_damage = {
		prefix = "ogre_mage_damage",
		to = 19,
		from = 1
	},
	ogre_mage_shield = {
		prefix = "ogre_mage_shield",
		to = 1,
		from = 1
	},
	fx_bolt_ogre_magi_hit = {
		prefix = "ogre_mage_proyHit",
		to = 23,
		from = 1
	},
	fx_bolt_ogre_magi_hit_air = {
		prefix = "ogre_mage_explosion_air",
		to = 23,
		from = 1
	},
	bloodServant_idle = {
		prefix = "bloodServant",
		to = 1,
		from = 1
	},
	bloodServant_walkingRightLeft = {
		prefix = "bloodServant",
		to = 11,
		from = 2
	},
	bloodServant_walkingUp = {
		prefix = "bloodServant",
		to = 21,
		from = 12
	},
	bloodServant_walkingDown = {
		prefix = "bloodServant",
		to = 31,
		from = 22
	},
	bloodServant_attack = {
		prefix = "bloodServant",
		to = 46,
		from = 32
	},
	bloodServant_death = {
		prefix = "bloodServant",
		to = 71,
		from = 47
	},
	mountedAvenger_idle = {
		prefix = "mountedAvenger",
		to = 1,
		from = 1
	},
	mountedAvenger_walkingRightLeft = {
		prefix = "mountedAvenger",
		to = 10,
		from = 2
	},
	mountedAvenger_walkingDown = {
		prefix = "mountedAvenger",
		to = 19,
		from = 11
	},
	mountedAvenger_walkingUp = {
		prefix = "mountedAvenger",
		to = 28,
		from = 20
	},
	mountedAvenger_attack = {
		prefix = "mountedAvenger",
		to = 47,
		from = 29
	},
	mountedAvenger_death = {
		prefix = "mountedAvenger",
		to = 94,
		from = 48
	},
	screecher_bat_idle = {
		prefix = "screecher_bat",
		to = 14,
		from = 1
	},
	screecher_bat_walkingRightLeft = {
		prefix = "screecher_bat",
		to = 14,
		from = 1
	},
	screecher_bat_walkingDown = {
		prefix = "screecher_bat",
		to = 28,
		from = 15
	},
	screecher_bat_walkingUp = {
		prefix = "screecher_bat",
		to = 42,
		from = 29
	},
	screecher_bat_attack = {
		prefix = "screecher_bat",
		to = 71,
		from = 43
	},
	screecher_bat_death = {
		prefix = "screecher_bat",
		to = 86,
		from = 72
	},
	mod_screecher_bat_stun_loop = {
		prefix = "screecher_bat_stun",
		to = 26,
		from = 1
	},
	dark_spitters_idle = {
		prefix = "dark_spitters",
		to = 1,
		from = 1
	},
	dark_spitters_walkingRightLeft = {
		prefix = "dark_spitters",
		to = 29,
		from = 2
	},
	dark_spitters_walkingDown = {
		prefix = "dark_spitters",
		to = 57,
		from = 30
	},
	dark_spitters_walkingUp = {
		prefix = "dark_spitters",
		to = 85,
		from = 58
	},
	dark_spitters_shoot = {
		prefix = "dark_spitters",
		to = 104,
		from = 86
	},
	dark_spitters_death = {
		prefix = "dark_spitters",
		to = 131,
		from = 105
	},
	dark_spitters_attack = {
		prefix = "dark_spitters",
		to = 148,
		from = 132
	},
	dark_spitters_proy = {
		prefix = "dark_spitters_projectile",
		to = 7,
		from = 1
	},
	mod_dark_spitters = {
		prefix = "dark_spitters_modifier",
		to = 12,
		from = 1
	},
	fx_bullet_dark_spitters_miss = {
		prefix = "dark_spitters_projectile_decal",
		to = 11,
		from = 1
	},
	shadow_spawn_idle = {
		prefix = "shadow_spawn",
		to = 1,
		from = 1
	},
	shadow_spawn_walkingRightLeft = {
		prefix = "shadow_spawn",
		to = 17,
		from = 2
	},
	shadow_spawn_walkingDown = {
		prefix = "shadow_spawn",
		to = 33,
		from = 18
	},
	shadow_spawn_walkingUp = {
		prefix = "shadow_spawn",
		to = 49,
		from = 34
	},
	shadow_spawn_attack = {
		prefix = "shadow_spawn",
		to = 69,
		from = 50
	},
	shadow_spawn_death = {
		prefix = "shadow_spawn",
		to = 93,
		from = 70
	},
	shadow_spawn_raise = {
		prefix = "shadow_spawn",
		to = 130,
		from = 94
	},
	grim_devourers_idle = {
		prefix = "grim_devourers",
		to = 1,
		from = 1
	},
	grim_devourers_walkingRightLeft = {
		prefix = "grim_devourers",
		to = 14,
		from = 2
	},
	grim_devourers_walkingDown = {
		prefix = "grim_devourers",
		to = 28,
		from = 15
	},
	grim_devourers_walkingUp = {
		prefix = "grim_devourers",
		to = 42,
		from = 29
	},
	grim_devourers_attack = {
		prefix = "grim_devourers",
		to = 58,
		from = 43
	},
	grim_devourers_death = {
		prefix = "grim_devourers",
		to = 82,
		from = 59
	},
	grim_devourers_cannibal = {
		prefix = "grim_devourers",
		to = 109,
		from = 83
	},
	shadow_champion_idle = {
		prefix = "shadow_champion",
		to = 1,
		from = 1
	},
	shadow_champion_walkingRightLeft = {
		prefix = "shadow_champion",
		to = 26,
		from = 2
	},
	shadow_champion_walkingDown = {
		prefix = "shadow_champion",
		to = 51,
		from = 27
	},
	shadow_champion_walkingUp = {
		prefix = "shadow_champion",
		to = 76,
		from = 52
	},
	shadow_champion_attack = {
		prefix = "shadow_champion",
		to = 103,
		from = 77
	},
	shadow_champion_death = {
		prefix = "shadow_champion",
		to = 140,
		from = 104
	},
	plant_magic_blossom_loading = {
		prefix = "plant_magicBlosom",
		to = 21,
		from = 1
	},
	plant_magic_blossom_ready = {
		prefix = "plant_magicBlosom",
		to = 32,
		from = 22
	},
	plant_magic_blossom_idle = {
		prefix = "plant_magicBlosom",
		to = 45,
		from = 33
	},
	plant_magic_blossom_shoot = {
		prefix = "plant_magicBlosom",
		to = 65,
		from = 46
	},
	fx_plant_magic_blossom_loading = {
		prefix = "plant_magicBlosom_loading",
		to = 16,
		from = 1
	},
	fx_plant_magic_blossom_idle1 = {
		prefix = "plant_magicBlosom_loaded",
		to = 26,
		from = 1
	},
	fx_plant_magic_blossom_idle2 = {
		prefix = "plant_magicBlosom_loaded2",
		to = 65,
		from = 1
	},
	bolt_plant_magic_blossom_travel = {
		prefix = "plant_magicBlosom_bolt",
		to = 1,
		from = 1
	},
	fx_bolt_plant_magic_blossom_hit = {
		prefix = "plant_magicBlosom_bolt",
		to = 9,
		from = 2
	},
	plant_poison_pumpkin_loading = {
		prefix = "plant_venom",
		to = 78,
		from = 55
	},
	plant_poison_pumpkin_ready = {
		prefix = "plant_venom",
		to = 25,
		from = 1
	},
	plant_poison_pumpkin_idle = {
		prefix = "plant_venom",
		to = 92,
		from = 79
	},
	plant_poison_pumpkin_shoot = {
		prefix = "plant_venom",
		to = 54,
		from = 26
	},
	fx_plant_poison_pumpkin_particles = {
		prefix = "plant_venom_particles",
		to = 24,
		from = 1
	},
	fx_plant_poison_pumpkin_smoke_left = {
		prefix = "plant_venom_smoke_left",
		to = 42,
		from = 1
	},
	fx_plant_poison_pumpkin_smoke_down = {
		prefix = "plant_venom_smoke_down",
		to = 42,
		from = 1
	},
	poison_small = {
		prefix = "poison_small",
		to = 12,
		from = 1
	},
	poison_big = {
		prefix = "poison_big",
		to = 12,
		from = 1
	},
	poison_violet_small = {
		prefix = "poison_violet_small",
		to = 12,
		from = 1
	},
	poison_violet_medium = {
		prefix = "poison_violet_big",
		to = 12,
		from = 1
	},
	poison_violet_big = {
		prefix = "poison_violet_boss_type1",
		to = 12,
		from = 1
	},
	nav_faerie_red = {
		prefix = "fairy_energyBall_red",
		to = 15,
		from = 1
	},
	nav_faerie_yellow = {
		prefix = "fairy_energyBall_yellow",
		to = 15,
		from = 1
	},
	nav_faerie_particle_red = {
		prefix = "fairy_particle_red",
		to = 12,
		from = 1
	},
	nav_faerie_particle_yellow = {
		prefix = "fairy_particle_yellow",
		to = 12,
		from = 1
	},
	fx_faerie_smoke_red = {
		prefix = "fairy_entryFx_big_red",
		to = 12,
		from = 1
	},
	fx_faerie_smoke_yellow = {
		prefix = "fairy_entryFx_big_yellow",
		to = 12,
		from = 1
	},
	crystal_arcane_layerX_loading = {
		layer_to = 11,
		from = 1,
		layer_prefix = "crystalArcane_layer%i",
		to = 47,
		layer_from = 1
	},
	crystal_arcane_layerX_ready = {
		layer_to = 11,
		from = 48,
		layer_prefix = "crystalArcane_layer%i",
		to = 71,
		layer_from = 1
	},
	crystal_arcane_layerX_idle = {
		layer_to = 11,
		from = 72,
		layer_prefix = "crystalArcane_layer%i",
		to = 167,
		layer_from = 1
	},
	crystal_arcane_layerX_lightning = {
		layer_to = 11,
		from = 215,
		layer_prefix = "crystalArcane_layer%i",
		to = 249,
		layer_from = 1
	},
	crystal_arcane_layerX_buff = {
		layer_to = 11,
		from = 168,
		layer_prefix = "crystalArcane_layer%i",
		to = 214,
		layer_from = 1
	},
	crystal_arcane_layerX_freeze_start = {
		layer_to = 11,
		from = 250,
		layer_prefix = "crystalArcane_layer%i",
		to = 269,
		layer_from = 1
	},
	crystal_arcane_layerX_freeze_loop = {
		layer_to = 11,
		from = 270,
		layer_prefix = "crystalArcane_layer%i",
		to = 284,
		layer_from = 1
	},
	crystal_arcane_layerX_freeze_end = {
		layer_to = 11,
		from = 285,
		layer_prefix = "crystalArcane_layer%i",
		to = 319,
		layer_from = 1
	},
	ray_crystal_arcane = {
		prefix = "crystalArcane_ray",
		to = 24,
		from = 1
	},
	freeze_creep_ground_start = {
		prefix = "freeze_creep",
		to = 7,
		from = 1
	},
	freeze_creep_ground_end = {
		prefix = "freeze_creep",
		to = 23,
		from = 8
	},
	freeze_creep_air_start = {
		prefix = "freeze_creepFlying",
		to = 9,
		from = 1
	},
	freeze_creep_air_end = {
		prefix = "freeze_creepFlying",
		to = 21,
		from = 10
	},
	decal_crystal_arcane_freeze_1 = {
		prefix = "crystalArcane_groundFreeze1",
		to = 11,
		from = 1
	},
	decal_crystal_arcane_freeze_2 = {
		prefix = "crystalArcane_groundFreeze2",
		to = 11,
		from = 1
	},
	fx_crystal_arcane_tower = {
		prefix = "crystalArcane_towerBuff_bubbles",
		to = 19,
		from = 1
	},
	fx_crystal_arcane_soldier = {
		prefix = "crystalArcane_towerBuff_soldiersFx",
		to = 28,
		from = 1
	},
	decal_crystal_arcane_soldier_bubbles = {
		prefix = "crystalArcane_towerBuff_soldiersBubbles",
		to = 19,
		from = 1
	},
	decal_crystal_arcane_soldier_base = {
		prefix = "crystalArcane_towerBuff_soldiersBase",
		to = 30,
		from = 1
	},
	crystal_unstable_layerX_loading = {
		layer_to = 4,
		from = 1,
		layer_prefix = "crystalUnstable_layer%i",
		to = 30,
		layer_from = 1
	},
	crystal_unstable_layerX_loading2 = {
		layer_to = 4,
		from = 31,
		layer_prefix = "crystalUnstable_layer%i",
		to = 60,
		layer_from = 1
	},
	crystal_unstable_layerX_ready = {
		layer_to = 4,
		from = 61,
		layer_prefix = "crystalUnstable_layer%i",
		to = 78,
		layer_from = 1
	},
	crystal_unstable_layerX_idle = {
		layer_to = 4,
		from = 79,
		layer_prefix = "crystalUnstable_layer%i",
		to = 79,
		layer_from = 1
	},
	crystal_unstable_layerX_idle2 = {
		layer_to = 4,
		from = 80,
		layer_prefix = "crystalUnstable_layer%i",
		to = 104,
		layer_from = 1
	},
	crystal_unstable_layerX_teleport = {
		layer_to = 4,
		from = 105,
		layer_prefix = "crystalUnstable_layer%i",
		to = 141,
		layer_from = 1
	},
	crystal_unstable_layerX_infuse = {
		layer_to = 4,
		from = 105,
		layer_prefix = "crystalUnstable_layer%i",
		to = 141,
		layer_from = 1
	},
	crystal_unstable_layerX_heal = {
		layer_to = 4,
		from = 142,
		layer_prefix = "crystalUnstable_layer%i",
		to = 180,
		layer_from = 1
	},
	fx_teleport_in_crystal_unstable = {
		prefix = "crystalUnstable_teleportIn",
		to = 12,
		from = 1
	},
	fx_teleport_out_crystal_unstable = {
		prefix = "crystalUnstable_teleportOut",
		to = 16,
		from = 1
	},
	fx_heal_crystal_unstable = {
		prefix = "crystalUnstable_healFx",
		to = 25,
		from = 1
	},
	fx_crystal_unstable_bubbles = {
		prefix = "crystalUnstable_healAura_bubbles",
		to = 25,
		from = 1
	},
	paralyzing_tree_ready = {
		prefix = "paralyzingTree",
		to = 73,
		from = 1
	},
	paralyzing_tree_shoot = {
		prefix = "paralyzingTree",
		to = 120,
		from = 74
	},
	paralyzing_tree_loading = {
		prefix = "paralyzingTree",
		to = 121,
		from = 121
	},
	fx_paralyzing_tree_1 = {
		prefix = "paralyzingTree_particle0",
		to = 30,
		from = 1
	},
	fx_paralyzing_tree_2 = {
		prefix = "paralyzingTree_particle1",
		to = 30,
		from = 1
	},
	fx_paralyzing_tree_3 = {
		prefix = "paralyzingTree_particle2",
		to = 30,
		from = 1
	},
	mod_paralyzing_tree_loop = {
		prefix = "paralyzingTree_stun",
		to = 26,
		from = 1
	},
	decal_rally_feedback = {
		prefix = "decal_rally_feedback",
		to = 30,
		from = 1
	},
	decal_tower_hover_default = {
		prefix = "decal_tower_hover_default",
		to = 10,
		from = 1
	},
	decal_water_wave_1_play = {
		prefix = "water_waves",
		to = 39,
		from = 1
	},
	decal_water_wave_2_play = {
		prefix = "water_waves2",
		to = 15,
		from = 1
	},
	decal_water_wave_3_play = {
		prefix = "water_waves3",
		to = 21,
		from = 1
	},
	decal_water_wave_4_play = {
		prefix = "water_waves4",
		to = 42,
		from = 1
	},
	decal_water_splash_play = {
		prefix = "water_splash",
		to = 30,
		from = 1
	},
	decal_bambi_idle = {
		prefix = "bambi",
		to = 1,
		from = 1
	},
	decal_bambi_eat = {
		prefix = "bambi",
		to = 35,
		from = 2
	},
	decal_bambi_run = {
		prefix = "bambi",
		to = 45,
		from = 36
	},
	decal_bambi_touch = {
		prefix = "bambi",
		to = 72,
		from = 46
	},
	decal_rabbit_ears = {
		prefix = "stage1_rabbit",
		to = 1,
		from = 1
	},
	decal_rabbit_popout = {
		prefix = "stage1_rabbit",
		to = 38,
		from = 1
	},
	decal_rabbit_travel1 = {
		prefix = "stage1_rabbit",
		to = 49,
		from = 39
	},
	decal_rabbit_travel2 = {
		to = 100,
		from = 56,
		prefix = "stage1_rabbit",
		post = {
			94,
			91,
			71,
			70
		}
	},
	decal_rabbit_travel3 = {
		prefix = "stage1_rabbit",
		to = 113,
		from = 101
	},
	decal_rabbit_hide1 = {
		prefix = "stage1_rabbit",
		to = 140,
		from = 114
	},
	decal_rabbit_hide2 = {
		prefix = "stage1_rabbit",
		to = 161,
		from = 141
	},
	decal_rabbit_hide3 = {
		prefix = "stage1_rabbit",
		to = 184,
		from = 163
	},
	faerie_grove_crystal_fx_yellow = {
		prefix = "fairy_crystals_fx",
		to = 12,
		from = 1
	},
	faerie_grove_crystal_fx_red = {
		prefix = "fairy_crystals_fx",
		to = 24,
		from = 13
	},
	decal_water_sparks_idle = {
		prefix = "water_sparks",
		to = 24,
		from = 1
	},
	decal_fish_jump = {
		prefix = "stage1_fish",
		to = 22,
		from = 1
	},
	decal_bird_1_play = {
		prefix = "stage1_bird1",
		to = 8,
		from = 1
	},
	decal_bird_2_play = {
		prefix = "stage1_bird2",
		to = 8,
		from = 1
	},
	decal_gandalf_idle = {
		prefix = "stage1_gandalf",
		to = 1,
		from = 1
	},
	decal_gandalf_smoke = {
		prefix = "stage1_gandalf",
		to = 46,
		from = 1
	},
	decal_stage_02_waterfall_1_idle = {
		prefix = "stage2_water_fall1",
		to = 9,
		from = 1
	},
	decal_stage_02_waterfall_2_idle = {
		prefix = "stage2_water_fall2",
		to = 9,
		from = 1
	},
	decal_stage_02_waterfall_3_idle = {
		prefix = "stage2_water_fall3",
		to = 9,
		from = 1
	},
	decal_stage_02_waterfall_4_idle = {
		prefix = "stage2_water_fall4",
		to = 9,
		from = 1
	},
	decal_stage_02_bigwaves_idle = {
		prefix = "stage2_big_waves",
		to = 57,
		from = 1
	},
	decal_s03_cascade_2_1 = {
		prefix = "stage3_cascade_2_1",
		to = 15,
		from = 1
	},
	decal_s03_cascade_2_2 = {
		prefix = "stage3_cascade_2_2",
		to = 12,
		from = 1
	},
	decal_s03_cascade_2_3 = {
		prefix = "stage3_cascade_2_3",
		to = 9,
		from = 1
	},
	decal_s03_cascade_2_4 = {
		prefix = "stage3_cascade_2_4",
		to = 9,
		from = 1
	},
	decal_s03_cascade_2_b = {
		prefix = "stage3_cascade_2_bottom",
		to = 9,
		from = 1
	},
	decal_s03_cascade_1_1 = {
		prefix = "stage3_cascade_1_1",
		to = 15,
		from = 1
	},
	decal_s03_cascade_1_2 = {
		prefix = "stage3_cascade_1_2",
		to = 12,
		from = 1
	},
	decal_s03_cascade_1_3 = {
		prefix = "stage3_cascade_1_3",
		to = 9,
		from = 1
	},
	decal_s03_cascade_1_4 = {
		prefix = "stage3_cascade_1_4",
		to = 9,
		from = 1
	},
	decal_s03_cascade_1_b = {
		prefix = "stage3_cascade_1_bottom",
		to = 9,
		from = 1
	},
	decal_s03_cascade_3_1 = {
		prefix = "stage3_cascade_3_1",
		to = 15,
		from = 1
	},
	decal_s03_cascade_3_2 = {
		prefix = "stage3_cascade_3_2",
		to = 12,
		from = 1
	},
	decal_s03_cascade_3_3 = {
		prefix = "stage3_cascade_3_3",
		to = 9,
		from = 1
	},
	decal_s03_cascade_3_4 = {
		prefix = "stage3_cascade_3_4",
		to = 9,
		from = 1
	},
	decal_s03_cascade_3_5 = {
		prefix = "stage3_cascade_3_5",
		to = 9,
		from = 1
	},
	decal_s03_cascade_3_6 = {
		prefix = "stage3_cascade_3_6",
		to = 9,
		from = 1
	},
	decal_s03_cascade_3_b = {
		prefix = "stage3_cascade_3_bottom",
		to = 21,
		from = 1
	},
	decal_s03_stones_water_1 = {
		prefix = "stage3_stones_water_1",
		to = 33,
		from = 1
	},
	decal_s03_stones_water_2 = {
		prefix = "stage3_stones_water_2",
		to = 33,
		from = 1
	},
	decal_s03_water_1 = {
		prefix = "stage3_watter1",
		to = 42,
		from = 1
	},
	decal_s03_water_2 = {
		prefix = "stage3_watter2",
		to = 33,
		from = 1
	},
	decal_crane_idle = {
		prefix = "stage3_crane",
		to = 1,
		from = 1
	},
	decal_crane_play = {
		prefix = "stage3_crane",
		to = 56,
		from = 12
	},
	decal_crane_click = {
		prefix = "stage3_crane",
		to = 130,
		from = 111
	},
	decal_crane_final_click = {
		prefix = "stage3_crane",
		to = 110,
		from = 57
	},
	decal_crane_fx = {
		prefix = "stage3_craneFx",
		to = 42,
		from = 1
	},
	decal_river_object_hobbit_travel = {
		prefix = "stage3_dwarfBarrel",
		to = 30,
		from = 1
	},
	decal_river_object_hobbit_save = {
		prefix = "stage3_dwarfBarrel",
		to = 79,
		from = 50
	},
	decal_river_object_hobbit_fall = {
		prefix = "stage3_dwarfBarrel",
		to = 31,
		from = 31
	},
	decal_river_object_hobbit_crash = {
		prefix = "stage3_dwarfBarrel",
		to = 49,
		from = 32
	},
	decal_river_object_barrel_travel = {
		prefix = "stage3_barrel",
		to = 30,
		from = 1
	},
	decal_river_object_barrel_save = {
		prefix = "stage3_barrel",
		to = 41,
		from = 32
	},
	decal_river_object_barrel_sink = {
		prefix = "stage3_barrel",
		to = 41,
		from = 32
	},
	decal_river_object_barrel_fall = {
		prefix = "stage3_barrel",
		to = 31,
		from = 31
	},
	decal_river_object_submarine_travel = {
		prefix = "stage3_submarine",
		to = 15,
		from = 1
	},
	decal_river_object_submarine_save = {
		prefix = "stage3_submarine",
		to = 86,
		from = 17
	},
	decal_river_object_submarine_fall = {
		prefix = "stage3_submarine",
		to = 16,
		from = 16
	},
	decal_river_object_submarine_sink = {
		prefix = "stage3_submarine",
		to = 86,
		from = 56
	},
	decal_river_object_wilson_travel = {
		prefix = "stage3_wilson",
		to = 30,
		from = 1
	},
	decal_river_object_wilson_save = {
		prefix = "stage3_wilson",
		to = 60,
		from = 31
	},
	decal_river_object_wilson_fall = {
		prefix = "stage3_wilson",
		to = 87,
		from = 87
	},
	decal_river_object_wilson_sink = {
		prefix = "stage3_wilson",
		to = 86,
		from = 61
	},
	decal_river_object_chest_travel = {
		prefix = "stage3_chest",
		to = 30,
		from = 1
	},
	decal_river_object_chest_save = {
		prefix = "stage3_chest",
		to = 53,
		from = 32
	},
	decal_river_object_chest_fall = {
		prefix = "stage3_chest",
		to = 31,
		from = 31
	},
	decal_river_object_chest_sink = {
		prefix = "stage3_chest",
		to = 75,
		from = 54
	},
	fx_waterfall_splash = {
		prefix = "water_splash_waterfall",
		to = 14,
		from = 1
	},
	decal_s04_tree_burn_idle = {
		prefix = "stage4_tree",
		to = 1,
		from = 1
	},
	decal_s04_tree_burn_burn = {
		prefix = "stage4_tree",
		to = 28,
		from = 1
	},
	fx_torch_gnoll_burner_explosion_stage04 = {
		prefix = "stage4_fire_explosion",
		to = 18,
		from = 1
	},
	fx_s04_tree_fire_1 = {
		prefix = "stage4_fire_fx1",
		to = 22,
		from = 1
	},
	fx_s04_tree_fire_2 = {
		prefix = "stage4_fire_fx2",
		to = 18,
		from = 1
	},
	decal_george_jungle_liana_idle = {
		prefix = "stage4_george_liana",
		to = 1,
		from = 1
	},
	decal_george_jungle_liana_start = {
		prefix = "stage4_george_liana",
		to = 5,
		from = 1
	},
	decal_george_jungle_liana_release = {
		prefix = "stage4_george_liana",
		to = 9,
		from = 6
	},
	decal_george_jungle_liana_click = {
		prefix = "stage4_george_liana",
		to = 22,
		from = 11
	},
	decal_george_jungle_fall = {
		prefix = "stage4_george",
		to = 25,
		from = 1
	},
	decal_george_jungle_bush_idle = {
		prefix = "stage4_george_stones",
		to = 1,
		from = 1
	},
	decal_george_jungle_bush_play = {
		prefix = "stage4_george_stones",
		to = 11,
		from = 1
	},
	decal_tree_ewok_walk = {
		prefix = "ewok_2",
		to = 18,
		from = 3
	},
	decal_tree_ewok_idle = {
		prefix = "ewok_2",
		to = 1,
		from = 1
	},
	decal_tree_ewok_shoot = {
		prefix = "ewok_2",
		to = 34,
		from = 21
	},
	decal_tree_ewok_dance1 = {
		prefix = "ewok_2",
		to = 44,
		from = 35
	},
	decal_tree_ewok_dance2 = {
		prefix = "ewok_2",
		to = 60,
		from = 45
	},
	decal_s05_cascade_1 = {
		prefix = "stage5_cascade_1",
		to = 15,
		from = 1
	},
	decal_s05_cascade_2 = {
		prefix = "stage5_cascade_2",
		to = 9,
		from = 1
	},
	decal_s05_cascade_3 = {
		prefix = "stage5_cascade_3",
		to = 12,
		from = 1
	},
	decal_s05_cascade_waves = {
		prefix = "stage5_cascade_waves",
		to = 27,
		from = 1
	},
	decal_s05_cascade_splash = {
		prefix = "stage5_cascade_splash",
		to = 9,
		from = 1
	},
	decal_s05_cascade_splashes = {
		prefix = "stage5_cascade_splashes",
		to = 20,
		from = 1
	},
	fx_bush_statue_click = {
		prefix = "stage5_bushesFx",
		to = 19,
		from = 1
	},
	decal_s06_eagle_1 = {
		prefix = "stage6_eagle",
		to = 51,
		from = 1
	},
	decal_s06_eagle_2 = {
		prefix = "stage6_eagle",
		to = 85,
		from = 52
	},
	decal_s06_eagle_3 = {
		prefix = "stage6_eagle",
		to = 99,
		from = 86
	},
	decal_s06_eagle_4 = {
		prefix = "stage6_eagle",
		to = 118,
		from = 100
	},
	soldier_gryphon_guard_idle = {
		prefix = "gryphon_guards",
		to = 1,
		from = 1
	},
	soldier_gryphon_guard_running = {
		prefix = "gryphon_guards",
		to = 6,
		from = 2
	},
	soldier_gryphon_guard_shoot = {
		prefix = "gryphon_guards",
		to = 21,
		from = 7
	},
	gryphon_l1_idle = {
		prefix = "ally_gryphon_layer1",
		to = 1,
		from = 1
	},
	gryphon_l1_takeoff = {
		prefix = "ally_gryphon_layer1",
		to = 29,
		from = 2
	},
	gryphon_l1_fly = {
		prefix = "ally_gryphon_layer1",
		to = 45,
		from = 30
	},
	gryphon_l1_attack_start = {
		prefix = "ally_gryphon_layer1",
		to = 55,
		from = 46
	},
	gryphon_l1_attack_loop = {
		prefix = "ally_gryphon_layer1",
		to = 73,
		from = 56
	},
	gryphon_l1_attack_end = {
		prefix = "ally_gryphon_layer1",
		to = 89,
		from = 74
	},
	gryphon_l1_land = {
		prefix = "ally_gryphon_layer1",
		to = 116,
		from = 90
	},
	gryphon_l1_call = {
		prefix = "ally_gryphon_layer1",
		to = 146,
		from = 117
	},
	gryphon_l2_idle = {
		prefix = "ally_gryphon_layer2",
		to = 1,
		from = 1
	},
	gryphon_l2_takeoff = {
		prefix = "ally_gryphon_layer2",
		to = 29,
		from = 2
	},
	gryphon_l2_fly = {
		prefix = "ally_gryphon_layer2",
		to = 45,
		from = 30
	},
	gryphon_l2_attack_start = {
		prefix = "ally_gryphon_layer2",
		to = 55,
		from = 46
	},
	gryphon_l2_attack_loop = {
		prefix = "ally_gryphon_layer2",
		to = 73,
		from = 56
	},
	gryphon_l2_attack_end = {
		prefix = "ally_gryphon_layer2",
		to = 89,
		from = 74
	},
	gryphon_l2_land = {
		prefix = "ally_gryphon_layer2",
		to = 116,
		from = 90
	},
	gryphon_l2_call = {
		prefix = "ally_gryphon_layer2",
		to = 146,
		from = 117
	},
	gryphon_attack_flash = {
		prefix = "ally_gryphon_bolt_flash",
		to = 8,
		from = 1
	},
	bolt_gryphon_travel = {
		prefix = "ally_gryphon_bolt",
		to = 4,
		from = 1
	},
	fx_bolt_gryphon_hit = {
		prefix = "ally_gryphon_bolt_explotion",
		to = 9,
		from = 1
	},
	decal_s06_boxed_boss_l1_idle = {
		prefix = "stage6_bossDecal_layer1",
		to = 1,
		from = 1
	},
	decal_s06_boxed_boss_l2_idle = {
		prefix = "stage6_bossDecal_layer2",
		to = 1,
		from = 1
	},
	decal_s06_boxed_boss_l3_idle = {
		prefix = "stage6_bossDecal_layer3",
		to = 1,
		from = 1
	},
	decal_s06_boxed_boss_l1_play = {
		prefix = "stage6_bossDecal_layer1",
		to = 42,
		from = 1
	},
	decal_s06_boxed_boss_l2_play = {
		prefix = "stage6_bossDecal_layer2",
		to = 42,
		from = 1
	},
	decal_s06_boxed_boss_l3_play = {
		prefix = "stage6_bossDecal_layer3",
		to = 42,
		from = 1
	},
	decal_s06_jailed_boss_l1_walk = {
		prefix = "bossHiena_cage_layer1",
		to = 22,
		from = 1
	},
	decal_s06_jailed_boss_l2_walk = {
		prefix = "bossHiena_cage_layer2",
		to = 22,
		from = 1
	},
	decal_s06_jailed_boss_l3_walk = {
		prefix = "bossHiena_cage_layer3",
		to = 22,
		from = 1
	},
	decal_s06_jailed_boss_l4_walk = {
		prefix = "bossHiena_cage_layer4",
		to = 22,
		from = 1
	},
	decal_s06_jailed_boss_l5_walk = {
		prefix = "bossHiena_cage_layer5",
		to = 22,
		from = 1
	},
	decal_s06_jailed_boss_l6_walk = {
		prefix = "bossHiena_cage_layer6",
		to = 22,
		from = 1
	},
	decal_s06_jailed_boss_l1_open = {
		prefix = "bossHiena_cage_layer1",
		to = 181,
		from = 23
	},
	decal_s06_jailed_boss_l2_open = {
		prefix = "bossHiena_cage_layer2",
		to = 181,
		from = 23
	},
	decal_s06_jailed_boss_l3_open = {
		prefix = "bossHiena_cage_layer3",
		to = 181,
		from = 23
	},
	decal_s06_jailed_boss_l4_open = {
		prefix = "bossHiena_cage_layer4",
		to = 181,
		from = 23
	},
	decal_s06_jailed_boss_l5_open = {
		prefix = "bossHiena_cage_layer5",
		to = 181,
		from = 23
	},
	decal_s06_jailed_boss_l6_open = {
		prefix = "bossHiena_cage_layer6",
		to = 181,
		from = 23
	},
	eb_gnoll_walkingRightLeft = {
		prefix = "bossHiena",
		to = 20,
		from = 1
	},
	eb_gnoll_walkingDown = {
		prefix = "bossHiena",
		to = 40,
		from = 21
	},
	eb_gnoll_walkingUp = {
		prefix = "bossHiena",
		to = 61,
		from = 41
	},
	eb_gnoll_idle = {
		prefix = "bossHiena",
		to = 62,
		from = 62
	},
	eb_gnoll_attack = {
		prefix = "bossHiena",
		to = 231,
		from = 209
	},
	eb_gnoll_specialAttack = {
		prefix = "bossHiena",
		to = 137,
		from = 63
	},
	eb_gnoll_scream = {
		prefix = "bossHiena",
		to = 174,
		from = 138
	},
	eb_gnoll_death = {
		prefix = "bossHiena",
		to = 208,
		from = 175
	},
	decal_wisp_1_l1 = {
		prefix = "wisps_1_layer1",
		to = 84,
		from = 1
	},
	decal_wisp_1_l2 = {
		prefix = "wisps_1_layer2",
		to = 84,
		from = 1
	},
	decal_wisp_1_l3 = {
		prefix = "wisps_1_layer3",
		to = 84,
		from = 1
	},
	decal_wisp_2_l1 = {
		prefix = "wisps_2_layer1",
		to = 84,
		from = 1
	},
	decal_wisp_2_l2 = {
		prefix = "wisps_2_layer2",
		to = 84,
		from = 1
	},
	decal_wisp_2_l3 = {
		prefix = "wisps_2_layer3",
		to = 84,
		from = 1
	},
	decal_wisp_2_l4 = {
		prefix = "wisps_2_layer4",
		to = 84,
		from = 1
	},
	decal_wisp_3_l1 = {
		prefix = "wisps_3_layer1",
		to = 84,
		from = 1
	},
	decal_wisp_3_l2 = {
		prefix = "wisps_3_layer2",
		to = 84,
		from = 1
	},
	decal_wisp_3_l3 = {
		prefix = "wisps_3_layer3",
		to = 84,
		from = 1
	},
	decal_wisp_3_l4 = {
		prefix = "wisps_3_layer4",
		to = 84,
		from = 1
	},
	decal_wisp_4_l1 = {
		prefix = "wisps_4_layer1",
		to = 85,
		from = 1
	},
	decal_wisp_4_l2 = {
		prefix = "wisps_4_layer2",
		to = 85,
		from = 1
	},
	decal_wisp_5_play = {
		prefix = "wisps_5",
		to = 58,
		from = 1
	},
	decal_wisp_6_play = {
		prefix = "wisps_6",
		to = 26,
		from = 1
	},
	decal_wisp_7_play = {
		prefix = "wisps_7",
		to = 40,
		from = 1
	},
	decal_wisp_8_play = {
		prefix = "wisps_8",
		to = 26,
		from = 1
	},
	decal_wisp_9_play = {
		prefix = "wisps_9",
		to = 22,
		from = 1
	},
	decal_wisp_10_play = {
		prefix = "wisps_10",
		to = 24,
		from = 1
	},
	decal_obelix_idle = {
		prefix = "obelix",
		to = 1,
		from = 1
	},
	decal_obelix_hammer = {
		prefix = "obelix",
		to = 56,
		from = 2
	},
	decal_obelix_eat = {
		prefix = "obelix",
		to = 112,
		from = 57
	},
	decal_s08_magic_bean_l1_step1 = {
		prefix = "stage10_magicBeans_layer1",
		to = 10,
		from = 2
	},
	decal_s08_magic_bean_l1_step2 = {
		prefix = "stage10_magicBeans_layer1",
		to = 23,
		from = 11
	},
	decal_s08_magic_bean_l1_step3 = {
		prefix = "stage10_magicBeans_layer1",
		to = 33,
		from = 24
	},
	decal_s08_magic_bean_l1_step4 = {
		prefix = "stage10_magicBeans_layer1",
		to = 248,
		from = 34
	},
	decal_s08_magic_bean_l2_step1 = {
		prefix = "stage10_magicBeans_layer2",
		to = 10,
		from = 2
	},
	decal_s08_magic_bean_l2_step2 = {
		prefix = "stage10_magicBeans_layer2",
		to = 23,
		from = 11
	},
	decal_s08_magic_bean_l2_step3 = {
		prefix = "stage10_magicBeans_layer2",
		to = 33,
		from = 24
	},
	decal_s08_magic_bean_l2_step4 = {
		prefix = "stage10_magicBeans_layer2",
		to = 248,
		from = 34
	},
	decal_s08_magic_bean_l3_step1 = {
		prefix = "stage10_magicBeans_layer3",
		to = 10,
		from = 2
	},
	decal_s08_magic_bean_l3_step2 = {
		prefix = "stage10_magicBeans_layer3",
		to = 23,
		from = 11
	},
	decal_s08_magic_bean_l3_step3 = {
		prefix = "stage10_magicBeans_layer3",
		to = 33,
		from = 24
	},
	decal_s08_magic_bean_l3_step4 = {
		prefix = "stage10_magicBeans_layer3",
		to = 248,
		from = 34
	},
	decal_s08_magic_bean_l4_step1 = {
		prefix = "stage10_magicBeans_layer4",
		to = 10,
		from = 2
	},
	decal_s08_magic_bean_l4_step2 = {
		prefix = "stage10_magicBeans_layer4",
		to = 23,
		from = 11
	},
	decal_s08_magic_bean_l4_step3 = {
		prefix = "stage10_magicBeans_layer4",
		to = 33,
		from = 24
	},
	decal_s08_magic_bean_l4_step4 = {
		prefix = "stage10_magicBeans_layer4",
		to = 248,
		from = 34
	},
	decal_s08_magic_bean_l5_step1 = {
		prefix = "stage10_magicBeans_layer5",
		to = 10,
		from = 2
	},
	decal_s08_magic_bean_l5_step2 = {
		prefix = "stage10_magicBeans_layer5",
		to = 23,
		from = 11
	},
	decal_s08_magic_bean_l5_step3 = {
		prefix = "stage10_magicBeans_layer5",
		to = 33,
		from = 24
	},
	decal_s08_magic_bean_l5_step4 = {
		prefix = "stage10_magicBeans_layer5",
		to = 248,
		from = 34
	},
	decal_s08_peekaboo_wolf_in = {
		prefix = "stage10_wolf",
		to = 14,
		from = 1
	},
	decal_s08_peekaboo_wolf_out = {
		prefix = "stage10_wolf",
		to = 20,
		from = 15
	},
	decal_s08_peekaboo_wolf_action = {
		prefix = "stage10_wolf",
		to = 46,
		from = 21
	},
	decal_s08_peekaboo_pork_in = {
		prefix = "stage10_pork",
		to = 33,
		from = 1
	},
	decal_s08_peekaboo_pork_out = {
		prefix = "stage10_pork",
		to = 66,
		from = 34
	},
	decal_s08_peekaboo_pork_action = {
		prefix = "stage10_pork",
		ranges = {
			{
				81,
				94
			},
			{
				67,
				80
			}
		}
	},
	decal_s08_peekaboo_rrh_in = {
		prefix = "stage10_redRidingHood",
		to = 8,
		from = 1
	},
	decal_s08_peekaboo_rrh_out = {
		prefix = "stage10_redRidingHood",
		to = 18,
		from = 9
	},
	decal_s08_peekaboo_rrh_action = {
		prefix = "stage10_redRidingHood",
		to = 71,
		from = 19
	},
	decal_s08_hansel_gretel_door_open = {
		prefix = "stage10_witchHouse_layer2",
		to = 10,
		from = 1
	},
	decal_s08_hansel_gretel_door_close = {
		prefix = "stage10_witchHouse_layer2",
		to = 19,
		from = 11
	},
	decal_s08_witch_idle = {
		prefix = "stage10_witch",
		to = 1,
		from = 1
	},
	decal_s08_witch_walk = {
		prefix = "stage10_witch",
		to = 9,
		from = 2
	},
	decal_s08_witch_angry = {
		prefix = "stage10_witch",
		to = 26,
		from = 10
	},
	decal_s08_witch_die = {
		prefix = "stage10_witch",
		to = 45,
		from = 26
	},
	decal_s08_witch_click = {
		prefix = "stage10_witch",
		to = 58,
		from = 46
	},
	decal_s08_hansel_walk = {
		prefix = "stage10_hansel",
		to = 5,
		from = 1
	},
	decal_s08_gretel_walk = {
		prefix = "stage10_gretel",
		to = 5,
		from = 1
	},
	decal_s09_waterfall_lines1 = {
		prefix = "stage9_waterfall_lines",
		to = 9,
		from = 1
	},
	decal_s09_waterfall_lines2 = {
		prefix = "stage9_waterfall_lines2",
		to = 15,
		from = 1
	},
	decal_s09_waterfall_top = {
		prefix = "stage9_waterfall_top",
		to = 9,
		from = 1
	},
	decal_s09_waterfall_bottom = {
		prefix = "stage9_waterfall_bottom",
		to = 9,
		from = 1
	},
	decal_s09_crystal_1_idle = {
		prefix = "stage9_crystals1_layer",
		to = 1,
		from = 1
	},
	decal_s09_crystal_1_break = {
		prefix = "stage9_crystals1_layer",
		to = 16,
		from = 1
	},
	decal_s09_crystal_2_idle = {
		prefix = "stage9_crystals2_layer",
		to = 1,
		from = 1
	},
	decal_s09_crystal_2_break = {
		prefix = "stage9_crystals2_layer",
		to = 16,
		from = 1
	},
	decal_s09_crystal_3_idle = {
		prefix = "stage9_crystals3_layer",
		to = 1,
		from = 1
	},
	decal_s09_crystal_3_break = {
		prefix = "stage9_crystals3_layer",
		to = 18,
		from = 1
	},
	decal_s09_crystal_4_idle = {
		prefix = "stage9_crystals4_layer",
		to = 1,
		from = 1
	},
	decal_s09_crystal_4_break = {
		prefix = "stage9_crystals4_layer",
		to = 16,
		from = 1
	},
	decal_s09_crystal_debris_1 = {
		prefix = "stage9_crystals_rocks",
		to = 25,
		from = 3
	},
	decal_s09_crystal_debris_2 = {
		prefix = "stage9_crystals_rocks",
		to = 25,
		from = 1
	},
	crystal_serpent_appear = {
		prefix = "crystalSerpent",
		to = 114,
		from = 1
	},
	crystal_serpent_spawn = {
		prefix = "crystalSerpent",
		to = 150,
		from = 115
	},
	crystal_serpent_idle = {
		prefix = "crystalSerpent",
		to = 175,
		from = 151
	},
	crystal_serpent_shootSmoke = {
		prefix = "crystalSerpent",
		to = 215,
		from = 176
	},
	crystal_serpent_superScream = {
		prefix = "crystalSerpent",
		to = 273,
		from = 216
	},
	crystal_serpent_dive = {
		prefix = "crystalSerpent",
		to = 341,
		from = 274
	},
	crystal_serpent_superScreamRays = {
		prefix = "crystalSerpent",
		to = 399,
		from = 342
	},
	crystal_serpent_waterWaves = {
		prefix = "crystalSerpent",
		to = 415,
		from = 400
	},
	crystal_serpent_block_tower_start = {
		prefix = "crystalSerpent_towerFreeze",
		to = 9,
		from = 1
	},
	crystal_serpent_block_tower_loop = {
		prefix = "crystalSerpent_towerFreeze",
		to = 9,
		from = 9
	},
	crystal_serpent_block_tower_end = {
		prefix = "crystalSerpent_towerFreeze",
		to = 5,
		from = 9
	},
	faerie_grove_crystal_fx_yellow = {
		prefix = "fairy_crystals_fx",
		to = 12,
		from = 1
	},
	faerie_grove_crystal_fx_red = {
		prefix = "fairy_crystals_fx",
		to = 24,
		from = 13
	},
	simon_gnome_idle = {
		prefix = "stage8_symon",
		to = 1,
		from = 1
	},
	simon_gnome_play = {
		prefix = "stage8_symon",
		to = 55,
		from = 1
	},
	simon_gnome_fx = {
		prefix = "stage8_symon",
		to = 67,
		from = 56
	},
	simon_gnome_sign = {
		prefix = "stage8_symon_signComePlay",
		to = 45,
		from = 1
	},
	decal_s10_gnome_idle = {
		prefix = "stage8_pixie",
		to = 1,
		from = 1
	},
	decal_s10_gnome_walk = {
		prefix = "stage8_pixie",
		to = 8,
		from = 2
	},
	decal_s10_gnome_guitarBegin = {
		prefix = "stage8_pixie",
		to = 22,
		from = 9
	},
	decal_s10_gnome_guitarLoop = {
		prefix = "stage8_pixie",
		to = 40,
		from = 23
	},
	decal_s10_gnome_guitarEnd = {
		prefix = "stage8_pixie",
		to = 46,
		from = 41
	},
	decal_s10_gnome_diamond = {
		prefix = "stage8_pixie",
		to = 122,
		from = 47
	},
	decal_s10_gnome_sleepBegin = {
		prefix = "stage8_pixie",
		to = 128,
		from = 123
	},
	decal_s10_gnome_sleepLoop = {
		prefix = "stage8_pixie",
		to = 153,
		from = 129
	},
	decal_s10_gnome_sleepEnd = {
		prefix = "stage8_pixie",
		to = 157,
		from = 154
	},
	decal_s10_gnome_teleportOut = {
		prefix = "stage8_pixie",
		to = 171,
		from = 158
	},
	decal_s10_gnome_teleportIn = {
		prefix = "stage8_pixie",
		to = 177,
		from = 172
	},
	decal_s10_gnome_explode = {
		prefix = "stage8_pixie",
		to = 215,
		from = 183
	},
	decal_s11_fire = {
		prefix = "stage11_fire",
		to = 12,
		from = 1
	},
	decal_s11_gnome_wheelbarrow_idle = {
		prefix = "stage11_bossDecal",
		to = 30,
		from = 6
	},
	decal_s11_gnome_wheelbarrow_play = {
		prefix = "stage11_bossDecal",
		to = 80,
		from = 31
	},
	decal_s11_gnome_painting_idle = {
		prefix = "stage11_bossDecal",
		to = 81,
		from = 81
	},
	decal_s11_gnome_painting_play = {
		prefix = "stage11_bossDecal",
		to = 138,
		from = 81
	},
	zealot_idle = {
		prefix = "zealot",
		to = 1,
		from = 1
	},
	zealot_walkingRightLeft = {
		prefix = "zealot",
		to = 25,
		from = 2
	},
	zealot_attack = {
		prefix = "zealot",
		to = 61,
		from = 26
	},
	zealot_death = {
		prefix = "zealot",
		to = 93,
		from = 62
	},
	zealot_walkingDown = {
		prefix = "zealot",
		to = 117,
		from = 94
	},
	zealot_walkingUp = {
		prefix = "zealot",
		to = 141,
		from = 118
	},
	zealot_cast_start = {
		prefix = "zealot",
		to = 147,
		from = 142
	},
	zealot_cast_loop = {
		prefix = "zealot",
		to = 162,
		from = 148
	},
	zealot_cast_end = {
		prefix = "zealot",
		to = 166,
		from = 163
	},
	s11_malicia_idle = {
		prefix = "malicia",
		to = 1,
		from = 1
	},
	s11_malicia_attack = {
		prefix = "malicia",
		to = 38,
		from = 2
	},
	s11_malicia_walk = {
		prefix = "malicia",
		to = 58,
		from = 39
	},
	s11_malicia_shoutStart = {
		prefix = "malicia",
		to = 68,
		from = 59
	},
	s11_malicia_shoutLoop = {
		prefix = "malicia",
		to = 74,
		from = 69
	},
	s11_malicia_shoutEnd = {
		prefix = "malicia",
		to = 77,
		from = 75
	},
	s11_malicia_cast = {
		prefix = "malicia",
		to = 113,
		from = 78
	},
	s11_malicia_teleportStart = {
		prefix = "malicia",
		to = 123,
		from = 114
	},
	s11_malicia_teleportLoop = {
		prefix = "malicia",
		to = 131,
		from = 124
	},
	s11_malicia_teleportEnd = {
		prefix = "malicia",
		to = 143,
		from = 132
	},
	s11_malicia_death = {
		prefix = "malicia",
		to = 154,
		from = 144
	},
	s11_malicia_deathIdle = {
		prefix = "malicia",
		to = 155,
		from = 155
	},
	s11_malicia_deathEnd = {
		prefix = "malicia",
		to = 224,
		from = 156
	},
	s11_malicia_standUp = {
		prefix = "malicia",
		to = 241,
		from = 225
	},
	s11_malicia_sitDown = {
		prefix = "malicia",
		to = 278,
		from = 242
	},
	s11_malicia_throneCast = {
		prefix = "malicia",
		to = 310,
		from = 279
	},
	s11_malicia_sittingIdle = {
		prefix = "malicia",
		to = 311,
		from = 311
	},
	s11_malicia_particle1 = {
		prefix = "malicia",
		to = 321,
		from = 312
	},
	s11_malicia_particle2 = {
		prefix = "malicia",
		to = 331,
		from = 322
	},
	s11_malicia_castFx = {
		prefix = "malicia",
		to = 367,
		from = 332
	},
	s11_malicia_shield_idle = {
		prefix = "malicia",
		to = 368,
		from = 368
	},
	s11_malicia_shield_break = {
		prefix = "malicia",
		to = 397,
		from = 369
	},
	s11_malicia_spiderNet = {
		prefix = "malicia",
		to = 424,
		from = 398
	},
	s11_malicia_netAnim = {
		prefix = "malicia",
		to = 428,
		from = 425
	},
	malicia_tower_block_start = {
		prefix = "malicia_towerNet",
		to = 10,
		from = 1
	},
	malicia_tower_block_loop = {
		prefix = "malicia_towerNet",
		to = 10,
		from = 10
	},
	malicia_tower_block_end = {
		prefix = "malicia_towerNet",
		to = 24,
		from = 11
	},
	fx_drow_queen_portal = {
		prefix = "DarterEffectTeleport",
		to = 11,
		from = 1
	},
	mactans_falling = {
		prefix = "mactans",
		to = 10,
		from = 1
	},
	mactans_startingWeb = {
		prefix = "mactans",
		to = 16,
		from = 11
	},
	mactans_web = {
		prefix = "mactans",
		to = 30,
		from = 17
	},
	mactans_startRetreat = {
		prefix = "mactans",
		to = 40,
		from = 31
	},
	mactans_startRetreat2 = {
		prefix = "mactans",
		to = 40,
		from = 36
	},
	mactans_retreat = {
		prefix = "mactans",
		to = 41,
		from = 41
	},
	mactans_bounce = {
		prefix = "mactans",
		to = 31,
		from = 31
	},
	mactans_decal1 = {
		prefix = "mactans_towerWebCycle1",
		to = 22,
		from = 1
	},
	mactans_decal2 = {
		prefix = "mactans_towerWebCycle2",
		to = 22,
		from = 1
	},
	mactans_decal3 = {
		prefix = "mactans_towerWebCycle3",
		to = 22,
		from = 1
	},
	mactans_decal4 = {
		prefix = "mactans_towerWebCycle4",
		to = 22,
		from = 1
	},
	mactans_malicia_grab = {
		prefix = "mactans_malicia",
		to = 19,
		from = 1
	},
	mactans_malicia_climbUp = {
		prefix = "mactans_malicia",
		to = 29,
		from = 20
	},
	mod_mactans_tower_block_end = {
		prefix = "mactans_towerWebs",
		to = 16,
		from = 5
	},
	decal_pixie_idle = {
		prefix = "pixie",
		to = 1,
		from = 1
	},
	decal_pixie_scratch = {
		prefix = "pixie",
		to = 18,
		from = 2
	},
	decal_pixie_harvester = {
		prefix = "pixie",
		to = 40,
		from = 19
	},
	decal_pixie_attack = {
		prefix = "pixie",
		to = 60,
		from = 41
	},
	decal_pixie_teleportOut = {
		prefix = "pixie",
		to = 75,
		from = 61
	},
	decal_pixie_teleportIn = {
		prefix = "pixie",
		to = 86,
		from = 76
	},
	decal_pixie_shoot = {
		prefix = "pixie",
		to = 100,
		from = 87
	},
	decal_pixie_walk = {
		prefix = "pixie",
		to = 107,
		from = 101
	},
	fx_bullet_pixie_instakill_hit = {
		prefix = "pixie_mushroomHit_big",
		to = 17,
		from = 1
	},
	fx_bullet_pixie_poison_hit = {
		prefix = "pixie_bottleHit_big",
		to = 16,
		from = 1
	},
	fx_mod_pixie_polymorph = {
		prefix = "pixie_polymorph_smoke_big",
		to = 11,
		from = 1
	},
	fx_mod_pixie_teleport_small = {
		prefix = "pixie_teleport_small",
		to = 10,
		from = 1
	},
	fx_mod_pixie_teleport_big = {
		prefix = "pixie_teleport_big",
		to = 10,
		from = 1
	},
	decal_s12_lemur_idle = {
		prefix = "terrain3_lemur",
		to = 1,
		from = 1
	},
	decal_s12_lemur_running = {
		prefix = "terrain3_lemur",
		to = 11,
		from = 2
	},
	decal_s12_lemur_action = {
		prefix = "terrain3_lemur",
		to = 63,
		from = 12
	},
	decal_bird_red = {
		prefix = "terrain3_pajarombriz",
		to = 8,
		from = 1
	},
	decal_bird_duck = {
		prefix = "terrain3_ducks",
		to = 8,
		from = 1
	},
	decal_metropolis_portal_start = {
		prefix = "ancientNecropolisTeleport",
		to = 8,
		from = 1
	},
	decal_metropolis_portal_loop = {
		prefix = "ancientNecropolisTeleport",
		to = 34,
		from = 9
	},
	decal_metropolis_portal_end = {
		prefix = "ancientNecropolisTeleport",
		to = 41,
		from = 35
	},
	fx_metropolis_portal = {
		prefix = "ancientNecropolisTeleport_decalFx",
		to = 25,
		from = 1
	},
	fx_teleport_metropolis = {
		prefix = "ancientNecropolisTeleport_creepFx_big",
		to = 20,
		from = 1
	},
	decal_s13_relic_book_idle = {
		prefix = "stage13_book",
		to = 1,
		from = 1
	},
	decal_s13_relic_book_play = {
		prefix = "stage13_book",
		to = 18,
		from = 1
	},
	decal_s13_relic_book_clicked = {
		prefix = "stage13_book",
		to = 38,
		from = 19
	},
	decal_s13_relic_broom_idle = {
		prefix = "stage13_broom",
		to = 1,
		from = 1
	},
	decal_s13_relic_broom_clicked = {
		prefix = "stage13_broom",
		to = 80,
		from = 2
	},
	decal_s13_relic_hat_idle = {
		prefix = "stage13_hat",
		to = 1,
		from = 1
	},
	decal_s13_relic_hat_clicked = {
		prefix = "stage13_hat",
		to = 32,
		from = 2
	},
	babyBeresad_idle = {
		prefix = "babyBeresad",
		to = 1,
		from = 1
	},
	babyBeresad_sneeze = {
		prefix = "babyBeresad",
		to = 49,
		from = 2
	},
	babyBeresad_wakeUp = {
		prefix = "babyBeresad",
		to = 87,
		from = 50
	},
	babyBeresad_fly = {
		prefix = "babyBeresad",
		to = 105,
		from = 88
	},
	babyBeresad_attack = {
		prefix = "babyBeresad",
		to = 123,
		from = 106
	},
	babyBeresad_land = {
		prefix = "babyBeresad",
		to = 134,
		from = 124
	},
	babyBeresad_zzz = {
		prefix = "babyBeresad",
		to = 205,
		from = 135
	},
	aura_baby_beresad_fire = {
		prefix = "babyBeresad_fireDecal",
		to = 12,
		from = 1
	},
	baby_beresad_flame_hit = {
		prefix = "babyBeresad_fireBurn",
		to = 10,
		from = 1
	},
	mod_baby_beresad_big = {
		prefix = "babyBeresad_creepFire_big",
		to = 10,
		from = 1
	},
	ps_baby_beresad_flame = {
		prefix = "babyBeresad_fire",
		to = 6,
		from = 1
	},
	babyAshbite_idle = {
		prefix = "babyAshbite",
		to = 18,
		from = 1
	},
	babyAshbite_death = {
		prefix = "babyAshbite",
		to = 63,
		from = 47
	},
	babyAshbite_respawn = {
		prefix = "babyAshbite",
		to = 84,
		from = 65
	},
	babyAshbite_hatch = {
		prefix = "babyAshbite",
		to = 98,
		from = 85
	},
	babyAshbite_shoot = {
		prefix = "babyAshbite",
		to = 46,
		from = 19
	},
	babyAshbite_special = {
		prefix = "babyAshbite",
		to = 145,
		from = 100
	},
	babyAshbite_specialFireGlow = {
		prefix = "babyAshbite",
		to = 191,
		from = 146
	},
	fireball_baby_ashbite = {
		prefix = "babyAshbite_proy",
		to = 10,
		from = 1
	},
	fx_fireball_baby_ashbite_hit = {
		prefix = "babyAshbite_proyHit",
		to = 15,
		from = 1
	},
	fx_fireball_baby_ashbite_hit_air = {
		prefix = "babyAshbite_proyHitAir",
		to = 14,
		from = 1
	},
	baby_ashbite_breath_particle = {
		prefix = "babyAshbite_specialFire_particle",
		to = 6,
		from = 1
	},
	baby_ashbite_breath_fire = {
		prefix = "babyAshbite_specialFire_fire",
		to = 18,
		from = 1
	},
	baby_ashbite_breath_fire_decal = {
		prefix = "babyAshbite_fireDecal",
		to = 32,
		from = 1
	},
	baby_ashbite_fierymist_particle = {
		prefix = "babyAshbite_smokeParticle",
		to = 10,
		from = 1
	},
	baby_ashbite_fierymist_decal = {
		prefix = "babyAshbite_smokeDecal",
		to = 27,
		from = 1
	},
	spider_egg_spawner_spawn = {
		prefix = "spiderEgg",
		to = 10,
		from = 1
	},
	spider_egg_spawner_idle = {
		prefix = "spiderEgg",
		to = 59,
		from = 11
	},
	spider_egg_spawner_open = {
		prefix = "spiderEgg",
		to = 86,
		from = 61
	},
	decal_s14_break_egg_idle = {
		prefix = "terrain3_eggs",
		to = 1,
		from = 1
	},
	decal_s14_break_egg_open = {
		prefix = "terrain3_eggs",
		to = 13,
		from = 1
	},
	decal_s14_break_spider = {
		prefix = "terrain3_spiders",
		to = 10,
		from = 1
	},
	stage15_malicia_attack = {
		prefix = "stage15_malicia",
		to = 28,
		from = 1
	},
	stage15_malicia_idle = {
		prefix = "stage15_malicia",
		to = 29,
		from = 29
	},
	stage15_malicia_jumpToCrystal = {
		prefix = "stage15_malicia",
		to = 104,
		from = 30
	},
	stage15_malicia_ray = {
		prefix = "stage15_malicia_ray",
		to = 8,
		from = 1
	},
	stage15_mactans_l1_idle = {
		prefix = "stage15_mactans_layer1",
		to = 1,
		from = 1
	},
	stage15_mactans_l1_attack = {
		prefix = "stage15_mactans_layer1",
		to = 21,
		from = 2
	},
	stage15_mactans_l1_jumpOut = {
		prefix = "stage15_mactans_layer1",
		to = 34,
		from = 22
	},
	stage15_mactans_l1_jumpIn = {
		prefix = "stage15_mactans_layer1",
		to = 47,
		from = 35
	},
	stage15_mactans_l1_jumpToCrystal = {
		prefix = "stage15_mactans_layer1",
		to = 122,
		from = 48
	},
	stage15_mactans_l2_idle = {
		prefix = "stage15_mactans_layer2",
		to = 1,
		from = 1
	},
	stage15_mactans_l2_attack = {
		prefix = "stage15_mactans_layer2",
		to = 21,
		from = 2
	},
	stage15_mactans_l2_jumpOut = {
		prefix = "stage15_mactans_layer2",
		to = 34,
		from = 22
	},
	stage15_mactans_l2_jumpIn = {
		prefix = "stage15_mactans_layer2",
		to = 47,
		from = 35
	},
	stage15_mactans_l2_jumpToCrystal = {
		prefix = "stage15_mactans_layer2",
		to = 122,
		from = 48
	},
	stage15_shield_idle = {
		prefix = "stage15_shield",
		to = 1,
		from = 1
	},
	stage15_shield_hit = {
		prefix = "stage15_shield",
		to = 8,
		from = 2
	},
	stage15_shield_break = {
		prefix = "stage15_shield",
		to = 27,
		from = 9
	},
	stage15_crystal_fx = {
		prefix = "stage15_crystal_Fx",
		to = 13,
		from = 1
	},
	stage15_crystal_l1_explosion = {
		prefix = "stage15_crystal_explosion_layer1",
		to = 114,
		from = 1
	},
	stage15_crystal_l2_explosion = {
		prefix = "stage15_crystal_explosion_layer2",
		to = 114,
		from = 1
	},
	stage15_crystal_l3_explosion = {
		prefix = "stage15_crystal_explosion_layer3",
		to = 114,
		from = 1
	},
	stage15_crystal_l4_explosion = {
		prefix = "stage15_crystal_explosion_layer4",
		to = 114,
		from = 1
	},
	decal_s15_finished_veznan_idle = {
		prefix = "stage15_bossDecal_veznan",
		to = 1,
		from = 1
	},
	decal_s15_finished_veznan_play = {
		prefix = "stage15_bossDecal_veznan",
		to = 56,
		from = 2
	},
	decal_s15_finished_guard_layerX_idle = {
		layer_to = 4,
		from = 1,
		layer_prefix = "stage15_bossDecal_demon_layer%i",
		to = 1,
		layer_from = 1
	},
	decal_s15_finished_guard_layerX_blink = {
		layer_to = 4,
		from = 2,
		layer_prefix = "stage15_bossDecal_demon_layer%i",
		to = 21,
		layer_from = 1
	},
	decal_s15_finished_guard_layerX_sleep = {
		layer_to = 4,
		from = 22,
		layer_prefix = "stage15_bossDecal_demon_layer%i",
		to = 155,
		layer_from = 1
	},
	eb_spider_layerX_idle = {
		layer_to = 6,
		from = 1,
		layer_prefix = "spiderQueen_layer%i",
		to = 1,
		layer_from = 1
	},
	eb_spider_layerX_walkingRightLeft = {
		layer_to = 6,
		from = 2,
		layer_prefix = "spiderQueen_layer%i",
		to = 21,
		layer_from = 1
	},
	eb_spider_layerX_walkingDown = {
		layer_to = 6,
		from = 22,
		layer_prefix = "spiderQueen_layer%i",
		to = 41,
		layer_from = 1
	},
	eb_spider_layerX_attack = {
		layer_to = 6,
		from = 42,
		layer_prefix = "spiderQueen_layer%i",
		to = 70,
		layer_from = 1
	},
	eb_spider_layerX_blockTower = {
		layer_to = 6,
		from = 71,
		layer_prefix = "spiderQueen_layer%i",
		to = 113,
		layer_from = 1
	},
	eb_spider_layerX_shootTower_start = {
		layer_to = 6,
		from = 114,
		layer_prefix = "spiderQueen_layer%i",
		to = 132,
		layer_from = 1
	},
	eb_spider_layerX_shootTower_loop = {
		layer_to = 6,
		from = 133,
		layer_prefix = "spiderQueen_layer%i",
		to = 142,
		layer_from = 1
	},
	eb_spider_layerX_shootTower_end = {
		layer_to = 6,
		from = 143,
		layer_prefix = "spiderQueen_layer%i",
		to = 167,
		layer_from = 1
	},
	eb_spider_layerX_unused = {
		layer_to = 6,
		from = 168,
		layer_prefix = "spiderQueen_layer%i",
		to = 227,
		layer_from = 1
	},
	eb_spider_layerX_shootTowerFail_start = {
		layer_to = 6,
		from = 228,
		layer_prefix = "spiderQueen_layer%i",
		to = 229,
		layer_from = 1
	},
	eb_spider_layerX_shootTowerFail_loop = {
		layer_to = 6,
		from = 230,
		layer_prefix = "spiderQueen_layer%i",
		to = 242,
		layer_from = 1
	},
	eb_spider_layerX_shootTowerFail_end = {
		layer_to = 6,
		from = 243,
		layer_prefix = "spiderQueen_layer%i",
		to = 251,
		layer_from = 1
	},
	eb_spider_layerX_death_first_start = {
		layer_to = 6,
		from = 252,
		layer_prefix = "spiderQueen_layer%i",
		to = 266,
		layer_from = 1
	},
	eb_spider_layerX_death_first_loop = {
		layer_to = 6,
		from = 267,
		layer_prefix = "spiderQueen_layer%i",
		to = 274,
		layer_from = 1
	},
	eb_spider_layerX_death_second_start = {
		layer_to = 6,
		from = 275,
		layer_prefix = "spiderQueen_layer%i",
		to = 285,
		layer_from = 1
	},
	eb_spider_layerX_death_second_loop = {
		layer_to = 6,
		from = 286,
		layer_prefix = "spiderQueen_layer%i",
		to = 297,
		layer_from = 1
	},
	eb_spider_layerX_death_unused = {
		layer_to = 6,
		from = 298,
		layer_prefix = "spiderQueen_layer%i",
		to = 343,
		layer_from = 1
	},
	eb_spider_layerX_flyingDown = {
		layer_to = 6,
		from = 344,
		layer_prefix = "spiderQueen_layer%i",
		to = 344,
		layer_from = 1
	},
	eb_spider_layerX_land = {
		layer_to = 6,
		from = 345,
		layer_prefix = "spiderQueen_layer%i",
		to = 358,
		layer_from = 1
	},
	eb_spider_layerX_jump = {
		layer_to = 6,
		from = 359,
		layer_prefix = "spiderQueen_layer%i",
		to = 372,
		layer_from = 1
	},
	eb_spider_layerX_flyingUp = {
		layer_to = 6,
		from = 373,
		layer_prefix = "spiderQueen_layer%i",
		to = 373,
		layer_from = 1
	},
	eb_spider_layerX_shoutOurs = {
		layer_to = 6,
		from = 374,
		layer_prefix = "spiderQueen_layer%i",
		to = 380,
		layer_from = 1
	},
	eb_spider_tower_block_start = {
		prefix = "spiderQueen_towerNet",
		to = 10,
		from = 1
	},
	eb_spider_tower_block_loop = {
		prefix = "spiderQueen_towerNet",
		to = 10,
		from = 10
	},
	eb_spider_tower_block_end = {
		prefix = "spiderQueen_towerNet",
		to = 24,
		from = 11
	},
	fx_eb_spider_spawn = {
		prefix = "spiderQueen_spawnFx",
		to = 12,
		from = 1
	},
	fx_eb_spider_jump_smoke = {
		prefix = "spiderQueen_smoke",
		to = 18,
		from = 1
	},
	ray_eb_spider = {
		prefix = "spiderQueen_ray",
		to = 14,
		from = 1
	},
	ray_eb_spider_tower = {
		prefix = "spiderQueen_towerRay",
		to = 18,
		from = 1
	},
	fx_ray_eb_spider_explosion = {
		prefix = "spiderQueen_rayExplosion",
		to = 20,
		from = 1
	},
	fx_ray_eb_spider_decal = {
		prefix = "spiderQueen_rayExplosion_decal",
		to = 14,
		from = 1
	},
	mod_eb_spider_tower_remove_explosion = {
		prefix = "spiderQueen_towerExplosion",
		to = 40,
		from = 1
	},
	decal_hr_crystal_skull_idle = {
		prefix = "stage16_skull",
		to = 1,
		from = 1
	},
	decal_hr_crystal_skull_play = {
		prefix = "stage16_skull",
		to = 32,
		from = 1
	},
	decal_hr_crystal_skull_clicked = {
		prefix = "stage16_skull",
		to = 75,
		from = 33
	},
	gnollBush_idle = {
		prefix = "gnollBush",
		to = 1,
		from = 1
	},
	gnollBush_standUp = {
		prefix = "gnollBush",
		to = 5,
		from = 2
	},
	gnollBush_walk = {
		prefix = "gnollBush",
		to = 21,
		from = 6
	},
	gnollBush_sitDown = {
		prefix = "gnollBush",
		to = 27,
		from = 22
	},
	gnollBush_explode = {
		prefix = "gnollBush",
		to = 49,
		from = 28
	},
	galahadriansBastion_layerX_reload = {
		layer_to = 4,
		from = 1,
		layer_prefix = "galahadriansBastion_layer%i",
		to = 38,
		layer_from = 1
	},
	galahadriansBastion_layerX_shoot = {
		layer_to = 4,
		from = 39,
		layer_prefix = "galahadriansBastion_layer%i",
		to = 52,
		layer_from = 1
	},
	galahadriansBastion_layerX_idle = {
		layer_to = 4,
		from = 53,
		layer_prefix = "galahadriansBastion_layer%i",
		to = 53,
		layer_from = 1
	},
	galahadriansBastion_layerX_broken = {
		layer_to = 4,
		from = 54,
		layer_prefix = "galahadriansBastion_layer%i",
		to = 54,
		layer_from = 1
	},
	bullet_razor_edge_flying = {
		prefix = "galahadriansBastion_proy",
		to = 4,
		from = 1
	},
	bullet_razor_edge_smoke = {
		prefix = "galahadriansBastion_proy_particle",
		to = 16,
		from = 1
	},
	fx_s16_bush_burner = {
		prefix = "gnollBush",
		to = 49,
		from = 28
	},
	fx_s16_burner_explosion = {
		prefix = "stage16_pathExplosion",
		to = 26,
		from = 1
	},
	soldier_s16_ground_archer_idle = {
		prefix = "groundArchers_shooter",
		to = 15,
		from = 15
	},
	soldier_s16_ground_archer_running = {
		prefix = "groundArchers_shooter",
		to = 15,
		from = 15
	},
	soldier_s16_ground_archer_shoot = {
		prefix = "groundArchers_shooter",
		to = 15,
		from = 1
	},
	gnollBush_idle = {
		prefix = "gnollBush",
		to = 1,
		from = 1
	},
	gnollBush_standUp = {
		prefix = "gnollBush",
		to = 5,
		from = 2
	},
	gnollBush_walk = {
		prefix = "gnollBush",
		to = 21,
		from = 6
	},
	gnollBush_sitDown = {
		prefix = "gnollBush",
		to = 27,
		from = 22
	},
	gnollBush_explode = {
		prefix = "gnollBush",
		to = 49,
		from = 28
	},
	decal_hr_worker_a = {
		prefix = "stage17_worker",
		to = 34,
		from = 1
	},
	decal_hr_worker_b = {
		prefix = "stage17_worker2",
		to = 148,
		from = 1
	},
	decal_s18_roadrunner_bush_idle = {
		prefix = "stage18_roadrunner_bush",
		to = 1,
		from = 1
	},
	decal_s18_roadrunner_bush_shake = {
		prefix = "stage18_roadrunner_bush",
		to = 33,
		from = 1
	},
	decal_s18_roadrunner_run = {
		prefix = "stage18_roadrunner_layer",
		to = 8,
		from = 1
	},
	decal_s18_coyote_pull = {
		prefix = "stage_18_coyote",
		to = 26,
		from = 1
	},
	decal_s18_coyote_push = {
		prefix = "stage_18_coyote",
		to = 95,
		from = 53
	},
	decal_s18_flag_head = {
		prefix = "stage_18_flag",
		to = 9,
		from = 1
	},
	eb_bram_attack = {
		prefix = "theBeheader",
		to = 20,
		from = 1
	},
	eb_bram_sitting = {
		prefix = "theBeheader",
		to = 21,
		from = 21
	},
	eb_bram_raise = {
		prefix = "theBeheader",
		to = 30,
		from = 21
	},
	eb_bram_walkingRightLeft = {
		prefix = "theBeheader",
		to = 54,
		from = 31
	},
	eb_bram_walkingDown = {
		prefix = "theBeheader",
		to = 78,
		from = 55
	},
	eb_bram_special = {
		prefix = "theBeheader",
		to = 122,
		from = 79
	},
	eb_bram_death = {
		prefix = "theBeheader",
		to = 225,
		from = 123
	},
	eb_bram_idle = {
		prefix = "theBeheader",
		to = 226,
		from = 226
	},
	decal_s19_drizzt_idle = {
		prefix = "stage19_drizztdourden",
		to = 36,
		from = 1
	},
	decal_s19_drizzt_alert = {
		prefix = "stage19_drizztdourden",
		to = 77,
		from = 37
	},
	decal_s19_drizzt_run = {
		prefix = "stage19_drizztdourden",
		to = 164,
		from = 78
	},
	decal_s19_drizzt_gnoll_idle = {
		prefix = "stage19_gnoll_drizztdourden",
		to = 1,
		from = 1
	},
	decal_s19_drizzt_gnoll_alert = {
		prefix = "stage19_gnoll_drizztdourden",
		to = 1,
		from = 1
	},
	decal_s19_drizzt_gnoll_walk = {
		prefix = "stage19_gnoll_drizztdourden",
		to = 21,
		from = 2
	},
	decal_s19_drizzt_gnoll_joke = {
		prefix = "stage19_gnoll_drizztdourden",
		to = 30,
		from = 22
	},
	decal_s19_drizzt_gnoll_scared = {
		prefix = "stage19_gnoll_drizztdourden",
		to = 44,
		from = 31
	},
	decal_s20_flame = {
		prefix = "stage20_fire",
		to = 12,
		from = 1
	},
	eb_bajnimen_idle = {
		prefix = "bajnimen_boss",
		to = 1,
		from = 1
	},
	eb_bajnimen_walkingUp = {
		prefix = "bajnimen_boss",
		to = 11,
		from = 2
	},
	eb_bajnimen_walkingDown = {
		prefix = "bajnimen_boss",
		to = 11,
		from = 2
	},
	eb_bajnimen_walkingRightLeft = {
		prefix = "bajnimen_boss",
		to = 11,
		from = 2
	},
	eb_bajnimen_attack = {
		prefix = "bajnimen_boss",
		to = 36,
		from = 12
	},
	eb_bajnimen_shadowStorm_start = {
		prefix = "bajnimen_boss",
		to = 44,
		from = 37
	},
	eb_bajnimen_shadowStorm_loop = {
		prefix = "bajnimen_boss",
		to = 54,
		from = 45
	},
	eb_bajnimen_shadowStorm_end = {
		prefix = "bajnimen_boss",
		to = 59,
		from = 55
	},
	eb_bajnimen_shoot = {
		prefix = "bajnimen_boss",
		to = 74,
		from = 60
	},
	eb_bajnimen_charge_start = {
		prefix = "bajnimen_boss",
		to = 84,
		from = 75
	},
	eb_bajnimen_charge_loop = {
		prefix = "bajnimen_boss",
		to = 100,
		from = 85
	},
	eb_bajnimen_charge_end = {
		prefix = "bajnimen_boss",
		to = 109,
		from = 101
	},
	eb_bajnimen_death = {
		prefix = "bajnimen_boss",
		to = 188,
		from = 110
	},
	bolt_bajnimen_flying = {
		prefix = "bajnimen_boss_particle",
		to = 6,
		from = 1
	},
	fx_bolt_bajnimen_hit = {
		prefix = "bajnimen_boss_particle_explosion",
		to = 11,
		from = 1
	},
	fx_meteor_bajnimen_explosion = {
		prefix = "bajnimen_boss_storm_explosion",
		to = 20,
		from = 1
	},
	decal_s21_white_flame = {
		prefix = "white_fire",
		to = 12,
		from = 1
	},
	decal_s21_red_banner = {
		prefix = "banner",
		to = 23,
		from = 1
	},
	decal_s21_lava_bubble_play = {
		prefix = "lava_bubble",
		to = 16,
		from = 1
	},
	decal_s22_lava_hole_play = {
		prefix = "lava_hole",
		to = 60,
		from = 1
	},
	decal_s22_lava_smoke_play = {
		prefix = "Stage9_Smoke",
		to = 31,
		from = 1
	},
	decal_s22_lava_bubble_play = {
		prefix = "Stage9_lavaBubble",
		to = 47,
		from = 1
	},
	fx_bomb_lava_fireball_launch = {
		prefix = "Stage9_lavaShotFx",
		to = 16,
		from = 1
	},
	fireball_explosion = {
		prefix = "fireball_explosion",
		to = 18,
		from = 1
	},
	eb_balrog_idle = {
		prefix = "boss_godieth",
		to = 8,
		from = 1
	},
	eb_balrog_walkingRightLeft = {
		prefix = "boss_godieth",
		to = 40,
		from = 9
	},
	eb_balrog_walkingDown = {
		prefix = "boss_godieth",
		to = 72,
		from = 41
	},
	eb_balrog_attack = {
		prefix = "boss_godieth",
		to = 103,
		from = 73
	},
	eb_balrog_spit = {
		prefix = "boss_godieth",
		to = 143,
		from = 104
	},
	eb_balrog_death = {
		prefix = "boss_godieth",
		to = 199,
		from = 144
	},
	balrog_aura_loop = {
		prefix = "boss_godieth_acidPool",
		to = 25,
		from = 1
	},
	balrog_aura_bubble_pop = {
		prefix = "boss_godieth_acidPool_bubble",
		to = 54,
		from = 1
	},
	balrog_aura_splash = {
		prefix = "boss_godieth_acidPool_splash",
		to = 17,
		from = 1
	},
	bullet_balrog = {
		prefix = "boss_godieth_spit-f",
		to = 6,
		from = 1
	},
	decal_s81_burner = {
		prefix = "stage_endless_1_burner",
		to = 12,
		from = 1
	},
	enemy_gnoll_warleader_idle = {
		prefix = "gnollBerzerker",
		to = 1,
		from = 1
	},
	enemy_gnoll_warleader_walkingRightLeft = {
		prefix = "gnollBerzerker",
		to = 25,
		from = 2
	},
	enemy_gnoll_warleader_walkingDown = {
		prefix = "gnollBerzerker",
		to = 49,
		from = 26
	},
	enemy_gnoll_warleader_walkingUp = {
		prefix = "gnollBerzerker",
		to = 73,
		from = 50
	},
	enemy_gnoll_warleader_attack = {
		prefix = "gnollBerzerker",
		to = 96,
		from = 74
	},
	enemy_gnoll_warleader_death = {
		prefix = "gnollBerzerker",
		to = 119,
		from = 97
	},
	eb_hee_haw_layerX_idle = {
		layer_to = 2,
		from = 1,
		layer_prefix = "hee-haw_layer%i",
		to = 1,
		layer_from = 1
	},
	eb_hee_haw_layerX_shoot = {
		layer_to = 2,
		from = 2,
		layer_prefix = "hee-haw_layer%i",
		to = 43,
		layer_from = 1
	},
	eb_hee_haw_layerX_shout = {
		layer_to = 2,
		from = 44,
		layer_prefix = "hee-haw_layer%i",
		to = 86,
		layer_from = 1
	},
	snare_hee_haw_falling = {
		prefix = "hee-haw_net",
		to = 8,
		from = 1
	},
	snare_hee_haw_miss = {
		prefix = "hee-haw_net",
		to = 30,
		from = 20
	},
	mod_snare_hee_haw_start = {
		prefix = "hee-haw_net",
		to = 19,
		from = 9
	},
	mod_snare_hee_haw_loop = {
		prefix = "hee-haw_net",
		to = 19,
		from = 19
	},
	mod_snare_hee_haw_end = {
		prefix = "hee-haw_net",
		to = 37,
		from = 32
	},
	catapult_endless_layerX_running = {
		layer_to = 9,
		from = 1,
		layer_prefix = "catapult_endless_layer%i",
		to = 15,
		layer_from = 1
	},
	catapult_endless_layerX_idle = {
		layer_to = 9,
		from = 16,
		layer_prefix = "catapult_endless_layer%i",
		to = 16,
		layer_from = 1
	},
	catapult_endless_layerX_shoot = {
		layer_to = 9,
		from = 17,
		layer_prefix = "catapult_endless_layer%i",
		to = 97,
		layer_from = 1
	},
	catapult_endless_layerX_death = {
		layer_to = 9,
		from = 98,
		layer_prefix = "catapult_endless_layer%i",
		to = 116,
		layer_from = 1
	},
	bullet_catapult_endless_bomb = {
		prefix = "catapult_endless_proy",
		to = 9,
		from = 4
	},
	catapult_endless_explosions_spikebomb = {
		prefix = "catapult_endless_explosions",
		to = 21,
		from = 1
	},
	catapult_endless_explosions_barrel = {
		prefix = "catapult_endless_explosions",
		to = 39,
		from = 22
	},
	catapult_endless_explosions_bomb = {
		prefix = "catapult_endless_explosions",
		to = 60,
		from = 40
	},
	decal_s82_house_fire = {
		prefix = "stage_endless_2_fire",
		to = 38,
		from = 1
	},
	eb_ainyl_idle = {
		prefix = "boss_ainyl",
		to = 1,
		from = 1
	},
	eb_ainyl_teleport = {
		prefix = "boss_ainyl",
		to = 78,
		from = 2
	},
	eb_ainyl_shield = {
		prefix = "boss_ainyl",
		to = 115,
		from = 79
	},
	eb_ainyl_block = {
		prefix = "boss_ainyl",
		to = 190,
		from = 116
	},
	ainyl_block_decal = {
		prefix = "boss_ainyl_block_decal",
		to = 9,
		from = 1
	},
	ainyl_block_end = {
		prefix = "boss_ainyl_block_end",
		to = 6,
		from = 1
	},
	ainyl_block_fx = {
		prefix = "boss_ainyl_block_fx",
		to = 12,
		from = 1
	},
	ainyl_shield_big = {
		prefix = "boss_ainyl_shield_big",
		to = 6,
		from = 1
	},
	ainyl_shield_small = {
		prefix = "boss_ainyl_shield_small",
		to = 6,
		from = 1
	},
	enemy_twilight_bannerbearer_idle = {
		prefix = "twilight_bannerbearer",
		to = 1,
		from = 1
	},
	enemy_twilight_bannerbearer_walkingRightLeft = {
		prefix = "twilight_bannerbearer",
		to = 25,
		from = 2
	},
	enemy_twilight_bannerbearer_walkingDown = {
		prefix = "twilight_bannerbearer",
		to = 49,
		from = 26
	},
	enemy_twilight_bannerbearer_walkingUp = {
		prefix = "twilight_bannerbearer",
		to = 73,
		from = 50
	},
	enemy_twilight_bannerbearer_attack = {
		prefix = "twilight_bannerbearer",
		to = 101,
		from = 74
	},
	enemy_twilight_bannerbearer_death = {
		prefix = "twilight_bannerbearer",
		to = 146,
		from = 102
	},
	aura_twilight_bannerbearer = {
		prefix = "twilight_bannerbearer_aura",
		to = 22,
		from = 1
	},
	mod_twilight_bannerbearer = {
		prefix = "twilight_bannerbearer_enemy_aura",
		to = 21,
		from = 1
	}
}
local o = {}

o.animations = a

return o
