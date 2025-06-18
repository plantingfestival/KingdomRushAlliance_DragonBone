-- chunkname: @./kr5/data/kui_templates/group_hero_room_tutorial_hero_points.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "hero_room_image_hero_room_skill_tooltip_arrow_",
			id = "label_hero_room_tutorial_points_tooltip_arrow",
			pos = v(35, 70.15),
			scale = v(1, 1),
			anchor = v(10.4, 0)
		},
		{
			class = "GG59View",
			image_name = "hero_room_9slice_hero_room_skill_tooltip_bg_",
			id = "hero_room_tutorial_power_tooltip_bg",
			pos = v(30.5, 6),
			size = v(385.874, 130.177),
			anchor = v(192.937, 65.0885),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TUTORIAL_hero_room_hero_points_title",
			font_size = 24,
			line_height_extra = "0",
			text = "Hero Points",
			class = "GG5Label",
			id = "V",
			font_name = "fla_body",
			pos = v(-143.6, -50.45),
			size = v(350.45, 41.75),
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
			text_key = "TUTORIAL_hero_room_hero_points_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Earn hero points by leveling up your hero.",
			class = "GG5Label",
			id = "label_hero_room_tutorial_hero_points_tooltip_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-143.4, -17.4),
			size = v(350.65, 80.9),
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
