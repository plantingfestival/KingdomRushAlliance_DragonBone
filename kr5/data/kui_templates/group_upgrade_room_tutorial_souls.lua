-- chunkname: @./kr5/data/kui_templates/group_upgrade_room_tutorial_souls.lua

return {
	class = "KView",
	children = {
		{
			class = "GG59View",
			image_name = "upgrades_room_9slice_hero_room_skill_tooltip_bg_",
			id = "hero_room_skill_tooltip_bg",
			pos = v(185.3, 45.75),
			size = v(402.002, 123.3545),
			anchor = v(201.001, 61.6772),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			class = "KImageView",
			image_name = "upgrades_room_image_upgrades_room_tooltip_arrow_down_",
			id = "upgrade_tooltip_arrow_5",
			pos = v(157.6, 104.4),
			scale = v(1, 1),
			anchor = v(10.8, 2.6)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TUTORIAL_upgrade_room_tooltip_souls_title",
			font_size = 24,
			line_height_extra = "0",
			fit_size = true,
			text = "Souls",
			class = "GG5Label",
			id = "label_upgrade_room_tutorial_tooltip_souls_title",
			font_name = "fla_body",
			pos = v(5.05, -8.95),
			scale = v(1.0648, 1),
			size = v(362.95, 39),
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
			text_key = "TUTORIAL_upgrade_room_tooltip_souls_desc",
			font_size = 24,
			line_height_extra = "0",
			fit_size = true,
			text = "Earn souls by completing the campaign stages.",
			class = "GG5Label",
			id = "label_upgrade_room_tutorial_tooltip_souls_desc",
			font_name = "fla_body",
			pos = v(5.05, 22.45),
			scale = v(1.0648, 1),
			size = v(362.45, 77.2),
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
