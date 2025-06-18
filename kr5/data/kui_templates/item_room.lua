-- chunkname: @./kr5/data/kui_templates/item_room.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "group_item_room",
			class = "KView",
			template_name = "group_item_room",
			pos = v(ctx.sw / 2, 17.8)
		},
		{
			id = "group_item_room_tutorial_CENTER",
			class = "KView",
			template_name = "group_item_room_tutorial",
			pos = v(1025.75, 342.65)
		}
	}
}
