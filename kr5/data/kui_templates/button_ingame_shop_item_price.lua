-- chunkname: @./kr5/data/kui_templates/button_ingame_shop_item_price.lua

return {
	default_image_name = "ingame_shop_kui_button_price_bg_0001",
	class = "GG5Button",
	focus_image_name = "ingame_shop_kui_button_price_bg_0003",
	image_offset = v(-124.15, -56.3),
	hit_rect = r(-124.15, -56.3, 258, 117),
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 38,
			fit_size = true,
			line_height_extra = "0",
			text = "500",
			class = "GG5ShaderLabel",
			id = "label_button_price",
			font_name = "fla_numbers_2",
			pos = v(-43.1, -25.9),
			scale = v(1, 1),
			size = v(123.15, 51.95),
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
