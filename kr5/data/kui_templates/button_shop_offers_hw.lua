-- chunkname: @./kr5/data/kui_templates/button_shop_offers_hw.lua

return {
	default_image_name = "shop_room_button_offer_big_bg_0001",
	class = "GG5Button",
	focus_image_name = "shop_room_button_offer_big_bg_0003",
	image_offset = v(-418.4, -214.35),
	hit_rect = r(-418.4, -214.35, 832.8, 430.75),
	children = {
		{
			image_name = "shop_room_9slice_shop_offer_purple_frame_",
			class = "GG59View",
			pos = v(-2.1, 13.75),
			size = v(833.7122, 432.179),
			anchor = v(416.8561, 228.237),
			slice_rect = r(19.85, 90.95, 23.6, 20.65)
		},
		{
			class = "KView"
		},
		{
			image_name = "shop_room_9slice_shop_offer_cost_bg_hw_",
			class = "GG59View",
			pos = v(-1.05, 177.2),
			size = v(819.1831, 63.6),
			anchor = v(409.5916, 31.8),
			slice_rect = r(5.25, 15.9, 5.7, 31.8)
		},
		{
			id = "image_shop_offer_discount_bg",
			image_name = "shop_room_image_shop_offer_discount_bg_hw_",
			class = "KImageView",
			pos = v(364.2, -172.3),
			anchor = v(40.95, 32.85)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			font_size = 30,
			fit_size = true,
			line_height_extra = "0",
			text = "50%",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_discount",
			font_name = "fla_numbers",
			pos = v(325.75, -198.5),
			scale = v(1, 1),
			size = v(76.8, 37.5),
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
						0.3333,
						0.0549,
						0.5255,
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
			font_name = "fla_body",
			pos = v(325.55, -170.35),
			scale = v(1, 1),
			size = v(77, 28.15),
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
						0.3333,
						0.0549,
						0.5255,
						1
					}
				}
			}
		},
		{
			vertical_align = "middle-caps",
			text_align = "center",
			font_size = 40,
			fit_size = true,
			line_height_extra = "1",
			text = "$4.99",
			class = "GG5ShaderLabel",
			id = "label_shop_offer_cost",
			font_name = "fla_numbers",
			pos = v(-403.3, 152.5),
			scale = v(1, 1),
			size = v(804.95, 48.7),
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
						0.2588,
						0,
						0.3294,
						1
					}
				}
			}
		},
		{
			template_name = "group_shop_normal_title_hw",
			class = "KView",
			id = "MovieClip4669",
			pos = v(-0.65, -174.45),
			UNLESS = ctx.custom_offer
		},
		{
			class = "KView",
			id = "cards_3",
			pos = v(-6.95, 10.45),
			UNLESS = ctx.custom_offer,
			children = {
				{
					id = "card_1",
					class = "KView",
					template_name = "group_shop_offer_card_hw",
					pos = v(-248.35, -2.7)
				},
				{
					class = "KImageView",
					image_name = "shop_room_image_room_offers_plus_sign_hw_",
					id = "image_room_offers_plus_sign",
					pos = v(121.4, -11.9),
					scale = v(1, 1),
					anchor = v(14.1, 14.1)
				},
				{
					class = "KImageView",
					image_name = "shop_room_image_room_offers_plus_sign_hw_",
					id = "image_room_offers_plus_sign",
					pos = v(-125.3, -11.9),
					scale = v(1, 1),
					anchor = v(14.1, 14.1)
				},
				{
					id = "card_2",
					class = "KView",
					template_name = "group_shop_offer_card_hw",
					pos = v(0.45, -2.7)
				},
				{
					id = "card_3",
					class = "KView",
					template_name = "group_shop_offer_card_hw",
					pos = v(249.25, -2.7)
				},
				{
					id = "multi_card_1",
					class = "KView",
					template_name = "group_card_bundle_hw",
					pos = v(-251.85, -9.05)
				},
				{
					id = "multi_card_2",
					class = "KView",
					template_name = "group_card_bundle_hw",
					pos = v(1.5, -9.05)
				},
				{
					id = "multi_card_3",
					class = "KView",
					template_name = "group_card_bundle_hw",
					pos = v(252.2, -9.05)
				}
			}
		}
	}
}
