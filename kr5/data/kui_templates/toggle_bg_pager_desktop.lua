-- chunkname: @./kr5/data/kui_templates/toggle_bg_pager_desktop.lua

return {
	class = "GG5ToggleButton",
	true_image_name = "room_bg_desktop_button_pager_bg_0001",
	focus_image_name = "room_bg_desktop_button_pager_bg_0003",
	false_image_name = "room_bg_desktop_button_pager_bg_0002",
	image_offset = v(-27.4, -27.2),
	hit_rect = r(-27.4, -27.2, 54.8, 54.6),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "0",
			font_size = 26,
			text = "19",
			id = "label_page",
			font_name = "fla_numbers",
			pos = v(-19, -18.9),
			size = v(38.05, 37.25),
			colors = {
				text = {
					231,
					244,
					251
				}
			}
		}
	}
}
