-- chunkname: @./kr5/data/kui_templates/group_popup_notification_enemy.lua

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
			template_name = "group_enemy_polaroid",
			class = "KView",
			r = 0.0447,
			id = "polaroid",
			pos = v(-410.05, 1.25),
			scale = v(1.0498, 1.0498)
		},
		{
			class = "GG5Label",
			text_align = "left",
			line_height_extra = "2",
			font_size = 42,
			text = "Hog Invader",
			id = "label_enemy_desc_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-181.05, -184.15),
			size = v(658.05, 63),
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
			class = "GG5Label",
			line_height_extra = "-5",
			font_size = 32,
			text = "Frantic miners who love to work because their gold and gems fever. Capable of breaking the toughest of rocks and enemies.",
			id = "label_enemy_desc_body",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-180.95, -117.9),
			size = v(657.25, 168.8),
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
			class = "GG5Label",
			line_height_extra = "0",
			font_size = 28,
			text = "- averange Speed\n- ranged fire attack\n- ranged fire attack",
			id = "label_enemy_desc_bullets",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-182.8, 44.25),
			size = v(659.8, 125.9),
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
			text_align = "center",
			font_size = 55,
			line_height_extra = "2",
			text_key = "NOTIFICATION_title_enemy",
			text = "New enemy!",
			class = "GG5ShaderLabel",
			id = "label_title_enemy",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-286.9, -307.7),
			size = v(567.1, 53.65),
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
