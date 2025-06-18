-- chunkname: @./kr5/data/kui_templates/upgrades_room.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			image_name = "upgrades_room_9slice_bg_temp_",
			class = "GG59View",
			pos = v(-36, -0.25),
			size = v(1800, 768.0007),
			anchor = v(0, -0.2499),
			slice_rect = r(7.3, 7.05, 34.95, 757.25)
		},
		{
			id = "group_upgrades_room",
			class = "KView",
			template_name = "group_upgrades_room",
			pos = v(ctx.sw / 2, 0)
		},
		{
			id = "group_upgrades_room_tutorial",
			class = "KView",
			template_name = "group_upgrades_room_tutorial",
			pos = v(ctx.sw / 2, 591)
		}
	}
}
