-- chunkname: @./kr5/data/kui_templates/group_heroroom.lua

return {
	class = "KView",
	children = {
		{
			class = "KView",
			id = "group_room_bg_desktop",
			transition = "down",
			pos = v(3, 236.05),
			UNLESS = ctx.is_mobile,
			children = {
				{
					class = "GG59View",
					image_name = "room_bg_desktop_9slice_bg_color_desktop_",
					id = "bg_color",
					pos = v(-4.1, 25.15),
					size = v(1473.6195, 1020.3274),
					anchor = v(736.1127, 510.1637),
					slice_rect = r(21.3, 20.45, 10, 10.05)
				},
				{
					class = "KView",
					id = "group_bg_textures",
					pos = v(-7.95, 8),
					scale = v(1.066, 0.9883),
					children = {
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_1",
							pos = v(-575, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_2",
							pos = v(-345, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_3",
							pos = v(-115, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_4",
							pos = v(115, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_5",
							pos = v(345, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_6",
							pos = v(575, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						}
					}
				},
				{
					class = "GG59View",
					image_name = "room_bg_desktop_9slice_bg_frame_desktop_",
					id = "bg_frame",
					pos = v(-13.75, -34.45),
					size = v(1560.5484, 1103.9091),
					anchor = v(765.8341, 479.1643),
					slice_rect = r(100.4, 75.25, 22.3, 15.4)
				},
				{
					id = "frame_top_right_corner",
					class = "KImageView",
					image_name = "room_bg_desktop_image_bg_frame_topcorner_desktop_",
					hidden = true,
					pos = v(697.65, -473.55),
					anchor = v(9.9, 29.15)
				},
				{
					class = "GG5Button",
					focus_image_name = "room_bg_desktop_button_bg_close_desktop_0003",
					id = "button_close_popup",
					default_image_name = "room_bg_desktop_button_bg_close_desktop_0001",
					pos = v(720.7, -479.3),
					scale = v(1, 1),
					anchor = v(42.7, 49.45)
				},
				{
					id = "group_rivets_left",
					class = "KView",
					pos = v(-748.75, 276.8),
					children = {
						{
							image_name = "room_bg_desktop_image_bg_rivet_desktop_",
							class = "KImageView",
							pos = v(8.65, -456.45),
							scale = v(0.7772, 0.7772),
							anchor = v(11.1, 9.6)
						},
						{
							image_name = "room_bg_desktop_image_bg_rivet_desktop_",
							class = "KImageView",
							pos = v(8.65, -10.5),
							scale = v(0.7772, 0.7772),
							anchor = v(11.1, 9.6)
						}
					}
				},
				{
					id = "group_rivets_right",
					class = "KView",
					pos = v(728.15, 276.8),
					children = {
						{
							image_name = "room_bg_desktop_image_bg_rivet_desktop_",
							class = "KImageView",
							pos = v(8.65, -456.45),
							scale = v(0.7772, 0.7772),
							anchor = v(11.1, 9.6)
						},
						{
							image_name = "room_bg_desktop_image_bg_rivet_desktop_",
							class = "KImageView",
							pos = v(8.65, -9.25),
							scale = v(0.7772, 0.7772),
							anchor = v(11.1, 9.6)
						}
					}
				},
				{
					id = "group_rivets_bottom",
					class = "KView",
					pos = v(-460.3, 543.5),
					children = {
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(-146.55, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(-45.75, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(55.05, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(155.85, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(256.65, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(357.45, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(458.25, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(559.05, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(659.85, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(760.65, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(861.45, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(962.25, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(1063.05, -6.45),
							anchor = v(5.75, 6.4)
						}
					}
				},
				{
					class = "GG59View",
					image_name = "room_bg_desktop_9slice_bg_title_desktop_",
					id = "title_bg",
					pos = v(-6.6, -540),
					size = v(556.9127, 73.5989),
					anchor = v(273.4073, 32.5995),
					slice_rect = r(99.95, 3.05, 16.8, 24.75)
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 50,
					line_height_extra = "1",
					fit_size = true,
					text = "HEROES",
					text_key = "MAP_BUTTON_HERO_ROOM",
					class = "GG5ShaderLabel",
					id = "title_text",
					font_name = "fla_h",
					pos = v(-230.6, -565.05),
					scale = v(1, 1),
					size = v(460, 68.15),
					colors = {
						text = {
							85,
							186,
							255
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
								0.4745,
								1,
								1,
								1
							},
							c2 = {
								0.3333,
								0.7255,
								0.9961,
								1
							},
							c3 = {
								0.3333,
								0.7255,
								0.9961,
								1
							}
						},
						{
							thickness = 4.166666666666667,
							outline_color = {
								0.0745,
								0.2039,
								0.2784,
								1
							}
						}
					}
				}
			}
		},
		{
			class = "KView",
			transition_delay = 0.15,
			id = "group_hero_stats",
			transition = "scale",
			pos = v(-489.75, 408.85),
			children = {
				{
					image_name = "hero_room_9slice_stats_bg_",
					class = "GG59View",
					pos = v(1.5, 14.15),
					size = v(265.2258, 336.5391),
					anchor = v(132.5895, 168.1943),
					slice_rect = r(70.95, 27.9, 141.95, 55.95)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_bars_bg_",
					pos = v(6.3, -84.1),
					anchor = v(109.85, 22.1)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_bars_bg_",
					pos = v(6.3, -17.95),
					anchor = v(109.85, 22.1)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_bars_bg_",
					pos = v(6.3, 48.25),
					anchor = v(109.85, 22.1)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_bars_bg_",
					pos = v(6.3, 114.45),
					anchor = v(109.85, 22.1)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_stats_bg_",
					pos = v(-140.65, -199.1),
					anchor = v(4.4, 4.4)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_stats_bottom_",
					pos = v(-140.65, -199.1),
					anchor = v(-6.05, -376.2)
				},
				{
					id = "hero_stat_bar_1",
					image_name = "hero_room_image_stat_bar_",
					class = "KImageView",
					pos = v(-59.2, -84.25),
					anchor = v(0.1, 5.2)
				},
				{
					id = "hero_stat_bar_2",
					image_name = "hero_room_image_stat_bar_",
					class = "KImageView",
					pos = v(-59.2, -18.3),
					anchor = v(0.1, 5.2)
				},
				{
					id = "hero_stat_bar_3",
					image_name = "hero_room_image_stat_bar_",
					class = "KImageView",
					pos = v(-59.2, 48.3),
					anchor = v(0.1, 5.2)
				},
				{
					id = "hero_stat_bar_4",
					image_name = "hero_room_image_stat_bar_",
					class = "KImageView",
					pos = v(-59.2, 114.05),
					anchor = v(0.1, 5.2)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_xp_bar_",
					id = "hero_xp_bar",
					pos = v(-67.4, -171.4),
					scale = v(1, 1),
					anchor = v(-0.05, 0.1)
				},
				{
					vertical_align = "top",
					text_align = "center",
					class = "GG5Label",
					line_height_extra = "2",
					font_size = 32,
					text = "10",
					id = "label_hero_level",
					fit_size = true,
					font_name = "fla_numbers_2",
					pos = v(-129.2, -179.05),
					size = v(48.25, 32.9),
					colors = {
						text = {
							221,
							232,
							236
						}
					}
				},
				{
					id = "hero_stat_icon_1",
					image_name = "hero_room_image_stat_icon_",
					class = "KImageView",
					pos = v(-82.2, -84.4),
					anchor = v(21.7, 22.4)
				},
				{
					id = "hero_stat_icon_2",
					image_name = "hero_room_image_stat_icon_",
					class = "KImageView",
					pos = v(-82.2, -16.8),
					anchor = v(21.7, 22.4)
				},
				{
					id = "hero_stat_icon_3",
					image_name = "hero_room_image_stat_icon_",
					class = "KImageView",
					pos = v(-82.2, 49.55),
					anchor = v(21.7, 22.4)
				},
				{
					id = "hero_stat_icon_4",
					image_name = "hero_room_image_stat_icon_",
					class = "KImageView",
					pos = v(-82.2, 115.85),
					anchor = v(21.7, 22.4)
				}
			}
		},
		{
			class = "KView",
			transition_delay = 0.1,
			id = "group_hero_info_panel",
			transition = "down",
			pos = v(34.65, 171.45),
			children = {
				{
					image_name = "hero_room_9slice_info_bg_",
					class = "GG59View",
					pos = v(5.05, 18.6),
					size = v(592.8784, 281.6382),
					anchor = v(0, 0),
					slice_rect = r(15.2, 15, 9.75, 10.2)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_info_top_bar_",
					pos = v(302.65, 168.75),
					anchor = v(300.65, 155.1)
				},
				{
					vertical_align = "middle",
					text_align = "left",
					text_key = "HERO_ROOM_HERO_NAME",
					font_size = 27,
					line_height_extra = "2",
					text = "Vesper",
					class = "GG5Label",
					id = "label_hero_name",
					fit_size = true,
					font_name = "fla_h",
					pos = v(26.1, 43.75),
					size = v(543.45, 41.4),
					colors = {
						text = {
							255,
							212,
							64
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					text_key = "HERO_ROOM_HERO_DESC",
					font_size = 22,
					line_height_extra = "0",
					text = "An old wizard king that  refused to die at any cost. after learning the secret arts of the necromancy he became an undead by his own power. Now he joins teh Veznan army to become even stronger.necromancy he became an undead by his own power. Now he joins teh Veznan army ",
					class = "GG5Label",
					id = "label_hero_desc",
					fit_size = true,
					font_name = "fla_body",
					pos = v(26.2, 84.8),
					size = v(555.55, 202.9),
					colors = {
						text = {
							203,
							209,
							196
						}
					}
				},
				{
					class = "KView",
					pos = v(260.65, -2.2),
					children = {
						{
							id = "image_points_bg",
							image_name = "hero_room_image_points_bg_",
							class = "KImageView",
							pos = v(-0.2, 0.05),
							anchor = v(10, 7.05)
						},
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "2",
							font_size = 28,
							text = "20",
							id = "label_heropoints",
							fit_size = true,
							font_name = "fla_numbers",
							pos = v(47.75, 4.55),
							size = v(45.7, 38.5),
							colors = {
								text = {
									255,
									248,
									0
								}
							}
						}
					}
				}
			}
		},
		{
			class = "KView",
			transition_delay = 0.2,
			id = "group_hero_room_skills",
			transition = "up",
			pos = v(313.1, 557.2),
			children = {
				{
					class = "HeroSkillItemView",
					template_name = "button_hero_skill",
					pos = v(-220.75, -10.2)
				},
				{
					class = "HeroSkillItemView",
					template_name = "button_hero_skill",
					pos = v(-99.55, -10.2)
				},
				{
					class = "HeroSkillItemView",
					template_name = "button_hero_skill",
					pos = v(21.65, -10.2)
				},
				{
					class = "HeroSkillItemView",
					template_name = "button_hero_skill",
					pos = v(142.85, -10.2)
				},
				{
					class = "HeroSkillItemView",
					template_name = "button_hero_skill_ultimate",
					pos = v(267.3, -9.8)
				}
			}
		},
		{
			id = "hero_room_skill_tooltip",
			class = "KView",
			pos = v(344, 397.75),
			children = {
				{
					class = "KImageView",
					image_name = "hero_room_image_hero_room_skill_tooltip_arrow_",
					id = "hero_room_skill_tooltip_arrow_5",
					pos = v(235.75, 70.15),
					scale = v(1, 1),
					anchor = v(10.4, 0)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_hero_room_skill_tooltip_arrow_",
					id = "hero_room_skill_tooltip_arrow_4",
					pos = v(112.35, 70.15),
					scale = v(1, 1),
					anchor = v(10.4, 0)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_hero_room_skill_tooltip_arrow_",
					id = "hero_room_skill_tooltip_arrow_3",
					pos = v(-10.15, 70.15),
					scale = v(1, 1),
					anchor = v(10.4, 0)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_hero_room_skill_tooltip_arrow_",
					id = "hero_room_skill_tooltip_arrow_2",
					pos = v(-132.8, 70.15),
					scale = v(1, 1),
					anchor = v(10.4, 0)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_hero_room_skill_tooltip_arrow_",
					id = "hero_room_skill_tooltip_arrow_1",
					pos = v(-255, 70.15),
					scale = v(1, 1),
					anchor = v(10.4, 0)
				},
				{
					class = "GG59View",
					image_name = "hero_room_9slice_hero_room_skill_tooltip_bg_",
					id = "hero_room_skill_tooltip_bg",
					pos = v(-7.4, -3.85),
					size = v(595.9998, 150),
					anchor = v(297.9999, 75),
					slice_rect = r(20, 20, 40, 40)
				},
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 23,
					text = "Inspiring Leader",
					id = "label_hero_room_skill_tooltip_title",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-289.55, -70.5),
					size = v(564.75, 32.35),
					colors = {
						text = {
							0,
							102,
							153
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 22,
					text = "Summon 2 goblins to the battlefield. Each goblin gains power with the hero.",
					id = "label_hero_room_skill_tooltip_desc",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-288.7, -33.4),
					size = v(563.15, 94.05),
					colors = {
						text = {
							76,
							70,
							70
						}
					}
				}
			}
		},
		{
			class = "GG5Button",
			transition_delay = 0.15,
			id = "hero_room_reset_button",
			template_name = "button_hero_room_small",
			transition = "up",
			pos = v(298.05, 677.35),
			scale = v(1, 1)
		},
		{
			class = "GG5Button",
			transition_delay = 0.15,
			id = "hero_room_done_button",
			template_name = "button_hero_room_small",
			transition = "up",
			pos = v(533.25, 677.35),
			scale = v(1, 1)
		},
		{
			class = "KView",
			template_name = "group_hero_portrait_big",
			id = "group_hero_portrait_big",
			transition = "up",
			pos = v(-328.95, 149.55)
		},
		{
			id = "hero_room_roster_sel_overlay",
			class = "KView",
			pos = v(-861.1, -17.8),
			anchor = v(0, 0),
			size = v(1728, 768)
		},
		{
			class = "KView",
			id = "group_hero_roster_sel",
			transition = "down",
			pos = v(-632.15, -0.2),
			WHEN = ctx.is_mobile,
			children = {
				{
					image_name = "hero_room_image_roster_sel_bg_",
					class = "KImageView",
					pos = v(105.65, 77.35),
					scale = v(1, 1),
					anchor = v(113.25, 79.3)
				},
				{
					vertical_align = "top",
					text_align = "center",
					text_key = "HERO_ROOM_EQUIPPED_HEROES",
					font_size = 20,
					line_height_extra = "0",
					text = "Equipped Heroes",
					class = "GG5Label",
					id = "label_equipped_heroes",
					fit_size = true,
					font_name = "fla_body",
					pos = v(13.75, 152.7),
					size = v(255.45, 28.6),
					colors = {
						text = {
							255,
							255,
							255
						}
					}
				},
				{
					id = "button_hero_roster_sel_01",
					class = "HeroSliderItemView",
					template_name = "button_hero_roster_thumb",
					pos = v(81.15, 79.95)
				},
				{
					id = "button_hero_roster_sel_02",
					class = "HeroSliderItemView",
					template_name = "button_hero_roster_thumb",
					pos = v(202.8, 79.95)
				}
			}
		},
		{
			class = "KView",
			id = "group_hero_roster",
			transition = "down",
			pos = v(-330.5, 10.35),
			WHEN = ctx.is_mobile,
			children = {
				{
					image_name = "hero_room_9slice_image_roster_bg_",
					class = "GG59View",
					pos = v(-70.5, 12.5),
					size = v(946.6381, 119.9185),
					anchor = v(-80.7632, 0.1045),
					slice_rect = r(21.3, 19.05, 19, 18.75)
				},
				{
					class = "KImageView",
					image_name = "hero_room_image_roster_shadow_",
					pos = v(-224.85, 0.75),
					anchor = v(-1099.85, -11.85)
				},
				{
					class = "KView"
				},
				{
					image_name = "hero_room_image_roster_frame_",
					class = "KImageView",
					anchor = v(32, 8.15)
				},
				{
					id = "hero_room_heroes",
					class = "KView",
					pos = v(25.1, 16.4),
					anchor = v(0, 3.45),
					size = v(927.5, 114.85)
				}
			}
		},
		{
			class = "KView",
			id = "group_hero_roster_sel",
			transition = "down",
			pos = v(-606.5, -71.9),
			UNLESS = ctx.is_mobile,
			scale = v(0.829, 0.829),
			children = {
				{
					class = "KView",
					pos = v(25.25, 43.05),
					children = {
						{
							image_name = "hero_room_9slice_shadow_roster_",
							class = "GG59View",
							pos = v(0, -0.05),
							size = v(224.4486, 354.7395),
							anchor = v(112.2243, 177.2775),
							slice_rect = r(50.6, 29.95, 23, 42.45)
						},
						{
							image_name = "hero_room_9slice_roster_bg_desktop_",
							class = "GG59View",
							pos = v(1.9, -3.95),
							size = v(177.7859, 327.4052),
							anchor = v(88.9934, 163.8876),
							slice_rect = r(17.1, 17.2, 9.9, 10)
						},
						{
							image_name = "hero_room_image_rosterframe2_r_",
							class = "KImageView",
							r = 1.5708,
							pos = v(81.8, -3),
							anchor = v(146.9, -1.45)
						},
						{
							image_name = "hero_room_image_rosterframe2_l_",
							class = "KImageView",
							r = 1.5708,
							pos = v(-89.9, -6.65),
							anchor = v(150.1, 8.05)
						},
						{
							image_name = "hero_room_image_rosterframe_t_",
							class = "GG59View",
							pos = v(2.15, -169.4),
							size = v(157.7771, 13.8),
							anchor = v(81.1669, 6.9),
							slice_rect = r(12.25, 4.15, 3.55, 5.55)
						},
						{
							image_name = "hero_room_image_rosterframe_b_",
							class = "GG59View",
							pos = v(0.9, 162.1),
							size = v(139.8813, 13.1),
							anchor = v(69.9406, 6.55),
							slice_rect = r(4.95, 3.25, 9.9, 6.6)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_corner_01_",
							pos = v(-80.05, -159.75),
							anchor = v(17.1, 17.05)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_corner_02_",
							pos = v(79.75, -159.85),
							anchor = v(18.15, 17)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_corner_03_",
							pos = v(79.95, 152.95),
							anchor = v(17.85, 17)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_corner_04_",
							pos = v(-79.45, 152.6),
							anchor = v(17.85, 17)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_rivet_roster_",
							pos = v(-90.5, 79.35),
							anchor = v(6.05, 6.3)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_rivet_roster_",
							pos = v(-90.5, -102),
							anchor = v(6.05, 6.3)
						}
					}
				},
				{
					id = "button_hero_roster_sel_01",
					class = "HeroSliderItemView",
					template_name = "button_hero_roster_thumb_desktop",
					pos = v(25.95, -38.5)
				},
				{
					id = "button_hero_roster_sel_02",
					class = "HeroSliderItemView",
					template_name = "button_hero_roster_thumb_desktop",
					pos = v(25.9, 116.05)
				},
				{
					vertical_align = "top",
					text_align = "center",
					text_key = "HERO_ROOM_EQUIPPED_HEROES",
					font_size = 20,
					line_height_extra = "0",
					text = "Equipped Heroes",
					class = "GG5Label",
					id = "label_equipped_heroes_desktop",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-102.25, 213.7),
					size = v(255.45, 28.6),
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
			class = "KView",
			id = "group_hero_roster",
			transition = "down",
			pos = v(-669.8, -180.75),
			UNLESS = ctx.is_mobile,
			scale = v(0.829, 0.829),
			children = {
				{
					image_name = "hero_room_9slice_roster_bg_desktop_",
					class = "GG59View",
					pos = v(923.15, 171.2),
					size = v(1385.1338, 327.4052),
					anchor = v(693.3495, 163.8876),
					slice_rect = r(17.1, 17.2, 9.9, 10)
				},
				{
					class = "KView",
					pos = v(-0.7, -0.5),
					children = {
						{
							image_name = "hero_room_9slice_shadow_roster_",
							class = "GG59View",
							pos = v(924.5, 173.95),
							size = v(1434.3919, 352.1764),
							anchor = v(717.196, 175.9966),
							slice_rect = r(50.6, 29.95, 23, 42.45)
						},
						{
							image_name = "hero_room_image_rosterframe2_l_",
							class = "KImageView",
							r = 1.5707,
							pos = v(228.2, 170.25),
							anchor = v(150.1, 8.05)
						},
						{
							image_name = "hero_room_image_rosterframe2_r_",
							class = "KImageView",
							r = 1.5707,
							pos = v(1609.55, 169.85),
							anchor = v(146.9, -1.45)
						},
						{
							image_name = "hero_room_image_rosterframe_t_",
							class = "GG59View",
							pos = v(944.9, 5.45),
							size = v(1349.6438, 13.8),
							anchor = v(694.3113, 6.9),
							slice_rect = r(12.25, 4.15, 3.55, 5.55)
						},
						{
							image_name = "hero_room_image_rosterframe_b_",
							class = "GG59View",
							pos = v(925.65, 336.95),
							size = v(1352.1512, 13.1),
							anchor = v(676.0756, 6.55),
							slice_rect = r(4.95, 3.25, 9.9, 6.6)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_corner_01_",
							pos = v(238.25, 14.95),
							anchor = v(17.1, 17.05)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_corner_02_",
							pos = v(1607.65, 14.85),
							anchor = v(18.15, 17)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_corner_03_",
							pos = v(1607.95, 327.7),
							anchor = v(17.85, 17)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_corner_04_",
							pos = v(238.05, 327.1),
							anchor = v(17.85, 17)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_rivet_roster_",
							pos = v(1617.7, 262.85),
							anchor = v(6.05, 6.3)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_rivet_roster_",
							pos = v(1617.7, 81.5),
							anchor = v(6.05, 6.3)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_link_desktop_",
							pos = v(207.45, 95.15),
							anchor = v(12.8, 18.25)
						},
						{
							class = "KImageView",
							image_name = "hero_room_image_roster_link_desktop_",
							pos = v(207.45, 253.2),
							anchor = v(12.8, 18.25)
						}
					}
				},
				{
					id = "hero_room_heroes",
					class = "KView",
					pos = v(771.6, 171.1),
					children = {
						{
							id = "button_hero_roster_01",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(-455.65, -77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_02",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(-303.75, -77.6),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_03",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(-151.95, -77.6),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_04",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(-0.05, -77.6),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_05",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(151.75, -77.6),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_06",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(303.65, -77.6),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_07",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(455.65, -77.6),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_10",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(-455.65, 77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_11",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(-303.75, 77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_12",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(-151.95, 77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_13",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(-0.05, 77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_14",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(151.75, 77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_15",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(303.65, 77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_16",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(455.65, 77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_08",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(606.35, -77.6),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_17",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(606.35, 77.65),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_09",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(757.75, -77.6),
							anchor = v(68, 66.9)
						},
						{
							id = "button_hero_roster_18",
							image_name = "hero_room_image_roster_thumb_empty_",
							class = "KImageView",
							pos = v(757.75, 77.65),
							anchor = v(68, 66.9)
						}
					}
				}
			}
		}
	}
}
