-- chunkname: @./kr5/data/kui_templates/group_upgrades_room.lua

return {
	class = "KView",
	children = {
		{
			class = "KView",
			id = "group_room_bg_desktop",
			transition = "down",
			pos = v(-0.6, 375.65),
			UNLESS = ctx.is_mobile,
			children = {
				{
					class = "GG59View",
					image_name = "room_bg_desktop_9slice_bg_color_desktop_",
					id = "bg_color",
					pos = v(-5.45, 26.15),
					size = v(1412.4585, 888.4739),
					anchor = v(705.5611, 444.2369),
					slice_rect = r(21.3, 20.45, 10, 10.05)
				},
				{
					class = "KView",
					id = "group_bg_textures",
					pos = v(-8, 5),
					scale = v(1.0042, 0.8197),
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
					pos = v(-13.4, -25.9),
					size = v(1495.7771, 946.4822),
					anchor = v(734.0478, 410.8314),
					slice_rect = r(100.4, 75.25, 22.3, 15.4)
				},
				{
					id = "frame_top_right_corner",
					class = "KImageView",
					image_name = "room_bg_desktop_image_bg_frame_topcorner_desktop_",
					hidden = true,
					pos = v(670.65, -403.55),
					anchor = v(9.9, 29.15)
				},
				{
					class = "GG5Button",
					focus_image_name = "room_bg_desktop_button_bg_close_desktop_0003",
					id = "button_close_popup",
					default_image_name = "room_bg_desktop_button_bg_close_desktop_0001",
					pos = v(693.7, -409.3),
					scale = v(1, 1),
					anchor = v(42.7, 49.45)
				},
				{
					id = "group_rivets_left",
					class = "KView",
					pos = v(-715.75, 276.8),
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
					pos = v(694.85, 276.8),
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
					pos = v(-460.3, 463.5),
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
					pos = v(-6.6, -462),
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
					text = "UPGRADES",
					text_key = "MAP_BUTTON_UPGRADES",
					class = "GG5ShaderLabel",
					id = "title_text",
					font_name = "fla_h",
					pos = v(-232.55, -486.6),
					scale = v(1, 1),
					size = v(460, 69.65),
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
			template_name = "group_upgrades_towers",
			class = "KView",
			transition_delay = 0.05,
			id = "group_upgrades_towers",
			transition = "down",
			pos = v(-506.45, 339.9)
		},
		{
			template_name = "group_upgrades_heroes",
			class = "KView",
			transition_delay = 0.1,
			id = "group_upgrades_heroes",
			transition = "down",
			pos = v(-178.5, 340)
		},
		{
			template_name = "group_upgrades_reinforcements",
			class = "KView",
			transition_delay = 0.15,
			id = "group_upgrades_reinforcements",
			transition = "down",
			pos = v(148.85, 340)
		},
		{
			template_name = "group_upgrades_alliance",
			class = "KView",
			transition_delay = 0.2,
			id = "group_upgrades_alliance",
			transition = "down",
			pos = v(483.2, 340)
		},
		{
			class = "UpgradeTooltipView",
			template_name = "template_upgrade_tooltip",
			pos = v(-683.05, 90.9)
		},
		{
			class = "KView",
			transition_delay = 0.25,
			id = "group_upgrades_points",
			transition = "up",
			pos = v(-550.8, 713.25),
			scale = v(1, 1),
			children = {
				{
					class = "KImageView",
					image_name = "upgrades_room_image_upgrades_points_bg_",
					pos = v(4.55, 1.9),
					anchor = v(84.5, 41.65)
				},
				{
					class = "KImageView",
					image_name = "upgrades_room_image_upgrades_points_icon_",
					pos = v(-35.15, 1.05),
					anchor = v(20.45, 26.15)
				},
				{
					vertical_align = "middle",
					text_align = "center",
					line_height_extra = "2",
					font_size = 37,
					fit_size = true,
					text = "30",
					class = "GG5Label",
					id = "label_upgrade_points",
					font_name = "fla_numbers",
					pos = v(1.55, -25.1),
					scale = v(1, 1),
					size = v(69.35, 49.55),
					colors = {
						text = {
							114,
							255,
							173
						}
					}
				}
			}
		},
		{
			template_name = "button_upgrades_room_small",
			class = "GG5Button",
			transition_delay = 0.25,
			id = "upgrades_room_reset_button",
			transition = "up",
			pos = v(286.55, 714.3)
		},
		{
			template_name = "button_upgrades_room_small",
			class = "GG5Button",
			transition_delay = 0.25,
			id = "upgrades_room_done_button",
			transition = "up",
			pos = v(522.1, 714.3)
		}
	}
}
