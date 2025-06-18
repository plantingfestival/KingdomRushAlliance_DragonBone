-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tip_heroes.lua

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
			pos = v(700, 664),
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
			image_name = "notifications_tips_slides_0007",
			pos = v(WW / 2, WH / 2),
			anchor = v(340, 263)
		},
		{
			fit_lines = 1,
			class = "GGLabel",
			font_size = 32,
			font_name = "body_bold",
			pos = v(WW / 2 - 210, WH / 2 - 220),
			size = v(420, 60),
			text = _("Hero at your command!")
		},
		{
			line_height = 0.9,
			fit_lines = 2,
			font_size = 20,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 210, WH / 2 - 180),
			size = v(420, 120),
			text = _("Heroes are elite units that can face strong enemies and support your forces."),
			colors = {
				text = {
					59,
					53,
					42
				}
			}
		},
		{
			line_height = 0.9,
			fit_lines = 3,
			font_size = 20,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 245, WH / 2 + 30),
			size = v(120, 30),
			text = _("Shows level, health and experience."),
			colors = {
				text = {
					59,
					53,
					42
				}
			}
		},
		{
			line_height = 0.9,
			fit_lines = 2,
			font_size = 20,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 210, WH / 2 + 160),
			size = v(420, 20),
			text = _("Heroes gain experience every time they damage an enemy or use an ability."),
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
			class = "GGLabel",
			font_size = 18,
			font_name = "body",
			pos = v(WW / 2 - 70, WH / 2 - 102),
			size = v(220, 40),
			text = _("Select by tapping on the portrait or hero unit.")
		},
		{
			vertical_align = "middle",
			fit_lines = 2,
			class = "GGLabel",
			font_size = 18,
			font_name = "body",
			pos = v(WW / 2 + 45, WH / 2 + 73),
			size = v(190, 54),
			text = _("Touch on the path to move the hero.")
		}
	}
}
