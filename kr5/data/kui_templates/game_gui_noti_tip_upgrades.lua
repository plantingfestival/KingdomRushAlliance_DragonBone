-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tip_upgrades.lua

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
			pos = v(700, 640),
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
			image_name = "notifications_tips_slides_0006",
			pos = v(WW / 2, WH / 2),
			anchor = v(340, 263),
			children = {
				{
					text_align = "left",
					fit_lines = 2,
					font_size = 26,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body_bold",
					pos = v(192, 49),
					size = v(419, 60),
					text = _("UPGRADES AND HEROES RESTRICTIONS!")
				},
				{
					vertical_align = "bottom",
					fit_lines = 4,
					font_size = 24,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(74, 148),
					size = v(239, 121),
					text = _("iron and heroic challenges may have restrictions on upgrades!"),
					colors = {
						text = {
							59,
							53,
							42
						}
					}
				},
				{
					text_align = "left",
					fit_lines = 1,
					font_size = 22,
					line_height = 0.9,
					class = "GGLabel",
					font_name = "body",
					pos = v(72, 377),
					size = v(386, 22),
					text = _("check the stage description to see:"),
					colors = {
						text = {
							168,
							43,
							10
						}
					}
				},
				{
					text_align = "left",
					fit_lines = 1,
					font_size = 22,
					class = "GGLabel",
					font_name = "body",
					pos = v(70, 405),
					size = v(384, 22),
					text = _("- max upgrade level allowed"),
					colors = {
						text = {
							59,
							53,
							42
						}
					}
				},
				{
					text_align = "left",
					fit_lines = 1,
					font_size = 22,
					class = "GGLabel",
					font_name = "body",
					pos = v(69, 431),
					size = v(389, 22),
					text = _("- if heroes are allowed"),
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
					fit_lines = 2,
					font_size = 12,
					line_height = 0.8,
					class = "GGLabel",
					font_name = "body",
					pos = v(528, 422),
					size = v(86, 22),
					text = _("max lvl allowed"),
					colors = {
						text = {
							234,
							96,
							77
						}
					}
				},
				{
					vertical_align = "middle",
					fit_lines = 1,
					font_size = 12,
					line_height = 0.8,
					class = "GGLabel",
					font_name = "body",
					pos = v(537, 447),
					size = v(69, 17),
					text = _("no heroes"),
					colors = {
						text = {
							234,
							96,
							77
						}
					}
				}
			}
		}
	}
}
