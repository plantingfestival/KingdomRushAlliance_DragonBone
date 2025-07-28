local BG_W = 1728
local BG_H = 768
local SF = ctx.safe_frame
local MAP_DECOS_PIVOT_W = BG_W / 2 + 266
local MAP_DECOS_PIVOT_H = BG_W / 2 - 218 + 169.5

return {
	{
		x = ctx.sw,
		y = ctx.sh
	},
	class = "KWindow",
	children = {
		{
			id = "map_view",
			class = "MapView",
			size = v(2432, 1922),
			children = {
				{
					class = "KImageView",
					image_name = "MapBackground1"
				},
				{
					class = "KImageView",
					image_name = "MapBackground2",
					pos = v(2048, 0)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "AcolyteDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "ArboreanBabyDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "ArboreanFatDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "ArboreanHeartDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "BonfireDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "ChainPendulumDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "CrystalsDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "CutTreeRipplesDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "FirefliesDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "FishDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "MermaidsDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "FloatingHouseDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "HeartRipplesDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "PurpleBubblesDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "RayosDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "RedParticlesDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "MantaDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "RedVaporDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "RockRipplesDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "SeaDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "SheepsDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "SmokeBonfireDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "TowerFlashDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "VaporCraterDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "VeznanTowerDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "WaterSparksDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "WavesRiverDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "DLCDwarfSparksDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "DLCDwarfSnowDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "DLCDwarfSmokeDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "DLCDwarfFireDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "DLCDwarfEyesDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					id = "group_map_paths",
					class = "KView",
					template_name = "group_map_paths",
					pos = v(310.9, 937.05)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					ts = -4,
					exo_name = "ArboreanHoneyDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "ArboreanTreeDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					ts = 2,
					exo_name = "TentacleRocksDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					exo_animation = "loop",
					class = "GGExo",
					id = "map_deco_sword",
					exo_name = "SwordDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					exo_animation = "loop_inactive",
					class = "GGExoOverseer",
					id = "decos_map_overseer",
					exo_name = "overseer_mapDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					id = "group_map_flags",
					class = "KView",
					template_name = "group_map_flags",
					pos = v(272.25, 864.85)
				},
				{
					id = "map_dlc_special_flag",
					class = "KView",
					template_name = "map_dlc_special_flag",
					pos = v(865, 817.65)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "BirdsDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					ts = -3,
					exo_name = "NoxiousHorrorDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					class = "GGExo",
					exo_animation = "loop",
					exo_name = "BlinkersDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					exo_animation = "idle",
					class = "GGExo",
					hidden = true,
					id = "decos_map_clouds",
					exo_name = "clouds_mapDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				},
				{
					loop = true,
					exo_animation = "loop",
					class = "GGExo",
					hidden = true,
					id = "decos_map_thunder",
					exo_name = "rayos_t3inactiveDef",
					pos = v(MAP_DECOS_PIVOT_W, MAP_DECOS_PIVOT_H)
				}
			}
		},
		{
			image_name = "map_borders",
			propagate_on_down = true,
			class = "KImageView",
			propagate_on_up = true,
			id = "vignette_view",
			propagate_on_click = true
		},
		{
			propagate_on_up = true,
			propagate_on_down = true,
			class = "MapTouchView",
			disable_mouse_enter = true,
			id = "map_touch_view",
			propagate_on_click = true,
			size = v(ctx.sw, ctx.sh)
		},
		{
			id = "group_map_hud",
			class = "KView",
			template_name = "group_map_hud"
		},
		{
			class = "KView",
			id = "cheat_button",
			pos = v(SF.l, SF.t),
			size = v(100, 50),
			colors = {
				background = {
					0,
					255,
					0,
					0
				}
			}
		},
		{
			hidden = false,
			class = "GG5PopUpLevelSelect",
			template_name = "popup_level_select",
			id = "level_select_view",
			pos = v(ctx.sw / 2, 384),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpOptions",
			template_name = "popup_options",
			id = "popup_options",
			WHEN = ctx.is_mobile,
			pos = v(ctx.sw / 2, 384),
			size = v(ctx.sw, ctx.sh)
		},
		{
			template_name = "popup_options_desktop",
			class = "GG5PopUpOptionsDesktop",
			id = "popup_options",
			UNLESS = ctx.is_mobile,
			context = ctx.context,
			pos = v(ctx.sw / 2, ctx.sh / 2),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpLocaleList",
			template_name = "popup_locale_list",
			id = "popup_locale_list",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		},
		{
			class = "GG5PopUpMessage",
			template_name = "popup_message",
			id = "popup_message",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		},
		{
			id = "modal_bg_rooms",
			class = "RoomBackgroundView",
			hidden = true,
			block_id = "modal_bg_rooms_block",
			WHEN = ctx.is_mobile,
			pos = v(ctx.sw / 2, 0),
			exo_animations = {
				"background_in",
				"background_idle_loop",
				"background_out"
			},
			children = {
				{
					id = "group_heroroom_bg",
					class = "KView",
					pos = v(0, 384),
					children = {
						{
							class = "GG59View",
							overdraw_sides = true,
							id = "modal_bg_rooms_block",
							image_name = "hero_room_9slice_bg_temp_",
							pos = v(-900, -384.35),
							size = v(1943.9967, 771),
							anchor = v(0, -0.25),
							slice_rect = r(7.3, 7.05, 34.95, 757.25)
						}
					}
				},
				{
					exo_animation = "background_in",
					class = "GGExo",
					id = "modal_bg_exo",
					exo_name = "metagame_menues_bgDef",
					pos = v(0, 384)
				}
			}
		},
		{
			id = "modal_bg_rooms",
			class = "RoomBackgroundView",
			hidden = true,
			UNLESS = ctx.is_mobile,
			pos = v(ctx.sw / 2, 0),
			pos = v(ctx.sw / 2, ctx.sh / 2),
			children = {
				{
					propagate_on_down = false,
					class = "KView",
					propagate_drag = false,
					id = "overlay",
					propagate_on_enter = false,
					pos = v(-ctx.sw / 2, -ctx.sh / 2),
					size = v(ctx.sw, ctx.sh),
					colors = {
						background = {
							0,
							0,
							0,
							190
						}
					}
				}
			}
		},
		{
			id = "achievements_room_view",
			class = "AchievementsRoomView",
			hidden = true,
			background_id = "modal_bg_rooms",
			content_id = "group_achievements_room_container",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			anchor = v(ctx.sw / 2, ctx.sh / 2),
			children = {
				{
					id = "group_achievements_room_container",
					propagate_on_down = true,
					class = "KView",
					template_name = "achievements_room",
					hidden = false,
					propagate_on_click = true,
					propagate_on_up = true,
					pos = v(0, 0)
				}
			}
		},
		{
			id = "shop_room_view",
			class = "ShopRoomView",
			hidden = true,
			background_id = "modal_bg_rooms",
			content_id = "group_shop_room_container",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			anchor = v(ctx.sw / 2, ctx.sh / 2),
			children = {
				{
					id = "group_shop_room_container",
					propagate_on_down = true,
					class = "KView",
					template_name = "shop_room",
					hidden = false,
					propagate_on_click = true,
					propagate_on_up = true,
					pos = v(0, 0)
				}
			}
		},
		{
			id = "upgrades_room_view",
			class = "UpgradesRoomView",
			hidden = true,
			background_id = "modal_bg_rooms",
			content_id = "group_upgrades_room",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			anchor = v(0, 384),
			children = {
				{
					id = "group_upgrades_room",
					class = "KView",
					template_name = "group_upgrades_room",
					hidden = false,
					pos = v(0, 0)
				},
				{
					propagate_on_down = true,
					class = "KView",
					propagate_on_up = true,
					id = "group_upgrades_room_tutorial_overlay",
					propagate_on_click = true,
					pos = v(-ctx.sw / 2, -ctx.sh / 2)
				},
				{
					id = "group_upgrades_tutorial",
					class = "KView",
					template_name = "group_upgrades_room_tutorial",
					hidden = true,
					pos = v(-240, 591.36)
				}
			}
		},
		{
			id = "hero_room_view",
			class = "HeroRoomView",
			hidden = true,
			background_id = "modal_bg_rooms",
			content_id = "group_heroroom",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			anchor = v(0, 384),
			children = {
				{
					id = "group_heroroom",
					class = "KView",
					template_name = "group_heroroom",
					hidden = false,
					pos = v(0, ctx.OVT(17.8, "desktop", 150))
				},
				{
					propagate_on_down = true,
					class = "KView",
					propagate_on_up = true,
					id = "group_hero_room_tutorial_overlay",
					propagate_on_click = true,
					pos = v(-ctx.sw / 2, -ctx.sh / 2)
				},
				{
					id = "group_hero_room_tutorial",
					class = "KView",
					template_name = "group_heroroom_tutorial",
					hidden = true,
					pos = v(165, ctx.sh / 2 + ctx.OVT(-35, "desktop", 91))
				},
				{
					id = "hero_room_cheat_level",
					class = "GGImageButton",
					click_image_name = "mapStarsContainer_getGems_button_0002",
					hidden = true,
					default_image_name = "mapStarsContainer_getGems_button_0001",
					pos = v(-685, 225),
					scale = v(1.5, 1.5)
				}
			}
		},
		{
			id = "tower_room_view",
			class = "TowerRoomView",
			hidden = true,
			background_id = "modal_bg_rooms",
			content_id = "group_tower_room",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			anchor = v(0, 384),
			children = {
				{
					id = "group_tower_room",
					class = "KView",
					template_name = "group_tower_room",
					hidden = false,
					pos = v(0, ctx.OVT(17.8, "desktop", 150))
				},
				{
					propagate_on_down = true,
					class = "KView",
					propagate_on_up = true,
					id = "group_tower_room_tutorial_overlay",
					propagate_on_click = true,
					pos = v(-ctx.sw / 2, -ctx.sh / 2)
				},
				{
					id = "group_tower_room_tutorial",
					class = "KView",
					template_name = "group_tower_room_tutorial",
					hidden = true,
					pos = v(165, ctx.sh / 2 + ctx.OVT(-35, "desktop", 91))
				}
			}
		},
		{
			id = "item_room_view",
			class = "ItemRoomView",
			hidden = true,
			background_id = "modal_bg_rooms",
			content_id = "group_item_room",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			anchor = v(0, 384),
			children = {
				{
					id = "group_item_room",
					class = "KView",
					template_name = "group_item_room",
					hidden = false,
					pos = v(0, 17.8)
				},
				{
					propagate_on_down = true,
					class = "KView",
					propagate_on_up = true,
					id = "group_item_room_tutorial_overlay",
					propagate_on_click = true,
					pos = v(-ctx.sw / 2, -ctx.sh / 2)
				},
				{
					id = "group_item_room_tutorial",
					class = "KView",
					template_name = "group_item_room_tutorial",
					hidden = true,
					pos = v(165, ctx.sh / 2 - 35)
				}
			}
		},
		{
			id = "card_rewards_view",
			class = "CardRewardsView",
			hidden = true,
			pos = v(ctx.sw / 2, ctx.sh / 2),
			anchor = v(ctx.sw / 2, ctx.sh / 2),
			children = {
				{
					id = "screen_cards_main",
					class = "KView",
					template_name = "screen_cards_main",
					hidden = false,
					pos = v(0, 0)
				}
			}
		},
		{
			id = "difficulty_room_view",
			class = "DifficultyRoomView",
			hidden = true,
			background_id = "modal_bg_rooms",
			content_id = "group_difficulty_room",
			pos = v(ctx.sw / 2, ctx.sh / 2),
			anchor = v(0, 384),
			children = {
				{
					id = "group_difficulty_room",
					class = "KView",
					template_name = "group_difficulty_room",
					hidden = false,
					pos = v(0, 384)
				}
			}
		},
		{
			hidden = true,
			class = "GG5PopUpMessage",
			template_name = "popup_message",
			id = "message_view",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		},
		{
			hidden = true,
			class = "GG5PopUpPurchasing",
			template_name = "popup_purchasing",
			id = "processing_view",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		},
		{
			hidden = true,
			class = "GG5PopUpError",
			template_name = "popup_error",
			id = "error_view",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		},
		{
			hidden = true,
			class = "GG5PopUpBugReport",
			template_name = "popup_bugreport",
			id = "error_report_view",
			pos = v(ctx.sw / 2, 362),
			size = v(ctx.sw, ctx.sh)
		}
	}
}
