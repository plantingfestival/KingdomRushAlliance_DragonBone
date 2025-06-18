-- chunkname: @./kr5/data/kui_templates/group_start_desktop.lua

return {
	class = "KView",
	children = {
		{
			focus_image_name = "screen_slots_image_bg_start_button_0003",
			class = "GG5Button",
			id = "button_start_desktop",
			default_image_name = "screen_slots_image_bg_start_button_0001",
			pos = v(0, -139.1),
			image_offset = v(-284.4, -108.35),
			hit_rect = r(-284.4, -108.35, 572, 264.1),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 75,
					line_height_extra = "1",
					fit_size = true,
					text = "start",
					text_key = "START",
					class = "GG5ShaderLabel",
					id = "label_start",
					font_name = "fla_h",
					pos = v(-171.2, -51.7),
					scale = v(1, 1),
					size = v(346.8, 71.75),
					colors = {
						text = {
							231,
							254,
							0
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
								0.9059,
								0.9961,
								0,
								1
							},
							c2 = {
								0.9686,
								0.8078,
								0.0078,
								1
							},
							c3 = {
								0.9686,
								0.8078,
								0.0078,
								1
							}
						},
						{
							thickness = 4.166666666666667,
							outline_color = {
								0.2,
								0.2824,
								0.3059,
								1
							}
						}
					}
				}
			}
		},
		{
			focus_image_name = "screen_slots_image_button_quit_bg_0003",
			class = "GG5Button",
			id = "button_quit_desktop",
			default_image_name = "screen_slots_image_button_quit_bg_0001",
			pos = v(2.5, -43.2),
			image_offset = v(-199.65, -66.55),
			hit_rect = r(-199.65, -66.55, 370, 148.1),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 43,
					line_height_extra = "1",
					text_key = "BUTTON_QUIT",
					text = "qUIT",
					class = "GG5ShaderLabel",
					id = "label_quit",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-95.65, -22.7),
					size = v(194.75, 42.8),
					colors = {
						text = {
							231,
							254,
							0
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
								0.9059,
								0.9961,
								0,
								1
							},
							c2 = {
								0.9686,
								0.8078,
								0.0078,
								1
							},
							c3 = {
								0.9686,
								0.8078,
								0.0078,
								1
							}
						},
						{
							thickness = 3.3333333333333335,
							outline_color = {
								0.2,
								0.2824,
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
