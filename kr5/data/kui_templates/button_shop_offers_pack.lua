-- chunkname: @./kr5/data/kui_templates/button_shop_offers_pack.lua

return {
	default_image_name = "shop_room_button_offer_small_bg_0001",
	class = "GG5Button",
	focus_image_name = "shop_room_button_offer_small_bg_0003",
	image_offset = v(-135.2, -227.5),
	hit_rect = r(-135.2, -227.5, 270.4, 430.75),
	children = {
		{
			image_name = "shop_room_9slice_shop_offer_gold_frame_",
			class = "GG59View",
			pos = v(0, 13.85),
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
			vertical_align = "middle-caps",
			text_align = "left",
			font_size = 26,
			line_height_extra = "0",
			fit_size = true,
			text = "Special offer Pack!",
			text_key = "SHOP_ROOM_OFFER_PACK_DESC",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_pack_desc",
			font_name = "fla_h",
			pos = v(-116.1, -205.6),
			scale = v(1, 1),
			size = v(158.15, 70.35),
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
			anchor = v(40.95, 32.85)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 30,
			fit_size = true,
			line_height_extra = "0",
			text = "50%",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_discount",
			font_name = "fla_numbers_2",
			pos = v(46.6, -202.2),
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
			vertical_align = "middle",
			text_align = "center",
			font_size = 21,
			line_height_extra = "0",
			fit_size = true,
			text = "off!",
			text_key = "OFF!",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_discount_off",
			font_name = "fla_h",
			pos = v(46.4, -175.65),
			scale = v(1, 1),
			size = v(77, 34.5),
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
			vertical_align = "middle",
			text_align = "center",
			font_size = 40,
			fit_size = true,
			line_height_extra = "1",
			text = "$4.99",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_pack_cost",
			font_name = "fla_numbers_2",
			pos = v(-114.15, 158.5),
			scale = v(1, 1),
			size = v(227.95, 59.55),
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
					thickness = 2.5,
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
