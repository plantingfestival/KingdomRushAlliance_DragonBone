-- chunkname: @./kr5/data/kui_templates/group_restore.lua

return {
	class = "RestoreView",
	children = {
		{
			image_name = "screen_slots_9slice_restore_panel_bg_",
			class = "GG59View",
			pos = v(17.95, 51.45),
			size = v(989.6928, 623.15),
			anchor = v(482.0402, 319.75),
			slice_rect = r(347.65, 302.8, 18, 9)
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "RESTORE_SLOT_TITLE",
			font_size = 44,
			line_height_extra = "0",
			text = "Choose slot to replace",
			class = "GG5Label",
			id = "restore_pick_slot_label",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-412.95, -219.2),
			size = v(882.35, 43.75),
			colors = {
				text = {
					224,
					248,
					255
				}
			}
		},
		{
			id = "restore_slots",
			class = "KView",
			pos = v(-62, 259.2),
			children = {
				{
					class = "SlotView",
					template_name = "group_slot",
					id = "restore_slot_1",
					pos = v(255.85, -354.8),
					scale = v(0.8285, 0.8285)
				},
				{
					class = "SlotView",
					template_name = "group_slot",
					id = "restore_slot_2",
					pos = v(255.85, -209.55),
					scale = v(0.8285, 0.8285)
				},
				{
					class = "SlotView",
					template_name = "group_slot",
					id = "restore_slot_3",
					pos = v(255.85, -62.85),
					scale = v(0.8285, 0.8285)
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "RESTORE_SLOT_ADD_GEMS_TITLE",
			font_size = 44,
			line_height_extra = "0",
			text = "Choose slot to add gems",
			class = "GG5Label",
			id = "restore_pick_slot_add_gems_label",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-412.95, -219.2),
			size = v(881.6, 43.75),
			colors = {
				text = {
					224,
					248,
					255
				}
			}
		},
		{
			id = "restore_new_stats",
			class = "KView",
			pos = v(-359.05, 98.75),
			children = {
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 30,
					text = "199/199",
					id = "l_stars",
					fit_size = true,
					font_name = "fla_numbers",
					pos = v(59.45, -99.4),
					size = v(139.95, 40.95),
					colors = {
						text = {
							224,
							248,
							255
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 30,
					text = "99",
					id = "l_heroic",
					fit_size = true,
					font_name = "fla_numbers",
					pos = v(58.3, -42.75),
					size = v(52.05, 40.95),
					colors = {
						text = {
							224,
							248,
							255
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 30,
					text = "99",
					id = "l_iron",
					fit_size = true,
					font_name = "fla_numbers",
					pos = v(166.75, -42.75),
					size = v(53.45, 40.95),
					colors = {
						text = {
							224,
							248,
							255
						}
					}
				},
				{
					class = "KImageView",
					image_name = "screen_slots_image_slot_badges_",
					id = "restore_badges",
					pos = v(48.15, -72.5),
					scale = v(1.1974, 1.1974),
					anchor = v(43.1, 22.6)
				}
			}
		},
		{
			id = "restore_add_gems",
			class = "KView",
			pos = v(-240.4, 49),
			children = {
				{
					class = "KImageView",
					image_name = "screen_slots_image_gem_",
					pos = v(-81.85, 0),
					anchor = v(36.35, 32.35)
				},
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 34,
					text = "2000",
					id = "l_gems",
					fit_size = true,
					font_name = "fla_numbers",
					pos = v(-31.8, -23.75),
					size = v(175.7, 45.9),
					colors = {
						text = {
							224,
							248,
							255
						}
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "ERROR_MESSAGE_GENERIC",
			font_size = 44,
			line_height_extra = "0",
			text = "Ups! Something went wrong.",
			class = "GG5Label",
			id = "restore_error_label",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-400.7, 25.25),
			size = v(836.95, 43.75),
			colors = {
				text = {
					224,
					248,
					255
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			class = "GG5Label",
			line_height_extra = "0",
			font_size = 44,
			text = "XXX",
			id = "restore_error_code_label",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-400.7, 175.85),
			size = v(836.95, 47.75),
			colors = {
				text = {
					224,
					248,
					255
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "RESTORE_SLOT_PROGRESS_MSG",
			font_size = 44,
			line_height_extra = "0",
			text = "GETTING RESTORE DATA FROM SERVER...",
			class = "GG5Label",
			id = "restore_in_progress",
			fit_size = true,
			font_name = "fla_h",
			pos = v(-323.35, 4),
			size = v(711.2, 83.5),
			colors = {
				text = {
					224,
					248,
					255
				}
			}
		},
		{
			class = "GG5Button",
			focus_image_name = "screen_slots_button_close_slots_sindow_0003",
			id = "restore_view_close_button",
			default_image_name = "screen_slots_button_close_slots_sindow_0001",
			pos = v(497.9, -250.65),
			scale = v(1, 1),
			anchor = v(53.6, 45.25)
		}
	}
}
