-- chunkname: @./kr5/data/kui_templates/group_item_room_tutorial_equip.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "item_room_image_item_room_tooltip_arrow_2_",
			id = "label_item_room_tutorial_equip_tooltip_arrow",
			pos = v(-143.65, -109.25),
			scale = v(1, 1),
			anchor = v(10.4, 20.25)
		},
		{
			class = "GG59View",
			image_name = "item_room_9slice_item_room_tooltip_bg_",
			id = "item_room_tutorial_power_tooltip_bg",
			pos = v(-143.25, -53.25),
			size = v(430.5249, 112.3706),
			anchor = v(215.2625, 56.1853),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TUTORIAL_item_room_tutorial_equip_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Use slots to equip power-ups. Drag to switch between them.\n",
			class = "GG5Label",
			id = "label_item_room_tutorial_equip_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-334.35, -100.15),
			size = v(383.9, 92.65),
			colors = {
				text = {
					76,
					70,
					70
				}
			}
		}
	}
}
