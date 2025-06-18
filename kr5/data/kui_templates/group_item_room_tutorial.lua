-- chunkname: @./kr5/data/kui_templates/group_item_room_tutorial.lua

return {
	class = "KView",
	children = {
		{
			template_name = "group_item_room_tutorial_buy",
			class = "KView",
			transition_delay = 0.15,
			id = "item_room_tutorial_buy",
			transition = "scale",
			pos = v(-122.2, 85.75)
		},
		{
			template_name = "group_item_room_tutorial_navigate",
			class = "KView",
			transition_delay = 0.15,
			id = "item_room_tutorial_navigate",
			transition = "scale",
			pos = v(-342.35, -54.65)
		},
		{
			template_name = "group_item_room_tutorial_equip",
			class = "KView",
			transition_delay = 0.15,
			id = "item_room_tutorial_equip",
			transition = "scale",
			pos = v(-446.3, 391.2)
		}
	}
}
