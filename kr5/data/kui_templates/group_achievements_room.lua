-- chunkname: @./kr5/data/kui_templates/group_achievements_room.lua

return {
	class = "KView",
	children = {
		{
			default_image_name = "achievements_room_button_confirm_yes_bg_0001",
			focus_image_name = "achievements_room_button_confirm_yes_bg_0003",
			class = "GG5Button",
			id = "button_confirm_ok",
			pos = v(603.7, 131),
			scale = v(1, 1),
			image_offset = v(-129.1, -54.35),
			hit_rect = r(-129.1, -54.35, 265, 128),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 35,
					line_height_extra = "0",
					text_key = "BUTTON_OK",
					text = "ok",
					class = "GG5ShaderLabel",
					id = "label_button_ok",
					font_name = "fla_h",
					pos = v(-98.8, 41.05),
					scale = v(1.1537, 1.1537),
					size = v(197.7, 41.1),
					colors = {
						text = {
							26,
							70,
							94
						}
					},
					shaders = {
						"p_bevel"
					},
					shader_args = {
						{
							distance = 2,
							angle = 300,
							c1 = {
								0.7922,
								0.9647,
								1,
								1
							},
							c2 = {
								0,
								0,
								0,
								1
							}
						}
					}
				}
			}
		},
		{
			focus_image_name = "achievements_room_button_achievement_room_amount_indicator_left_0003",
			class = "GG5Button",
			id = "achievement_room_amount_indicator_left_button",
			default_image_name = "achievements_room_button_achievement_room_amount_indicator_left_0001",
			pos = v(-524.85, -186.6),
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
					font_name = "fla_h",
					pos = v(-40.95, -23.9),
					scale = v(1, 1),
					size = v(65.3, 45.65),
					colors = {
						text = {
							231,
							244,
							251
						}
					},
					shaders = {
						"p_outline",
						"p_outline"
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
			pos = v(720.5, -186.6),
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
					font_name = "fla_h",
					pos = v(-40.95, -23.9),
					scale = v(1, 1),
					size = v(65.3, 45.65),
					colors = {
						text = {
							231,
							244,
							251
						}
					},
					shaders = {
						"p_outline",
						"p_outline"
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
