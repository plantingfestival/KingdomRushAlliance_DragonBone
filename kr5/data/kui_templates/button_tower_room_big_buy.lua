-- chunkname: @./kr5/data/kui_templates/button_tower_room_big_buy.lua

return {
	default_image_name = "tower_room_button_price_bg_0001",
	class = "GG5Button",
	focus_image_name = "tower_room_button_price_bg_0003",
	image_offset = v(-127.15, -56.95),
	hit_rect = r(-127.15, -56.95, 258, 116),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 37,
			fit_size = true,
			line_height_extra = "0",
			text = "$4,99",
			class = "GG5ShaderLabel",
			id = "label_button_price",
			font_name = "fla_h",
			pos = v(-92.05, -33.45),
			scale = v(1, 1),
			size = v(186.5, 61.2),
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
