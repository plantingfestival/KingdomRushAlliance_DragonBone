-- chunkname: @./kr5/data/kui_templates/achievements_room.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			class = "KView",
			id = "achievements_room_desktop",
			pos = v(ctx.sw / 2, 384),
			UNLESS = ctx.is_mobile,
			children = {
				{
					class = "KView",
					id = "group_room_bg_desktop",
					transition = "down",
					pos = v(-0.4, -20.55),
					UNLESS = ctx.is_mobile,
					children = {
						{
							class = "GG59View",
							image_name = "room_bg_desktop_9slice_bg_color_desktop_",
							id = "bg_color",
							pos = v(1.05, 22),
							size = v(1723.8361, 961.8982),
							anchor = v(861.1026, 480.9491),
							slice_rect = r(21.3, 20.45, 10, 10.05)
						},
						{
							class = "KView",
							id = "group_bg_textures",
							pos = v(-1.55, 8.35),
							scale = v(1.2486, 0.9335),
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
							pos = v(-13.35, -22.7),
							size = v(1822.6086, 998.784),
							anchor = v(894.4393, 433.5335),
							slice_rect = r(100.4, 75.25, 22.3, 15.4)
						},
						{
							id = "frame_top_right_corner",
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_frame_topcorner_desktop_",
							hidden = true,
							pos = v(834.9, -433.4),
							anchor = v(9.9, 29.15)
						},
						{
							class = "GG5Button",
							focus_image_name = "room_bg_desktop_button_bg_close_desktop_0003",
							id = "button_close_popup",
							default_image_name = "room_bg_desktop_button_bg_close_desktop_0001",
							pos = v(855.65, -430.85),
							scale = v(1, 1),
							anchor = v(42.7, 49.45)
						},
						{
							id = "group_rivets_left",
							class = "KView",
							pos = v(-876.25, 256.45),
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
							pos = v(861.85, 256.85),
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
							pos = v(-460.3, 495.15),
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
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(-246.85, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(-347.6, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(1163.35, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(1263.7, -6.45),
									anchor = v(5.75, 6.4)
								}
							}
						},
						{
							id = "pager",
							class = "GG5Pager",
							pos = v(-736.95, 550.3),
							children = {
								{
									class = "GG59View",
									image_name = "room_bg_desktop_9slice_bg_pager_desktop_",
									id = "pager_bg",
									pos = v(-64.9, -28),
									size = v(129.9991, 67.6),
									anchor = v(0.1139, 0.9),
									slice_rect = r(52.95, -2.8, 11.8, 3)
								},
								{
									id = "button_page_01",
									class = "GG5ToggleButton",
									template_name = "toggle_bg_pager_desktop",
									pos = v(-1, -12.55)
								}
							}
						},
						{
							class = "GG59View",
							image_name = "room_bg_desktop_9slice_bg_title_desktop_",
							id = "title_bg",
							pos = v(-6.6, -480),
							size = v(601.823, 73.5989),
							anchor = v(295.4553, 32.5995),
							slice_rect = r(99.95, 3.05, 16.8, 24.75)
						},
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 50,
							line_height_extra = "1",
							text_key = "ACHIEVEMENTS",
							text = "ACHIEVEMENTS",
							class = "GG5ShaderLabel",
							id = "title_text",
							font_name = "fla_h",
							pos = v(-242.65, -494),
							scale = v(1, 1),
							size = v(481.3, 51),
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
					id = "achievements_page_desktop",
					class = "KView",
					scale = v(1.0499, 1.0499),
					children = {
						{
							id = "ach_01",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(-537.1, -314.5)
						},
						{
							id = "ach_05",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(2.9, -314.5)
						},
						{
							id = "ach_09",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(542.9, -314.5)
						},
						{
							id = "ach_03",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(-537.1, 105.5)
						},
						{
							id = "ach_04",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(-537.1, 315.5)
						},
						{
							id = "ach_02",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(-537.1, -104.5)
						},
						{
							id = "ach_07",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(2.9, 105.5)
						},
						{
							id = "ach_08",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(2.9, 315.5)
						},
						{
							id = "ach_06",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(2.9, -104.5)
						},
						{
							id = "ach_11",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(542.9, 105.5)
						},
						{
							id = "ach_12",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(542.9, 315.5)
						},
						{
							id = "ach_10",
							class = "KView",
							template_name = "group_achievement_room_achievement",
							pos = v(542.9, -104.5)
						}
					}
				}
			}
		},
		{
			class = "KView",
			id = "group_achievements_room_cards_container",
			transition = "left",
			pos = v(508.25, 330.3),
			children = {
				{
					id = "group_achievement_room_achievement_disabled",
					class = "KView",
					template_name = "group_achievement_room_achievement_disabled",
					pos = v(1.65, -1.6)
				},
				{
					id = "group_achievement_room_claim",
					class = "KView",
					template_name = "group_achievement_room_claim",
					pos = v(3.1, 203.6)
				},
				{
					id = "group_achievement_room_achievement",
					class = "KView",
					template_name = "group_achievement_room_achievement",
					pos = v(3.05, -203)
				}
			}
		},
		{
			class = "KView",
			transition_delay = 0.25,
			id = "group_achievements_room_done",
			transition = "up",
			pos = v(ctx.sw / 2, 0),
			children = {
				{
					default_image_name = "achievements_room_button_confirm_yes_bg_0001",
					focus_image_name = "achievements_room_button_confirm_yes_bg_0003",
					class = "GG5Button",
					id = "button_achievements_room_confirm_ok",
					pos = v(525, 696),
					scale = v(1, 1),
					image_offset = v(-108.1, -48.85),
					hit_rect = r(-108.1, -48.85, 219, 102),
					children = {
						{
							vertical_align = "middle-caps",
							text_align = "center",
							font_size = 35,
							fit_size = true,
							line_height_extra = "2",
							text = "DONE",
							class = "GG5ShaderLabel",
							id = "label_button_ok",
							font_name = "fla_h",
							pos = v(-76.15, -25.8),
							scale = v(1, 1),
							size = v(149.95, 47.85),
							colors = {
								text = {
									26,
									51,
									83
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 3.3333333333333335,
									outline_color = {
										0,
										0.8275,
										0.9961,
										1
									}
								}
							}
						}
					}
				}
			}
		},
		{
			id = "group_achievements_room",
			class = "KView",
			pos = v(ctx.sw / 2, 0),
			children = {
				{
					focus_image_name = "achievements_room_button_achievement_room_amount_indicator_left_0003",
					class = "GG5Button",
					id = "achievement_room_amount_indicator_left_button",
					default_image_name = "achievements_room_button_achievement_room_amount_indicator_left_0001",
					pos = v(-542.4, 317),
					image_offset = v(-75.6, -46.65),
					hit_rect = r(-75.6, -46.65, 116, 96),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 45,
							fit_size = true,
							line_height_extra = "2",
							text = "2",
							class = "GG5ShaderLabel",
							id = "label_achievement_room_amount_indicator",
							font_name = "fla_numbers_2",
							pos = v(-40.95, -23.5),
							scale = v(1, 1),
							size = v(65.3, 44.65),
							colors = {
								text = {
									231,
									244,
									251
								}
							},
							shaders = {
								"p_outline_tint",
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 1.6666666666666667,
									outline_color = {
										0,
										0.2667,
										0.4745,
										1
									}
								},
								{
									thickness = 1.6666666666666667,
									outline_color = {
										0,
										0.5882,
										1,
										1
									}
								}
							}
						}
					}
				},
				{
					focus_image_name = "achievements_room_button_achievement_room_amount_indicator_0003",
					class = "GG5Button",
					id = "achievement_room_amount_indicator_button",
					default_image_name = "achievements_room_button_achievement_room_amount_indicator_0001",
					pos = v(613.05, 317),
					image_offset = v(-56.15, -46.65),
					hit_rect = r(-56.15, -46.65, 116, 96),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 45,
							fit_size = true,
							line_height_extra = "2",
							text = "2",
							class = "GG5ShaderLabel",
							id = "label_achievement_room_amount_indicator",
							font_name = "fla_numbers_2",
							pos = v(-40.95, -23.95),
							scale = v(1, 1),
							size = v(65.3, 44.65),
							colors = {
								text = {
									231,
									244,
									251
								}
							},
							shaders = {
								"p_outline_tint",
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 1.6666666666666667,
									outline_color = {
										0,
										0.2667,
										0.4745,
										1
									}
								},
								{
									thickness = 1.6666666666666667,
									outline_color = {
										0,
										0.5882,
										1,
										1
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
