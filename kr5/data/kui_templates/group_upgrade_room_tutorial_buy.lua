-- chunkname: @./kr5/data/kui_templates/group_upgrade_room_tutorial_buy.lua

return {
	class = "KView",
	children = {
		{
			class = "GG59View",
			image_name = "upgrades_room_9slice_hero_room_skill_tooltip_bg_",
			id = "hero_room_skill_tooltip_bg",
			pos = v(179.9, 41.15),
			size = v(416.8945, 124.6851),
			anchor = v(208.4473, 62.3425),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			class = "KImageView",
			image_name = "upgrades_room_image_upgrades_room_tooltip_arrow_down_",
			id = "upgrade_tooltip_arrow_5",
			pos = v(180.15, 104.4),
			scale = v(1, 1),
			anchor = v(10.8, 2.6)
		},
		{
			vertical_align = "middle",
			text_align = "left",
			text_key = "TUTORIAL_upgrade_room_tooltip_buy_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Use souls to buy upgrades for your powers. r your powerr your power",
			class = "GG5Label",
			id = "label_upgrade_room_tutorial_tooltip_buy_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-7.15, -13),
			size = v(376.55, 109.25),
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
