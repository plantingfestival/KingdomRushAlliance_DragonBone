-- chunkname: @./kr5/data/kui_templates/group_hero_room_tutorial_navigate.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "hero_room_image_hero_room_skill_tooltip_arrow_2_",
			id = "label_hero_room_tutorial_navigate_tooltip_arrow",
			pos = v(-244.2, -109.25),
			scale = v(1, 1),
			anchor = v(10.4, 20.25)
		},
		{
			class = "GG59View",
			image_name = "hero_room_9slice_hero_room_skill_tooltip_bg_",
			id = "hero_room_tutorial_power_tooltip_bg",
			pos = v(-135.85, -56.55),
			size = v(354.6753, 105.9167),
			anchor = v(177.3376, 52.9584),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "middle",
			text_align = "left",
			text_key = "TUTORIAL_hero_room_tutorial_navigate_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Navigate through the different heroes.",
			class = "GG5Label",
			id = "label_hero_room_tutorial_navigate_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-293.7, -92.85),
			size = v(316.5, 78.75),
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
