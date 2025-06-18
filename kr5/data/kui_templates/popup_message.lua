-- chunkname: @./kr5/data/kui_templates/popup_message.lua

return {
	class = "GG5PopUpMessage",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					class = "KImageView",
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_medium_",
					pos = v(4.55, -19.4),
					anchor = v(386.9, -199.4)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(1.45, 20.4),
					size = v(742.9758, 390.385),
					anchor = v(371.4879, 195.1925),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_01_medium_",
					class = "KImageView",
					pos = v(371.5, -0.95),
					scale = v(1, 0.8387),
					anchor = v(9.45, 156.8)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_02_medium_",
					class = "KImageView",
					pos = v(-371.95, 9.2),
					scale = v(1, 0.8387),
					anchor = v(9.35, 164.65)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(372.45, -44.15),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(372.05, 87.85),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-373.3, -44.15),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-373.7, 87.85),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_side_03_medium_",
					pos = v(1.95, -174.1),
					anchor = v(343.6, 11.2)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_side_04_medium_",
					pos = v(-0.1, 217.8),
					anchor = v(324, 11.15)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_01_",
					pos = v(-336.6, -138.6),
					anchor = v(46.25, 44.75)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_03_",
					pos = v(-336.6, 180.9),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_04_",
					pos = v(336.5, 180.9),
					anchor = v(46.25, 44.8)
				},
				{
					class = "GG59View",
					image_name = "gui_popups_9slice_image_title_bg_",
					id = "tittle_bg",
					pos = v(-2.55, -208.8),
					size = v(315.41, 62.2981),
					anchor = v(157.7362, 27.6492),
					slice_rect = r(117.95, -1.9, 16.8, 62.65)
				},
				{
					id = "warning_sign",
					image_name = "gui_popups_image_warning_sign_",
					class = "KImageView",
					pos = v(-4.35, -214.25),
					anchor = v(66.35, 48.15)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_02_",
					pos = v(319.5, -139.1),
					anchor = v(29, 44.45)
				},
				{
					vertical_align = "top",
					text_align = "center",
					text_key = "POPUP_label_desc",
					font_size = 58,
					line_height_extra = "1",
					text = "Exit?",
					class = "GG5Label",
					id = "label_desc",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-319.05, -89.15),
					size = v(637.05, 75.45),
					colors = {
						text = {
							231,
							244,
							251
						}
					}
				},
				{
					default_image_name = "gui_popups_button_yes_bg _0001",
					focus_image_name = "gui_popups_button_yes_bg _0003",
					class = "GG5Button",
					id = "button_popup_yes",
					pos = v(172.25, 119.15),
					scale = v(1, 1),
					image_offset = v(-150.35, -56.75),
					hit_rect = r(-150.35, -56.75, 303, 118),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 44,
							line_height_extra = "0",
							fit_size = true,
							text = "YES",
							text_key = "BUTTON_OK",
							class = "GG5ShaderLabel",
							id = "label_button_yes",
							font_name = "fla_h",
							pos = v(-108.35, -31.75),
							scale = v(1, 1),
							size = v(219.1, 59.45),
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
					default_image_name = "gui_popups_button_no_bg _0001",
					focus_image_name = "gui_popups_button_no_bg _0003",
					class = "GG5Button",
					id = "button_popup_no",
					pos = v(-172.7, 119.15),
					scale = v(1, 1),
					image_offset = v(-150.35, -56.75),
					hit_rect = r(-150.35, -56.75, 303, 118),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 44,
							line_height_extra = "0",
							fit_size = true,
							text = "No",
							text_key = "BUTTON_OK",
							class = "GG5ShaderLabel",
							id = "label_button_no",
							font_name = "fla_h",
							pos = v(-112.4, -30.45),
							scale = v(1, 1),
							size = v(226.8, 55.8),
							colors = {
								text = {
									47,
									14,
									9
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 3.3333333333333335,
									outline_color = {
										0.9059,
										0.4745,
										0.4196,
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
