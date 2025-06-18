-- chunkname: @./kr5/data/kui_templates/group_item_ring_quantity.lua

return {
	class = "KView",
	children = {
		{
			id = "image_item_ring_quantity_bg",
			class = "KView",
			anchor = v(44.15, 22.15)
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
			font_name = "body",
			pos = v(-33.35, -16.95),
			size = v(66.05, 33.05),
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
