-- chunkname: @./kr5/data/kui_templates/group_shop_offers_dlc_2.lua

return {
	class = "KView",
	children = {
		{
			image_name = "shop_room_9slice_shadow_roster_",
			class = "GG59View",
			pos = v(-9.55, -10.9),
			size = v(921.308, 525.0574),
			anchor = v(460.654, 262.3922),
			slice_rect = r(50.6, 33.45, 23, 35.05)
		},
		{
			image_name = "shop_room_9slice_shop_offer_frame_w_",
			class = "GG59View",
			pos = v(-7.2, -13),
			size = v(893.9337, 521.7),
			anchor = v(449.756, 261.7),
			slice_rect = r(42, 183.4, 46.05, 154.05)
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers_wukong_video",
			id = "button_shop_offers_bg",
			pos = v(-6, -18.8),
			WHEN = ctx.show_video
		},
		{
			class = "GG5Button",
			template_name = "button_shop_offers_wukong",
			id = "button_shop_offers_bg",
			pos = v(-7.3, -18.8),
			WHEN = ctx.big_offer and not ctx.show_video
		},
		{
			class = "KView",
			template_name = "group_shop_gems_special_offer_title_wukong",
			pos = v(-10.75, -267.95)
		},
		{
			image_name = "shop_room_image_wukong_art_right_",
			class = "KImageView",
			pos = v(331.35, 77.5),
			UNLESS = ctx.show_video,
			anchor = v(209.95, 363.6)
		},
		{
			image_name = "shop_room_image_wukong_art_left_",
			class = "KImageView",
			pos = v(-347.2, 49),
			UNLESS = ctx.show_video,
			anchor = v(187.55, 334.3)
		},
		{
			image_name = "shop_room_image_wukong_dlc2_art_right_video_",
			class = "KImageView",
			pos = v(331.55, 77.5),
			WHEN = ctx.show_video,
			anchor = v(83.5, 363.6)
		},
		{
			image_name = "shop_room_image_wukong_dlc2_art_left_video_",
			class = "KImageView",
			pos = v(-347.2, 49),
			WHEN = ctx.show_video,
			anchor = v(187.55, 334.3)
		},
		{
			class = "KView",
			template_name = "group_shop_gems_dlc_title_wukong",
			pos = v(-10.75, -197.9)
		},
		{
			focus_image_name = "shop_room_button_offer_info_0003",
			class = "GG5Button",
			id = "button_offer_info",
			default_image_name = "shop_room_button_offer_info_0001",
			pos = v(-378.55, -201.95),
			image_offset = v(-24.9, -25.5),
			hit_rect = r(-24.9, -25.5, 52, 54),
			children = {
				{
					id = "image_button_hotspot",
					class = "KImageView",
					image_name = "shop_room_image_button_hotspot_",
					anchor = v(39.85, 39.85)
				}
			}
		},
		{
			id = "group_mode_tooltip_2",
			class = "KView",
			pos = v(-369.3, -105.95),
			children = {
				{
					class = "KImageView",
					image_name = "shop_room_image_hero_room_skill_tooltip_arrow_",
					id = "image_mode_tooltip_arrow",
					pos = v(-10.2, -45.85),
					scale = v(1, 1),
					anchor = v(10.4, 8.5)
				},
				{
					class = "GG59View",
					image_name = "shop_room_9slice_offer_info_tooltip_bg_",
					id = "hero_room_skill_tooltip_bg",
					pos = v(145.2, 89.3),
					size = v(393.3765, 248.1006),
					anchor = v(196.6882, 124.0503),
					slice_rect = r(20, 20, 40, 40)
				},
				{
					vertical_align = "middle",
					text_align = "center",
					text_key = "SHOP_ROOM_DLC_2_TOOLTIP_TITLE",
					font_size = 21,
					line_height_extra = "0",
					text = "TOOLTIP TITLE",
					class = "GG5Label",
					id = "label_info_tooltip_title",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-38.75, -22.6),
					size = v(369.15, 33.7),
					colors = {
						text = {
							45,
							94,
							152
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "center",
					text_key = "SHOP_ROOM_DLC_2_TOOLTIP_DESCRIPTION",
					font_size = 21,
					line_height_extra = "-2",
					text = "25 New Stages\nNew Tower\nNew Hero\nOver XX New Enemies\nXX Mini Bosses\nAn epic Boss Fight\nAnd More...",
					class = "GG5Label",
					id = "label_info_tooltip_desc",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-38.75, 17.3),
					size = v(369.15, 183.4),
					colors = {
						text = {
							48,
							46,
							38
						}
					}
				}
			}
		}
	}
}
