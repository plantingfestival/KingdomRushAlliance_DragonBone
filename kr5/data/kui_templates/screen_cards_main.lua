-- chunkname: @./kr5/data/kui_templates/screen_cards_main.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "group_card_1",
			class = "KView",
			template_name = "group_card_1",
			pos = v(ctx.sw / 2, 384)
		},
		{
			id = "group_card_2",
			class = "KView",
			template_name = "group_card_2",
			pos = v(ctx.sw / 2, 384)
		},
		{
			id = "group_card_3",
			class = "KView",
			template_name = "group_card_3",
			pos = v(ctx.sw / 2, 384)
		},
		{
			id = "group_card_4",
			class = "KView",
			template_name = "group_card_4",
			pos = v(ctx.sw / 2, 384)
		}
	}
}
