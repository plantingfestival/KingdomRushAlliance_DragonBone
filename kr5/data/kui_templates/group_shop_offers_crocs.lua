-- chunkname: @./kr5/data/kui_templates/group_shop_offers_crocs.lua

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
			template_name = "button_shop_offers_crocs",
			id = "button_shop_offers_bg",
			pos = v(-7.3, -18.8),
			WHEN = ctx.big_offer
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
			pos = v(-266.65, 207.5),
			size = v(473, 41.65),
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
			template_name = "group_shop_gems_special_offer_title_croc",
			pos = v(-10.75, -267.95)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_croc_art_right _",
			pos = v(331.35, 77.5),
			anchor = v(186.5, 392.85)
		},
		{
			class = "KImageView",
			image_name = "shop_room_image_crocs_art_left_",
			pos = v(-347.2, 49),
			anchor = v(219.05, 369.05)
		}
	}
}
