-- chunkname: @./kr5/data/kui_templates/group_shop_offers_x2.lua

return {
	class = "KView",
	children = {
		{
			image_name = "shop_room_9slice_shadow_roster_",
			class = "GG59View",
			pos = v(-9.15, -9.5),
			size = v(702.0347, 526.6668),
			anchor = v(351.0174, 263.1965),
			slice_rect = r(50.6, 33.45, 23, 35.05)
		},
		{
			image_name = "shop_room_9slice_shop_offer_frame_",
			class = "GG59View",
			pos = v(-7.5, -13),
			size = v(688.1791, 521.7),
			anchor = v(346.2367, 261.7),
			slice_rect = r(42, 183.4, 46.05, 154.05)
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers_x2",
			id = "button_shop_offers_bg",
			pos = v(-7.3, -18.8),
			WHEN = ctx.big_offer
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers_pack",
			id = "button_shop_offers_pack_01",
			pos = v(-153.7, -17),
			WHEN = ctx.small_offers
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers_pack",
			id = "button_shop_offers_pack_02",
			pos = v(140.85, -17),
			WHEN = ctx.small_offers
		},
		{
			id = "image_shop_offer_ends_bg",
			image_name = "shop_room_image_shop_offer_ends_bg_",
			class = "KImageView",
			pos = v(57.9, 227.5),
			anchor = v(366.7, 16.8)
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "SHOP_ROOM_OFFER_ENDS_TIME",
			font_size = 23,
			line_height_extra = "0",
			text = "Offer ends in: 12h 9min",
			class = "GG5Label",
			id = "label_shop_offer_ends_time",
			font_name = "fla_body",
			pos = v(-297.55, 210),
			size = v(580.95, 32.35),
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
			template_name = "group_shop_gems_offer_title_x2",
			pos = v(-10.75, -267.95)
		},
		{
			class = "KView",
			template_name = "group_shop_gems_special_offer_title_X2",
			pos = v(-10.75, -267.95)
		}
	}
}
