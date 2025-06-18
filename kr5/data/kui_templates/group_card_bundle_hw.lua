-- chunkname: @./kr5/data/kui_templates/group_card_bundle_hw.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card_bundle3",
			pos = v(-11.45, -9.1),
			scale = v(0.9107, 0.9107),
			anchor = v(77.2, 110.65)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card_bundle2",
			pos = v(0.3, -9.1),
			scale = v(0.9107, 0.9107),
			anchor = v(77.2, 110.65)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card_bundle1",
			pos = v(11.65, -9.1),
			scale = v(0.9107, 0.9107),
			anchor = v(77.2, 110.65)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 20,
			line_height_extra = "0",
			fit_size = true,
			text = "Summon Blackburn\nsdsdsdsd",
			text_key = "SHOP_ROOM_OFFER_CARD_BUNDLE_TITLE",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_card_bundle_title",
			font_name = "fla_h",
			pos = v(-116.95, 91.45),
			scale = v(1, 1),
			size = v(246.95, 53.2),
			colors = {
				text = {
					255,
					255,
					255
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 1.6666666666666667,
					outline_color = {
						0.2588,
						0,
						0.3294,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5ShaderLabel",
			font_size = 40,
			line_height_extra = "1",
			text = "X4",
			id = "label_shop_offer_bundle_quantity",
			fit_size = true,
			font_name = "fla_numbers_2",
			pos = v(15.15, 53.25),
			size = v(85.9, 48.7),
			colors = {
				text = {
					255,
					255,
					255
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 2.0833333333333335,
					outline_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		}
	}
}
