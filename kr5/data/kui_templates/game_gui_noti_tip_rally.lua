-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tip_rally.lua

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
			pos = v(700, 660),
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
			image_name = "notifications_tips_slides_0003",
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
			text = _("COMMAND YOUR TROOPS!"),
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
			fit_lines = 4,
			font_size = 24,
			line_height = 0.9,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 180, WH / 2 - 160),
			size = v(410, 120),
			text = _("you can adjust your soldiers rally point to make them defend a different area."),
			colors = {
				text = {
					59,
					53,
					42
				}
			}
		},
		{
			vertical_align = "bottom",
			fit_lines = 2,
			font_size = 18,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 + 35, WH / 2 - 60),
			size = v(150, 20),
			text = _("rally range"),
			colors = {
				background = {
					0,
					0,
					0,
					0
				},
				text = {
					12,
					126,
					178
				}
			}
		},
		{
			line_height = 0.9,
			fit_lines = 3,
			font_size = 18,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 - 225, WH / 2 + 160),
			size = v(250, 10),
			text = _("select the rally point control"),
			colors = {
				background = {
					0,
					0,
					0,
					0
				},
				text = {
					168,
					43,
					10
				}
			}
		},
		{
			line_height = 0.9,
			fit_lines = 3,
			font_size = 18,
			class = "GGLabel",
			font_name = "body",
			pos = v(WW / 2 + 65, WH / 2 + 160),
			size = v(240, 30),
			text = _("select where you want to move your soldiers"),
			colors = {
				background = {
					0,
					0,
					0,
					0
				},
				text = {
					168,
					43,
					10
				}
			}
		}
	}
}
