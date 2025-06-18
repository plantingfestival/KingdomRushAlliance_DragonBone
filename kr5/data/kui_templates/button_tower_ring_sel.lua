-- chunkname: @./kr5/data/kui_templates/button_tower_ring_sel.lua

return {
	default_image_name = "tower_room_image_tower_icon_frame_0001",
	class = "TowerRingItemButton",
	focus_image_name = "tower_room_image_tower_icon_frame_0003",
	image_offset = v(-44.65, -43.5),
	hit_rect = r(-44.65, -43.5, 91, 91),
	children = {
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_icon_",
			id = "image_slot_icon",
			pos = v(0, 1.2),
			scale = v(1, 1),
			anchor = v(43.05, 43)
		},
		{
			id = "image_slot_locked",
			class = "KImageView",
			image_name = "tower_room_image_slot_locked_",
			anchor = v(43, 43)
		},
		{
			id = "image_tower_icon_flash_01",
			class = "KImageView",
			image_name = "tower_room_image_tower_icon_flash_",
			anchor = v(40.85, 40.9)
		},
		{
			id = "tower_icon_frame_front",
			image_name = "tower_room_image_tower_icon_frame_front_",
			class = "KImageView",
			pos = v(0.35, 0),
			anchor = v(55.85, 46.9)
		},
		{
			id = "image_tower_icon_equip_highligth",
			image_name = "tower_room_image_tower_icon_equip_highligth_",
			class = "KImageView",
			pos = v(0.5, -0.15),
			anchor = v(44.65, 43.5)
		}
	}
}
