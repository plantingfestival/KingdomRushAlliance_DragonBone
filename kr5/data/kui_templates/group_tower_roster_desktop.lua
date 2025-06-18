return {
	class = "KView",
	children = {
		{
			image_name = "tower_room_9slice_roster_bg_desktop_",
			class = "GG59View",
			pos = v(635.55, 116.4),
			size = v(1246.8634, 386.0109),
			anchor = v(624.1361, 150.6755),
			slice_rect = r(17.1, 17.2, 9.9, 10)
		},
		{
			class = "KView",
			pos = v(552.15, 130.35),
			children = {
				{
					image_name = "tower_room_9slice_shadow_roster_",
					class = "GG59View",
					pos = v(82.75, -20),
					size = v(1299.3769, 423.3135),
					anchor = v(649.6884, 161.5727),
					slice_rect = r(50.6, 39.75, 23, 26.15)
				},
				{
					image_name = "tower_room_image_rosterframe2_l_",
					class = "KImageView",
					r = 1.5707,
					pos = v(-544.1, 26.6),
					scale = v(0.9189, 1.25),
					anchor = v(150.1, 8.05)
				},
				{
					image_name = "tower_room_image_rosterframe2_r_",
					class = "KImageView",
					r = 1.5707,
					pos = v(699.95, 26.25),
					scale = v(0.9189, 1.25),
					anchor = v(146.9, -1.45)
				},
				{
					image_name = "tower_room_9slice_rosterframe_t_",
					class = "GG59View",
					pos = v(99.65, -165.8),
					size = v(1210, 13.8),
					anchor = v(624.8913, 6.9),
					slice_rect = r(12.25, 4.15, 3.55, 5.55)
				},
				{
					image_name = "tower_room_9slice_rosterframe_b_",
					class = "GG59View",
					pos = v(79.9, 230.1),
					size = v(1210, 13.0655),
					anchor = v(602.092, 6.5328),
					slice_rect = r(4.5, 2.1, 5.25, 4.2)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_roster_corner_01_",
					pos = v(-534.3, -156.5),
					anchor = v(17.1, 17.05)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_roster_corner_02_",
					pos = v(698.1, -156.6),
					anchor = v(18.15, 17)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_roster_corner_03_",
					pos = v(698.4, 220.35),
					anchor = v(17.85, 17)
				},
				{
					class = "KImageView",
					image_name = "tower_room_image_roster_corner_04_",
					pos = v(-534.5, 220.65),
					anchor = v(17.85, 17)
				}
			}
		},
		{
			id = "tower_room_towers",
			class = "KView",
			pos = v(22.5, -21),
			anchor = v(0, 0),
			size = v(1221.3, 365.85)
			-- pos = v(689.6, 143.15),
			-- children = {
			-- 	{
			-- 		id = "button_tower_roster_01",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-598.1, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_02",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-462.4, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_03",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-326.7, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_04",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-191, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_05",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-55.3, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_06",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(80.4, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_07",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(216.1, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_08",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(351.8, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_09",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(487.5, -106.4),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_10",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-598.1, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_11",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-462.4, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_12",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-326.7, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_13",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-191, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_14",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-55.3, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_15",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(80.4, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_16",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(216.1, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_17",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(351.8, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_18",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(487.5, 15.55),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_19",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-598.1, 137.5),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_20",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-462.4, 137.5),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_21",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-326.7, 137.5),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_22",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-191, 137.5),
			-- 		anchor = v(59.8, 58.85)
			-- 	},
			-- 	{
			-- 		id = "button_tower_roster_23",
			-- 		image_name = "tower_room_image_roster_thumb_empty_",
			-- 		class = "KImageView",
			-- 		pos = v(-55.3, 137.5),
			-- 		anchor = v(59.8, 58.85)
			-- 	}
			-- }
		},
		{
			id = "button_tower_roster_sel",
			class = "TowerSliderItemView",
			template_name = "button_tower_roster_thumb_desktop",
			pos = v(91.55, 46.95)
		}
	}
}