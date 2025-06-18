-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tutorial_1.lua

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
			text = _("INGAME_TUTORIAL_INSTRUCTIONS"),
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
			default_image_name = "tutorial_but_skip_0001",
			font_size = 30,
			class = "GG5Button",
			id = "skip_button",
			focus_image_name = "tutorial_but_skip_0003",
			font_name = "body_bold",
			pos = v(WW / 2 - 150, 610),
			anchor = v(120, 42),
			text_offset = v(10, 25),
			text_size = v(220, 44),
			text = _("INGAME_TUTORIAL_SKIP"),
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
			vertical_align = "middle",
			default_image_name = "tutorial_but_continue_0001",
			font_size = 30,
			class = "GG5Button",
			id = "continue_button",
			focus_image_name = "tutorial_but_continue_0003",
			font_name = "body_bold",
			pos = v(WW / 2 + 150, 610),
			anchor = v(120, 42),
			text_offset = v(10, 25),
			text_size = v(220, 44),
			text = _("INGAME_TUTORIAL_NEXT"),
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
			image_name = "tutorial_slide1",
			pos = v(WW / 2, WH / 2),
			anchor = v(340, 263),
			children = {
				{
					fit_lines = 1,
					class = "GGLabel",
					r = 0,
					font_size = 32,
					font_name = "body_bold",
					pos = v(80, 40),
					size = v(520, 39),
					text = _("Objective")
				},
				{
					fit_lines = 1,
					class = "GGLabel",
					r = 0,
					font_size = 22,
					font_name = "body",
					pos = v(80, 81),
					size = v(520, 28),
					text = _("protect your lands from the enemy attacks.")
				},
				{
					fit_lines = 1,
					class = "GGLabel",
					r = 0,
					font_size = 18,
					font_name = "body",
					pos = v(80, 109),
					size = v(520, 24),
					text = _("build defensive towers along the road to stop them.")
				},
				{
					vertical_align = "middle",
					r = 0,
					font_size = 15,
					line_height = 0.9,
					class = "GGLabel",
					fit_size = true,
					font_name = "body",
					pos = v(170, 171),
					size = v(190, 46),
					text = _("don't let enemies past this point.")
				},
				{
					vertical_align = "middle",
					r = 0,
					font_size = 15,
					line_height = 0.9,
					class = "GGLabel",
					fit_size = true,
					font_name = "body",
					pos = v(387, 382),
					size = v(153, 36),
					text = _("build towers to defend the road.")
				},
				{
					vertical_align = "middle",
					r = 0,
					font_size = 15,
					line_height = 0.9,
					class = "GGLabel",
					fit_size = true,
					font_name = "body",
					pos = v(406, 288),
					size = v(152, 34),
					text = _("earn gold by killing enemies.")
				}
			}
		}
	}
}
