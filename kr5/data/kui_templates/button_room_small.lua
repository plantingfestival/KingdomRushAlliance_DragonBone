-- chunkname: @./kr5/data/kui_templates/button_room_small.lua

return {
	default_image_name = "hero_room_button_small_bg_0001",
	class = "GG5Button",
	focus_image_name = "hero_room_button_small_bg_0003",
	image_offset = v(-108.1, -48.85),
	hit_rect = r(-108.1, -48.85, 219, 102),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5ShaderLabel",
			font_size = 35,
			line_height_extra = "2",
			text = "DONE",
			id = "label_button_room_small",
			font_name = "fla_h",
			pos = v(-75.65, -25.25),
			size = v(149.95, 35.65),
			colors = {
				text = {
					13,
					39,
					60
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0,
						0.8275,
						0.9961,
						1
					}
				}
			}
		}
	}
}
