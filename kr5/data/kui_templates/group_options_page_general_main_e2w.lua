-- chunkname: @./kr5/data/kui_templates/group_options_page_general_main_e2w.lua

return {
	class = "KView",
	children = {
		{
			class = "KView",
			pos = v(496.9, 216.55),
			children = {
				{
					image_name = "gui_popups_image_window_ui_popup_bg_shadow_2_",
					class = "KImageView",
					pos = v(1.3, -130.5),
					scale = v(0.8334, 1),
					anchor = v(586.3, -275.6)
				},
				{
					image_name = "gui_popups_9slice_window_bg_",
					class = "GG59View",
					pos = v(-1.35, -27.8),
					size = v(957.0131, 509.9901),
					anchor = v(478.5066, 254.995),
					slice_rect = r(29.55, 27.7, 59.1, 55.4)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_02_big_",
					class = "KImageView",
					pos = v(-482.25, -33.9),
					scale = v(1, 0.756),
					anchor = v(12.25, 258.65)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_03_big_",
					class = "KImageView",
					pos = v(16.5, -280.1),
					scale = v(0.8148, 1),
					anchor = v(522.9, 15.3)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_04_big_",
					class = "KImageView",
					pos = v(0.9, 227.15),
					scale = v(0.8194, 1),
					anchor = v(504.4, 12.2)
				},
				{
					image_name = "gui_popups_image_ui_popup_side_01_big_",
					class = "KImageView",
					pos = v(477.85, -44.9),
					scale = v(1, 0.8338),
					anchor = v(12.35, 249.1)
				},
				{
					image_name = "gui_popups_image_ui_popup_corner_01_big_",
					class = "KImageView",
					pos = v(-442.3, -241.85),
					scale = v(1, 1),
					anchor = v(51.2, 49.55)
				},
				{
					image_name = "gui_popups_image_ui_popup_corner_04_big_",
					class = "KImageView",
					pos = v(438.8, 187.05),
					scale = v(1, 1),
					anchor = v(51.2, 49.55)
				},
				{
					image_name = "gui_popups_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(-483.75, -142.95),
					scale = v(1, 1),
					anchor = v(8.1, 8.85)
				},
				{
					class = "KImageView",
					image_name = "gui_popups_image_ui_popup_corner_03_big_",
					pos = v(-441.7, 187.05),
					anchor = v(51.2, 49.55)
				},
				{
					image_name = "gui_popups_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(-483.75, 87.1),
					scale = v(1, 1),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(477.6, -142.95),
					scale = v(1, 1),
					anchor = v(8.1, 8.85)
				},
				{
					image_name = "gui_popups_image_ui_popup_nail_big_",
					class = "KImageView",
					pos = v(477.6, 87.1),
					scale = v(1, 1),
					anchor = v(8.1, 8.85)
				},
				{
					class = "GG5Button",
					focus_image_name = "gui_popups_button_close_ingame_0003",
					id = "button_close_popup",
					default_image_name = "gui_popups_button_close_ingame_0001",
					pos = v(461.85, -264.3),
					scale = v(1, 1),
					anchor = v(42.55, 42.9)
				},
				{
					class = "GG59View",
					image_name = "gui_popups_9slice_image_title_bg_",
					id = "tittle_bg",
					pos = v(-2.9, -317.85),
					size = v(372.7825, 62.2962),
					anchor = v(186.4282, 27.6483),
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
					pos = v(-218.5, -336.8),
					scale = v(1, 1),
					size = v(433.1, 52.75),
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
				}
			}
		},
		{
			id = "toggle_music",
			false_image_name = "gui_popups_toggle_music_0002",
			class = "GG5ToggleButton",
			true_image_name = "gui_popups_toggle_music_0001",
			focus_image_name = "gui_popups_toggle_music_0003",
			pos = v(339.3, 48.15),
			anchor = v(56.15, 55.95)
		},
		{
			id = "toggle_sfx",
			false_image_name = "gui_popups_toggle_sfx_0002",
			class = "GG5ToggleButton",
			true_image_name = "gui_popups_toggle_sfx_0001",
			focus_image_name = "gui_popups_toggle_sfx_0003",
			pos = v(651.6, 48.15),
			anchor = v(56.15, 55.95)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 22,
			line_height_extra = "1",
			fit_size = true,
			text = "Music\n",
			text_key = "POPUP_SETTINGS_MUSIC",
			class = "GG5ShaderLabel",
			id = "label_music",
			font_name = "fla_body",
			pos = v(252.7, 103.35),
			scale = v(1, 1),
			size = v(174, 59.2),
			colors = {
				text = {
					231,
					244,
					251
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 22,
			line_height_extra = "1",
			fit_size = true,
			text = "SFX\n",
			text_key = "POPUP_SETTINGS_SFX",
			class = "GG5ShaderLabel",
			id = "label_sfx",
			font_name = "fla_body",
			pos = v(561.55, 103.35),
			scale = v(1, 1),
			size = v(174, 59.2),
			colors = {
				text = {
					231,
					244,
					251
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		},
		{
			id = "toggle_cloud_save",
			false_image_name = "gui_popups_toggle_cloud_save_0002",
			class = "GG5ToggleButton",
			true_image_name = "gui_popups_toggle_cloud_save_0001",
			focus_image_name = "gui_popups_toggle_cloud_save_0003",
			pos = v(651.35, 234.5),
			anchor = v(56.15, 55.95)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 22,
			line_height_extra = "1",
			fit_size = true,
			text = "Cloud Save\n",
			text_key = "CLOUD_SAVE",
			class = "GG5ShaderLabel",
			id = "label_cloud_save",
			font_name = "fla_body",
			pos = v(571.35, 289.7),
			scale = v(1, 1),
			size = v(160.25, 59.2),
			colors = {
				text = {
					231,
					244,
					251
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "POPUP_label_version",
			font_size = 20,
			line_height_extra = "1",
			text = "V 1.14.5 HD.",
			class = "GG5Label",
			id = "label_version",
			font_name = "fla_body",
			pos = v(46.5, 388.8),
			scale = v(1, 1),
			size = v(280.5, 32.05),
			colors = {
				text = {
					149,
					165,
					173
				}
			}
		},
		{
			id = "button_credits",
			focus_image_name = "gui_popups_button_credits_0003",
			class = "GG5Button",
			default_image_name = "gui_popups_button_credits_0001",
			pos = v(339.6, 234.5),
			anchor = v(56.15, 55.95)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 22,
			line_height_extra = "1",
			fit_size = true,
			text = "Credits\n",
			text_key = "Credits",
			class = "GG5ShaderLabel",
			id = "label_credits",
			font_name = "fla_body",
			pos = v(264.6, 289.7),
			scale = v(1, 1),
			size = v(150, 59.2),
			colors = {
				text = {
					231,
					244,
					251
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		},
		{
			image_name = "gui_popups_image_divider_",
			class = "KImageView",
			pos = v(495.95, 154.7),
			scale = v(0.936, 1),
			anchor = v(470, 2.85)
		},
		{
			id = "button_delete_account",
			focus_image_name = "gui_popups_button_trashcan_0003",
			class = "GG5Button",
			default_image_name = "gui_popups_button_trashcan_0001",
			pos = v(495.6, 234.5),
			anchor = v(56.15, 55.95)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 22,
			line_height_extra = "1",
			fit_size = true,
			text = "Delete Account",
			text_key = "POPUP_DELETE_ACCOUNT",
			class = "GG5ShaderLabel",
			id = "label_delete_account",
			font_name = "fla_body",
			pos = v(420.6, 289.7),
			scale = v(1, 1),
			size = v(150, 59.2),
			colors = {
				text = {
					231,
					244,
					251
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		},
		{
			text_key = "POPUP_ICP_MESSAGE",
			text_align = "center",
			line_height_extra = "1",
			font_size = 20,
			text = "ICP备案号：陕ICP备99999999号-99A",
			class = "GG5Label",
			id = "label_icp_message",
			font_name = "fla_body",
			pos = v(246, 386.8),
			scale = v(1, 1),
			size = v(500, 42.2),
			colors = {
				text = {
					231,
					244,
					251
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 22,
			line_height_extra = "1",
			fit_size = true,
			text = "Google Play\n",
			text_key = "GOOGLE_PLAY",
			class = "GG5ShaderLabel",
			id = "label_google_play",
			font_name = "fla_body",
			pos = v(570.5, 289.75),
			scale = v(1, 1),
			size = v(162.4, 59.2),
			colors = {
				text = {
					231,
					244,
					251
				}
			},
			shaders = {
				"p_glow"
			},
			shader_args = {
				{
					thickness = 2,
					glow_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		},
		{
			id = "toggle_google_play",
			false_image_name = "gui_popups_toggle_google_play_0002",
			class = "GG5ToggleButton",
			true_image_name = "gui_popups_toggle_google_play_0001",
			focus_image_name = "gui_popups_toggle_google_play_0003",
			pos = v(652.05, 234.55),
			anchor = v(56.15, 55.95)
		}
	}
}
