-- chunkname: @./kr5/data/kui_templates/toggle_encyclopedia_pager.lua

return {
	class = "GG5ToggleButton",
	true_image_name = "room_encyclopedia_button_pager_0001",
	focus_image_name = "room_encyclopedia_button_pager_0003",
	false_image_name = "room_encyclopedia_button_pager_0002",
	image_offset = v(-16, -16.55),
	hit_rect = r(-16, -16.55, 32.9, 33.25),
	children = {
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "0",
			font_size = 19,
			text = "19",
			id = "label_page_selected",
			font_name = "fla_numbers_2",
			pos = v(-13.25, -10.95),
			size = v(26.25, 21.2),
			colors = {
				text = {
					97,
					56,
					41
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "0",
			font_size = 19,
			text = "19",
			id = "label_page",
			font_name = "fla_numbers_2",
			pos = v(-13.25, -10.95),
			size = v(26.25, 21.2),
			colors = {
				text = {
					250,
					232,
					195
				}
			}
		}
	}
}
