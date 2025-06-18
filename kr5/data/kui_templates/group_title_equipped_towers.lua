-- chunkname: @./kr5/data/kui_templates/group_title_equipped_towers.lua

return {
	class = "KView",
	children = {
		{
			image_name = "tower_room_9slice_info_bg_",
			class = "GG59View",
			pos = v(-186.7, -20.2),
			size = v(373.3514, 40.446),
			anchor = v(0, 0),
			slice_rect = r(15.2, 15, 9.75, 10.2)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			text_key = "TOWER_ROOM_EQUIPPED_TOWERS_TITLE",
			font_size = 27,
			line_height_extra = "0",
			text = "Equipped towers",
			class = "GG5Label",
			id = "label_title_equipped_towers",
			fit_size = true,
			font_name = "fla_body",
			pos = v(-172.9, -22.4),
			size = v(342.8, 44.5),
			colors = {
				text = {
					203,
					209,
					196
				}
			}
		}
	}
}
