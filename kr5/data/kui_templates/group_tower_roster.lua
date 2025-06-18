-- chunkname: @./kr5/data/kui_templates/group_tower_roster.lua

return {
	class = "KView",
	children = {
		{
			image_name = "tower_room_9slice_image_roster_bg_",
			class = "GG59View",
			pos = v(-193.8, 3.3),
			size = v(1253.4958, 131.8811),
			anchor = v(-203.978, 0.1191),
			slice_rect = r(20.1, 21.05, 13, 12)
		},
		{
			id = "tower_room_towers",
			class = "KView",
			pos = v(13.6, 8.8),
			anchor = v(0, 0),
			size = v(1246, 121)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_roster_shadow_",
			pos = v(10.95, 0.75),
			anchor = v(-1169.15, -7.55)
		},
		{
			id = "button_tower_roster_sel",
			class = "TowerSliderItemView",
			template_name = "button_tower_roster_thumb",
			pos = v(76.2, 70.15)
		},
		{
			image_name = "tower_room_image_roster_frame_",
			class = "KImageView",
			anchor = v(5.65, 8.9)
		}
	}
}
