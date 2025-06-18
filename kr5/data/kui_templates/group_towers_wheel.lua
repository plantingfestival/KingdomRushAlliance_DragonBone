-- chunkname: @./kr5/data/kui_templates/group_towers_wheel.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_ring_ring_",
			pos = v(-98.3, -99.6),
			anchor = v(43.05, 36)
		},
		{
			template_name = "button_tower_ring_sel",
			class = "TowerRingItemButton",
			r = 0,
			id = "button_tower_ring_sel_01",
			pos = v(-76.1, -113),
			scale = v(0.9999, 0.9999)
		},
		{
			template_name = "button_tower_ring_sel",
			class = "TowerRingItemButton",
			r = 0,
			id = "button_tower_ring_sel_02",
			pos = v(73.55, -113),
			scale = v(0.9999, 0.9999)
		},
		{
			template_name = "button_tower_ring_sel",
			class = "TowerRingItemButton",
			r = 0,
			id = "button_tower_ring_sel_05",
			pos = v(-1.65, 116.5),
			scale = v(0.9999, 0.9999)
		},
		{
			template_name = "button_tower_ring_sel",
			class = "TowerRingItemButton",
			r = 0,
			id = "button_tower_ring_sel_04",
			pos = v(116.15, 18.8),
			scale = v(0.9999, 0.9999)
		},
		{
			template_name = "button_tower_ring_sel",
			class = "TowerRingItemButton",
			r = 0,
			id = "button_tower_ring_sel_03",
			pos = v(-120.75, 18.8),
			scale = v(0.9999, 0.9999)
		}
	}
}
