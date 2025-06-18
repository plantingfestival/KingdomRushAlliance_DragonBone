-- chunkname: @./kr5/data/kui_templates/group_tower_room.lua

return {
	class = "KView",
	children = {
		{
			class = "KView",
			id = "group_room_bg_desktop",
			transition = "down",
			pos = v(1.15, 224.65),
			UNLESS = ctx.is_mobile,
			children = {
				{
					class = "GG59View",
					image_name = "room_bg_desktop_9slice_bg_color_desktop_",
					id = "bg_color",
					pos = v(-14.1, 27.15),
					size = v(1425.0428, 1020.3274),
					anchor = v(711.8473, 510.1637),
					slice_rect = r(21.3, 20.45, 10, 10.05)
				},
				{
					id = "group_bg_textures",
					class = "KView",
					pos = v(-14.1, 15.9),
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
					pos = v(-13.75, -26.45),
					size = v(1497.771, 1094.063),
					anchor = v(735.0263, 474.8905),
					slice_rect = r(100.4, 75.25, 22.3, 15.4)
				},
				{
					id = "frame_top_right_corner",
					class = "KImageView",
					image_name = "room_bg_desktop_image_bg_frame_topcorner_desktop_",
					hidden = true,
					pos = v(665.6, -471.55),
					anchor = v(9.9, 29.15)
				},
				{
					class = "GG5Button",
					focus_image_name = "room_bg_desktop_button_bg_close_desktop_0003",
					id = "button_close_popup",
					default_image_name = "room_bg_desktop_button_bg_close_desktop_0001",
					pos = v(689.45, -471.3),
					scale = v(1, 1),
					anchor = v(42.7, 49.45)
				},
				{
					id = "group_rivets_left",
					class = "KView",
					pos = v(-720.7, 278.8),
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
					pos = v(694.8, 278.8),
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
					pos = v(-460.3, 545.5),
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
					pos = v(-6.6, -524),
					size = v(556.9127, 73.5989),
					anchor = v(273.4073, 32.5995),
					slice_rect = r(99.95, 3.05, 16.8, 24.75)
				},
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 50,
					line_height_extra = "1",
					text_key = "MAP_BUTTON_TOWER_ROOM",
					text = "TOWERS",
					class = "GG5ShaderLabel",
					id = "title_text",
					font_name = "fla_h",
					pos = v(-236.6, -542.4),
					scale = v(1, 1),
					size = v(460, 62.45),
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
			template_name = "group_tower_info_panel",
			class = "KView",
			transition_delay = 0.1,
			id = "group_tower_info_panel",
			transition = "down",
			pos = v(167.1, 162.55)
		},
		{
			template_name = "group_title_skills",
			class = "KView",
			transition_delay = 0.1,
			id = "group_title_skills",
			transition = "down",
			pos = v(169.1, 441.3)
		},
		{
			template_name = "group_tower_skills",
			class = "KView",
			transition_delay = 0.15,
			id = "group_tower_skills",
			transition = "up",
			pos = v(248.75, 497.65)
		},
		{
			class = "KView",
			template_name = "group_tower_roster",
			id = "group_tower_roster",
			transition = "down",
			pos = v(-635.2, -0.8),
			WHEN = ctx.is_mobile
		},
		{
			template_name = "group_tower_roster_desktop",
			class = "KView",
			id = "group_tower_roster",
			transition = "down",
			pos = v(-632.5, -209.85),
			UNLESS = ctx.is_mobile
		},
		{
			template_name = "group_title_equipped_towers",
			class = "KView",
			transition_delay = 0.15,
			id = "MovieClip219",
			transition = "scale",
			pos = v(-442.8, 196.15)
		},
		{
			class = "KView",
			id = "group_tower_portrait_big",
			transition = "up",
			pos = v(-213.15, 142.45),
			children = {
				{
					id = "tower_room_portrait",
					class = "KImageView",
					pos = v(169.25, 275.2),
					anchor = v(160, 240)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_tower_room_portrait_flash_",
					id = "tower_room_portrait_flash",
					pos = v(14.65, 33),
					scale = v(6.253, 9.5759),
					anchor = v(0, 0)
				},
				{
					id = "image_tower_portrait_frame",
					image_name = "tower_room_image_portrait_frame_",
					class = "KImageView",
					pos = v(171, 302.2),
					anchor = v(176, 288.2)
				},
				{
					class = "KView",
					id = "group_sale_label_big",
					pos = v(255.35, 103.5),
					WHEN = ctx.is_mobile,
					children = {
						{
							image_name = "tower_room_image_sale_bg_big_",
							class = "KImageView",
							pos = v(-62.1, 62.7),
							scale = v(1, 1),
							anchor = v(20.65, 146.1)
						},
						{
							vertical_align = "middle-caps",
							line_height_extra = "2",
							text = "descuento",
							class = "GG5ShaderLabel",
							text_key = "DISCOUNT",
							fit_size = true,
							font_name = "fla_h",
							r = -0.7701,
							font_size = 28,
							text_align = "center",
							id = "label_discount",
							pos = v(9.1, -48.2),
							scale = v(0.8836, 0.8836),
							size = v(144.2, 38.75),
							colors = {
								text = {
									244,
									227,
									52
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
							anchor = v(43.95, 4.75)
						},
						{
							line_height_extra = "0",
							vertical_align = "top",
							text = "50%",
							class = "GG5ShaderLabel",
							fit_size = true,
							font_name = "fla_numbers_2",
							r = -0.7613,
							font_size = 38,
							text_align = "center",
							id = "label_sale_big",
							pos = v(50.45, -59.15),
							scale = v(0.8584, 0.8584),
							size = v(84.05, 32.85),
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
							anchor = v(37.1, 0.75)
						}
					}
				},
				{
					id = "button_tower_room_big_disabled",
					class = "GG5Button",
					template_name = "button_tower_room_big_disabled",
					pos = v(171, 518.9)
				},
				{
					class = "GG5Button",
					template_name = "button_tower_room_big_locked",
					id = "button_tower_room_big_locked",
					pos = v(170.3, 519.15),
					scale = v(1, 1)
				},
				{
					class = "GG5Button",
					template_name = "button_tower_room_big_buy",
					id = "button_tower_room_big_buy",
					pos = v(169.3, 519),
					scale = v(1, 1)
				},
				{
					class = "GG5Button",
					template_name = "button_tower_room_big_select",
					id = "button_tower_room_big_select",
					pos = v(171.1, 518.85),
					scale = v(1, 1)
				},
				{
					id = "image_towerroom_badside",
					image_name = "tower_room_image_towerroom_badside_",
					class = "KImageView",
					pos = v(37.95, 21.5),
					anchor = v(20.3, 15.65)
				},
				{
					id = "image_towerroom_goodside",
					image_name = "tower_room_image_towerroom_goodside_",
					class = "KImageView",
					pos = v(37.95, 21.5),
					anchor = v(20.3, 15.65)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_dlc_dwarf_badge_big_",
					id = "image_dlc_1_badge_big",
					pos = v(284.8, 47.9),
					scale = v(1, 1),
					anchor = v(51.75, 31.2)
				},
				{
					id = "group_dlc_tooltip",
					class = "KView",
					pos = v(383.15, 61.95),
					children = {
						{
							class = "KImageView",
							image_name = "tower_room_image_dlc_arrow_",
							id = "image_dlc_arrow",
							pos = v(-61.85, -8.3),
							scale = v(1, 1),
							anchor = v(9.3, 10.4)
						},
						{
							class = "GG59View",
							image_name = "tower_room_9slice_offer_info_tooltip_bg_",
							id = "hero_room_dlc_tooltip_bg",
							pos = v(145.2, 12),
							size = v(393.3765, 122.2021),
							anchor = v(196.6882, 61.1011),
							slice_rect = r(20, 20, 40, 40)
						},
						{
							vertical_align = "middle",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 21,
							text = "COLOSAL DWARFARE CAMPAIGN",
							id = "label_info_tooltip_title",
							fit_size = true,
							font_name = "fla_body",
							pos = v(-38.75, -39.4),
							size = v(369.15, 33.7),
							colors = {
								text = {
									45,
									94,
									152
								}
							}
						},
						{
							vertical_align = "middle",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "-2",
							font_size = 21,
							text = "This hero is included in the colosal dwarfare campaign",
							id = "label_info_tooltip_desc",
							fit_size = true,
							font_name = "fla_body",
							pos = v(-38.75, -2.3),
							size = v(369.15, 66.05),
							colors = {
								text = {
									48,
									46,
									38
								}
							}
						}
					}
				}
			}
		},
		{
			id = "tower_room_skill_tooltip",
			class = "KView",
			template_name = "group_tower_room_skill_tooltip",
			pos = v(405.25, 402.25)
		},
		{
			class = "GG5Button",
			transition_delay = 0.15,
			id = "tower_room_done_button",
			template_name = "button_tower_room_confirm_ok",
			transition = "up",
			pos = v(525.1, 667.4),
			scale = v(1, 1)
		},
		{
			id = "tower_room_roster_sel_overlay",
			class = "KView",
			pos = v(-864, -17.8),
			anchor = v(0, 0),
			size = v(1728, 768)
		},
		{
			template_name = "group_towers_wheel",
			class = "KView",
			transition_delay = 0.15,
			id = "group_tower_ring",
			transition = "scale",
			pos = v(-443.35, 418.1)
		}
	}
}
