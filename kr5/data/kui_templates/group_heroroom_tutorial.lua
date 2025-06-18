-- chunkname: @./kr5/data/kui_templates/group_heroroom_tutorial.lua

return {
	class = "KView",
	children = {
		{
			template_name = "group_hero_room_tutorial_power",
			class = "KView",
			transition_delay = 0.15,
			id = "hero_room_tutorial_power",
			transition = "scale",
			pos = v(182.65, 71.35)
		},
		{
			template_name = "group_hero_room_tutorial_select",
			class = "KView",
			transition_delay = 0.15,
			id = "hero_room_tutorial_select",
			transition = "scale",
			pos = v(-179.75, 205.4)
		},
		{
			template_name = "group_hero_room_tutorial_hero_points",
			class = "KView",
			transition_delay = 0.15,
			id = "hero_room_tutorial_hero_points",
			transition = "scale",
			pos = v(160.9, -247.6)
		},
		{
			template_name = "group_hero_room_tutorial_navigate",
			class = "KView",
			transition_delay = 0.15,
			id = "hero_room_tutorial_navigate",
			transition = "scale",
			pos = v(-146.9, -54.65)
		}
	}
}
