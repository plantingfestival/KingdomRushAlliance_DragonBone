-- chunkname: @./kr5/data/kui_templates/group_item_info_panel.lua

return {
	class = "KView",
	children = {
		{
			image_name = "item_room_9slice_info_bg_",
			class = "GG59View",
			pos = v(138.4, 18.25),
			size = v(460.2185, 334.0107),
			anchor = v(0, 0),
			slice_rect = r(15.2, 15, 9.75, 10.2)
		},
		{
			class = "KImageView",
			image_name = "item_room_image_item_info_panel_frame_bottom_",
			pos = v(369.1, 185.25),
			anchor = v(233.8, -156.5)
		},
		{
			class = "KImageView",
			image_name = "item_room_image_item_info_panel_frame_top_",
			pos = v(369.1, 185.25),
			anchor = v(233, 172.05)
		},
		{
			vertical_align = "middle-caps",
			text_align = "left",
			text_key = "ITEM_ROOM_item_name",
			font_size = 25,
			line_height_extra = "2",
			text = "Junk Bomb",
			class = "GG5Label",
			id = "label_item_name",
			fit_size = true,
			font_name = "fla_h",
			pos = v(160.25, 28.15),
			size = v(418.1, 39.6),
			colors = {
				text = {
					255,
					199,
					64
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "ITEM_ROOM_item_desc",
			font_size = 22,
			line_height_extra = "0",
			text = "An old wizard king that  refused to die at any cost. after learning the secret arts of the necromancy he became an undead by his own power. Now he joins teh Veznan army to become even stronger.",
			class = "GG5Label",
			id = "label_item_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(159.65, 67.95),
			size = v(417.75, 203.1),
			colors = {
				text = {
					203,
					209,
					196
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "ITEM_ROOM_item_bottom_desc",
			font_size = 21,
			line_height_extra = "-2",
			text = "Goblins have this innate talent of making explode everything they touch.",
			class = "GG5Label",
			id = "label_item_bottom_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(160.25, 268.15),
			size = v(417.75, 66.1),
			colors = {
				text = {
					245,
					210,
					126
				}
			}
		}
	}
}
