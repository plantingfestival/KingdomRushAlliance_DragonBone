-- chunkname: @./kr5/data/kui_templates/button_room_big_disabled.lua

return {
	default_image_name = "hero_room_button_selected_bg _0001",
	class = "GG5Button",
	focus_image_name = "hero_room_button_selected_bg _0003",
	image_offset = v(-124.05, -56.3),
	hit_rect = r(-124.05, -56.3, 258, 117),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 36,
			line_height_extra = "2",
			text = "equipped",
			class = "GG5ShaderLabel",
			id = "label_button_selected",
			font_name = "fla_h",
			pos = v(-87.25, -25.25),
			scale = v(1, 1),
			size = v(181.3, 37.45),
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
						0.5373,
						0.6549,
						0.698,
						1
					}
				}
			}
		}
	}
}
