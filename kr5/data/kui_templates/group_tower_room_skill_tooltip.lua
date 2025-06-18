-- chunkname: @./kr5/data/kui_templates/group_tower_room_skill_tooltip.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_room_skill_tooltip_arrow_",
			id = "hero_room_skill_tooltip_arrow_2",
			pos = v(77.05, 68.8),
			scale = v(1, 1),
			anchor = v(10.35, 0)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_room_skill_tooltip_arrow_",
			id = "hero_room_skill_tooltip_arrow_1",
			pos = v(-101.7, 68.8),
			scale = v(1, 1),
			anchor = v(10.35, 0)
		},
		{
			class = "GG59View",
			image_name = "tower_room_9slice_tower_room_skill_tooltip_bg_",
			id = "hero_room_skill_tooltip_bg",
			pos = v(-8, 1.3),
			size = v(379.5618, 139.9219),
			anchor = v(189.7809, 69.9609),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TOWER_ROOM_skill_tooltip_title",
			font_size = 21,
			line_height_extra = "0",
			text = "BLADE OF DEMISE",
			class = "GG5Label",
			id = "label_tower_room_skill_tooltip_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-179.4, -62.3),
			size = v(343, 29.85),
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
			text_key = "TOWER_ROOM_skill_tooltip_desc",
			font_size = 21,
			line_height_extra = "0",
			text = "The shadow archer vanishes and appears behind an enemy, killing it instantly",
			class = "GG5Label",
			id = "label_tower_room_skill_tooltip_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-179.15, -31.9),
			size = v(342.15, 96),
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
