-- chunkname: @./kr5/data/kui_templates/group_item_roster.lua

return {
	class = "KView",
	children = {
		{
			image_name = "item_room_9slice_roster_bg_",
			class = "GG59View",
			pos = v(518.1, 69.65),
			size = v(1016.9604, 127.4023),
			anchor = v(508.4802, 63.7012),
			slice_rect = r(20, 20, 40, 40)
		},
		{
			id = "item_room_items",
			class = "KView",
			pos = v(15.4, 16.4),
			anchor = v(0, 6.7),
			size = v(1009.6, 121.35)
		},
		{
			class = "KImageView",
			image_name = "item_room_image_roster_shadow_",
			pos = v(-226.55, 0.75),
			anchor = v(-1169.15, -7.55)
		},
		{
			id = "button_item_roster_sel",
			class = "ItemSliderItemView",
			template_name = "button_item_roster_thumb",
			pos = v(76.2, 70.15)
		},
		{
			image_name = "item_room_image_roster_frame_",
			class = "KImageView",
			anchor = v(5.65, 8.9)
		}
	}
}
