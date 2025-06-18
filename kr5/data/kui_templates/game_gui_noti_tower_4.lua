-- chunkname: @./kr5/data/kui_templates/game_gui_noti_tower_4.lua

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
			pos = v(260, 170),
			text_offset = v(20, 19),
			text_size = v(344, 44),
			text = _("NOTIFICATION_NEW_TOWER_TITLE"),
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
			pos = v(660, 600),
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
			class = "GG9SlicesView",
			direction = "h",
			pos = v(WW / 2, WH / 2 - 40),
			anchor = v(325, 150),
			size = v(650, 300),
			scale = v(1, 0.7)
		},
		{
			class = "KView",
			pos = v(WW / 2, WH / 2),
			anchor = v(325, 105),
			size = v(650, 210),
			children = {
				{
					space = 0,
					layout = "top",
					class = "GGLayout",
					pos = v(50, -10),
					size = v(550, 220),
					children = {
						{
							class = "GGLabel",
							fit_lines = 1,
							vertical_align = "bottom",
							font_size = 30,
							font_name = "body",
							size = v(550, 40),
							text = string.format(_("NOTIFICATION_NEW_TOWERS_SUB_TITLE"), ctx.level),
							colors = {
								background = {
									0,
									0,
									0,
									0
								},
								text = {
									24,
									26,
									15,
									255
								}
							}
						},
						{
							class = "GGLabel",
							fit_lines = 1,
							font_size = 20,
							font_name = "body",
							size = v(550, 30),
							text = string.format(_("NOTIFICATION_NEW_TOWERS_SUB_DESCRIPTION"), ctx.level),
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
					pos = v(-50, 105),
					r = rad(8),
					scale = v(1, 1),
					image_name = ctx.images[1],
					children = {
						{
							class = "KImageView",
							image_name = "notifications_creeps_marco",
							scale = v(1, 1),
							pos = v(-3, -3)
						}
					}
				},
				{
					class = "KImageView",
					pos = v(150, 90),
					r = rad(-8),
					scale = v(1, 1),
					image_name = ctx.images[2],
					children = {
						{
							class = "KImageView",
							image_name = "notifications_creeps_marco",
							scale = v(1, 1),
							pos = v(-3, -3)
						}
					}
				},
				{
					class = "KImageView",
					pos = v(300, 108),
					r = rad(8),
					scale = v(1, 1),
					image_name = ctx.images[3],
					children = {
						{
							class = "KImageView",
							image_name = "notifications_creeps_marco",
							scale = v(1, 1),
							pos = v(-3, -3)
						}
					}
				},
				{
					class = "KImageView",
					pos = v(500, 90),
					r = rad(-8),
					scale = v(1, 1),
					image_name = ctx.images[4],
					children = {
						{
							class = "KImageView",
							image_name = "notifications_creeps_marco",
							scale = v(1, 1),
							pos = v(-3, -3)
						}
					}
				}
			}
		}
	}
}
