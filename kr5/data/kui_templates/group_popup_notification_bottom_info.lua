-- chunkname: @./kr5/data/kui_templates/group_popup_notification_bottom_info.lua

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
			image_name = "ingame_notifications_image_bottom_info_book_icon_",
			pos = v(-291.55, -210.5),
			anchor = v(65.85, 53.25)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_bottom_info_tip_bottom_info_",
			pos = v(18.55, 172),
			anchor = v(316.5, 51.8)
		},
		{
			image_name = "ingame_notifications_9slice_enemy_desc_baloon_",
			class = "GG59View",
			pos = v(115.55, 2.45),
			size = v(493.9323, 195.8258),
			anchor = v(246.9662, 97.9129),
			slice_rect = r(2.8, 2.6, 6.55, 6.1)
		},
		{
			image_name = "ingame_notifications_image_bottom_info_polaroid_",
			class = "KImageView",
			pos = v(-76.5, -8.9),
			scale = v(1, 1),
			anchor = v(99.4, 96.35)
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
			text_key = "NOTIFICATION_bottom_info_desc_body",
			font_size = 27,
			line_height_extra = "2",
			fit_size = true,
			text = "During battle, tap the bottom info portrait to get more details about your foes",
			class = "GG5Label",
			id = "label_bottom_info_desc_body",
			font_name = "fla_body",
			pos = v(-209.15, -235.15),
			scale = v(1, 1),
			size = v(553.2, 136.75),
			colors = {
				text = {
					90,
					55,
					38
				}
			}
		},
		{
			text_key = "NOTIFICATION_bottom_info_desc_title",
			text_align = "left",
			line_height_extra = "0",
			font_size = 28,
			fit_size = true,
			text = "Know your enemy!",
			class = "GG5Label",
			id = "label_bottom_info_desc_title",
			font_name = "fla_body",
			pos = v(-209.15, -276.65),
			scale = v(1, 1),
			size = v(553.25, 43.3),
			colors = {
				text = {
					154,
					12,
					12
				}
			}
		},
		{
			text_key = "ENEMY_BEAR_VANGUARD_NAME",
			text_align = "left",
			line_height_extra = "2",
			font_size = 25,
			fit_size = true,
			text = "Bear Vanguard",
			class = "GG5Label",
			id = "label_bottom_info_enemy_name",
			font_name = "fla_body",
			pos = v(-200.8, 125.75),
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
			vertical_align = "middle",
			text_align = "center",
			text_key = "NOTIFICATION_bottom_info_tap_portrait_desc",
			font_size = 24,
			line_height_extra = "0",
			fit_size = true,
			text = "Tap to see enemy description\nAAAAAAAAAA",
			class = "GG5Label",
			id = "label_bottom_info_tap_portrait_desc",
			font_name = "fla_body",
			pos = v(-389.15, -40.95),
			scale = v(1, 1),
			size = v(215.05, 119.1),
			colors = {
				text = {
					183,
					63,
					13
				}
			}
		},
		{
			text_key = "ENEMY_BEAR_VANGUARD_NAME",
			text_align = "left",
			line_height_extra = "2",
			font_size = 21,
			text = "Bearrrr",
			class = "GG5Label",
			id = "label_bottom_info_enemy_desc_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(36.5, -83.8),
			size = v(315.25, 38.4),
			colors = {
				text = {
					116,
					25,
					25
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "ENEMY_BEAR_VANGUARD_DESCRIPTION",
			font_size = 16,
			line_height_extra = "-3",
			fit_size = true,
			text = "Frantic miners who love to work because their gold and gems fever. Capable of breaking the toughest of rocks and enemies.",
			class = "GG5Label",
			id = "label_bottom_info_enemy_desc_body",
			font_name = "fla_body",
			pos = v(36.15, -52.95),
			scale = v(1, 1),
			size = v(316.55, 91),
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
			text_key = "ENEMY_BEAR_VANGUARD_EXTRA",
			font_size = 14,
			line_height_extra = "0",
			fit_size = true,
			text = "- averange Speed\n- ranged fire attack\n- ranged fire attack",
			class = "GG5Label",
			id = "label_bottom_info_enemy_desc_bullets",
			font_name = "fla_body",
			pos = v(35.95, 30.75),
			scale = v(1, 1),
			size = v(316.75, 63.1),
			colors = {
				text = {
					198,
					56,
					56
				}
			}
		},
		{
			class = "KView"
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_bottom_info_tap_arrow_",
			pos = v(-340.5, 99.15),
			anchor = v(32.85, 39.6)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_bottom_info_portrait_circle_",
			pos = v(-252.55, 167.95),
			anchor = v(66.5, 60.75)
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
