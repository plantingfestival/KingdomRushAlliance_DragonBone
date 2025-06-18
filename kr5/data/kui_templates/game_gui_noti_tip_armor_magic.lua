-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tip_armor_magic.lua

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
			pos = v(700, 622),
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
			image_name = "notifications_tips_slides_0002",
			pos = v(WW / 2, WH / 2),
			anchor = v(340, 263)
		},
		{
			text_align = "left",
			fit_lines = 1,
			font_size = 32,
			class = "GGLabel",
			font_name = "body_bold",
			pos = v(WW / 2 - 180, WH / 2 - 204),
			size = v(420, 60),
			text = _("MAGIC RESISTANT ENEMIES!"),
			colors = {
				text = {
					0,
					0,
					0
				}
			}
		},
		{
			text_align = "left",
			fit_lines = 3,
			font_size = 24,
			line_height = 0.9,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 180, WH / 2 - 160),
			size = v(410, 120),
			text = _("some enemies enjoy different levels of magic resistance that protects them against magical attacks."),
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
			font_size = 24,
			line_height = 0.9,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 50, WH / 2 - 50),
			size = v(100, 20),
			text = _("resists damage from"),
			colors = {
				text = {
					218,
					58,
					17
				}
			}
		},
		{
			vertical_align = "middle",
			text_align = "left",
			fit_lines = 1,
			font_size = 12,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 + 38, WH / 2 + 67),
			size = v(50, 10),
			text = _("MEDIUM"),
			colors = {
				text = {
					255,
					255,
					255
				}
			}
		},
		{
			line_height = 0.9,
			fit_lines = 2,
			font_size = 26,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 240, WH / 2 + 110),
			size = v(480, 30),
			text = _("Magic resistant enemies take less damage from mages."),
			colors = {
				text = {
					59,
					53,
					42
				}
			}
		}
	}
}
