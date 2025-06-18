-- chunkname: @./kr5/data/kui_templates/ingame_achievement_ui.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "group_ingame_achievements_ui",
			class = "KView",
			pos = v(150.5, 0),
			children = {
				{
					class = "KImageView",
					image_name = "ingame_achievement_ui_image_ingame_achievements_ui_",
					id = "image_ingame_achievements_ui",
					pos = v(-102.15, 40.6),
					scale = v(1.3078, 1.3078),
					anchor = v(34.95, 29.4)
				},
				{
					id = "image_ingame_achievements_icon_ui",
					class = "KImageView",
					pos = v(-109.95, 40.05),
					anchor = v(32, 32)
				},
				{
					vertical_align = "top",
					text_align = "left",
					line_height_extra = "0",
					font_size = 12,
					fit_size = true,
					text = "Destroy 3 Mine Carts before they can reach destinationda\ndsfasdfasfdzxscz",
					class = "GG5Label",
					id = "label_achievement_desc",
					font_name = "fla_body",
					pos = v(-69.55, 25.65),
					scale = v(1, 1),
					size = v(209.15, 48.4),
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
					line_height_extra = "2",
					font_size = 14,
					text = "Feels good to be back ",
					class = "GG5Label",
					id = "label_achievement_name",
					font_name = "fla_body",
					pos = v(-69.55, 7.1),
					scale = v(1, 1),
					size = v(209.1, 21.25),
					colors = {
						text = {
							255,
							212,
							64
						}
					}
				},
				{
					id = "animation_ingame_achievements_ui_glow_fx",
					class = "GGAni",
					pos = v(-110, 40.2),
					anchor = v(29.8, 29.85),
					animation = {
						to = 17,
						prefix = "ingame_achievement_ui_animation_ingame_achievements_ui_glow_fx",
						from = 1
					}
				},
				{
					id = "animation_ingame_achievements_ui_fx",
					class = "GGAni",
					pos = v(-109.45, 29.9),
					anchor = v(37.2, 36),
					animation = {
						to = 28,
						prefix = "ingame_achievement_ui_animation_ingame_achievements_ui_fx",
						from = 1
					}
				}
			}
		}
	}
}
