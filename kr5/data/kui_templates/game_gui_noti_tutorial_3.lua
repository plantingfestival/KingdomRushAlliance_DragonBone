-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tutorial_3.lua

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
			pos = v(WW / 2, 120),
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
			default_image_name = "tutorial_but_continue_0001",
			fit_lines = 1,
			font_size = 28,
			class = "GG5Button",
			id = "gotit_button",
			focus_image_name = "tutorial_but_continue_0003",
			font_name = "body_bold",
			pos = v(WW / 2, 600),
			anchor = v(120, 42),
			text_offset = v(10, 15),
			text_size = v(220, 44),
			text = _("INGAME_TUTORIAL_GOTCHA_1"),
			colors = {
				text = {
					255,
					255,
					206,
					255
				}
			},
			children = {
				{
					vertical_align = "bottom",
					font_size = 20,
					fit_lines = 1,
					class = "GGLabel",
					font_name = "body_bold",
					pos = v(120, 74),
					anchor = v(110, 20),
					size = v(220, 20),
					text = _("INGAME_TUTORIAL_GOTCHA_2"),
					colors = {
						background = {
							255,
							255,
							255,
							0
						},
						text = {
							255,
							255,
							206,
							255
						}
					}
				}
			}
		},
		{
			class = "KImageView",
			image_name = "tutorial_slide3",
			pos = v(WW / 2, WH / 2),
			anchor = v(418, 204),
			children = {
				{
					fit_lines = 1,
					class = "GGLabel",
					font_size = 32,
					font_name = "body_bold",
					pos = v(70, 38),
					size = v(694, 37),
					text = _("Basic Tower Types")
				},
				{
					fit_lines = 2,
					class = "GGLabel",
					font_size = 24,
					font_name = "body",
					pos = v(70, 79),
					size = v(694, 56),
					text = _("There are four basic types of towers available.")
				},
				{
					fit_lines = 2,
					class = "GGLabel",
					font_size = 17,
					font_name = "body",
					pos = v(48, 138),
					size = v(164, 40),
					text = _("ARCHER TOWER"),
					colors = {
						text = {
							178,
							46,
							12
						}
					}
				},
				{
					fit_lines = 2,
					class = "GGLabel",
					font_size = 17,
					font_name = "body",
					pos = v(248, 139),
					size = v(157, 40),
					text = _("BARRACKS"),
					colors = {
						text = {
							178,
							46,
							12
						}
					}
				},
				{
					fit_lines = 2,
					class = "GGLabel",
					font_size = 17,
					font_name = "body",
					pos = v(440, 138),
					size = v(162, 40),
					text = _("MAGES’ GUILD"),
					colors = {
						text = {
							178,
							46,
							12
						}
					}
				},
				{
					fit_lines = 2,
					class = "GGLabel",
					font_size = 17,
					font_name = "body",
					pos = v(636, 138),
					size = v(163, 40),
					text = _("ARTILLERY"),
					colors = {
						text = {
							178,
							46,
							12
						}
					}
				},
				{
					vertical_align = "middle",
					fit_lines = 2,
					font_size = 17,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(55, 307),
					size = v(150, 42),
					text = _("good rate of fire")
				},
				{
					vertical_align = "middle",
					fit_lines = 2,
					font_size = 17,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(251, 307),
					size = v(150, 42),
					text = _("soldiers block enemies")
				},
				{
					vertical_align = "middle",
					fit_lines = 2,
					font_size = 17,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(446, 307),
					size = v(150, 42),
					text = _("high damage, armor piercing")
				},
				{
					vertical_align = "middle",
					fit_lines = 2,
					font_size = 17,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(643, 307),
					size = v(150, 42),
					text = _("deals area damage")
				}
			}
		}
	}
}
