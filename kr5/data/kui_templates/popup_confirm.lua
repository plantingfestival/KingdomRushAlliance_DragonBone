-- chunkname: @./kr5/data/kui_templates/popup_confirm.lua

return {
	class = "GG5PopUpConfirm",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_",
					class = "KImageView",
					pos = v(1.6, -55.55),
					scale = v(0.8799, 1.0025),
					anchor = v(361.55, -164.85)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(1.25, 6.35),
					size = v(616.5406, 287.9606),
					anchor = v(308.2703, 143.9803),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_01_",
					class = "KImageView",
					pos = v(306.25, 6.5),
					scale = v(1, 0.7768),
					anchor = v(9.45, 154.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_02_",
					class = "KImageView",
					pos = v(-306.95, 20.65),
					scale = v(1, 0.7768),
					anchor = v(9.35, 126.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(306.45, -33.15),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(306.05, 45.45),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-308.3, -33.15),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-308.7, 45.45),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_03_",
					class = "KImageView",
					pos = v(5.6, -134.85),
					scale = v(0.8891, 1),
					anchor = v(319.95, 11.2)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_04_",
					class = "KImageView",
					pos = v(-4.1, 149.05),
					scale = v(0.9316, 1),
					anchor = v(295.45, 11.15)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_01_",
					pos = v(-271.6, -99.35),
					anchor = v(46.25, 44.75)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_03_",
					pos = v(-271.6, 112.15),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_04_",
					pos = v(270.5, 112.15),
					anchor = v(46.25, 44.8)
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					text_key = "POPUP_label_confirm_msg",
					font_size = 40,
					line_height_extra = "0",
					text = "Exit?",
					class = "GG5Label",
					id = "label_confirm_msg",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-256, -84.4),
					size = v(512, 75.35),
					colors = {
						text = {
							231,
							244,
							251
						}
					}
				},
				{
					class = "GG59View",
					image_name = "gui_popups_9slice_image_title_bg_",
					id = "tittle_bg",
					pos = v(0.45, -166.65),
					size = v(360.8248, 62.2981),
					anchor = v(180.4481, 27.6492),
					slice_rect = r(117.95, -1.9, 16.8, 62.65)
				},
				{
					id = "warning_sign",
					image_name = "gui_popups_image_warning_sign_",
					class = "KImageView",
					pos = v(0.4, -184.15),
					anchor = v(66.35, 48.15)
				},
				{
					default_image_name = "gui_popups_button_confirm_ok_bg_0001",
					focus_image_name = "gui_popups_button_confirm_ok_bg_0003",
					class = "GG5Button",
					id = "button_popup_confirm_ok",
					pos = v(-1.1, 67.45),
					scale = v(1, 1),
					image_offset = v(-124.1, -48.85),
					hit_rect = r(-124.1, -48.85, 251, 102),
					children = {
						{
							vertical_align = "middle-caps",
							text_align = "center",
							font_size = 44,
							line_height_extra = "0",
							fit_size = true,
							text = "ok",
							text_key = "BUTTON_OK",
							class = "GG5ShaderLabel",
							id = "label_button_ok",
							font_name = "fla_h",
							pos = v(-86.5, -28.9),
							scale = v(1, 1),
							size = v(176.5, 55.2),
							colors = {
								text = {
									12,
									39,
									60
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 3.3333333333333335,
									outline_color = {
										0,
										0.8275,
										0.9961,
										1
									}
								}
							}
						}
					}
				},
				{
					class = "GG5Button",
					focus_image_name = "gui_popups_button_close_ingame_0003",
					id = "button_close_popup",
					default_image_name = "gui_popups_button_close_ingame_0001",
					pos = v(290.85, -119.05),
					scale = v(1, 1),
					anchor = v(42.55, 42.9)
				}
			}
		}
	}
}
