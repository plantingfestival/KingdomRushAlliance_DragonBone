-- chunkname: @./kr5/data/kui_templates/shop_room.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			template_name = "popup_dlc_desktop",
			class = "KView",
			id = "popup_dlc_desktop",
			pos = v(ctx.sw / 2, 512.5),
			size = v(ctx.sw, ctx.sh),
			context = ctx.context,
			UNLESS = ctx.is_mobile
		},
		{
			WHEN = false,
			class = "KView",
			id = "group_shop_room_cards_container",
			transition = "left",
			pos = v(893.75, 358.95),
			children = {
				{
					id = "group_shop_offers",
					class = "KView",
					template_name = "group_shop_offers",
					pos = v(185.55, 24.4)
				},
				{
					id = "group_shop_gems_portrait",
					class = "KView",
					template_name = "group_shop_gems_portrait",
					pos = v(-464.65, 7.1)
				},
				{
					id = "group_shop_offers_x2",
					class = "KView",
					template_name = "group_shop_offers_x2",
					pos = v(185.55, 24.4)
				},
				{
					id = "group_shop_offers_halloween",
					class = "KView",
					template_name = "group_shop_offers_halloween",
					pos = v(185.55, 24.4)
				},
				{
					id = "group_shop_offers_crocs",
					class = "KView",
					template_name = "group_shop_offers_crocs",
					pos = v(185.55, 24.4)
				},
				{
					id = "group_shop_offers_dlc_1",
					class = "KView",
					template_name = "group_shop_offers_dlc_1",
					pos = v(184.65, 24.4)
				}
			}
		},
		{
			class = "KView",
			transition_delay = 0.25,
			id = "group_shop_gems",
			transition = "down",
			pos = v(ctx.sw / 2, 0),
			WHEN = ctx.is_mobile,
			children = {
				{
					id = "group_shop_total_gems",
					class = "KView",
					template_name = "group_shop_total_gems",
					pos = v(-481.25, 39.65)
				}
			}
		},
		{
			class = "KView",
			transition_delay = 0.25,
			id = "group_shop_done",
			transition = "up",
			pos = v(ctx.sw / 2, 0),
			WHEN = ctx.is_mobile,
			children = {
				{
					id = "group_shop_room_done",
					class = "KView",
					template_name = "group_shop_room_done",
					pos = v(-0.55, 0.9)
				}
			}
		}
	}
}
