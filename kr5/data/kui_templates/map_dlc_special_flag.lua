-- chunkname: @./kr5/data/kui_templates/map_dlc_special_flag.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			class = "KView",
			id = "group_flag_dlc_1",
			pos = v(898, 538),
			scale = v(1, 1),
			children = {
				{
					frame_duration = 39,
					play = "loop",
					class = "GGTimeline",
					fps = 30,
					pos = v(-1.65, -42.05),
					children = {
						{
							id = "l0_image_dwarf_flag_shine",
							class = "KImageView",
							image_name = "map_dlc_special_flag_image_dwarf_flag_shine_",
							anchor = v(65.7, 64.95)
						}
					},
					timeline = {
						{
							id = "l0_image_dwarf_flag_shine",
							frame_duration = 38,
							ease = 0,
							f = 1,
							pos = v(0, 0)
						},
						{
							f = 39,
							frame_duration = 1,
							r = -0.6135,
							id = "l0_image_dwarf_flag_shine",
							ease = 0,
							pos = v(0, 0),
							scale = v(0.9999, 0.9999)
						}
					}
				},
				{
					class = "KView"
				},
				{
					focus_image_name = "map_dlc_special_flag_button_dwarf_flag_0003",
					class = "GG5Button",
					default_image_name = "map_dlc_special_flag_button_dwarf_flag_0001",
					pos = v(-7.4, -33.4),
					anchor = v(60.35, 48.9)
				},
				{
					fps = 30,
					class = "GGTimeline",
					frame_duration = 12,
					play = "loop",
					pos = v(-4.15, -76.85),
					scale = v(1, 1),
					children = {
						{
							id = "l0_animation_dwarf_flag_flame",
							class = "GGAni",
							pos = v(1, 2.15),
							anchor = v(8.05, 9.15),
							animation = {
								to = 12,
								prefix = "map_dlc_special_flag_animation_dwarf_flag_flame",
								from = 1
							}
						}
					},
					timeline = {
						{
							a_from = 1,
							play = "loop",
							a_to = 12,
							frame_duration = 12,
							id = "l0_animation_dwarf_flag_flame",
							f = 1,
							pos = v(1, 2.15)
						}
					}
				},
				{
					frame_duration = 39,
					play = "loop",
					class = "GGTimeline",
					fps = 30,
					pos = v(-15.8, -26.75),
					children = {
						{
							id = "l0_animation_flag_dlc_dwarf_smoke",
							class = "GGAni",
							anchor = v(15.25, 118.4),
							animation = {
								to = 39,
								prefix = "map_dlc_special_flag_animation_flag_dlc_dwarf_smoke",
								from = 1
							}
						}
					},
					timeline = {
						{
							a_from = 1,
							play = "loop",
							a_to = 39,
							frame_duration = 39,
							id = "l0_animation_flag_dlc_dwarf_smoke",
							f = 1,
							pos = v(0, 0)
						}
					}
				}
			}
		},
		{
			frame_duration = 55,
			class = "GGTimeline",
			id = "flag_unlock_anim_dlc_1",
			fps = 30,
			pos = v(898, 538),
			scale = v(1, 1),
			children = {
				{
					id = "l0_animation_flag_dlc_1_unlock",
					class = "GGAni",
					pos = v(-1.95, -39.8),
					anchor = v(159.85, 158.5),
					animation = {
						to = 55,
						prefix = "map_dlc_special_flag_animation_flag_dlc_1_unlock",
						from = 1
					}
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "loop",
					a_to = 55,
					frame_duration = 55,
					id = "l0_animation_flag_dlc_1_unlock",
					f = 1,
					pos = v(-1.95, -39.8)
				}
			}
		}
	}
}
