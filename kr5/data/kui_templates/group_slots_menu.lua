-- chunkname: @./kr5/data/kui_templates/group_slots_menu.lua

return {
	class = "KView",
	children = {
		{
			image_name = "screen_slots_image_slots_panel_bg_",
			class = "KImageView",
			anchor = v(432.8, 272.2)
		},
		{
			id = "slot_1",
			class = "SlotView",
			template_name = "group_slot",
			pos = v(3.8, -135.8)
		},
		{
			id = "slot_2",
			class = "SlotView",
			template_name = "group_slot",
			pos = v(3.8, 39.55)
		},
		{
			id = "slot_3",
			class = "SlotView",
			template_name = "group_slot",
			pos = v(3.8, 216.6)
		},
		{
			class = "GG5Button",
			focus_image_name = "screen_slots_button_close_slots_sindow_0003",
			id = "button_close_popup",
			default_image_name = "screen_slots_button_close_slots_sindow_0001",
			pos = v(337.95, -244.65),
			scale = v(1, 1),
			anchor = v(53.6, 45.25)
		}
	}
}
