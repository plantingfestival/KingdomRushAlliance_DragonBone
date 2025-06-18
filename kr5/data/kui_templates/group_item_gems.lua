-- chunkname: @./kr5/data/kui_templates/group_item_gems.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "item_room_image_item_gems_bg_",
			pos = v(-5.55, -0.6),
			anchor = v(101.7, 25.35)
		},
		{
			vertical_align = "top",
			text_align = "left",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 28,
			text = "50301",
			id = "label_item_room_gems",
			fit_size = true,
			font_name = "fla_numbers",
			pos = v(-51.8, -17.95),
			size = v(98.5, 38.5),
			colors = {
				text = {
					222,
					247,
					255
				}
			}
		},
		{
			id = "button_item_room_buy_gems",
			focus_image_name = "item_room_button_item_room_buy_gems_0003",
			class = "GG5Button",
			default_image_name = "item_room_button_item_room_buy_gems_0001",
			pos = v(79, 0.95),
			anchor = v(38.4, 36.2)
		}
	}
}
