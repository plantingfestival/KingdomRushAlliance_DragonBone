-- chunkname: @./kr5/data/kui_templates/popup_accept_privacy_policy.lua

return {
	class = "GG5PopUpAcceptPrivacyPolicy",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_",
					class = "KImageView",
					pos = v(1.6, 143.5),
					scale = v(1.4807, 1.0025),
					anchor = v(361.55, -164.85)
				},
				{
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_",
					class = "KImageView",
					pos = v(-2.2, 155.3),
					scale = v(0.4072, 1.0025),
					anchor = v(361.55, -164.85)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(2, 23.05),
					size = v(1034.3149, 609.1751),
					anchor = v(517.1575, 304.5876),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_separator_",
					class = "KImageView",
					pos = v(-2165.1, 91.15),
					scale = v(6.2618, 1),
					anchor = v(-277.5, 1.05)
				},
				{
					image_name = "gui_popups_image_ui_popup_separator_",
					class = "KImageView",
					pos = v(-2165.1, -164.85),
					scale = v(6.2618, 1),
					anchor = v(-277.5, 1.05)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_01_",
					class = "KImageView",
					pos = v(518.3, 23.3),
					scale = v(1, 1.8928),
					anchor = v(9.45, 154.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_02_",
					class = "KImageView",
					pos = v(-521, 17.55),
					scale = v(1, 2.2158),
					anchor = v(9.35, 126.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-522.4, -92.15),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(-522.8, 94.4),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_03_",
					class = "KImageView",
					pos = v(2.5, -279.85),
					scale = v(1.5274, 1),
					anchor = v(319.95, 11.2)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_04_",
					class = "KImageView",
					pos = v(-4, 334.1),
					scale = v(1.6426, 1),
					anchor = v(295.45, 11.15)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_01_",
					pos = v(-485.65, -245.85),
					anchor = v(46.25, 44.75)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_03_",
					pos = v(-484.65, 297.25),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_04_",
					pos = v(484.55, 297.1),
					anchor = v(46.25, 44.8)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(521.85, -92.15),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_nail_",
					pos = v(521.45, 94.4),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_02_",
					pos = v(467.2, -245.85),
					anchor = v(29, 44.45)
				},
				{
					vertical_align = "middle",
					text_align = "center",
					text_key = "POPUP_label_tellage",
					font_size = 28,
					line_height_extra = "0",
					text = "Please tell us your age",
					class = "GG5Label",
					id = "label_tellage",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-256, -156.6),
					size = v(512, 64.65),
					colors = {
						text = {
							231,
							244,
							251
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					text_key = "POPUP_label_welcometokr",
					font_size = 36,
					line_height_extra = "0",
					text = "welcome to kingdom rush alliance!",
					class = "GG5Label",
					id = "label_welcometokr",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-345.05, -250.6),
					size = v(705.2, 58.2),
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
					text_key = "POPUP_label_pleaseconfirmterms",
					font_size = 28,
					line_height_extra = "0",
					text = "Please confirm you have read and accepted Privacy Policy and Terms Of Service",
					class = "GG5Label",
					id = "label_pleaseconfirmterms",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-362.1, 98.65),
					size = v(722.2, 86.4),
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
					pos = v(-0.3, -313.75),
					size = v(322.1885, 55.6266),
					anchor = v(161.1262, 24.6882),
					slice_rect = r(117.95, -1.9, 16.8, 62.65)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_warning_sign_",
					id = "warning_sign",
					pos = v(-3.35, -318.5),
					scale = v(0.7733, 0.7733),
					anchor = v(66.35, 48.15)
				},
				{
					default_image_name = "gui_popups_button_confirm_ok_bg_0001",
					focus_image_name = "gui_popups_button_confirm_ok_bg_0003",
					class = "GG5Button",
					id = "button_popup_confirm_ok",
					pos = v(-5.1, 329.65),
					scale = v(1, 1),
					image_offset = v(-124.1, -48.85),
					hit_rect = r(-124.1, -48.85, 251, 102),
					children = {
						{
							vertical_align = "middle-caps",
							text_align = "center",
							font_size = 34,
							line_height_extra = "0",
							fit_size = true,
							text = "confirm",
							text_key = "BUTTON_CONFIRM",
							class = "GG5ShaderLabel",
							id = "label_button_confirm",
							font_name = "fla_h",
							pos = v(-86.5, -23.7),
							scale = v(1, 1),
							size = v(176.5, 44.55),
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
					default_image_name = "gui_popups_button_confirm_privacypolicybg_0001",
					focus_image_name = "gui_popups_button_confirm_privacypolicybg_0003",
					class = "GG5Button",
					id = "button_privacypolicy",
					pos = v(-176.35, 221.9),
					scale = v(1, 1),
					image_offset = v(-168.55, -35.05),
					hit_rect = r(-168.55, -35.05, 343, 79),
					children = {
						{
							vertical_align = "middle-caps",
							text_align = "center",
							font_size = 19,
							line_height_extra = "0",
							fit_size = true,
							text = "privacy policy",
							text_key = "BUTTON_PRIVACYPOLICY",
							class = "GG5ShaderLabel",
							id = "label_button_privacypolicy",
							font_name = "fla_h",
							pos = v(-153.55, -14.6),
							scale = v(1, 1),
							size = v(305.65, 31),
							colors = {
								text = {
									231,
									244,
									251
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 1.25,
									outline_color = {
										0.1725,
										0.3804,
										0.4353,
										1
									}
								}
							}
						}
					}
				},
				{
					default_image_name = "gui_popups_button_confirm_privacypolicybg_0001",
					focus_image_name = "gui_popups_button_confirm_privacypolicybg_0003",
					class = "GG5Button",
					id = "button_termsofservice",
					pos = v(174.25, 221.9),
					scale = v(1, 1),
					image_offset = v(-168.55, -35.05),
					hit_rect = r(-168.55, -35.05, 343, 79),
					children = {
						{
							vertical_align = "middle-caps",
							text_align = "center",
							font_size = 19,
							line_height_extra = "0",
							fit_size = true,
							text = "TERMS OF SERVICE",
							text_key = "BUTTON_TERMSOFSERVICE",
							class = "GG5ShaderLabel",
							id = "label_button_termsofservice",
							font_name = "fla_h",
							pos = v(-153.55, -14.6),
							scale = v(1, 1),
							size = v(305.65, 31.05),
							colors = {
								text = {
									231,
									244,
									251
								}
							},
							shaders = {
								"p_outline_tint"
							},
							shader_args = {
								{
									thickness = 1.25,
									outline_color = {
										0.1725,
										0.3804,
										0.4353,
										1
									}
								}
							}
						}
					}
				},
				{
					class = "GG5PopupAcceptPPAgemonth",
					template_name = "popup_acceptpp_agemonth",
					id = "template_agemonth",
					pos = v(-109.15, -16.4),
					size = v(ctx.sw, ctx.sh)
				},
				{
					class = "GG5PopupAcceptPPAgeyear",
					template_name = "popup_acceptpp_ageyear",
					id = "template_ageyear",
					pos = v(94.95, -15.35),
					size = v(ctx.sw, ctx.sh)
				},
				{
					image_name = "gui_popups_image_ui_dropdown_",
					class = "KImageView",
					pos = v(-73.7, -18.55),
					scale = v(0.746, 0.746),
					anchor = v(4, 4)
				},
				{
					image_name = "gui_popups_image_ui_dropdown_",
					class = "KImageView",
					pos = v(142.75, -18.55),
					scale = v(0.746, 0.746),
					anchor = v(4, 4)
				},
				{
					id = "button_agemonth",
					focus_image_name = "gui_popups_button_bg_agemonthgraphic_0003",
					class = "GG5Button",
					default_image_name = "gui_popups_button_bg_agemonthgraphic_0001",
					pos = v(-147.15, -37.75),
					anchor = v(37.6, 24.15)
				},
				{
					id = "button_ageyear",
					focus_image_name = "gui_popups_button_bg_ageyeargraphic_0003",
					class = "GG5Button",
					default_image_name = "gui_popups_button_bg_ageyeargraphic_0001",
					pos = v(43.95, -35.9),
					anchor = v(45.6, 23.6)
				}
			}
		}
	}
}
