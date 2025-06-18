-- chunkname: @./kr5/data/kui_templates/group_item_portrait.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "item_room_image_item_portrait_",
			id = "item_room_portrait",
			pos = v(0.2, -80.65),
			scale = v(0.9997, 0.9997),
			anchor = v(155.95, 183.3)
		},
		{
			class = "KImageView",
			image_name = "item_room_image_item_portrait_flash_",
			id = "item_room_portrait_flash",
			pos = v(-157.4, -263.7),
			scale = v(315.8208, 364.1029),
			anchor = v(0, 0)
		},
		{
			image_name = "item_room_9slice_info_bg_",
			class = "GG59View",
			pos = v(79.4, -261.9),
			size = v(79.9121, 35.8553),
			anchor = v(0, 0),
			slice_rect = r(15.2, 15, 9.75, 10.2)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 26,
			text = "10",
			id = "label_portrait_item_quantity",
			fit_size = true,
			font_name = "fla_numbers",
			pos = v(86.05, -260.85),
			size = v(51.6, 36),
			colors = {
				text = {
					222,
					247,
					255
				}
			}
		},
		{
			class = "KImageView",
			image_name = "item_room_image_item_portrait_frame_",
			pos = v(0, -82.3),
			anchor = v(176.15, 202.15)
		},
		{
			class = "GG5Button",
			template_name = "button_item_room_item_equip",
			id = "item_room_button_item_equip",
			pos = v(-0.45, 225),
			scale = v(1, 1)
		},
		{
			id = "item_room_button_item_equipped",
			class = "GG5Button",
			template_name = "button_item_room_item_equipped",
			pos = v(-0.45, 225)
		},
		{
			class = "GG5Button",
			template_name = "button_item_room_item_price",
			id = "item_room_button_item_price",
			pos = v(-2.9, 120.35),
			scale = v(1, 1)
		},
		{
			loop = true,
			id = "animation_item_buy_fx",
			class = "GGAni",
			pos = v(112.6, -240.75),
			anchor = v(178.4, 178.4),
			animation = {
				to = 12,
				prefix = "item_room_animation_item_buy_fx",
				from = 1
			}
		}
	}
}
