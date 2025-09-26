-- chunkname: @./kr5/data/kui_templates/room_encyclopedia.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			class = "KView",
			template_name = "group_encyclopedia_room",
			id = "group_encyclopedia_room",
			pos = v(ctx.sw / 2, 382.55),
			scale = v(1.15, 1.15)
		}
	}
}
