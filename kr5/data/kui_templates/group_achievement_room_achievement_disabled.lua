-- chunkname: @./kr5/data/kui_templates/group_achievement_room_achievement_disabled.lua

return {
	class = "KView",
	children = {
		{
			id = "image_achievements_room_achievement_bg_disabled",
			image_name = "achievements_room_image_achievements_room_achievement_bg_disabled_",
			class = "KImageView",
			pos = v(-2.9, -0.5),
			anchor = v(255.65, 92)
		},
		{
			id = "image_achievements_room_gems_bg",
			image_name = "achievements_room_image_achievements_room_gems_bg_",
			class = "KImageView",
			pos = v(-177.45, 69.2),
			anchor = v(63.15, 17.25)
		},
		{
			id = "image_achievements_room_achievement_icon",
			image_name = "achievements_room_image_achievements_room_achievement_icon_",
			class = "KImageView",
			pos = v(-184.15, -19.05),
			anchor = v(58.3, 58.05)
		},
		{
			id = "image_achievements_room_progress_bg",
			image_name = "achievements_room_image_achievements_room_progress_bg_",
			class = "KImageView",
			pos = v(2, 65.55),
			anchor = v(111.6, 4.55)
		},
		{
			class = "GG59View",
			image_name = "achievements_room_9slice_achievements_room_progress_bar_",
			id = "image_achievements_room_progress_bar",
			pos = v(-108.35, 61.95),
			size = v(35.2896, 7.65),
			anchor = v(0.0626, 0.05),
			slice_rect = r(12, -1.85, 3.35, 3.85)
		},
		{
			vertical_align = "top",
			text_align = "left",
			line_height_extra = "0",
			font_size = 17,
			fit_size = true,
			text = "9999/10000",
			class = "GG5Label",
			id = "label_achievement_room_achievement_progress",
			font_name = "fla_numbers",
			pos = v(119.5, 51.65),
			scale = v(1, 1),
			size = v(122.3, 24.95),
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
			line_height_extra = "0",
			font_size = 21,
			fit_size = true,
			text = "200",
			class = "GG5Label",
			id = "label_achievement_room_gem_reward",
			font_name = "fla_numbers",
			pos = v(-194.25, 53.95),
			scale = v(1, 1),
			size = v(58.35, 29.85),
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
			text_key = "ACHIEVEMENT_ROOM_achievement_desc",
			font_size = 20,
			line_height_extra = "0",
			fit_size = true,
			text = "Destroy 3 Mine Carts before they can reach destinationda\ndsfasdfasfdzxscz",
			class = "GG5Label",
			id = "label_achievement_room_desc_disabled",
			font_name = "fla_body",
			pos = v(-109.95, -42.95),
			scale = v(1, 1),
			size = v(338.2, 88.15),
			colors = {
				text = {
					121,
					143,
					149
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
			id = "label_achievement_room_name_disabled",
			font_name = "fla_body",
			pos = v(-109.75, -77.05),
			scale = v(1, 1),
			size = v(338.5, 31.95),
			colors = {
				text = {
					149,
					136,
					38
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
