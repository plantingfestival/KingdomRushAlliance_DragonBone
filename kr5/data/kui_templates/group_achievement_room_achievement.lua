-- chunkname: @./kr5/data/kui_templates/group_achievement_room_achievement.lua

return {
	class = "KView",
	children = {
		{
			id = "image_achievements_room_achievement_bg",
			image_name = "achievements_room_image_achievements_room_achievement_bg_",
			class = "KImageView",
			pos = v(-2.9, -0.5),
			anchor = v(252.65, 90)
		},
		{
			id = "image_achievements_room_achievement_icon",
			image_name = "achievements_room_image_achievements_room_achievement_icon_",
			class = "KImageView",
			pos = v(-184.15, -19.05),
			anchor = v(58.3, 58.05)
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "ACHIEVEMENT_ROOM_achievement_desc",
			font_size = 20,
			line_height_extra = "0",
			fit_size = true,
			text = "Destroy 3 Mine Carts before they can reach destinationda\ndsfasdfasfdzxscz",
			class = "GG5Label",
			id = "label_achievement_room_desc",
			font_name = "fla_body",
			pos = v(-109.95, -42.95),
			scale = v(1, 1),
			size = v(338.2, 91.6),
			colors = {
				text = {
					222,
					247,
					255
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "ACHIEVEMENT_ROOM_achievement_name",
			font_size = 21,
			line_height_extra = "2",
			fit_size = true,
			text = "Feels good to be back ",
			class = "GG5Label",
			id = "label_achievement_room_name",
			font_name = "fla_body",
			pos = v(-109.75, -77.05),
			scale = v(1, 1),
			size = v(338.5, 34),
			colors = {
				text = {
					255,
					226,
					0
				}
			}
		},
		{
			id = "image_dlc_1_flag",
			image_name = "achievements_room_image_dlc_dwarf_flag_",
			class = "KImageView",
			pos = v(-218.9, -68.45),
			anchor = v(23.9, 26.3)
		}
	}
}
