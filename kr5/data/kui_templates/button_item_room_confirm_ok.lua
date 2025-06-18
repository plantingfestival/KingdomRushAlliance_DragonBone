-- chunkname: @./kr5/data/kui_templates/button_item_room_confirm_ok.lua

return {
	default_image_name = "item_room_button_confirm_yes_bg_0001",
	class = "GG5Button",
	focus_image_name = "item_room_button_confirm_yes_bg_0003",
	image_offset = v(-108.1, -48.85),
	hit_rect = r(-108.1, -48.85, 219, 102),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 36,
			line_height_extra = "0",
			fit_size = true,
			text = "done",
			text_key = "BUTTON_DONE",
			class = "GG5ShaderLabel",
			id = "label_button_room_small",
			font_name = "fla_h",
			pos = v(-72.65, -23.3),
			scale = v(1, 1),
			size = v(148.1, 45.35),
			colors = {
				text = {
					32,
					42,
					49
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
