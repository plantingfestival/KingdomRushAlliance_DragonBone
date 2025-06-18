-- chunkname: @./kr5/data/kui_templates/group_item_room_tutorial_navigate.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "item_room_image_item_room_tooltip_arrow_2_",
			id = "label_item_room_tutorial_navigate_tooltip_arrow",
			pos = v(-143.65, -109.25),
			scale = v(1, 1),
			anchor = v(10.4, 20.25)
		},
		{
			class = "GG59View",
			image_name = "item_room_9slice_item_room_tooltip_bg_",
			id = "item_room_tutorial_power_tooltip_bg",
			pos = v(-143.25, -53.35),
			size = v(416.1243, 112.2607),
			anchor = v(208.0621, 56.1304),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TUTORIAL_item_room_tutorial_navigate_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Navigate through the different power-ups.\n",
			class = "GG5Label",
			id = "label_item_room_tutorial_navigate_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-326.65, -100.9),
			size = v(370.7, 92.65),
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
