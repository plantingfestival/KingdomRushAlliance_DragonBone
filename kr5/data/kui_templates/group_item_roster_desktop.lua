-- chunkname: @./kr5/data/kui_templates/group_item_roster_desktop.lua

return {
	class = "KView",
	children = {
		{
			image_name = "item_room_9slice_roster_bg_desktop_",
			class = "GG59View",
			pos = v(982.95, 76.8),
			size = v(1267.7055, 139.5621),
			anchor = v(634.569, 69.8599),
			slice_rect = r(17.1, 17.2, 9.9, 10)
		},
		{
			class = "KView",
			pos = v(-0.7, -0.5),
			children = {
				{
					image_name = "item_room_9slice_shadow_roster_",
					class = "GG59View",
					pos = v(985.45, 80.3),
					size = v(1314.6566, 165.1639),
					anchor = v(657.3283, 82.539),
					slice_rect = r(50.6, 29.95, 23, 42.45)
				},
				{
					class = "KImageView",
					image_name = "item_room_image_rosterframe2_l_",
					pos = v(344.75, 74.9),
					anchor = v(5.85, 62.55)
				},
				{
					class = "KImageView",
					image_name = "item_room_image_rosterframe2_r_",
					pos = v(1614.5, 72),
					anchor = v(3.35, 58.95)
				},
				{
					image_name = "item_room_image_rosterframe_t_",
					class = "GG59View",
					pos = v(1000, 5.45),
					size = v(1243.9492, 13.8),
					anchor = v(639.9378, 6.9),
					slice_rect = r(12.25, 4.15, 3.55, 5.55)
				},
				{
					image_name = "item_room_image_rosterframe_b_",
					class = "GG59View",
					pos = v(980.1, 146.9),
					size = v(1250.3671, 13.1),
					anchor = v(625.1836, 6.55),
					slice_rect = r(4.95, 3.25, 9.9, 6.6)
				},
				{
					class = "KImageView",
					image_name = "item_room_image_roster_corner_01_",
					pos = v(356.55, 14.95),
					anchor = v(17.1, 17.05)
				},
				{
					class = "KImageView",
					image_name = "item_room_image_roster_corner_02_",
					pos = v(1607.65, 14.85),
					anchor = v(18.15, 17)
				},
				{
					class = "KImageView",
					image_name = "item_room_image_roster_corner_03_",
					pos = v(1607.95, 137.65),
					anchor = v(17.85, 17)
				},
				{
					class = "KImageView",
					image_name = "item_room_image_roster_corner_04_",
					pos = v(356.35, 137.05),
					anchor = v(17.85, 17)
				},
				{
					class = "KImageView",
					image_name = "item_room_image_rivet_roster_",
					pos = v(1617.7, 77.85),
					anchor = v(6.05, 6.3)
				},
				{
					class = "KImageView",
					image_name = "item_room_image_rivet_roster_",
					pos = v(345.5, 77.9),
					anchor = v(6.05, 6.3)
				}
			}
		},
		{
			id = "item_room_items",
			class = "KView",
			pos = v(890.6, 166.3),
			children = {
				{
					id = "button_item_roster_01",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-473, -91),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_02",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-347.95, -90.95),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_03",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-222.9, -90.95),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_04",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(-97.85, -90.95),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_05",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(27.2, -90.95),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_06",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(152.25, -90.95),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_07",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(277.3, -90.95),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_08",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(402.35, -90.95),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_09",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(527.4, -90.95),
					anchor = v(54.5, 54.3)
				},
				{
					id = "button_item_roster_10",
					image_name = "item_room_image_roster_thumb_empty_",
					class = "KImageView",
					pos = v(652.7, -90.95),
					anchor = v(54.5, 54.3)
				}
			}
		}
	}
}
