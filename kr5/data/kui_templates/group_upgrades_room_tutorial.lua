-- chunkname: @./kr5/data/kui_templates/group_upgrades_room_tutorial.lua

return {
	class = "KView",
	children = {
		{
			template_name = "group_upgrade_room_tutorial_souls",
			class = "KView",
			transition_delay = 0.15,
			id = "upgrade_room_tutorial_souls",
			transition = "scale",
			pos = v(-435.05, -42.9)
		},
		{
			template_name = "group_upgrade_room_tutorial_buy",
			class = "KView",
			transition_delay = 0.15,
			id = "upgrade_room_tutorial_buy",
			transition = "scale",
			pos = v(208.55, -181.6)
		}
	}
}
