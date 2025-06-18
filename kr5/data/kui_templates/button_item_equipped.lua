-- chunkname: @./kr5/data/kui_templates/button_item_equipped.lua

return {
	default_image_name = "item_room_button_equipped_bg _0001",
	class = "GG5Button",
	focus_image_name = "item_room_button_equipped_bg _0003",
	image_offset = v(-123.9, -56.3),
	hit_rect = r(-123.9, -56.3, 257, 117),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 36,
			line_height_extra = "2",
			text_key = "ITEM_ROOM_selected",
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
				"p_outline"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.4784,
						0.5882,
						0.6275,
						1
					}
				}
			}
		}
	}
}
