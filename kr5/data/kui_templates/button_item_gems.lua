-- chunkname: @./kr5/data/kui_templates/button_item_gems.lua

return {
	focus_image_name = "item_room_undefined_0003",
	default_image_name = "item_room_undefined_0001",
	class = "GG5Button",
	children = {
		{
			class = "KImageView",
			image_name = "item_room_image_item_gems_bg_",
			pos = v(-7, -2.65),
			anchor = v(101.9, 26.5)
		},
		{
			vertical_align = "top",
			text_align = "left",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 20,
			text = "50301",
			id = "label_item_room_gems",
			fit_size = true,
			font_name = "body",
			pos = v(-44.9, -10.85),
			size = v(88.6, 25),
			colors = {
				text = {
					222,
					247,
					255
				}
			}
		},
		{
			focus_image_name = "item_room_button_item_room_buy_gems_0003",
			class = "GG5Button",
			default_image_name = "item_room_button_item_room_buy_gems_0001",
			pos = v(77.55, -1.1),
			anchor = v(38.4, 36.2)
		}
	}
}
