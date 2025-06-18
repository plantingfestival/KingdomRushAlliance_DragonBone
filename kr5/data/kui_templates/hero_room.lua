-- chunkname: @./kr5/data/kui_templates/hero_room.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "group_heroroom_bg",
			class = "KView",
			pos = v(ctx.sw / 2, 384.2),
			children = {
				{
					class = "GG59View",
					image_name = "hero_room_9slice_bg_temp_",
					pos = v(-900, -384.35),
					size = v(1799.9969, 768.2),
					slice_rect = r(7.3, 7.05, 34.95, 757.25)
				}
			}
		},
		{
			class = "KView"
		},
		{
			id = "group_heroroom",
			class = "KView",
			template_name = "group_heroroom",
			pos = v(ctx.sw / 2, 18.65)
		},
		{
			id = "group_hero_room_tutorial_CENTER",
			class = "KView",
			template_name = "group_heroroom_tutorial",
			pos = v(1025.75, 342.65)
		}
	}
}
