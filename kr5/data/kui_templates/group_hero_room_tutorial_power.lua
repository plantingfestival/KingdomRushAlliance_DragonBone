-- chunkname: @./kr5/data/kui_templates/group_hero_room_tutorial_power.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "hero_room_image_hero_room_skill_tooltip_arrow_",
			id = "label_hero_room_tutorial_power_tooltip_arrow",
			pos = v(-255, 70.15),
			scale = v(1, 1),
			anchor = v(10.4, 0)
		},
		{
			class = "GG59View",
			image_name = "hero_room_9slice_hero_room_skill_tooltip_bg_",
			id = "hero_room_tutorial_power_tooltip_bg",
			pos = v(-58.6, 3.05),
			size = v(514.0125, 136.1902),
			anchor = v(257.0062, 68.0951),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TUTORIAL_hero_room_power_title",
			font_size = 24,
			line_height_extra = "0",
			text = "Hero Powers",
			class = "GG5Label",
			id = "label_hero_room_tutorial_power_tooltip_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-292.5, -52.95),
			size = v(472.2, 44.75),
			colors = {
				text = {
					0,
					102,
					153
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TUTORIAL_hero_room_power_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Use hero points to buy and improve powers for your hero.",
			class = "GG5Label",
			id = "label_hero_room_tutorial_power_tooltip_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-292.6, -16.15),
			size = v(471.8, 76.05),
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
