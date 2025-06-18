-- chunkname: @./kr5/data/kui_templates/group_popup_notification_armored_enemies.lua

return {
	class = "KView",
	children = {
		{
			class = "KView"
		},
		{
			class = "GG59View",
			image_name = "ingame_notifications_9slice_notification_bg_",
			id = "bg",
			pos = v(-3.45, -20.6),
			size = v(921.8482, 668.3008),
			anchor = v(460.9241, 331.6985),
			slice_rect = r(232.75, 188.6, 1.5, 1.65)
		},
		{
			id = "title_bg",
			image_name = "ingame_notifications_image_title_bg_2_",
			class = "KImageView",
			pos = v(-0.45, -332.15),
			anchor = v(271.9, 50.1)
		},
		{
			class = "KView"
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_armored_enemies_shield_",
			pos = v(-269, -193.25),
			anchor = v(60.2, 61.4)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_armored_enemies_arrow_",
			pos = v(-80.2, -16),
			anchor = v(69, 15.05)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_armored_enemies_enemy_",
			pos = v(-228.1, -15.3),
			anchor = v(27.2, 25.65)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_armored_enemies_tower_1_",
			pos = v(95.9, -27.35),
			anchor = v(73.3, 55.45)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_armored_enemies_tower_2_",
			pos = v(241.05, -30.9),
			anchor = v(77.7, 54.2)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_armored_enemies_bottom_info_",
			pos = v(8.15, 92),
			anchor = v(316.5, 51.8)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 48,
			line_height_extra = "2",
			fit_size = true,
			text = " New tip",
			text_key = "NOTIFICATION_title_new_tip",
			class = "GG5ShaderLabel",
			id = "label_title_new_tip",
			font_name = "fla_h",
			pos = v(-236.15, -360.35),
			scale = v(1, 1),
			size = v(473.4, 47.4),
			colors = {
				text = {
					240,
					237,
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
						0.0471,
						0.2,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "NOTIFICATION_armored_enemies_desc_body_1",
			font_size = 27,
			line_height_extra = "2",
			fit_size = true,
			text = "Einige Feinde tragen Rüstung verschiedener Stärken qui schützt sie contre nicht magische Angriffe.",
			class = "GG5Label",
			id = "label_armored_enemies_desc_body_1",
			font_name = "fla_body",
			pos = v(-195.6, -230.5),
			scale = v(1, 1),
			size = v(533.65, 121.85),
			colors = {
				text = {
					90,
					55,
					38
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "NOTIFICATION_armored_enemies_desc_title",
			font_size = 28,
			line_height_extra = "0",
			fit_size = true,
			text = "ARMORED ENEMIES!",
			class = "GG5Label",
			id = "label_armored_enemies_desc_title",
			font_name = "fla_body",
			pos = v(-194.6, -273.55),
			scale = v(1, 1),
			size = v(532.7, 43.3),
			colors = {
				text = {
					154,
					12,
					12
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "NOTIFICATION_armored_enemies_desc_body_3",
			font_size = 27,
			line_height_extra = "0",
			fit_size = true,
			text = "Les ennemis blindés prennent moins de dégâts des archers, des soldats et des druides en pierre.",
			class = "GG5Label",
			id = "label_armored_enemies_desc_body_3",
			font_name = "fla_body",
			pos = v(-327.4, 147.5),
			scale = v(1, 1),
			size = v(667.6, 84.6),
			colors = {
				text = {
					90,
					55,
					38
				}
			}
		},
		{
			vertical_align = "bottom",
			text_align = "center",
			text_key = "NOTIFICATION_armored_enemies_desc_body_2",
			font_size = 26,
			line_height_extra = "0",
			fit_size = true,
			text = "Widersteht\nSchaden von",
			class = "GG5Label",
			id = "label_armored_enemies_desc_body_2",
			font_name = "fla_body",
			pos = v(-195, -109.25),
			scale = v(1, 1),
			size = v(227, 77),
			colors = {
				text = {
					212,
					63,
					0
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "NOTIFICATION_armored_enemies_enemy_name",
			font_size = 25,
			line_height_extra = "2",
			fit_size = true,
			text = "Tusked Brawler",
			class = "GG5Label",
			id = "label_armored_enemies_enemy_name",
			font_name = "fla_body",
			pos = v(-211.2, 45.75),
			scale = v(1, 1),
			size = v(289.95, 39.15),
			colors = {
				text = {
					192,
					192,
					192
				}
			}
		},
		{
			focus_image_name = "ingame_notifications_button_ok_0003",
			class = "GG5Button",
			id = "button_done",
			default_image_name = "ingame_notifications_button_ok_0001",
			pos = v(252.05, 299.4),
			image_offset = v(-172.2, -61.85),
			hit_rect = r(-172.2, -61.85, 356, 125),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 48,
					line_height_extra = "0",
					fit_size = true,
					text = "Ok",
					text_key = "NOTIFICATION_button_ok",
					class = "GG5ShaderLabel",
					id = "label_button_ok",
					font_name = "fla_h",
					pos = v(-129.8, -28.35),
					scale = v(1, 1),
					size = v(267.95, 47.4),
					colors = {
						text = {
							250,
							253,
							255
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 1.6666666666666667,
							outline_color = {
								0.1176,
								0.2157,
								0.3059,
								1
							}
						}
					}
				}
			}
		}
	}
}
