-- chunkname: @./kr5/data/kui_templates/group_tower_info_panel.lua

return {
	class = "KView",
	children = {
		{
			image_name = "tower_room_9slice_info_bg_",
			class = "GG59View",
			pos = v(2.95, 21.8),
			size = v(459.2828, 241.3462),
			anchor = v(0, 0),
			slice_rect = r(15.2, 15, 9.75, 10.2)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_info_panel_frame_",
			pos = v(233.15, 150.8),
			anchor = v(233, 131.05)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "TOWER_ROOM_tower_desc",
			font_size = 22,
			line_height_extra = "0",
			text = "Rigorously trained to be the deadliest of marksmen, these archers will easily take car of enemies before they get noticed",
			class = "GG5Label",
			id = "label_tower_desc",
			fit_size = true,
			font_name = "fla_body",
			pos = v(14.65, 74),
			size = v(435.35, 151.25),
			colors = {
				text = {
					203,
					209,
					196
				}
			}
		},
		{
			vertical_align = "middle-caps",
			text_align = "left",
			text_key = "TOWER_ROOM_tower_name",
			font_size = 25,
			line_height_extra = "2",
			text = "Paladin Covenant",
			class = "GG5Label",
			id = "label_tower_name",
			fit_size = true,
			font_name = "fla_h",
			pos = v(14.65, 33.1),
			size = v(433.65, 44.3),
			colors = {
				text = {
					255,
					212,
					64
				}
			}
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_stats_bar_bg_",
			pos = v(46.75, 231.75),
			anchor = v(0, 0)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_stats_bar_bg_",
			pos = v(196.7, 231.75),
			anchor = v(0, 0)
		},
		{
			class = "KImageView",
			image_name = "tower_room_image_tower_stats_bar_bg_",
			pos = v(346.6, 231.75),
			anchor = v(0, 0)
		},
		{
			class = "GG59View",
			image_name = "tower_room_image_tower_stat_bar_",
			id = "tower_stat_bar_1",
			pos = v(46.8, 237.45),
			size = v(97.5213, 11.85),
			anchor = v(0, 5.85),
			slice_rect = r(2.3, 2, 2.45, 7.35)
		},
		{
			class = "GG59View",
			image_name = "tower_room_image_tower_stat_bar_",
			id = "tower_stat_bar_2",
			pos = v(196.95, 237.55),
			size = v(97.5213, 11.85),
			anchor = v(0, 5.85),
			slice_rect = r(2.3, 2, 2.45, 7.35)
		},
		{
			class = "GG59View",
			image_name = "tower_room_image_tower_stat_bar_",
			id = "tower_stat_bar_3",
			pos = v(346.7, 237.5),
			size = v(98.178, 11.85),
			anchor = v(0, 5.85),
			slice_rect = r(2.3, 2, 2.45, 7.35)
		},
		{
			id = "tower_stat_icon_1",
			image_name = "tower_room_image_tower_stat_icon_",
			class = "KImageView",
			pos = v(27.55, 236.6),
			anchor = v(12, 12)
		},
		{
			id = "tower_stat_icon_2",
			image_name = "tower_room_image_tower_stat_icon_",
			class = "KImageView",
			pos = v(177.75, 236.6),
			anchor = v(12, 12)
		},
		{
			id = "tower_stat_icon_3",
			image_name = "tower_room_image_tower_stat_icon_",
			class = "KImageView",
			pos = v(327.95, 236.6),
			anchor = v(12, 12)
		}
	}
}
