-- chunkname: @./kr5/data/kui_templates/ingame_shop_kui.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			class = "KView",
			template_name = "group_ingame_shop_item_gems",
			id = "group_item_gems",
			transition = "down",
			pos = v(ctx.safe_frame.l, 0)
		},
		{
			class = "KView",
			id = "group_item_portraits",
			transition = "down",
			pos = v(ctx.sw / 2, 388),
			children = {
				{
					id = "group_item_portrait_01",
					class = "KView",
					template_name = "group_ingame_shop_item_portrait",
					pos = v(-376.15, -384.9)
				},
				{
					id = "group_item_portrait_02",
					class = "KView",
					template_name = "group_ingame_shop_item_portrait",
					pos = v(-1.2, -384.9)
				},
				{
					id = "group_item_portrait_03",
					class = "KView",
					template_name = "group_ingame_shop_item_portrait",
					pos = v(373.75, -384.9)
				}
			}
		},
		{
			id = "group_ingame_shop_cards_container",
			class = "KView",
			pos = v(864, 0),
			children = {
				{
					id = "button_shop_gems_portrait",
					class = "GG5Button",
					template_name = "button_ingame_shop_gems_portrait",
					pos = v(-402.1, 371.6)
				}
			}
		},
		{
			class = "KView",
			id = "group_ingame_shop_button_ok_gems",
			transition = "up",
			pos = v(ctx.sw - ctx.safe_frame.r, 768),
			children = {
				{
					class = "GG5Button",
					template_name = "button_ingame_shop_confirm_ok",
					id = "button_ingame_shop_confirm_ok_gems",
					pos = v(-101.2, -71),
					scale = v(1, 1)
				}
			}
		},
		{
			id = "group_ingame_shop_button_ok_item",
			class = "KView",
			pos = v(ctx.sw / 2, 768),
			children = {
				{
					text_key = "BUTTON_DONE",
					class = "GG5Button",
					template_name = "button_ingame_shop_confirm_ok",
					id = "button_ingame_shop_confirm_ok_item",
					pos = v(-101.2, -71),
					scale = v(1, 1)
				}
			}
		}
	}
}
