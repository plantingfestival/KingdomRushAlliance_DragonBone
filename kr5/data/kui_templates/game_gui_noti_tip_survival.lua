-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tip_survival.lua

WW = 1024
WH = 768

return {
	class = "KView",
	pos = v(WW / 2, WH / 2),
	size = v(WW, WH),
	anchor = v(WW / 2, WH / 2),
	children = {
		{
			vertical_align = "middle",
			text_align = "center",
			fit_lines = 1,
			image_name = "notifications_tit_generics_0003",
			font_size = 34,
			class = "GGLabel",
			font_name = "h_noti",
			pos = v(WW / 2, 70),
			anchor = v(192, 0),
			text_offset = v(20, 19),
			text_size = v(344, 44),
			text = _("INGAME_TUTORIAL_TIP_CHALLENGE"),
			colors = {
				text = {
					245,
					244,
					180
				}
			}
		},
		{
			vertical_align = "middle",
			default_image_name = "notifications_but_lightblue_0001",
			font_size = 34,
			class = "GG5Button",
			id = "ok_button",
			focus_image_name = "notifications_but_lightblue_0003",
			font_name = "body_bold",
			pos = v(700, 644),
			anchor = v(96, 44),
			text_offset = v(10, 25),
			text_size = v(172, 40),
			text = _("INGAME_TUTORIAL_OK"),
			colors = {
				text = {
					255,
					255,
					206,
					255
				}
			}
		},
		{
			class = "KImageView",
			image_name = "notifications_tips_slides_0009",
			pos = v(WW / 2, WH / 2),
			anchor = v(340, 263),
			children = {
				{
					fit_lines = 1,
					class = "GGLabel",
					font_size = 42,
					font_name = "body_bold",
					pos = v(61, 52),
					size = v(550, 37),
					text = _("Survival mode!"),
					colors = {
						text = {
							185,
							0,
							7
						}
					}
				},
				{
					text_align = "left",
					fit_lines = 4,
					font_size = 22,
					class = "GGLabel",
					font_name = "body",
					pos = v(248, 148),
					size = v(332, 124),
					text = _("Face an endless unrelenting enemy force and try to defeat as many as possible to compete for the best score!"),
					colors = {
						text = {
							59,
							53,
							42
						}
					}
				},
				{
					vertical_align = "middle",
					fit_lines = 4,
					font_size = 22,
					class = "GGLabel",
					font_name = "body",
					pos = v(92, 300),
					size = v(280, 114),
					text = _("Earn huge bonus points and gold by calling waves earlier!"),
					colors = {
						text = {
							59,
							53,
							42
						}
					}
				},
				{
					vertical_align = "middle-caps",
					class = "GGShaderLabel",
					font_size = 26,
					shader_margin = 16,
					text = "+1000",
					font_name = "numbers_bold",
					pos = v(502, 385),
					size = v(100, 25),
					colors = {
						text = {
							255,
							255,
							255,
							255
						}
					},
					shaders = {
						"p_outline",
						"p_glow"
					},
					shader_args = {
						{
							thickness = 1.5,
							outline_color = {
								0,
								0.6196078431372549,
								0.7058823529411765,
								1
							}
						},
						{
							thickness = 1,
							glow_color = {
								0,
								0.6196078431372549,
								0.7058823529411765,
								1
							}
						}
					}
				}
			}
		}
	}
}
