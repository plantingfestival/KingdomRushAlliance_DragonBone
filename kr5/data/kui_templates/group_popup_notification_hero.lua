-- chunkname: @./kr5/data/kui_templates/group_popup_notification_hero.lua

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
			pos = v(-3.45, -17.9),
			size = v(921.8482, 668.3008),
			anchor = v(460.9241, 331.6985),
			slice_rect = r(232.75, 188.6, 1.5, 1.65)
		},
		{
			id = "title_bg",
			image_name = "ingame_notifications_image_title_bg_2_",
			class = "KImageView",
			pos = v(-0.45, -329.45),
			anchor = v(271.9, 50.1)
		},
		{
			class = "KView"
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_hero_portrait_ingame_",
			pos = v(-269, -48.15),
			anchor = v(122.15, 136.9)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_hero_polaroid _",
			pos = v(112.55, 10.8),
			anchor = v(251.2, 129.35)
		},
		{
			class = "KView",
			template_name = "group_hero_baloon_2",
			pos = v(192.8, 114.5)
		},
		{
			class = "KView",
			template_name = "group_hero_baloon_1",
			pos = v(37.95, -112.15)
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "NOTIFICATION_hero_desc_body_1",
			font_size = 25,
			line_height_extra = "2",
			text = "Helden sind Elite-Einheiten, die stark sein können\nFeinde und unterstützen Sie Ihre Kräfte.",
			class = "GG5Label",
			id = "label_hero_desc_body_1",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-363.7, -230.4),
			size = v(727.6, 77.85),
			colors = {
				text = {
					90,
					55,
					38
				}
			}
		},
		{
			text_key = "NOTIFICATION_hero_desc_title",
			text_align = "center",
			line_height_extra = "2",
			font_size = 35,
			text = "Hero at your command!",
			class = "GG5Label",
			id = "label_hero_desc_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-363.35, -285.25),
			size = v(726.15, 53.2),
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
			font_size = 48,
			line_height_extra = "2",
			fit_size = true,
			text = "Hint",
			text_key = "NOTIFICATION_title_hint",
			class = "GG5ShaderLabel",
			id = "label_title_hint",
			font_name = "fla_h",
			pos = v(-232.35, -358.05),
			scale = v(1, 1),
			size = v(465.2, 47.4),
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
			vertical_align = "middle",
			text_align = "center",
			text_key = "NOTIFICATION_hero_desc_body_2",
			font_size = 25,
			line_height_extra = "2",
			text = "Heroes gain experience every time they damage an enemy or use an ability",
			class = "GG5Label",
			id = "label_hero_desc_body_2",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-363.75, 164.3),
			size = v(726.3, 76.3),
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
			text_align = "center",
			text_key = "NOTIFICATION_hero_desc",
			font_size = 25,
			line_height_extra = "2",
			fit_size = true,
			text = "Shows level, health and experience",
			class = "GG5Label",
			id = "label_hero_desc",
			font_name = "fla_body",
			pos = v(-392.3, 48.8),
			scale = v(1, 1),
			size = v(236.9, 113.45),
			colors = {
				text = {
					154,
					12,
					12
				}
			}
		},
		{
			focus_image_name = "ingame_notifications_button_ok_0003",
			class = "GG5Button",
			id = "button_done",
			default_image_name = "ingame_notifications_button_ok_0001",
			pos = v(254.75, 300.45),
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
