-- chunkname: @./kr5/data/kui_templates/group_shop_title_gems.lua

return {
	class = "KView",
	children = {
		{
			image_name = "shop_room_9slice_info_bg_",
			class = "GG59View",
			pos = v(-151.35, -20.2),
			size = v(309.455, 40.446),
			anchor = v(0, 0),
			slice_rect = r(15.2, 15, 9.75, 10.2)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			text_key = "SHOP_ROOM_GEMS_TITLE",
			font_size = 25,
			line_height_extra = "0",
			text = "HANDFUL OF GEMS",
			class = "GG5Label",
			id = "label_shop_title_gems",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-145.35, -23.3),
			size = v(294.75, 45.65),
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
