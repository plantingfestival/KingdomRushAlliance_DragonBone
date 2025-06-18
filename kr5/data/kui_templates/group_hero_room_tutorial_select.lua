-- chunkname: @./kr5/data/kui_templates/group_hero_room_tutorial_select.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "hero_room_image_hero_room_skill_tooltip_arrow_",
			id = "label_hero_room_tutorial_select_tooltip_arrow",
			pos = v(-141.2, 70.15),
			scale = v(1, 1),
			anchor = v(10.4, 0)
		},
		{
			class = "GG59View",
			image_name = "hero_room_9slice_hero_room_skill_tooltip_bg_",
			id = "hero_room_tutorial_power_tooltip_bg",
			pos = v(-140.05, 17.25),
			size = v(349.9414, 107.7002),
			anchor = v(174.9707, 53.8501),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "middle",
			text_align = "left",
			text_key = "TUTORIAL_hero_room_tutorial_select_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Select the hero you want to use in the battlefield.",
			class = "GG5Label",
			id = "label_hero_room_tutorial_select_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-297.15, -26),
			size = v(314.85, 84.85),
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
