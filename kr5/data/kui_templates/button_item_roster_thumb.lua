-- chunkname: @./kr5/data/kui_templates/button_item_roster_thumb.lua

return {
	default_image_name = "item_room_image_roster_thumb_bg_0001",
	class = "ItemSliderItemView",
	focus_image_name = "item_room_image_roster_thumb_bg_0003",
	image_offset = v(-57.15, -55.9),
	hit_rect = r(-57.15, -55.9, 117, 114),
	children = {
		{
			id = "image_roster_thumb",
			class = "KImageView",
			image_name = "item_room_image_roster_thumb_",
			anchor = v(55, 54)
		},
		{
			id = "roster_flash",
			image_name = "item_room_image_roster_flash_",
			class = "KImageView",
			scale = v(1.1037, 1.0961),
			anchor = v(50.3, 49.5)
		},
		{
			id = "group_roster_item_quantity",
			class = "KView",
			template_name = "group_roster_item_quantity",
			pos = v(26.6, 36.9)
		}
	}
}
