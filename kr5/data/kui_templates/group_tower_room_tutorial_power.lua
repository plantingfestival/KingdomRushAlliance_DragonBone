-- chunkname: @./kr5/data/kui_templates/group_tower_room_tutorial_power.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_room_skill_tooltip_arrow_",
			id = "label_tower_room_tutorial_power_tooltip_arrow",
			pos = v(-209.8, 70.15),
			scale = v(1, 1),
			anchor = v(10.35, 0)
		},
		{
			class = "GG59View",
			image_name = "tower_room_9slice_tower_room_skill_tooltip_bg_",
			id = "tower_room_tutorial_power_tooltip_bg",
			pos = v(-81.5, 7.1),
			size = v(456.9385, 128.0115),
			anchor = v(228.4692, 64.0057),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TUTORIAL_tower_room_power_title",
			font_size = 24,
			line_height_extra = "0",
			text = "Lvl 4 Powers",
			class = "GG5Label",
			id = "label_tower_room_tutorial_power_tooltip_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-288.9, -51.5),
			size = v(417.5, 33.55),
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
			text_key = "TUTORIAL_tower_room_power_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "When your towers reach level 4 you can use two powers",
			class = "GG5Label",
			id = "label_tower_room_tutorial_power_tooltip_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-288.95, -15.2),
			size = v(417.3, 75.15),
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
