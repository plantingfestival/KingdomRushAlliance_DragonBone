-- chunkname: @./kr5/data/kui_templates/group_item_room.lua

return {
	class = "KView",
	children = {
		{
			template_name = "group_item_info_panel",
			class = "KView",
			transition_delay = 0.1,
			id = "group_item_info_panel",
			transition = "down",
			pos = v(34.65, 163.95)
		},
		{
			class = "GG5Button",
			transition_delay = 0.25,
			id = "item_room_button_confirm_ok",
			template_name = "button_item_room_confirm_ok",
			transition = "up",
			pos = v(525, 671.2),
			scale = v(1, 1)
		},
		{
			class = "KView",
			template_name = "group_item_portrait",
			id = "group_item_portrait",
			transition = "up",
			pos = v(-21.15, 437.75)
		},
		{
			class = "KView",
			template_name = "group_item_roster",
			id = "group_item_roster",
			transition = "down",
			pos = v(-395.5, 6.35)
		},
		{
			class = "KView",
			template_name = "group_item_gems",
			id = "group_item_gems",
			transition = "down",
			pos = v(-528.65, 58.25)
		},
		{
			template_name = "group_title_equipped_items",
			class = "KView",
			transition_delay = 0.15,
			id = "group_title_equipped_items",
			transition = "scale",
			pos = v(-429.95, 194.85)
		},
		{
			id = "item_room_wheel_sel_overlay",
			class = "KView",
			pos = v(-864, -17.8),
			anchor = v(0, 0),
			size = v(1728, 768)
		},
		{
			template_name = "group_items_wheel",
			class = "KView",
			transition_delay = 0.15,
			id = "group_items_wheel",
			transition = "scale",
			pos = v(-430.4, 429.6)
		}
	}
}
