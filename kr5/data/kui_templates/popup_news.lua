-- chunkname: @./kr5/data/kui_templates/popup_news.lua

return {
	class = "GG5PopUpNews",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_2_",
					class = "KImageView",
					pos = v(4.25, -53.75),
					scale = v(0.8924, 1),
					anchor = v(586.3, -275.6)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(0.55, -6.05),
					size = v(1049.6707, 547.8798),
					anchor = v(524.8353, 273.9399),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					id = "news_mask",
					class = "KImageView",
					pos = v(-0.6, 0.45),
					anchor = v(510.05, 270.5)
				},
				{
					id = "group_position_marker",
					class = "KView",
					template_name = "group_news_position_marker",
					pos = v(0.4, 231.35)
				},
				{
					image_name = "gui_popups_image_ui_news_border_",
					class = "KImageView",
					pos = v(42.3, -274.75),
					scale = v(1.7343, 1.9394),
					anchor = v(316.55, 4.45)
				},
				{
					image_name = "gui_popups_image_ui_news_border2_",
					class = "KImageView",
					r = -3.1416,
					pos = v(-37.8, 258.35),
					scale = v(1.9999, 1.9393),
					anchor = v(269, 4.45)
				},
				{
					image_name = "gui_popups_image_ui_news_border3_",
					class = "KImageView",
					pos = v(521.65, -22.25),
					scale = v(1, 0.9487),
					anchor = v(8.15, 245.6)
				},
				{
					image_name = "gui_popups_image_ui_news_border4_",
					class = "KImageView",
					pos = v(-513.9, -10.7),
					scale = v(1, 2.2158),
					anchor = v(8.95, 108.95)
				},
				{
					class = "GG59View",
					image_name = "gui_popups_9slice_image_title_bg_",
					id = "tittle_bg",
					pos = v(0.1, -308.75),
					size = v(292.7547, 62.2962),
					anchor = v(146.4063, 27.6483),
					slice_rect = r(117.95, -1.9, 16.8, 62.65)
				},
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 42,
					line_height_extra = "2",
					fit_size = true,
					text = "NEWS",
					text_key = "POPUP_label_title_news",
					class = "GG5ShaderLabel",
					id = "label_title_news",
					font_name = "fla_h",
					pos = v(-158.2, -328.7),
					scale = v(1, 1),
					size = v(317.35, 58.6),
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
					image_name = "gui_popups_image_ui_news_corner1_",
					class = "KImageView",
					r = -1.5708,
					pos = v(-480.6, -242.9),
					scale = v(2.1107, 1.9817),
					anchor = v(19.9, 0.2)
				},
				{
					image_name = "gui_popups_image_ui_news_corner2_",
					class = "KImageView",
					r = -1.5708,
					pos = v(510.1, -263.45),
					scale = v(2.1107, 1.9817),
					anchor = v(10.1, 10.6)
				},
				{
					image_name = "gui_popups_image_ui_news_corner3_",
					class = "KImageView",
					r = -1.5708,
					pos = v(-501.3, 246.25),
					scale = v(2.1107, 1.9817),
					anchor = v(10.1, 10.6)
				},
				{
					image_name = "gui_popups_image_ui_news_corner4_",
					class = "KImageView",
					r = -1.5708,
					pos = v(510.5, 246.75),
					scale = v(2.1107, 1.9817),
					anchor = v(10.1, 10.6)
				},
				{
					class = "GG5Button",
					focus_image_name = "gui_popups_button_close_ingame_0003",
					id = "button_close_popup",
					default_image_name = "gui_popups_button_close_ingame_0001",
					pos = v(515.15, -260.1),
					scale = v(1, 1),
					anchor = v(42.55, 42.9)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-515.8, -160.15),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-515.8, 146.4),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(520.1, -160.15),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(520.1, 146.4),
					anchor = v(8.1, 8.85)
				},
				{
					focus_image_name = "gui_popups_button_news_next_desktop_0003",
					class = "GG5Button",
					id = "button_news_next",
					default_image_name = "gui_popups_button_news_next_desktop_0001",
					pos = v(524.8, -12.3),
					UNLESS = ctx.is_mobile,
					anchor = v(77.95, 77.45)
				},
				{
					focus_image_name = "gui_popups_button_news_prev_desktop_0003",
					class = "GG5Button",
					id = "button_news_prev",
					default_image_name = "gui_popups_button_news_prev_desktop_0001",
					pos = v(-517.25, -12.3),
					UNLESS = ctx.is_mobile,
					anchor = v(78, 77.45)
				},
				{
					focus_image_name = "gui_popups_button_confirm_ok_bg_0003",
					class = "GG5Button",
					id = "button_news_open",
					default_image_name = "gui_popups_button_confirm_ok_bg_0001",
					pos = v(-1.95, 325.4),
					UNLESS = ctx.is_mobile,
					scale = v(1, 1),
					image_offset = v(-124.1, -48.85),
					hit_rect = r(-124.1, -48.85, 251, 102),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 44,
							line_height_extra = "0",
							fit_size = true,
							text = "OPEN",
							text_key = "BUTTON_OPEN",
							class = "GG5ShaderLabel",
							id = "label_button_news_ok",
							font_name = "fla_h",
							pos = v(-86.5, -28.35),
							scale = v(1, 1),
							size = v(176.5, 53),
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
