-- chunkname: @./kr5/data/kui_templates/button_room_big_buy.lua

return {
	default_image_name = "hero_room_button_price_bg_0001",
	class = "GG5Button",
	focus_image_name = "hero_room_button_price_bg_0003",
	image_offset = v(-116.05, -48.3),
	hit_rect = r(-116.05, -48.3, 238.3, 97.85),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 37,
			line_height_extra = "2",
			text = "$4,99",
			class = "GG5ShaderLabel",
			id = "label_button_price",
			font_name = "fla_h",
			pos = v(-90.85, -26.9),
			scale = v(1, 1),
			size = v(186.5, 37.45),
			colors = {
				text = {
					61,
					18,
					13
				}
			},
			shaders = {
				"p_outline_tint"
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
