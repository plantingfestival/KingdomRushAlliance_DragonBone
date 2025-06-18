-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tip_strategy.lua

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
			image_name = "notifications_tit_generics_0004",
			font_size = 34,
			class = "GGLabel",
			font_name = "h_noti",
			pos = v(WW / 2, 70),
			anchor = v(192, 0),
			text_offset = v(20, 19),
			text_size = v(344, 44),
			text = _("INGAME_TUTORIAL_NEW_TIP"),
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
			image_name = "notifications_tips_slides_0004",
			pos = v(WW / 2, WH / 2),
			anchor = v(340, 263)
		},
		{
			class = "GGLabel",
			fit_lines = 1,
			font_size = 32,
			font_name = "body_bold",
			pos = v(WW / 2 - 260, WH / 2 - 220),
			size = v(520, 48),
			text = _("STRATEGY BASICS!"),
			colors = {
				text = {
					0,
					0,
					0
				}
			}
		},
		{
			text_align = "center",
			fit_lines = 3,
			font_size = 22,
			line_height = 0.9,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 260, WH / 2 - 176),
			size = v(520, 90),
			text = _("Barracks are good for blocking the enemy but lack in attack power. Make sure you have enough firepower to support them!"),
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
			fit_lines = 3,
			font_size = 18,
			line_height = 0.9,
			class = "GGLabel",
			font_name = "body",
			pos = v(512, 505),
			size = v(171, 71),
			text = _("Support your soldiers with ranged towers!")
		}
	}
}
