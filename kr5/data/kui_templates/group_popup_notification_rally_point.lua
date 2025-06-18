-- chunkname: @./kr5/data/kui_templates/group_popup_notification_rally_point.lua

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
			image_name = "ingame_notifications_image_rally_point_flag_",
			pos = v(-263.3, -194.7),
			anchor = v(55.95, 55.95)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_rally_point_arrow_",
			pos = v(-118.95, 111.6),
			anchor = v(9.45, 16.3)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_rally_point_arrow_",
			pos = v(258.45, 111.6),
			anchor = v(9.45, 16.3)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_rally_point_tower_",
			pos = v(-236.75, 11.45),
			anchor = v(116.45, 117.5)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_rally_point_tower_example_",
			pos = v(135.7, 6.6),
			anchor = v(201.85, 123.2)
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
			pos = v(-232.35, -361.25),
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
			vertical_align = "top",
			text_align = "left",
			text_key = "NOTIFICATION_rally_point_desc_body_1",
			font_size = 25,
			line_height_extra = "0",
			fit_size = true,
			text = "Sie können Ihre Soldaten s Sammelpunkte anpassen, um ihnen einen anderen Bereich machen zu verteidigen.",
			class = "GG5Label",
			id = "label_rally_point_desc_body_1",
			font_name = "fla_body",
			pos = v(-183.65, -230.75),
			scale = v(1, 1),
			size = v(504, 109.45),
			colors = {
				text = {
					90,
					55,
					38
				}
			}
		},
		{
			vertical_align = "middle",
			text_align = "left",
			text_key = "NOTIFICATION_rally_point_desc_title",
			font_size = 28,
			line_height_extra = "0",
			fit_size = true,
			text = "COMMAND  YOUR  TROOPS!",
			class = "GG5Label",
			id = "label_rally_point_desc_title",
			font_name = "fla_body",
			pos = v(-183.75, -268.75),
			scale = v(1, 1),
			size = v(503.75, 43.3),
			colors = {
				text = {
					154,
					12,
					12
				}
			}
		},
		{
			text_key = "NOTIFICATION_rally_point_desc_subtitle",
			text_align = "center",
			line_height_extra = "0",
			font_size = 26,
			fit_size = true,
			text = "gamme de rallye",
			class = "GG5Label",
			id = "label_rally_point_desc_subtitle",
			font_name = "fla_body",
			pos = v(19.05, -102.75),
			scale = v(1, 1),
			size = v(225.25, 40.5),
			colors = {
				text = {
					40,
					125,
					181
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "NOTIFICATION_rally_point_desc_body_3",
			font_size = 26,
			line_height_extra = "0",
			fit_size = true,
			text = "Où touchiez vous voulez que vos soldats pour aller",
			class = "GG5Label",
			id = "label_rally_point_desc_body_3",
			font_name = "fla_body",
			pos = v(91.75, 125.15),
			scale = v(1, 1),
			size = v(261, 113.5),
			colors = {
				text = {
					183,
					63,
					13
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "NOTIFICATION_rally_point_desc_body_2",
			font_size = 26,
			line_height_extra = "0",
			fit_size = true,
			text = "sélectionner le point de contrôle rallye",
			class = "GG5Label",
			id = "label_rally_point_desc_body_2",
			font_name = "fla_body",
			pos = v(-206.5, 125.35),
			scale = v(1, 1),
			size = v(245.6, 113.5),
			colors = {
				text = {
					183,
					63,
					13
				}
			}
		},
		{
			focus_image_name = "ingame_notifications_button_ok_0003",
			class = "GG5Button",
			id = "button_done",
			default_image_name = "ingame_notifications_button_ok_0001",
			pos = v(252.05, 297.75),
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
