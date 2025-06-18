-- chunkname: @./kr5/data/kui_templates/group_item_room_tutorial_buy.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "item_room_image_item_room_tooltip_arrow_",
			id = "label_item_room_tutorial_buy_tooltip_arrow",
			pos = v(-58.8, 70.15),
			scale = v(1, 1),
			anchor = v(10.4, 0)
		},
		{
			class = "GG59View",
			image_name = "item_room_9slice_item_room_tooltip_bg_",
			id = "hero_room_tutorial_power_tooltip_bg",
			pos = v(-59.2, 1.75),
			size = v(503.4619, 140.1575),
			anchor = v(251.731, 70.0787),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TUTORIAL_item_room_buy_title",
			font_size = 24,
			line_height_extra = "0",
			text = "Power-ups",
			class = "GG5Label",
			id = "label_item_room_tutorial_buy_tooltip_title",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-287.25, -59),
			size = v(455.95, 39.35),
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
			text_key = "TUTORIAL_item_room_buy_desc",
			font_size = 24,
			line_height_extra = "0",
			text = "Power-ups help you defeat your enemies. Buy more using gems and equip them to use.",
			class = "GG5Label",
			id = "label_item_room_tutorial_buy_tooltip_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-286.2, -23.4),
			size = v(454.9, 92.65),
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
