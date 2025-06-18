-- chunkname: @./kr5/data/kui_templates/button_room_big_select.lua

return {
	default_image_name = "hero_room_button_select_bg _0001",
	class = "GG5Button",
	focus_image_name = "hero_room_button_select_bg _0003",
	image_offset = v(-124.05, -56.3),
	hit_rect = r(-124.05, -56.3, 258, 117),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 37,
			line_height_extra = "2",
			text = "EQUIP",
			class = "GG5ShaderLabel",
			id = "label_button_select",
			font_name = "fla_h",
			pos = v(-90.85, -26.9),
			scale = v(1, 1),
			size = v(186.5, 37.45),
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
