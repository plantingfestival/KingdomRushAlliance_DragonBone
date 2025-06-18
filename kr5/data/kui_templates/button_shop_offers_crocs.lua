-- chunkname: @./kr5/data/kui_templates/button_shop_offers_crocs.lua

return {
	default_image_name = "shop_room_button_offer_big_bg_0001",
	class = "GG5Button",
	focus_image_name = "shop_room_button_offer_big_bg_0003",
	image_offset = v(-418.4, -214.35),
	hit_rect = r(-418.4, -214.35, 832.8, 430.75),
	children = {
		{
			image_name = "shop_room_9slice_shop_offer_green_frame_crocs_",
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
			image_name = "shop_room_image_shop_offer_discount_bg_crocs_",
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
			font_name = "fla_numbers_2",
			pos = v(325.75, -198.5),
			scale = v(1, 1),
			size = v(76.8, 45.7),
			colors = {
				text = {
					233,
					246,
					209
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
						0.2,
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
			pos = v(325.55, -170.35),
			scale = v(1, 1),
			size = v(77, 33.15),
			colors = {
				text = {
					233,
					246,
					209
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
						0.2,
						0,
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
			font_name = "fla_numbers_2",
			pos = v(-403.3, 152.5),
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
						0,
						0.2,
						0,
						1
					}
				}
			}
		},
		{
			template_name = "group_shop_normal_title_crocs",
			class = "KView",
			id = "MovieClip4669",
			pos = v(-0.65, -174.45),
			UNLESS = ctx.custom_offer
		},
		{
			class = "KView",
			id = "cards_3",
			pos = v(-0.95, 10.45),
			UNLESS = ctx.custom_offer,
			children = {
				{
					class = "KImageView",
					image_name = "shop_room_image_room_offers_plus_sign_crocs_",
					id = "image_room_offers_plus_sign",
					pos = v(-1.6, -11.9),
					scale = v(1, 1),
					anchor = v(14.1, 14.1)
				},
				{
					id = "card_1",
					class = "KView",
					template_name = "group_shop_offer_card_crocs",
					pos = v(-122.55, -2.7)
				},
				{
					id = "card_2",
					class = "KView",
					template_name = "group_shop_offer_card_crocs",
					pos = v(126.25, -2.7)
				},
				{
					id = "multi_card_1",
					class = "KView",
					template_name = "group_card_bundle_hw",
					pos = v(-128.85, -9.05)
				},
				{
					id = "multi_card_2",
					class = "KView",
					template_name = "group_card_bundle_hw",
					pos = v(124.5, -9.05)
				}
			}
		}
	}
}
