-- chunkname: @./kr5-desktop/data/game_gui_data.lua

local V = require("klua.vector")
local v = V.v
local i18n = require("i18n")

local function CJK(default, zh, ja, kr)
	return i18n.cjk(i18n, default, zh, ja, kr)
end

local base_offset = 0

if KR_PLATFORM == "ios" then
	base_offset = 6
end

local ring_scale = 0.52
local tower_offset = v(135, 135)

return {
	notifications = {
		enemy_hog_invader = {
			icon = "notification_enemies_0001",
			image = "encyclopedia_creeps_0001",
			template = "enemy"
		},
		enemy_tusked_brawler = {
			icon = "notification_enemies_0002",
			image = "encyclopedia_creeps_0002",
			template = "enemy"
		},
		enemy_turtle_shaman = {
			icon = "notification_enemies_0005",
			image = "encyclopedia_creeps_0005",
			template = "enemy"
		},
		enemy_bear_vanguard = {
			icon = "notification_enemies_0004",
			image = "encyclopedia_creeps_0003",
			template = "enemy"
		},
		enemy_cutthroat_rat = {
			icon = "notification_enemies_0007",
			image = "encyclopedia_creeps_0004",
			template = "enemy"
		},
		enemy_dreadeye_viper = {
			icon = "notification_enemies_0006",
			image = "encyclopedia_creeps_0007",
			template = "enemy"
		},
		enemy_surveyor_harpy = {
			icon = "notification_enemies_0010",
			image = "encyclopedia_creeps_0006",
			template = "enemy"
		},
		enemy_skunk_bombardier = {
			icon = "notification_enemies_0008",
			image = "encyclopedia_creeps_0009",
			template = "enemy"
		},
		enemy_hyena5 = {
			icon = "notification_enemies_0003",
			image = "encyclopedia_creeps_0008",
			template = "enemy"
		},
		enemy_rhino = {
			icon = "notification_enemies_0009",
			image = "encyclopedia_creeps_0010",
			template = "enemy"
		},
		boss_pig = {
			template = "enemy",
			image = "encyclopedia_creeps_0011"
		},
		enemy_acolyte = {
			icon = "notification_enemies_0011",
			image = "encyclopedia_creeps_0012",
			template = "enemy"
		},
		enemy_acolyte_tentacle = {
			template = "enemy",
			image = "encyclopedia_creeps_0013"
		},
		enemy_lesser_sister = {
			icon = "notification_enemies_0012",
			image = "encyclopedia_creeps_0014",
			template = "enemy"
		},
		enemy_lesser_sister_nightmare = {
			icon = "notification_enemies_0013",
			image = "encyclopedia_creeps_0015",
			template = "enemy"
		},
		enemy_blinker = {
			icon = "notification_enemies_0014",
			image = "encyclopedia_creeps_0016",
			template = "enemy"
		},
		enemy_unblinded_priest = {
			icon = "notification_enemies_0015",
			image = "encyclopedia_creeps_0017",
			template = "enemy"
		},
		enemy_unblinded_abomination = {
			icon = "notification_enemies_0016",
			image = "encyclopedia_creeps_0018",
			template = "enemy"
		},
		enemy_unblinded_abomination_stage_8 = {
			template = "enemy",
			image = "encyclopedia_creeps_0050"
		},
		enemy_unblinded_shackler = {
			icon = "notification_enemies_0017",
			image = "encyclopedia_creeps_0019",
			template = "enemy"
		},
		enemy_spiderling = {
			icon = "notification_enemies_0020",
			image = "encyclopedia_creeps_0023",
			template = "enemy"
		},
		enemy_armored_nightmare = {
			icon = "notification_enemies_0021",
			image = "encyclopedia_creeps_0022",
			template = "enemy"
		},
		enemy_corrupted_stalker = {
			icon = "notification_enemies_0018",
			image = "encyclopedia_creeps_0020",
			template = "enemy"
		},
		enemy_small_stalker = {
			icon = "notification_enemies_0029",
			image = "encyclopedia_creeps_0024",
			template = "enemy"
		},
		enemy_crystal_golem = {
			icon = "notification_enemies_0019",
			image = "encyclopedia_creeps_0021",
			template = "enemy"
		},
		boss_corrupted_denas = {
			template = "enemy",
			image = "encyclopedia_creeps_0026"
		},
		enemy_glareling = {
			icon = "notification_enemies_0022",
			image = "encyclopedia_creeps_0025",
			template = "enemy"
		},
		enemy_mindless_husk = {
			icon = "notification_enemies_0023",
			image = "encyclopedia_creeps_0027",
			template = "enemy"
		},
		enemy_vile_spawner = {
			icon = "notification_enemies_0024",
			image = "encyclopedia_creeps_0028",
			template = "enemy"
		},
		enemy_lesser_eye = {
			icon = "notification_enemies_0025",
			image = "encyclopedia_creeps_0031",
			template = "enemy"
		},
		enemy_hardened_horror = {
			icon = "notification_enemies_0026",
			image = "encyclopedia_creeps_0029",
			template = "enemy"
		},
		enemy_noxious_horror = {
			icon = "notification_enemies_0027",
			image = "encyclopedia_creeps_0030",
			template = "enemy"
		},
		enemy_evolving_scourge = {
			icon = "notification_enemies_0028",
			image = "encyclopedia_creeps_0032",
			template = "enemy"
		},
		enemy_amalgam = {
			icon = "notification_enemies_0030",
			image = "encyclopedia_creeps_0033",
			template = "enemy"
		},
		enemy_stage_11_cult_leader_illusion = {
			template = "enemy",
			image = "encyclopedia_creeps_0035"
		},
		boss_cult_leader = {
			template = "enemy",
			image = "encyclopedia_creeps_0036"
		},
		enemy_tower_ray_sheep = {
			template = "enemy",
			image = "encyclopedia_creeps_0037"
		},
		enemy_tower_ray_sheep_flying = {
			template = "enemy",
			image = "encyclopedia_creeps_0037"
		},
		controller_stage_16_overseer = {
			template = "enemy",
			image = "encyclopedia_creeps_0038"
		},
		enemy_bear_woodcutter = {
			template = "enemy",
			image = "encyclopedia_creeps_0039"
		},
		enemy_corrupted_elf = {
			icon = "notification_enemies_0031",
			image = "encyclopedia_creeps_0040",
			template = "enemy"
		},
		enemy_specter = {
			icon = "notification_enemies_0032",
			image = "encyclopedia_creeps_0041",
			template = "enemy"
		},
		enemy_dust_cryptid = {
			icon = "notification_enemies_0034",
			image = "encyclopedia_creeps_0042",
			template = "enemy"
		},
		enemy_bane_wolf = {
			icon = "notification_enemies_0033",
			image = "encyclopedia_creeps_0043",
			template = "enemy"
		},
		enemy_deathwood = {
			icon = "notification_enemies_0035",
			image = "encyclopedia_creeps_0044",
			template = "enemy"
		},
		enemy_animated_armor = {
			icon = "notification_enemies_0037",
			image = "encyclopedia_creeps_0045",
			template = "enemy"
		},
		enemy_revenant_soulcaller = {
			icon = "notification_enemies_0036",
			image = "encyclopedia_creeps_0046",
			template = "enemy"
		},
		enemy_pumpkin_witch = {
			template = "enemy",
			image = "encyclopedia_creeps_0047"
		},
		enemy_pumpkin_witch_flying = {
			template = "enemy",
			image = "encyclopedia_creeps_0047"
		},
		enemy_revenant_harvester = {
			icon = "notification_enemies_0038",
			image = "encyclopedia_creeps_0048",
			template = "enemy"
		},
		boss_navira = {
			template = "enemy",
			image = "encyclopedia_creeps_0049"
		},
		enemy_crocs_basic = {
			icon = "notification_enemies_0041",
			image = "encyclopedia_creeps_0054",
			template = "enemy"
		},
		enemy_crocs_basic_egg = {
			icon = "notification_enemies_0040",
			image = "encyclopedia_creeps_0053",
			template = "enemy"
		},
		enemy_quickfeet_gator = {
			icon = "notification_enemies_0043",
			image = "encyclopedia_creeps_0056",
			template = "enemy"
		},
		enemy_quickfeet_gator_chicken_leg = {
			template = "enemy",
			image = "encyclopedia_creeps_0056"
		},
		enemy_killertile = {
			icon = "notification_enemies_0042",
			image = "encyclopedia_creeps_0055",
			template = "enemy"
		},
		enemy_crocs_flier = {
			icon = "notification_enemies_0047",
			image = "encyclopedia_creeps_0057",
			template = "enemy"
		},
		enemy_crocs_ranged = {
			icon = "notification_enemies_0044",
			image = "encyclopedia_creeps_0058",
			template = "enemy"
		},
		enemy_crocs_shaman = {
			icon = "notification_enemies_0045",
			image = "encyclopedia_creeps_0062",
			template = "enemy"
		},
		enemy_crocs_tank = {
			icon = "notification_enemies_0046",
			image = "encyclopedia_creeps_0059",
			template = "enemy"
		},
		enemy_crocs_egg_spawner = {
			icon = "notification_enemies_0039",
			image = "encyclopedia_creeps_0060",
			template = "enemy"
		},
		enemy_crocs_hydra = {
			icon = "notification_enemies_0048",
			image = "encyclopedia_creeps_0061",
			template = "enemy"
		},
		boss_crocs_lvl1 = {
			template = "enemy",
			image = "encyclopedia_creeps_0063"
		},
		boss_crocs_lvl2 = {
			template = "enemy",
			image = "encyclopedia_creeps_0063"
		},
		boss_crocs_lvl3 = {
			template = "enemy",
			image = "encyclopedia_creeps_0063"
		},
		boss_crocs_lvl4 = {
			template = "enemy",
			image = "encyclopedia_creeps_0063"
		},
		boss_crocs_lvl5 = {
			template = "enemy",
			image = "encyclopedia_creeps_0063"
		},
		enemy_darksteel_hammerer = {
			icon = "notification_enemies_0055",
			image = "encyclopedia_creeps_0064",
			template = "enemy"
		},
		enemy_darksteel_shielder = {
			icon = "notification_enemies_0056",
			image = "encyclopedia_creeps_0065",
			template = "enemy"
		},
		enemy_surveillance_sentry = {
			icon = "notification_enemies_0059",
			image = "encyclopedia_creeps_0068",
			template = "enemy"
		},
		enemy_rolling_sentry = {
			icon = "notification_enemies_0058",
			image = "encyclopedia_creeps_0067",
			template = "enemy"
		},
		enemy_mad_tinkerer = {
			icon = "notification_enemies_0062",
			image = "encyclopedia_creeps_0072",
			template = "enemy"
		},
		enemy_scrap_drone = {
			icon = "notification_enemies_0063",
			image = "encyclopedia_creeps_0073",
			template = "enemy"
		},
		enemy_brute_welder = {
			icon = "notification_enemies_0060",
			image = "encyclopedia_creeps_0069",
			template = "enemy"
		},
		enemy_scrap_speedster = {
			icon = "notification_enemies_0057",
			image = "encyclopedia_creeps_0066",
			template = "enemy"
		},
		enemy_darksteel_fist = {
			icon = "notification_enemies_0061",
			image = "encyclopedia_creeps_0071",
			template = "enemy"
		},
		enemy_common_clone = {
			icon = "notification_enemies_0054",
			image = "encyclopedia_creeps_0075",
			template = "enemy"
		},
		enemy_darksteel_guardian = {
			icon = "notification_enemies_0066",
			image = "encyclopedia_creeps_0070",
			template = "enemy"
		},
		enemy_darksteel_anvil = {
			icon = "notification_enemies_0064",
			image = "encyclopedia_creeps_0074",
			template = "enemy"
		},
		enemy_darksteel_hulk = {
			icon = "notification_enemies_0065",
			image = "encyclopedia_creeps_0076",
			template = "enemy"
		},
		enemy_machinist = {
			icon = "notification_enemies_0067",
			image = "encyclopedia_creeps_0077",
			template = "enemy"
		},
		boss_machinist = {
			template = "enemy",
			image = "encyclopedia_creeps_0078"
		},
		enemy_deformed_grymbeard_clone = {
			icon = "notification_enemies_0068",
			image = "encyclopedia_creeps_0079",
			template = "enemy"
		},
		boss_grymbeard = {
			template = "enemy",
			image = "encyclopedia_creeps_0080"
		},
		enemy_spider_priest = {
			icon = "notification_enemies_0071",
			image = "encyclopedia_creeps_0083",
			template = "enemy"
		},
		enemy_ballooning_spider = {
			icon = "notification_enemies_0070",
			image = "encyclopedia_creeps_0082",
			template = "enemy"
		},
		enemy_ballooning_spider_flyer = {
			template = "enemy",
			image = "encyclopedia_creeps_0082"
		},
		enemy_spider_sister = {
			icon = "notification_enemies_0072",
			image = "encyclopedia_creeps_0084",
			template = "enemy"
		},
		enemy_glarenwarden = {
			icon = "notification_enemies_0074",
			image = "encyclopedia_creeps_0085",
			template = "enemy"
		},
		enemy_cultbrood = {
			icon = "notification_enemies_0075",
			image = "encyclopedia_creeps_0086",
			template = "enemy"
		},
		enemy_drainbrood = {
			icon = "notification_enemies_0076",
			image = "encyclopedia_creeps_0087",
			template = "enemy"
		},
		enemy_spidead = {
			icon = "notification_enemies_0077",
			image = "encyclopedia_creeps_0089",
			template = "enemy"
		},
		boss_spider_queen = {
			template = "enemy",
			image = "encyclopedia_creeps_0088"
		},
		TIP_ARMOR = {
			always = true,
			ach_flag = 1,
			template = "armored_enemies",
			ach_id = "ART_OF_WAR",
			icon = "alert_tip_0002"
		},
		TIP_RALLY = {
			always = true,
			ach_flag = 2,
			template = "rally_point",
			ach_id = "ART_OF_WAR",
			icon = "alert_tip_0001"
		},
		TIP_ARMOR_MAGIC = {
			always = true,
			ach_flag = 4,
			template = "magic_resistant_enemies",
			ach_id = "ART_OF_WAR",
			icon = "alert_tip_0003"
		},
		TIP_BOTTOM_INFO = {
			always = true,
			ach_flag = 8,
			template = "bottom_info",
			ach_id = "ART_OF_WAR",
			icon = "alert_tip_0004"
		},
		TIP_GLARE = {
			always = true,
			ach_flag = 16,
			template = "glare",
			ach_id = "ART_OF_WAR",
			icon = "alert_tip_0005"
		},
		POWER_REINFORCEMENT = {
			template = "specials",
			prefix = "POWER_SUMMON",
			always = true,
			image = "tutorial_powers_polaroids_0001",
			signals = {
				{
					"unlock-user-power",
					1
				}
			}
		},
		TUTORIAL_HERO = {
			template = "hero",
			always = true
		}
	},
	text_balloons = {
		TB_BUILD = {
			flags = "yellow_text centered",
			hide_cond = "tap_twice",
			scale_world = true,
			origin = "world",
			text = "INGAME_BALLOON_TAP_TWICE_BUILD",
			prefix = "tutorial_text_background",
			size = v(200, 58),
			padding = v(100, 8),
			offset = v(645, 610)
		},
		TB_POWER1 = {
			text = "INGAME_BALLOON_NEW_POWER",
			hide_cond = "power_selected_1",
			flags = "callout-bottom-add_as_child",
			origin = "id:power_button_1:top-center",
			scale_world = false,
			size = v(250, 58),
			offset = v(0, -10)
		},
		TB_POWER2 = {
			text = "INGAME_BALLOON_NEW_POWER",
			hide_cond = "power_selected_2",
			flags = "callout-bottom-add_as_child",
			origin = "id:power_button_2:top-center",
			scale_world = false,
			size = v(250, 58),
			offset = v(0, -10)
		},
		TB_POWER3 = {
			text = "INGAME_BALLOON_NEW_POWER",
			hide_cond = "custom_event_wait",
			flags = "callout-bottom-add_as_child",
			origin = "id:power_button_3:top-center",
			scale_world = false,
			size = v(250, 58),
			offset = v(0, -10)
		},
		TB_WAVE = {
			flags = "yellow_text centered right",
			hide_cond = "wave_sent",
			scale_world = true,
			origin = "world-middle-right-safe",
			text = "INGAME_BALLOON_TAP_TO_CALL",
			prefix = "tutorial_text_background",
			size = v(200, 58),
			padding = v(60, 8),
			offset = v(-90, 200)
		},
		TB_START = {
			flags = "yellow_text centered right",
			hide_cond = "wave_sent",
			scale_world = true,
			origin = "world",
			text = "INGAME_BALLOON_TAP_TWICE_WAVE",
			prefix = "tutorial_text_background",
			size = v(200, 58),
			padding = v(60, 8),
			offset = v(1050, 490)
		},
		TB_GOLD = {
			flags = "yellow_text",
			hide_cond = "custom_event_wait",
			scale_world = true,
			origin = "world",
			text = "INGAME_BALLOON_GOLD",
			prefix = "tutorial_text_background",
			size = v(200, 58),
			padding = v(60, 8),
			offset = v(680, 615)
		},
		TB_GOAL = {
			flags = "yellow_text centered",
			hide_cond = "custom_event_wait",
			scale_world = true,
			origin = "world-center-middle",
			text = "INGAME_BALLOON_GOAL",
			prefix = "tutorial_text_background",
			size = v(240, 58),
			padding = v(60, 8),
			offset = v(-440, 0)
		},
		TB_HERO2 = {
			text = "INGAME_BALLOON_NEW_HERO",
			hide_cond = "custom_event_wait",
			flags = "callout-bottom-left-add_as_child",
			scale_world = false,
			origin = "id:hero_portrait_2:top-center",
			size = v(200, 58),
			padding = v(60, 8),
			offset = v(0, -3)
		},
		LV01_ARBOREAN01 = {
			time = 3,
			origin = "world",
			flags = "callout-bottom-right centered dialog",
			text = "TAUNT_TUTORIAL_ARBOREAN_BARRACK_0001",
			size = v(200, 40),
			offset = v(980, 560),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV01_ARBOREAN02 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_TUTORIAL_ARBOREAN_ALL_0001",
			size = v(200, 40),
			offset = v(980, 560),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV02_VEZNAN01 = {
			time = 4,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE02_VEZNAN_0001",
			size = v(200, 40),
			offset = v(320, 395),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV02_VEZNAN02 = {
			time = 4,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE02_VEZNAN_0002",
			size = v(200, 40),
			offset = v(320, 395),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV02_RAELYN01 = {
			time = 1,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE02_RAELYN_0001",
			size = v(200, 40),
			offset = v(420, 400),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV06_CULTIST01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE06_CULTIST_GREETING_0001",
			size = v(200, 40),
			offset = v(630, 625),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV06_CULTIST02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE06_CULTIST_GREETING_0002",
			size = v(200, 40),
			offset = v(630, 625),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV06_BOSS01 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE06_BOSS_PIG_RESPONSE_0001",
			size = v(200, 40),
			offset = v(545, 625),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV06_BOSS02 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE06_BOSS_PIG_PREBATTLE_0001",
			size = v(200, 40),
			offset = v(545, 625),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV06_BOSS_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_BOSS_PIG_FROM_POOL_0001",
			size = v(200, 40),
			offset = v(545, 650),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV06_BOSS_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_BOSS_PIG_FROM_POOL_0002",
			size = v(200, 40),
			offset = v(545, 650),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV06_BOSS_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_BOSS_PIG_FROM_POOL_0003",
			size = v(200, 40),
			offset = v(545, 650),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV06_BOSS_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_BOSS_PIG_FROM_POOL_0004",
			size = v(200, 40),
			offset = v(545, 650),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV06_BOSS_TAUNT_05 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_BOSS_PIG_FROM_POOL_0005",
			size = v(200, 40),
			offset = v(545, 650),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV06_BOSS_TAUNT_06 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_BOSS_PIG_FROM_POOL_0006",
			size = v(200, 40),
			offset = v(545, 650),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV11_CULTIST01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_0001",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_0002",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST03 = {
			time = 2,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_0003",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST04 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_0004",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_VEZNAN01 = {
			time = 3,
			origin = "world",
			flags = "callout-left centered dialog",
			text = "TAUNT_STAGE11_VEZNAN_0001",
			size = v(200, 40),
			offset = v(113, 600),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV11_CULTIST05_ESCAPE = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_0005",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_FIGHT_0001",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_FIGHT_0002",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_FIGHT_0003",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_FIGHT_0004",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_05 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_FIGHT_0005",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_06 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_FIGHT_0006",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_IN_BOSSFIGHT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_IN_BOSSFIGHT_0001",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_IN_BOSSFIGHT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_IN_BOSSFIGHT_0002",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_IN_BOSSFIGHT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_IN_BOSSFIGHT_0003",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_IN_BOSSFIGHT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_IN_BOSSFIGHT_0004",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_IN_BOSSFIGHT_05 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_IN_BOSSFIGHT_0005",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV11_CULTIST_TAUNT_IN_BOSSFIGHT_06 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE11_CULTIST_LEADER_IN_BOSSFIGHT_0006",
			size = v(200, 40),
			offset = v(730, 504),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST01 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_0001",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST02 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_0002",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST03 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_0003",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST04 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_0004",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_DENAS01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE15_DENAS_0001",
			size = v(200, 40),
			offset = v(560, 490),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				0,
				204,
				204,
				255
			},
			line_color = {
				0,
				204,
				204,
				255
			}
		},
		LV15_CULTIST01_BOSSFIGHT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_BEFORE_BOSSFIGHT_0001",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST01_BOSSFIGHT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_BEFORE_BOSSFIGHT_0002",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST01_BOSSFIGHT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_BEFORE_BOSSFIGHT_0003",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST01_BOSSFIGHT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_BEFORE_BOSSFIGHT_0004",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST01_BOSSFIGHT_05 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_BEFORE_BOSSFIGHT_0005",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV15_CULTIST01_BOSSFIGHT_06 = {
			time = 3,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE15_CULTIST_BEFORE_BOSSFIGHT_0006",
			size = v(200, 40),
			offset = v(915, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				250,
				50,
				80,
				255
			},
			line_color = {
				250,
				50,
				80,
				255
			}
		},
		LV16_DENAS01_BOSSFIGHT_01 = {
			time = 2.5,
			origin = "world",
			flags = "callout-right-bottom centered dialog",
			text = "TAUNT_STAGE16_DENAS_AFTER_BOSSFIGHT_0001",
			size = v(200, 40),
			offset = v(510, 595),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				0,
				204,
				204,
				255
			},
			line_color = {
				0,
				204,
				204,
				255
			}
		},
		LV18_ERIDAN_PREPARATION_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_PREPARATION_0001",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_PREPARATION_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_PREPARATION_0002",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_PREPARATION_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_PREPARATION_0003",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_PREPARATION_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_PREPARATION_0004",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_FIGHT_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_FIGHT_0001",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_FIGHT_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_FIGHT_0002",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_FIGHT_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_FIGHT_0003",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_FIGHT_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_FIGHT_0004",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_FIGHT_TAUNT_05 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_FIGHT_0005",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_FIGHT_TAUNT_06 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_FIGHT_0006",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_FIGHT_TAUNT_07 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_FIGHT_0007",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV18_ERIDAN_FIGHT_TAUNT_08 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE18_ERIDAN_FIGHT_0008",
			size = v(200, 40),
			offset = v(225, 610),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				20,
				220,
				180,
				255
			},
			line_color = {
				20,
				220,
				180,
				255
			}
		},
		LV19_NAVIRA_START_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_START_0001",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_START_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_START_0002",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_START_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_START_0003",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_FIGHT_0001",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_FIGHT_0002",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_FIGHT_0003",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_FIGHT_0004",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_TAUNT_05 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_FIGHT_0005",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_TAUNT_06 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_FIGHT_0006",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_BEFORE_BOSSFIGHT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_BEFORE_BOSSFIGHT_0001",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_BEFORE_BOSSFIGHT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_BEFORE_BOSSFIGHT_0002",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV19_NAVIRA_BEFORE_BOSSFIGHT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE19_BOSS_NAVIRA_BEFORE_BOSSFIGHT_0003",
			size = v(200, 40),
			offset = v(810, 590),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				190,
				20,
				255
			},
			line_color = {
				255,
				190,
				20,
				255
			}
		},
		LV22_BOSS_BEFORE_FIGHT_EAT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_BEFORE_FIGHT_EAT_01",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_BOSS_BEFORE_FIGHT_EAT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_BEFORE_FIGHT_EAT_02",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_BOSS_BEFORE_FIGHT_EAT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_BEFORE_FIGHT_EAT_03",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_BOSS_BEFORE_FIGHT_EAT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_BEFORE_FIGHT_EAT_04",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_BOSS_BEFORE_FIGHT_EAT_05 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_BEFORE_FIGHT_EAT_05",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_BOSS_BEFORE_FIGHT_EAT_06 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_BEFORE_FIGHT_EAT_03",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_BOSS_BEFORE_FIGHT_EAT_07 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_BEFORE_FIGHT_EAT_04",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_BOSS_BEFORE_FIGHT_EAT_08 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_BEFORE_FIGHT_EAT_05",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_MAGE_BEFORE_FIGHT_RESPONSE_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_BEFORE_FIGHT_RESPONSE_01",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_MAGE_BEFORE_FIGHT_RESPONSE_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_BEFORE_FIGHT_RESPONSE_02",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_MAGE_BEFORE_FIGHT_RESPONSE_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_BEFORE_FIGHT_RESPONSE_03",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_MAGE_BEFORE_FIGHT_RESPONSE_04 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_BEFORE_FIGHT_RESPONSE_04",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_MAGE_BEFORE_FIGHT_RESPONSE_05 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_BEFORE_FIGHT_RESPONSE_05",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_MAGE_BEFORE_FIGHT_RESPONSE_06 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_BEFORE_FIGHT_RESPONSE_05",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_MAGE_BEFORE_FIGHT_RESPONSE_07 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_BEFORE_FIGHT_RESPONSE_05",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_MAGE_BEFORE_FIGHT_RESPONSE_08 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_BEFORE_FIGHT_RESPONSE_05",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_BOSS_INTRO_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_INTRO_01",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_BOSS_INTRO_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "LV22_BOSS_INTRO_02",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV22_MAGE_INTRO_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_INTRO_01",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		LV22_MAGE_INTRO_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "LV22_MAGE_INTRO_02",
			size = v(200, 40),
			offset = v(410, 540),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				107,
				255,
				10,
				255
			},
			line_color = {
				107,
				255,
				10,
				255
			}
		},
		TAUNT_STAGE22_BOSS_CROCS_BEFORE_BOSSFIGHT_0001 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE22_BOSS_CROCS_BEFORE_BOSSFIGHT_0001",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		TAUNT_STAGE22_BOSS_CROCS_BEFORE_BOSSFIGHT_0002 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_STAGE22_BOSS_CROCS_BEFORE_BOSSFIGHT_0002",
			size = v(200, 40),
			offset = v(494, 592),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV24_MACHINIST_BEFORE_BOSSFIGHT_01 = {
			time = 1.25,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE24_BOSS_MACHINIST_BEFORE_BOSSFIGHT_0001",
			size = v(200, 40),
			offset = v(20, 460),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV24_MACHINIST_BEFORE_BOSSFIGHT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE24_BOSS_MACHINIST_BEFORE_BOSSFIGHT_0002",
			size = v(200, 40),
			offset = v(0, 430),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV25_MACHINIST_END_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_STAGE25_BOSS_MACHINIST_END_0001",
			size = v(200, 40),
			offset = v(545, 450),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV25_MACHINIST_END_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_STAGE25_BOSS_MACHINIST_END_0002",
			size = v(200, 40),
			offset = v(545, 450),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_PREPARATION_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_PREPARATION_0001",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_PREPARATION_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_PREPARATION_0002",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_PREPARATION_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_PREPARATION_0003",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_PREPARATION_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_PREPARATION_0004",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_FIGHT_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_FIGHT_0001",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_FIGHT_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_FIGHT_0002",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_FIGHT_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_FIGHT_0003",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_FIGHT_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_FIGHT_0004",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_BEFORE_BOSSFIGHT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_BEFORE_BOSSFIGHT_0001",
			size = v(200, 40),
			offset = v(140, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_BEFORE_BOSSFIGHT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_BEFORE_BOSSFIGHT_0002",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_BEFORE_BOSSFIGHT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_BEFORE_BOSSFIGHT_0003",
			size = v(200, 40),
			offset = v(130, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_AFTER_BOSSFIGHT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_AFTER_BOSSFIGHT_0001",
			size = v(200, 40),
			offset = v(130, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV26_GRYMBEARD_AFTER_BOSSFIGHT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE26_BOSS_GRYMBEARD_AFTER_BOSSFIGHT_0002",
			size = v(200, 40),
			offset = v(130, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_PREPARATION_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_PREPARATION_0001",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_PREPARATION_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_PREPARATION_0002",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_PREPARATION_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_PREPARATION_0003",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_PREPARATION_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-left-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_PREPARATION_0004",
			size = v(200, 40),
			offset = v(135, 570),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_FIGHT_TAUNT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_FIGHT_0001",
			size = v(200, 40),
			offset = v(590, 630),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_FIGHT_TAUNT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_FIGHT_0002",
			size = v(200, 40),
			offset = v(590, 630),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_FIGHT_TAUNT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_FIGHT_0003",
			size = v(200, 40),
			offset = v(590, 630),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_FIGHT_TAUNT_04 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_FIGHT_0004",
			size = v(200, 40),
			offset = v(590, 630),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_FIGHT_TAUNT_05 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_FIGHT_0005",
			size = v(200, 40),
			offset = v(590, 630),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV27_GRYMBEARD_FIGHT_TAUNT_06 = {
			time = 3,
			origin = "world",
			flags = "callout-center-bottom centered dialog",
			text = "TAUNT_STAGE27_BOSS_GRYMBEARD_FIGHT_0006",
			size = v(200, 40),
			offset = v(590, 630),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				221,
				107,
				57,
				255
			},
			line_color = {
				221,
				107,
				57,
				255
			}
		},
		LV30_BOSS_INTRO_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_INTRO_01",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_INTRO_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_INTRO_02",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_INTRO_03 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_INTRO_03",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_PREFIGHT_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_PREFIGHT_01",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_PREFIGHT_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_PREFIGHT_02",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_PREFIGHT_03 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_PREFIGHT_03",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_ABILITY_01 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_ABILITY_01",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_ABILITY_02 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_ABILITY_02",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_ABILITY_03 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_ABILITY_03",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_ABILITY_04 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_ABILITY_04",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_ABILITY_05 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_ABILITY_05",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_ABILITY_06 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_ABILITY_06",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		},
		LV30_BOSS_ABILITY_07 = {
			time = 3,
			origin = "world",
			flags = "callout-center-top centered dialog",
			text = "TAUNT_LVL30_BOSS_ABILITY_07",
			size = v(200, 40),
			offset = v(533, 652),
			padding = v(40, 15),
			bg_color = {
				37,
				43,
				47,
				255
			},
			text_color = {
				255,
				50,
				80,
				255
			},
			line_color = {
				255,
				50,
				80,
				255
			}
		}
	},
	tower_menu_button_places = {
		v(-92 * ring_scale, -146 * ring_scale),
		v(92 * ring_scale, -146 * ring_scale),
		v(-153 * ring_scale, 31 * ring_scale),
		v(153 * ring_scale, 31 * ring_scale),
		v(0 * ring_scale, 155 * ring_scale),
		v(-124 * ring_scale, -123 * ring_scale),
		v(124 * ring_scale, -123 * ring_scale),
		v(149 * ring_scale, 75 * ring_scale),
		v(0 * ring_scale, 155 * ring_scale),
		v(-92 * ring_scale, -146 * ring_scale),
		v(92 * ring_scale, -146 * ring_scale),
		v(0 * ring_scale, -155 * ring_scale),
		v(-145 * ring_scale, 78 * ring_scale)
	},
	tower_menu_power_places = {
		v(30, 0.8),
		v(50.8, 9.6),
		v(58.8, 29.6)
	},
	range_center_offset = v(0, -12),
	damage_icons = {
		default = "icon_0007",
		magic = "icon_0010",
		sword = "icon_0007",
		fireball = "icon_0013",
		arrow = "icon_0011",
		shot = "icon_0012",
		[DAMAGE_TRUE] = "icon_0007",
		[DAMAGE_PHYSICAL] = "icon_0007",
		[DAMAGE_MAGICAL] = "icon_0010",
		[DAMAGE_EXPLOSION] = "icon_0007"
	},
	power_button_block_styles = {
		drow_queen = {
			image = "malicia_powerNet_0001",
			animations = {
				block = {
					to = 14,
					prefix = "malicia_powerNet",
					from = 1
				},
				unblock = {
					to = 20,
					prefix = "malicia_powerNet",
					from = 15
				}
			}
		},
		eb_spider = {
			image = "spiderQueen_powerNet_0001",
			animations = {
				block = {
					to = 14,
					prefix = "spiderQueen_powerNet",
					from = 1
				},
				unblock = {
					to = 20,
					prefix = "spiderQueen_powerNet",
					from = 15
				}
			}
		}
	}
}
