-- chunkname: @./kr5/data/kui_templates/group_victory.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "victory_defeat_image_victory_bg_",
			pos = v(-3.6, -303.35),
			anchor = v(277.55, 316.4)
		},
		{
			id = "animation_star_3",
			class = "GGAni",
			pos = v(35.2, -118.5),
			anchor = v(17.15, 59.35),
			animation = {
				to = 35,
				prefix = "victory_defeat_animation_star_3",
				from = 1
			}
		},
		{
			id = "animation_star_2",
			class = "GGAni",
			pos = v(-26.7, -107.1),
			anchor = v(16.45, 52.45),
			animation = {
				to = 35,
				prefix = "victory_defeat_animation_star_2",
				from = 1
			}
		},
		{
			id = "animation_star_1",
			class = "GGAni",
			pos = v(-87.7, -119.05),
			anchor = v(18.5, 56.7),
			animation = {
				to = 33,
				prefix = "victory_defeat_animation_star_1",
				from = 1
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 75,
			line_height_extra = "2",
			text_key = "TXT_VICTORY",
			text = "VICTORY",
			class = "GG5ShaderLabel",
			id = "label_victory",
			font_name = "fla_h",
			pos = v(-169.05, -304.15),
			size = v(322.95, 71.75),
			colors = {
				text = {
					51,
					51,
					51
				}
			},
			shaders = {
				"p_bands",
				"p_glow"
			},
			shader_args = {
				{
					margin = 1,
					p1 = 0.5,
					p2 = 0.99,
					c1 = {
						0.9961,
						1,
						0.4784,
						1
					},
					c2 = {
						0.9765,
						0.8706,
						0.1059,
						1
					},
					c3 = {
						0.9765,
						0.8706,
						0.1059,
						1
					}
				},
				{
					thickness = 2,
					glow_color = {
						0.6902,
						0.4,
						0,
						1
					}
				}
			}
		},
		{
			text_key = "TXT_VICTORY_GEMS",
			text_align = "center",
			line_height_extra = "2",
			font_size = 32,
			text = "999",
			class = "GG5Label",
			id = "label_gems_amount",
			font_name = "body",
			pos = v(-24, -187.05),
			size = v(109.05, 43.4),
			colors = {
				text = {
					255,
					255,
					255
				}
			}
		},
		{
			focus_image_name = "victory_defeat_button_ingame_quit_0003",
			class = "GG5Button",
			id = "button_continue",
			default_image_name = "victory_defeat_button_ingame_quit_0001",
			pos = v(58.4, 48.6),
			image_offset = v(-50.75, -50.7),
			hit_rect = r(-50.75, -50.7, 104, 104),
			children = {
				{
					id = "image_icon_continue",
					image_name = "victory_defeat_image_icon_continue_",
					class = "KImageView",
					pos = v(2.8, -1.55),
					anchor = v(17.3, 19.75)
				}
			}
		},
		{
			focus_image_name = "victory_defeat_button_ingame_quit_0003",
			class = "GG5Button",
			id = "button_restart",
			default_image_name = "victory_defeat_button_ingame_quit_0001",
			pos = v(-52.5, 48.6),
			image_offset = v(-50.75, -50.7),
			hit_rect = r(-50.75, -50.7, 104, 104),
			children = {
				{
					id = "image_icon_restart",
					image_name = "victory_defeat_image_icon_restart_",
					class = "KImageView",
					pos = v(0, -0.4),
					anchor = v(21.2, 22.1)
				}
			}
		}
	}
}
