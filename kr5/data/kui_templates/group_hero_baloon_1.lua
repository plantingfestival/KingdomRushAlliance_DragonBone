-- chunkname: @./kr5/data/kui_templates/group_hero_baloon_1.lua

return {
	class = "KView",
	children = {
		{
			image_name = "ingame_notifications_9slice_txt_baloon_",
			class = "GG59View",
			r = -3.1416,
			pos = v(13.25, 3.65),
			size = v(338.5321, 85.7167),
			anchor = v(169.2661, 42.8584),
			slice_rect = r(33.9, 30.95, 6.55, 6.1)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_txt_baloon_2_",
			pos = v(23.6, 60.2),
			anchor = v(21.35, 15.6)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			text_key = "NOTIFICATION_hero_desc_baloon_1",
			font_size = 20,
			line_height_extra = "0",
			text = "Wählen Sie durch Antippen des Portraits oder der \ndes Portraits oder der",
			class = "GG5Label",
			id = "label_hero_desc_baloon_1",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-139.65, -37.8),
			size = v(307.3, 88.15),
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
