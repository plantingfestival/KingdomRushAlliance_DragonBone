-- chunkname: @./kr5/data/kui_templates/popup_locale_list.lua

return {
	class = "GG5PopUpLocaleList",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_2_",
					class = "KImageView",
					pos = v(3.65, -61.55),
					scale = v(0.8196, 1),
					anchor = v(586.3, -275.6)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(-0.7, 21.1),
					size = v(922.0632, 490.9784),
					anchor = v(461.0316, 245.4892),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_02_big_",
					class = "KImageView",
					pos = v(-463.6, 18),
					scale = v(1, 0.8481),
					anchor = v(12.25, 258.65)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_03_big_",
					class = "KImageView",
					pos = v(3.75, -223.5),
					scale = v(0.8101, 1),
					anchor = v(522.9, 15.3)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_04_big_",
					class = "KImageView",
					pos = v(3.2, 268.6),
					scale = v(0.7753, 1),
					anchor = v(504.4, 12.2)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_01_big_",
					class = "KImageView",
					pos = v(459.75, 19.8),
					scale = v(1, 0.8481),
					anchor = v(12.35, 249.1)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_03_big_",
					pos = v(-423.1, 228.3),
					anchor = v(51.2, 49.55)
				},
				{
					image_name = "gui_popups_image_ui_popup_corner_01_big_",
					class = "KImageView",
					pos = v(-424.05, -185.65),
					scale = v(1, 1),
					anchor = v(51.2, 49.55)
				},
				{
					image_name = "gui_popups_image_ui_popup_corner_04_big_",
					class = "KImageView",
					pos = v(420.7, 228.5),
					scale = v(1, 1),
					anchor = v(51.2, 49.55)
				},
				{
					image_name = "gui_popups_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(-464.9, -89.15),
					scale = v(1, 1),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(-464.9, 139.7),
					scale = v(1, 1),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(460.65, -89.15),
					scale = v(1, 1),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(460.65, 139.7),
					scale = v(1, 1),
					anchor = v(8.1, 8.85)
				},
				{
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_1",
					pos = v(-200, -149.15),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_2",
					pos = v(200, -149.15),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_3",
					pos = v(-200, -64.15),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_4",
					pos = v(200, -64.15),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_5",
					pos = v(-200, 20.85),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_6",
					pos = v(200, 20.85),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_7",
					pos = v(-200, 105.85),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_8",
					pos = v(200, 105.85),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_9",
					pos = v(-200, 190.85),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					focus_image_name = "gui_popups_toggle_language_item_bg_0003",
					false_image_name = "gui_popups_toggle_language_item_bg_0002",
					class = "GG5ToggleButton",
					true_image_name = "gui_popups_toggle_language_item_bg_0001",
					id = "toggle_language_item_10",
					pos = v(200, 190.85),
					image_offset = v(-170.05, -44.1),
					hit_rect = r(-170.05, -44.1, 343, 91),
					children = {
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5ShaderLabel",
							font_size = 28,
							line_height_extra = "0",
							text = "LANGUAGE",
							id = "label_locale",
							fit_size = true,
							font_name = "fla_h",
							pos = v(-144.25, -19),
							size = v(288.05, 37.25),
							colors = {
								text = {
									230,
									243,
									249
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
					class = "GG5Button",
					focus_image_name = "gui_popups_button_close_ingame_0003",
					id = "button_close_popup",
					default_image_name = "gui_popups_button_close_ingame_0001",
					pos = v(443.85, -208.4),
					scale = v(1, 1),
					anchor = v(42.55, 42.9)
				}
			}
		}
	}
}
