-- chunkname: @./kr5/data/kui_templates/button_item_price.lua

return {
	default_image_name = "item_room_button_price_bg_0001",
	class = "GG5Button",
	focus_image_name = "item_room_button_price_bg_0003",
	image_offset = v(-124.15, -56.3),
	hit_rect = r(-124.15, -56.3, 258, 117),
	children = {
		{
			vertical_align = "top",
			text_align = "left",
			font_size = 37,
			line_height_extra = "2",
			text = "500",
			class = "GG5ShaderLabel",
			id = "label_button_price",
			font_name = "fla_h",
			pos = v(-17.1, -26.9),
			scale = v(1, 1),
			size = v(113.45, 37.45),
			colors = {
				text = {
					61,
					18,
					13
				}
			},
			shaders = {
				"p_outline"
			},
			shader_args = {
				{
					thickness = 3.3333333333333335,
					outline_color = {
						0.9765,
						0.8706,
						0.1176,
						1
					}
				}
			}
		}
	}
}
