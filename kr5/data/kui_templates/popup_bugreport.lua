-- chunkname: @./kr5/data/kui_templates/popup_bugreport.lua

return {
	class = "GG5PopUpBugReport",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_",
					class = "KImageView",
					pos = v(4.9, 123.2),
					scale = v(0.9911, 1.0025),
					anchor = v(361.55, -164.85)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(1.25, 40.3),
					size = v(680.4273, 552.2789),
					anchor = v(340.2137, 276.1394),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_01_",
					class = "KImageView",
					pos = v(340.45, 40.65),
					scale = v(1, 1.4271),
					anchor = v(9.45, 154.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_02_",
					class = "KImageView",
					pos = v(-340.25, 31.6),
					scale = v(1, 1.9207),
					anchor = v(9.35, 126.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(339.75, -98.7),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(339.35, -20.1),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-340.5, -98.7),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-340.9, -20.1),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_03_",
					class = "KImageView",
					pos = v(5.6, -240.3),
					scale = v(0.9171, 1),
					anchor = v(319.95, 11.2)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_04_",
					class = "KImageView",
					pos = v(-4.35, 311.4),
					scale = v(0.9608, 1),
					anchor = v(295.45, 11.15)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_01_",
					pos = v(-307.1, -203.75),
					anchor = v(46.25, 44.75)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_03_",
					pos = v(-307.1, 275.6),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_04_",
					pos = v(307.1, 275.6),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_02_",
					pos = v(287.5, -205.5),
					anchor = v(29, 44.45)
				},
				{
					focus_image_name = "gui_popups_button_bugreport_0003",
					class = "GG5Button",
					id = "button_reportlostcontent",
					default_image_name = "gui_popups_button_bugreport_0001",
					pos = v(2.05, -57.95),
					image_offset = v(-240, -56.35),
					hit_rect = r(-240, -56.35, 483, 114),
					children = {
						{
							vertical_align = "middle-caps",
							text_align = "center",
							font_size = 40,
							line_height_extra = "2",
							fit_size = true,
							text = "lost content",
							text_key = "POPUP_label_title_reportlostcontent",
							class = "GG5ShaderLabel",
							id = "label_button_reportlostcontent",
							font_name = "fla_h",
							pos = v(-206.9, -26.45),
							scale = v(0.9999, 0.9999),
							size = v(419.8, 58.25),
							colors = {
								text = {
									232,
									245,
									251
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 3.3333333333333335,
									outline_color = {
										0.3961,
										0.4941,
										0.5216,
										1
									}
								}
							}
						}
					}
				},
				{
					focus_image_name = "gui_popups_button_bugreport_0003",
					class = "GG5Button",
					id = "button_reportbug",
					default_image_name = "gui_popups_button_bugreport_0001",
					pos = v(2.05, -157.95),
					image_offset = v(-240, -56.35),
					hit_rect = r(-240, -56.35, 483, 114),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 40,
							line_height_extra = "2",
							text_key = "POPUP_label_title_reportbug",
							text = "BUG",
							class = "GG5ShaderLabel",
							id = "label_button_reportbug",
							font_name = "fla_h",
							pos = v(-206.9, -23.85),
							scale = v(0.9999, 0.9999),
							size = v(416.8, 50.6),
							colors = {
								text = {
									232,
									245,
									251
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 3.3333333333333335,
									outline_color = {
										0.3961,
										0.4941,
										0.5216,
										1
									}
								}
							}
						}
					}
				},
				{
					focus_image_name = "gui_popups_button_bugreport_0003",
					class = "GG5Button",
					id = "button_reportother",
					default_image_name = "gui_popups_button_bugreport_0001",
					pos = v(2.05, 142.05),
					image_offset = v(-240, -56.35),
					hit_rect = r(-240, -56.35, 483, 114),
					children = {
						{
							vertical_align = "middle-caps",
							text_align = "center",
							font_size = 40,
							line_height_extra = "2",
							fit_size = true,
							text = "lost content",
							text_key = "POPUP_label_title_reportcrash",
							class = "GG5ShaderLabel",
							id = "label_button_reportother",
							font_name = "fla_h",
							pos = v(-206.9, -25.15),
							scale = v(0.9999, 0.9999),
							size = v(419.8, 53.15),
							colors = {
								text = {
									232,
									245,
									251
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 3.3333333333333335,
									outline_color = {
										0.3961,
										0.4941,
										0.5216,
										1
									}
								}
							}
						}
					}
				},
				{
					focus_image_name = "gui_popups_button_bugreport_0003",
					class = "GG5Button",
					id = "button_reportcrash",
					default_image_name = "gui_popups_button_bugreport_0001",
					pos = v(2.05, 43.05),
					image_offset = v(-240, -56.35),
					hit_rect = r(-240, -56.35, 483, 114),
					children = {
						{
							vertical_align = "middle-caps",
							text_align = "center",
							font_size = 40,
							line_height_extra = "2",
							fit_size = true,
							text = "CRASH",
							text_key = "POPUP_label_title_reportcrash",
							class = "GG5ShaderLabel",
							id = "label_button_reportcrash",
							font_name = "fla_h",
							pos = v(-206.9, -23.85),
							scale = v(0.9999, 0.9999),
							size = v(419.8, 53.2),
							colors = {
								text = {
									232,
									245,
									251
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 3.3333333333333335,
									outline_color = {
										0.3961,
										0.4941,
										0.5216,
										1
									}
								}
							}
						}
					}
				},
				{
					class = "GG59View",
					image_name = "gui_popups_9slice_image_title_bg_",
					id = "tittle_bg",
					pos = v(0.45, -273.25),
					size = v(360.8248, 62.2981),
					anchor = v(180.4481, 27.6492),
					slice_rect = r(117.95, -1.9, 16.8, 62.65)
				},
				{
					id = "warning_sign",
					image_name = "gui_popups_image_warning_sign_",
					class = "KImageView",
					pos = v(0.4, -290.75),
					anchor = v(66.35, 48.15)
				},
				{
					default_image_name = "gui_popups_button_confirm_ok_bg_0001",
					focus_image_name = "gui_popups_button_confirm_ok_bg_0003",
					class = "GG5Button",
					id = "button_popup_confirm_ok",
					pos = v(-1.1, 251.25),
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
