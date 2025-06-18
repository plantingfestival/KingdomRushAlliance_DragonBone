-- chunkname: @./kr5/data/kui_templates/group_tower_roster_desktop.lua

return {
	class = "KView",
	children = {
		{
			image_name = "tower_room_9slice_roster_bg_desktop_",
			class = "GG59View",
			pos = v(635.55, 165.55),
			size = v(1246.8634, 282.9823),
			anchor = v(624.1361, 141.651),
			slice_rect = r(17.1, 17.2, 9.9, 10)
		},
		{
			class = "KView",
			pos = v(552.15, 170.35),
			children = {
				{
					image_name = "tower_room_9slice_shadow_roster_",
					class = "GG59View",
					pos = v(82.75, 0.1),
					size = v(1299.3769, 306.3314),
					anchor = v(649.6884, 153.0861),
					slice_rect = r(50.6, 39.75, 23, 26.15)
				},
				{
					image_name = "tower_room_image_rosterframe2_l_",
					class = "KImageView",
					r = 1.5707,
					pos = v(-544.1, -5),
					scale = v(0.8625, 1),
					anchor = v(150.1, 8.05)
				},
				{
					image_name = "tower_room_image_rosterframe2_r_",
					class = "KImageView",
					r = 1.5707,
					pos = v(699.95, -5.35),
					scale = v(0.8625, 1),
					anchor = v(146.9, -1.45)
				},
				{
					image_name = "tower_room_9slice_rosterframe_t_",
					class = "GG59View",
					pos = v(99.65, -145.8),
					size = v(1214.701, 13.8),
					anchor = v(624.8913, 6.9),
					slice_rect = r(12.25, 4.15, 3.55, 5.55)
				},
				{
					image_name = "tower_room_9slice_rosterframe_b_",
					class = "GG59View",
					pos = v(79.9, 138.1),
					size = v(1208.2522, 13.0655),
					anchor = v(602.092, 6.5328),
					slice_rect = r(4.5, 2.1, 5.25, 4.2)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_roster_corner_01_",
					pos = v(-534.3, -136.5),
					anchor = v(17.1, 17.05)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_roster_corner_02_",
					pos = v(698.1, -136.6),
					anchor = v(18.15, 17)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_roster_corner_03_",
					pos = v(698.4, 128.35),
					anchor = v(17.85, 17)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_roster_corner_04_",
					pos = v(-534.5, 128.65),
					anchor = v(17.85, 17)
				}
			}
		},
		{
			class = "KView",
			id = "tower_room_towers",
			pos = v(625.1, 174.85),
			scale = v(0.9019, 0.9019),
			children = {
				{
					id = "button_tower_roster_01",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-598.1, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_02",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-462.4, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_03",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-326.7, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_04",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-191, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_05",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-55.3, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_06",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(80.4, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_07",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(216.1, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_08",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(351.8, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_09",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(487.5, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_11",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-598.1, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_12",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-462.4, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_13",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-326.7, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_14",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-191, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_15",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-55.3, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_16",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(80.4, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_17",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(216.1, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_18",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(351.8, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_19",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(487.5, 60.55),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_10",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(622.5, -76.4),
					anchor = v(59.8, 58.85)
				},
				{
					id = "button_tower_roster_20",
					image_name = "tower_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(622.5, 60.55),
					anchor = v(59.8, 58.85)
				}
			}
		},
		{
			class = "TowerSliderItemView",
			template_name = "button_tower_roster_thumb_desktop",
			id = "button_tower_roster_sel",
			pos = v(85.7, 106.15),
			scale = v(0.9019, 0.9019)
		}
	}
}
