-- chunkname: @./kr5/data/kui_templates/group_shop_total_gems.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "shop_room_image_shop_total_gems_bg_",
			pos = v(-5.55, -0.6),
			anchor = v(101.7, 25.35)
		},
		{
			vertical_align = "middle",
			text_align = "left",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 28,
			text = "50301",
			id = "label_shop_room_total_gems",
			fit_size = true,
			font_name = "fla_numbers",
			pos = v(-46.55, -18.35),
			size = v(129.2, 38.5),
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
