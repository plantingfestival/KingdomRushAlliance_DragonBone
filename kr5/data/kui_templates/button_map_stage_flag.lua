-- chunkname: @./kr5/data/kui_templates/button_map_stage_flag.lua

return {
	default_image_name = "map_flags_stage_flag_bg_0001",
	class = "StageFlag5",
	focus_image_name = "map_flags_stage_flag_bg_0003",
	image_offset = v(-41.7, -70.1),
	hit_rect = r(-41.7, -70.1, 88, 87),
	children = {
		{
			class = "GGAni",
			r = 0,
			id = "wings",
			pos = v(1.3, -4.35),
			scale = v(0.9999, 0.9999),
			anchor = v(49.65, 77.55),
			animation = {
				to = 12,
				prefix = "map_flags_animation_stage_flag_wings",
				from = 1
			},
			sounds = {
				{
					duration = 12,
					name = "kra_sfx_uiMap_heroicChallengeFlag_v1",
					f = 1
				}
			}
		},
		{
			class = "GGAni",
			id = "flag",
			anchor = v(43.9, 120.4),
			animation = {
				to = 202,
				prefix = "map_flags_animation_stage_flag",
				from = 1
			},
			sounds = {
				{
					duration = 62,
					name = "kra_sfx_ui_stageFlagAppear",
					f = 12
				},
				{
					duration = 77,
					name = "kr4_flag_glow",
					f = 74
				},
				{
					duration = 27,
					name = "kr4_flag_glow",
					f = 151
				}
			},
			animations = {
				nostar_fixed = {
					from = 1,
					to = 1
				},
				nostar_in = {
					from = 2,
					to = 25
				},
				nostar_flap = {
					from = 26,
					to = 73
				},
				campaign_in = {
					from = 74,
					to = 100
				},
				campaign_flap = {
					from = 101,
					to = 148
				},
				campaign_idle = {
					from = 149,
					to = 149
				},
				iron_idle = {
					from = 150,
					to = 150
				},
				iron_in = {
					from = 151,
					to = 177
				},
				iron_flap = {
					from = 178,
					to = 202
				}
			}
		},
		{
			class = "GGAni",
			id = "star1",
			pos = v(-15.95, -71.45),
			anchor = v(14.3, 19.7),
			animation = {
				to = 22,
				prefix = "map_flags_animation_stage_flag_star_1",
				from = 1
			},
			sounds = {
				{
					duration = 21,
					name = "kr4_map_star",
					f = 2
				}
			},
			animations = {
				off = {
					from = 1,
					to = 1
				},
				on = {
					from = 2,
					to = 22
				}
			}
		},
		{
			class = "GGAni",
			id = "star2",
			pos = v(1.75, -72.05),
			anchor = v(16.6, 22.65),
			animation = {
				to = 22,
				prefix = "map_flags_animation_stage_flag_star_2",
				from = 1
			},
			sounds = {
				{
					duration = 21,
					name = "kr4_map_star",
					f = 2
				}
			},
			animations = {
				off = {
					from = 1,
					to = 1
				},
				on = {
					from = 2,
					to = 22
				}
			}
		},
		{
			class = "GGAni",
			id = "star3",
			pos = v(18.65, -72.6),
			anchor = v(15.4, 18.05),
			animation = {
				to = 22,
				prefix = "map_flags_animation_stage_flag_star_3",
				from = 1
			},
			sounds = {
				{
					duration = 21,
					name = "kr4_map_star",
					f = 2
				}
			},
			animations = {
				off = {
					from = 1,
					to = 1
				},
				on = {
					from = 2,
					to = 22
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 15,
			text = "99",
			id = "level_number",
			font_name = "fla_body",
			pos = v(-14.5, -99.85),
			size = v(30.05, 25.05),
			colors = {
				text = {
					0,
					0,
					0
				}
			}
		},
		{
			class = "GGAni",
			id = "notification_dot",
			pos = v(11, -22.75),
			scale = v(0.84, 0.84),
			anchor = v(9.65, 6.55),
			animation = {
				to = 12,
				prefix = "map_flags_animation_notification_dot",
				from = 1
			}
		}
	}
}
