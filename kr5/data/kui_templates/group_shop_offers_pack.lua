-- chunkname: @./kr5/data/kui_templates/group_shop_offers_pack.lua

return {
	class = "KView",
	children = {
		{
			image_name = "shop_room_9slice_shop_offer_gold_frame_",
			class = "GG59View",
			pos = v(0, 12.15),
			size = v(270.3858, 430.7605),
			anchor = v(135.1929, 227.488),
			slice_rect = r(19.85, 90.95, 23.6, 20.65)
		},
		{
			class = "GG59View",
			image_name = "shop_room_9slice_shop_offer_cost_bg_",
			id = "image_shop_offer_price_bg",
			pos = v(-0.25, 177.2),
			size = v(257.5999, 63.6),
			anchor = v(128.7999, 31.8),
			slice_rect = r(5.25, 15.9, 5.7, 31.8)
		},
		{
			vertical_align = "top",
			text_align = "left",
			font_size = 26,
			line_height_extra = "-2",
			text_key = "SHOP_ROOM_OFFER_PACK_DESC",
			text = "Special offer Pack!",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_pack_desc_TEXTFIT",
			font_name = "fla_h",
			pos = v(-116.1, -210.35),
			scale = v(1, 1),
			size = v(158.15, 74.2),
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
						0.5137,
						0.2784,
						0,
						1
					}
				}
			}
		},
		{
			id = "image_shop_offer_discount_bg",
			image_name = "shop_room_image_shop_offer_discount_bg_",
			class = "KImageView",
			pos = v(85.05, -173.1),
			anchor = v(40.7, 32.1)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 30,
			fit_size = true,
			line_height_extra = "0",
			text = "50%",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_discount",
			font_name = "fla_numbers_2",
			pos = v(46.6, -207.5),
			scale = v(1, 1),
			size = v(76.8, 45.7),
			colors = {
				text = {
					255,
					254,
					225
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 0.8333333333333334,
					outline_color = {
						0.5137,
						0.2784,
						0,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 21,
			fit_size = true,
			line_height_extra = "0",
			text = "off!",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_discount_off",
			font_name = "fla_h",
			pos = v(46.4, -174.15),
			scale = v(1, 1),
			size = v(77, 33.15),
			colors = {
				text = {
					255,
					254,
					225
				}
			},
			shaders = {
				"p_outline_tint"
			},
			shader_args = {
				{
					thickness = 0.8333333333333334,
					outline_color = {
						0.5137,
						0.2784,
						0,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 40,
			fit_size = true,
			line_height_extra = "1",
			text = "$4.99",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_pack_cost",
			font_name = "fla_numbers_2",
			pos = v(-124.15, 147.3),
			scale = v(1, 1),
			size = v(247.55, 59.55),
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
						0.5137,
						0.2784,
						0,
						1
					}
				}
			}
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card_pack_01",
			pos = v(-40.1, -4.5),
			scale = v(0.9031, 0.9031),
			anchor = v(77.2, 110.65)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card_pack_02",
			pos = v(44.05, 18.15),
			scale = v(0.9031, 0.9031),
			anchor = v(77.2, 110.65)
		}
	}
}
