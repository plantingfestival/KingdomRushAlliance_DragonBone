return {
	class = "GG5PopUpLevelSelect",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					image_name = "level_select_image_window_ui_popup_bg_shadow_",
					class = "KImageView",
					pos = v(-22.25, 79.6),
					scale = v(1.4886, 0.9524),
					anchor = v(358.1, -156.85)
				},
				{
					id = "image_thumb",
					image_name = "level_select_image_level_select_thumb_",
					class = "KImageView",
					pos = v(-19.65, -7),
					anchor = v(504, 266)
				},
				{
					class = "GG59View",
					image_name = "level_select_9slice_level_select_black_overlay_",
					id = "image_txt_bg",
					pos = v(19.4, 125.1),
					size = v(930.2678, 266.8149),
					anchor = v(465.1339, 133.4074),
					slice_rect = r(3, 3.2, 4.2, 3.65)
				},
				{
					class = "KView",
					id = "group_mode_campaign",
					pos = v(17.85, 98.45),
					scale = v(1, 1),
					children = {
						{
							vertical_align = "top",
							text_align = "left",
							line_height_extra = "0",
							font_size = 24,
							text = "Success! the gates are destroyed and now our army is on the Dwarf realm! A long path lies ahead to reach the arcs where they guard the treasure. Advance through the old part of the reign, once glorious but fallen to our last skirmish. The forces of the dwarves will be scarce and we should not encounter much resistance. and we should not sista",
							class = "GG5Label",
							id = "label_campaign_brief",
							font_name = "fla_body",
							pos = v(-416.1, -90.95),
							scale = v(1, 1),
							size = v(856.2, 181.3),
							colors = {
								text = {
									255,
									255,
									255
								}
							}
						}
					}
				},
				{
					id = "group_mode_rules",
					class = "KView",
					pos = v(-201.35, 120.75),
					children = {
						{
							id = "image_rule_1",
							image_name = "level_select_image_rule_waves_",
							class = "KImageView",
							pos = v(-150.3, 4.8),
							anchor = v(16.7, 16.3)
						},
						{
							id = "image_rule_2",
							image_name = "level_select_image_rule_lives_",
							class = "KImageView",
							pos = v(-149.55, 55.1),
							anchor = v(17.85, 16)
						},
						{
							vertical_align = "top",
							text_align = "left",
							line_height_extra = "0",
							font_size = 24,
							fit_size = true,
							text = "1 life total",
							class = "GG5Label",
							id = "label_rules_2",
							font_name = "fla_body",
							pos = v(-123.7, 39.1),
							scale = v(1, 1),
							size = v(292.85, 33.55),
							colors = {
								text = {
									255,
									255,
									255
								}
							}
						},
						{
							vertical_align = "top",
							text_align = "left",
							font_size = 27,
							fit_size = true,
							line_height_extra = "1",
							text = "Challenge Rules",
							class = "GG5ShaderLabel",
							id = "label_rules",
							font_name = "fla_body",
							pos = v(-170.35, -59.45),
							scale = v(1, 1),
							size = v(340.65, 37.25),
							colors = {
								text = {
									255,
									255,
									255
								}
							},
							shaders = {
								"p_glow"
							},
							shader_args = {
								{
									thickness = 2,
									glow_color = {
										0,
										0,
										0,
										1
									}
								}
							}
						},
						{
							vertical_align = "top",
							text_align = "left",
							line_height_extra = "0",
							font_size = 24,
							fit_size = true,
							text = "6 elite waves",
							class = "GG5Label",
							id = "label_rules_1",
							font_name = "fla_body",
							pos = v(-125.7, -10.9),
							scale = v(1, 1),
							size = v(293.7, 33.55),
							colors = {
								text = {
									255,
									255,
									255
								}
							}
						}
					}
				},
				{
					id = "group_mode_towers",
					class = "KView",
					pos = v(221, 113.7),
					children = {
						{
							class = "KImageView",
							image_name = "level_select_image_available_towers_",
							id = "image_available_tower_1",
							pos = v(-109.5, 32.95),
							scale = v(1, 1),
							anchor = v(38.7, 38.1)
						},
						{
							class = "KImageView",
							image_name = "level_select_image_available_towers_",
							id = "image_available_tower_3",
							pos = v(-4, 32.95),
							scale = v(1.0191, 1.0191),
							anchor = v(38.7, 38.1)
						},
						{
							class = "KImageView",
							image_name = "level_select_image_available_towers_",
							id = "image_available_tower_5",
							pos = v(101.5, 32.95),
							scale = v(1.0191, 1.0191),
							anchor = v(38.7, 38.1)
						},
						{
							class = "KImageView",
							image_name = "level_select_image_available_towers_",
							id = "image_available_tower_2",
							pos = v(-46.5, 32.95),
							scale = v(1.0191, 1.0191),
							anchor = v(38.7, 38.1)
						},
						{
							class = "KImageView",
							image_name = "level_select_image_available_towers_",
							id = "image_available_tower_4",
							pos = v(54.5, 32.95),
							scale = v(1.0191, 1.0191),
							anchor = v(38.7, 38.1)
						},
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 27,
							fit_size = true,
							line_height_extra = "1",
							text = "Avalilable Towers",
							class = "GG5ShaderLabel",
							id = "label_available_towers",
							font_name = "fla_body",
							pos = v(-198.6, -53.65),
							scale = v(1, 1),
							size = v(397.15, 37.25),
							colors = {
								text = {
									255,
									255,
									255
								}
							},
							shaders = {
								"p_glow"
							},
							shader_args = {
								{
									thickness = 2,
									glow_color = {
										0,
										0,
										0,
										1
									}
								}
							}
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					line_height_extra = "1",
					font_size = 32,
					fit_size = true,
					text = "chagenge mode",
					class = "GG5Label",
					id = "label_mode",
					font_name = "fla_body",
					pos = v(-368.6, 3.05),
					scale = v(1, 1),
					size = v(610.25, 43.4),
					colors = {
						text = {
							255,
							212,
							64
						}
					}
				},
				{
					class = "KImageView",
					image_name = "level_select_image_inner_shadow_01_",
					pos = v(-473.15, -8.15),
					anchor = v(62.85, 275.45)
				},
				{
					id = "top_shadow",
					image_name = "level_select_image_inner_shadow_02_",
					class = "KImageView",
					pos = v(41.55, -242.1),
					anchor = v(451.85, 45.3)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_inner_shadow_03_",
					pos = v(473.05, 34.65),
					anchor = v(23.9, 231.45)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_inner_shadow_04_",
					pos = v(19.4, 246.95),
					anchor = v(429.7, 19.4)
				},
				{
					id = "top_shadow_s16",
					image_name = "level_select_image_inner_shadow_02_s16_",
					class = "KImageView",
					pos = v(41.55, -242.1),
					anchor = v(451.85, 45.3)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_badges_bg_",
					id = "image_badges_bg",
					pos = v(-16.15, -259.7),
					scale = v(0.7563, 0.7563),
					anchor = v(189.1, 32.5)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_badges_bg_s16_",
					id = "image_badges_bg_s16",
					pos = v(-17.45, -259.7),
					scale = v(0.7563, 0.7563),
					anchor = v(140.75, 32.5)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_vertex_01_",
					pos = v(-510.6, -264.55),
					anchor = v(26.2, 22.05)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_side_03_",
					pos = v(-18, -280.2),
					anchor = v(472.2, 11.8)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_vertex_02_",
					pos = v(472, -264.5),
					anchor = v(26.65, 22.2)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_side_02_",
					pos = v(490.8, -5.95),
					anchor = v(12.25, 241.95)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_vertex_03_",
					pos = v(471.6, 250.5),
					anchor = v(26.15, 22.1)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_side_04_",
					pos = v(-23.7, 265.75),
					anchor = v(477.5, 11.6)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_side_01_",
					pos = v(-530.4, -3.8),
					anchor = v(11.65, 242.55)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_vertex_04_",
					pos = v(-478.9, 127.25),
					anchor = v(63.1, 144.95)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_bottom_btn_bg_",
					pos = v(-20.95, 297.35),
					anchor = v(-104.55, 27.2)
				},
				{
					class = "GG59View",
					image_name = "level_select_9slice_image_title_bg_",
					id = "title_bg",
					pos = v(-17.9, -315.35),
					size = v(552.2832, 63.999),
					anchor = v(276.1416, 29.8995),
					slice_rect = r(116.05, 0.35, 16.8, 62.65)
				},
				{
					image_name = "level_select_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(-532.65, -146.15),
					scale = v(1, 1),
					anchor = v(8.45, 7.6)
				},
				{
					image_name = "level_select_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(491.05, -146.15),
					scale = v(1, 1),
					anchor = v(8.45, 7.6)
				},
				{
					image_name = "level_select_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(491.05, 124.35),
					scale = v(1, 1),
					anchor = v(8.45, 7.6)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_bottom_btn_bg_2_",
					pos = v(-259.8, 297.35),
					anchor = v(-68.75, 27.2)
				},
				{
					class = "GG5Button",
					template_name = "button_level_select_fight",
					id = "button_fight",
					pos = v(-21.45, 290.65),
					scale = v(1, 1)
				},
				{
					class = "GG5Button",
					template_name = "button_level_select_buy",
					id = "button_buy",
					pos = v(-21.45, 290.65),
					scale = v(1, 1)
				},
				{
					class = "LevelSelectModeButton",
					template_name = "toggle_level_mode",
					id = "toggle_mode_2",
					pos = v(-487.15, 128.25),
					scale = v(1, 1)
				},
				{
					class = "LevelSelectModeButton",
					template_name = "toggle_level_mode",
					id = "toggle_mode_3",
					pos = v(-487.15, 217.2),
					scale = v(1, 1)
				},
				{
					id = "toggle_mode_1",
					class = "LevelSelectModeButton",
					template_name = "toggle_level_mode",
					pos = v(-487.15, 38.25)
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 40,
					line_height_extra = "2",
					fit_size = true,
					text = "heart of the forest",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_1",
					font_name = "fla_h",
					pos = v(-366.45, -336.65),
					scale = v(0.9999, 0.9999),
					size = v(702.9, 51.65),
					colors = {
						text = {
							45,
							79,
							57
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.698,
								1,
								0.4314,
								1
							},
							c2 = {
								0.3647,
								0.8353,
								0.2627,
								1
							},
							c3 = {
								0.3647,
								0.8353,
								0.2627,
								1
							}
						},
						{
							thickness = 2.916666666666667,
							outline_color = {
								0.0627,
								0.1961,
								0.0196,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 40,
					line_height_extra = "2",
					fit_size = true,
					text = "heart of the forest",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_2",
					font_name = "fla_h",
					pos = v(-366.45, -336.25),
					scale = v(0.9999, 0.9999),
					size = v(702.9, 51.65),
					colors = {
						text = {
							45,
							79,
							57
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.698,
								1,
								0.4314,
								1
							},
							c2 = {
								0.3647,
								0.8353,
								0.2627,
								1
							},
							c3 = {
								0.3647,
								0.8353,
								0.2627,
								1
							}
						},
						{
							thickness = 2.916666666666667,
							outline_color = {
								0.0627,
								0.1961,
								0.0196,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 40,
					line_height_extra = "2",
					fit_size = true,
					text = "heart of the forest",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_3",
					font_name = "fla_h",
					pos = v(-366.2, -335.35),
					scale = v(0.9999, 0.9999),
					size = v(702.9, 50.5),
					colors = {
						text = {
							235,
							52,
							41
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.9098,
								0.6,
								0.4941,
								1
							},
							c2 = {
								0.9216,
								0.2,
								0.1529,
								1
							},
							c3 = {
								0.9216,
								0.2,
								0.1529,
								1
							}
						},
						{
							thickness = 2.916666666666667,
							outline_color = {
								0.2078,
								0.0863,
								0.0667,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 40,
					line_height_extra = "2",
					fit_size = true,
					text = "heart of the forest",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_4",
					font_name = "fla_h",
					pos = v(-366.45, -336.2),
					scale = v(0.9999, 0.9999),
					size = v(702.9, 51.15),
					colors = {
						text = {
							49,
							44,
							61
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.9608,
								0.702,
								1,
								1
							},
							c2 = {
								0.8392,
								0.3098,
								1,
								1
							},
							c3 = {
								0.8392,
								0.3098,
								1,
								1
							}
						},
						{
							thickness = 2.916666666666667,
							outline_color = {
								0.149,
								0.1137,
								0.349,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 40,
					line_height_extra = "2",
					fit_size = true,
					text = "heart of the forest",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_5",
					font_name = "fla_h",
					pos = v(-366.45, -336.2),
					scale = v(0.9999, 0.9999),
					size = v(702.9, 51.15),
					colors = {
						text = {
							14,
							44,
							33
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.4,
								1,
								0.7569,
								1
							},
							c2 = {
								0.1647,
								0.5569,
								0.4078,
								1
							},
							c3 = {
								0.1647,
								0.5569,
								0.4078,
								1
							}
						},
						{
							thickness = 2.916666666666667,
							outline_color = {
								0.0549,
								0.1725,
								0.1333,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 40,
					line_height_extra = "2",
					fit_size = true,
					text = "heart of the forest",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_6",
					font_name = "fla_h",
					pos = v(-366.45, -336.2),
					scale = v(0.9999, 0.9999),
					size = v(702.9, 51.15),
					colors = {
						text = {
							14,
							44,
							33
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.5137,
								1,
								0.651,
								1
							},
							c2 = {
								0.251,
								0.5882,
								0.3059,
								1
							},
							c3 = {
								0.251,
								0.5882,
								0.3059,
								1
							}
						},
						{
							thickness = 2.916666666666667,
							outline_color = {
								0,
								0.2039,
								0.0941,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 40,
					line_height_extra = "2",
					fit_size = true,
					text = "heart of the forest",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_7",
					font_name = "fla_h",
					pos = v(-366.35, -335.9),
					scale = v(0.9999, 0.9999),
					size = v(702.9, 51.15),
					colors = {
						text = {
							49,
							44,
							61
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.9373,
								0.498,
								0.1608,
								1
							},
							c2 = {
								0.8,
								0.1059,
								0,
								1
							},
							c3 = {
								0.8,
								0.1059,
								0,
								1
							}
						},
						{
							thickness = 2.916666666666667,
							outline_color = {
								0.2431,
								0.0157,
								0.0157,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 40,
					line_height_extra = "2",
					fit_size = true,
					text = "heart of the forest",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_8",
					font_name = "fla_h",
					pos = v(-366.2, -335.35),
					scale = v(0.9999, 0.9999),
					size = v(702.9, 50.5),
					colors = {
						text = {
							235,
							52,
							41
						}
					},
					shaders = {
						"p_bands",
						"p_outline_tint"
					},
					shader_args = {
						{
							margin = 1,
							p1 = 0.5,
							p2 = 0.99,
							c1 = {
								0.9098,
								0.6,
								0.4941,
								1
							},
							c2 = {
								0.9216,
								0.2,
								0.1529,
								1
							},
							c3 = {
								0.9216,
								0.2,
								0.1529,
								1
							}
						},
						{
							thickness = 2.916666666666667,
							outline_color = {
								0.2078,
								0.0863,
								0.0667,
								1
							}
						}
					}
				},
				{
					id = "button_close_popup",
					focus_image_name = "level_select_button_ui_level_select_close_0003",
					class = "GG5Button",
					default_image_name = "level_select_button_ui_level_select_close_0001",
					pos = v(457.8, -246.25),
					anchor = v(38, 34.1)
				},
				{
					id = "button_fight_debug",
					focus_image_name = "level_select_button_auto_upgrades_0003",
					class = "GG5Button",
					default_image_name = "level_select_button_auto_upgrades_0001",
					pos = v(349.15, 290.35),
					anchor = v(168.65, 42.15)
				},
				{
					class = "GG5Button",
					template_name = "button_extra_enemies",
					id = "button_extra_enemies",
					pos = v(320, 260),
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_badge_icon_star_",
					id = "image_badges_star_02",
					pos = v(-58.7, -252.05),
					scale = v(1, 1),
					anchor = v(22.3, 22.55)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_badge_icon_star_",
					id = "image_badges_star_03",
					pos = v(-18.4, -252.05),
					scale = v(1, 1),
					anchor = v(22.3, 22.55)
				},
				{
					id = "image_badges_star_01",
					image_name = "level_select_image_ui_level_select_badge_icon_star_",
					class = "KImageView",
					pos = v(-98.9, -252.05),
					anchor = v(22.3, 22.55)
				},
				{
					id = "image_badges_heroic",
					image_name = "level_select_image_ui_level_select_badge_heroic_",
					class = "KImageView",
					pos = v(27.6, -251.95),
					anchor = v(25.5, 21.45)
				},
				{
					id = "image_badges_iron",
					image_name = "level_select_image_ui_level_select_badge_iron_",
					class = "KImageView",
					pos = v(70.9, -251.55),
					anchor = v(16.65, 20.85)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_badge_icon_star_",
					id = "image_badges_star_02_s16",
					pos = v(-18, -252.05),
					scale = v(1, 1),
					anchor = v(22.3, 22.55)
				},
				{
					class = "KImageView",
					image_name = "level_select_image_ui_level_select_badge_icon_star_",
					id = "image_badges_star_03_s16",
					pos = v(22.3, -252.05),
					scale = v(1, 1),
					anchor = v(22.3, 22.55)
				},
				{
					id = "image_badges_star_01_s16",
					image_name = "level_select_image_ui_level_select_badge_icon_star_",
					class = "KImageView",
					pos = v(-58.2, -252.05),
					anchor = v(22.3, 22.55)
				},
				{
					id = "group_mode_tooltip_2",
					class = "KView",
					pos = v(-474.85, 14.65),
					children = {
						{
							class = "KImageView",
							image_name = "level_select_image_hero_room_skill_tooltip_arrow_",
							id = "image_mode_tooltip_arrow",
							pos = v(-10.2, 58.7),
							scale = v(1, 1),
							anchor = v(10.4, 10.2)
						},
						{
							class = "GG59View",
							image_name = "level_select_9slice_hero_room_skill_tooltip_bg_",
							id = "hero_room_skill_tooltip_bg",
							pos = v(-10.2, 8.3),
							size = v(270.3516, 85.4761),
							anchor = v(135.1758, 42.738),
							slice_rect = r(20, 20, 40, 40)
						},
						{
							vertical_align = "middle",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 20,
							text = "Mode Locked",
							id = "label_mode_tooltip_title",
							fit_size = true,
							font_name = "fla_body",
							pos = v(-139.65, -36.9),
							size = v(258.9, 28.6),
							colors = {
								text = {
									153,
									0,
									0
								}
							}
						},
						{
							vertical_align = "middle",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "-2",
							font_size = 18,
							text = "Unlock this mode by completing this stage",
							id = "label_mode_tooltip_desc",
							font_name = "fla_body",
							pos = v(-139.8, -7.05),
							size = v(259.2, 54.6),
							colors = {
								text = {
									0,
									0,
									0
								}
							}
						}
					}
				},
				{
					id = "group_mode_tooltip_3",
					class = "KView",
					pos = v(-474.85, 102.5),
					children = {
						{
							class = "KImageView",
							image_name = "level_select_image_hero_room_skill_tooltip_arrow_",
							id = "image_mode_tooltip_arrow",
							pos = v(-10.2, 58.7),
							scale = v(1, 1),
							anchor = v(10.4, 10.2)
						},
						{
							class = "GG59View",
							image_name = "level_select_9slice_hero_room_skill_tooltip_bg_",
							id = "hero_room_skill_tooltip_bg",
							pos = v(-10.2, 8.3),
							size = v(270.3516, 85.4761),
							anchor = v(135.1758, 42.738),
							slice_rect = r(20, 20, 40, 40)
						},
						{
							vertical_align = "middle",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 20,
							text = "Mode Locked",
							id = "label_mode_tooltip_title",
							fit_size = true,
							font_name = "fla_body",
							pos = v(-139.65, -36.9),
							size = v(258.9, 28.6),
							colors = {
								text = {
									153,
									0,
									0
								}
							}
						},
						{
							vertical_align = "middle",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "-2",
							font_size = 18,
							text = "Unlock this mode by completing this stage",
							id = "label_mode_tooltip_desc",
							font_name = "fla_body",
							pos = v(-139.8, -7.05),
							size = v(259.2, 54.6),
							colors = {
								text = {
									0,
									0,
									0
								}
							}
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "right",
					line_height_extra = "1",
					font_size = 25,
					fit_size = true,
					text = "completed in veteran",
					class = "GG5Label",
					id = "label_completed_difficulty",
					font_name = "fla_body",
					pos = v(138.7, 199.85),
					scale = v(1, 1),
					size = v(319.45, 43),
					colors = {
						text = {
							255,
							212,
							64
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "left",
					text_key = "BRIEFING_LEVEL_WARNING",
					font_size = 23,
					line_height_extra = "1",
					fit_size = true,
					text = "This campaign has a high difficulty level",
					class = "GG5Label",
					id = "label_high_difficulty",
					font_name = "fla_body",
					pos = v(-351.2, 187.45),
					scale = v(1, 1),
					size = v(804.1, 41.65),
					colors = {
						text = {
							240,
							136,
							120
						}
					}
				},
				{
					id = "image_icon_high_difficulty",
					image_name = "level_select_image_difficulty_warning_icon_",
					class = "KImageView",
					pos = v(-383.8, 207.05),
					anchor = v(16.15, 14.05)
				}
			}
		}
	}
}