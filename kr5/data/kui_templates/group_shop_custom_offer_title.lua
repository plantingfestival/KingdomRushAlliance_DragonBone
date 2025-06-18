-- chunkname: @./kr5/data/kui_templates/group_shop_custom_offer_title.lua

return {
	class = "KView",
	children = {
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 37,
			line_height_extra = "0",
			fit_size = true,
			text = "get all the heroes now",
			text_key = "SHOP_ROOM_OFFER_ALL_HEROES",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_desc",
			font_name = "fla_h",
			pos = v(-312.3, -23.15),
			scale = v(1, 1),
			size = v(624.55, 55.4),
			colors = {
				text = {
					255,
					255,
					255
				}
			},
			shaders = {
				"p_bands",
				"p_outline_tint"
			},
			shader_args = {
				{
					margin = 1,
					p1 = 0.5,
					p2 = 0.99,
					c1 = {
						0.9843,
						0.9333,
						0.7176,
						1
					},
					c2 = {
						0.9529,
						0.6824,
						0.1451,
						1
					},
					c3 = {
						0.9529,
						0.6824,
						0.1451,
						1
					}
				},
				{
					thickness = 2.5,
					outline_color = {
						0.5137,
						0.2784,
						0,
						1
					}
				}
			}
		}
	}
}
