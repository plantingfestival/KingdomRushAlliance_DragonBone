-- chunkname: @./kr5/data/kui_templates/group_shop_offers_bg.lua

return {
	class = "KView",
	children = {
		{
			image_name = "shop_room_9slice_shop_offer_gold_frame_",
			class = "GG59View",
			pos = v(-0.85, 14.05),
			size = v(832.8073, 430.7605),
			anchor = v(416.4037, 227.488),
			slice_rect = r(19.85, 90.95, 23.6, 20.65)
		},
		{
			image_name = "shop_room_9slice_shop_offer_cost_bg_",
			class = "GG59View",
			pos = v(-1.05, 177.2),
			size = v(819.1831, 63.6),
			anchor = v(409.5916, 31.8),
			slice_rect = r(5.25, 15.9, 5.7, 31.8)
		},
		{
			text_align = "center",
			font_size = 22,
			fit_size = true,
			line_height_extra = "0",
			text = "Melting Furnace",
			text_key = "SHOP_ROOM_OFFER_CARD_TITLE",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_card_title",
			font_name = "fla_body",
			pos = v(-329.3, 104.9),
			scale = v(1, 1),
			size = v(218.8, 31.1),
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
			font_size = 28,
			line_height_extra = "-1",
			fit_size = true,
			text = "crush your enemies from the start with these must have awesome content!",
			text_key = "SHOP_ROOM_OFFER_DESC",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_desc",
			font_name = "fla_h",
			pos = v(-399.8, -211.65),
			scale = v(1, 1),
			size = v(710.4, 80.8),
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
			id = "image_shop_offer_discount_bg",
			image_name = "shop_room_image_shop_offer_discount_bg_",
			class = "KImageView",
			pos = v(364.2, -172.3),
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
			font_name = "fla_h",
			pos = v(325.75, -204),
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
			pos = v(325.55, -173.25),
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
			id = "label_shop_offer_cost",
			font_name = "fla_h",
			pos = v(-403.3, 148.8),
			scale = v(1, 1),
			size = v(804.95, 59.55),
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
			vertical_align = "top",
			text_align = "left",
			font_size = 40,
			fit_size = true,
			line_height_extra = "1",
			text = "500 ",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_cost_gems",
			font_name = "fla_h",
			pos = v(-40.15, 147.25),
			scale = v(1, 1),
			size = v(333.25, 59.55),
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
			image_name = "shop_room_image_shop_offer_cost_gem_",
			id = "image_shop_offer_cost_gem",
			pos = v(-63.35, 173.7),
			scale = v(1, 1),
			anchor = v(21, 19.4)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_room_offers_plus_sign_",
			id = "image_room_offers_plus_sign",
			pos = v(-107.95, 1.75),
			scale = v(1, 1),
			anchor = v(14.6, 14.6)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card",
			pos = v(-220.4, -5.45),
			scale = v(1, 1),
			anchor = v(77.2, 110.65)
		},
		{
			text_align = "center",
			font_size = 22,
			fit_size = true,
			line_height_extra = "0",
			text = "Summon Blackburn",
			text_key = "SHOP_ROOM_OFFER_CARD_BUNDLE_TITLE",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_card_bundle_title",
			font_name = "fla_body",
			pos = v(-368.8, 95.1),
			scale = v(1, 1),
			size = v(238.9, 31.1),
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
			image_name = "shop_room_image_room_offers_plus_sign_",
			id = "image_room_offers_plus_sign_bundle",
			pos = v(-130.85, -6.7),
			scale = v(1, 1),
			anchor = v(14.6, 14.6)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card_bundle",
			pos = v(-269.9, -8.95),
			scale = v(0.9107, 0.9107),
			anchor = v(77.2, 110.65)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card_bundle",
			pos = v(-258.15, -8.95),
			scale = v(0.9107, 0.9107),
			anchor = v(77.2, 110.65)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_offer_card_",
			id = "image_shop_offer_card_bundle",
			pos = v(-246.8, -8.95),
			scale = v(0.9107, 0.9107),
			anchor = v(77.2, 110.65)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 40,
			fit_size = true,
			line_height_extra = "1",
			text = "X4",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_bundle_quantity",
			font_name = "fla_h",
			pos = v(-305.75, 35.2),
			scale = v(1, 1),
			size = v(117.8, 59.55),
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
