-- chunkname: @./kr5/data/kui_templates/group_shop_offers.lua

return {
	class = "KView",
	children = {
		{
			image_name = "shop_room_9slice_shadow_roster_",
			class = "GG59View",
			pos = v(-9.55, -10.9),
			size = v(921.308, 525.0589),
			anchor = v(460.654, 262.3929),
			slice_rect = r(50.6, 33.45, 23, 35.05)
		},
		{
			image_name = "shop_room_9slice_shop_offer_frame_",
			class = "GG59View",
			pos = v(-7.2, -13),
			size = v(893.9337, 521.7),
			anchor = v(449.756, 261.7),
			slice_rect = r(42, 183.4, 46.05, 154.05)
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers",
			id = "button_shop_offers_bg",
			pos = v(-7.3, -18.8),
			WHEN = ctx.big_offer
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers_pack",
			id = "button_shop_offers_pack_01",
			pos = v(-290.5, -17),
			WHEN = ctx.small_offers
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers_pack",
			id = "button_shop_offers_pack_02",
			pos = v(-7.2, -17),
			WHEN = ctx.small_offers
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers_pack",
			id = "button_shop_offers_pack_03",
			pos = v(274.95, -17),
			WHEN = ctx.small_offers
		},
		{
			id = "image_shop_offer_ends_bg",
			image_name = "shop_room_image_shop_offer_ends_bg_",
			class = "KImageView",
			pos = v(54.1, 227.5),
			anchor = v(366.7, 16.8)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			text_key = "SHOP_ROOM_OFFER_ENDS_TIME",
			font_size = 23,
			line_height_extra = "0",
			text = "Offer ends in: 12h 9min",
			class = "GG5Label",
			id = "label_shop_offer_ends_time",
			font_name = "fla_body",
			pos = v(-299.95, 207.5),
			size = v(580.95, 41.65),
			colors = {
				text = {
					255,
					255,
					255
				}
			}
		},
		{
			class = "KView",
			pos = v(-10.75, -267.95),
			children = {
				{
					class = "KImageView",
					image_name = "shop_room_image_shop_offer_title_bg_",
					pos = v(2.05, -1.1),
					anchor = v(344.7, 28.7)
				},
				{
					vertical_align = "middle",
					text_align = "center",
					font_size = 34,
					line_height_extra = "1",
					text_key = "SHOP_ROOM_OFFER_TITLE",
					text = "STARTER PACK!",
					class = "GG5ShaderLabel",
					id = "label_shop_offer_title",
					font_name = "fla_h",
					pos = v(-298.75, -26.2),
					scale = v(1, 1),
					size = v(600.85, 51.2),
					colors = {
						text = {
							242,
							235,
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
								0.1569,
								0.3529,
								0.5216,
								1
							}
						}
					}
				}
			}
		},
		{
			class = "KView",
			template_name = "group_shop_gems_special_offer_title",
			pos = v(-10.75, -267.95)
		}
	}
}
