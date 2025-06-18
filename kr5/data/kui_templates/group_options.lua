-- chunkname: @./kr5/data/kui_templates/group_options.lua

return {
	class = "KView",
	children = {
		{
			class = "GG5Button",
			focus_image_name = "screen_slots_button_options_0003",
			id = "button_options",
			default_image_name = "screen_slots_button_options_0001",
			pos = v(101.1, 96),
			scale = v(0.8965, 0.8965),
			anchor = v(49.1, 49.05)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 30,
			line_height_extra = "0",
			text_key = "OPTIONS",
			text = "OPTIONS",
			class = "GG5ShaderLabel",
			id = "label_options",
			fit_size = true,
			font_name = "fla_h",
			pos = v(0, 115.9),
			size = v(200.8, 45),
			colors = {
				text = {
					54,
					219,
					255
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.098,
						0.2039,
						0.2235,
						1
					}
				}
			}
		}
	}
}
