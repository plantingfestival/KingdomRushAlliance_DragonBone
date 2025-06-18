-- chunkname: @./kr5/data/kui_templates/group_popup_notification_glare.lua

return {
	class = "KView",
	children = {
		{
			class = "GG59View",
			image_name = "ingame_notifications_9slice_notification_bg_enemy_",
			id = "bg",
			pos = v(-3.3, -5.65),
			size = v(1170.6821, 608.9225),
			anchor = v(585.3411, 302.5555),
			slice_rect = r(282.75, 229.4, 1.5, 1.65)
		},
		{
			id = "title_bg",
			image_name = "ingame_notifications_image_title_bg_1_",
			class = "KImageView",
			pos = v(-4.85, -277.15),
			anchor = v(328.25, 58.75)
		},
		{
			template_name = "group_glare_polaroid",
			class = "KView",
			r = 0.0447,
			pos = v(-411.7, 1.6),
			scale = v(1.0498, 1.0498)
		},
		{
			focus_image_name = "ingame_notifications_button_ok_enemy_special_0003",
			class = "GG5Button",
			id = "button_done",
			default_image_name = "ingame_notifications_button_ok_enemy_special_0001",
			pos = v(301.35, 272),
			image_offset = v(-199, -70.35),
			hit_rect = r(-199, -70.35, 412, 142),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 56,
					line_height_extra = "0",
					fit_size = true,
					text = "Ok",
					text_key = "NOTIFICATION_button_ok",
					class = "GG5ShaderLabel",
					id = "label_button_ok",
					font_name = "fla_h",
					pos = v(-153.6, -32.3),
					scale = v(1, 1),
					size = v(318.7, 54.6),
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
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "NOTIFICATION_glare_desc_bullets",
			font_size = 28,
			line_height_extra = "-5",
			text = "- Heals nearby enemies\n- Triggers certain effects on enemies",
			class = "GG5Label",
			id = "label_glare_desc_bullets",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-171.95, 45.8),
			size = v(635.95, 125.9),
			colors = {
				text = {
					198,
					56,
					56
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "NOTIFICATION_glare_desc_body",
			font_size = 32,
			line_height_extra = "-5",
			text = "Corruption spawns become more powerful under the overseers stare\n",
			class = "GG5Label",
			id = "label_glare_desc_body",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-171.35, -117.85),
			size = v(636.15, 168.8),
			colors = {
				text = {
					90,
					55,
					38
				}
			}
		},
		{
			text_key = "NOTIFICATION_glare_desc_title",
			text_align = "left",
			line_height_extra = "2",
			font_size = 42,
			text = "Glare",
			class = "GG5Label",
			id = "label_glare_desc_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-171.35, -183.7),
			size = v(638.1, 63),
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
			text_align = "center",
			font_size = 55,
			line_height_extra = "2",
			fit_size = true,
			text = "Beware!",
			text_key = "NOTIFICATION_title_glare",
			class = "GG5ShaderLabel",
			id = "label_title_glare",
			font_name = "fla_h",
			pos = v(-286.2, -305.55),
			scale = v(1.0322, 1),
			size = v(573.6, 53.65),
			colors = {
				text = {
					255,
					237,
					237
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0.2,
						0,
						0,
						1
					}
				}
			}
		}
	}
}
