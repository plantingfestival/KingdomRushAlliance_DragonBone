-- chunkname: @./kr5/data/kui_templates/button_tower_room_confirm_ok.lua

return {
	default_image_name = "tower_room_button_confirm_yes_bg_0001",
	class = "GG5Button",
	focus_image_name = "tower_room_button_confirm_yes_bg_0003",
	image_offset = v(-108.1, -48.85),
	hit_rect = r(-108.1, -48.85, 219, 102),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 35,
			fit_size = true,
			line_height_extra = "2",
			text = "DONE",
			class = "GG5ShaderLabel",
			id = "label_button_room_small",
			font_name = "fla_h",
			pos = v(-75.65, -26.25),
			scale = v(1, 1),
			size = v(149.95, 49.15),
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
