-- chunkname: @./kr5/data/kui_templates/game_gui_power_button.lua

local function v(x, y)
	return {
		x = x,
		y = y
	}
end

return {
	class = "PowerButton",
	children = {
		{
			id = "hover",
			image_name = "power_button_frame_hover",
			class = "KImageView",
			hidden = true,
			pos = v(-19, -20)
		},
		{
			id = "mask",
			image_name = "power_loading",
			class = "KImageView"
		},
		{
			id = "timer_mask",
			class = "KImageView",
			image_name = "power_loading",
			pos = v(0, -2)
		},
		{
			class = "KImageView",
			id = "left_door",
			image_name = "ingame_ui_power_button_doors_0001",
			pos = v(-12, -13),
			animation = {
				hide_at_end = true,
				prefix = "ingame_ui_power_button_doors",
				to = 13
			}
		},
		{
			class = "KImageView",
			id = "right_door",
			image_name = "ingame_ui_power_button_doors_0001",
			pos = v(-11, -30),
			animation = {
				hide_at_end = true,
				prefix = "ingame_ui_power_button_doors",
				to = 13
			},
			scale = v(1, 1),
			pos = v(0, 0)
		},
		{
			id = "power_frame",
			class = "KImageView",
			image_name = "ingame_ui_power_button_frame",
			pos = v(-22, -19)
		},
		{
			class = "KImageView",
			id = "glow",
			image_name = "power_button_doors_light_0001",
			pos = v(4, 48),
			animation = {
				hide_at_end = false,
				prefix = "power_button_doors_light",
				to = 13
			}
		},
		{
			id = "selected",
			class = "KImageView",
			image_name = "ingame_ui_power_button_frame_select",
			pos = v(-20, -20)
		},
		{
			class = "KImageView",
			id = "instant_reload",
			image_name = "reload_skill_reload_skill_0001",
			pos = v(-31, -66),
			animation = {
				hide_at_end = true,
				prefix = "reload_skill_reload_skill",
				to = 17
			}
		}
	}
}
