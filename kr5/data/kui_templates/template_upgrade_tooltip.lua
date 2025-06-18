-- chunkname: @./kr5/data/kui_templates/template_upgrade_tooltip.lua

return {
	class = "UpgradeTooltipView",
	children = {
		{
			class = "GG59View",
			image_name = "upgrades_room_9slice_hero_room_skill_tooltip_bg_",
			id = "hero_room_skill_tooltip_bg",
			pos = v(173.35, 70.55),
			size = v(346.7261, 141.0938),
			anchor = v(173.363, 70.5469),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			class = "KImageView",
			image_name = "upgrades_room_image_upgrades_room_tooltip_arrow_left_",
			id = "upgrade_tooltip_arrow_1",
			pos = v(0.6, 67.35),
			scale = v(1, 1),
			anchor = v(20.4, 10.4)
		},
		{
			class = "KImageView",
			image_name = "upgrades_room_image_upgrades_room_tooltip_arrow_right_",
			id = "upgrade_tooltip_arrow_3",
			pos = v(346.1, 67.35),
			scale = v(1, 1),
			anchor = v(0, 10.4)
		},
		{
			class = "KImageView",
			image_name = "upgrades_room_image_upgrades_room_tooltip_arrow_left_",
			id = "upgrade_tooltip_arrow_2",
			pos = v(0.6, 42.6),
			scale = v(1, 1),
			anchor = v(20.4, 10.4)
		},
		{
			class = "KImageView",
			image_name = "upgrades_room_image_upgrades_room_tooltip_arrow_right_",
			id = "upgrade_tooltip_arrow_4",
			pos = v(346.1, 42.6),
			scale = v(1, 1),
			anchor = v(0, 10.4)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "UPGRADES_ROOM_TOOLTIP_TITLE",
			font_size = 21,
			line_height_extra = "0",
			text = "BIGGER BOMBS",
			class = "GG5Label",
			id = "label_upgrades_room_tooltip_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(15.3, 9.4),
			size = v(318.1, 29.85),
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
			text_key = "UPGRADES_ROOM_TOOLTIP_DESC",
			font_size = 21,
			line_height_extra = "0",
			text = "Infused with powerful alchemy, explosions now have a bigger range of effect.",
			class = "GG5Label",
			id = "label_upgrades_room_tooltip_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(15.2, 40),
			size = v(317.25, 92.5),
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
