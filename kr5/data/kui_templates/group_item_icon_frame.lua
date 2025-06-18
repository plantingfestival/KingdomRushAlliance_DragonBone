-- chunkname: @./kr5/data/kui_templates/group_item_icon_frame.lua

return {
	class = "KView",
	children = {
		{
			id = "image_item_icon_frame_front",
			image_name = "item_room_image_item_icon_frame_front_",
			class = "KImageView",
			pos = v(1.5, 1),
			anchor = v(74, 76.5)
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "0",
			font_size = 30,
			text = "4",
			id = "label_item_quantity",
			fit_size = true,
			font_name = "fla_numbers",
			pos = v(-33, 25.75),
			size = v(66.05, 40.95),
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
