-- chunkname: @./kr5/data/kui_templates/group_tower_room_tutorial_slots.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_room_skill_tooltip_arrow_2_",
			id = "label_tower_room_tutorial_navigate_tooltip_arrow",
			pos = v(-141.45, -109.95),
			scale = v(1, 1),
			anchor = v(10.35, 21.5)
		},
		{
			class = "GG59View",
			image_name = "tower_room_9slice_tower_room_skill_tooltip_bg_",
			id = "tower_room_tutorial_power_tooltip_bg",
			pos = v(-140.6, -56.45),
			size = v(382.3242, 104.4238),
			anchor = v(191.1621, 52.2119),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "middle",
			text_align = "left",
			text_key = "TUTORIAL_tower_room_tutorial_slots_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Use slots to equip new towers. Drag to switch ",
			class = "GG5Label",
			id = "label_tower_room_tutorial_slots_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-309.8, -99.85),
			size = v(344, 84),
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
