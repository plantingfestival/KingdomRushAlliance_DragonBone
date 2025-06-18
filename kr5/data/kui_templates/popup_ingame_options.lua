-- chunkname: @./kr5/data/kui_templates/popup_ingame_options.lua

return {
	class = "GG5PopUpIngameOptions",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					class = "KImageView",
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_",
					pos = v(3.55, -5.95),
					anchor = v(361.55, -164.85)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(3.6, -6.35),
					size = v(730.2912, 391.249),
					anchor = v(365.1456, 195.6245),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_side_01_",
					pos = v(365.95, -24.1),
					anchor = v(9.45, 154.4)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_side_02_",
					pos = v(-364.4, -5.9),
					anchor = v(9.35, 126.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(366.15, -71.45),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(365.75, 60.55),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-365.75, -71.45),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-366.15, 60.55),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_03_",
					class = "KImageView",
					pos = v(24, -199.3),
					scale = v(1.0778, 1),
					anchor = v(319.95, 11.2)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_04_",
					class = "KImageView",
					pos = v(-2.95, 186.3),
					scale = v(1.0778, 1),
					anchor = v(295.45, 11.15)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_01_",
					pos = v(-329.05, -163.8),
					anchor = v(46.25, 44.75)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_03_",
					pos = v(-329.05, 149.4),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_04_",
					pos = v(330.2, 149.4),
					anchor = v(46.25, 44.8)
				},
				{
					class = "GG5Button",
					focus_image_name = "gui_popups_button_close_ingame_0003",
					id = "button_close_popup",
					default_image_name = "gui_popups_button_close_ingame_0001",
					pos = v(350.55, -183.5),
					scale = v(1, 1),
					anchor = v(42.55, 42.9)
				},
				{
					class = "GG59View",
					image_name = "gui_popups_9slice_image_title_bg_",
					id = "tittle_bg",
					pos = v(0.15, -231.1),
					size = v(447.373, 62.2981),
					anchor = v(223.7308, 27.6492),
					slice_rect = r(117.95, -1.9, 16.8, 62.65)
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					font_size = 42,
					line_height_extra = "2",
					fit_size = true,
					text = "options",
					text_key = "POPUP_label_title_options",
					class = "GG5ShaderLabel",
					id = "label_title_options",
					font_name = "fla_h",
					pos = v(-160.5, -253.95),
					scale = v(1, 1),
					size = v(317.35, 57.75),
					colors = {
						text = {
							231,
							244,
							250
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 3.3333333333333335,
							outline_color = {
								0.251,
								0.3451,
								0.3725,
								1
							}
						}
					}
				},
				{
					id = "button_restart",
					focus_image_name = "gui_popups_button_ingame_restart_0003",
					class = "GG5Button",
					default_image_name = "gui_popups_button_ingame_restart_0001",
					pos = v(131.3, -23.95),
					anchor = v(104.55, 103.25)
				},
				{
					id = "button_quit",
					focus_image_name = "gui_popups_button_ingame_quit_0003",
					class = "GG5Button",
					default_image_name = "gui_popups_button_ingame_quit_0001",
					pos = v(-131.3, -23.95),
					anchor = v(104.55, 103.25)
				},
				{
					id = "toggle_ingame_sfx",
					false_image_name = "gui_popups_toggle_ingame_sfx_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_ingame_sfx_0001",
					focus_image_name = "gui_popups_toggle_ingame_sfx_0003",
					pos = v(86.7, 187.5),
					anchor = v(99.3, 74.85)
				},
				{
					id = "toggle_ingame_music",
					false_image_name = "gui_popups_toggle_ingame_music_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_ingame_music_0001",
					focus_image_name = "gui_popups_toggle_ingame_music_0003",
					pos = v(-86.65, 187.5),
					anchor = v(99.3, 74.85)
				}
			}
		}
	}
}
