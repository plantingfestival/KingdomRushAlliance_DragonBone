-- chunkname: @./kr5/data/kui_templates/group_tower_room_tutorial_navigate.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_room_skill_tooltip_arrow_2_",
			id = "label_tower_room_tutorial_navigate_tooltip_arrow",
			pos = v(-244.2, -109.95),
			scale = v(1, 1),
			anchor = v(10.35, 21.5)
		},
		{
			class = "GG59View",
			image_name = "tower_room_9slice_tower_room_skill_tooltip_bg_",
			id = "tower_room_tutorial_power_tooltip_bg",
			pos = v(-135.85, -59.75),
			size = v(344.9512, 99.4128),
			anchor = v(172.4756, 49.7064),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "middle",
			text_align = "left",
			text_key = "TUTORIAL_tower_room_tutorial_navigate_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Navigate through the different towers.",
			class = "GG5Label",
			id = "label_tower_room_tutorial_navigate_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-289.8, -102.05),
			size = v(308.7, 80.25),
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
