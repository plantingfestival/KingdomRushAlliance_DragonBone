-- chunkname: @./kr5/data/kui_templates/group_hero_baloon_2.lua

return {
	class = "KView",
	children = {
		{
			image_name = "ingame_notifications_9slice_txt_baloon_",
			class = "GG59View",
			r = -3.1416,
			pos = v(13.25, -2.95),
			size = v(338.5321, 87.07),
			anchor = v(169.2661, 43.535),
			slice_rect = r(33.9, 30.95, 6.55, 6.1)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_txt_baloon_",
			pos = v(4.6, -59.75),
			anchor = v(16.6, 16.95)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			text_key = "NOTIFICATION_hero_desc_baloon_2",
			font_size = 20,
			line_height_extra = "0",
			text = "Wählen Sie durch Antippen des Portraits oder der",
			class = "GG5Label",
			id = "label_hero_desc_baloon_2",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-142.1, -39.9),
			size = v(312.35, 80),
			colors = {
				text = {
					67,
					41,
					28
				}
			}
		}
	}
}
