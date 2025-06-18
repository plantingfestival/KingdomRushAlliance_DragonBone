-- chunkname: @./kr5/data/kui_templates/group_roster_item_quantity.lua

return {
	class = "KView",
	children = {
		{
			image_name = "item_room_image_roster_item_quantity_",
			class = "KImageView",
			pos = v(-23.1, -11.7),
			scale = v(1.1876, 0.6214),
			anchor = v(0, 0)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 23,
			text = "10",
			id = "label_roster_item_quantity",
			fit_size = true,
			font_name = "fla_numbers",
			pos = v(-21.6, -16.85),
			size = v(43.75, 32.35),
			colors = {
				text = {
					222,
					247,
					255
				}
			}
		}
	}
}
