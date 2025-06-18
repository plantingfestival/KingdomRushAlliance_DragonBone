-- chunkname: @./kr5/data/kui_templates/game_gui_noti_power_special.lua

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
			image_name = "notifications_tit_generics_0001",
			fit_lines = 1,
			font_size = 34,
			class = "GGLabel",
			font_name = "h_noti",
			pos = v(190, 160),
			text_offset = v(20, 19),
			text_size = v(300, 44),
			text = _("NOTIFICATION_NEW_SPECIAL_TITLE"),
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
			pos = v(720, 542),
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
			slices_prefix = "notification_bg_enemy",
			direction = "h",
			class = "GG9SlicesView",
			pos = v(WW / 2, WH / 2),
			anchor = v(350, 160),
			size = v(700, 320),
			children = {
				{
					space = 6,
					layout = "top",
					class = "GGLayout",
					pos = v(236, 48),
					size = v(440, 220),
					children = {
						{
							fit_lines = 1,
							class = "GGLabel",
							font_size = 34,
							id = "title",
							text_align = "left",
							font_name = "body_bold",
							text = _(string.upper(ctx.prefix) .. "_NAME"),
							colors = {
								text = {
									24,
									26,
									15,
									255
								}
							}
						},
						{
							line_height = 0.9,
							class = "GGLabel",
							font_size = 20,
							id = "desc",
							text_align = "left",
							font_name = "body",
							text = _(string.upper(ctx.prefix) .. "_LARGE_DESCRIPTION"),
							colors = {
								text = {
									24,
									26,
									15,
									255
								}
							}
						}
					}
				},
				{
					class = "KImageView",
					pos = v(-25, 55),
					r = rad(4),
					scale = v(1, 1),
					image_name = ctx.image,
					children = {
						{
							class = "KImageView",
							image_name = "notifications_creeps_marco",
							scale = v(1, 1),
							pos = v(-6, 0)
						}
					}
				}
			}
		}
	}
}
