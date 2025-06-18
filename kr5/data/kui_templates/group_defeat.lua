-- chunkname: @./kr5/data/kui_templates/group_defeat.lua

return {
	class = "KView",
	children = {
		{
			class = "KImageView",
			image_name = "victory_defeat_image_defeat_bg_",
			pos = v(-3.6, -303.35),
			anchor = v(335.8, 270.2)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 75,
			line_height_extra = "2",
			text_key = "TXT_VICTORY",
			text = "defeat",
			class = "GG5ShaderLabel",
			id = "label_defeat",
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
						1,
						0.6431,
						0.1608,
						1
					},
					c2 = {
						0.8784,
						0.4118,
						0.1176,
						1
					},
					c3 = {
						0.8784,
						0.4118,
						0.1176,
						1
					}
				},
				{
					thickness = 2,
					glow_color = {
						0.5137,
						0.1725,
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
			pos = v(58.4, -32.4),
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
			pos = v(-52.5, -32.4),
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
