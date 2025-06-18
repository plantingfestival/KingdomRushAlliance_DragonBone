-- chunkname: @./kr5/data/kui_templates/popup_error.lua

return {
	class = "GG5PopUpError",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_",
					class = "KImageView",
					pos = v(4.9, -0.75),
					scale = v(0.9911, 1.0025),
					anchor = v(361.55, -164.85)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(1.25, 12.75),
					size = v(680.4273, 363.4644),
					anchor = v(340.2137, 181.7322),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_01_",
					class = "KImageView",
					pos = v(338.45, 12.65),
					scale = v(1, 0.9937),
					anchor = v(9.45, 154.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_02_",
					class = "KImageView",
					pos = v(-340.25, 13.65),
					scale = v(1, 1.2191),
					anchor = v(9.35, 126.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(339.75, -26.75),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(339.35, 51.85),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-340.5, -26.75),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-340.9, 51.85),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_03_",
					class = "KImageView",
					pos = v(5.6, -168.35),
					scale = v(0.9171, 1),
					anchor = v(319.95, 11.2)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_04_",
					class = "KImageView",
					pos = v(-4.35, 195.4),
					scale = v(0.9608, 1),
					anchor = v(295.45, 11.15)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_01_",
					pos = v(-307.1, -131.8),
					anchor = v(46.25, 44.75)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_03_",
					pos = v(-307.1, 159.6),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_04_",
					pos = v(307.1, 159.6),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_02_",
					pos = v(287.5, -133.55),
					anchor = v(29, 44.45)
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					text_key = "POPUP_label_error_msg",
					font_size = 40,
					line_height_extra = "0",
					text = "error",
					class = "GG5Label",
					id = "label_error_msg",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-278.4, -137.5),
					size = v(559.1, 54.4),
					colors = {
						text = {
							231,
							244,
							251
						}
					}
				},
				{
					vertical_align = "middle",
					text_align = "center",
					text_key = "POPUP_label_error_msg2",
					font_size = 29,
					line_height_extra = "0",
					text = "couldnt process the purchase or something. i dont know.",
					class = "GG5Label",
					id = "label_error_msg2",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-278.4, -70.9),
					size = v(559.1, 128.95),
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
					pos = v(0.45, -201.3),
					size = v(360.8248, 62.2981),
					anchor = v(180.4481, 27.6492),
					slice_rect = r(117.95, -1.9, 16.8, 62.65)
				},
				{
					id = "warning_sign",
					image_name = "gui_popups_image_warning_sign_",
					class = "KImageView",
					pos = v(0.4, -218.8),
					anchor = v(66.35, 48.15)
				},
				{
					default_image_name = "gui_popups_button_confirm_ok_bg_0001",
					focus_image_name = "gui_popups_button_confirm_ok_bg_0003",
					class = "GG5Button",
					id = "button_popup_confirm_ok",
					pos = v(-1.1, 119.3),
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
				}
			}
		}
	}
}
