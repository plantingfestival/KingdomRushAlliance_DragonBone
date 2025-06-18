-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tutorial_2.lua

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
			pos = v(WW / 2, 113),
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
			pos = v(WW / 2 - 150, 600),
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
			pos = v(WW / 2 + 150, 600),
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
			image_name = "tutorial_slide2",
			pos = v(WW / 2, WH / 2),
			anchor = v(330, 210),
			children = {
				{
					fit_lines = 1,
					class = "GGLabel",
					font_size = 32,
					font_name = "body_bold",
					pos = v(35, 40),
					size = v(590, 40),
					text = _("Tower construction")
				},
				{
					fit_lines = 2,
					class = "GGLabel",
					font_size = 22,
					font_name = "body",
					pos = v(35, 80),
					size = v(590, 63),
					text = _("Build towers on strategic points to stop the enemy hordes from getting through.")
				},
				{
					vertical_align = "middle",
					fit_lines = 2,
					font_size = 16,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(78, 272),
					size = v(121, 55),
					text = _("this is a strategic point."),
					colors = {
						text = {
							112,
							94,
							77
						}
					}
				},
				{
					vertical_align = "middle",
					fit_lines = 1,
					font_size = 16,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(75, 177),
					size = v(118, 33),
					r = rad(8),
					colors = {
						text = {
							193,
							60,
							20
						}
					},
					text = _("tap these!")
				},
				{
					vertical_align = "middle",
					fit_lines = 1,
					font_size = 16,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(471, 163),
					size = v(120, 33),
					r = rad(8),
					colors = {
						text = {
							193,
							60,
							20
						}
					},
					text = _("wOOt!")
				},
				{
					vertical_align = "middle",
					fit_lines = 2,
					font_size = 16,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(246, 345),
					size = v(189, 49),
					r = rad(8),
					colors = {
						text = {
							193,
							60,
							20
						}
					},
					text = _("select the tower you want to build!")
				},
				{
					vertical_align = "middle",
					fit_lines = 2,
					font_size = 16,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(473, 305),
					size = v(126, 42),
					r = rad(8),
					colors = {
						text = {
							193,
							60,
							20
						}
					},
					text = _("ready for action!")
				}
			}
		}
	}
}
