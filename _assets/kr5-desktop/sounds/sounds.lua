-- chunkname: @C:\\Users\\dev02\\Desktop\\Customized KR5\\Kingdom Rush Alliance\\_assets\\kr5-desktop\\sounds\\sounds.lua

return {
	AreaAttack = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Sound_CommonAreaHit.ogg"
		}
	},
	ArrowSound = {
		source_group = "BULLETS",
		mode = "random",
		loop = false,
		files = {
			"Sound_ArrowRelease2.ogg",
			"Sound_ArrowRelease3.ogg",
			"kra_sfx_combat_rangedAttack_arrows_var1_v1.ogg",
			"kra_sfx_combat_rangedAttack_arrows_var3_v1.ogg",
			"kra_sfx_combat_rangedAttack_arrows_var4_v1.ogg"
		},
		gain = {
			0.65,
			0.8
		}
	},
	BoltSound = {
		loop = false,
		gain = 0.68,
		source_group = "BULLETS",
		files = {
			"Sound_MageShot.ogg"
		}
	},
	BombExplosionSound = {
		loop = false,
		gain = 0.8,
		source_group = "EXPLOSIONS",
		files = {
			"Sound_Bomb1.ogg"
		}
	},
	BombShootSound = {
		loop = false,
		gain = 0.75,
		source_group = "EXPLOSIONS",
		files = {
			"Sound_EngineerShot.ogg"
		}
	},
	CommonNoSwordAttack = {
		source_group = "SFX",
		gain = 0.75,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_combat_meleeAttack_noSword_var1.ogg",
			"kra_sfx_combat_meleeAttack_noSword_var6.ogg",
			"kra_sfx_combat_meleeAttack_noSword_var5.ogg",
			"kra_sfx_combat_meleeAttack_noSword_var4.ogg",
			"kra_sfx_combat_meleeAttack_noSword_var3.ogg",
			"kra_sfx_combat_meleeAttack_noSword_var2.ogg"
		}
	},
	CommonLightning = {
		source_group = "SFX",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kr5_sfx_lightning_op1.ogg",
			"kr5_sfx_lightning_op2.ogg",
			"kr5_sfx_lightning_op3.ogg"
		}
	},
	DeathEplosion = {
		loop = false,
		gain = 0.4,
		source_group = "DEATH",
		files = {
			"Sound_EnemyExplode1.ogg"
		}
	},
	DeathHuman = {
		loop = false,
		mode = "random",
		source_group = "DEATH",
		files = {
			"Sound_HumanDead1.ogg",
			"Sound_HumanDead2.ogg",
			"Sound_HumanDead3.ogg",
			"Sound_HumanDead4.ogg"
		}
	},
	GUISplash = {
		source_group = "GUI",
		gain = 1,
		loop = false,
		delay = 0,
		files = {
			"KR5_SFX_IronhideLogo_24042024.ogg"
		}
	},
	GUIAchievementWin = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_AchievementWin.ogg"
		}
	},
	GUIButtonCommon = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_genericbuttonsoft_op1.ogg"
		}
	},
	GUIButtonUnavailable = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_buttonUnavailable_v1.ogg"
		}
	},
	GUIBuyUpgrade = {
		loop = false,
		gain = 0.6,
		source_group = "GUI",
		files = {
			"Sound_GUIBuyUpgrade.ogg"
		}
	},
	GUICoins = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_Coins.ogg"
		}
	},
	GUILooseLife = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_LooseLife.ogg"
		}
	},
	GUIMapNewFlah = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_MapNewFlag.ogg"
		}
	},
	GUINextWaveIncoming = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_WaveIncoming.ogg"
		}
	},
	GUINextWaveReady = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_NextWaveReady.ogg"
		}
	},
	GUINotificationClose = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_NotificationClose.ogg"
		}
	},
	GUINotificationOpen = {
		loop = false,
		gain = 0.8,
		source_group = "GUI",
		files = {
			"Sound_NotificationOpen.ogg"
		}
	},
	GUINotificationPaperOver = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_NotificationPaperOver.ogg"
		}
	},
	GUINotificationSecondLevel = {
		loop = false,
		gain = 0.8,
		source_group = "GUI",
		files = {
			"Sound_NotificationSecondLevel.ogg"
		}
	},
	GUIPlaceRallyPoint = {
		loop = false,
		gain = 0.8,
		source_group = "GUI",
		files = {
			"Sound_RallyPointPlaced.ogg"
		}
	},
	GUIQuestCompleted = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_stageVictory_v1.ogg"
		}
	},
	GUIQuestFailed = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_stageDefeat_v1.ogg"
		}
	},
	GUIQuickMenuOpen = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_GUIOpenTowerMenu.ogg"
		}
	},
	GUIQuickMenuOver = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_GUIMouseOverTowerIcon.ogg"
		}
	},
	GUISpellRefresh = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_SpellRefresh.ogg"
		}
	},
	GUISpellSelect = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_SpellSelect.ogg"
		}
	},
	GUITowerBuilding = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_TowerBuilding.ogg"
		}
	},
	GUITowerOpenDoor = {
		source_group = "GUI",
		gain = 0.2,
		loop = false,
		delay = 0.2,
		files = {
			"kra_sfx_tower_paladinCovenant_deploy_v1.ogg"
		}
	},
	GUITowerSell = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_TowerSell.ogg"
		}
	},
	GUITransitionClose = {
		source_group = "GUI",
		gain = 1,
		loop = false,
		delay = 0.1,
		files = {
			"kr5_sfx_UIgate-close.ogg"
		}
	},
	GUITransitionOpen = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_UIgate-open_op1.ogg"
		}
	},
	GUIWinStars = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		interruptible = true,
		files = {
			"kr5_sfx_victorystars_3_v1.ogg"
		}
	},
	GuimapNewRoad = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"Sound_MapRoad.ogg"
		}
	},
	GUIAchievementClaim = {
		ignore = 0.2,
		gain = 0.8,
		loop = false,
		source_group = "GUI",
		files = {
			"kr5_sfx_achievementcollect.ogg"
		}
	},
	GUICardPreGlow = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_rewards_unlock_glow_v1.ogg"
		}
	},
	GUICardAppear = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_rewards_unlock_appear-stomp_v1.ogg"
		}
	},
	GUICardUnlock = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_rewards_unlock_cardReveal_v1.ogg"
		}
	},
	GUICardUnlockFade = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_rewards_disappear_var1_v1.ogg",
			"kra_sfx_ui_rewards_disappear_var2_v1.ogg",
			"kra_sfx_ui_rewards_disappear_var3_v1.ogg"
		}
	},
	GUIEquip = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_heroselect_op2.ogg"
		}
	},
	GUIBalloonIn = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_balloon-in.ogg"
		}
	},
	GUIBalloonOut = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_balloon-out.ogg"
		}
	},
	GUIFlagFall = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_flagfall.ogg"
		}
	},
	GUIButtonSoft1 = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_genericbuttonsoft_op1.ogg"
		}
	},
	GUIButtonSoft2 = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_genericbuttonsoft_op2.ogg"
		}
	},
	GUIHeroScroll = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_heroscroll_op1.ogg"
		}
	},
	GUIHeroSelect = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_heroselect_op1.ogg"
		}
	},
	GUIHeroSkillConfirm = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_heroskillconfirm.ogg"
		}
	},
	GUIHeroSkillSelect = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr5_sfx_heroskillselect.ogg"
		}
	},
	HeroLevelUp = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroReinforcementTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroReinforcementTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Reinforcement-01a.ogg"
		}
	},
	HitSound = {
		loop = false,
		gain = 0.15,
		source_group = "BULLETS",
		files = {
			"Sound_ArrowHit2.ogg",
			"Sound_ArrowHit3.ogg"
		}
	},
	InAppBuyGems = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"inapp_cash.ogg"
		}
	},
	InAppBuyInApp = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"inapp_chin.ogg"
		}
	},
	InAppEarnGems = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"inapp_gems.ogg"
		}
	},
	InAppExtraGold = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"inapp_gnome.ogg"
		}
	},
	GUIRewardUnlockCardAppear = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_rewards_unlock_cardAppear_v1.ogg"
		}
	},
	GUIRewardUnlockPreGlow = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_rewards_unlock_pre-glow_v1.ogg"
		}
	},
	GUIRewardUnlockCardUnlock = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_rewards_unlock_op1_v1.ogg"
		}
	},
	GUIMapDotsAppear = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_mapDotsAppear_op2_v2.ogg"
		}
	},
	GUIMapStageFlagAppear = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_stageFlagAppear_v1.ogg"
		}
	},
	GUIMapStageFlagHeroicWings = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_uiMap_heroicChallengeFlag_v1.ogg"
		}
	},
	GUIMapCultistBridgeAppear = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		delay = 0.7,
		files = {
			"kra_sfx_uiMap_cultistBridge_op2_v1.ogg"
		}
	},
	GUIMapCloudRemoval = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		delay = 1.5,
		files = {
			"kra_sfx_uiMap_cloudRemoval_v1.ogg"
		}
	},
	GUIButtonHover = {
		source_group = "GUI",
		gain = 0.2,
		ignore = 0.1,
		loop = false,
		files = {
			"kra_sfx_uiMenu_hover_op1_v1.ogg"
		}
	},
	GUIButtonOut = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_buttonOut_op2_v2.ogg"
		}
	},
	GUIResetUpgrade = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_resetSkills_v1.ogg"
		}
	},
	GUIHeroTowerSelect = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_heroTowerSelect_v1.ogg"
		}
	},
	GUITowerWheelTapOn = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_towerWheelDrag_tapOn_v1.ogg"
		}
	},
	GUITowerWheelTapOff = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_towerWheelDrag_tapOff_v1.ogg"
		}
	},
	GUIStageVictory = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_stageVictory_v1.ogg"
		}
	},
	GUIStageDefeat = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_stageDefeat_v1.ogg"
		}
	},
	GUIGemCounterSingle = {
		ignore = 0.1,
		gain = 0.7,
		loop = false,
		source_group = "GUI",
		files = {
			"kra_sfx_ui_gemCounter_SINGLE_v1.ogg"
		}
	},
	HeroVesperTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_vesper_taunt2.ogg",
			"kr_voice_vesper_taunt3.ogg",
			"kr_voice_vesper_taunt4.ogg",
			"kr_voice_vesper_taunt.ogg"
		}
	},
	HeroVesperTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_vesper_taunt.ogg"
		}
	},
	HeroVesperTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_vesper_taunt.ogg"
		}
	},
	HeroVesperDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_vesper_death_var1d.ogg"
		}
	},
	HeroVesperArrowToTheKneeCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_vesper_arrowToTheKnee_cast_v1.ogg"
		}
	},
	HeroVesperArrowToTheKneeImpact = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_vesper_arrowToTheKnee_impact_op1_v1.ogg"
		}
	},
	HeroVesperRicochetCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_vesper_ricochet_cast_v1.ogg"
		}
	},
	HeroVesperRicochetImpact = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_heroes_vesper_ricochet_impact_var1_v1.ogg",
			"kra_heroes_vesper_ricochet_impact_var2_v1.ogg",
			"kra_heroes_vesper_ricochet_impact_var3_v1.ogg"
		}
	},
	HeroVesperMartialFlourishCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_vesper_oneShot_martialFlourish_v1.ogg"
		}
	},
	HeroVesperDisengageCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_vesper_disengage_v1.ogg"
		}
	},
	HeroVesperUltimateLvl1 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_vesper_arrowStorm_low_v1.ogg"
		}
	},
	HeroVesperUltimateLvl2 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_vesper_arrowStorm_mid_v1.ogg"
		}
	},
	HeroVesperUltimateLvl3 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_vesper_arrowStorm_high_v1.ogg"
		}
	},
	HeroNyruTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_nyru_taunt2_var1c.ogg",
			"kr_voice_nyru_taunt3_var1a.ogg",
			"kr_voice_nyru_taunt4_var1a.ogg",
			"kr_voice_nyru_taunt_var1c.ogg"
		}
	},
	HeroNyruTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_nyru_taunt2_var1c.ogg"
		}
	},
	HeroNyruTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_nyru_taunt2_var1c.ogg"
		}
	},
	HeroNyruDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_nyru_death_var1a.ogg"
		}
	},
	HeroNyruSentinelWispsCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_sentinelWisps_cast_v1.ogg"
		}
	},
	HeroNyruSentinelWispsSpawn = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_sentinelWisps_spawn_v1.ogg"
		}
	},
	HeroNyruSentinelWispsShoot = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_heroes_nyru_sentinelWisps_attack_var1_v1.ogg",
			"kra_heroes_nyru_sentinelWisps_attack_var3_v1.ogg"
		}
	},
	HeroNyruVerdantBlastCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_verdantBlast_cast_oneShot_v1.ogg"
		}
	},
	HeroNyruVerdantBlastHit = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_verdantBlast_impact_v1.ogg"
		}
	},
	HeroNyruLeafWhirlwindCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_leafWhirlwind_op1_v2.ogg"
		}
	},
	HeroNyruFairyDustCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_fairyDust_v1.ogg"
		}
	},
	HeroNyruRootDefenderStartLvl1 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_rootDefender_low_v1.ogg"
		}
	},
	HeroNyruRootDefenderStartLvl2 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_rootDefender_mid_v1.ogg"
		}
	},
	HeroNyruRootDefenderStartLvl3 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_rootDefender_high_v1.ogg"
		}
	},
	HeroNyruRootDefenderEnd = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_rootDefender_retract_v1.ogg"
		}
	},
	HeroNyruTreewalk = {
		loop = true,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_treewalk_LOOP_var2_v2.ogg"
		}
	},
	HeroNyruBasicAttackRanged = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_heroes_nyru_basicAttack_ranged_var1_v1.ogg",
			"kra_heroes_nyru_basicAttack_ranged_var2_v1.ogg",
			"kra_heroes_nyru_basicAttack_ranged_var3_v1.ogg"
		}
	},
	HeroNyruBasicAttackMelee = {
		loop = false,
		mode = "random",
		gain = 0.1,
		source_group = "SFX",
		delay = 0.25,
		files = {
			"kra_heroes_nyru_basicAttack_melee_var1_op1_v1.ogg",
			"kra_heroes_nyru_basicAttack_melee_var2_op1_v1.ogg",
			"kra_heroes_nyru_basicAttack_melee_var3_op1_v1.ogg"
		}
	},
	HeroRaelynTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_raelyn_taunt_var1c.ogg",
			"kr_voice_raelyn_taunt2_var2a.ogg",
			"kr_voice_raelyn_taunt3_var2b.ogg",
			"kr_voice_raelyn_taunt4_var1a.ogg"
		}
	},
	HeroRaelynTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_raelyn_taunt3_var2b.ogg"
		}
	},
	HeroRaelynTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_raelyn_taunt3_var2b.ogg"
		}
	},
	HeroRaelynDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_raelyn_death_var1e.ogg"
		}
	},
	HeroRaelynUnbreakableCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_raelyn_unbreakable_op1_v1.ogg"
		}
	},
	HeroRaelynInspireFearCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_raelyn_inspireFear_op2_v1.ogg"
		}
	},
	HeroRaelynBrutalSlashCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_raelyn_brutalSlash_op2_v1.ogg"
		}
	},
	HeroRaelynOnslaughtCast = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.2,
		files = {
			"kra_sfx_heroes_raelyn_onslaught_var3_v1.ogg"
		}
	},
	HeroRaelynBasicAttack = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.2,
		files = {
			"kra_sfx_heroes_raelyn_basicAttack_var1_v1.ogg"
		}
	},
	HeroRaelynUltimateCast = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_raelyn_commandOrders_v2_op1.ogg"
		}
	},
	HeroRaelynUltimateTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_darkknight_taunt01_d.ogg",
			"kr_voice_darkknight_taunt02_c.ogg"
		}
	},
	HeroRaelynUltimateDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_raelyn_commandOrders_death_v1.ogg"
		}
	},
	HeroSpaceElfTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_theriennethevoidadept_select_c.ogg",
			"kr_voice_theriennethevoidadept_taunt01_d.ogg",
			"kr_voice_theriennethevoidadept_taunt02_c.ogg",
			"kr_voice_theriennethevoidadept_taunt03_b.ogg"
		}
	},
	HeroSpaceElfTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_theriennethevoidadept_select_c.ogg"
		}
	},
	HeroSpaceElfTauntSelect = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_theriennethevoidadept_select_c.ogg"
		}
	},
	HeroSpaceElfDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_theriennethevoidadept_death_h.ogg"
		}
	},
	HeroSpaceElfAstralReflection = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_astralReflection_v1.ogg"
		}
	},
	HeroSpaceElfBlackAegis = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_blackAegis_cast_v1.ogg"
		}
	},
	HeroSpaceElfBlackAegisExplosion = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_blackAegis_explosion.ogg"
		}
	},
	HeroSpaceElfVoidRift = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_voidRift_cast_v1.ogg"
		}
	},
	HeroSpaceElfSpatialDistortion = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_spatialDistortion_cast_v1.ogg"
		}
	},
	HeroSpaceElfTeleportIn = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_teleportIn_v1.ogg"
		}
	},
	HeroSpaceElfTeleportOut = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_teleportOut_v1.ogg"
		}
	},
	HeroSpaceElfCosmicPrisonIn = {
		loop = false,
		gain = 0.2,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_cosmicPrison_phaseIn_v1.ogg"
		}
	},
	HeroSpaceElfCosmicPrisonOut = {
		loop = false,
		gain = 0.3,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_therien_cosmicPrison_phaseOut_v1.ogg"
		}
	},
	HeroBuilderTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_torrestheforeman_select_a.ogg",
			"kr_voice_torrestheforeman_taunt01_c.ogg",
			"kr_voice_torrestheforeman_taunt02_b.ogg",
			"kr_voice_torrestheforeman_taunt03_e.ogg"
		}
	},
	HeroBuilderTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_torrestheforeman_select_a.ogg"
		}
	},
	HeroBuilderTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_torrestheforeman_select_a.ogg"
		}
	},
	HeroBuilderDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_torrestheforeman_death_a.ogg"
		}
	},
	HeroBuilderBasicAttack = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_heroes_nyru_basicAttack_melee_var1_op1_v1.ogg"
		}
	},
	HeroBuilderWreckingBall = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_torres_wreckingBall_v1.ogg"
		}
	},
	HeroBuilderMenAtWork = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_torres_menAtWork_v1.ogg"
		}
	},
	HeroBuilderDemolitionMan = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_torres_demolitionMan_spin_v1.ogg"
		}
	},
	HeroBuilderLunchBreak = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_torres_lunchBreak_v1.ogg"
		}
	},
	HeroBuilderDefensiveTurretCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_torres_defensiveTurret_cast_v1.ogg"
		}
	},
	HeroBuilderDefensiveTurretDestroy = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_torres_defensiveTurret_destroy_v1.ogg"
		}
	},
	HeroMechaTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_onagro_taunt_a.ogg",
			"kr_voice_onagro_taunt02_a.ogg",
			"kr_voice_onagro_taunt03_e.ogg",
			"kr_voice_onagro_taunt04_c.ogg"
		}
	},
	HeroMechaTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_onagro_taunt_a.ogg"
		}
	},
	HeroMechaTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_onagro_taunt_a.ogg"
		}
	},
	HeroMechaDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_onagro_death_c.ogg"
		}
	},
	HeroMechaBasicAttack = {
		loop = false,
		mode = "random",
		gain = 0.6,
		source_group = "SFX",
		delay = 0.3,
		files = {
			"kra_sfx_heroes_onagro_basicAttack_cast_var1_v1.ogg",
			"kra_sfx_heroes_onagro_basicAttack_cast_var2_v1.ogg",
			"kra_sfx_heroes_onagro_basicAttack_cast_var3_v1.ogg"
		}
	},
	HeroMechaBasicAttackHit = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_onagro_basicAttack_impact_var1_v1.ogg",
			"kra_sfx_heroes_onagro_basicAttack_impact_var2_v1.ogg",
			"kra_sfx_heroes_onagro_basicAttack_impact_var3_v1.ogg"
		}
	},
	HeroMechaGoblidroneCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_goblidrone_cast_v1.ogg"
		}
	},
	HeroMechaGoblidroneAttack = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_goblidrone_attack_var1_v1.ogg",
			"kra_sfx_heroes_goblidrone_attack_var2_v1.ogg",
			"kra_sfx_heroes_goblidrone_attack_var3_v1.ogg",
			"kra_sfx_heroes_goblidrone_attack_var4_v1.ogg"
		}
	},
	HeroMechaMineDropCast = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 1.7,
		files = {
			"kra_sfx_heroes_mineDrop_cast_var1_v1.ogg",
			"kra_sfx_heroes_mineDrop_cast_var2_v1.ogg",
			"kra_sfx_heroes_mineDrop_cast_var3_v1.ogg"
		}
	},
	HeroMechaMineDropExplosion = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_mineDrop_explosion_v2.ogg"
		}
	},
	HeroMechaDeathFromAboveCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_onagro_deathFromAbove_cast_v1.ogg"
		}
	},
	HeroMechaDeathFromAboveAttack = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_onagro_deathFromAbove_attack_shot_var1_v1.ogg",
			"kra_sfx_heroes_onagro_deathFromAbove_attack_shot_var2_v1.ogg",
			"kra_sfx_heroes_onagro_deathFromAbove_attack_shot_var3_v1.ogg"
		}
	},
	HeroMechaDeathFromAboveExplosion = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_onagro_deathFromAbove_attack_explosion_var1_v1.ogg",
			"kra_sfx_heroes_onagro_deathFromAbove_attack_explosion_var2_v1.ogg",
			"kra_sfx_heroes_onagro_deathFromAbove_attack_explosion_var3_v1.ogg"
		}
	},
	HeroMechaPowerSlamCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_powerSlam_cast_v1.ogg"
		}
	},
	HeroMechaTarBombCast = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_tarBomb_cast_var1_v1.ogg",
			"kra_sfx_heroes_tarBomb_cast_var2_v1.ogg",
			"kra_sfx_heroes_tarBomb_cast_var3_v1.ogg"
		}
	},
	HeroMechaTarBombExplosion = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_tarBomb_explosion_v1.ogg"
		}
	},
	HeroLumenirTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_lumenir_taunt03_a.ogg",
			"kr_voice_lumenir_taunt_b.ogg",
			"kr_voice_lumenir_taunt02_c.ogg",
			"kr_voice_lumenir_taunt04_a.ogg"
		}
	},
	HeroLumenirTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_lumenir_taunt03_a.ogg"
		}
	},
	HeroLumenirTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_lumenir_taunt03_a.ogg"
		}
	},
	HeroLumenirDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_lumenir_death_c.ogg"
		}
	},
	HeroLumenirBasicAttack = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_lumenir_basicAttack_cast_var1_op2_v1.ogg",
			"kra_sfx_heroes_lumenir_basicAttack_cast_var2_op2_v1.ogg",
			"kra_sfx_heroes_lumenir_basicAttack_cast_var3_op2_v1.ogg"
		}
	},
	HeroLumenirBlessingOfRetributionCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_lumenir_blessingOfRetribution_cast_v1.ogg"
		}
	},
	HeroLumenirCallOfTriumphCast = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_lumenir_callOfTriumph_cast_var1_v2.ogg",
			"kra_sfx_heroes_lumenir_callOfTriumph_cast_var2_v2.ogg",
			"kra_sfx_heroes_lumenir_callOfTriumph_cast_var3_v2.ogg"
		}
	},
	HeroLumenirCallOfTriumphOut = {
		source_group = "SFX",
		gain = 0.9,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_lumenir_callOfTriumph_out_var1_v1.ogg",
			"kra_sfx_heroes_lumenir_callOfTriumph_out_var2_v1.ogg",
			"kra_sfx_heroes_lumenir_callOfTriumph_out_var3_v1.ogg"
		}
	},
	HeroLumenirCelestialJudgementCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_lumenir_celestialJudgement_cast_v1.ogg"
		}
	},
	HeroLumenirCelestialJudgementImpact = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_lumenir_celestialJudgement_impact_v2_op2.ogg"
		}
	},
	HeroLumenirRadiantWaveCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_lumenir_radiantWave_cast_v1.ogg"
		}
	},
	HeroLumenirLightCompanionCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_lumenir_lightCompanion_cast_v1.ogg"
		}
	},
	HeroLumenirLightCompanionBasicAttack = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_lumenir_lightCompanion_basicAttack_var1_v1.ogg",
			"kra_sfx_heroes_lumenir_lightCompanion_basicAttack_var2_v1.ogg",
			"kra_sfx_heroes_lumenir_lightCompanion_basicAttack_var3_v1.ogg"
		}
	},
	HeroVenomTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_grimson_taunt_b.ogg",
			"kr_voice_grimson_taunt02_b.ogg",
			"kr_voice_grimson_taunt03_b.ogg",
			"kr_voice_grimson_taunt04_c.ogg"
		}
	},
	HeroVenomTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_grimson_taunt_b.ogg"
		}
	},
	HeroVenomTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_grimson_taunt_b.ogg"
		}
	},
	HeroVenomDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_grimson_death_b.ogg"
		}
	},
	HeroVenomBasicAttack = {
		source_group = "SFX",
		gain = 0.3,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_grimson_basicAttack_var1_v1.ogg",
			"kra_sfx_heroes_grimson_basicAttack_var2_v1.ogg",
			"kra_sfx_heroes_grimson_basicAttack_var3_v1.ogg"
		}
	},
	HeroVenomHeartseekerCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_grimson_heartseeker_cast_v1.ogg"
		}
	},
	HeroVenomInnerBeastCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_grimson_innerBeast_cast_v1.ogg"
		}
	},
	HeroVenomInnerBeastOut = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_grimson_innerBeast_out_v1.ogg"
		}
	},
	HeroVenomDeadlySpikesCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_grimson_deadlySpikes_cast_v1.ogg"
		}
	},
	HeroVenomDeadlySpikesOut = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_grimson_deadlySpikes_out_v1.ogg"
		}
	},
	HeroVenomRenewFleshCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_grimson_renewFlesh_cast_v1.ogg"
		}
	},
	HeroVenomRenewCreepingDeathCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_grimson_creepingDeath_cast_v1.ogg"
		}
	},
	HeroVenomRenewCreepingDeathSpikes = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_grimson_creepingDeath_spikes_v1.ogg"
		}
	},
	HeroRobotTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_warhead_taunt01_b.ogg",
			"kr_voice_warhead_taunt02_a.ogg",
			"kr_voice_warhead_taunt03_a.ogg"
		}
	},
	HeroRobotTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_warhead_select_b.ogg"
		}
	},
	HeroRobotTauntSelect = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_warhead_select_b.ogg"
		}
	},
	HeroRobotDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_warhead_death_c.ogg"
		}
	},
	HeroRobotDeepImpactCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_hero_warhead_deepImpact_cast_v1.ogg"
		}
	},
	HeroRobotDeepImpactImpact = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_hero_warhead_deepImpact_impact_v1.ogg"
		}
	},
	HeroRobotSmokescreenCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_warhead_smokescreen_cast_wSomeScreen_v1.ogg"
		}
	},
	HeroRobotImmolationCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_warhead_immolation_cast_v1.ogg"
		}
	},
	HeroRobotUppercutCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_warhead_uppercut_cast_v1.ogg"
		}
	},
	HeroRobotJetpackCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_warhead_jetpack_oneShot_v1.ogg"
		}
	},
	HeroRobotMotorheadCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_warhead_motorhead_cast-march_v1.ogg"
		}
	},
	HeroHunterTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_anya_select_c.ogg",
			"kr_voice_anya_taunt_a.ogg",
			"kr_voice_anya_taunt02_a.ogg",
			"kr_voice_anya_taunt03_b.ogg"
		}
	},
	HeroHunterTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_anya_select_c.ogg"
		}
	},
	HeroHunterTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_anya_select_c.ogg"
		}
	},
	HeroHunterDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_anya_death_d.ogg"
		}
	},
	HeroHunterBasicAttack = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_anya_basicAttack_var1_v1.ogg",
			"kra_sfx_heroes_anya_basicAttack_var2_v1.ogg",
			"kra_sfx_heroes_anya_basicAttack_var3_v1.ogg"
		}
	},
	HeroHunterHealStrikeCast = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_anya_vampiricStrike_cast_var1_v1.ogg",
			"kra_sfx_heroes_anya_vampiricStrike_cast_var2_v1.ogg",
			"kra_sfx_heroes_anya_vampiricStrike_cast_var3_v1.ogg"
		}
	},
	HeroHunterRicochetCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_anya_mistyStep_cast_v1.ogg"
		}
	},
	HeroHunterRicochetBounce = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_anya_mistyStep_bounce_op1_v1.ogg"
		}
	},
	HeroHunterShootAroundCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		interruptible = true,
		files = {
			"kra_sfx_heroes_anya_argentStorm_shot_op1_v1.ogg"
		}
	},
	HeroHunterShootAroundInterrupt = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_anya_argentStorm_fadeOut_v1.ogg"
		}
	},
	HeroHunterBeastsCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_anya_duskBeasts_cast_v1.ogg"
		}
	},
	HeroHunterUltimateCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_anya_huntersAid_cast_v1.ogg"
		}
	},
	HeroHunterUltimateAttack = {
		loop = false,
		gain = 0.7,
		mode = "random",
		source_group = "SFX",
		delay = 0.2,
		files = {
			"kra_sfx_heroes_anya_huntersAid_attack_op2_var1_v1.ogg",
			"kra_sfx_heroes_anya_huntersAid_attack_op2_var2_v1.ogg",
			"kra_sfx_heroes_anya_huntersAid_attack_op2_var3_v1.ogg"
		}
	},
	HeroDragonGemTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_kosmyr_select_c.ogg",
			"kr_voice_kosmyr_taunt01_a.ogg",
			"kr_voice_kosmyr_taunt02_a.ogg",
			"kr_voice_kosmyr_taunt03_a.ogg"
		}
	},
	HeroDragonGemTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_kosmyr_select_c.ogg"
		}
	},
	HeroDragonGemTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_kosmyr_select_c.ogg"
		}
	},
	HeroDragonGemDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_kosmyr_death_b.ogg"
		}
	},
	HeroDragonGemBasicAttackCast = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_kosmyr_basicAttack_cast_var1_v1.ogg",
			"kra_sfx_heroes_kosmyr_basicAttack_cast_var2_v1.ogg",
			"kra_sfx_heroes_kosmyr_basicAttack_cast_var3_v1.ogg"
		}
	},
	HeroDragonGemBasicAttackImpact = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_kosmyr_basicAttack_impact_var1_v1.ogg",
			"kra_sfx_heroes_kosmyr_basicAttack_impact_var2_v1.ogg",
			"kra_sfx_heroes_kosmyr_basicAttack_impact_var3_v1.ogg"
		}
	},
	HeroDragonGemPrismaticShardCast = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kosmyr_prismaticShard_cast_v1.ogg"
		}
	},
	HeroDragonGemPrismaticShardRipple = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_kosmyr_prismaticShard_ripple_var1_v1.ogg",
			"kra_sfx_heroes_kosmyr_prismaticShard_ripple_var2_v1.ogg",
			"kra_sfx_heroes_kosmyr_prismaticShard_ripple_var3_v1.ogg",
			"kra_sfx_heroes_kosmyr_prismaticShard_ripple_var4_v1.ogg"
		}
	},
	HeroDragonGemParalyzingBreathCast = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kosmyr_paralyzingBreath_Cast_v1.ogg"
		}
	},
	HeroDragonGemRedDeathCast = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kosmyr_redDeath_cast_v1.ogg"
		}
	},
	HeroDragonGemRedDeathExplosion = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kosmyr_redDeath_explosion_v1.ogg"
		}
	},
	HeroDragonGemPowerConduitCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kosmyr_powerConduit_cast_shot_v1.ogg"
		}
	},
	HeroDragonGemPowerConduitCrystal = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kosmyr_powerConduit_crystal_op1_v1.ogg"
		}
	},
	HeroDragonGemUltimateCast = {
		source_group = "SFX",
		gain = 0.9,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_kosmyr_crystalAvalanch_cast_var1_v1.ogg",
			"kra_sfx_heroes_kosmyr_crystalAvalanch_cast_var2_v1.ogg",
			"kra_sfx_heroes_kosmyr_crystalAvalanch_cast_var3_v1.ogg",
			"kra_sfx_heroes_kosmyr_crystalAvalanch_cast_var4_v1.ogg"
		}
	},
	HeroBirdTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_broden_select_b.ogg",
			"kr_voice_broden_taunt01_c.ogg",
			"kr_voice_broden_taunt02_a.ogg",
			"kr_voice_broden_taunt03_d.ogg"
		}
	},
	HeroBirdTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_broden_select_b.ogg"
		}
	},
	HeroBirdTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_broden_select_b.ogg"
		}
	},
	HeroBirdDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_broden_death_a.ogg"
		}
	},
	HeroBirdBasicAttackCast = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_broden_basicAttack_cast_var1_v1.ogg",
			"kra_sfx_heroes_broden_basicAttack_cast_var2_v1.ogg",
			"kra_sfx_heroes_broden_basicAttack_cast_var3_v1.ogg"
		}
	},
	HeroBirdBasicAttackImpact = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_broden_basicAttack_impact_var1_v1.ogg",
			"kra_sfx_heroes_broden_basicAttack_impact_var2_v1.ogg",
			"kra_sfx_heroes_broden_basicAttack_impact_var3_v1.ogg"
		}
	},
	HeroBirdBasicCarpetBombingCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_broden_carpetBombing_cast_v1.ogg"
		}
	},
	HeroBirdBasicCarpetBombingImpact = {
		ignore = 0.5,
		gain = 0.4,
		loop = false,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_broden_carpetBombing_impact_v1.ogg"
		}
	},
	HeroBirdTerrorShriekCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_heroes_broden_terrorShriek_cast_v1.ogg"
		}
	},
	HeroBirdBulletRainCast = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		interruptible = true,
		files = {
			"kra_sfx_heroes_broden_bulletRain_cast_v1.ogg"
		}
	},
	HeroBirdBulletRainEnd = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		interruptible = true,
		files = {
			"kra_sfx_heroes_broden_bulletRain_loopEnd.ogg"
		}
	},
	HeroBirdHuntingDiveCast = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_heroes_broden_huntingDive_cast_v1.ogg"
		}
	},
	HeroBirdBirdsOfPreyCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_broden_birdsOfPrey_cast_op2_v1.ogg"
		}
	},
	HeroBirdBirdsOfPreyGryphonAttack = {
		source_group = "SFX",
		gain = 0.3,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_broden_birdsOfPrey_gryphonAttack_var1_v1.ogg",
			"kra_sfx_heroes_broden_birdsOfPrey_gryphonAttack_var2_v1.ogg",
			"kra_sfx_heroes_broden_birdsOfPrey_gryphonAttack_var3_v1.ogg",
			"kra_sfx_heroes_broden_birdsOfPrey_gryphonAttack_var4_v1.ogg"
		}
	},
	HeroWitchTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_stregi_select_b.ogg",
			"kr_voice_stregi_taunt-01_a.ogg",
			"kr_voice_stregi_taunt-02_d.ogg",
			"kr_voice_stregi_taunt-03_c.ogg"
		}
	},
	HeroWitchTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_stregi_select_b.ogg"
		}
	},
	HeroWitchTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_stregi_select_b.ogg"
		}
	},
	HeroWitchDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_stregi_death_b.ogg"
		}
	},
	HeroWitchBasicAttackCast = {
		loop = false,
		gain = 0.7,
		mode = "sequence",
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_heroes_stregi_basicAttack_cast_var1_v1.ogg",
			"kra_sfx_heroes_stregi_basicAttack_cast_var2_v1.ogg",
			"kra_sfx_heroes_stregi_basicAttack_cast_var3_v1.ogg"
		}
	},
	HeroWitchDazzlingDecoyCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_stregi_dazzlingDecoy_cast_v1.ogg"
		}
	},
	HeroWitchDazzlingDecoyExplosion = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_stregi_dazzlingDecoy_explosion_v1.ogg"
		}
	},
	HeroWitchNightFuriesCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_stregi_nightFuries_cast_v1.ogg"
		}
	},
	HeroWitchVeggiefyIn = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_stregi_veggiefy_in_v1.ogg"
		}
	},
	HeroWitchVeggiefyOut = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_stregi_veggiefy_out_v1.ogg"
		}
	},
	HeroWitchSquishNSquashCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_squishNSquash_cast_v1.ogg"
		}
	},
	HeroWitchSquishNSquashImpact = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_squishNSquash_impact_v1.ogg"
		}
	},
	HeroDragonBoneUltimateIn = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_stregi_drowsyReturn_in_v1.ogg"
		}
	},
	HeroDragonBoneUltimateOut = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_stregi_drowsyReturn_out_v1.ogg"
		}
	},
	HeroDragonBoneTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_bonehart_select_c.ogg",
			"kr_voice_bonehart_taunt-01_b.ogg",
			"kr_voice_bonehart_taunt-02_a.ogg",
			"kr_voice_bonehart_taunt-03_c.ogg"
		}
	},
	HeroDragonBoneTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_bonehart_select_c.ogg"
		}
	},
	HeroDragonBoneTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_bonehart_select_c.ogg"
		}
	},
	HeroDragonBoneDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_bonehart_death_a.ogg"
		}
	},
	HeroDragonBoneBasicAttackCast = {
		source_group = "SFX",
		gain = 0.5,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_heroes_bonehart_basicAttack_cast_var1.ogg",
			"kra_sfx_heroes_bonehart_basicAttack_cast_var2.ogg",
			"kra_sfx_heroes_bonehart_basicAttack_cast_var3.ogg"
		}
	},
	HeroDragonBoneBasicAttackImpact = {
		source_group = "SFX",
		gain = 0.5,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_heroes_bonehart_basicAttack_impact_var1.ogg",
			"kra_sfx_heroes_bonehart_basicAttack_impact_var2.ogg",
			"kra_sfx_heroes_bonehart_basicAttack_impact_var3.ogg"
		}
	},
	HeroDragonBoneDiseaseNovaCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_bonehart_diseaseNova_cast_v1.ogg"
		}
	},
	HeroDragonBonePlagueCloudCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_bonehart_plagueCloud_cast_v1.ogg"
		}
	},
	HeroDragonBoneSpineRainCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_bonehart_spineRain_cast_v1.ogg"
		}
	},
	HeroDragonBoneSpineRainImpact = {
		source_group = "SFX",
		gain = 0.3,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_heroes_bonehart_spineRain_impact_var1_v1.ogg",
			"kra_sfx_heroes_bonehart_spineRain_impact_var2_v1.ogg",
			"kra_sfx_heroes_bonehart_spineRain_impact_var3_v1.ogg"
		}
	},
	HeroDragonBoneSpreadingBurstCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_bonehart_spreadingBurst_cast_v1.ogg"
		}
	},
	HeroDragonBoneSpreadingBurstImpact = {
		source_group = "SFX",
		gain = 0.4,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_heroes_bonehart_spreadingBurst_impact_var1_v1.ogg",
			"kra_sfx_heroes_bonehart_spreadingBurst_impact_var2_v1.ogg",
			"kra_sfx_heroes_bonehart_spreadingBurst_impact_var3_v1.ogg"
		}
	},
	HeroDragonBoneUltimateCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_bonehart_raiseDrakes_cast_op2_v1.ogg"
		}
	},
	HeroDragonArbDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_silvara_death_c.ogg"
		}
	},
	HeroDragonArbTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_silvara_move2_a.ogg",
			"kr_voice_silvara_move3_b.ogg",
			"kr_voice_silvara_move4_b.ogg"
		}
	},
	HeroDragonArbTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_silvara_move2_a.ogg"
		}
	},
	HeroDragonArbTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_silvara_move2_a.ogg"
		}
	},
	HeroDragonArbArboreansHit = {
		loop = false,
		mode = "random",
		gain = 0.4,
		source_group = "SFX",
		delay = 0.333,
		files = {
			"kra_sfx_crocs_hero_spawned_unit_shield_hit_var1_v1.ogg",
			"kra_sfx_crocs_hero_spawned_unit_shield_hit_var2_v1.ogg",
			"kra_sfx_crocs_hero_spawned_unit_shield_hit_var3_v1.ogg"
		}
	},
	HeroDragonArbAttackSplints = {
		source_group = "SFX",
		gain = 0.23,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_hero_throws_spikes_var1_v1.ogg",
			"kra_sfx_crocs_hero_throws_spikes_var2_v1.ogg",
			"kra_sfx_crocs_hero_throws_spikes_var3_v1.ogg",
			"kra_sfx_crocs_hero_throws_spikes_var4_v1.ogg",
			"kra_sfx_crocs_hero_throws_spikes_var4_v1.ogg",
			"kra_sfx_crocs_hero_throws_spikes_var4_v1.ogg",
			"kra_sfx_crocs_hero_throws_spikes_var4_v1.ogg"
		}
	},
	HeroDragonArbUltimate = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_hero_ultimate_blue_v1.ogg"
		}
	},
	HeroKratoaTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_kratoa_taunt-select_c.ogg",
			"kr_voice_kratoa_taunt02_b.ogg",
			"kr_voice_kratoa_taunt03_b.ogg",
			"kr_voice_kratoa_taunt04_c.ogg"
		}
	},
	HeroKratoaTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_kratoa_taunt04_c.ogg"
		}
	},
	HeroKratoaTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_kratoa_taunt-select_c.ogg"
		}
	},
	HeroKratoaDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_kratoa_death_b.ogg"
		}
	},
	HeroKratoaBasicAttack = {
		loop = false,
		mode = "random",
		gain = 0.6,
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_heroes_kratoa_basicAttack_cast_var1_v1.ogg",
			"kra_sfx_heroes_kratoa_basicAttack_cast_var2_v1.ogg",
			"kra_sfx_heroes_kratoa_basicAttack_cast_var3_v1.ogg"
		}
	},
	HeroKratoaTemperTantrum = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		delay = 0.4,
		files = {
			"kra_sfx_heroes_temperTantrum_cast_v1.ogg"
		}
	},
	HeroKratoaHotheaded = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kratoa_hotheaded_cast_v1.ogg"
		}
	},
	HeroKratoaDoubleTroubleCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kratoa_doubleTrouble_cast_op1_v1.ogg"
		}
	},
	HeroKratoaDoubleTroubleImpact = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kratoa_doubleTrouble_impact_v1.ogg"
		}
	},
	HeroKratoaWildEruption = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_heroes_wildEruption_cast_v1.ogg"
		}
	},
	HeroKratoaRageOutburstCast = {
		loop = false,
		mode = "random",
		gain = 0.7,
		ignore = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kratoa_rageOutburst_cast_var2_v1.ogg",
			"kra_sfx_heroes_kratoa_rageOutburst_cast_var2_v1.ogg",
			"kra_sfx_heroes_kratoa_rageOutburst_cast_var3_v1.ogg"
		}
	},
	HeroKratoaRageOutburstImpact = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_kratoa_rageOutburst_impact_var2_v1.ogg",
			"kra_sfx_heroes_kratoa_rageOutburst_impact_var2_v1.ogg",
			"kra_sfx_heroes_kratoa_rageOutburst_impact_var3_v1.ogg"
		}
	},
	HeroKratoaRageOutburstDeath = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_heroes_kratoa_rageOutburst_death_v1.ogg"
		}
	},
	HeroSpiderTunnelingIn = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_heroe_tunneling_in_v1.ogg"
		}
	},
	HeroSpiderTunnelingOut = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_heroe_tunneling_out_v1.ogg"
		}
	},
	HeroSpiderTunnelingAppear = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_heroe_tunneling_appear_v1.ogg"
		}
	},
	HeroSpiderGlobalCocoons = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_heroe_global_cocoons_v1.ogg"
		}
	},
	HeroSpiderGlobalSpawn = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_heroe_global_spawn_v1.ogg"
		}
	},
	HeroSpiderSupremeHunter = {
		loop = false,
		gain = 0.38,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_heroe_supremehunter_fullSeq_v1.ogg"
		}
	},
	HeroSpiderAreaDamage = {
		loop = false,
		gain = 0.45,
		source_group = "SFX",
		delay = 0.8,
		files = {
			"kra_sfx_spiders_heroe_areadamage_v1.ogg"
		}
	},
	HeroSpiderBasicAttack = {
		loop = false,
		mode = "random",
		gain = 0.4,
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_spiders_heroe_melee_op1_var1_v1.ogg",
			"kra_sfx_spiders_heroe_melee_op1_var2_v1.ogg",
			"kra_sfx_spiders_heroe_melee_op1_var3_v1.ogg"
		}
	},
	HeroSpiderInstakill = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		delay = 0.3,
		files = {
			"kra_sfx_spiders_heroe_instakill_v1.ogg"
		}
	},
	HeroSpiderAttackRanged = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_heroe_range_var1_v1.ogg",
			"kra_sfx_spiders_heroe_range_var2_v1.ogg",
			"kra_sfx_spiders_heroe_range_var3_v1.ogg"
		}
	},
	HeroSpiderTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_spydyr_01a.ogg",
			"kr_voice_spydyr_03b.ogg",
			"kr_voice_spydyr_04d.ogg",
			"kr_voice_spydyr_taunt-select_b.ogg"
		}
	},
	HeroSpiderTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_spydyr_01a.ogg"
		}
	},
	HeroSpiderTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_spydyr_taunt-select_b.ogg"
		}
	},
	HeroSpiderDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_spydyr_death_b.ogg"
		}
	},
	HeroWukongTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_sunwukong_1_c.ogg",
			"kr_voice_sunwukong_2_b.ogg",
			"kr_voice_sunwukong_3_b.ogg",
			"kr_voice_sunwukong_4_a.ogg"
		}
	},
	HeroWukongTauntIntro = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_sunwukong_1_c.ogg"
		}
	},
	HeroWukongTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_sunwukong_4_a.ogg"
		}
	},
	HeroWukongDeath = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_sunwukong_5_c.ogg"
		}
	},
	HeroWukongTauntZH = {
		ignore = 1,
		mode = "sequence",
		gain = 0.9,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_CN_wukong_here_comes_your_grandpa_sun_1.ogg",
			"kr_voice_CN_wukong_are_there_any_peaches_in_your_land_1.ogg",
			"kr_voice_CN_wukong_vivid_and_monkey-like_2.ogg",
			"kr_voice_CN_wukong_where_are_you_going_demon_2.ogg"
		}
	},
	HeroWukongTauntZHIntro = {
		loop = false,
		gain = 0.9,
		source_group = "TAUNTS",
		files = {
			"kr_voice_CN_wukong_here_comes_your_grandpa_sun_1.ogg"
		}
	},
	HeroWukongTauntZHSelect = {
		loop = false,
		gain = 0.9,
		source_group = "TAUNTS",
		files = {
			"kr_voice_CN_wukong_here_comes_your_grandpa_sun_1.ogg"
		}
	},
	HeroWukongDeathZH = {
		loop = false,
		gain = 0.9,
		source_group = "TAUNTS",
		files = {
			"kr_voice_CN_wukong_grandpa_sun_will_be_right_back_2.ogg"
		}
	},
	HeroWukongDeathSFX = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_hero_death_op3_v1.ogg"
		}
	},
	HeroWukongUltimate = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_hero_ultimate_v1.ogg"
		}
	},
	HeroWukongClones = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_hero_hair_clones_v1.ogg"
		}
	},
	HeroWukongInstakill = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_hero_instakill_v2.ogg"
		}
	},
	HeroWukongMeleeFast = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		chance = 0.5,
		files = {
			"kra_sfx_wukong_hero_melee_fast_hits_v1.ogg"
		}
	},
	HeroWukongMeleeJump = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		chance = 0.5,
		files = {
			"kra_sfx_wukong_hero_melee_jump_v1.ogg"
		}
	},
	HeroWukongMeleeSimple = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		chance = 0.5,
		files = {
			"kra_sfx_wukong_hero_melee_simple_v1.ogg"
		}
	},
	HeroWukongMeleeSpin = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		chance = 0.5,
		files = {
			"kra_sfx_wukong_hero_melee_spin_v1.ogg"
		}
	},
	HeroWukongMultiStaff = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_hero_multi_staf_op1_v1.ogg"
		}
	},
	HeroWukongZhuSmash = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_hero_zhu_smash_v1.ogg"
		}
	},
	TowerRoyalArchersTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_royalArchers_taunt_var1c.ogg",
			"kr_voice_royalArchers_taunt2_var1a.ogg",
			"kr_voice_royalArchers_taunt3_var1a.ogg"
		}
	},
	TowerRoyalArchersTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_royalArchers_taunt_var1c.ogg"
		}
	},
	TowerRoyalArchersSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_royalArchers_skill_a_var1a.ogg"
		}
	},
	TowerRoyalArchersSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_royalArchers_skill_b_var1b.ogg"
		}
	},
	TowerRoyalArchersArmorPiercerShot = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 1.12,
		files = {
			"kra_sfx_tower_royalArchers_skill_armorPiercer_v1.ogg"
		}
	},
	TowerRoyalArchersArmorPiercerHit = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_royalArchers_skill_impact_v1.ogg"
		}
	},
	TowerRoyalArchersRapaciousHunterTakeOff = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_royalArchers_skill_rapaciousHunter_takeOff_v1.ogg"
		}
	},
	TowerRoyalArchersRapaciousHunterDescend = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_royalArchers_skill_strike_var1_v1.ogg",
			"kra_sfx_tower_royalArchers_skill_strike_var2_v1.ogg"
		}
	},
	TowerRoyalArchersRapaciousHunterHit = {
		source_group = "SFX",
		gain = 0.4,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_tower_royalArchers_skill_rapaciousHunter_impact_var1_v1.ogg",
			"kra_sfx_tower_royalArchers_skill_rapaciousHunter_impact_var2_v1.ogg"
		}
	},
	TowerArcaneWizardTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_arcanewizard_taunt_var1c.ogg",
			"kr_voice_arcanewizard_taunt2_var1a.ogg",
			"kr_voice_arcanewizard_taunt3_var1b.ogg"
		}
	},
	TowerArcaneWizardTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_arcanewizard_taunt_var1c.ogg"
		}
	},
	TowerArcaneWizardSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_arcanewizard_skill_a_var1a.ogg"
		}
	},
	TowerArcaneWizardSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_arcanewizard_skill_b_var1a.ogg"
		}
	},
	TowerArcaneWizardBasicAttack = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_arcaneWizard_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_arcaneWizard_basicAttack_var2_v1.ogg",
			"kra_sfx_tower_arcaneWizard_basicAttack_var3_v1.ogg"
		}
	},
	TowerArcaneWizardDisintegrate = {
		source_group = "SFX",
		gain = 0.6,
		loop = false,
		delay = 0.2,
		files = {
			"kra_sfx_tower_arcaneWizard_skill_disintegration_v1.ogg"
		}
	},
	TowerArcaneWizardEmpowerment = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_arcaneWizard_skill_empowerment_v1.ogg"
		}
	},
	TowerTricannonTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_tricannon_taunt3_var1a.ogg",
			"kr_voice_tricannon_taunt2_var1c.ogg",
			"kr_voice_tricannon_taunt_var1a.ogg"
		}
	},
	TowerTricannonTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_tricannon_taunt3_var1a.ogg"
		}
	},
	TowerTricannonSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_tricannon_skill_a_var1c.ogg"
		}
	},
	TowerTricannonSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_tricannon_skill_b_var1a.ogg"
		}
	},
	TowerTricannonBasicAttackFire = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_tricannon_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_tricannon_basicAttack_var2_v1.ogg",
			"kra_sfx_tower_tricannon_basicAttack_var3_v1.ogg"
		}
	},
	TowerTricannonBasicAttackImpact = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_tricannon_basicAttack_impact-single_var1_v1.ogg",
			"kra_sfx_tower_tricannon_basicAttack_impact-single_var2_v1.ogg",
			"kra_sfx_tower_tricannon_basicAttack_impact-single_var3_v1.ogg"
		}
	},
	TowerTricannonBombardmentLvl1 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_tricannon_skill_bombardment_lvl1_v1.ogg"
		}
	},
	TowerTricannonBombardmentLvl2 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_tricannon_skill_bombardment_lvl2_v1.ogg"
		}
	},
	TowerTricannonBombardmentLvl3 = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_tricannon_skill_bombardment_lvl3_v1.ogg"
		}
	},
	TowerTricannonOverheat = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_tricannon_skill_overheat-oneshot_v1.ogg"
		}
	},
	TowerPaladinCovenantTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_paladincovenant_taunt3_var1a.ogg",
			"kr_voice_paladincovenant_taunt2_var1a.ogg",
			"kr_voice_paladincovenant_taunt_var1a.ogg"
		}
	},
	TowerPaladinCovenantTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_paladincovenant_taunt3_var1a.ogg"
		}
	},
	TowerPaladinCovenantSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_paladincovenant_skill_a_var1a.ogg"
		}
	},
	TowerPaladinCovenantSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_paladincovenant_skill_b_var1b.ogg"
		}
	},
	TowerPaladinCovenantHealingPrayer = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_tower_paladinCovenant_skill_healingPrayer_v1.ogg"
		}
	},
	TowerPaladinCovenantLeadByExample = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_paladinCovenant_skill_leadByExampleAura_v1.ogg"
		}
	},
	TowerPaladinCovenantUnitDeath = {
		source_group = "SFX",
		gain = 1.5,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_tower_paladinCovenant_unitDeath_var1_v1.ogg",
			"kra_sfx_tower_paladinCovenant_unitDeath_var2_v1.ogg",
			"kra_sfx_tower_paladinCovenant_unitDeath_var3_v1.ogg"
		}
	},
	TowerDemonPitTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_demonpit_taunt3_var1a.ogg",
			"kr_voice_demonpit_taunt2_var1c.ogg",
			"kr_voice_demonpit_taunt_var1a.ogg"
		}
	},
	TowerDemonPitTauntSelect = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_demonpit_taunt3_var1a.ogg"
		}
	},
	TowerDemonPitSkillATaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_demonpit_skill_a_var1c.ogg"
		}
	},
	TowerDemonPitSkillBTaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_demonpit_skill_b_var1a.ogg"
		}
	},
	TowerDemonPitBasicAttack = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_demonPit_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_demonPit_basicAttack_var2_v1.ogg",
			"kra_sfx_tower_demonPit_basicAttack_var3_v1.ogg"
		}
	},
	TowerDemonPitDemonExplosion = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_demonPit_demonExplosion_v1.ogg"
		}
	},
	TowerDemonPitBigGuyBasicAttack = {
		loop = false,
		mode = "random",
		gain = 0.4,
		source_group = "SFX",
		delay = 0.2,
		files = {
			"kra_sfx_tower_demonPit_bigGuy_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_demonPit_bigGuy_basicAttack_var2_v1.ogg",
			"kra_sfx_tower_demonPit_bigGuy_basicAttack_var3_v1.ogg"
		}
	},
	TowerArboreanEmissaryTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_arboreanemissary_taunt3_var1a.ogg",
			"kr_voice_arboreanemissary_taunt2_var1a.ogg",
			"kr_voice_arboreanemissary_taunt_var1a.ogg"
		}
	},
	TowerArboreanEmissaryTauntSelect = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_arboreanemissary_taunt3_var1a.ogg"
		}
	},
	TowerArboreanEmissarySkillATaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_arboreanemissary_skill_a_var1b.ogg"
		}
	},
	TowerArboreanEmissarySkillBTaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_arboreanemissary_skill_b_var1a.ogg"
		}
	},
	TowerArboreanEmissaryBasicAttack = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_arboreanEmissary_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_arboreanEmissary_basicAttack_var3_v1.ogg",
			"kra_sfx_tower_arboreanEmissary_basicAttack_var2_v1.ogg"
		}
	},
	TowerArboreanEmissaryGiftOfNature = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_arboreanEmissary_giftOfNature_cast_v1.ogg"
		}
	},
	TowerArboreanEmissaryThornyGarden = {
		source_group = "SFX",
		gain = 0.9,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_arboreanEmissary_thornyGarden_spawn_var3_v1.ogg",
			"kra_sfx_tower_arboreanEmissary_thornyGarden_spawn_var2_v1.ogg",
			"kra_sfx_tower_arboreanEmissary_thornyGarden_spawn_var1_v1.ogg"
		}
	},
	TowerElvenStargazersTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_elvenstargazers_taunt01_d.ogg",
			"kr_voice_elvenstargazers_taunt02_d.ogg",
			"kr_voice_elvenstargazers_taunt03_c.ogg"
		}
	},
	TowerElvenStargazersTauntSelect = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_elvenstargazers_taunt01_d.ogg"
		}
	},
	TowerElvenStargazersSkillATaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_elvenstargazers_skill_b_d.ogg"
		}
	},
	TowerElvenStargazersSkillBTaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_elvenstargazers_skill_a_c.ogg"
		}
	},
	TowerElvenStargazersBasicAttack = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_elvenStargazer_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_elvenStargazer_basicAttack_var2_v1.ogg",
			"kra_sfx_tower_elvenStargazer_basicAttack_var3_v1.ogg",
			"kra_sfx_tower_elvenStargazer_basicAttack_var4_v1.ogg"
		}
	},
	TowerElvenStargazersRisingStarImpact = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_elvenStargazer_risingStar_impact_var1_v1.ogg",
			"kra_sfx_tower_elvenStargazer_risingStar_impact_var2_v1.ogg",
			"kra_sfx_tower_elvenStargazer_risingStar_impact_var3_v1.ogg"
		}
	},
	TowerElvenStargazersEventHorizonCast = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_tower_elvenStargazer_eventHorizon_cast_v1.ogg"
		}
	},
	TowerElvenStargazersEventHorizonTeleportIn = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 0.3,
		files = {
			"kra_sfx_tower_elvenStargazer_eventHorizon_teleportIn_v1.ogg"
		}
	},
	TowerElvenStargazersEventHorizonTeleportOut = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 0.3,
		files = {
			"kra_sfx_tower_elvenStargazer_eventHorizon_teleportOut_v1.ogg"
		}
	},
	TowerBallistaTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_ballistaoutpost_taunt01_d.ogg",
			"kr_voice_ballistaoutpost_taunt02_c.ogg",
			"kr_voice_ballistaoutpost_taunt03_b.ogg"
		}
	},
	TowerBallistaTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_ballistaoutpost_taunt01_d.ogg"
		}
	},
	TowerBallistaSkillATaunt = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_ballistaoutpost_skill_a_b.ogg"
		}
	},
	TowerBallistaSkillBTaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_ballistaoutpost_skill_b_b.ogg"
		}
	},
	TowerBallistaBasicAttack = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_ballistaOutpost_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_ballistaOutpost_basicAttack_var2_v1.ogg",
			"kra_sfx_tower_ballistaOutpost_basicAttack_var3_v1.ogg",
			"kra_sfx_tower_ballistaOutpost_basicAttack_var4_v1.ogg",
			"kra_sfx_tower_ballistaOutpost_basicAttack_var5_v1.ogg"
		}
	},
	TowerBallistaScrapBombCast = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_ballistaOutpost_scrapBomb_cast_var1_v1.ogg",
			"kra_sfx_tower_ballistaOutpost_scrapBomb_cast_var2_v1.ogg",
			"kra_sfx_tower_ballistaOutpost_scrapBomb_cast_var3_v1.ogg"
		}
	},
	TowerBallistaScrapBombExplosion = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_ballistaOutpost_scrapBomb_explosion_var1_v1.ogg",
			"kra_sfx_tower_ballistaOutpost_scrapBomb_explosion_var2_v1.ogg"
		}
	},
	TowerBallistaFinalNail = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_ballistaOutpost_finalNail_v1.ogg"
		}
	},
	TowerNecromancerTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_necromancerslair_taunt01_c.ogg",
			"kr_voice_necromancerslair_taunt02_a.ogg",
			"kr_voice_necromancerslair_taunt03_c.ogg"
		}
	},
	TowerNecromancerTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_necromancerslair_taunt01_c.ogg"
		}
	},
	TowerNecromancerSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_necromancerslair_skill-a_c.ogg"
		}
	},
	TowerNecromancerSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_necromancerslair_skill-b_a.ogg"
		}
	},
	TowerNecromancerBasicAttack = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_necromancer_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_necromancer_basicAttack_var2_v1.ogg",
			"kra_sfx_tower_necromancer_basicAttack_var3_v1.ogg"
		}
	},
	TowerNecromancerBasicAttackHit = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_necromancer_basicAttack_hit_var1_v1.ogg",
			"kra_sfx_tower_necromancer_basicAttack_hit_var2_v1.ogg",
			"kra_sfx_tower_necromancer_basicAttack_hit_var3_v1.ogg"
		}
	},
	TowerNecromancerBasicAttackSummon = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_necromancer_basicAttack_boltSummon_var1_v1.ogg",
			"kra_sfx_tower_necromancer_basicAttack_boltSummon_var2_v1.ogg",
			"kra_sfx_tower_necromancer_basicAttack_boltSummon_var3_v1.ogg"
		}
	},
	TowerNecromancerSkeletonSummon = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_necromancer_skeletonSummon_v2.ogg"
		}
	},
	TowerNecromancerDeathRider = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.3,
		files = {
			"kra_sfx_tower_necromancer_deathRider_op1_v1.ogg"
		}
	},
	TowerNecromancerSigilOfSilence = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_necromancer_sigilOfSilence_v1.ogg"
		}
	},
	TowerRocketGunnersTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_rocketgunners_taunt01_c.ogg",
			"kr_voice_rocketgunners_taunt02_a.ogg",
			"kr_voice_rocketgunners_taunt03_a.ogg"
		}
	},
	TowerRocketGunnersTauntSelect = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_rocketgunners_taunt01_c.ogg"
		}
	},
	TowerRocketGunnersSkillATaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_rocketgunners_skill-a_c.ogg"
		}
	},
	TowerRocketGunnersSkillBTaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_rocketgunners_skill-b_c.ogg"
		}
	},
	TowerRocketGunnersLiftoffTaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_rocketgunners_liftoff_b.ogg"
		}
	},
	TowerRocketGunnersTouchdownTaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_rocketgunners_touchdown_c.ogg"
		}
	},
	TowerRocketGunnersSpawn = {
		source_group = "SFX",
		gain = 0.3,
		loop = false,
		delay = 0.8,
		files = {
			"kra_sfx_tower_rocketGunners_unitSpawn_v1.ogg"
		}
	},
	TowerRocketGunnersTakeoff = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_rocketGunners_takeoff_v1.ogg"
		}
	},
	TowerRocketGunnersBasicAttack = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_rocketGunners_basicAttack_var1_1.ogg",
			"kra_sfx_tower_rocketGunners_basicAttack_var2_1.ogg",
			"kra_sfx_tower_rocketGunners_basicAttack_var3_1.ogg"
		}
	},
	TowerRocketGunnersStingMissileCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_rocketGunners_stingMissile_cast_v1.ogg"
		}
	},
	TowerRocketGunnersStingMissileExplosion = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_rocketGunners_stingMissile_explosion_v1.ogg"
		}
	},
	TowerRocketGunnersPhosphoricCoating = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_rocketGunners_phosphoricCoating_var1_v1.ogg",
			"kra_sfx_tower_rocketGunners_phosphoricCoating_var2_v1.ogg",
			"kra_sfx_tower_rocketGunners_phosphoricCoating_var3_v1.ogg"
		}
	},
	TowerFlamespitterTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_dwarvenflamespitter_taunt01_c.ogg",
			"kr_voice_dwarvenflamespitter_taunt02_a.ogg",
			"kr_voice_dwarvenflamespitter_taunt03_a.ogg"
		}
	},
	TowerFlamespitterTauntSelect = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_dwarvenflamespitter_taunt01_c.ogg"
		}
	},
	TowerFlamespitterSkillATaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_dwarvenflamespitter_skill-a_b.ogg"
		}
	},
	TowerFlamespitterSkillBTaunt = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr_voice_dwarvenflamespitter_skill-b_d.ogg"
		}
	},
	TowerFlamespitterBasicAttack = {
		source_group = "SFX",
		gain = 0.75,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_dwarvenFlamespitter_basicAttack_cast_var1_v1.ogg",
			"kra_sfx_tower_dwarvenFlamespitter_basicAttack_cast_var2_v1.ogg",
			"kra_sfx_tower_dwarvenFlamespitter_basicAttack_cast_var3_v1.ogg"
		}
	},
	TowerFlamespitterBlazingTrailCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_dwarvenFlamespitter_blazingTrail_cast_v1.ogg"
		}
	},
	TowerFlamespitterBlazingTrailImpact = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_dwarvenFlamespitter_blazingTrail_impact_v1.ogg"
		}
	},
	TowerFlamespitterScorchingTorchesCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_dwarvenFlamespitter_scorchingTorches_cast_v1.ogg"
		}
	},
	TowerFlamespitterScorchingTorchesFlareUp = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_dwarvenFlamespitter_scorchingTorches_flareUp_var1_v1.ogg",
			"kra_sfx_tower_dwarvenFlamespitter_scorchingTorches_flareUp_var2_v1.ogg",
			"kra_sfx_tower_dwarvenFlamespitter_scorchingTorches_flareUp_var3_v1.ogg",
			"kra_sfx_tower_dwarvenFlamespitter_scorchingTorches_flareUp_var4_v1.ogg"
		}
	},
	TowerBarrelTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_battlebrewmasters_select_c.ogg",
			"kr_voice_battlebrewmasters_taunt01_d.ogg",
			"kr_voice_battlebrewmasters_taunt02_a.ogg"
		}
	},
	TowerBarrelTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_battlebrewmasters_select_c.ogg"
		}
	},
	TowerBarrelSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_battlebrewmasters_skill-a_b.ogg"
		}
	},
	TowerBarrelSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_battlebrewmasters_skill-b_d.ogg"
		}
	},
	TowerBarrelBasicAttackCast = {
		loop = false,
		gain = 0.6,
		mode = "random",
		source_group = "SFX",
		delay = 0.1,
		files = {
			"kra_sfx_battleBrewmasters_basicAttack_cast_var1_v1.ogg",
			"kra_sfx_battleBrewmasters_basicAttack_cast_var2_v1.ogg",
			"kra_sfx_battleBrewmasters_basicAttack_cast_var3_v1.ogg"
		}
	},
	TowerBarrelBasicAttackImpact = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_brewMaster_basicAttack_impact_var1_v1.ogg",
			"kra_sfx_tower_brewMaster_basicAttack_impact_var2_v1.ogg",
			"kra_sfx_tower_brewMaster_basicAttack_impact_var3_v1.ogg"
		}
	},
	TowerBarrelBadBatchRattle = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_brewMaster_badBatch_rattle_v1.ogg"
		}
	},
	TowerBarrelBadBatchExplosion = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_brewMaster_badBatch_explosion_v1.ogg"
		}
	},
	TowerBarrelElixirOfMightEvict = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_brewMaster_elixirOfMight_evict_v1.ogg"
		}
	},
	TowerBarrelElixirOfMightDrink = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 2.5,
		files = {
			"kra_sfx_tower_brewMaster_elixirOfMight_drinkAndBoost_v1.ogg"
		}
	},
	TowerSandTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_dunesentinels_select_e.ogg",
			"kr_voice_dunesentinels_taunt01_b.ogg",
			"kr_voice_dunesentinels_taunt02_d.ogg"
		}
	},
	TowerSandTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_dunesentinels_select_e.ogg"
		}
	},
	TowerSandSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_dunesentinels_skill-a_d.ogg"
		}
	},
	TowerSandSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_dunesentinels_skill-b_c.ogg"
		}
	},
	TowerSandBasicAttackHit = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_duneSentinels_basicAttack_var1_v1.ogg",
			"kra_sfx_tower_duneSentinels_basicAttack_var2_v1.ogg",
			"kra_sfx_tower_duneSentinels_basicAttack_var3_v1.ogg",
			"kra_sfx_tower_duneSentinels_basicAttack_var4_v1.ogg",
			"kra_sfx_tower_duneSentinels_basicAttack_var5_v1.ogg"
		}
	},
	TowerSandSkillGoldCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_duneSentinels_bountyHunt_cast_v1.ogg"
		}
	},
	TowerSandSkillBigBladeCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_tower_duneSentinels_whirlingDoom_cast_v1.ogg"
		}
	},
	TowerGhostTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_grimwraiths_select_c.ogg",
			"kr_voice_grimwraiths_taunt01_c.ogg",
			"kr_voice_grimwraiths_taunt02_c.ogg"
		}
	},
	TowerGhostTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.7,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_grimwraiths_select_c.ogg"
		}
	},
	TowerGhostSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_grimwraiths_skill-a_b.ogg"
		}
	},
	TowerGhostSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_grimwraiths_skill-b_d.ogg"
		}
	},
	TowerGhostExtraDamageCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_tower_grimWraiths_soulSiphoning_cast_v1.ogg"
		}
	},
	TowerGhostSoulAttackCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_tower_grimWraiths_undyingDread_cast_one_v1.ogg"
		}
	},
	TowerGhostSoulAttackTravel = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_tower_grimWraiths_undyingDread_travel_v1.ogg"
		}
	},
	TowerGhostSoulAttackImpact = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_tower_grimWraiths_undyingDread_impact_v1.ogg"
		}
	},
	TowerGhostTeleport = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_tower_grimWraiths_teleport_out-in_v1.ogg"
		}
	},
	TowerGhostSpawnUnit = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_grimWraiths_spawnUnit_var1_v1.ogg",
			"kra_sfx_tower_grimWraiths_spawnUnit_var2_v1.ogg",
			"kra_sfx_tower_grimWraiths_spawnUnit_var3_v1.ogg"
		}
	},
	TowerRayTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_eldrictchchannelers_select_[2]a.ogg",
			"kr_voice_eldrictchchannelers_taunt01_b.ogg",
			"kr_voice_eldrictchchannelers_taunt02_[2]b.ogg"
		}
	},
	TowerRayTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_eldrictchchannelers_select_[2]a.ogg"
		}
	},
	TowerRaySkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_eldrictchchannelers_skill-a_[2]c.ogg"
		}
	},
	TowerRaySkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_eldrictchchannelers_skill-b_b.ogg"
		}
	},
	TowerRayBasicAttackCast = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		interruptible = true,
		files = {
			"kra_sfx_tower_eldrictchChannelers_basicAttack_long_var1_v1.ogg",
			"kra_sfx_tower_eldrictchChannelers_basicAttack_long_var2_v1.ogg",
			"kra_sfx_tower_eldrictchChannelers_basicAttack_long_var3_v1.ogg"
		}
	},
	TowerRayBasicAttackOffset = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_tower_eldrictchChannelers_basicAttack_offset_v1.ogg"
		}
	},
	TowerRayMutationHexCast = {
		source_group = "SFX",
		gain = 0.9,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_eldrictchChannelers_mutationHex_cast_var1_v1.ogg",
			"kra_sfx_tower_eldrictchChannelers_mutationHex_cast_var3_v1.ogg"
		}
	},
	TowerDarkElfTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.8,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_twilightlongbows_taunt-01_a.ogg",
			"kr_voice_twilightlongbows_taunt-02_b.ogg",
			"kr_voice_twilightlongbows_select_b.ogg"
		}
	},
	TowerDarkElfTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_twilightlongbows_select_b.ogg"
		}
	},
	TowerDarkElfSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_twilightlongbows_skill-a_g.ogg"
		}
	},
	TowerDarkElfSkillBTaunt = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_twilightlongbows_skill-b_d.ogg"
		}
	},
	TowerDarkElfUnitTaunt = {
		source_group = "TAUNTS",
		gain = 0.7,
		ignore = 1,
		loop = false,
		files = {
			"kr_voice_twilightlongbows_skill-a_g.ogg"
		}
	},
	TowerDarkElfBasicAttackCast = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		interruptible = true,
		files = {
			"kra_sfx_tower_twlightLongbows_basicAttack_cast-noCharge_var1_v1.ogg",
			"kra_sfx_tower_twlightLongbows_basicAttack_cast-noCharge_var2_v1.ogg",
			"kra_sfx_tower_twlightLongbows_basicAttack_cast-noCharge_var3_v1.ogg"
		}
	},
	TowerDarkElfSupportBladesSpawn = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_tower_twlightLongbows_supportBlades_spawn_v1.ogg"
		}
	},
	TowerDarkElfThrillOfTheHuntCast = {
		source_group = "SFX",
		gain = 0.6,
		loop = false,
		delay = 0.7,
		files = {
			"kra_sfx_tower_twlightLongbows_thrillOfTheHunt_cast-travelOnly_v1.ogg"
		}
	},
	TowerWeirdwoodBasicAttackCast = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		interruptible = true,
		files = {
			"kra_sfx_stage17_weirdwood_basicAttack_throw_var1_v1.ogg",
			"kra_sfx_stage17_weirdwood_basicAttack_throw_var2_v1.ogg",
			"kra_sfx_stage17_weirdwood_basicAttack_throw_var3_v1.ogg"
		}
	},
	TowerWeirdwoodBasicAttackHit = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_stage17_weirdwood_basicAttack_explosion_v1.ogg"
		}
	},
	TowerWeirdwoodTransform = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_stage17_weirdwood_deathwoodTransform_v1.ogg"
		}
	},
	TowerWeirdwoodCorruption = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_stage17_weirdwood_leavesFall_v1.ogg"
		}
	},
	TowerElvenBarrackUnitTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_elvenmercenaries_taunt-01_c.ogg",
			"kr_voice_elvenmercenaries_taunt-02_b.ogg"
		}
	},
	TowerHermitToadTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.8,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_boghermit_build_a.ogg",
			"kr_voice_boghermit_build2_b.ogg",
			"kr_voice_boghermit_build3_c.ogg"
		}
	},
	TowerHermitToadTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_boghermit_build_a.ogg"
		}
	},
	TowerHermitToadSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_boghermit_power1_c.ogg"
		}
	},
	TowerHermitToadSkillBTaunt = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_boghermit_power2_c.ogg"
		}
	},
	TowerHermitToadSwitchToArtillery = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_boghermit_switchtoartillery_c.ogg"
		}
	},
	TowerHermitToadSwitchToMage = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_boghermit_switchtomage_c.ogg"
		}
	},
	TowerHermitToadShootMagic = {
		loop = false,
		gain = 0.25,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_tower_pipe_shoot_magic_var1_v1.ogg"
		}
	},
	TowerHermitToadShootEngineer = {
		loop = false,
		gain = 0.25,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_tower_pipe_shoot_water_var3_v1.ogg"
		}
	},
	TowerHermitToadShootEngineerImpact = {
		loop = false,
		gain = 0.25,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_tower_pipe_shoot_water_impact_var3_v1.ogg"
		}
	},
	TowerHermitToadBackToPond = {
		loop = false,
		gain = 0.35,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_tower_stomp_path_backToPond_v1.ogg"
		}
	},
	TowerHermitToadJump = {
		loop = false,
		gain = 0.35,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_tower_stomp_path_jumpOut_v1.ogg"
		}
	},
	TowerHermitToadFall = {
		loop = false,
		gain = 0.35,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_tower_stomp_path_v1.ogg"
		}
	},
	TowerHermitToadTongue = {
		loop = false,
		gain = 0.35,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_tower_tonge_shoot_v1.ogg"
		}
	},
	TowerDwarfTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.8,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_cannoneersquad_taunt-select_e.ogg",
			"kr_voice_cannoneersquad_taunt02_b.ogg",
			"kr_voice_cannoneersquad_taunt03_c.ogg"
		}
	},
	TowerDwarfTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_cannoneersquad_taunt-select_e.ogg"
		}
	},
	TowerDwarfSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_cannoneersquad_skill-a_c.ogg"
		}
	},
	TowerDwarfSkillBTaunt = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"kr_voice_cannoneersquad_skill-b_c.ogg"
		}
	},
	TowerDwarfBasicAttack = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_towers_cannoneers_basicAttack_var1_v1.ogg",
			"kra_sfx_towers_cannoneers_basicAttack_var2_v1.ogg",
			"kra_sfx_towers_cannoneers_basicAttack_var3_v1.ogg"
		}
	},
	TowerDwarfIncendiaryAmmo = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_towers_cannoneers_incendiaryAmmo_impact_var1_v1.ogg",
			"kra_sfx_towers_cannoneers_incendiaryAmmo_impact_var2_v1.ogg",
			"kra_sfx_towers_cannoneers_incendiaryAmmo_impact_var3_v1.ogg"
		}
	},
	TowerDwarfIncendiaryJump = {
		source_group = "SFX",
		gain = 0.6,
		loop = false,
		delay = 0.4,
		files = {
			"kra_sfx_towers_cannoneers_jump_cast_v1.ogg"
		}
	},
	TowerDwarfUnitDeath = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_towers_cannoneers_death_var1.ogg",
			"kra_sfx_towers_cannoneers_death_var2.ogg",
			"kra_sfx_towers_cannoneers_death_var3.ogg"
		}
	},
	TowerSparkingGeodeRay = {
		source_group = "SFX",
		gain = 0.15,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_tower_heode_ray_var1_v1.ogg",
			"kra_sfx_spiders_tower_heode_ray_var2_v1.ogg",
			"kra_sfx_spiders_tower_heode_ray_var3_v1.ogg",
			"kra_sfx_spiders_tower_heode_ray_var4_v1.ogg",
			"kra_sfx_spiders_tower_heode_ray_var5_v1.ogg"
		}
	},
	TowerSparkingGeodeCristalizeBolt = {
		source_group = "SFX",
		gain = 0.45,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_tower_heode_cristalize_bolt_var1_v1.ogg",
			"kra_sfx_spiders_tower_heode_cristalize_bolt_var2_v1.ogg",
			"kra_sfx_spiders_tower_heode_cristalize_bolt_var3_v1.ogg"
		}
	},
	TowerSparkingGeodeCristalizeCast = {
		loop = false,
		gain = 0.45,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_tower_heode_cristalize_cast_var3_v1.ogg"
		}
	},
	TowerSparkingGeodeSpikeCast = {
		loop = false,
		gain = 0.45,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_tower_heode_spike_cast_v1.ogg"
		}
	},
	TowerSparkingGeodeSpikeLoop = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_tower_heode_spike_sparksLOOP_v1.ogg"
		}
	},
	TowerSparkingGeodeTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_surgecolossus_taunt-select_c.ogg",
			"kr_voice_surgecolossus_04c.ogg",
			"kr_voice_surgecolossus_05c.ogg"
		}
	},
	TowerSparkingGeodeTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.7,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_surgecolossus_taunt-select_c.ogg"
		}
	},
	TowerSparkingGeodeSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_surgecolossus_03c.ogg"
		}
	},
	TowerSparkingGeodeSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_surgecolossus_02c.ogg"
		}
	},
	TowerPandasTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_pandatower_taunt01_f.ogg",
			"kr_voice_pandatower_taunt02_b.ogg",
			"kr_voice_pandatower_taunt03_c.ogg"
		}
	},
	TowerPandasTauntSelect = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_pandatower_taunt01_f.ogg"
		}
	},
	TowerPandasSkillATaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_pandatower_thunderskill_a.ogg"
		}
	},
	TowerPandasSkillBTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_pandatower_hatskill_a.ogg"
		}
	},
	TowerPandasSkillCTaunt = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"kr_voice_pandatower_fieryskill_b.ogg"
		}
	},
	TowerPandasTauntZH = {
		ignore = 1,
		mode = "sequence",
		gain = 0.9,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_CN_pandas_panda_style_3.ogg",
			"kr_voice_CN_pandas_no_charge_for_awesome_2.ogg",
			"kr_voice_CN_pandas_we_know_kung-fu_2.ogg"
		}
	},
	TowerPandasTauntZHSelect = {
		source_group = "TAUNTS",
		gain = 0.9,
		mode = "sequence",
		loop = false,
		files = {
			"kr_voice_CN_pandas_panda_style_3.ogg"
		}
	},
	TowerPandasSkillATauntZH = {
		loop = false,
		gain = 0.9,
		source_group = "TAUNTS",
		files = {
			"kr_voice_CN_pandas_ayumbabayeee_1.ogg"
		}
	},
	TowerPandasSkillBTauntZH = {
		loop = false,
		gain = 0.9,
		source_group = "TAUNTS",
		files = {
			"kr_voice_CN_pandas_watch_and_see_3.ogg"
		}
	},
	TowerPandasSkillCTauntZH = {
		loop = false,
		gain = 0.9,
		source_group = "TAUNTS",
		files = {
			"kr_voice_CN_pandas_get_over_there_2.ogg"
		}
	},
	TowerPandasArrival = {
		source_group = "SFX",
		gain = 0.4,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_wukong_tower_pandas_arrival_single_var1_v1.ogg",
			"kra_sfx_wukong_tower_pandas_arrival_single_var2_v1.ogg",
			"kra_sfx_wukong_tower_pandas_arrival_single_var3_v1.ogg"
		}
	},
	TowerPandasDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_wukong_tower_pandas_death_generic_var1_v1.ogg",
			"kra_sfx_wukong_tower_pandas_death_generic_var2_v1.ogg",
			"kra_sfx_wukong_tower_pandas_death_generic_var3_v1.ogg"
		}
	},
	TowerPandasRangedBolt = {
		source_group = "BULLETS",
		gain = 0.4,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_wukong_tower_pandas_ranged_bolt_var1_v1.ogg",
			"kra_sfx_wukong_tower_pandas_ranged_bolt_var2_v1.ogg",
			"kra_sfx_wukong_tower_pandas_ranged_bolt_var3_v1.ogg"
		}
	},
	TowerPandasRangedFire = {
		source_group = "BULLETS",
		gain = 0.4,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_wukong_tower_pandas_ranged_fire_var1_v1.ogg",
			"kra_sfx_wukong_tower_pandas_ranged_fire_var2_v1.ogg",
			"kra_sfx_wukong_tower_pandas_ranged_fire_var3_v1.ogg"
		}
	},
	TowerPandasRangedHat = {
		source_group = "BULLETS",
		gain = 0.4,
		mode = "sequence",
		loop = false,
		files = {
			"kra_sfx_wukong_tower_pandas_ranged_hat_var1_v1.ogg",
			"kra_sfx_wukong_tower_pandas_ranged_hat_var2_v1.ogg",
			"kra_sfx_wukong_tower_pandas_ranged_hat_var3_v1.ogg"
		}
	},
	TowerPandasSkillBolt = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_tower_pandas_skill_bolt_op1_v1.ogg"
		}
	},
	TowerPandasSkillFire = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_tower_pandas_skill_fire_v1.ogg"
		}
	},
	TowerPandasSkillHat = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_tower_pandas_skill_hat_throw_v1.ogg"
		}
	},
	TowerPandasMelee = {
		loop = false,
		gain = 0.2,
		mode = "sequence",
		source_group = "SFX",
		chance = 0.2,
		files = {
			"kra_sfx_wukong_tower_pandas_melee_var1_v1.ogg",
			"kra_sfx_wukong_tower_pandas_melee_var2_v1.ogg",
			"kra_sfx_wukong_tower_pandas_melee_var3_v1.ogg"
		}
	},
	ReinforcementTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_neutralreinforcements_taunt01_a.ogg",
			"kr_voice_neutralreinforcements_taunt02_a.ogg",
			"kr_voice_neutralreinforcements_taunt03_a.ogg"
		}
	},
	ReinforcementLinireaTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_linireanreinforcements_taunt01_c.ogg",
			"kr_voice_linireanreinforcements_taunt02_c.ogg",
			"kr_voice_linireanreinforcements_taunt03_b.ogg"
		}
	},
	ReinforcementDarkArmyTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_darkarmyreinforcements_taunt01_a.ogg",
			"kr_voice_darkarmyreinforcements_taunt02_b.ogg",
			"kr_voice_darkarmyreinforcements_taunt03_b.ogg"
		}
	},
	EnemyTuskedBrawlerDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_tuskedBrawler_death_op1_var3.ogg"
		}
	},
	EnemyBearVanguardRage = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_bearVanguard_rage_v1.ogg"
		}
	},
	EnemyBearVanguardDeath = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 0.7,
		files = {
			"kra_sfx_enemy_bearVanguard_death_v1.ogg"
		}
	},
	EnemyTurtleShamanBasicAttack = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_turtleShaman_basicAttack_var3.ogg"
		}
	},
	EnemyTurtleShamanHealing = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_turtleShaman_healing_v1.ogg"
		}
	},
	EnemyTurtleShamanDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_turtleShaman_death_op2_v1.ogg"
		}
	},
	EnemyRottenfangHyenaFeast = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_rottenfangHyena_barbaricFeast_v1.ogg"
		}
	},
	EnemyRottenfangHyenaDeath = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_rottenfangHyena_death_var3_v1_op2.ogg"
		}
	},
	EnemyCutthroatRat = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_cutthroatRat_stealthSkill-oneShot_v1.ogg"
		}
	},
	EnemyCutthroatRatDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_cutthroatRat_death_var3_v1.ogg"
		}
	},
	EnemySkunkBombardierBasicAttackCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_skunkBombardier_basicAttack-whoosh_var1_v1.ogg"
		}
	},
	EnemySkunkBombardierBasicAttackImpact = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_skunkBombardier_basicAttack-impact_var1_v1.ogg"
		}
	},
	EnemySkunkBombardierDeath = {
		source_group = "SFX",
		gain = 0.85,
		loop = false,
		delay = 0.8,
		files = {
			"kra_sfx_enemy_skunkBombardier_death_v1.ogg"
		}
	},
	EnemyDreadeyeViperDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_dreadeyeViper_death_var1_v1.ogg"
		}
	},
	EnemyPatrollingVultureDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_patrollingVulture_death_var4_v1.ogg"
		}
	},
	EnemyRazingRhinoBasicAttack = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_enemy_razingRhino_basicAttack_var3_v1.ogg"
		}
	},
	EnemyRazingRhinoCharge = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_razingRhino_charge_v1.ogg"
		}
	},
	EnemyRazingRhinoDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_razingRhino_death_v1.ogg"
		}
	},
	EnemyAcolyteDeath = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_cultistAcolyte_death_var1_v1.ogg",
			"kra_sfx_enemy_cultistAcolyte_death_var2_v1.ogg",
			"kra_sfx_enemy_cultistAcolyte_death_var3_v1.ogg",
			"kra_sfx_enemy_cultistAcolyte_death_var4_v1.ogg",
			"kra_sfx_enemy_cultistAcolyte_death_var5_v1.ogg"
		}
	},
	EnemyAcolyteDeathSpecial = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 0.4,
		files = {
			"kra_sfx_enemy_cultistAcolyte_deathSpecial_v1.ogg"
		}
	},
	EnemyAcolyteTentacleBasicAttack = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_acolyteTentacle_attack_var1_v1.ogg",
			"kra_sfx_enemy_acolyteTentacle_attack_var2_v1.ogg",
			"kra_sfx_enemy_acolyteTentacle_attack_var3_v1.ogg"
		}
	},
	EnemyAcolyteTentacleDeath = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_acolyteTentacle_death_var1_v1.ogg",
			"kra_sfx_enemy_acolyteTentacle_death_var2_v1.ogg",
			"kra_sfx_enemy_acolyteTentacle_death_var3_v1.ogg"
		}
	},
	EnemyVoidBlinkerTeleport = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_voidBlinker_teleport_v1.ogg"
		}
	},
	EnemyVoidBlinkerDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_voidBlinker_death_var1_v1.ogg",
			"kra_sfx_enemy_voidBlinker_death_var3_v1.ogg"
		}
	},
	EnemyTwistedSisterSummonCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_twistedSister_summon_cast_v1.ogg"
		}
	},
	EnemyTwistedSisterSummonSpawn = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_twistedSister_summon_spawn_v2.ogg"
		}
	},
	EnemyTwistedSisterDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_twistedSister_death_v1.ogg"
		}
	},
	EnemyNightmareDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_nightmare_death_v1.ogg"
		}
	},
	EnemyUnblindedPriestDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_unblindedPriest_death_var1.ogg",
			"kra_sfx_enemy_unblindedPriest_death_var2.ogg",
			"kra_sfx_enemy_unblindedPriest_death_var3.ogg"
		}
	},
	EnemyUnblindedPriestTransformCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		interruptible = true,
		files = {
			"kra_sfx_enemy_unblindedPriest_transform_cast_v2.ogg"
		}
	},
	EnemyUnblindedPriestTransformSpawn = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_unblindedPriest_transform_spawn_v1.ogg"
		}
	},
	EnemyAbominationDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_abomination_death_v1.ogg"
		}
	},
	EnemyAbominationInstakill = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_abomination_instakill_v1.ogg"
		}
	},
	EnemySpiderlingDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_spiderling_death_var1_v1.ogg"
		}
	},
	EnemyShacklerDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_shackler_death_var-003.ogg"
		}
	},
	EnemyShacklerBlockTowerBlock = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_shackler_blockTower_block_v1.ogg"
		}
	},
	EnemyShacklerBlockTowerUnblock = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_shackler_blockTower_unblock_v1.ogg"
		}
	},
	EnemyBoundNightmareDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_boundNightmare_death_op2_v1.ogg"
		}
	},
	EnemyCorruptedStalkerDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_corruptedStalker_death_v1.ogg"
		}
	},
	EnemyCrystalGolemDeath = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_stoneGolem_death_v1.ogg"
		}
	},
	EnemyGlarelingDeath = {
		loop = false,
		gain = 0.5,
		mode = "random",
		source_group = "SFX",
		delay = 0.6,
		files = {
			"kra_sfx_enemy_voidBlinker_death_var1_v1.ogg",
			"kra_sfx_enemy_voidBlinker_death_var3_v1.ogg"
		}
	},
	EnemyVoidBlinkerStareCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_voidBlinker_stare_v1.ogg"
		}
	},
	EnemyMindlessHuskDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_enemy_mindlessHusk_death_v1.ogg"
		}
	},
	EnemyMindlessHuskSpawnDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_enemy_mindlessHusk_deathSpawn_v1.ogg"
		}
	},
	EnemyVileSpawnerDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0.2,
		files = {
			"kra_sfx_enemy_vileSpawner_death_v1.ogg"
		}
	},
	EnemyVileSpawnerSpawnCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_enemy_vileSpawner_spawn_cast_v1.ogg"
		}
	},
	EnemyLesserEyeDeath = {
		loop = false,
		gain = 0.5,
		mode = "random",
		source_group = "SFX",
		delay = 0.25,
		files = {
			"kra_sfx_enemy_voidBlinker_death_var1_v1.ogg",
			"kra_sfx_enemy_voidBlinker_death_var3_v1.ogg"
		}
	},
	EnemyNoxiousHorrorDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_enemy_noxiousHorror_death_op1_v1.ogg"
		}
	},
	EnemyNoxiousHorrorBasicAttackCast = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_enemy_noxiousHorror_basicAttack_cast_op2_v1.ogg"
		}
	},
	EnemyNoxiousHorrorBasicAttackImpact = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_enemy_noxiousHorror_basicAttack_impact_v1.ogg"
		}
	},
	EnemyHardenedHorrorDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0.1,
		files = {
			"kra_sfx_enemy_hardenedHorror_death_op2_v1.ogg"
		}
	},
	EnemyEvolvingScourgeDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0.1,
		files = {
			"kra_sfx_enemy_evolvingScourge_death_var2_v1.ogg"
		}
	},
	EnemyEvolvingScourgeEvolve = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_evolvingScourge_evolve_op1_v1.ogg"
		}
	},
	EnemyAmalgamDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		delay = 0.1,
		files = {
			"kra_sfx_enemy_fleshBehemoth_death_op1_v1.ogg"
		}
	},
	EnemySheepDeath = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_sheep_death_var1_v1.ogg",
			"kra_sfx_enemy_sheep_death_var2_v1.ogg",
			"kra_sfx_enemy_sheep_death_var3_v1.ogg"
		}
	},
	EnemyCorruptedElfSpawn = {
		loop = false,
		mode = "random",
		gain = 0.6,
		ignore = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_corruptedRanger_spawn_var1_v1.ogg",
			"kra_sfx_enemy_corruptedRanger_spawn_var2_v1.ogg",
			"kra_sfx_enemy_corruptedRanger_spawn_var3_v1.ogg"
		}
	},
	EnemyCorruptedElfDeath = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_corruptedRanger_death_var1_v2.ogg",
			"kra_sfx_enemy_corruptedRanger_death_var2_v2.ogg",
			"kra_sfx_enemy_corruptedRanger_death_var3_v2.ogg"
		}
	},
	EnemySpecterRushAnticipation = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_specter_interact_cast_var1_v2.ogg",
			"kra_sfx_enemy_specter_interact_cast_var2_v2.ogg",
			"kra_sfx_enemy_specter_interact_cast_var3_v2.ogg"
		}
	},
	EnemySpecterRush = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_specter_interact_cast_op2_var-003.ogg",
			"kra_sfx_enemy_specter_interact_cast_op2_var-004.ogg",
			"kra_sfx_enemy_specter_interact_cast_var-005.ogg"
		}
	},
	EnemySpecterCorruption = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_stage17_weirdwood_specterImpact_v1.ogg"
		}
	},
	EnemySpecterDeath = {
		loop = false,
		mode = "random",
		gain = 0.8,
		ignore = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_specter_death_var1_v2.ogg",
			"kra_sfx_enemy_specter_death_var2_v2.ogg",
			"kra_sfx_enemy_specter_death_var3_v2.ogg",
			"kra_sfx_enemy_specter_death_var4_v2.ogg",
			"kra_sfx_enemy_specter_death_var5_v2.ogg",
			"kra_sfx_enemy_specter_death_var6_v2.ogg"
		}
	},
	EnemyDustCryptidDeath = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_dustCryptid_death_v1.ogg"
		}
	},
	EnemyBaneWolfDeath = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_baneWolf_death_var1_v1.ogg",
			"kra_sfx_enemy_baneWolf_death_var2_v1.ogg",
			"kra_sfx_enemy_baneWolf_death_var3_v1.ogg"
		}
	},
	EnemyDeathwoodRangedAttackCast = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemies_deathwood_rangedAttack_cast_var1_v1.ogg",
			"kra_sfx_enemies_deathwood_rangedAttack_cast_var2_v1.ogg",
			"kra_sfx_enemies_deathwood_rangedAttack_cast_var3_v1.ogg"
		}
	},
	EnemyDeathwoodRangedAttackImpact = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemies_deathwood_rangedAttack_impact_var1_v1.ogg",
			"kra_sfx_enemies_deathwood_rangedAttack_impact_var2_v1.ogg",
			"kra_sfx_enemies_deathwood_rangedAttack_impact_var3_v1.ogg"
		}
	},
	EnemyDeathwoodDeath = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_deathwood_death_op1_v1.ogg"
		}
	},
	EnemyAnimatedArmorDeath = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_animatedArmor_death_v1.ogg"
		}
	},
	EnemyAnimatedArmorRevive = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_animatedArmor_revive_v1.ogg"
		}
	},
	EnemyRevenantSoulcallerAttackCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_soulcaller_attack_cast_v1.ogg"
		}
	},
	EnemyRevenantSoulcallerBlockTowerIn = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_soulcaller_towerBlock_in_v1.ogg"
		}
	},
	EnemyRevenantSoulcallerBlockTowerOut = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_soulcaller_towerBlock_out_v1.ogg"
		}
	},
	EnemyRevenantSoulcallerDeath = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_soulcaller_death_v1.ogg"
		}
	},
	EnemyRevenantHarvesterClone = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 0.2,
		files = {
			"kra_sfx_enemy_harvester_duplicate_v1.ogg"
		}
	},
	EnemyRevenantHarvesterDeath = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_harvester_death_var1_v1.ogg",
			"kra_sfx_enemy_harvester_death_var2_v1.ogg",
			"kra_sfx_enemy_harvester_death_var3_v1.ogg"
		}
	},
	EnemyPumpkinDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_heroes_stregi_veggiefy_death_var1_v1.ogg",
			"kra_sfx_heroes_stregi_veggiefy_death_var2_v1.ogg",
			"kra_sfx_heroes_stregi_veggiefy_death_var3_v1.ogg"
		}
	},
	EnemyDarksteelHammererDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_darksteelHammerer_death_var1_v1.ogg",
			"kra_sfx_enemy_darksteelHammerer_death_var2_v1.ogg"
		}
	},
	EnemyDarksteelShielderDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_darksteelShielder_death_var1_v1.ogg",
			"kra_sfx_enemy_darksteelShielder_death_var2_v1.ogg"
		}
	},
	EnemyCommonCloneDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_darksteelHammerer_death_var1_v1.ogg",
			"kra_sfx_enemy_darksteelHammerer_death_var2_v1.ogg"
		}
	},
	EnemyRollingSentryDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_rollingSentry_death_var1_v1.ogg",
			"kra_sfx_enemy_rollingSentry_death_var2_v1.ogg"
		}
	},
	EnemyRollingSentryAttack = {
		ignore = 1,
		gain = 0.4,
		mode = "random",
		loop = false,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_rollingSentry_attack_op1_var1_v1.ogg",
			"kra_sfx_enemy_rollingSentry_attack_op1_var2_v1.ogg"
		}
	},
	EnemyScrapSpeedsterDeath = {
		source_group = "SFX",
		gain = 0.3,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_scrapSpeedster_death_var1_v1.ogg",
			"kra_sfx_enemy_scrapSpeedster_death_var3_v1.ogg"
		}
	},
	EnemyBruteWelderDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_bruteWelder_death_var1_v1.ogg",
			"kra_sfx_enemy_bruteWelder_death_var2_v1.ogg"
		}
	},
	EnemyBruteWelderDeathImpact = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_bruteWelder_deathImpact_v1.ogg"
		}
	},
	EnemyDarksteelFistDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_darksteelFist_death_var1_v1.ogg",
			"kra_sfx_enemy_darksteelFist_death_var2_v1.ogg",
			"kra_sfx_enemy_darksteelFist_death_var3_v1.ogg"
		}
	},
	EnemyDarksteelFistStun = {
		loop = false,
		mode = "random",
		gain = 0.5,
		source_group = "SFX",
		delay = 0.1,
		files = {
			"kra_sfx_enemy_darksteelFist_stun_op1_v1.ogg",
			"kra_sfx_enemy_darksteelFist_stun_op2_v1.ogg"
		}
	},
	EnemyMadTinkererDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_madTinkerer_death_var1_v1.ogg"
		}
	},
	EnemyMadTinkererRayCast = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_madTinkerer_rayCast_v1.ogg"
		}
	},
	EnemyMadTinkererSummon = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_enemy_madTinkerer_summon_v1.ogg"
		}
	},
	EnemyScrapDroneDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_scrapDrone_death_v1.ogg",
			"kra_sfx_enemy_scrapDrone_death_v1.ogg"
		}
	},
	EnemyDarksteelAnvilDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_darksteelAnvil_death_var1_v1.ogg",
			"kra_sfx_enemy_darksteelAnvil_death_var3_v1.ogg",
			"kra_sfx_enemy_darksteelAnvil_death_var4_v1.ogg"
		}
	},
	EnemyDarksteelAnvilBeat = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		delay = 1.2,
		files = {
			"kra_sfx_enemy_darksteelAnvil_beat_SHORT_v2.ogg"
		}
	},
	EnemyDarksteelHulkDeath = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_darksteelHulk_death_var2_v1.ogg",
			"kra_sfx_enemy_darksteelHulk_death_var3_v1.ogg"
		}
	},
	EnemyDarksteelHulkCharge = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_darksteelHulk_charge_op1_v1.ogg"
		}
	},
	EnemyDarksteelGuardianAttack = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_enemy_darksteelGuardian_attack_var1_v1.ogg",
			"kra_sfx_enemy_darksteelGuardian_attack_var2_v1.ogg",
			"kra_sfx_enemy_darksteelGuardian_attack_var3_v1.ogg"
		}
	},
	EnemyDarksteelGuardianDeath = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_darksteelGuardian_death_oneShot_v1.ogg"
		}
	},
	EnemyDarksteelGuardianActivation = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_stage23_darksteelGuardian_activation_v1.ogg"
		}
	},
	EnemyDarksteelGuardianRock = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		delay = 0.3,
		files = {
			"kra_sfx_stage23_darksteelGuardian_rockBreak_v1.ogg"
		}
	},
	EnemyDarksteelEnrage = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_enemy_darksteelGuardian_enrage_cast_v1.ogg"
		}
	},
	EnemyDarksteelRageAttack = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		delay = 0.25,
		files = {
			"kra_sfx_enemy_darksteelGuardian_enrage_attack_v1.ogg"
		}
	},
	EnemyCrokinderDeath = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_crokinder_death_var1_v1.ogg"
		}
	},
	EnemyCrokinderEvolve = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_crokinder_transform_var3_v1.ogg"
		}
	},
	EnemyCrocBasicMelee = {
		loop = false,
		gain = 0.2,
		mode = "random",
		source_group = "SFX",
		delay = 0.2666,
		files = {
			"kra_sfx_crocs_gator_melee_var1_v1.ogg",
			"kra_sfx_crocs_gator_melee_var2_v1.ogg",
			"kra_sfx_crocs_gator_melee_var3_v1.ogg"
		}
	},
	EnemyKillertileMelee = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_killertile_bitemelee_v1.ogg"
		}
	},
	EnemyQuickfeetMelee = {
		loop = false,
		gain = 0.2,
		mode = "random",
		source_group = "SFX",
		delay = 0.2666,
		files = {
			"kra_sfx_crocs_quickfeet_melee_var1_v1.ogg",
			"kra_sfx_crocs_quickfeet_melee_var2_v1.ogg",
			"kra_sfx_crocs_quickfeet_melee_var3_v1.ogg"
		}
	},
	EnemyQuickfeetRanged = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_quickfeet_throw_chicken_leg_and_throwup_v1.ogg"
		}
	},
	EnemyCrocsBasicEvolve = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_quickfeet_throw_chicken_leg_eat_and_grow_v1.ogg"
		}
	},
	EnemyCrocsRangedShot = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_lizardshot_range_var1_v1.ogg",
			"kra_sfx_crocs_lizardshot_range_var2_v1.ogg",
			"kra_sfx_crocs_lizardshot_range_var3_v1.ogg"
		}
	},
	EnemyCrocsRangedMelee = {
		loop = false,
		gain = 0.2,
		mode = "random",
		source_group = "SFX",
		delay = 0.2666,
		files = {
			"kra_sfx_crocs_lizardshot_melee_var1_v1.ogg",
			"kra_sfx_crocs_lizardshot_melee_var2_v1.ogg",
			"kra_sfx_crocs_lizardshot_melee_var3_v1.ogg"
		}
	},
	EnemyNestingGatorMelee = {
		loop = false,
		gain = 0.2,
		mode = "random",
		source_group = "SFX",
		delay = 0.2666,
		files = {
			"kra_sfx_crocs_nesting_gator_melee_var1_v1.ogg",
			"kra_sfx_crocs_nesting_gator_melee_var2_v1.ogg",
			"kra_sfx_crocs_nesting_gator_melee_var3_v1.ogg"
		}
	},
	EnemyNestingGatorAbility = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_nesting_gator_spawn_op1_v1.ogg"
		}
	},
	EnemyCrocShamanShot = {
		source_group = "SFX",
		gain = 0.15,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_crocs_wise_range_cast_var1_v1.ogg"
		}
	},
	EnemyCrocTankSpin = {
		loop = false,
		gain = 0.2,
		mode = "random",
		source_group = "SFX",
		delay = 0.3333,
		files = {
			"kra_sfx_crocs_tank_spin_op2_v1.ogg"
		}
	},
	EnemyCultbroodDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_enemy_spider_cultbrood_death_var1_v1.ogg",
			"kra_sfx_spiders_enemy_spider_cultbrood_death_var2_v1.ogg"
		}
	},
	EnemyCultbroodMelee = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.466,
		files = {
			"kra_sfx_spiders_enemy_spider_cultbrood_melee_var1_v1.ogg",
			"kra_sfx_spiders_enemy_spider_cultbrood_melee_var2_v1.ogg",
			"kra_sfx_spiders_enemy_spider_cultbrood_melee_var3_v1.ogg"
		}
	},
	EnemyDrainbroodMelee = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.33,
		files = {
			"kra_sfx_spiders_enemy_spider_drainbrood_melee_var1_v1.ogg",
			"kra_sfx_spiders_enemy_spider_drainbrood_melee_var2_v1.ogg",
			"kra_sfx_spiders_enemy_spider_drainbrood_melee_var3_v1.ogg"
		}
	},
	EnemyGlarenwardenDeath = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.3,
		files = {
			"kra_sfx_spiders_enemy_spider_glarenwarden_death_v1.ogg"
		}
	},
	EnemyGlarenwardenMelee = {
		loop = false,
		gain = 0.3,
		mode = "random",
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_spiders_enemy_spider_glarenwarden_melee_var1_v1.ogg",
			"kra_sfx_spiders_enemy_spider_glarenwarden_melee_var2_v1.ogg",
			"kra_sfx_spiders_enemy_spider_glarenwarden_melee_var3_v1.ogg"
		}
	},
	EnemySpiderPriestTransform = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.9,
		files = {
			"kra_sfx_spiders_enemy_spider_priest_transform_v1.ogg"
		}
	},
	EnemySpiderSisterRange = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_enemy_spider_sister_range_var1_v1.ogg",
			"kra_sfx_spiders_enemy_spider_sister_range_var2_v1.ogg",
			"kra_sfx_spiders_enemy_spider_sister_range_var3_v1.ogg"
		}
	},
	EnemySpiderSisterSpawn = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.3,
		files = {
			"kra_sfx_spiders_enemy_spider_sister_spawn_v1.ogg"
		}
	},
	EnemySpidersMechanicSpawnerInflate = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_mechanic_spawner_prev_v1.ogg"
		}
	},
	EnemySpidersMechanicSpawnerExplode = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 4,
		files = {
			"kra_sfx_spiders_mechanic_spawner_explode_v1.ogg"
		}
	},
	EnemySpidersMechanicSpawnerRegenerate = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_mechanic_spawner_regenerate_v1.ogg"
		}
	},
	EnemySpidersMechanicTowerSpiderDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_mechanic_spider_death_v1.ogg"
		}
	},
	EnemySpidersMechanicTowerSpiderWorkingLoop = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = true,
		files = {
			"kra_sfx_spiders_mechanic_spider_working_LOOP_v1.ogg"
		}
	},
	EnemyAshSpiritDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_ash_spirit_death_v1.ogg"
		}
	},
	EnemyAshSpiritMelee = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_ash_spirit_melee_var1.ogg",
			"kra_sfx_wukong_enemy_ash_spirit_melee_var2.ogg",
			"kra_sfx_wukong_enemy_ash_spirit_melee_var3.ogg"
		}
	},
	EnemyBlazeRaiderMeleeSpecial = {
		loop = false,
		gain = 0.25,
		mode = "random",
		source_group = "SFX",
		delay = 0.15,
		files = {
			"kra_sfx_wukong_enemy_blaze_raider_special_v1.ogg"
		}
	},
	EnemyBurningTreantDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_burning_treant_death_v1.ogg"
		}
	},
	EnemyBurningTreantSpecial = {
		source_group = "SFX",
		gain = 0.25,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_burning_treant_special_v1.ogg"
		}
	},
	EnemyFireFoxDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_fire_fox_death_v1.ogg"
		}
	},
	EnemyFireFoxMelee = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.1,
		files = {
			"kra_sfx_wukong_enemy_fire_fox_melee_var1_v1.ogg",
			"kra_sfx_wukong_enemy_fire_fox_melee_var2_v1.ogg",
			"kra_sfx_wukong_enemy_fire_fox_melee_var3_v1.ogg"
		}
	},
	EnemyFirePhoenixDeath = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.1,
		files = {
			"kra_sfx_wukong_enemy_fire_phoenix_death_wScreech_v1.ogg"
		}
	},
	EnemyFlameGuardMeleeSpecial = {
		source_group = "SFX",
		mode = "random",
		gain = 0.4,
		loop = false,
		dealy = 0.1,
		files = {
			"kra_sfx_wukong_enemy_flame_guard_special_v1.ogg"
		}
	},
	EnemyNineTailedFoxDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_nine_tailed_fox_death_wWhimper_v1.ogg"
		}
	},
	EnemyNineTailedFoxMeleeDouble = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_wukong_enemy_nine_tailed_fox_melee_double_v1.ogg"
		}
	},
	EnemyNineTailedFoxMelee = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.05,
		files = {
			"kra_sfx_wukong_enemy_nine_tailed_fox_melee_var1_v1.ogg",
			"kra_sfx_wukong_enemy_nine_tailed_fox_melee_var2_v1.ogg",
			"kra_sfx_wukong_enemy_nine_tailed_fox_melee_var3_v1.ogg"
		}
	},
	EnemyNineTailedFoxTeleportIn = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_nine_tailed_fox_teleport_IN_v1.ogg"
		}
	},
	EnemyNineTailedFoxTeleportOut = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_nine_tailed_fox_teleport_OUT_v1.ogg"
		}
	},
	EnemyWuxianDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_wuxian_death_v1.ogg"
		}
	},
	EnemyWuxianRanged = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_wuxian_ranged_v1.ogg"
		}
	},
	EnemyWuxianSpecial = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_wuxian_special_woVoice_v1.ogg",
			"kra_sfx_wukong_enemy_wuxian_special_wVoice_v1.ogg"
		}
	},
	EnemyStormSpiritLeap = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_drakeling_leap_v1.ogg"
		}
	},
	EnemyStormSpiritDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_drakeling_death_v1.ogg"
		}
	},
	EnemyQiongqiRanged = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_qiongqi_ranged_op1_v1.ogg"
		}
	},
	EnemyQiongqiDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_qiongqi_death_v1.ogg"
		}
	},
	EnemyWaterSorceressSpecial = {
		loop = false,
		gain = 0.2,
		mode = "random",
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_wukong_enemy_wmaster_special_v1.ogg"
		}
	},
	EnemyElementalMelee = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.7,
		files = {
			"kra_sfx_wukong_enemy_elemental_melee_var1_v1.ogg",
			"kra_sfx_wukong_enemy_elemental_melee_var2_v1.ogg",
			"kra_sfx_wukong_enemy_elemental_melee_var3_v1.ogg"
		}
	},
	EnemyElementalRangedImpact = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_elemental_ranged_impact_var1_v1.ogg",
			"kra_sfx_wukong_enemy_elemental_ranged_impact_var2_v1.ogg",
			"kra_sfx_wukong_enemy_elemental_ranged_impact_var3_v1.ogg"
		}
	},
	EnemyElementalDeathEffectCast = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 1,
		files = {
			"kra_sfx_wukong_enemy_elemental_death_effect_cast_op1_v1.ogg"
		}
	},
	EnemyElementalDeathEffectStun = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_elemental_death_effect_stun_v1.ogg"
		}
	},
	EnemyElementalDeath = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 1,
		files = {
			"kra_sfx_wukong_enemy_elemental_death_normal_v1.ogg"
		}
	},
	EnemyFanGuardDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_fan_guard_death_op1_v1.ogg",
			"kra_sfx_wukong_enemy_fan_guard_death_op2_v1.ogg"
		}
	},
	EnemyFanGuardSpecial = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.7,
		files = {
			"kra_sfx_wukong_enemy_fan_guard_special_v1.ogg"
		}
	},
	EnemyDoomBringerDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_doombringer_death_v1.ogg"
		}
	},
	EnemyDoomBringerStun = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_doombringer_stun_v1.ogg"
		}
	},
	EnemyGoldenEyedAura = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_gebeast_aura_v1.ogg"
		}
	},
	EnemyGoldenEyedDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_gebeast_death_op2_v1.ogg"
		}
	},
	EnemyGoldenEyedMelee = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.7,
		files = {
			"kra_sfx_wukong_enemy_gebeast_melee_var1_v1.ogg",
			"kra_sfx_wukong_enemy_gebeast_melee_var2_v1.ogg",
			"kra_sfx_wukong_enemy_gebeast_melee_var3_v1.ogg"
		}
	},
	EnemyGoldenEyedSummon = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 1,
		files = {
			"kra_sfx_wukong_enemy_gebeast_bdksummon_v1.ogg"
		}
	},
	EnemyDemonMinotaurChargeStop = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_minotaur_charge_stop_v1.ogg"
		}
	},
	EnemyDemonMinotaurChargeTrample = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = true,
		files = {
			"kra_sfx_wukong_enemy_minotaur_charge_trample-LOOP_v1.ogg"
		}
	},
	EnemyDemonMinotaurChargeWarning = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_minotaur_charge_warning_v1.ogg"
		}
	},
	EnemyDemonMinotaurDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_minotaur_death_v1.ogg"
		}
	},
	EnemyDemonMinotaurHeadButt = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 1.3,
		files = {
			"kra_sfx_wukong_enemy_minotaur_headbutt_var1_v1.ogg",
			"kra_sfx_wukong_enemy_minotaur_headbutt_var2_v1.ogg",
			"kra_sfx_wukong_enemy_minotaur_headbutt_var3_v1.ogg"
		}
	},
	EnemyWarlockDeath = {
		loop = false,
		gain = 0.6,
		mode = "random",
		source_group = "SFX",
		delay = 1.1,
		files = {
			"kra_sfx_wukong_enemy_warlock_death_v1.ogg"
		}
	},
	EnemyWarlockRangedCast = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_warlock_ranged_cast_var1_v1.ogg",
			"kra_sfx_wukong_enemy_warlock_ranged_cast_var2_v1.ogg",
			"kra_sfx_wukong_enemy_warlock_ranged_cast_var3_v1.ogg"
		}
	},
	EnemyWarlockRangedImpact = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_warlock_ranged_impact_var1_v1.ogg",
			"kra_sfx_wukong_enemy_warlock_ranged_impact_var2_v1.ogg",
			"kra_sfx_wukong_enemy_warlock_ranged_impact_var3_v1.ogg"
		}
	},
	EnemyWarlockSummonChannel = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_enemy_warlock_summon_channel_v1.ogg"
		}
	},
	EnemyWarlockSummonSpawn = {
		loop = false,
		gain = 0.7,
		mode = "random",
		source_group = "SFX",
		delay = 1.4,
		files = {
			"kra_sfx_wukong_enemy_warlock_summon_spawn_v1.ogg"
		}
	},
	EnemyBossPrincessClone = {
		source_group = "SPECIALS",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_clone_v1.ogg"
		}
	},
	EnemyBossPrincessDeath = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_death_v1.ogg"
		}
	},
	EnemyBossPrincessHeroStunChannel = {
		source_group = "SPECIALS",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_hero_stun_channel_v2.ogg"
		}
	},
	EnemyBossPrincessHeroStunFail = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_hero_stun_fail_woVoice_v1.ogg",
			"kra_sfx_wukong_princess_hero_stun_fail_wVoice_v1.ogg"
		}
	},
	EnemyBossPrincessHeroStunSuccess = {
		source_group = "SPECIALS",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_hero_stun_success_v2.ogg"
		}
	},
	EnemyBossPrincessMeleeArea = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_wukong_princess_melee_area_v1.ogg"
		}
	},
	EnemyBossPrincessMelee = {
		loop = false,
		gain = 0.4,
		mode = "random",
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_wukong_princess_melee_var1_v1.ogg",
			"kra_sfx_wukong_princess_melee_var2_v1.ogg",
			"kra_sfx_wukong_princess_melee_var3_v1.ogg"
		}
	},
	EnemyBossPrincessMudPoolTransformation = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_mud_pool_transformation_v1.ogg"
		}
	},
	EnemyBossPrincessMudPoolSummon = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_mud_summon_var1_v1.ogg",
			"kra_sfx_wukong_princess_mud_summon_var2_v1.ogg",
			"kra_sfx_wukong_princess_mud_summon_var3_v1.ogg",
			"kra_sfx_wukong_princess_mud_summon_var4_v1.ogg",
			"kra_sfx_wukong_princess_mud_summon_var5_v1.ogg"
		}
	},
	EnemyBossPrincessMudTower = {
		loop = false,
		mode = "random",
		gain = 0.8,
		source_group = "SPECIALS",
		delay = 0,
		files = {
			"kra_sfx_wukong_princess_mud_tower_op1_v2.ogg",
			"kra_sfx_wukong_princess_mud_tower_op2_v2.ogg"
		}
	},
	EnemyBossPrincessRangedCast = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_ranged_cast_v1.ogg"
		}
	},
	EnemyBossPrincessRangedImpact = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_ranged_impact_var1_v1.ogg",
			"kra_sfx_wukong_princess_ranged_impact_var2_v1.ogg"
		}
	},
	EnemyBossPrincessTeleportIn = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_teleport-IN_v1.ogg"
		}
	},
	EnemyBossPrincessTeleportOut = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_princess_teleport-OUT_v1.ogg"
		}
	},
	Terrain1AmbienceSoundBirds = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_terrain1Ambient_birds_var1_v1.ogg",
			"kra_sfx_terrain1Ambient_birds_var2_v1.ogg",
			"kra_sfx_terrain1Ambient_birds_var3_v1.ogg",
			"kra_sfx_terrain1Ambient_birds_var4_v1.ogg",
			"kra_sfx_terrain1Ambient_birds_var5_v1.ogg",
			"kra_sfx_terrain1Ambient_birds_var6_v1.ogg"
		}
	},
	Terrain1AmbienceSoundWind = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_terrain1Ambient_wind_var1_v1.ogg",
			"kra_sfx_terrain1Ambient_wind_var2_v1.ogg",
			"kra_sfx_terrain1Ambient_wind_var3_v1.ogg"
		}
	},
	Terrain1CommonArboreanTapIn = {
		loop = false,
		mode = "random",
		gain = 0.9,
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_easterEgg_arboreanTap_in_var1_v2.ogg",
			"kra_sfx_easterEgg_arboreanTap_in_var2_v2.ogg"
		}
	},
	Terrain1CommonArboreanTapOut = {
		loop = false,
		mode = "random",
		gain = 0.9,
		source_group = "SFX",
		delay = 0.8,
		files = {
			"kra_sfx_easterEgg_arboreanTap_out_fullSeq_op1_v2.ogg",
			"kra_sfx_easterEgg_arboreanTap_out_fullSeq_op2_v2.ogg"
		}
	},
	EasterEggCommonTap = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_interactionTap.ogg"
		}
	},
	Terrain2AmbienceSoundBats = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_terrain2Ambient_bats_var1_v1.ogg",
			"kra_sfx_terrain2Ambient_bats_var2_v1.ogg",
			"kra_sfx_terrain2Ambient_bats_var3_v1.ogg"
		}
	},
	Terrain2AmbienceSoundWind = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_terrain2Ambient_wind_var1_v1.ogg",
			"kra_sfx_terrain2Ambient_wind_var2_v1.ogg",
			"kra_sfx_terrain2Ambient_wind_var3_v1.ogg"
		}
	},
	Terrain2AmbienceSoundWaterDrop = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_terrain2Ambient_waterDrops_var1_v1.ogg",
			"kra_sfx_terrain2Ambient_waterDrops_var2_v1.ogg",
			"kra_sfx_terrain2Ambient_waterDrops_var3_v1.ogg"
		}
	},
	Terrain3AmbienceSoundGutural = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_terrain3Ambient_gutural_var2_v1.ogg",
			"kra_sfx_terrain3Ambient_gutural_var3_v1.ogg",
			"kra_sfx_terrain3Ambient_gutural_var5_v1.ogg"
		}
	},
	Terrain4AmbienceSoundWind = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_update1Ambient_wind_var1.ogg",
			"kra_sfx_update1Ambient_wind_var2.ogg",
			"kra_sfx_update1Ambient_wind_var3.ogg",
			"kra_sfx_update1Ambient_wind_var4.ogg"
		}
	},
	Terrain6AmbienceSoundWindRocks = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_dlc1Ambient_windRocks_var1_v1.ogg",
			"kra_sfx_dlc1Ambient_windRocks_var2_v1.ogg",
			"kra_sfx_dlc1Ambient_windRocks_var3_v1.ogg"
		}
	},
	Terrain6AmbienceSoundForge = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_dlc1Ambient_forge_var1_v1.ogg",
			"kra_sfx_dlc1Ambient_forge_var2_v1.ogg",
			"kra_sfx_dlc1Ambient_forge_var3_v1.ogg"
		}
	},
	Stage01ArboreanSageAppear = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_stageTutorial_arboreanSage_appear_v1.ogg"
		}
	},
	Stage01ArboreanSageDisappear = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_stageTutorial_arboreanSage_disappear_v1.ogg"
		}
	},
	Stage01ArboreanSageCast = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.3,
		files = {
			"kra_sfx_stageTutorial_arboreanSage_cast_op2_v1.ogg"
		}
	},
	Stage01ArboreanSageShrubDisappear = {
		loop = false,
		mode = "random",
		gain = 0.6,
		source_group = "SFX",
		delay = 0.3,
		files = {
			"kra_sfx_stageTutorial_arboreanSage_shrubDisappear_var1_v1.ogg",
			"kra_sfx_stageTutorial_arboreanSage_shrubDisappear_var2_v1.ogg",
			"kra_sfx_stageTutorial_arboreanSage_shrubDisappear_var3_v1.ogg",
			"kra_sfx_stageTutorial_arboreanSage_shrubDisappear_var4_v1.ogg"
		}
	},
	Stage01Rune = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_runeStage1_v1.ogg"
		}
	},
	Stage01FireOff = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_campfire_off_v1.ogg"
		}
	},
	Stage01FireOn = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_campfire_on_v1.ogg"
		}
	},
	Stage01FireFinal = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_camperFire_tap3_v1.ogg"
		}
	},
	Stage01RobinHood = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 0.3,
		files = {
			"kra_sfx_easterEgg_robinHood_v1.ogg"
		}
	},
	Stage02LinkFishing = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_easterEgg_linkFishing_var3_v1.ogg",
			"kra_sfx_easterEgg_linkFishing_var2_v1.ogg",
			"kra_sfx_easterEgg_linkFishing_var1_v1.ogg"
		}
	},
	Stage02GuardianTreePreCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stageMechanic_guardianTree_pre-cast_v1.ogg"
		}
	},
	Stage02LionKing = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.85,
		files = {
			"kra_sfx_easterEgg_lionKing_op1_v1.ogg"
		}
	},
	Stage02GuardianTreeCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stageMechanic_guardianTree_cast_v1.ogg"
		}
	},
	Stage02GuardianTreeRoots = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stageMechanic_guardianTree_roots_v1.ogg"
		}
	},
	Stage0203Rune = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_runeStage2-3_v1.ogg"
		}
	},
	Stage02RaelynTeleport = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage02_cinematic_raelyn_teleport_v1.ogg"
		}
	},
	Stage02VeznanTeleport = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage02_cinematic_veznan_teleport_v1.ogg"
		}
	},
	Stage03HeartOfTheForestReady = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stageMechanic_heartOfTheForest_ready_v1.ogg"
		}
	},
	Stage03HeartOfTheForestCast = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.7,
		files = {
			"kra_sfx_stageMechanic_heartOfTheForest_cast_v1.ogg"
		}
	},
	Stage03HeartOfTheForestBlast = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stageMechanic_heartOfTheForest_energyBlasts_var1_v1.ogg",
			"kra_sfx_stageMechanic_heartOfTheForest_energyBlasts_var2_v1.ogg",
			"kra_sfx_stageMechanic_heartOfTheForest_energyBlasts_var3_v1.ogg",
			"kra_sfx_stageMechanic_heartOfTheForest_energyBlasts_var4_v1.ogg"
		}
	},
	Stage04ArboreanThornspears = {
		ignore = 1,
		mode = "sequence",
		gain = 0.7,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_arboreanthornspears_taunt01_a.ogg",
			"kr_voice_arboreanthornspears_taunt02_b.ogg"
		}
	},
	Stage04ElevatorIn = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage04_wildbeastElevator_inFull_op1.ogg"
		}
	},
	Stage04ElevatorOut = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage04_wildbeastElevator_out_v3.ogg"
		}
	},
	Stage04ElevatorBreak = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stageMechanic_wildbeastElevator_break_v1.ogg"
		}
	},
	Stage04Rune = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_runeStage4_v1.ogg"
		}
	},
	Stage04ArboreanFall = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_arboreanFall_op2_v1.ogg"
		}
	},
	Stage04SheepyFall = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_sheepyTerrain1_fall_v1.ogg"
		}
	},
	Stage04SheepyImpact = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0.75,
		files = {
			"kra_sfx_easterEgg_sheepyTerrain1_impact_v1.ogg"
		}
	},
	Stage05WoodcutterBearRoar = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stageMechanic_woodcutterBear_roar_v1.ogg"
		}
	},
	Stage05WoodcutterBearChop = {
		loop = false,
		mode = "random",
		gain = 1,
		source_group = "SFX",
		delay = 0.2,
		files = {
			"kra_sfx_stageMechanic_woodcutterBear_chop_2_v1.ogg",
			"kra_sfx_stageMechanic_woodcutterBear_chop_1_v1.ogg"
		}
	},
	Stage0506Rune = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_runeStage5-6_v1.ogg"
		}
	},
	Stage06BossPigSnore = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0,
		files = {
			"kra_sfx_stage06_bossFight_cinematic_goregrindSnore_v1.ogg"
		}
	},
	Stage06BossPigWakeUp = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0,
		files = {
			"kra_sfx_stage06_bossFight_cinematic_goregrindWakeUp_v1.ogg"
		}
	},
	Stage06BossPigAttack = {
		loop = false,
		mode = "random",
		gain = 0.8,
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_boss_goregrind_attack_var3_v1.ogg",
			"kra_sfx_boss_goregrind_attack_var2_v1.ogg",
			"kra_sfx_boss_goregrind_attack_var1_v1.ogg"
		}
	},
	Stage06BossPigJumpCinematic = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0,
		files = {
			"kra_sfx_stage06_bossFight_Cinematic_goregrindJump.ogg"
		}
	},
	Stage06BossPigJump = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 1.2,
		files = {
			"kra_sfx_boss_goregrind_jumpCast.ogg"
		}
	},
	Stage06BossPigLand = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.1,
		files = {
			"kra_sfx_boss_goregrind_jumpImpact_land_v1.ogg"
		}
	},
	Stage06BossPigFalling = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.1,
		files = {
			"kra_sfx_boss_goregrind_jumpImpact_falling_v1.ogg"
		}
	},
	Stage06BossPigDeath = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_boss_goregrind_death_v1.ogg"
		}
	},
	Stage06BossPigHorn = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_boss_goregrind_horn_v1.ogg"
		}
	},
	Stage06EasterEggMinecraftClick = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_minecraftPig_var3_v1.ogg"
		}
	},
	Stage06EasterEggMinecraftDeath = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_minecraftPig_death_v1.ogg"
		}
	},
	Stage06BurrowOpen = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stageMechanic_burrowOpen_v1.ogg"
		}
	},
	Stage06WoodenDoorOpen = {
		loop = true,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stageMechanic_woodenDoorOpen_v1.ogg"
		}
	},
	Stage06WoodenDoorClose = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.25,
		files = {
			"kra_sfx_stageMechanic_woodenDoorForcedClose_v1.ogg"
		}
	},
	Stage06AcolyteTeleport = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_cinematicStage06_acolyteTeleport_v1.ogg"
		}
	},
	Stage07CultTemple = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage07_cultTempleBridge_v1.ogg"
		}
	},
	Stage07Witcher = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_witcher_v1.ogg"
		}
	},
	Stage07CrowCaw = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_crow_caw_v1.ogg"
		}
	},
	Stage07CrowFly = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_crow_fly_v1.ogg"
		}
	},
	Stage08RescuedElves = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr_voice_rescuedelves_taunt01_b.ogg",
			"kr_voice_rescuedelves_taunt02_c.ogg"
		}
	},
	Stage08BasketTap = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_basket_tap_v1.ogg"
		}
	},
	Stage08BasketBreak = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_basket_break_v1.ogg"
		}
	},
	Stage09CultBridge = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage09_cultBridge_v1.ogg"
		}
	},
	Stage09CultBridgeRumble = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_stage09_cultBridge_rumble_v1.ogg"
		}
	},
	Stage09NightmarePortalCandles = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage09_nightmarePortalOn-candles_v1.ogg"
		}
	},
	Stage09NightmarePortalEye = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.2,
		files = {
			"kra_sfx_stage09_nightmarePortalOn-eye_v1.ogg"
		}
	},
	Stage09DryBonesBreak = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_dryBones_break_v1.ogg"
		}
	},
	Stage09DryBonesReform = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_dryBones_reform_v1.ogg"
		}
	},
	Stage09SheepyCamera = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		delay = 0.7,
		files = {
			"kra_sfx_easterEgg_sheepyTerrain2_camera_v1.ogg"
		}
	},
	Stage09SheepyBridge = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_sheepyTerrain2_bridgeBaa_v1.ogg"
		}
	},
	Stage10ObeliskActivation = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage10_obelisk_activation_op1_v3.ogg"
		}
	},
	Stage10ObeliskEffectChange = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage10_obelisk_effectChange_v2.ogg"
		}
	},
	Stage10ObeliskEffectStun = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage10_obelisk_effectStun_cast_v1.ogg"
		}
	},
	Stage10ObeliskEffectHealLoopStart = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage10_obelisk_effectHeal_cast_loopStart.ogg"
		}
	},
	Stage10ObeliskEffectHealLoop = {
		loop = true,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage10_obelisk_effectHeal_cast_LOOP_v1.ogg"
		}
	},
	Stage10ObeliskEffectTeleport = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {}
	},
	Stage10ObeliskEffectGolemSpawnCast = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage10_obelisk_golemSpawn_cast.ogg"
		}
	},
	Stage10ObeliskEffectGolemSpawnGolem = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage10_obelisk_golemSpawn_golem.ogg"
		}
	},
	Stage10VillagePeopleStatuePuff = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_villagePeople_statuePuff_op1_v1.ogg"
		}
	},
	Stage10VillagePeopleFireworks = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_villagePeople_fireworks_v1.ogg"
		}
	},
	Stage10VillagePeopleSong = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_villagePeople_hits_op2_v2.ogg"
		}
	},
	Stage11AmbienceThunder = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage11_ambienceThunder_var1_v1.ogg",
			"kra_sfx_stage11_ambienceThunder_var2_v1.ogg",
			"kra_sfx_stage11_ambienceThunder_var3_v1.ogg"
		}
	},
	Stage11PortalOpen = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_portalOpen_v1.ogg"
		}
	},
	Stage11PortalClose = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_portalClose_v1.ogg"
		}
	},
	Stage11MydriasIllusionSummonCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_mydriasIllusionSummon_cast_v1.ogg"
		}
	},
	Stage11MydriasIllusionShieldCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_mydriasIllusionShield_cast_v1.ogg"
		}
	},
	Stage11MydriasIllusionTendrilsCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_mydriasIllusionTendrils_cast_v1.ogg"
		}
	},
	Stage11MydriasIllusionTendrilsDeath = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_mydriasIllusionTendrils_death_v1.ogg"
		}
	},
	Stage11MydriasIllusionDeath = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_mydriasIllusion_death_v1.ogg"
		}
	},
	Stage11MidCinematicChainBreak = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_midCinematic_chainBreak_v1.ogg"
		}
	},
	Stage11MidCinematicPlatformMove = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_midCinematic_platformMove_v1.ogg"
		}
	},
	Stage11MidCinematicDenasJump = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_midCinematic_denasJump_v1.ogg"
		}
	},
	Stage11MidCinematicDenasJumpLand = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_midCinematic_denasJumpLand_v1.ogg"
		}
	},
	Stage11MidCinematicVeznanTeleport = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_midCinematic_veznanTeleport_v1.ogg"
		}
	},
	Stage11VeznanReady = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_veznanReady_op2_v1.ogg"
		}
	},
	Stage11VeznanSoulImpactCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_veznanSoulImpact_cast_v1.ogg"
		}
	},
	Stage11VeznanSoulImpactImpact = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage11_bossFight_veznanSoulImpact_impact_var1_v1.ogg",
			"kra_sfx_stage11_bossFight_veznanSoulImpact_impact_var2_v1.ogg",
			"kra_sfx_stage11_bossFight_veznanSoulImpact_impact_var3_v1.ogg"
		}
	},
	Stage11VeznanDemonGuardCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_veznanDemonGuard_cast_withoutPortal_v1.ogg"
		}
	},
	Stage11VeznanMagicShacklesCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_veznanMagicShackles_cast_v1.ogg"
		}
	},
	Stage11VeznanMagicShacklesRelease = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_veznanMagicShackles_release_v1.ogg"
		}
	},
	Stage11BossCorruptedDenasAttack = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_denasAttack_v1.ogg"
		}
	},
	Stage11BossCorruptedDenasGlarelingSpawn = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_denasGlarelingSpawn_v1.ogg"
		}
	},
	Stage11BossCorruptedDenasTransformationIn = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_denasTransformation_in_op1_v1.ogg"
		}
	},
	Stage11BossCorruptedDenasTransformationOut = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage11_bossFight_denasTransformation_out_v1.ogg"
		}
	},
	Stage11EasterEggFrodoAndSam = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_hobbitsShelob_v1.ogg"
		}
	},
	Stage11CreepPortalIn = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage11_bossFight_portalCreepIn_var1.ogg",
			"kra_sfx_stage11_bossFight_portalCreepIn_var2.ogg"
		}
	},
	Stage11CultLeaderLeave = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage11_bossFight_endCinematic_platformMove_v1.ogg"
		}
	},
	Stage12SheepyPart1 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_sheepyTerrain3_part1_v1.ogg"
		}
	},
	Stage12SheepyPart2 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_sheepyTerrain3_part2_v1.ogg"
		}
	},
	Stage12SheepyPart3 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_sheepyTerrain3_part3_v1.ogg"
		}
	},
	Stage12WeirderThingsEnterChar = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_easterEgg_weirderThings_enterChars_climb_v1.ogg"
		}
	},
	Stage12WeirderThingsFirstStrum = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		delay = 3.8,
		files = {
			"kra_sfx_easterEgg_weirderThings_enterChars_firstStrum_v1.ogg"
		}
	},
	Stage12WeirderThingsEnterCharTap2 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		delay = 0.25,
		files = {
			"kra_sfx_easterEgg_weirderThings_enterChars_tap2_v1.ogg"
		}
	},
	stage113DarkRayTowerRepair = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage113_darkRayTower_repair_v1.ogg"
		}
	},
	stage113DarkRayAttack = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage113_darkRayTower_attack_op2_v1.ogg"
		}
	},
	stage113DarkRaySpecialAttack = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage113_darkRayTower_specialAttack_v1.ogg"
		}
	},
	stage113DarkRayDestroy = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0.3,
		files = {
			"kra_sfx_stage113_darkRayTower_destroy_v1.ogg"
		}
	},
	Stage14NewPath = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage14_newPath_v1.ogg"
		}
	},
	Stage14BehemothPoolSplash = {
		loop = false,
		gain = 0.8,
		mode = "random",
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_stage14_behemothPool_splash_var1_v1.ogg",
			"kra_sfx_stage14_behemothPool_splash_var2_v1.ogg",
			"kra_sfx_stage14_behemothPool_splash_var3_v1.ogg"
		}
	},
	Stage14BehemothPoolSpawn1 = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage14_behemothPool_spawn1_v2.ogg"
		}
	},
	Stage14BehemothPoolSpawn2 = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage14_behemothPool_spawn2_v2.ogg"
		}
	},
	Stage14BehemothPoolSpawn3 = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 1.5,
		files = {
			"kra_sfx_stage14_behemothPool_spawn3_v2.ogg"
		}
	},
	Stage14RickPortal12Open = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_easterEgg_wobbaLubbaDubDub_portal12_open_v1.ogg"
		}
	},
	Stage14RickPortal12Pass = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_easterEgg_wobbaLubbaDubDub_portal12_pass_v1.ogg"
		}
	},
	Stage14RickPortal12Close = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_easterEgg_wobbaLubbaDubDub_portal12_close_v1.ogg"
		}
	},
	Stage14RickPortalOpenNoLaser = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		delay = 0,
		files = {
			"kra_sfx_easterEgg_wobbaLubbaDubDub_portal12_open-noLaser_v1.ogg"
		}
	},
	Stage14RickPortal3Out = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_easterEgg_wobbaLubbaDubDub_portal3_out_v1.ogg"
		}
	},
	Stage15ReinforcementDenasSummon = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kr_voice_kingdenas_taunt01_a.ogg",
			"kr_voice_kingdenas_taunt02_c.ogg",
			"kr_voice_kingdenas_taunt03_a.ogg"
		}
	},
	Stage15ReinforcementDenasBasicAttack1 = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage15_reinforcementDenas_basicAttack_p1_var1_v1.ogg",
			"kra_sfx_stage15_reinforcementDenas_basicAttack_p1_var2_v1.ogg",
			"kra_sfx_stage15_reinforcementDenas_basicAttack_p1_var3_v1.ogg"
		}
	},
	Stage15ReinforcementDenasBasicAttack2 = {
		source_group = "SFX",
		gain = 0.8,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage15_reinforcementDenas_basicAttack_p2_var1_v1.ogg",
			"kra_sfx_stage15_reinforcementDenas_basicAttack_p2_var2_v1.ogg",
			"kra_sfx_stage15_reinforcementDenas_basicAttack_p2_var3_v1.ogg"
		}
	},
	Stage15ReinforcementDenasSpecialAttack = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_reinforcementDenas_secondaryAttack_v1.ogg"
		}
	},
	Stage15ReinforcementDenasSpawn = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_reinforcementDenas_summon_op1_v1.ogg"
		}
	},
	Stage15MydriasEnter = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_cinematic_mydriasEnter_v1.ogg"
		}
	},
	Stage15MydriasExit = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_cinematic_mydriasExit_v1.ogg"
		}
	},
	Stage15MutatedMydriasEnter = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_cinematic_mutatedMydriasEnter_v1.ogg"
		}
	},
	Stage15MydriasTentacleTrap = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_bossFight_mydriasTentacleTrap_v1.ogg"
		}
	},
	Stage15MydriasTentacleCircleCounter = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_bossFight_mydriasTentacleCircleCounter_op1_v1.ogg"
		}
	},
	Stage15MydriasTentacleCircle = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_bossFight_mydriasTentacleCircle_op2_v2.ogg"
		}
	},
	Stage15MydriasRay = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0.4,
		files = {
			"kra_sfx_stage15_bossFight_mydriasRay_v1.ogg"
		}
	},
	Stage15MydriasUncloak = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_bossFight_mydriasUncloak_v1.ogg"
		}
	},
	Stage15MydriasBurrowIn = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_bossFight_mydriasBurrowIn_v1.ogg"
		}
	},
	Stage15MydriasBurrowOut = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_bossFight_mydriasBurrowOut_v1.ogg"
		}
	},
	Stage15RiffPortalOpen = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_riffPortal_portalOpen_v1.ogg"
		}
	},
	Stage15RiffPortalClose = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_riffPortal_portalClose_v1.ogg"
		}
	},
	Stage15RiffPortalBroom = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_riffPortal_Broom_v1.ogg"
		}
	},
	Stage15MydriasDeath = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_bossFight_mydriasDeath.ogg"
		}
	},
	Stage15ReinforcementDenasOut = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage15_reinforcementDenas_out_v1.ogg"
		}
	},
	Stage16OverseerRumble = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerRumble_op1_v1.ogg"
		}
	},
	Stage16OverseerUnchainCenter = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerUnchainCenter_v1.ogg"
		}
	},
	Stage16OverseerUnchainLeftRight = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerUnchainLeftRight_v1.ogg"
		}
	},
	Stage16OverseerUnchainDown = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerUnchainDown_v1.ogg"
		}
	},
	Stage16OverseerSpawnerCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerSpawnerCast_v1.ogg"
		}
	},
	Stage16OverseerSpawnerImpact = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerSpawnerImpact_v1.ogg"
		}
	},
	Stage16OverseerTeleportCharge = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerTowerTeleport_PreCharge_v1.ogg"
		}
	},
	Stage16OverseerTeleport = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerTowerTeleport_TowerTeleport_v1.ogg"
		}
	},
	Stage16OverseerDestroyCharge = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerTowerHolderDestroy_charge_v1.ogg"
		}
	},
	Stage16OverseerDestroyRay = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerTowerHolderDestroy_Ray_v1.ogg"
		}
	},
	Stage16OverseerDestroyExplosion = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerTowerHolderDestroy_explosion_op2_v1.ogg"
		}
	},
	Stage16OverseerHurt = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage16_bossFight_overseerHurt_op1_v1.ogg"
		}
	},
	Stage16OverseerDeath = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_stage16_bossFight_overseerDefeat_fullSeq_v2.ogg"
		}
	},
	Stage17VinesOut = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage17_rootSoulcaller_cast.ogg"
		}
	},
	Stage17RootSoulcallerIn = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage17_rootSoulcaller_in.ogg"
		}
	},
	Stage17RootSoulcallerOut = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		delay = 0.25,
		files = {
			"kra_sfx_stage17_rootSoulcaller_out.ogg"
		}
	},
	Stage18EridanInOut = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage18_eridan_in-out_v2.ogg"
		}
	},
	Stage18EridanInstakill = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage18_eridan_instakill_v2.ogg"
		}
	},
	Stage18LampBreak = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage18_lamp_break_op1_v1.ogg"
		}
	},
	Stage18CuckooIn = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.2,
		files = {
			"kra_sfx_easterEgg_stage18Sheepy_tap-OPEN_v1.ogg"
		}
	},
	Stage18CuckooOut = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.6,
		files = {
			"kra_sfx_easterEgg_stage18Sheepy_tap-CLOSE_v1.ogg"
		}
	},
	Stage19NaviraEnter = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage19_bossFight_navira_enter_v1.ogg"
		}
	},
	Stage19NaviraFireballSpawn = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage19_bossFight_navira_fireball_spawn_var1_v1.ogg",
			"kra_sfx_stage19_bossFight_navira_fireball_spawn_var2_v1.ogg",
			"kra_sfx_stage19_bossFight_navira_fireball_spawn_var3_v1.ogg"
		}
	},
	Stage19NaviraFireballCast = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage19_bossFight_navira_fireball_cast_var1_v1.ogg",
			"kra_sfx_stage19_bossFight_navira_fireball_cast_var2_v1.ogg",
			"kra_sfx_stage19_bossFight_navira_fireball_cast_var3_v1.ogg"
		}
	},
	Stage19NaviraFireballHit = {
		source_group = "SFX",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage19_bossFight_navira_fireball_impact_var1_v2.ogg",
			"kra_sfx_stage19_bossFight_navira_fireball_impact_var2_v2.ogg",
			"kra_sfx_stage19_bossFight_navira_fireball_impact_var3_v2.ogg"
		}
	},
	Stage19NaviraHandsDown = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage19_bossFight_statue_handsDown_v1.ogg"
		}
	},
	Stage19NaviraHandsUp = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 4.9,
		files = {
			"kra_sfx_stage19_bossFight_statue_handsUp_v1.ogg"
		}
	},
	Stage19NaviraTornadoIn = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage19_bossFight_navira_tornado_transformIn_op1_v1.ogg"
		}
	},
	Stage19NaviraTornadoOut = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage19_bossFight_navira_tornado_transformOut_v1.ogg"
		}
	},
	Stage19NaviraDeath = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage19_bossFight_navira_death_v1.ogg"
		}
	},
	Stage19Statue12 = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage19_statueGame_tap12_v1.ogg"
		}
	},
	Stage19Statue3 = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage19_statueGame_tap3_v1.ogg"
		}
	},
	Stage20TreeWakeup = {
		loop = false,
		gain = 0.8,
		mode = "random",
		source_group = "SFX",
		delay = 1,
		files = {
			"kra_sfx_crocs_tree_wakeup_op1_v1.ogg",
			"kra_sfx_crocs_tree_wakeup_op2_v1.ogg",
			"kra_sfx_crocs_tree_wakeup_op3_v1.ogg"
		}
	},
	Stage20TreeHeadScratch = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.833,
		files = {
			"kra_sfx_crocs_head_scratch_v1.ogg"
		}
	},
	Stage20TreeHitFloor = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_trunk_hit_floor_v1.ogg"
		}
	},
	Stage20TreeHitFloorRepeat = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_tower_logBounce_var1_v1.ogg",
			"kra_sfx_tower_logBounce_var2_v1.ogg",
			"kra_sfx_tower_logBounce_var3_v1.ogg"
		}
	},
	Stage20BeesFly = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_bee_flying_v1.ogg"
		}
	},
	Stage20BeesThrow = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_bee_hit_floor_THROW_v1.ogg"
		}
	},
	Stage20BeesImpact = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_bee_hit_floor_IMPACT_v1.ogg"
		}
	},
	Stage20HouseImpact = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_arboreans_house_hit_var1_v1.ogg",
			"kra_sfx_crocs_arboreans_house_hit_var2_v1.ogg",
			"kra_sfx_crocs_arboreans_house_hit_var3_v1.ogg"
		}
	},
	Stage20HouseDestroyed = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_arboreans_house_destroy_v1.ogg"
		}
	},
	Stage21JuanchoEngineFail = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.333,
		files = {
			"kra_sfx_crocs_juancho_engine_fail_v1.ogg"
		}
	},
	Stage21JuanchoEngineSuccess = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.333,
		files = {
			"kra_sfx_crocs_juancho_engine_sucess_v1.ogg"
		}
	},
	Stage22AbominorAcidHit = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_acid_hit_floor_var1_v1.ogg",
			"kra_sfx_crocs_abominor_acid_hit_floor_var2_v1.ogg",
			"kra_sfx_crocs_abominor_acid_hit_floor_var3_v1.ogg"
		}
	},
	Stage22AbominorCatchArm = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_catch_arm_again_v1.ogg"
		}
	},
	Stage22AbominorDeath = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_death_v1.ogg"
		}
	},
	Stage22AbominorEatEnemy = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_eat_enemy_op2_v1.ogg"
		}
	},
	Stage22AbominorEatTower = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_eat_tower_eat_v1.ogg"
		}
	},
	Stage22AbominorEatTowerV2 = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_release_eatTower_v2.ogg"
		}
	},
	Stage22AbominorEatTowerFistRemove = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_eat_tower_fistRemove_v1.ogg"
		}
	},
	Stage22AbominorFireballHit = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_fireball_hit_floor_var1_v1.ogg",
			"kra_sfx_crocs_abominor_fireball_hit_floor_var2_v1.ogg",
			"kra_sfx_crocs_abominor_fireball_hit_floor_var3_v1.ogg"
		}
	},
	Stage22AbominorMeleeHit = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_hit_enemy_var1_v1.ogg",
			"kra_sfx_crocs_abominor_hit_enemy_var2_v1.ogg",
			"kra_sfx_crocs_abominor_hit_enemy_var3_v1.ogg"
		}
	},
	Stage22AbominorReleaseArm = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_release_arm_v1.ogg"
		}
	},
	Stage22AbominorReleaseArmEatTowerOneshot = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_release_arm-eatTower_v2.ogg"
		}
	},
	Stage22AbominorScreamTransformation = {
		source_group = "SFX",
		gain = 0.733,
		loop = false,
		delay = 0.9,
		files = {
			"kra_sfx_crocs_abominor_grow_v1.ogg"
		}
	},
	Stage22AbominorSetFree = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_crocs_abominor_set_free_v1.ogg"
		}
	},
	Stage22AbominorShootAcid = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.0666,
		files = {
			"kra_sfx_crocs_abominor_shoot_acid_throw_v1.ogg"
		}
	},
	Stage22AbominorShootFireball = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.0333,
		files = {
			"kra_sfx_crocs_abominor_shoot_fireball_v1.ogg"
		}
	},
	Stage22AbominorSpitEggs = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.15,
		files = {
			"kra_sfx_crocs_abominor_spit_eggs_var1_v1.ogg"
		}
	},
	Stage22AbominorFallToPath = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.0666,
		files = {
			"kra_sfx_crocs_abominor_stones_hit_floor_oneShot_v1.ogg"
		}
	},
	Stage22TowerRestore = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0,
		files = {
			"kra_sfx_crocs_magic_tower_restore_op1_v1.ogg"
		}
	},
	Stage23BootOpen = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage23_automatonFoot_open_v1.ogg"
		}
	},
	Stage23BootClose = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage23_automatonFoot_close_v1.ogg"
		}
	},
	Stage23TruckOneShot = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_truck_oneShot_v1.ogg"
		}
	},
	Stage23TruckTap3 = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_truck_tap3_full_v1.ogg"
		}
	},
	Stage24UpgradeStationIn = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_upgradeStation_in_op2_v1.ogg"
		}
	},
	Stage24UpgradeStationOut = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_upgradeStation_out_v1.ogg"
		}
	},
	Stage24UpgradeStationTransform = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_upgradeStation_transform_v1.ogg"
		}
	},
	Stage24MachinistEnter = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_machinist_enter_op1_v1.ogg"
		}
	},
	Stage24MachinistExit = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_machinist_exit_v1.ogg"
		}
	},
	Stage24MachinistLever1 = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.3,
		files = {
			"kra_sfx_stage24_machinist_lever_1_v1.ogg"
		}
	},
	Stage24MachinistLever2 = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.1,
		files = {
			"kra_sfx_stage24_machinist_lever_2_v1.ogg"
		}
	},
	Stage24MachinistLever3 = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 0.1,
		files = {
			"kra_sfx_stage24_machinist_lever_3_v1.ogg"
		}
	},
	Stage24FactoryTurnOnStart = {
		loop = false,
		gain = 0.2,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_factory_turnOn_start_v1.ogg"
		}
	},
	Stage24FactoryTurnOnEnd = {
		source_group = "SFX",
		gain = 0.4,
		loop = false,
		delay = 0.7,
		files = {
			"kra_sfx_stage24_factory_turnOn_end_v1.ogg"
		}
	},
	Stage24FactoryTurnOff = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_factory_turnOff_v1.ogg"
		}
	},
	Stage24Outro = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_outro_v1.ogg"
		}
	},
	Stage24BFMachinistCannonCastShot = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_bossFight_machinist_cannon_cast_shot_v1.ogg"
		}
	},
	Stage24BFMachinistCannonImpact = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage24_bossFight_machinist_cannon_impact_v1.ogg"
		}
	},
	Stage25TorsoOpen = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_torso_open_v1.ogg"
		}
	},
	Stage25TorsoOperateLever1 = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_torso_operate_lever1_v1.ogg"
		}
	},
	Stage25TorsoOperateLever2 = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_torso_operate_lever2_v1.ogg"
		}
	},
	Stage25TorsoClose = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_torso_close_v1.ogg"
		}
	},
	Stage25FistSlam = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_fist_slam_v1.ogg"
		}
	},
	Stage25TorsoButton = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_torso_button_v1.ogg"
		}
	},
	Stage25MissileLaunch = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_missile_launch_v1.ogg"
		}
	},
	Stage25MissileImpact = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_missile_impact_v1.ogg"
		}
	},
	Stage25IntroCrash = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_intro_crash_v1.ogg"
		}
	},
	Stage25IntroCrashFinalExplosion = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_intro_crash-finalExplosion_v1.ogg"
		}
	},
	Stage25Outro = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage25_outro_v1.ogg"
		}
	},
	Stage25SolidSnakeTap12 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_solidSnake_tap12_v1.ogg"
		}
	},
	Stage25SolidSnakeTap3 = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_solidSnake_tap3-MG_v1.ogg"
		}
	},
	Stage26Chain = {
		source_group = "SFX",
		gain = 0.5,
		loop = false,
		delay = 1,
		files = {
			"kra_sfx_stage26_grymbeardChainPull_short.ogg"
		}
	},
	Stage26FistSpawnerHand = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_stage26_fistSpawner_HAND_var1_v1.ogg",
			"kra_sfx_stage26_fistSpawner_HAND_var2_v1.ogg",
			"kra_sfx_stage26_fistSpawner_HAND_var3_v1.ogg"
		}
	},
	Stage26FistSpawnerBoothFrontDoorOpen = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage26_fistSpawner_BoothFrontDoorOpen_v1.ogg"
		}
	},
	Stage26FistSpawnerBoothFrontDoorClose = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage26_fistSpawner_BoothFrontDoorClose_v1.ogg"
		}
	},
	Stage26CloneSpawnerIn = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_stage26_cloneSpawner_IN.ogg"
		}
	},
	Stage26CloneSpawnerOut = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_stage26_cloneSpawner_OUT.ogg"
		}
	},
	Stage26HulkSpawnerShotTransform = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_stage26_hulkSpawner_shot-transform_oneShot_v1.ogg"
		}
	},
	Stage26PreBFCinematic = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_stage26_preBFCinematic_v1.ogg"
		}
	},
	Stage26BFGrymbeardDamaged = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage26_bossFight_grymbeard_damaged_v1.ogg"
		}
	},
	Stage26Outro = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage26_outro_v2.ogg"
		}
	},
	Stage26MewtwoTap12 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_mewtwo_tap12_v1.ogg"
		}
	},
	Stage26MewtwoTap3 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_mewtwo_tap3_v1.ogg"
		}
	},
	Stage26MewtwoFlightFullSequence = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_mewtwo_flight_fullSeq_v1.ogg"
		}
	},
	Stage27Intro = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_intro_v1.ogg"
		}
	},
	Stage27PlatformUp = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_platformUp_v1.ogg"
		}
	},
	Stage27PlatformDown = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_platformDown_v1.ogg"
		}
	},
	Stage27PlatformDestroyChains = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_platformDestroy_chains_v1.ogg"
		}
	},
	Stage27PlatformDestroyHeadImpacts = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_platformDestroy_headImpacts_v1.ogg"
		}
	},
	Stage27CloneCannonOneShot = {
		source_group = "SFX",
		gain = 0.8,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_stage27_cloneCannon_oneShot_shot-retreat_v1.ogg"
		}
	},
	Stage27CloneCannonAlarm = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_cloneCannon_alarm_v1.ogg"
		}
	},
	Stage27HeadOpen = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.3,
		files = {
			"kra_sfx_stage27_headOpen_v1.ogg"
		}
	},
	Stage27HeadClose = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_headClose_v1.ogg"
		}
	},
	Stage27HeadMove = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_stage27_headFireblast_move_v1.ogg"
		}
	},
	Stage27HeadReturn = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_headFireblast_move-returntocenter_v1.ogg"
		}
	},
	Stage27HeadFireblastCharge = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		interruptible = true,
		files = {
			"kra_sfx_stage27_headFireblast_charge_v1.ogg"
		}
	},
	Stage27HeadFireblastRelease = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		interruptible = true,
		files = {
			"kra_sfx_stage27_headFireblast_release_v1.ogg"
		}
	},
	Stage27HeadFireblastCancelTap = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_headFireblast_cancelTap_v1.ogg"
		}
	},
	Stage27HeadFireblastInterrupt = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_headFireblast_interrupt_v1.ogg"
		}
	},
	Stage27PreBossfightCinematic = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_preBossFightCinematic_v1.ogg"
		}
	},
	Stage27BFGrymbeardDeath = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_bossFight_grymbeard_death_v1.ogg"
		}
	},
	Stage27BFGrymbeardMeleeAttack = {
		loop = false,
		mode = "random",
		gain = 0.8,
		source_group = "SFX",
		delay = 0.9,
		files = {
			"kra_sfx_stage27_bossFight_grymbeard_meleeAttack_var1_v1.ogg",
			"kra_sfx_stage27_bossFight_grymbeard_meleeAttack_var2_v1.ogg",
			"kra_sfx_stage27_bossFight_grymbeard_meleeAttack_var3_v1.ogg"
		}
	},
	Stage27BFGrymbeardRangedAttackCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_bossFight_grymbeard_rangedAttack_cast_v1.ogg"
		}
	},
	Stage27BFGrymbeardRangedAttackImpact = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_bossFight_grymbeard_rangedAttack_impact_v1.ogg"
		}
	},
	Stage27BFRobotScrapCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_stage27_bossFight_robotScrap_cast_v1.ogg"
		}
	},
	Stage27BeamWorkersTap1 = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx-easterEgg_beamWorkers_tap1_v1.ogg"
		}
	},
	Stage27BeamWorkersTap2 = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx-easterEgg_beamWorkers_tap2_v1.ogg"
		}
	},
	Stage27BeamWorkersTap3 = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx-easterEgg_beamWorkers_tap3_v1.ogg"
		}
	},
	Stage30BossfightCinematic = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_cinematic_op1_v1.ogg"
		}
	},
	Stage30BossfightClawOpen = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_claw_open_v1.ogg"
		}
	},
	Stage30BossfightClawClose = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_claw_close_v1.ogg"
		}
	},
	Stage30BossfightRange = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_spiders_bossfight_range_var1_v1.ogg",
			"kra_sfx_spiders_bossfight_range_var2_v1.ogg",
			"kra_sfx_spiders_bossfight_range_var3_v1.ogg"
		}
	},
	Stage30BossfightSpit = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_spit_v1.ogg"
		}
	},
	Stage30BossfightJump = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_jump_v1.ogg"
		}
	},
	Stage30BossfightFall = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_fall_v1.ogg"
		}
	},
	Stage30BossfightDead = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_dead_v1.ogg"
		}
	},
	Stage30BossfightDrainLoopStart = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_drain_charge_loop-start_v1.ogg"
		}
	},
	Stage30BossfightDrainLoop = {
		loop = true,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_drain_charge_loop_v1.ogg"
		}
	},
	Stage30BossfightDrainExecute = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_drain_execute_v1.ogg"
		}
	},
	Stage30BossfightBuffCharge = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_spiders_bossfight_buff_charge_v1.ogg"
		}
	},
	Stage31FountainRefill = {
		source_group = "SPECIALS",
		gain = 0.7,
		loop = false,
		delay = 3,
		files = {
			"kra_sfx_wukong_mechanic_stage1_fountain_refill_v1.ogg"
		}
	},
	Stage31FountainSplash = {
		loop = false,
		gain = 0.8,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage1_fountain_splash_v1.ogg"
		}
	},
	Stage31FountainTapoon = {
		source_group = "SPECIALS",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_mechanic_stage1_fountain_tapon_var1_v1.ogg",
			"kra_sfx_wukong_mechanic_stage1_fountain_tapon_var2_v1.ogg",
			"kra_sfx_wukong_mechanic_stage1_fountain_tapon_var3_v1.ogg"
		}
	},
	Stage32RedboyDragonSamadhiFireStart = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 0.35,
		files = {
			"kra_sfx_wukong_stage32_redboy_samadhi_fire_part1_v2.ogg"
		}
	},
	Stage32RedboyDragonSamadhiFireEnd = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 2.7,
		files = {
			"kra_sfx_wukong_stage32_redboy_samadhi_fire_part2_v2.ogg"
		}
	},
	Stage32RedboyDragonLavaSurge = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 0.6,
		files = {
			"kra_sfx_wukong_stage32_redboy_lava_surge_woVoice_v2.ogg"
		}
	},
	Stage32RedboyDragonRoar = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 1,
		files = {
			"kra_sfx_wukong_stage32_dragon_roar_v1.ogg"
		}
	},
	Stage32RedboyDragonBlockTowers = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 1.5,
		files = {
			"kra_sfx_wukong_stage32_dragon_lava_spit_op2_v1.ogg"
		}
	},
	Stage32RedboyAbsorbFire = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 0.2,
		files = {
			"kra_sfx_wukong_stage32_redboy_explosion_v1.ogg"
		}
	},
	Stage32RedboyTransform = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 0.5,
		files = {
			"kra_sfx_wukong_stage32_redboy_transform_v1.ogg"
		}
	},
	Stage32RedboyJumpFromDragon = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 0.6,
		files = {
			"kra_sfx_wukong_stage32_redboy_entrance_op2_v1.ogg"
		}
	},
	Stage32RedboySamadhiAsTeen = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 1.3,
		files = {
			"kra_sfx_wukong_stage32_redboy_samadhi_teen_prep_op2_v1.ogg"
		}
	},
	Stage32RedboyDeathStart = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SPECIALS",
		delay = 0,
		files = {
			"kra_sfx_wukong_stage32_redboy_death_part1_v1.ogg"
		}
	},
	Stage32RedboyDeathEnd = {
		loop = false,
		mode = "random",
		gain = 0.7,
		source_group = "SFX",
		delay = 0.6,
		files = {
			"kra_sfx_wukong_stage32_redboy_death_part2_v1.ogg"
		}
	},
	Stage33StormStart = {
		source_group = "SPECIALS",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_mechanic_stage3_storm_ambience_LOOPStart_v1.ogg"
		}
	},
	Stage33StormLoop = {
		loop = true,
		gain = 0.2,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage3_storm_ambience_LOOP_v1.ogg"
		}
	},
	Stage33StormDistantThunder = {
		source_group = "SFX",
		gain = 0.2,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_mechanic_stage3_storm_ambience_distantThunder_var1_v1.ogg",
			"kra_sfx_wukong_mechanic_stage3_storm_ambience_distantThunder_var2_v1.ogg",
			"kra_sfx_wukong_mechanic_stage3_storm_ambience_distantThunder_var3_v1.ogg"
		}
	},
	Stage33StormLightning = {
		source_group = "SFX",
		gain = 0.4,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_mechanic_stage3_storm_lightning_strike_var1_v1.ogg",
			"kra_sfx_wukong_mechanic_stage3_storm_lightning_strike_var2_v1.ogg",
			"kra_sfx_wukong_mechanic_stage3_storm_lightning_strike_var3_v1.ogg"
		}
	},
	Stage33StormLightningMark = {
		source_group = "SFX",
		gain = 0.7,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_mechanic_stage3_storm_lightning_mark_v1.ogg"
		}
	},
	Stage33BoatDrumLoop = {
		loop = true,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage3_boat_drum_op2_v1.ogg"
		}
	},
	Stage35PortalWater = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage35_portal_water_v1.ogg"
		}
	},
	Stage35Spawners = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage35_spawners_v1.ogg"
		}
	},
	Stage35BossBullKingEat = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_bdk_intro_eatandgrow_v1.ogg"
		}
	},
	Stage35BossBullKingDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_bdk_death_v1.ogg"
		}
	},
	Stage35BossBullKingJumpToPath = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_bdk_intro_jumpToPath_v1.ogg"
		}
	},
	Stage35BossBullKingStand = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_bdk_intro_stand_v1.ogg"
		}
	},
	Stage35BossBullKingMeleeArea = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_bdk_melee_area_v1.ogg"
		}
	},
	Stage35BossBullKingMeleeVar1 = {
		source_group = "SFX",
		gain = 0.5,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_wukong_bdk_melee_var1_v1.ogg",
			"kra_sfx_wukong_bdk_melee_var2_v1.ogg",
			"kra_sfx_wukong_bdk_melee_var3_v1.ogg",
			"kra_sfx_wukong_bdk_melee_var4_v1.ogg"
		}
	},
	Stage35BossBullKingStun = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_bdk_stun_op1_v1.ogg"
		}
	},
	Stage35Cinematic1 = {
		source_group = "SPECIALS",
		gain = 0.5,
		loop = false,
		delay = 1.5,
		files = {
			"kra_sfx_wukong_mechanic_stage35_cinematic_1_v1.ogg"
		}
	},
	Stage35Cinematic2 = {
		source_group = "SPECIALS",
		gain = 0.5,
		loop = false,
		delay = 1.5,
		files = {
			"kra_sfx_wukong_mechanic_stage35_cinematic_2_v1.ogg"
		}
	},
	Stage35Cinematic3 = {
		source_group = "SPECIALS",
		gain = 0.5,
		loop = false,
		delay = 1.5,
		files = {
			"kra_sfx_wukong_mechanic_stage35_cinematic_3_v1.ogg"
		}
	},
	Stage35Cinematic4Part1 = {
		source_group = "SPECIALS",
		gain = 0.5,
		loop = false,
		delay = 0.5,
		files = {
			"kra_sfx_wukong_mechanic_stage35_cinematic_4_part1_v1.ogg"
		}
	},
	Stage35Cinematic4Part2 = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage35_cinematic_4_part2_v1.ogg"
		}
	},
	Stage35Cinematic4Part2Scream = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage35_cinematic_4_scream_v2.ogg"
		}
	},
	Terrain3GlareOnSmall1 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_terrain3_glareOn_littleEye_op1_v1.ogg"
		}
	},
	Terrain3GlareOnSmall2 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_terrain3_glareOn_littleEye_op2_v1.ogg"
		}
	},
	Terrain3GlareOnBig = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_terrain3_glareOn_bigEye_v1.ogg"
		}
	},
	Terrain3GlareOff = {
		source_group = "SFX",
		gain = 1,
		loop = false,
		delay = 0.75,
		files = {
			"kra_sfx_terrain3_glare_off_v1.ogg"
		}
	},
	Terrain4CheshireCatIn = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_cheshireCat_appear_v1.ogg"
		}
	},
	Terrain4CheshireCatOut = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 1.4,
		files = {
			"kra_sfx_easterEgg_cheshireCat_disappear_v1.ogg"
		}
	},
	Terrain4HowlingTree = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kra_sfx_easterEgg_howlingTree_var1_v1.ogg",
			"kra_sfx_easterEgg_howlingTree_var2_v1.ogg",
			"kra_sfx_easterEgg_howlingTree_var3_v1.ogg"
		}
	},
	Terrain6ExodiaPart = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_easterEgg_exodiaPart_v1.ogg"
		}
	},
	TerrainWukongMeteoriteCast = {
		loop = false,
		gain = 0.55,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage1_meteorites_LOOP_in_faded_martin.ogg"
		}
	},
	TerrainWukongMeteoriteImpact = {
		loop = false,
		gain = 0.55,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage1_meteorites_impact_v2.ogg"
		}
	},
	TerrainWukongMeteoriteTravelLoop = {
		loop = true,
		gain = 0.55,
		source_group = "SPECIALS",
		files = {
			"kra_sfx_wukong_mechanic_stage1_meteorites_travel-LOOP_v1.ogg"
		}
	},
	TerrainWukongElementalHolderEvolve = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_mechanic_stage1_holder_evolve_v1.ogg"
		}
	},
	TerrainWukongElementalHolderUnlock = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_mechanic_stage1_holder_unlock.ogg"
		}
	},
	TerrainWukongElementalHolderWoodActive = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_mechanic_stage1_holder_active_vines_v1.ogg"
		}
	},
	TerrainWukongElementalHolderFireActiveIn = {
		loop = false,
		gain = 0.3,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_mechanic_stage2_holder_active_instakill_v1_in.ogg"
		}
	},
	TerrainWukongElementalHolderFireActiveKill = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_mechanic_stage2_holder_active_instakill_v1_kill.ogg"
		}
	},
	TerrainWukongElementalHolderEarthActive = {
		source_group = "SFX",
		gain = 0.7,
		loop = false,
		delay = 2,
		files = {
			"kra_sfx_wukong_mechanic_stage34_holder_active_summon_v1.ogg"
		}
	},
	TerrainWukongElementalHolderMetalActive = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_wukong_mechanic_stage35_holder_active_steal_op2_v1.ogg"
		}
	},
	ItemsClusterBombCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_clusterBomb_cast_v1.ogg"
		}
	},
	ItemsClusterBombSmallBombs = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_clusterBomb_smallBombs_v1.ogg"
		}
	},
	ItemsPortableCoilCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_portableCoil_cast_v1.ogg"
		}
	},
	ItemsPortableCoilAttack = {
		loop = false,
		mode = "random",
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_portableCoil_attack_var1_v1.ogg",
			"kra_sfx_inApps_portableCoil_attack_var2_v1.ogg",
			"kra_sfx_inApps_portableCoil_attack_var3_v1.ogg"
		}
	},
	ItemsScrollOfSpaceshiftCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_scrollOfSpaceshift_cast_v1.ogg"
		}
	},
	ItemsScrollOfSpaceshiftTeleportIn = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_scrollOfSpaceshift_teleportIn_v1.ogg"
		}
	},
	ItemsScrollOfSpaceshiftTeleportOut = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_scrollOfSpaceshift_teleportOut_v1.ogg"
		}
	},
	ItemsSecondBreathCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_secondBreath_cast_v1.ogg"
		}
	},
	ItemsDeathsTouchCast = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_deathsTouch_cast_v1.ogg"
		}
	},
	ItemsWinterAgeCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_winterAge_cast_v1.ogg"
		}
	},
	ItemsWinterAgeLoop = {
		loop = true,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_winterAge_loop_v1.ogg"
		}
	},
	ItemsWinterAgeRelease = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_winterAge_release_v1.ogg"
		}
	},
	ItemsLootBoxCast = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_lootBox_cast_v1.ogg"
		}
	},
	ItemsMedicalKitCast = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_medicalKit_cast_op1_v1.ogg"
		}
	},
	ItemsMedicalKitHeartAdd = {
		loop = false,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_medicalKit_heartAdd_v1.ogg"
		}
	},
	ItemsBlackburnCast = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_helmOfBlackburn_cast.ogg"
		}
	},
	ItemsBlackburnMeleeAttack = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		mode = "random",
		delay = 0.4,
		files = {
			"kra_sfx_inApps_helmOfBlackburn_meleeAttack_var1_v1.ogg",
			"kra_sfx_inApps_helmOfBlackburn_meleeAttack_var2_v1.ogg",
			"kra_sfx_inApps_helmOfBlackburn_meleeAttack_var3_v1.ogg"
		}
	},
	ItemsBlackburnRangedAttack = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kra_sfx_inApps_helmOfBlackburn_rangedAttack_op2_v1.ogg"
		}
	},
	ItemsVeznanWrathEnter = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kr5_sfx_veznanwrath_appear_sinrisa_v1.ogg"
		}
	},
	ItemsVeznanWrathInitialBurst = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr5_sfx_veznanwrath_initialburst_v1.ogg"
		}
	},
	ItemsVeznanWrathExplosion = {
		source_group = "SFX",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kr5_sfx_veznanwrath_flame_var1_v1.ogg",
			"kr5_sfx_veznanwrath_flame_var3_v1.ogg",
			"kr5_sfx_veznanwrath_flame_var4_v1.ogg"
		}
	},
	UpgradeLimitPushing = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_upgrade_limitPushing_trigger_v1.ogg"
		}
	},
	UpgradeDisplayOfTrueMightDarkArmy = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_upgrade_displayOfTrueMight_darkArmy_trigger_var1_v1.ogg"
		}
	},
	UpgradeDisplayOfTrueMightLinirea = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_upgrade_displayOfTrueMight_linirea_trigger_v1.ogg"
		}
	},
	UpgradeFavoriteCustomer = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_upgrade_favouriteCustomer_trigger_v1.ogg"
		}
	},
	UpgradeArcaneTeleporterIn = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_upgrade_arcaneTeleporter_trigger_IN_v1.ogg"
		}
	},
	UpgradeArcaneTeleporterOut = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_upgrade_arcaneTeleporter_trigger_OUT_v1.ogg"
		}
	},
	UpgradeArcaneTeleporterFull = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_upgrade_arcaneTeleporter_trigger_FullSeq_v1.ogg"
		}
	},
	UpgradeSealOfPunishmentHit = {
		ignore = 0.5,
		gain = 1,
		mode = "random",
		loop = false,
		source_group = "SFX",
		files = {
			"kra_sfx_upgrade_sealOfPunishment_trigger_var1_v1.ogg",
			"kra_sfx_upgrade_sealOfPunishment_trigger_var2_v1.ogg",
			"kra_sfx_upgrade_sealOfPunishment_trigger_var3_v1.ogg",
			"kra_sfx_upgrade_sealOfPunishment_trigger_var4_v1.ogg",
			"kra_sfx_upgrade_sealOfPunishment_trigger_var5_v1.ogg"
		}
	},
	kra_sfx_ui_mapDotsAppear_op2_v2 = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_ui_mapDotsAppear_op2_v2.ogg"
		}
	},
	kra_sfx_ui_stageFlagAppear = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kra_sfx_ui_stageFlagAppear_v1.ogg"
		}
	},
	kr4_flag_glow = {
		loop = false,
		gain = 0.2,
		source_group = "SFX",
		files = {
			"kr4_flag_glow.ogg"
		}
	},
	kr4_map_star = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr4_map_star.ogg"
		}
	},
	MeleeSword = {
		ignore = 0.45,
		mode = "sequence",
		gain = 0.2,
		source_group = "SWORDS",
		loop = false,
		files = {
			"Sound_SoldiersFighting-01.ogg",
			"Sound_SoldiersFighting-02.ogg",
			"Sound_SoldiersFighting-03.ogg",
			"Sound_SoldiersFighting-04.ogg",
			"Sound_SoldiersFighting-05.ogg"
		}
	},
	MusicMainMenu = {
		stream = true,
		gain = 1,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_mainMenu_v1.ogg"
		}
	},
	MusicMap = {
		stream = true,
		gain = 0.6,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_atlas_v1.ogg"
		}
	},
	MusicCredits = {
		stream = true,
		gain = 0.8,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_credits_v3.ogg"
		}
	},
	MusicBattlePrep_01 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_02 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_preparation2_v1.ogg"
		}
	},
	MusicBattlePrep_03 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_04 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_preparation2_v1.ogg"
		}
	},
	MusicBattlePrep_05 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_06 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_preparation2_v1.ogg"
		}
	},
	MusicBattlePrep_07 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_preparation1_vN.ogg"
		}
	},
	MusicBattlePrep_08 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_preparation2_v2.ogg"
		}
	},
	MusicBattlePrep_09 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_preparation1_vN.ogg"
		}
	},
	MusicBattlePrep_10 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_preparation2_v2.ogg"
		}
	},
	MusicBattlePrep_11 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_preparation1_vN.ogg"
		}
	},
	MusicBattlePrep_12 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_13 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_preparation2_v1.ogg"
		}
	},
	MusicBattlePrep_14 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_15 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_16 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_preparation3_v1.ogg"
		}
	},
	MusicBattlePrep_17 = {
		stream = true,
		gain = 0.5,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update1_bgmusic_preparation1_v3.ogg"
		}
	},
	MusicBattlePrep_18 = {
		stream = true,
		gain = 0.6,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update1_bgmusic_preparation1_v3.ogg"
		}
	},
	MusicBattlePrep_19 = {
		stream = true,
		gain = 0.6,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update1_bgmusic_preparation1_v3.ogg"
		}
	},
	MusicBattlePrep_20 = {
		stream = true,
		gain = 0.6,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update2_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_21 = {
		stream = true,
		gain = 0.5,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update2_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_22 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update2_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_23 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_24 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_preparation2_v2.ogg"
		}
	},
	MusicBattlePrep_25 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_26 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_preparation2_v2.ogg"
		}
	},
	MusicBattlePrep_27 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_28 = {
		stream = true,
		gain = 0.6,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update3_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_29 = {
		stream = true,
		gain = 0.5,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update3_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_30 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update3_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_31 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_32 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_preparation2_v1.ogg"
		}
	},
	MusicBattlePrep_33 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_34 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_35 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_preparation2_v1.ogg"
		}
	},
	MusicBattlePrep_81 = {
		stream = true,
		gain = 0.6,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_preparation1_v1.ogg"
		}
	},
	MusicBattlePrep_82 = {
		stream = true,
		gain = 0.5,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_preparation1_v1.ogg"
		}
	},
	MusicBattle_01 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_battle1_v1.ogg"
		}
	},
	MusicBattle_02 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_battle2_v1.ogg"
		}
	},
	MusicBattle_03 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_battle1_v1.ogg"
		}
	},
	MusicBattle_04 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_battle2_v1.ogg"
		}
	},
	MusicBattle_05 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_battle1_v1.ogg"
		}
	},
	MusicBattle_06 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_battle2_v1.ogg"
		}
	},
	MusicBattle_07 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_battle1_v1.ogg"
		}
	},
	MusicBattle_08 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_battle2_v2.ogg"
		}
	},
	MusicBattle_09 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_battle1_v1.ogg"
		}
	},
	MusicBattle_10 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_battle2_v2.ogg"
		}
	},
	MusicBattle_11 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_battle1_v1.ogg"
		}
	},
	MusicBattle_12 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_battle1_v1.ogg"
		}
	},
	MusicBattle_13 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_battle2_v1.ogg"
		}
	},
	MusicBattle_14 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_battle1_v1.ogg"
		}
	},
	MusicBattle_15 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_battle2_v1.ogg"
		}
	},
	MusicBattle_16 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_boss2_v1.ogg"
		}
	},
	MusicBattle_17 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update1_bgmusic_battle1_v2.ogg"
		}
	},
	MusicBattle_18 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update1_bgmusic_battle1_v2.ogg"
		}
	},
	MusicBattle_19 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update1_bgmusic_battle1_v2.ogg"
		}
	},
	MusicBattle_20 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update2_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_21 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update2_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_22 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update2_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_23 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_24 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_battle2_v1.ogg"
		}
	},
	MusicBattle_25 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_26 = {
		stream = true,
		gain = 0.3,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_battle2_v1.ogg"
		}
	},
	MusicBattle_27 = {
		stream = true,
		gain = 0.25,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_28 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update3_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_29 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update3_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_30 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update3_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_31 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_32 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_battle2_v1.ogg"
		}
	},
	MusicBattle_33 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_battle3_v1.ogg"
		}
	},
	MusicBattle_34 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_battle1_v1.ogg"
		}
	},
	MusicBattle_35 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_battle2_v1.ogg"
		}
	},
	MusicBattle_81 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_battle2_v1"
		}
	},
	MusicBattle_82 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_battle2_v1"
		}
	},
	MusicBossFight_6 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t1_boss_v2.ogg"
		}
	},
	MusicBossFight_11 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t2_boss_v1.ogg"
		}
	},
	MusicBossFight_15 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_boss1_v1.ogg"
		}
	},
	MusicBossFight_16 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_bgmusic_t3_boss2_v1.ogg"
		}
	},
	MusicBossFight_19 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update1_bgmusic_bossBattle_v2.ogg"
		}
	},
	MusicBossFight_22 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update2_bgmusic_bossBattle_v1.ogg"
		}
	},
	MusicBossFight_27 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc1_bgmusic_bossBattle_v1.ogg"
		}
	},
	MusicBossFight_30 = {
		stream = true,
		gain = 0.4,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_update3_bgmusic_bossBattle_v1.ogg"
		}
	},
	MusicBossFight_35 = {
		stream = true,
		gain = 0.2,
		loop = true,
		source_group = "MUSIC",
		files = {
			"kr5_dlc2_bgmusic_bossBattle_v1.ogg"
		}
	},
	MusicEndVictory = {
		source_group = "MUSIC",
		gain = 0.7,
		stream = true,
		files = {
			"kr5_bgmusic_t3_boss_victory.ogg"
		}
	},
	MusicSuspense = {
		source_group = "MUSIC",
		gain = 0.7,
		stream = true,
		files = {
			"MusicSuspense.ogg"
		}
	},
	DeathKnightTaunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"necromancer_deathknight_taunt_1.ogg",
			"necromancer_deathknight_taunt_2.ogg"
		}
	},
	NecromancerSummon = {
		loop = false,
		gain = 0.3,
		source_group = "BULLETS",
		files = {
			"mecromancer_summon.ogg"
		}
	},
	DeathSkeleton = {
		source_group = "DEATH",
		loop = false,
		files = {
			"Sound_EnemySkeletonBreak2.ogg"
		}
	},
	HeroDragonAttackHit = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"hero_dragon_fireball_explode.ogg"
		}
	},
	HeroDracolichAttack = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"halloween_bonedragon_attack.ogg"
		}
	},
	HeroDracolichBoneRain = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"halloween_bonedragon_bonerain.ogg"
		}
	},
	HeroDracolichDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Bonehart-Death01c_WET.ogg"
		}
	},
	HeroDracolichKamikaze = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"halloween_bonedragon_kamikaze2.ogg"
		}
	},
	HeroDracolichRespawn = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"halloween_bonedragon_respawn_simple.ogg"
		}
	},
	HeroDracolichSoulsPlague = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"halloween_bonedragon_soulsplague.ogg"
		}
	},
	HeroDracolichSpawnDog = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"halloween_bonedragon_spawn_congrowl.ogg"
		}
	},
	HeroDracolichTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Bonehart-01a_WET.ogg",
			"Bonehart-02b_WET.ogg",
			"Bonehart-03b_WET.ogg",
			"Bonehart-04c_WET.ogg"
		}
	},
	HeroDracolichTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroDracolichTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Bonehart-02b_WET.ogg"
		}
	},
	AxeSound = {
		source_group = "BULLETS",
		loop = false,
		files = {
			"Sound_BattleAxe.ogg"
		}
	},
	BarrackBarbarianTaunt = {
		source_group = "TAUNTS",
		gain = 0.6,
		mode = "sequence",
		loop = false,
		files = {
			"Barbarian_Ready.ogg",
			"Barbarian_Taunt1.ogg",
			"Barbarian_Taunt2.ogg",
			"Barbarian_Move.ogg"
		}
	},
	BarrackBarbarianDoubleAxesTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Barbarian_Move.ogg"
		}
	},
	BarrackBarbarianThrowingAxesTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Barbarian_Ready.ogg"
		}
	},
	BarrackBarbarianTwisterTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Barbarian_Taunt1.ogg"
		}
	},
	whirlwindattack = {
		loop = false,
		source_group = "SWORDS",
		files = {
			"kr4_barbarians_berseker_whirlwindattack.ogg"
		}
	},
	AssassinGold = {
		loop = false,
		gain = 0.6,
		source_group = "SPECIALS",
		files = {
			"assassin_gold.ogg"
		}
	},
	AssassinSneakAttack = {
		loop = false,
		gain = 0.3,
		source_group = "SPECIALS",
		files = {
			"assassin_sneakattack.ogg"
		}
	},
	AssassinTaunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"assassin_taunt_gold.ogg",
			"assassin_taunt_counter.ogg",
			"assassin_taunt_sneak.ogg",
			"assassin_taunt_ready.ogg"
		}
	},
	AssassinTauntCounter = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"assassin_taunt_counter.ogg"
		}
	},
	AssassinTauntGold = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"assassin_taunt_gold.ogg"
		}
	},
	AssassinTauntReady = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"assassin_taunt_ready.ogg"
		}
	},
	AssassinTauntSneak = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"assassin_taunt_sneak.ogg"
		}
	},
	TowerEntwoodClobber = {
		loop = false,
		gain = 0.8,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_tree_clobber_v2.ogg"
		}
	},
	ElvesRockEntwoodTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"PapaTree_Ready[2]-01d.ogg"
		}
	},
	TowerStoneDruidBoulderThrow = {
		loop = false,
		gain = 0.5,
		source_group = "BULLETS",
		files = {
			"kr3_sfx_stonedruid_boulderthrow-op2.ogg"
		}
	},
	RTWaterExplosion = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"Explosion_water.ogg"
		}
	},
	TowerEntwoodCocoThrow = {
		loop = false,
		gain = 0.5,
		source_group = "BULLETS",
		files = {
			"kr3_sfx_tree_cocothrow.ogg"
		}
	},
	TowerEntwoodCocoExplosion = {
		loop = false,
		gain = 0.8,
		source_group = "EXPLOSIONS",
		files = {
			"kr3_sfx_tree_cocoexplosion[explofuerte].ogg"
		}
	},
	TowerEntwoodFieryExplote = {
		loop = false,
		gain = 0.8,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_tree_fierynutexplotion.ogg"
		}
	},
	TowerEntwoodFieryThrow = {
		loop = false,
		gain = 0.8,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_tree_fierynutthrow.ogg"
		}
	},
	TowerEntwoodLeaves = {
		loop = false,
		gain = 0.1,
		source_group = "BULLETS",
		files = {
			"kr3_sfx_tree_leaves.ogg"
		}
	},
	ElvesRockEntwoodClobberingTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"PapaTree_Clobberin[2]-01e.ogg"
		}
	},
	ElvesRockEntwoodFieryNutsTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"PapaTree_Fiery[2]-01d.ogg"
		}
	},
	TowerForestKeeperCircleOfHealing = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_forestkeeper_circleofhealing-CONGAITA_HI.ogg"
		}
	},
	TowerForestKeeperNormalSpear = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kr3_sfx_forestkeeper_normalspear_v2-op1.ogg"
		}
	},
	TowerForestKeeperAncientSpear = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_forestkeeper_ancientoakspear_LOW_v1+3db.ogg"
		}
	},
	TowerForestKeeperEerieGarden = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_forestkeeper_eeriegarden_SINPOPS.ogg"
		}
	},
	ElvesBarrackForestKeeperTaunt = {
		source_group = "TAUNTS",
		gain = 0.6,
		mode = "sequence",
		loop = false,
		files = {
			"ForestProtector_Ready[2]-01c.ogg",
			"ForestProtector_Eerie[2]-01a.ogg",
			"ForestProtector_Circle[2]-01g.ogg",
			"ForestProtector_Ancient[2]-01c.ogg"
		}
	},
	ElvesBarrackForestKeeperCircleOfLifeTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"ForestProtector_Circle[2]-01g.ogg"
		}
	},
	RTBlacksurgeHoldTower = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"Blacksurge_holdtower.ogg"
		}
	},
	RTWaterDead = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"Waterenemy_death.ogg"
		}
	},
	SpecialMermaid = {
		source_group = "SFX",
		gain = 0.5,
		ignore = 0.5,
		loop = false,
		files = {
			"mermaid.ogg"
		}
	},
	ElvesCreepGolemAreaAttack = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kro_sfx_elemental_areaattack.ogg"
		}
	},
	BoltSorcererSound = {
		loop = false,
		gain = 0.68,
		source_group = "BULLETS",
		files = {
			"Sound_Sorcerer.ogg"
		}
	},
	DeathHuman = {
		loop = false,
		mode = "random",
		source_group = "DEATH",
		files = {
			"Sound_HumanDead1.ogg",
			"Sound_HumanDead2.ogg",
			"Sound_HumanDead3.ogg",
			"Sound_HumanDead4.ogg"
		}
	},
	ElvesCreepGolemDeath = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kro_sfx_elemental_death.ogg"
		}
	},
	ElvesCreepEvokerHeal = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kro_sfx_evoker_heal[sinshaker].ogg"
		}
	},
	ElvesScourgerDeath = {
		loop = false,
		gain = 0.3,
		source_group = "SFX",
		files = {
			"kre_sfx_scourger_death.ogg"
		}
	},
	ElvesCrystallizingGnoll = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kro_sfx_unstablecrystal_crystallize[op1].ogg"
		}
	},
	ElvesDeathGnolls = {
		loop = false,
		gain = 0.3,
		source_group = "SFX",
		files = {
			"kro_sfx_crystallizedgnoll_v2.ogg"
		}
	},
	ElvesCrystallizedGnoll = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kro_sfx_crystallizedgnoll_v2.ogg"
		}
	},
	ElvesCreepScreecherDeath = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kro_sfx_bitteringrancor_screecher-death.ogg"
		}
	},
	ElvesCreepScreecherScream = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kro_sfx_bitteringrancor_screecher-scream[op5].ogg"
		}
	},
	SaurianSniperBullet = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"KRF_sfx_suarian_sniper.ogg"
		}
	},
	DeathPuff = {
		loop = false,
		gain = 0.8,
		source_group = "DEATH",
		files = {
			"Sound_EnemyPuffDead.ogg"
		}
	},
	SaurianMyrmidonBite = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"myrmidon_bite.ogg"
		}
	},
	SaurianBlazefangDeath = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"blazefang_death.ogg"
		}
	},
	SaurianBlazefangAttack = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"blazefang_attack.ogg"
		}
	},
	SaurianNightscaleInvisible = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"nightscale_invisibility.ogg"
		}
	},
	SaurianDarterTeleporth = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"darter_teleout.ogg"
		}
	},
	SaurianBruteAttack = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"saurian_brute_attack.ogg"
		}
	},
	DeathBig = {
		source_group = "DEATH",
		loop = false,
		files = {
			"Sound_EnemyBigDead.ogg"
		}
	},
	SaurianSavantOpenPortal = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"savant_open_portal.ogg"
		}
	},
	SaurianSavantPortalLoop = {
		loop = true,
		gain = 0.3,
		source_group = "GUI",
		files = {
			"savant_portal_loop.ogg"
		}
	},
	SaurianSavantTeleporth = {
		loop = false,
		gain = 0.3,
		source_group = "SFX",
		files = {
			"savant_telein.ogg"
		}
	},
	SaurianSavantAttack = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"savant_attack.ogg"
		}
	},
	SaurianKingBossDeath = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"KRF_sfx_saurianboss_muerte.ogg"
		}
	},
	SaurianKingBossHammer = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"KRF_sfx_saurianboss_martillo_1t.ogg"
		}
	},
	SaurianKingBossQuake = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"KRF_sfx_saurianboss_temblor.ogg"
		}
	},
	SaurianKingBossTongue = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"KRF_sfx_saurianboss_op1.ogg"
		}
	},
	ElvesHeroGyroAttack = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kro_sfx_wilbur_attack[concasquillos].ogg"
		}
	},
	ElvesHeroGyroBombsMarch = {
		loop = true,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kro_sfx_wilbur_bombsmarch[op1].ogg"
		}
	},
	ElvesHeroGyroBoombBox = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kro_sfx_wilbur_boombox.ogg"
		}
	},
	ElvesHeroGyroBoombBoxTouchdown = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kro_sfx_wilbur_boombox_box.ogg"
		}
	},
	ElvesHeroGyroDeath = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"Gyro_death-01d.ogg"
		}
	},
	ElvesHeroGyroDronesAttack = {
		loop = false,
		gain = 0.3,
		source_group = "SFX",
		files = {
			"kro_sfx_wilbur_dronesattack[metralla]_cut.ogg"
		}
	},
	ElvesHeroGyroDronesSpawn = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kro_sfx_wilbur_calldrones.ogg"
		}
	},
	ElvesHeroGyroSmokeLaunch = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kro_sfx_wilbur_smokespit.ogg"
		}
	},
	ElvesHeroGyroTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Gyro_confirm-01c.ogg",
			"Gyro_confirm-02c.ogg",
			"Gyro_confirm-03c.ogg",
			"Gyro_confirm-04b.ogg"
		}
	},
	ElvesHeroGyroTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	ElvesHeroGyroTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Gyro_confirm-01c.ogg"
		}
	},
	RocketLaunchSound = {
		loop = false,
		gain = 0.8,
		source_group = "BULLETS",
		files = {
			"Sound_RocketLaunt.ogg"
		}
	},
	DwarvesMechadwarfDeath = {
		loop = false,
		gain = 0.3,
		source_group = "DEATH",
		files = {
			"kr4_dwarves_mechadwarf_death.ogg"
		}
	},
	DwarvesSmokebeardRepair = {
		loop = false,
		gain = 0.5,
		source_group = "BULLETS",
		files = {
			"kr4_dwarves_smokebeard_repair.ogg"
		}
	},
	TeslaAttack = {
		loop = false,
		gain = 0.6,
		source_group = "BULLETS",
		files = {
			"Sound_Tesla_attack_1.ogg",
			"Sound_Tesla_attack_2.ogg"
		}
	},
	HWFrankensteinTaunt = {
		loop = false,
		gain = 1,
		mode = "random",
		source_group = "TAUNTS",
		files = {
			"FrankyTower-03c.ogg",
			"FrankyTower-04a.ogg"
		}
	},
	HWFrankensteinUpgradeFrankenstein = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"FrankyTower-02f.ogg"
		}
	},
	HWFrankensteinUpgradeLightning = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"FrankyTower-01d.ogg"
		}
	},
	HWFrankensteinChargeLightning = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"halloween_tesla_charge.ogg"
		}
	},
	EngineerTeslaChargedBoltTaunt = {
		source_group = "TAUNTS",
		gain = 0.6,
		mode = "random",
		loop = false,
		files = {
			"Tesla_Taunt2a.ogg",
			"Tesla_Taunt2b.ogg",
			"Tesla_Taunt2c.ogg"
		}
	},
	EngineerTeslaOverchargeTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Tesla_Taunt1.ogg"
		}
	},
	EngineerTeslaTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Tesla_Ready.ogg"
		}
	},
	HeroDragonAttackThrow = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"hero_dragon_spit.ogg"
		}
	},
	HeroDragonBorn = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"hero_dragon_birth.ogg"
		}
	},
	HeroDragonDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"hero_dragon_death.ogg"
		}
	},
	HeroDragonFlame = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"hero_dragon_flamethrower.ogg"
		}
	},
	HeroDragonNapalm = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"hero_dragon_napalm.ogg"
		}
	},
	HeroDragonSmoke = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"hero_dragon_smoke.ogg"
		}
	},
	HeroDragonTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"dragonHero_confirm1.ogg",
			"dragonHero_confirm2.ogg",
			"dragonHero_confirm3.ogg",
			"dragonHero_confirm4.ogg"
		}
	},
	HeroDragonTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroDragonTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"dragonHero_confirm4.ogg"
		}
	},
	BoltReleaseSound = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"kr4_bolt_release.ogg"
		}
	},
	HeroDianyunSon = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr4_hero_dianyun_son.ogg"
		}
	},
	HeroDianyunTauntDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_hero_dianyun_taunt_death.ogg"
		}
	},
	HeroDianyunTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_hero_dianyun_taunt_1.ogg"
		}
	},
	HeroDianyunTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr4_hero_dianyun_taunt_1.ogg",
			"kr4_hero_dianyun_taunt_2.ogg",
			"kr4_hero_dianyun_taunt_3.ogg",
			"kr4_hero_dianyun_taunt_4.ogg"
		}
	},
	WarmongerMageAttack = {
		loop = false,
		gain = 0.6,
		source_group = "BULLETS",
		files = {
			"kr4_warmonger_mage_attack.ogg"
		}
	},
	TowerDruidHengeBearAttack = {
		loop = false,
		gain = 0.3,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_druidhenge_bearattack_v4-op1.ogg"
		}
	},
	TowerDruidHengeBearDeath = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_druidhenge_beardeath_v3_op1-condesplome.ogg"
		}
	},
	TowerDruidHengeBearSummon = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_druidhenge_bearsummon_v3-op2.ogg"
		}
	},
	TowerDruidHengeRockSummon = {
		loop = false,
		gain = 0.5,
		source_group = "BULLETS",
		files = {
			"kr3_sfx_druidhenge_bouldersummon.ogg"
		}
	},
	TowerStoneDruidBoulderExplote = {
		loop = false,
		gain = 0.5,
		source_group = "EXPLOSIONS",
		files = {
			"kr3_sfx_stonedruid_boulderexplosion.ogg"
		}
	},
	TowerStoneDruidBoulderSummon = {
		loop = false,
		gain = 0.3,
		source_group = "BULLETS",
		files = {
			"kr3_sfx_stonedruid_bouldersummon.ogg"
		}
	},
	ElvesRockTaunt = {
		ignore = 1.5,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"StoneDruid_Taunt-01b.ogg",
			"StoneDruid_Taunt-02b.ogg",
			"StoneDruid_Taunt-03a.ogg"
		}
	},
	TowerDruidHengeRockThrow = {
		loop = false,
		gain = 0.5,
		source_group = "BULLETS",
		files = {
			"kr3_sfx_druidhenge_rockthrow_v2-op2-medio.ogg"
		}
	},
	ElvesRockHengeTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"DruidHenge_Ready-01a.ogg"
		}
	},
	ElvesRockHengeNatureFriendTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"DruidHenge_Sylvan[2]-01b.ogg"
		}
	},
	ElvesRockHengeSylvanCurseTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"DruidHenge_Sylvan[2]-01b.ogg"
		}
	},
	SoldierDruidBearRallyChange = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Viking_Transform.ogg"
		}
	},
	TowerDruidHengeSylvanCurseCast = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_druidhenge_sylvancursecast_v4-op2.ogg"
		}
	},
	ElfTaunt = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"Elf_Taun1.ogg",
			"Elf_Taun2.ogg"
		}
	},
	ElvesBarrackTaunt = {
		ignore = 1.5,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Barrack_Taunt[2]-01c.ogg",
			"Barrack_Taunt[2]-02c.ogg",
			"Barrack_Taunt[2]-03c.ogg",
			"Barrack_Taunt[2]-04e.ogg"
		}
	},
	ElvesBarrackBladesingerTaunt = {
		source_group = "TAUNTS",
		gain = 0.6,
		mode = "sequence",
		loop = false,
		files = {
			"Bladesinger_Ready[2]-01b.ogg",
			"Bladesinger_PerfectParry[2]-01d.ogg",
			"Bladesinger_BladeDance[2]-01a.ogg",
			"Bladesinger_SwirlingEdge[2]-01a.ogg"
		}
	},
	TowerBladesingerPerfectParry = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_bladesinger_perfectparry_v2-op2-faded.ogg"
		}
	},
	TowerBladesingerBladedance = {
		loop = false,
		gain = 0.3,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_bladesinger_bladedance_v2-op2.ogg"
		}
	},
	ElvesBarrackBladesingerPerfectParryTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Bladesinger_PerfectParry[2]-01d.ogg"
		}
	},
	ElvesBarrackBladesingerBladeDanceTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Bladesinger_BladeDance[2]-01a.ogg"
		}
	},
	ElvesBarrackBladesingerSwirlingEdge = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Bladesinger_SwirlingEdge[2]-01a.ogg"
		}
	},
	ElvesDrowTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "SPECIALS",
		files = {
			"Drow_01c.ogg",
			"Drow_02c.ogg",
			"Drow_03b.ogg"
		}
	},
	ElvesSpecialDrowLifeDrain = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"Drow_01c.ogg"
		}
	},
	ElvesSpecialDrowDaggers = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"Drow_02c.ogg"
		}
	},
	ElvesSpecialDrowBlademail = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"Drow_03b.ogg"
		}
	},
	kr4_elves_barrack_taunt = {
		source_group = "TAUNTS",
		mode = "sequence",
		loop = false,
		ignore = 2,
		files = {
			"kr4_elves_barrack_taunt_1.ogg",
			"kr4_elves_barrack_taunt_2.ogg",
			"kr4_elves_barrack_taunt_3.ogg",
			"kr4_elves_barrack_taunt_4.ogg"
		}
	},
	elves_barrack_backstab_upgrade = {
		source_group = "SPECIALS",
		loop = false,
		files = {
			"kr4_elves_barrack_backstab_upg.ogg"
		}
	},
	elves_barrack_multishoot_upgrade = {
		source_group = "SPECIALS",
		loop = false,
		files = {
			"kr4_elves_barrack_multishoot_upg.ogg"
		}
	},
	elves_barrack_afterlife_upgrade = {
		source_group = "SPECIALS",
		loop = false,
		files = {
			"kr4_elves_barrack_afterlife_upg.ogg"
		}
	},
	elves_arrow_release_sound = {
		loop = false,
		mode = "sequence",
		source_group = "SFX",
		files = {
			"kr4_elves_eliteharassers_arrowstorm_single1.ogg",
			"kr4_elves_eliteharassers_arrowstorm_single2.ogg",
			"kr4_elves_eliteharassers_arrowstorm_single3.ogg"
		}
	},
	elves_eliteharassers_lastbreath1 = {
		source_group = "SFX",
		loop = false,
		files = {
			"kr4_elves_eliteharassers_lastbreath1.ogg"
		}
	},
	elves_eliteharassers_lastbreath2 = {
		source_group = "SFX",
		loop = false,
		files = {
			"kr4_elves_eliteharassers_lastbreath2.ogg"
		}
	},
	RTBluegaleStormAmbience = {
		source_group = "SFX",
		gain = 1,
		ignore = 2.33,
		loop = false,
		files = {
			"Bluegale_storm_ambience.ogg"
		}
	},
	RTBluegaleStormSummon = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"Bluegale_storm_summon.ogg"
		}
	},
	EmberLordsMageAttack = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"kr4_ember_lords_mage_attack.ogg"
		}
	},
	HeroTraminLand = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr4_hero_tramin_land.ogg"
		}
	},
	HeroBeresadSpawnImpact = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr4_hero_beresad_spawn_impact.ogg"
		}
	},
	TenShiTaunt = {
		loop = false,
		gain = 0.7,
		mode = "random",
		source_group = "TAUNTS",
		ignore = 1,
		files = {
			"TenShi_02c.ogg",
			"TenShi_01c_and_a.ogg",
			"TenShi_01a_mmh.ogg",
			"TenShi_01a_mmh.ogg",
			"TenShi_01a_mmh.ogg"
		}
	},
	TenShiTauntBuffed = {
		loop = false,
		gain = 0.7,
		mode = "random",
		source_group = "TAUNTS",
		ignore = 1,
		files = {
			"TenShi_buffed_01c.ogg",
			"TenShi_buffed_02b.ogg",
			"TenShi_buffed_01a_laugh_only.ogg"
		}
	},
	TenShiTauntIntro = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	TenShiTauntSelect = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"TenShi_02c.ogg"
		}
	},
	TenShiRespawn = {
		loop = false,
		gain = 0.7,
		source_group = "TAUNTS",
		files = {
			"TenShi_respawn_01d.ogg"
		}
	},
	TenShiTransformToBuffed = {
		loop = false,
		gain = 1,
		mode = "sequence",
		source_group = "TAUNTS",
		files = {
			"TenShi_transformation_01d.ogg",
			"TenShi_transformation_02c.ogg"
		}
	},
	TenShiTransformToNormal = {
		loop = false,
		gain = 1,
		mode = "sequence",
		source_group = "TAUNTS",
		files = {
			"TenShi_01a_mmh.ogg"
		}
	},
	TenShiAttack1 = {
		loop = false,
		gain = 0.6,
		mode = "random",
		source_group = "BULLETS",
		files = {
			"kr1_sfx_tenshi_basicAttack1_var1_v1.ogg",
			"kr1_sfx_tenshi_basicAttack1_var2_v1.ogg",
			"kr1_sfx_tenshi_basicAttack1_var3_v1.ogg"
		}
	},
	TenShiAttack2 = {
		loop = false,
		gain = 0.6,
		source_group = "BULLETS",
		files = {
			"kr1_sfx_tenshi_attack2_v1.ogg"
		}
	},
	TenShiRainOfFireStart = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_rainOfFire_start_mix.ogg"
		}
	},
	TenShiRainOfFireEnd = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_rainOfFire_loop-End_v1_10db.ogg"
		}
	},
	TenShiBuffedSpinAttack = {
		loop = false,
		gain = 1,
		mode = "random",
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_buffedSpinAttack_2hits_v1.ogg",
			"kr1_sfx_tenshi_buffedSpinAttack_3hits_v1.ogg"
		}
	},
	TenShiBuffedBombAttack = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_buffedBombAttack_3hits_v1_op2.ogg"
		}
	},
	TenShiBuffedBombAttackLong = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_buffedBombAttack_6hits_v1_op2.ogg"
		}
	},
	TenShiTransformToBuffedSfx = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_transformToBuffed_op1_v1.ogg"
		}
	},
	TenShiTransformToNormalSfx = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_transformToNormal_v1.ogg"
		}
	},
	TenShiDeathSfx = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_death_v1.ogg"
		}
	},
	TenShiTeleportSfx = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr1_sfx_tenshi_teleport_v1_15db.ogg"
		}
	},
	FireballHit = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"Sound_FireballHit.ogg"
		}
	},
	FireballRelease = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"Sound_FireballUnleash.ogg"
		}
	},
	DarkArmyBarrackBrutalStrike = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kr4_dark_army_barrack_brutal_strike.ogg"
		}
	},
	ElvesMageTaunt = {
		ignore = 1.5,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Mage_Taunt-01e.ogg",
			"Mage_Taunt-03d.ogg",
			"Mage_Taunt[2]-02a.ogg"
		}
	},
	ElvesMageWildMagusDoomTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"WildMagus_Doom[2]-01b.ogg"
		}
	},
	ElvesMageWildMagusSilenceTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"WildMagus_Silence-01c.ogg"
		}
	},
	TowerWizardBasicBolt = {
		loop = false,
		gain = 0.1,
		source_group = "BULLETS",
		files = {
			"kr3_sfx_basicwizard_doublebolt-op1.ogg"
		}
	},
	TowerWildMagusBoltcast = {
		source_group = "BULLETS",
		gain = 0.3,
		ignore = 0.3,
		loop = false,
		files = {
			"kr3_sfx_wildmagus_boltcast_v2-op1.ogg"
		}
	},
	TowerWildMagusDisruptionCast = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_wildmagus_disruptioncast_v2.ogg"
		}
	},
	TowerWildMagusDoomCast = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_wildmagus_doomcast_v2.ogg"
		}
	},
	TowerWildMagusDoomExplote = {
		loop = false,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_wildmagus_doomexplotion_v3-op1.ogg"
		}
	},
	TowerWildMagusDoomLoop = {
		loop = true,
		gain = 0.5,
		source_group = "SPECIALS",
		files = {
			"kr3_sfx_wildmagus_doomloop_v2-op1.ogg"
		}
	},
	ElvesMageWildMagusTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"WildMagus_Ready-01a.ogg"
		}
	},
	TemplarArterial = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"templar_arterialStrike.ogg"
		}
	},
	TemplarHolygrail = {
		loop = false,
		gain = 0.8,
		source_group = "SPECIALS",
		files = {
			"templar_holyGrail.ogg"
		}
	},
	TemplarTaunt = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"templar_taunt_ready.ogg",
			"templar_taunt_1.ogg",
			"templar_taunt_2.ogg",
			"templar_taunt_3.ogg"
		}
	},
	TemplarTauntReady = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"templar_taunt_3.ogg"
		}
	},
	TemplarTauntTauntOne = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"templar_taunt_ready.ogg"
		}
	},
	TemplarTauntTauntTwo = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"templar_taunt_1.ogg"
		}
	},
	TemplarTauntThree = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"templar_taunt_2.ogg"
		}
	},
	HeroRiflemanBrea = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Dwarf_brea_shot2.ogg"
		}
	},
	HeroRiflemanBreaHit = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Dwarf_brea_shot_hit.ogg"
		}
	},
	HeroRiflemanDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Dwarf-Rifleman-Death_c.ogg"
		}
	},
	HeroRiflemanMine = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Dwarf_mine.ogg"
		}
	},
	HeroRiflemanTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Dwarf-Rifleman-04c.ogg",
			"Dwarf-Rifleman-02c.ogg",
			"Dwarf-Rifleman-03c.ogg",
			"Dwarf-Rifleman-01a.ogg"
		}
	},
	HeroRiflemanTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroRiflemanTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Dwarf-Rifleman-01a.ogg"
		}
	},
	ShotgunSound = {
		source_group = "BULLETS",
		loop = false,
		files = {
			"Sound_Shootgun.ogg"
		}
	},
	HeroPaladinDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Holy-Paladin-Death_b.ogg"
		}
	},
	HeroPaladinDeflect = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Paladin_deflect.ogg"
		}
	},
	HeroPaladinTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Holy-Paladin-04a.ogg",
			"Holy-Paladin-02c.ogg",
			"Holy-Paladin-03b.ogg",
			"Holy-Paladin-01c.ogg"
		}
	},
	HeroPaladinTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroPaladinTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Holy-Paladin-01c.ogg"
		}
	},
	HeroPaladinValor = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Paladin_shield_buff.ogg"
		}
	},
	HeroFrostDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Frost-Mage-Death_01c.ogg"
		}
	},
	HeroFrostGroundFreeze = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Elora_GroundFreeze.ogg"
		}
	},
	HeroFrostIceRainBreak = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Elora_IceShardBreak.ogg"
		}
	},
	HeroFrostIceRainDrop = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Elora_IceShard.ogg"
		}
	},
	HeroFrostIceRainSummon = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Elora_IceShardSummon.ogg"
		}
	},
	HeroFrostTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Frost-Mage-04a.ogg",
			"Frost-Mage-03d.ogg",
			"Frost-Mage-02c.ogg",
			"Frost-Mage-01a.ogg"
		}
	},
	HeroFrostTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroFrostTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Frost-Mage-01a.ogg"
		}
	},
	HeroRainOfFireArea = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Cinder_special_area.ogg"
		}
	},
	HeroRainOfFireDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Elemental-Death_c.ogg"
		}
	},
	HeroRainOfFireFireball1 = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Cinder_special_fireball_1_start.ogg"
		}
	},
	HeroRainOfFireFireball2 = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Cinder_special_fireball_2_end.ogg"
		}
	},
	HeroRainOfFireTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Elemental-01c.ogg",
			"Elemental-02c.ogg",
			"Elemental-03b.ogg",
			"Elemental-04c.ogg"
		}
	},
	HeroRainOfFireTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroRainOfFireTauntSelect = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Elemental-01c.ogg"
		}
	},
	HeroReinforcementHit = {
		loop = false,
		gain = 1,
		source_group = "BULLETS",
		files = {
			"Motumbo_hit.ogg"
		}
	},
	DwarfArcherTaunt1 = {
		source_group = "TAUNTS",
		gain = 1,
		loop = false,
		files = {
			"dwarfArcher_taunt_1.ogg"
		}
	},
	DwarfArcherTaunt2 = {
		source_group = "TAUNTS",
		gain = 1,
		loop = false,
		files = {
			"dwarfArcher_taunt_2.ogg"
		}
	},
	DwarfTaunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"dwarf_taunt_1.ogg",
			"dwarf_taunt_2.ogg",
			"dwarfBarracks_taunt_1.ogg"
		}
	},
	DwarfHeroTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"dwarfHero_taunt_confirm_1.ogg",
			"dwarfHero_taunt_confirm_2.ogg",
			"dwarfHero_taunt_confirm_3.ogg"
		}
	},
	DwarfHeroTauntDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"dwarfHero_taunt_death.ogg"
		}
	},
	DwarfHeroTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	BarrackPaladinHealingTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Paladin_Ready.ogg"
		}
	},
	BarrackPaladinHolyStrikeTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Paladin_Taunt1.ogg"
		}
	},
	BarrackPaladinShieldTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Paladin_Taunt2.ogg"
		}
	},
	BarrackPaladinTaunt = {
		source_group = "TAUNTS",
		gain = 0.6,
		mode = "sequence",
		loop = false,
		files = {
			"Paladin_Ready.ogg",
			"Paladin_Taunt1.ogg",
			"Paladin_Taunt2.ogg",
			"Paladin_Move.ogg"
		}
	},
	HealingSound = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"Sound_PaladinHeal.ogg"
		}
	},
	ArcherTaunt = {
		ignore = 1.5,
		mode = "sequence",
		gain = 0.6,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Archer_Ready.ogg",
			"Archer_Taunt1.ogg",
			"Archer_Taunt2.ogg"
		}
	},
	TotemSpirits = {
		loop = false,
		gain = 0.8,
		source_group = "SPECIALS",
		files = {
			"axlethrower_totem_spirits.ogg"
		}
	},
	TotemTaunt = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"axlethrower_taunt_ready.ogg",
			"axlethrower_taunt_totem1.ogg",
			"axlethrower_taunt_totem2.ogg"
		}
	},
	TotemTauntReady = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"axlethrower_taunt_ready.ogg"
		}
	},
	TotemTauntTotemOne = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"axlethrower_taunt_totem1.ogg"
		}
	},
	TotemTauntTotemTwo = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"axlethrower_taunt_totem2.ogg"
		}
	},
	TotemVanish = {
		loop = false,
		gain = 0.8,
		source_group = "SPECIALS",
		files = {
			"axlethrower_totem_vanish.ogg"
		}
	},
	TotemWeakness = {
		loop = false,
		gain = 0.8,
		source_group = "SPECIALS",
		files = {
			"axlethrower_totem_weakness.ogg"
		}
	},
	CrossbowEagle = {
		loop = false,
		gain = 0.3,
		source_group = "SPECIALS",
		files = {
			"crossbow_eagle.ogg"
		}
	},
	CrossbowTaunt = {
		source_group = "TAUNTS",
		gain = 0.8,
		mode = "sequence",
		loop = false,
		files = {
			"crossbow_taunt_ready.ogg",
			"crossbow_taunt_eagle.ogg",
			"crossbow_taunt_multishot.ogg"
		}
	},
	CrossbowTauntEagle = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"crossbow_taunt_eagle.ogg"
		}
	},
	CrossbowTauntMultishoot = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"crossbow_taunt_multishot.ogg"
		}
	},
	CrossbowTauntReady = {
		loop = false,
		gain = 0.8,
		source_group = "TAUNTS",
		files = {
			"crossbow_taunt_ready.ogg"
		}
	},
	ArcherRangerPoisonTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Ranger_Taunt1.ogg"
		}
	},
	ShrapnelSound = {
		source_group = "BULLETS",
		ignore = 0.1,
		loop = false,
		files = {
			"Sound_Shrapnel.ogg"
		}
	},
	SniperSound = {
		source_group = "BULLETS",
		loop = false,
		files = {
			"Sound_Sniper.ogg"
		}
	},
	ArcherMusketeerShrapnelTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Muskateer_Event1.ogg"
		}
	},
	ArcherMusketeerSniperTaunt = {
		loop = false,
		gain = 0.6,
		source_group = "TAUNTS",
		files = {
			"Muskateer_Snipe.ogg"
		}
	},
	ArcherMusketeerTaunt = {
		source_group = "TAUNTS",
		gain = 0.6,
		mode = "sequence",
		loop = false,
		files = {
			"Muskateer_Ready.ogg",
			"Muskateer_Event1.ogg",
			"Muskateer_Event2.ogg"
		}
	},
	fallen_ones_spirit_mausoleum_build_taunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "random",
		loop = false,
		files = {
			"kr4_fallen_ones_spirit_mausoleum_taunt_1.ogg",
			"kr4_fallen_ones_spirit_mausoleum_taunt_2.ogg",
			"kr4_fallen_ones_spirit_mausoleum_taunt_3.ogg",
			"kr4_fallen_ones_spirit_mausoleum_taunt_4.ogg"
		}
	},
	fallen_ones_spirit_mausoleum_communion_upgrade = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_fallen_ones_spirit_mausoleum_communion_upg.ogg"
		}
	},
	fallen_ones_spirit_mausoleum_possesion_upgrade = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_fallen_ones_spirit_mausoleum_possesion_upg.ogg"
		}
	},
	fallen_ones_spirit_mausoleum_gargoyles_upgrade = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_fallen_ones_spirit_mausoleum_gargoyles_upg.ogg"
		}
	},
	fallen_ones_spirit_mausoleum_attack_preload = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kr4_fallen_ones_spirit_mausoleum_attack_preload.ogg"
		}
	},
	fallen_ones_spirit_mausoleum_attack = {
		loop = false,
		gain = 0.5,
		source_group = "BULLETS",
		files = {
			"kr4_fallen_ones_spirit_mausoleum_attack.ogg"
		}
	},
	fallen_ones_spirit_mausoleum_possession_cast = {
		loop = false,
		gain = 0.5,
		source_group = "BULLETS",
		files = {
			"kr4_fallen_ones_spirit_mausoleum_possession_cast.ogg"
		}
	},
	fallen_ones_spirit_mausoleum_possession_hit = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kr4_fallen_ones_spirit_mausoleum_possession_hit.ogg"
		}
	},
	open_door_sound = {
		loop = false,
		gain = 1,
		source_group = "GUI",
		files = {
			"kr4_tower_open_door.ogg"
		}
	},
	warmonger_barrack_build_taunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kr4_warmonger_barrack_taunt_1.ogg",
			"kr4_warmonger_barrack_taunt_2.ogg",
			"kr4_warmonger_barrack_taunt_3.ogg"
		}
	},
	warmonger_barrack_extra_armor_upgrade = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_warmonger_barrack_battlewits_upg.ogg"
		}
	},
	warmonger_barrack_regeneration_upgrade = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_warmonger_barrack_seal_of_blood_upg.ogg"
		}
	},
	warmonger_barrack_unit_swap_upgrade = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_warmonger_barrack_promotion_upg.ogg"
		}
	},
	warmonger_barrack_move_taunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kr4_warmonger_barrack_battlewits_upg.ogg",
			"kr4_warmonger_barrack_seal_of_blood_upg.ogg",
			"kr4_warmonger_barrack_taunt_4.ogg"
		}
	},
	warmonger_barrack_build_taunt_4 = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_warmonger_barrack_taunt_4.ogg"
		}
	},
	orcs_death_sound = {
		loop = false,
		gain = 0.35,
		source_group = "SFX",
		files = {
			"kr4_orcs_death.ogg"
		}
	},
	legionnaire_taunt_1 = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"legionnaire_taunt_1.ogg"
		}
	},
	legionnaire_taunt_2 = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"legionnaire_taunt_2.ogg"
		}
	},
	legionnaire_move_taunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"legionnaire_taunt_1.ogg",
			"legionnaire_taunt_2.ogg"
		}
	},
	kr4_enemies_sandstorm_elephant_death = {
		loop = false,
		gain = 0.5,
		source_group = "SFX",
		files = {
			"kr4_sfx_elephant_death_v1.ogg"
		}
	},
	kr4_enemies_sandstorm_elephant_drums = {
		loop = true,
		gain = 0.9,
		source_group = "SFX",
		files = {
			"kr4_sfx_elephant_buff_v2_LOOP_withTail.ogg"
		}
	},
	kr4_enemies_sandstorm_elephant_ambient_1 = {
		loop = false,
		gain = 8,
		source_group = "SFX",
		files = {
			"kr4_sfx_elephant_ambient_var1.ogg"
		}
	},
	sandstorm_elephant_ambient = {
		source_group = "SFX",
		gain = 8,
		mode = "random",
		loop = false,
		files = {
			"kr4_sfx_elephant_ambient_var1.ogg",
			"kr4_sfx_elephant_ambient_var2.ogg"
		}
	},
	HeroSamuraiDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Oni-Death01a.ogg"
		}
	},
	HeroSamuraiDeathStrike = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"inferno_oni_instakill.ogg"
		}
	},
	HeroSamuraiTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Oni-04a.ogg",
			"Oni-03c.ogg",
			"Oni-02c.ogg",
			"Oni-01c.ogg"
		}
	},
	HeroSamuraiTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	HeroSamuraiTorment = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"inferno_oni_groundSwords.ogg"
		}
	},
	PirateTowerTaunt1 = {
		source_group = "TAUNTS",
		gain = 1,
		loop = false,
		files = {
			"Pirate_Tower_01a.ogg"
		}
	},
	PirateTowerTaunt2 = {
		source_group = "TAUNTS",
		gain = 1,
		loop = false,
		files = {
			"Pirate_Tower_02b.ogg"
		}
	},
	AmazonTaunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"amazon_taunt_1.ogg",
			"amazon_taunt_2.ogg"
		}
	},
	SpecialCarnivorePlant = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"carnivore_plant.ogg"
		}
	},
	krv_sfx_bucaneer_attack = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"krv_sfx_bucaneer_attack.ogg"
		}
	},
	krv_sfx_bucaneer_explotion = {
		source_group = "SFX",
		gain = 0.7,
		ignore = 1,
		loop = false,
		files = {
			"krv_sfx_bucaneer_explotion.ogg"
		}
	},
	kr4_enemies_pirates_corsair_heal = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"jw_fx_pirates_corsair_heal_v1.ogg"
		}
	},
	kr4_enemies_pirates_boatswain_melee = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"jw_sfx_pirates_boatswain_melee_v1.ogg"
		}
	},
	PiratesTaunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"pirate_taunt_1.ogg",
			"pirate_taunt_2.ogg",
			"pirate_taunt_3.ogg"
		}
	},
	PirateBigTaunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"Pirate_Big_01c.ogg",
			"Pirate_Big_02c.ogg"
		}
	},
	dwarves_sulfur_alchemist_death = {
		loop = false,
		gain = 1,
		source_group = "DEATH",
		files = {
			"kr4_dwarves_sulfur_alchemist_death.ogg"
		}
	},
	common_enemies_dead = {
		loop = false,
		gain = 0.7,
		source_group = "DEATH",
		files = {
			"kr4_enemies_common_dead.ogg"
		}
	},
	ElvesGnomeDeathTaunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"kro_sfx_gnome_death[op1].ogg",
			"kro_sfx_gnome_death[op4].ogg",
			"kro_sfx_gnome_death[op7].ogg"
		}
	},
	ElvesGnomeDesintegrate = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_gnome_desintegrate_v2[comic].ogg"
		}
	},
	ElvesGnomeNew = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"Gnome_02a.ogg"
		}
	},
	ElvesGnomePoison = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_gnome_poison_v2[confrasco].ogg"
		}
	},
	ElvesGnomePolymorf = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_gnome_polymorf[conchimes].ogg"
		}
	},
	ElvesGnomePower = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"Gnome_01d.ogg"
		}
	},
	ElvesGnomeSteal = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_gnome_polymorf[conchimes].ogg"
		}
	},
	ElvesGnomeTeleport = {
		loop = false,
		gain = 0.2,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_veznan_teleport_v1.ogg"
		}
	},
	VenomPlantDischarge = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_poisonplant_discharge[conacido]_B.ogg"
		}
	},
	VenomPlantReady = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_poisonplant_ready_v2B.ogg"
		}
	},
	ElvesEwokAttack = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"Awok_02c.ogg"
		}
	},
	ElvesPlantMissile = {
		loop = false,
		gain = 0.3,
		source_group = "SFX",
		files = {
			"kre_sfx_plant_magicmissile.ogg"
		}
	},
	ElvesPlantReady = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kre_sfx_plant_ready_conchime.ogg"
		}
	},
	ElvesFaeryDragonAttack = {
		loop = false,
		gain = 0.2,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_faerydragon_sfx_attack[op2][soloattack]_B.ogg"
		}
	},
	ElvesFaeryDragonAttackCristalization = {
		loop = false,
		gain = 0.2,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_faerydragon_attack[solocristalizacion].ogg"
		}
	},
	ElvesFaeryDragonDragonBuy = {
		loop = false,
		gain = 0.2,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_faerydragon_buydragon[op1].ogg"
		}
	},
	ElvesFaeryDragonExtraAbility = {
		loop = false,
		gain = 0.2,
		source_group = "SPECIALS",
		files = {
			"kro_sfx_faerydragon_extraability[solochimes].ogg"
		}
	},
	GenieTaunt = {
		source_group = "TAUNTS",
		gain = 1,
		mode = "sequence",
		loop = false,
		files = {
			"genie_taunt_1.ogg",
			"genie_taunt_2.ogg"
		}
	},
	ElvesHeroEridanDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Eridan_Death-01a.ogg"
		}
	},
	ElvesHeroEridanDoubleStrike = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_eridan_doublestrike_v2[mid].ogg"
		}
	},
	ElvesHeroEridanNimbleFencing = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_eridan_nimblefencing.ogg"
		}
	},
	ElvesHeroEridanTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Eridan_Confirm-01d.ogg",
			"Eridan_Confirm-03b.ogg",
			"Eridan_Confirm03-01a.ogg",
			"Eridan_confirmextra-01a.ogg",
			"Arivan_Confirm-01b.ogg",
			"Arivan_Confirm-02c.ogg",
			"Arivan_Confirm-03a.ogg",
			"Arivan_Confirm04-01a.ogg"
		}
	},
	ElvesHeroEridanTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	ElvesHeroArivanDeath = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Arivan_Death-01a.ogg"
		}
	},
	ElvesHeroArivanFireball = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_arivan_fireballshot_v2.ogg"
		}
	},
	ElvesHeroArivanFireballExplode = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_arivan_fireballhit_v3.ogg"
		}
	},
	ElvesHeroArivanFireballSummon = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_arivan_fireballsummon[op2].ogg"
		}
	},
	ElvesHeroArivanIceShoot = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_arivan_iceboltshot_v2[contono].ogg"
		}
	},
	ElvesHeroArivanIceShootHit = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_arivan_icebolt[hit].ogg"
		}
	},
	ElvesHeroArivanLightingBolt = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_arivan_lightningbolt_v2.ogg"
		}
	},
	ElvesHeroArivanStorm = {
		loop = true,
		gain = 0.3,
		source_group = "GUI",
		files = {
			"kre_sfx_arivan_elementalstorm_v2_op3.ogg"
		}
	},
	ElvesHeroArivanSummonRocks = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"kre_sfx_arivan_stonesummon_v2.ogg"
		}
	},
	ElvesHeroArivanTaunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"Arivan_Confirm-01b.ogg",
			"Arivan_Confirm-02c.ogg",
			"Arivan_Confirm-03a.ogg",
			"Arivan_Confirm04-01a.ogg"
		}
	},
	ElvesHeroArivanTauntIntro = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"Level_up.ogg"
		}
	},
	ElvesHeroArivanRegularRay = {
		loop = false,
		gain = 1,
		source_group = "SPECIALS",
		files = {
			"archmage_attack.ogg"
		}
	},
	dinos_ignis_altar_build_taunt = {
		ignore = 1,
		mode = "sequence",
		gain = 1,
		loop = false,
		source_group = "TAUNTS",
		files = {
			"kr4_dinos_ignis_altar_build_taunt_1.ogg",
			"kr4_dinos_ignis_altar_build_taunt_2.ogg",
			"kr4_dinos_ignis_altar_build_taunt_3.ogg"
		}
	},
	ignis_altar_build_taunt_4 = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_dinos_ignis_altar_build_taunt_4.ogg"
		}
	},
	ignis_altar_upgrade_elemental = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_dinos_ignis_altar_upgrade_elemental.ogg"
		}
	},
	ignis_altar_upgrade_true_fire = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_dinos_ignis_altar_upgrade_true_fire.ogg"
		}
	},
	ignis_altar_upgrade_debuff = {
		loop = false,
		gain = 1,
		source_group = "TAUNTS",
		files = {
			"kr4_dinos_ignis_altar_upgrade_debuff.ogg"
		}
	},
	dinos_ignis_altar_single_extinction_explotion = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_tower_altar_single_extintion_explotion.ogg"
		}
	},
	dinos_ignis_altar_single_extinction_1 = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_tower_altar_single_extintion_var1.ogg"
		}
	},
	dinos_ignis_altar_attack_shoot = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_tower_altar_attack_shoot.ogg"
		}
	},
	dinos_ignis_altar_attack_dot = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_tower_altar_attack_dot.ogg"
		}
	},
	dinos_ignis_altar_summon_elemental = {
		loop = false,
		gain = 1,
		source_group = "SFX",
		files = {
			"kr4_sfx_tower_altar_burning_summon.ogg"
		}
	},
	dinos_ignis_altar_elemental_spawn = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_tower_altar_burning_arise.ogg"
		}
	},
	dinos_ignis_altar_elemental_respawn = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_tower_altar_burning_elemental_respawn.ogg"
		}
	},
	malik_melee_attack = {
		loop = false,
		gain = 0.4,
		source_group = "SFX",
		files = {
			"kr4_sfx_malik_melee_attack_v1.ogg"
		}
	},
	malik_ranged_attack = {
		loop = false,
		gain = 0.6,
		source_group = "SFX",
		files = {
			"kr4_sfx_malik_ranged_attack_v1.ogg"
		}
	},
	malik_jump_charge = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kr4_sfx_malik_jump_charge-jump_v1.ogg"
		}
	},
	malik_jump_hit = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_malik_jump_hit_v1.ogg"
		}
	},
	malik_tower_destroy_oneshot = {
		loop = false,
		gain = 0.8,
		source_group = "SFX",
		files = {
			"kr4_sfx_malik_tower_destroy_oneShot_v2.ogg"
		}
	},
	malik_death_hammerfall = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_malik_death_hammerFall_v1.ogg"
		}
	},
	malik_death_body_fall = {
		loop = false,
		gain = 0.7,
		source_group = "SFX",
		files = {
			"kr4_sfx_malik_death_bodyFall_v1.ogg"
		}
	}
}
