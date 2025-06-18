-- chunkname: @./kr5/data/kui_templates/difficulty_room.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "group_difficulty_room",
			class = "KView",
			template_name = "group_difficulty_room",
			pos = v(ctx.sw / 2, 384)
		}
	}
}
