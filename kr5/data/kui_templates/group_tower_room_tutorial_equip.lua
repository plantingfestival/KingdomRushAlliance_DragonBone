-- chunkname: @./kr5/data/kui_templates/group_tower_room_tutorial_equip.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_room_skill_tooltip_arrow_",
			id = "label_tower_room_tutorial_select_tooltip_arrow",
			pos = v(-141.2, 70.15),
			scale = v(1, 1),
			anchor = v(10.35, 0)
		},
		{
			class = "GG59View",
			image_name = "tower_room_9slice_tower_room_skill_tooltip_bg_",
			id = "tower_room_tutorial_equip_tooltip_bg",
			pos = v(-139.85, 20.5),
			size = v(356.1267, 101.2939),
			anchor = v(178.0634, 50.647),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "middle",
			text_align = "left",
			text_key = "TUTORIAL_tower_room_tutorial_equip_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "You can equip new towers to try different ",
			class = "GG5Label",
			id = "label_tower_room_tutorial_equip_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-295.2, -21.5),
			size = v(311.9, 78.1),
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
