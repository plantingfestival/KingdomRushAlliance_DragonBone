-- chunkname: @./kr5/data/kui_templates/group_tower_room_tutorial.lua

return {
	class = "KView",
	children = {
		{
			template_name = "group_tower_room_tutorial_power",
			class = "KView",
			transition_delay = 0.15,
			id = "tower_room_tutorial_power",
			transition = "scale",
			pos = v(351.25, 74.7)
		},
		{
			template_name = "group_tower_room_tutorial_equip",
			class = "KView",
			transition_delay = 0.15,
			id = "tower_room_tutorial_equip",
			transition = "scale",
			pos = v(-60.9, 187.9)
		},
		{
			template_name = "group_tower_room_tutorial_navigate",
			class = "KView",
			transition_delay = 0.15,
			id = "tower_room_tutorial_navigate",
			transition = "scale",
			pos = v(-361.05, -60.45)
		},
		{
			template_name = "group_tower_room_tutorial_slots",
			class = "KView",
			transition_delay = 0.15,
			id = "tower_room_tutorial_slots",
			transition = "scale",
			pos = v(-466, 390.7)
		}
	}
}
