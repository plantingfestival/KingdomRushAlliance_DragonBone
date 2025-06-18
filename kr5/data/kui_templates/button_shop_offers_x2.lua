-- chunkname: @./kr5/data/kui_templates/button_shop_offers_x2.lua

return {
	default_image_name = "shop_room_button_offer_big_bg_x2_0001",
	class = "GG5Button",
	focus_image_name = "shop_room_button_offer_big_bg_x2_0003",
	image_offset = v(-418.4, -214.35),
	hit_rect = r(-418.4, -214.35, 832.8, 430.75),
	children = {
		{
			image_name = "shop_room_9slice_shop_offer_gold_frame_x2_",
			class = "GG59View",
			pos = v(-1.3, 13.15),
			size = v(621.9877, 430.7605),
			anchor = v(310.9938, 227.488),
			slice_rect = r(19.85, 90.95, 23.6, 20.65)
		},
		{
			image_name = "shop_room_9slice_shop_offer_cost_bg_",
			class = "GG59View",
			pos = v(-2.25, 177.8),
			size = v(610.3174, 64.9771),
			anchor = v(305.1587, 32.4885),
			slice_rect = r(5.25, 15.9, 5.7, 31.8)
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 28,
			line_height_extra = "0",
			text_key = "SHOP_ROOM_OFFER_DESC",
			text = "crush your enemies from the start with these must have",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_desc",
			font_name = "fla_h",
			pos = v(-222.05, -201.75),
			scale = v(1, 1),
			size = v(433.9, 81.8),
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
			pos = v(263.2, -173.95),
			anchor = v(40.95, 32.85)
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
			font_name = "fla_numbers_2",
			pos = v(-295.55, 159.2),
			scale = v(1, 1),
			size = v(589.05, 59.55),
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
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 30,
			fit_size = true,
			line_height_extra = "0",
			text = "50%",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_discount",
			font_name = "fla_numbers_2",
			pos = v(224.95, -199.7),
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
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 21,
			line_height_extra = "0",
			fit_size = true,
			text = "off!",
			text_key = "OFF!",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_discount_off",
			font_name = "fla_h",
			pos = v(224.75, -172.35),
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
			class = "KView",
			id = "cards_3",
			pos = v(-0.45, 10.45),
			UNLESS = ctx.custom_offer,
			children = {
				{
					class = "KImageView",
					image_name = "shop_room_image_room_offers_plus_sign_",
					id = "image_room_offers_plus_sign",
					pos = v(-0.05, 0),
					scale = v(1, 1),
					anchor = v(14.6, 14.6)
				},
				{
					id = "card_1",
					class = "KView",
					template_name = "group_shop_offer_card",
					pos = v(-138.95, 0)
				},
				{
					id = "card_2",
					class = "KView",
					template_name = "group_shop_offer_card",
					pos = v(138.95, 0)
				},
				{
					id = "multi_card_1",
					class = "KView",
					template_name = "group_card_bundle",
					pos = v(-142.4, -6.35)
				},
				{
					id = "multi_card_2",
					class = "KView",
					template_name = "group_card_bundle",
					pos = v(140.55, -6.85)
				}
			}
		}
	}
}
