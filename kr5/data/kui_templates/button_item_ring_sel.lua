-- chunkname: @./kr5/data/kui_templates/button_item_ring_sel.lua

return {
	default_image_name = "item_room_image_item_icon_frame_0001",
	class = "ItemRingItemButton",
	focus_image_name = "item_room_image_item_icon_frame_0003",
	image_offset = v(-74, -76.5),
	hit_rect = r(-74, -76.5, 146, 150.05),
	children = {
		{
			id = "image_item_icon_bg",
			image_name = "item_room_image_item_icon_bg_",
			class = "KImageView",
			pos = v(-0.8, -10.95),
			anchor = v(58.4, 58.4)
		},
		{
			id = "group_item_icon_01",
			class = "ItemRingItemButtonThumb",
			template_name = "group_item_icon",
			pos = v(-1.35, -7.9)
		},
		{
			id = "image_item_icon_flash_01",
			image_name = "item_room_image_item_icon_flash_",
			class = "KImageView",
			pos = v(-1.35, -7.9),
			anchor = v(58.65, 58.55)
		},
		{
			id = "group_item_icon_frame",
			class = "KView",
			template_name = "group_item_icon_frame",
			pos = v(-0.25, -0.75)
		},
		{
			id = "image_item_icon_equip_highligth_01",
			image_name = "item_room_image_item_icon_equip_highligth_",
			class = "KImageView",
			pos = v(-1.15, -12.55),
			anchor = v(61.95, 57.65)
		}
	}
}
