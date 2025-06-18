-- chunkname: @./kr5/data/kui_templates/game_gui_hero_portrait.lua

local function v(x, y)
	return {
		x = x,
		y = y
	}
end

return {
	class = "HeroPortrait",
	image_name = "ingame_ui_gui_portraits_hero_bg",
	children = {
		{
			id = "hover",
			image_name = "ingame_ui_gui_portraits_hero_bg_hover",
			class = "KImageView",
			hidden = true
		},
		{
			id = "hero_face",
			class = "KImageView",
			image_name = "hero_portraits_0001",
			pos = v(-2, -18)
		},
		{
			id = "health_bar",
			class = "KImageView",
			image_name = "hero_portrait_bars_0001",
			pos = v(53, 110.56)
		},
		{
			id = "xp_bar",
			class = "KImageView",
			image_name = "hero_portrait_bars_0002",
			pos = v(53, 119)
		},
		{
			font_size = 17,
			align = "center",
			text = "10",
			class = "GGLabel",
			id = "xp_level",
			font_name = "numbers_italic",
			pos = v(24.6, 106),
			size = v(28.8, 19.200000000000003),
			colors = {
				text = {
					255,
					255,
					255,
					255
				}
			}
		},
		{
			id = "overlay",
			clip = true,
			class = "KView",
			hidden = true,
			pos = v(27, 100),
			size = v(88, 72),
			colors = {
				background = {
					255,
					255,
					255,
					0
				}
			},
			children = {
				{
					image_name = "ingame_ui_hero_cooldown",
					propagate_on_down = true,
					class = "KImageView",
					propagate_on_click = true,
					id = "overlay_img",
					scale = v(1, -1),
					pos = v(-10, 89)
				}
			}
		},
		{
			alpha = 1,
			image_name = "hero_portraits_selected_0001",
			class = "KImageView",
			hidden = true,
			id = "outline",
			pos = v(-2, -18),
			size = v(88, 72)
		},
		{
			id = "door",
			image_name = "ingame_ui_gui_portraits_hero_doors_0001",
			class = "KImageView",
			hidden = true,
			pos = v(14, 10),
			animation = {
				hide_at_end = true,
				prefix = "ingame_ui_gui_portraits_hero_doors",
				to = 13
			}
		}
	}
}
