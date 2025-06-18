-- chunkname: @./kr5/data/kui_templates/group_map_hud.lua

return {
	class = "KView",
	children = {
		{
			id = "group_bottom",
			class = "KView",
			pos = v(ctx.sw / 2, 759.3),
			children = {
				{
					class = "GG59View",
					image_name = "screen_map_9slice_shadow_bottom__",
					id = "shadow",
					pos = v(2.75, -80.05),
					size = v(1747.5072, 201.2874),
					anchor = v(870.4811, 100.5879),
					slice_rect = r(3.3, 3.7, 6.75, 89.9)
				},
				{
					id = "button_map_heroes",
					focus_image_name = "screen_map_button_map_heroes_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_heroes_0001",
					pos = v(-364.3, -99.05),
					anchor = v(78.3, 76.35)
				},
				{
					id = "button_map_towers",
					focus_image_name = "screen_map_button_map_towers_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_towers_0001",
					pos = v(-179.15, -98.05),
					anchor = v(78.3, 75.5)
				},
				{
					id = "button_map_upgrades",
					focus_image_name = "screen_map_button_map_upgrades_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_upgrades_0001",
					pos = v(5.9, -98.05),
					anchor = v(78.25, 75.5)
				},
				{
					id = "button_map_items",
					focus_image_name = "screen_map_button_map_items_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_items_0001",
					pos = v(191, -98.05),
					anchor = v(78.25, 75.5)
				},
				{
					id = "button_map_shop",
					focus_image_name = "screen_map_button_map_shop_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_shop_0001",
					pos = v(376.15, -99.05),
					anchor = v(78.3, 74.55)
				},
				{
					id = "group_sale_button_overlay_heroes",
					class = "KView",
					pos = v(-377.75, -133.25),
					children = {
						{
							class = "KImageView",
							image_name = "screen_map_image_button_label_sale_",
							pos = v(5.35, 4.3),
							anchor = v(58.05, 34.3)
						},
						{
							vertical_align = "middle-caps",
							line_height_extra = "0",
							text = "sale",
							class = "GG5ShaderLabel",
							text_key = "SALE_SCREEN_MAP_ROOMS",
							fit_size = true,
							font_name = "fla_h",
							r = 0.3802,
							font_size = 26,
							text_align = "center",
							id = "label_sale",
							pos = v(-10.6, -13.8),
							scale = v(0.8382, 0.8382),
							size = v(82.1, 25.6),
							colors = {
								text = {
									255,
									255,
									255
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 2.5,
									outline_color = {
										0.8588,
										0,
										0,
										1
									}
								}
							},
							anchor = v(35.45, -1.1)
						}
					}
				},
				{
					id = "group_sale_button_overlay_towers",
					class = "KView",
					pos = v(-192.9, -133.25),
					children = {
						{
							class = "KImageView",
							image_name = "screen_map_image_button_label_sale_",
							pos = v(5.35, 4.3),
							anchor = v(58.05, 34.3)
						},
						{
							vertical_align = "middle-caps",
							line_height_extra = "0",
							text = "sale",
							class = "GG5ShaderLabel",
							text_key = "SALE_SCREEN_MAP_ROOMS",
							fit_size = true,
							font_name = "fla_h",
							r = 0.3802,
							font_size = 26,
							text_align = "center",
							id = "label_sale",
							pos = v(-10.55, -13.85),
							scale = v(0.8352, 0.8352),
							size = v(81.85, 25.45),
							colors = {
								text = {
									255,
									255,
									255
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 2.5,
									outline_color = {
										0.8588,
										0,
										0,
										1
									}
								}
							},
							anchor = v(35.35, -1.3)
						}
					}
				},
				{
					class = "KView"
				},
				{
					vertical_align = "middle",
					text_align = "center",
					font_size = 24,
					line_height_extra = "0",
					fit_size = true,
					text = "TOWERS",
					text_key = "MAP_BUTTON_TOWER_ROOM",
					class = "GG5ShaderLabel",
					id = "label_map_towers",
					font_name = "fla_body",
					pos = v(-271.35, -56.55),
					scale = v(1, 1),
					size = v(181.45, 43),
					colors = {
						text = {
							224,
							249,
							241
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "center",
					font_size = 24,
					line_height_extra = "0",
					fit_size = true,
					text = "HEROES",
					text_key = "MAP_BUTTON_HERO_ROOM",
					class = "GG5ShaderLabel",
					id = "label_map_heroes",
					font_name = "fla_body",
					pos = v(-454.6, -56.55),
					scale = v(1, 1),
					size = v(177.85, 43),
					colors = {
						text = {
							224,
							249,
							241
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "center",
					font_size = 24,
					line_height_extra = "0",
					fit_size = true,
					text = "ITEMS",
					text_key = "MAP_BUTTON_ITEMS",
					class = "GG5ShaderLabel",
					id = "label_map_items",
					font_name = "fla_body",
					pos = v(104.7, -56.65),
					scale = v(1, 1),
					size = v(177.4, 42.35),
					colors = {
						text = {
							224,
							249,
							241
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "center",
					font_size = 24,
					line_height_extra = "0",
					fit_size = true,
					text = "UPGRADES",
					text_key = "MAP_BUTTON_UPGRADES",
					class = "GG5ShaderLabel",
					id = "label_map_upgrades",
					font_name = "fla_body",
					pos = v(-83.55, -56.55),
					scale = v(1, 1),
					size = v(179.15, 43),
					colors = {
						text = {
							224,
							249,
							241
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "center",
					font_size = 24,
					line_height_extra = "0",
					fit_size = true,
					text = "SHOP",
					text_key = "MAP_BUTTON_SHOP",
					class = "GG5ShaderLabel",
					id = "label_map_shop",
					font_name = "fla_body",
					pos = v(287.65, -56.55),
					scale = v(1, 1),
					size = v(177.85, 43),
					colors = {
						text = {
							224,
							249,
							241
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					id = "map_hud_notification_new_hero",
					class = "KView",
					pos = v(-362.15, -192.6),
					children = {
						{
							image_name = "screen_map_9slice_bg_new_item_",
							class = "GG59View",
							pos = v(0.8, -14.2),
							size = v(164.6167, 58.4066),
							anchor = v(83.1128, 29.6023),
							slice_rect = r(77.55, 8.55, 8.85, 17.3)
						},
						{
							class = "KImageView",
							image_name = "screen_map_image_notif_arrow_",
							pos = v(0, 17.9),
							anchor = v(7.65, 3.8)
						},
						{
							vertical_align = "middle",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 22,
							line_height_extra = "-8",
							text = "New Tower!",
							id = "label_txt_notification_icon",
							fit_size = true,
							font_name = "fla_body",
							pos = v(-87.2, -40.35),
							size = v(168.35, 50.2),
							colors = {
								text = {
									244,
									255,
									91
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 1.6666666666666667,
									outline_color = {
										0.8039,
										0.4314,
										0,
										1
									}
								}
							}
						}
					}
				},
				{
					id = "map_hud_notification_new_tower",
					class = "KView",
					pos = v(-178.8, -192.6),
					children = {
						{
							image_name = "screen_map_9slice_bg_new_item_",
							class = "GG59View",
							pos = v(0.8, -14.2),
							size = v(164.6167, 58.4066),
							anchor = v(83.1128, 29.6023),
							slice_rect = r(77.55, 8.55, 8.85, 17.3)
						},
						{
							class = "KImageView",
							image_name = "screen_map_image_notif_arrow_",
							pos = v(0, 17.9),
							anchor = v(7.65, 3.8)
						},
						{
							vertical_align = "middle",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 22,
							line_height_extra = "-8",
							text = "New Tower!",
							id = "label_txt_notification_icon",
							fit_size = true,
							font_name = "fla_body",
							pos = v(-87.2, -40.35),
							size = v(168.35, 50.2),
							colors = {
								text = {
									244,
									255,
									91
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 1.6666666666666667,
									outline_color = {
										0.8039,
										0.4314,
										0,
										1
									}
								}
							}
						}
					}
				},
				{
					loop = true,
					id = "alert_heroes",
					class = "GGAni",
					pos = v(-314.4, -147.6),
					anchor = v(24.3, 21.9),
					animation = {
						to = 24,
						prefix = "screen_map_animation_alert",
						from = 1
					}
				},
				{
					loop = true,
					id = "alert_towers",
					class = "GGAni",
					pos = v(-129.6, -146.7),
					anchor = v(24.3, 21.9),
					animation = {
						to = 24,
						prefix = "screen_map_animation_alert",
						from = 1
					}
				},
				{
					loop = true,
					id = "alert_upgrades",
					class = "GGAni",
					pos = v(55.95, -145.8),
					anchor = v(24.3, 21.9),
					animation = {
						to = 24,
						prefix = "screen_map_animation_alert",
						from = 1
					}
				},
				{
					loop = true,
					id = "alert_items",
					class = "GGAni",
					pos = v(240.45, -145.8),
					anchor = v(24.3, 21.9),
					animation = {
						to = 24,
						prefix = "screen_map_animation_alert",
						from = 1
					}
				},
				{
					loop = true,
					id = "alert_shop",
					class = "GGAni",
					pos = v(426.05, -147.6),
					anchor = v(24.3, 21.9),
					animation = {
						to = 24,
						prefix = "screen_map_animation_alert",
						from = 1
					}
				}
			}
		},
		{
			id = "group_bottom_right",
			class = "KView",
			pos = v(ctx.sw - ctx.safe_frame.r, 759.5),
			children = {
				{
					id = "button_map_achievements",
					focus_image_name = "screen_map_button_map_achievements_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_achievements_0001",
					pos = v(-114.45, -95.75),
					anchor = v(94.3, 88.85)
				},
				{
					vertical_align = "middle",
					text_align = "center",
					font_size = 24,
					line_height_extra = "0",
					text_key = "MAP_BUTTON_ACHIEVEMENTS",
					text = "ACHIEVEMENTS",
					class = "GG5ShaderLabel",
					id = "label_map_achievements",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-224.45, -57.7),
					size = v(220, 45.7),
					colors = {
						text = {
							223,
							248,
							240
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					loop = true,
					id = "alert_achievements",
					class = "GGAni",
					pos = v(-67.35, -146.3),
					anchor = v(24.3, 21.9),
					animation = {
						to = 24,
						prefix = "screen_map_animation_alert",
						from = 1
					}
				}
			}
		},
		{
			id = "group_top_right",
			class = "KView",
			pos = v(ctx.sw - ctx.safe_frame.r, 0),
			children = {
				{
					id = "button_map_options",
					focus_image_name = "screen_map_button_map_options_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_options_0001",
					pos = v(-51.95, 70.85),
					anchor = v(53.95, 50)
				}
			}
		},
		{
			id = "group_top_left",
			class = "KView",
			pos = v(ctx.safe_frame.l, -10.8),
			children = {
				{
					class = "KImageView",
					image_name = "screen_map_image_hud_gems_",
					id = "bg_gems",
					pos = v(31.1, 57.9),
					scale = v(0.8908, 0.8908),
					anchor = v(-201.25, 25.5)
				},
				{
					class = "KImageView",
					image_name = "screen_map_image_hud_stars_",
					id = "bg_stars",
					pos = v(31.1, 57.9),
					scale = v(0.8908, 0.8908),
					anchor = v(36, 28.7)
				},
				{
					vertical_align = "middle",
					text_align = "center",
					font_size = 28,
					fit_size = true,
					line_height_extra = "2",
					text = "110/110",
					class = "GG5ShaderLabel",
					id = "label_map_stars",
					font_name = "fla_numbers",
					pos = v(58.8, 42.35),
					scale = v(1, 1),
					size = v(118, 38.5),
					colors = {
						text = {
							255,
							255,
							255
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.0833333333333335,
							outline_color = {
								0,
								0,
								0,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "left",
					font_size = 30,
					fit_size = true,
					line_height_extra = "2",
					text = "45",
					class = "GG5ShaderLabel",
					id = "label_map_gems",
					font_name = "fla_numbers",
					pos = v(274, 40.4),
					scale = v(1, 1),
					size = v(94.05, 40.95),
					colors = {
						text = {
							255,
							255,
							255
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.0833333333333335,
							outline_color = {
								0,
								0,
								0,
								1
							}
						}
					}
				},
				{
					id = "button_map_hud_buy_gems",
					focus_image_name = "screen_map_button_map_hud_buy_gems_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_hud_buy_gems_0001",
					pos = v(408.45, 61.8),
					anchor = v(38.4, 36.2)
				}
			}
		},
		{
			class = "ShopOfferBubbleView",
			id = "group_offer_icon",
			pos = v(ctx.sw - ctx.safe_frame.r, 189.8),
			WHEN = ctx.is_mobile,
			children = {
				{
					id = "animation_offer_icon",
					image_name = "screen_map_image_offer_icon_",
					class = "KImageView",
					pos = v(0.9, 1.65),
					anchor = v(98.85, 43.55)
				},
				{
					loop = true,
					class = "GGAni",
					id = "animation_reflection",
					pos = v(-92.35, -36.5),
					scale = v(1.5131, 1.5131),
					anchor = v(0, 0),
					animation = {
						to = 128,
						prefix = "screen_map_animation_reflection_box",
						from = 1
					}
				},
				{
					loop = true,
					id = "animation_offer_icon",
					class = "GGAni",
					pos = v(0.9, 1.65),
					anchor = v(85.15, 81.7),
					animation = {
						to = 18,
						prefix = "screen_map_animation_offer_icon_particles",
						from = 1
					}
				},
				{
					id = "timeline_offer_icon",
					fps = 30,
					class = "GGTimeline",
					frame_duration = 54,
					play = "loop",
					pos = v(0.9, 1.65),
					children = {
						{
							class = "GGAni",
							id = "l9_animation_spark",
							pos = v(-96.4, -35),
							scale = v(1.314, 1.314),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "l1_animation_spark",
							pos = v(-60.7, 24.1),
							scale = v(1.1064, 1.1064),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "l0_animation_spark",
							pos = v(-90.4, -12.6),
							scale = v(0.8798, 0.8798),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						}
					},
					timeline = {
						{
							f = 1,
							a_from = 20,
							play = "loop",
							id = "l9_animation_spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-96.4, -35),
							scale = v(1.314, 1.314)
						},
						{
							f = 1,
							a_from = 26,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749)
						},
						{
							f = 1,
							a_from = 36,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-53.8, -46.9),
							scale = v(1.0774, 1.0774)
						},
						{
							f = 1,
							a_from = 5,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-60.75, 25.35),
							scale = v(0.9123, 0.9123)
						},
						{
							f = 1,
							a_from = 11,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-101.25, 5.75),
							scale = v(1.1403, 1.1403)
						},
						{
							f = 1,
							a_from = 50,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-76.45, -17.9),
							scale = v(1.5332, 1.5332)
						},
						{
							f = 1,
							a_from = 30,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-31.45, 3.55),
							scale = v(1.4529, 1.4529)
						},
						{
							f = 1,
							a_from = 40,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-50.55, 21.35),
							scale = v(0.8649, 0.8649)
						},
						{
							f = 1,
							a_from = 26,
							play = "loop",
							id = "l1_animation_spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-60.7, 24.1),
							scale = v(1.1064, 1.1064)
						},
						{
							f = 1,
							a_from = 31,
							play = "loop",
							id = "l0_animation_spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-90.4, -12.6),
							scale = v(0.8798, 0.8798)
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 21,
					line_height_extra = "2",
					fit_size = true,
					text = "99h 99m",
					text_key = "MAP_BUTTON_SHOP",
					class = "GG5ShaderLabel",
					id = "label_map_shop",
					font_name = "fla_body",
					pos = v(-112.15, 28.15),
					scale = v(1, 1),
					size = v(119.35, 40.6),
					colors = {
						text = {
							224,
							249,
							241
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					id = "button_map_offer",
					focus_image_name = "screen_map_button_map_offer_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_offer_0001",
					pos = v(-51.85, -1.45),
					anchor = v(57.5, 54.6)
				}
			}
		},
		{
			season = "halloween",
			class = "ShopOfferBubbleView",
			id = "group_offer_icon_halloween",
			pos = v(ctx.sw - ctx.safe_frame.r, 311.85),
			WHEN = ctx.is_mobile,
			children = {
				{
					id = "animation_offer_icon",
					image_name = "screen_map_image_offer_icon_halloween_",
					class = "KImageView",
					pos = v(0.9, 1.65),
					anchor = v(98.85, 50.25)
				},
				{
					loop = true,
					class = "GGAni",
					id = "animation_reflection_season",
					pos = v(-92.35, -36.5),
					scale = v(1.5131, 1.5131),
					anchor = v(2, 3),
					animation = {
						to = 128,
						prefix = "screen_map_animation_reflection",
						from = 1
					}
				},
				{
					loop = true,
					class = "GGAni",
					id = "animation_offer_icon",
					pos = v(-77.65, -24.05),
					scale = v(1, 1),
					anchor = v(5.45, 27.25),
					animation = {
						to = 18,
						prefix = "screen_map_animation_sparks_halloween",
						from = 1
					}
				},
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 21,
					line_height_extra = "2",
					fit_size = true,
					text = "99h 99m",
					text_key = "MAP_BUTTON_SHOP",
					class = "GG5ShaderLabel",
					id = "label_map_shop",
					font_name = "fla_body",
					pos = v(-112.15, 28.15),
					scale = v(1, 1),
					size = v(119.35, 40.6),
					colors = {
						text = {
							224,
							249,
							241
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					id = "button_map_offer",
					focus_image_name = "screen_map_button_map_offer_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_offer_0001",
					pos = v(-51.85, -1.45),
					anchor = v(57.5, 54.6)
				}
			}
		},
		{
			season = "christmas",
			class = "ShopOfferBubbleView",
			id = "group_offer_icon_christmas",
			pos = v(ctx.sw - ctx.safe_frame.r, 311.35),
			WHEN = ctx.is_mobile,
			children = {
				{
					id = "animation_offer_icon",
					image_name = "screen_map_image_offer_icon_christmas_",
					class = "KImageView",
					pos = v(0.9, 1.65),
					anchor = v(98.8, 44)
				},
				{
					loop = true,
					class = "GGAni",
					id = "animation_reflection_season",
					pos = v(-92.35, -36.5),
					scale = v(1.5131, 1.5131),
					anchor = v(2, 3),
					animation = {
						to = 128,
						prefix = "screen_map_animation_reflection",
						from = 1
					}
				},
				{
					id = "timeline_offer_icon",
					fps = 30,
					class = "GGTimeline",
					frame_duration = 54,
					play = "loop",
					pos = v(0.9, 1.65),
					children = {
						{
							class = "GGAni",
							id = "l9_animation_spark",
							pos = v(-96.4, -35),
							scale = v(1.314, 1.314),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "spark",
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "l1_animation_spark",
							pos = v(-60.7, 24.1),
							scale = v(1.1064, 1.1064),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						},
						{
							class = "GGAni",
							id = "l0_animation_spark",
							pos = v(-90.4, -12.6),
							scale = v(0.8798, 0.8798),
							anchor = v(-2.35, -2.4),
							animation = {
								to = 54,
								prefix = "screen_map_animation_spark",
								from = 1
							}
						}
					},
					timeline = {
						{
							f = 1,
							a_from = 20,
							play = "loop",
							id = "l9_animation_spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-96.4, -35),
							scale = v(1.314, 1.314)
						},
						{
							f = 1,
							a_from = 26,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-26.3, -31.5),
							scale = v(1.3749, 1.3749)
						},
						{
							f = 1,
							a_from = 36,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-53.8, -46.9),
							scale = v(1.0774, 1.0774)
						},
						{
							f = 1,
							a_from = 5,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-60.75, 25.35),
							scale = v(0.9123, 0.9123)
						},
						{
							f = 1,
							a_from = 11,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-101.25, 5.75),
							scale = v(1.1403, 1.1403)
						},
						{
							f = 1,
							a_from = 50,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-76.45, -17.9),
							scale = v(1.5332, 1.5332)
						},
						{
							f = 1,
							a_from = 30,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-31.45, 3.55),
							scale = v(1.4529, 1.4529)
						},
						{
							f = 1,
							a_from = 40,
							play = "loop",
							id = "spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-50.55, 21.35),
							scale = v(0.8649, 0.8649)
						},
						{
							f = 1,
							a_from = 26,
							play = "loop",
							id = "l1_animation_spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-60.7, 24.1),
							scale = v(1.1064, 1.1064)
						},
						{
							f = 1,
							a_from = 31,
							play = "loop",
							id = "l0_animation_spark",
							a_to = 54,
							frame_duration = 54,
							pos = v(-90.4, -12.6),
							scale = v(0.8798, 0.8798)
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 21,
					line_height_extra = "2",
					fit_size = true,
					text = "99h 99m",
					text_key = "MAP_BUTTON_SHOP",
					class = "GG5ShaderLabel",
					id = "label_map_shop",
					font_name = "fla_body",
					pos = v(-112.15, 28.15),
					scale = v(1, 1),
					size = v(119.35, 40.6),
					colors = {
						text = {
							224,
							249,
							241
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0,
								0.2314,
								0.2706,
								1
							}
						}
					}
				},
				{
					id = "button_map_offer",
					focus_image_name = "screen_map_button_map_offer_0003",
					class = "GG5Button",
					default_image_name = "screen_map_button_map_offer_0001",
					pos = v(-51.85, -1.45),
					anchor = v(57.5, 54.6)
				}
			}
		}
	}
}
