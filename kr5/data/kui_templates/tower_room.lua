-- chunkname: @./kr5/data/kui_templates/tower_room.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "v",
			class = "KView",
			template_name = "group_tower_room_bg",
			pos = v(865, 384.2)
		},
		{
			id = "group_towerroom",
			class = "KView",
			template_name = "group_tower_room",
			pos = v(ctx.sw / 2, 23.4)
		},
		{
			id = "group_tower_room_tutorial_CENTER",
			class = "KView",
			template_name = "group_tower_room_tutorial",
			pos = v(1025.75, 342.65)
		}
	}
}
