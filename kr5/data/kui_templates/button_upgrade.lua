-- chunkname: @./kr5/data/kui_templates/button_upgrade.lua

return {
	default_image_name = "upgrades_room_image_upgrade_button_bg_0001",
	class = "UpgradeRoomUpgradeView",
	focus_image_name = "upgrades_room_image_upgrade_button_bg_0003",
	image_offset = v(-65.55, -66.6),
	hit_rect = r(-65.55, -66.6, 135, 130),
	children = {
		{
			class = "KImageView",
			image_name = "upgrades_room_image_upgrades_icon_",
			id = "upgrade_icon",
			pos = v(0.05, -4.7),
			scale = v(1, 1.0047),
			anchor = v(46, 46)
		},
		{
			id = "image_upgrade_level_up",
			image_name = "upgrades_room_image_upgrade_level_up_",
			class = "KImageView",
			pos = v(0.25, -4.2),
			anchor = v(46.35, 46.65)
		},
		{
			id = "image_upgrade_level_up_disabled",
			image_name = "upgrades_room_image_upgrade_level_up_disabled_",
			class = "KImageView",
			pos = v(0.25, -4.2),
			anchor = v(46.35, 46.65)
		},
		{
			id = "image_upgrade_sell",
			image_name = "upgrades_room_image_upgrade_sell_",
			class = "KImageView",
			pos = v(0.25, -4.2),
			anchor = v(46.35, 46.65)
		},
		{
			id = "image_upgrade_sell_disabled",
			image_name = "upgrades_room_image_upgrade_sell_disabled_",
			class = "KImageView",
			pos = v(0.25, -4.2),
			anchor = v(46.35, 46.65)
		},
		{
			image_name = "upgrades_room_image_upgrade_frame_",
			class = "KImageView",
			pos = v(-0.15, -3.4),
			scale = v(1, 1),
			anchor = v(57.6, 57.75)
		},
		{
			id = "upgrade_flash",
			image_name = "upgrades_room_image_upgrade_flash_",
			class = "KImageView",
			pos = v(0, -4.3),
			anchor = v(54.05, 53.9)
		},
		{
			id = "image_upgrade_cost_bg",
			image_name = "upgrades_room_image_upgrade_cost_bg_",
			class = "KImageView",
			pos = v(0.2, 46.4),
			anchor = v(32.75, 17.1)
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 22,
			text = "2",
			id = "label_upgrade_cost",
			fit_size = true,
			font_name = "fla_numbers",
			pos = v(1.45, 30.95),
			size = v(19.1, 34.9),
			colors = {
				text = {
					114,
					255,
					173
				}
			}
		},
		{
			id = "image_upgrade_cost_bg_disabled",
			image_name = "upgrades_room_image_upgrade_cost_bg_disabled_",
			class = "KImageView",
			pos = v(0.2, 46.4),
			anchor = v(32.75, 17.1)
		},
		{
			vertical_align = "middle",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "2",
			font_size = 22,
			text = "2",
			id = "label_upgrade_cost_disabled",
			fit_size = true,
			font_name = "fla_numbers",
			pos = v(1.45, 31),
			size = v(19.1, 31.1),
			colors = {
				text = {
					43,
					110,
					71
				}
			}
		},
		{
			class = "KImageView",
			image_name = "upgrades_room_image_upgrades_bought_",
			id = "image_upgrade_bought",
			pos = v(0.2, -0.35),
			scale = v(1, 1),
			anchor = v(47.05, 51.15)
		},
		{
			class = "GGAni",
			id = "animation_upgrade_select_fx",
			pos = v(0.25, 6.85),
			scale = v(0.9227, 0.9227),
			anchor = v(59.3, 94.25),
			animation = {
				to = 18,
				prefix = "upgrades_room_animation_upgrade_select_fx",
				from = 1
			}
		}
	}
}
