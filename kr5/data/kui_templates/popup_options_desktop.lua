-- chunkname: @./kr5/data/kui_templates/popup_options_desktop.lua

return {
	class = "GG5PopUpOptionsDesktop",
	children = {
		{
			id = "contents",
			class = "KView",
			children = {
				{
					id = "group_options_bg_desktop",
					class = "KView",
					pos = v(-10.6, -56.8),
					children = {
						{
							class = "GG59View",
							image_name = "room_bg_desktop_9slice_bg_color_desktop_",
							id = "bg_color",
							pos = v(7.75, 37.55),
							size = v(1078.4542, 930.9534),
							anchor = v(538.7169, 465.4767),
							slice_rect = r(21.3, 20.45, 10, 10.05)
						},
						{
							class = "KView",
							id = "group_bg_textures",
							pos = v(-3.75, 26.25),
							scale = v(0.9073, 0.8848),
							children = {
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_texture_desktop_",
									id = "bg_texture_1",
									pos = v(-467.15, 31.2),
									scale = v(1.0712, 1.1723),
									anchor = v(107.45, 454.15)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_texture_desktop_",
									id = "bg_texture_2",
									pos = v(-230.9, 31.2),
									scale = v(1.0712, 1.1723),
									anchor = v(107.45, 454.15)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_texture_desktop_",
									id = "bg_texture_3",
									pos = v(5.3, 31.2),
									scale = v(1.0712, 1.1723),
									anchor = v(107.45, 454.15)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_texture_desktop_",
									id = "bg_texture_4",
									pos = v(241.6, 31.2),
									scale = v(1.0712, 1.1723),
									anchor = v(107.45, 454.15)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_texture_desktop_",
									id = "bg_texture_5",
									pos = v(477.85, 31.2),
									scale = v(1.0712, 1.1723),
									anchor = v(107.45, 454.15)
								}
							}
						},
						{
							class = "GG59View",
							image_name = "room_bg_desktop_9slice_bg_frame_desktop_",
							id = "bg_frame",
							pos = v(-1.9, -12.6),
							size = v(1162.9535, 1004.6397),
							anchor = v(570.7157, 436.0753),
							slice_rect = r(100.4, 75.25, 22.3, 15.4)
						},
						{
							id = "frame_top_right_corner",
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_frame_topcorner_desktop_",
							hidden = true,
							pos = v(506.7, -418.25),
							anchor = v(9.9, 29.15)
						},
						{
							class = "GG5Button",
							focus_image_name = "room_bg_desktop_button_bg_close_desktop_0003",
							id = "button_close_popup",
							default_image_name = "room_bg_desktop_button_bg_close_desktop_0001",
							pos = v(530.5, -418.8),
							scale = v(1, 1),
							anchor = v(42.7, 49.45)
						},
						{
							id = "group_rivets_left",
							class = "KView",
							pos = v(-542.4, 278.8),
							children = {
								{
									image_name = "room_bg_desktop_image_bg_rivet_desktop_",
									class = "KImageView",
									pos = v(8.65, -456.45),
									scale = v(0.7772, 0.7772),
									anchor = v(11.1, 9.6)
								},
								{
									image_name = "room_bg_desktop_image_bg_rivet_desktop_",
									class = "KImageView",
									pos = v(8.65, -10.5),
									scale = v(0.7772, 0.7772),
									anchor = v(11.1, 9.6)
								}
							}
						},
						{
							id = "group_rivets_right",
							class = "KView",
							pos = v(536.55, 278.8),
							children = {
								{
									image_name = "room_bg_desktop_image_bg_rivet_desktop_",
									class = "KImageView",
									pos = v(8.65, -456.45),
									scale = v(0.7772, 0.7772),
									anchor = v(11.1, 9.6)
								},
								{
									image_name = "room_bg_desktop_image_bg_rivet_desktop_",
									class = "KImageView",
									pos = v(8.65, -9.25),
									scale = v(0.7772, 0.7772),
									anchor = v(11.1, 9.6)
								}
							}
						},
						{
							id = "group_rivets_bottom",
							class = "KView",
							pos = v(-449.95, 507.3),
							children = {
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(55.05, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(155.85, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(256.65, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(357.45, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(458.25, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(559.05, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(659.85, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(760.65, -6.45),
									anchor = v(5.75, 6.4)
								},
								{
									class = "KImageView",
									image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
									pos = v(861.45, -6.45),
									anchor = v(5.75, 6.4)
								}
							}
						},
						{
							id = "pager",
							class = "GG5Pager",
							pos = v(-416.65, 563.95),
							children = {
								{
									class = "GG59View",
									image_name = "room_bg_desktop_9slice_bg_pager_desktop_",
									id = "pager_bg",
									pos = v(-64.9, -28),
									size = v(129.9991, 67.6),
									anchor = v(0.1139, 0.9),
									slice_rect = r(52.95, -2.8, 11.8, 3)
								},
								{
									id = "button_page_01",
									class = "GG5ToggleButton",
									template_name = "toggle_bg_pager_desktop",
									pos = v(-1, -12.55)
								}
							}
						},
						{
							class = "GG59View",
							image_name = "room_bg_desktop_9slice_bg_title_desktop_",
							id = "title_bg",
							pos = v(-6.3, -474.55),
							size = v(694.8449, 73.5989),
							anchor = v(341.1229, 32.5995),
							slice_rect = r(99.95, 3.05, 16.8, 24.75)
						},
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 50,
							line_height_extra = "1",
							text = "OPTIONS",
							class = "GG5ShaderLabel",
							id = "title_text",
							font_name = "fla_h",
							pos = v(-236.6, -488.55),
							scale = v(1, 1),
							size = v(460, 51),
							colors = {
								text = {
									85,
									186,
									255
								}
							},
							shaders = {
								"p_bands",
								"p_outline_tint"
							},
							shader_args = {
								{
									margin = 1,
									p1 = 0.5,
									p2 = 0.99,
									c1 = {
										0.4745,
										1,
										1,
										1
									},
									c2 = {
										0.3333,
										0.7255,
										0.9961,
										1
									},
									c3 = {
										0.3333,
										0.7255,
										0.9961,
										1
									}
								},
								{
									thickness = 4.166666666666667,
									outline_color = {
										0.0745,
										0.2039,
										0.2784,
										1
									}
								}
							}
						}
					}
				},
				{
					title_key = "OPTIONS_PAGE_VIDEO",
					class = "KView",
					id = "page_05",
					pos = v(-10.45, -28),
					children = {
						{
							vertical_align = "top",
							text_align = "left",
							text_key = "SETTINGS_FULLSCREEN",
							font_size = 27,
							line_height_extra = "0",
							text = "FullscreeN",
							class = "GG5Label",
							id = "label_options_fullscreen",
							font_name = "fla_body",
							pos = v(96, 109.2),
							scale = v(0.9926, 1),
							size = v(400, 42.2),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						},
						{
							id = "toggle_options_large_mouse_pointer",
							class = "GG5ToggleButton",
							template_name = "toggle_checkbox_options",
							pos = v(50, -5)
						},
						{
							vertical_align = "top",
							text_align = "left",
							text_key = "SETTINGS_LARGE_MOUSE_POINTER",
							font_size = 27,
							line_height_extra = "0",
							text = "Large mouse pointer",
							class = "GG5Label",
							id = "label_options_large_mouse_pointer",
							font_name = "fla_body",
							pos = v(96, -26.1),
							size = v(400, 42.2),
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
							text_align = "left",
							text_key = "SETTINGS_VSYNC",
							font_size = 27,
							line_height_extra = "0",
							text = "Vsync",
							class = "GG5Label",
							id = "label_options_vsync",
							font_name = "fla_body",
							pos = v(96, 41.55),
							scale = v(0.9926, 1),
							size = v(400, 42.2),
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
							text_align = "left",
							text_key = "SETTINGS_FULLSCREEN_BORDERLESS",
							font_size = 27,
							line_height_extra = "0",
							text = "Borderless",
							class = "GG5Label",
							id = "label_options_borderless",
							font_name = "fla_body",
							pos = v(96, 176.85),
							scale = v(0.9926, 1),
							size = v(400, 42.2),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						},
						{
							id = "toggle_options_vsync",
							class = "GG5ToggleButton",
							template_name = "toggle_checkbox_options",
							pos = v(50, 62.65)
						},
						{
							id = "toggle_options_fullscreen",
							class = "GG5ToggleButton",
							template_name = "toggle_checkbox_options",
							pos = v(50, 130.3)
						},
						{
							id = "toggle_options_borderless",
							class = "GG5ToggleButton",
							template_name = "toggle_checkbox_options",
							pos = v(50, 197.95)
						},
						{
							vertical_align = "top",
							text_align = "left",
							text_key = "SETTINGS_RETINA_DISPLAY",
							font_size = 27,
							line_height_extra = "0",
							text = "Retina display (macOS)",
							class = "GG5Label",
							id = "label_options_highdpi",
							font_name = "fla_body",
							pos = v(96, 244.6),
							scale = v(0.9926, 1),
							size = v(400, 42.2),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						},
						{
							id = "toggle_options_highdpi",
							class = "GG5ToggleButton",
							template_name = "toggle_checkbox_options",
							pos = v(50, 265.7)
						},
						{
							vertical_align = "top",
							text_align = "left",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Screen resolution",
							text_key = "SETTINGS_SCREEN_RESOLUTION",
							font_name = "fla_body",
							pos = v(-480, -422),
							size = v(440, 42),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						},
						{
							class = "GG5SelectList",
							id = "selectlist_resolution",
							pos = v(-480, -380),
							scale = v(1, 2),
							anchor = v(0, 0),
							size = v(445, 200)
						},
						{
							vertical_align = "top",
							text_align = "left",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Display",
							text_key = "SETTINGS_DISPLAY",
							font_name = "fla_body",
							pos = v(-480, 35.95),
							size = v(440, 42.2),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						},
						{
							id = "selectlist_display",
							class = "GG5SelectList",
							pos = v(-480, 89.65),
							anchor = v(0, 0),
							size = v(445, 200)
						},
						{
							vertical_align = "top",
							text_align = "left",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Image quality",
							text_key = "SETTINGS_IMAGE_QUALITY",
							font_name = "fla_body",
							pos = v(24.6, -422),
							size = v(440, 42),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						},
						{
							class = "GG5SelectList",
							id = "selectlist_image_quality",
							pos = v(24.6, -380),
							scale = v(1, 0.57),
							anchor = v(0, 0),
							size = v(445, 200)
						},
						{
							vertical_align = "top",
							text_align = "left",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "FPS",
							text_key = "SETTINGS_FRAMES_PER_SECOND",
							font_name = "fla_body",
							pos = v(24.6, -247.05),
							size = v(440, 42),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						},
						{
							class = "GG5SelectList",
							id = "selectlist_fps",
							pos = v(25, -208.25),
							scale = v(1, 0.38),
							anchor = v(0, 0),
							size = v(445, 200)
						},
						{
							text_key = "BUTTON_CONFIRM",
							class = "GG5Button",
							transition_delay = 0.15,
							id = "video_settings_apply_button",
							transition = "up",
							template_name = "button_options_wide",
							pos = v(0, 381.3),
							scale = v(1, 1)
						}
					}
				},
				{
					title_key = "OPTIONS_PAGE_SHORTCUTS",
					class = "KView",
					id = "page_04",
					pos = v(-10.2, -29.4),
					children = {
						{
							class = "KView",
							id = "MovieClip298",
							pos = v(111.45, 1),
							WHEN = ctx.context == "ingame",
							children = {
								{
									vertical_align = "top",
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Cancel / Back / Pause",
									text_key = "JOYSTICK_HELP_INGAME_ESCAPE",
									font_name = "fla_body",
									pos = v(-95.65, -335),
									size = v(474.35, 42.2),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								},
								{
									class = "KView",
									pos = v(-210.8, -315),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_ESCAPE",
											font_size = 27,
											line_height_extra = "0",
											text = "ESCAPE",
											class = "GG5Label",
											id = "label_page_escape",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.95),
											size = v(146.9, 34.3),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-210.8, -245),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_RETURN",
											font_size = 27,
											line_height_extra = "0",
											text = "RETURN",
											class = "GG5Label",
											id = "label_page_down",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.95),
											size = v(146.9, 34.6),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-350.75, -35),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_SPACE",
											font_size = 27,
											line_height_extra = "0",
											text = "SPACE",
											class = "GG5Label",
											id = "label_space",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.95),
											size = v(146.9, 34.65),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-294.55, -105),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "1",
											id = "label_1",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-224.55, -105),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "2",
											id = "label_2",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-154.5, -105),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "3",
											id = "label_3",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-154.5, 105),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "W",
											id = "label_W",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										},
										{
											vertical_align = "top",
											text_align = "center",
											line_height_extra = "0",
											font_size = 27,
											text = "",
											class = "GG5Label",
											font_name = "fla_h",
											pos = v(-2, -87.4),
											size = v(104, 28.4),
											colors = {
												text = {
													224,
													249,
													241
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-154.5, 175),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "E",
											id = "label_E",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-154.5, 245),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "R",
											id = "label_R",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-154.5, 315),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = ".",
											id = "label_period",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-252.65, -175),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-126, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-60.6, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(4.8, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(70.2, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											class = "KImageView",
											image_name = "gui_popups_desktop_image_key_arrow_",
											pos = v(-98.4, -5.4),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = -1.5708,
											pos = v(-32.1, -5.35),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = 1.5708,
											pos = v(33.8, -4.45),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = -3.1416,
											pos = v(99.15, -5.4),
											anchor = v(9.35, 9.95)
										}
									}
								},
								{
									class = "KView",
									pos = v(-224.55, -35),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "4",
											id = "label_4",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-154.5, 35),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "6",
											id = "label_6",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									vertical_align = "top",
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Select",
									text_key = "JOYSTICK_HELP_INGAME_A",
									font_name = "fla_body",
									pos = v(-95.65, -265),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Move",
									text_key = "JOYSTICK_HELP_INGAME_AXIS_LEFT",
									font_name = "fla_body",
									pos = v(-95.65, -195),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Powers",
									text_key = "JOYSTICK_HELP_INGAME_POWERS",
									font_name = "fla_body",
									pos = v(-95.65, -128.35),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Move heroes",
									text_key = "JOYSTICK_HELP_INGAME_MOVE_HEROES",
									font_name = "fla_body",
									pos = v(-95.65, -55),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Move reinforcements",
									text_key = "JOYSTICK_HELP_INGAME_MOVE_REINFORCEMENTS",
									font_name = "fla_body",
									pos = v(-95.65, 15),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Send wave",
									text_key = "JOYSTICK_HELP_INGAME_X",
									font_name = "fla_body",
									pos = v(-95.65, 85),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Wave info",
									text_key = "JOYSTICK_HELP_INGAME_Y",
									font_name = "fla_body",
									pos = v(-95.65, 155),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Show info card",
									text_key = "JOYSTICK_HELP_INGAME_BACK",
									font_name = "fla_body",
									pos = v(-95.65, 225),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Toggle pointer",
									text_key = "JOYSTICK_HELP_INGAME_AXIS_LEFT_BUTTON",
									font_name = "fla_body",
									pos = v(-95.65, 295),
									size = v(474.35, 42.2),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								},
								{
									class = "KView",
									pos = v(-154.5, -35),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-27.95, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											vertical_align = "top",
											text_align = "center",
											class = "GG5Label",
											line_height_extra = "0",
											font_size = 27,
											text = "5",
											id = "label_5",
											font_name = "fla_numbers_2",
											pos = v(-19.25, -18.35),
											size = v(38.9, 28.4),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								}
							}
						},
						{
							class = "KView",
							id = "MovieClip297",
							pos = v(107, 1),
							WHEN = ctx.context == "map",
							children = {
								{
									vertical_align = "top",
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Cancel / Back / Pause",
									text_key = "JOYSTICK_HELP_MAP_B",
									font_name = "fla_body",
									pos = v(-95.65, -335),
									size = v(474.35, 42.2),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								},
								{
									class = "KView",
									pos = v(-210.8, -312.5),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_ESCAPE",
											font_size = 27,
											line_height_extra = "0",
											text = "ESCAPE",
											class = "GG5Label",
											id = "label_page_escape",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.95),
											size = v(146.9, 34.3),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-210.8, -242.5),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_RETURN",
											font_size = 27,
											line_height_extra = "0",
											text = "RETURN",
											class = "GG5Label",
											id = "label_page_down",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.95),
											size = v(146.9, 34.6),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-210.25, -102.5),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_PAGE_UP",
											font_size = 27,
											line_height_extra = "0",
											text = "PAGE UP",
											class = "GG5Label",
											id = "label_page_up",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.95),
											size = v(146.9, 34.35),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-252.65, -172.5),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-126, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-60.6, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(4.8, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(70.2, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											class = "KImageView",
											image_name = "gui_popups_desktop_image_key_arrow_",
											pos = v(-98.4, -5.4),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = -1.5708,
											pos = v(-32.1, -5.35),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = 1.5708,
											pos = v(33.8, -4.45),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = -3.1416,
											pos = v(99.15, -5.4),
											anchor = v(9.35, 9.95)
										}
									}
								},
								{
									vertical_align = "top",
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Select",
									text_key = "JOYSTICK_HELP_MAP_A",
									font_name = "fla_body",
									pos = v(-95.65, -265),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Move",
									text_key = "JOYSTICK_HELP_MAP_AXIS_LEFT",
									font_name = "fla_body",
									pos = v(-95.65, -195),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Prev. level/page",
									text_key = "JOYSTICK_HELP_MAP_LB",
									font_name = "fla_body",
									pos = v(-95.65, -128.35),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Next level/page",
									text_key = "JOYSTICK_HELP_MAP_RB",
									font_name = "fla_body",
									pos = v(-95.65, -55),
									size = v(474.35, 42.2),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								},
								{
									class = "KView",
									pos = v(-211.35, -32.5),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_PAGE_DOWN",
											font_size = 27,
											line_height_extra = "0",
											text = "PAGE DOWN",
											class = "GG5Label",
											id = "label_page_down",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.8),
											size = v(146.9, 34.1),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								}
							}
						},
						{
							class = "KView",
							id = "MovieClip299",
							pos = v(113.8, 1),
							WHEN = ctx.context == "slots",
							children = {
								{
									vertical_align = "top",
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Show/Hide options",
									text_key = "JOYSTICK_HELP_SLOTS_START",
									font_name = "fla_body",
									pos = v(-95.65, -335),
									size = v(474.35, 42.2),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								},
								{
									class = "KView",
									pos = v(-210.8, -315),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_ESCAPE",
											font_size = 27,
											line_height_extra = "0",
											text = "ESCAPE",
											class = "GG5Label",
											id = "label_page_escape",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.95),
											size = v(146.9, 34.3),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-210.8, -245),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_1_",
											class = "KImageView",
											pos = v(28.35, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(100.15, 3)
										},
										{
											vertical_align = "middle-caps",
											text_align = "center",
											text_key = "KEYBOARD_KEY_RETURN",
											font_size = 27,
											line_height_extra = "0",
											text = "RETURN",
											class = "GG5Label",
											id = "label_page_down",
											fit_size = true,
											font_name = "fla_h",
											pos = v(-72.75, -21.95),
											size = v(146.9, 34.6),
											colors = {
												text = {
													184,
													209,
													238
												}
											}
										}
									}
								},
								{
									class = "KView",
									pos = v(-252.65, -175),
									children = {
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-126, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(-60.6, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(4.8, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											image_name = "gui_popups_desktop_image_keyboardbutton_2_",
											class = "KImageView",
											pos = v(70.2, -26),
											scale = v(1.1829, 1.1829),
											anchor = v(5, 3)
										},
										{
											class = "KImageView",
											image_name = "gui_popups_desktop_image_key_arrow_",
											pos = v(-98.4, -5.4),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = -1.5708,
											pos = v(-32.1, -5.35),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = 1.5708,
											pos = v(33.8, -4.45),
											anchor = v(9.35, 9.95)
										},
										{
											image_name = "gui_popups_desktop_image_key_arrow_",
											class = "KImageView",
											r = -3.1416,
											pos = v(99.15, -5.4),
											anchor = v(9.35, 9.95)
										}
									}
								},
								{
									vertical_align = "top",
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Select",
									text_key = "JOYSTICK_HELP_SLOTS_A",
									font_name = "fla_body",
									pos = v(-95.65, -265),
									size = v(474.35, 42.2),
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
									text_align = "left",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 27,
									text = "Move",
									text_key = "JOYSTICK_HELP_SLOTS_AXIS_LEFT",
									font_name = "fla_body",
									pos = v(-95.65, -195),
									size = v(474.35, 42.2),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								}
							}
						}
					}
				},
				{
					title_key = "OPTIONS_PAGE_CONTROLS",
					class = "KView",
					id = "page_03",
					pos = v(-4.4, -42.9),
					children = {
						{
							class = "GG5Slider",
							template_name = "slider_options",
							id = "joy_pointer_speed",
							pos = v(6.85, -330.05),
							scale = v(0.8, 0.8)
						},
						{
							class = "GG5Slider",
							template_name = "slider_options",
							id = "joy_pointer_power",
							pos = v(6.9, -228.3),
							scale = v(0.8, 0.8)
						},
						{
							class = "GG5Slider",
							template_name = "slider_options",
							id = "joy_pointer_accel",
							pos = v(6.9, -126.55),
							scale = v(0.8, 0.8)
						},
						{
							class = "GG5Slider",
							template_name = "slider_options",
							id = "joy_pointer_accel_max",
							pos = v(6.9, -24.8),
							scale = v(0.8, 0.8)
						},
						{
							class = "GG5Slider",
							template_name = "slider_options",
							id = "joy_pointer_threshold",
							pos = v(6.9, 76.95),
							scale = v(0.8, 0.8)
						},
						{
							class = "GG5Slider",
							template_name = "slider_options",
							id = "joy_rate_limit_delay",
							pos = v(6.9, 178.7),
							scale = v(0.8, 0.8)
						},
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Pointer speed",
							text_key = "JOYSTICK_CONFIG_POINTER_SPEED",
							font_name = "fla_body",
							pos = v(-386.5, -394.95),
							size = v(768.85, 42.2),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						},
						{
							text_key = "BUTTON_RESET",
							class = "GG5Button",
							transition_delay = 0.15,
							id = "controller_settings_reset_button",
							transition = "up",
							template_name = "button_options_wide",
							pos = v(-0.45, 384.65),
							scale = v(1, 1)
						},
						{
							class = "GG5Slider",
							template_name = "slider_options",
							id = "joy_rate_limit_delay_repeat",
							pos = v(6.9, 280.5),
							scale = v(0.8, 0.8)
						},
						{
							vertical_align = "top",
							text_align = "center",
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Pointer sens.",
							text_key = "JOYSTICK_CONFIG_POINTER_SENS",
							font_name = "fla_body",
							pos = v(-386.5, -292.75),
							size = v(768.85, 42.2),
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
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Pointer accel.",
							text_key = "JOYSTICK_CONFIG_POINTER_ACCEL",
							font_name = "fla_body",
							pos = v(-386.5, -188.65),
							size = v(768.85, 42.2),
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
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Pointer max. accel.",
							text_key = "JOYSTICK_CONFIG_POINTER_MAX_ACCEL",
							font_name = "fla_body",
							pos = v(-386.5, -87.35),
							size = v(768.85, 42.2),
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
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Stick dead zone",
							text_key = "JOYSTICK_CONFIG_AXIS_DEAD_ZONE",
							font_name = "fla_body",
							pos = v(-386.5, 13.05),
							size = v(768.85, 42.2),
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
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "First repeat delay",
							text_key = "JOYSTICK_CONFIG_FIRST_REPEAT_DELAY",
							font_name = "fla_body",
							pos = v(-386.5, 115.3),
							size = v(768.85, 42.2),
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
							class = "GG5Label",
							line_height_extra = "0",
							font_size = 27,
							text = "Repeat delay",
							text_key = "JOYSTICK_CONFIG_REPEAT_DELAY",
							font_name = "fla_body",
							pos = v(-386.5, 215.65),
							size = v(768.85, 42.2),
							colors = {
								text = {
									231,
									244,
									251
								}
							}
						}
					}
				},
				{
					title_key = "OPTIONS_PAGE_HELP",
					class = "KView",
					id = "page_02",
					pos = v(-10.2, -32.4),
					children = {
						{
							class = "KImageView",
							image_name = "gui_popups_desktop_image_gamepad_generic_",
							pos = v(0, 27.05),
							anchor = v(286.5, 201.9)
						},
						{
							class = "KView",
							id = "MovieClip293",
							pos = v(11.6, -6.95),
							WHEN = ctx.context == "ingame",
							children = {
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(248.05, 6.15),
									size = v(44.2878, 2.5),
									anchor = v(22.269, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(248.3, 92),
									size = v(45.6231, 2.5),
									anchor = v(22.9404, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(209.95, -148.35),
									size = v(32.8742, 2.5),
									anchor = v(16.53, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(170.45, -125.5),
									size = v(67.1393, 2.4999),
									anchor = v(33.7593, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(196.95, -74.9),
									size = v(75.8713, 2.5),
									anchor = v(38.15, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(208.35, -12.85),
									size = v(56.7553, 2.4999),
									anchor = v(28.538, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(185.55, 50.75),
									size = v(117.7154, 2.4999),
									anchor = v(59.1902, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(174.05, -207.9),
									size = v(129.1749, 2.4999),
									anchor = v(64.9524, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(26.2, -164.35),
									size = v(213.2589, 2.5),
									anchor = v(107.2319, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(52.05, -296),
									size = v(73.6094, 2.4999),
									anchor = v(37.0126, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-44.85, -164.55),
									size = v(210.9842, 2.5),
									anchor = v(106.0881, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(-70.8, -295.45),
									size = v(75.0819, 2.4999),
									anchor = v(37.753, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									class = "GG59View",
									r = -0.7854,
									id = "line_lb",
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									pos = v(-203, -188.95),
									size = v(98.107, 2.6041),
									anchor = v(49.3307, 1.3021),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-183.6, 233.9),
									size = v(227.2331, 2.5),
									anchor = v(114.2584, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-162, 203.5),
									size = v(157.8683, 2.5),
									anchor = v(79.3801, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(-147.8, 85.75),
									size = v(101.4717, 2.4999),
									anchor = v(51.0225, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(-122.6, 86.35),
									size = v(112.3187, 2.4999),
									anchor = v(56.4766, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-83.6, 29.45),
									size = v(36.2027, 2.5),
									anchor = v(18.2036, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(-86.15, 100.8),
									size = v(92.488, 2.4999),
									anchor = v(46.5053, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-112.5, 45.85),
									size = v(10.5955, 2.5),
									anchor = v(5.3277, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(-232.2, -104.5),
									size = v(50.3257, 2.5),
									anchor = v(25.305, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(-181.6, -78.5),
									size = v(76.5271, 2.4999),
									anchor = v(38.4797, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(-260.45, 32.75),
									size = v(66.2691, 2.5),
									anchor = v(33.3218, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(-201.65, 5.95),
									size = v(76.5271, 2.4999),
									anchor = v(38.4797, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									vertical_align = "top",
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_START",
									font_size = 24,
									line_height_extra = "0",
									text = "Pause/Resume\n",
									class = "GG5Label",
									id = "label_start",
									font_name = "fla_body",
									pos = v(89.7, -345.6),
									size = v(409.5, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_RB",
									font_size = 24,
									line_height_extra = "0",
									text = "Seleccionar heroe 2\n",
									class = "GG5Label",
									id = "label_rb",
									font_name = "fla_body",
									pos = v(227.15, -274.55),
									size = v(269.45, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_Y",
									font_size = 24,
									line_height_extra = "0",
									text = "Wave info\n",
									class = "GG5Label",
									id = "label_y",
									font_name = "fla_body",
									pos = v(231.15, -168.2),
									size = v(223.45, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_X",
									font_size = 24,
									line_height_extra = "0",
									text = "Send wave\n",
									class = "GG5Label",
									id = "label_x",
									font_name = "fla_body",
									pos = v(241.15, -94),
									size = v(213.3, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_B",
									font_size = 24,
									line_height_extra = "0",
									text = "cancelar/volver\n",
									class = "GG5Label",
									id = "label_b",
									font_name = "fla_body",
									pos = v(275.95, -14.65),
									size = v(226.55, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_A",
									font_size = 24,
									line_height_extra = "0",
									text = "seleccionar\n",
									class = "GG5Label",
									id = "label_a",
									font_name = "fla_body",
									pos = v(279.75, 73.95),
									size = v(225.85, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_DPAD_RIGHT",
									font_size = 24,
									line_height_extra = "0",
									text = "controles\n",
									class = "GG5Label",
									id = "label_dr",
									font_name = "fla_body",
									pos = v(-112.95, 133.15),
									size = v(253.15, 63.1),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_INGAME_BACK",
									font_size = 24,
									line_height_extra = "0",
									text = "Show info card\n",
									class = "GG5Label",
									id = "label_back",
									font_name = "fla_body",
									pos = v(-507.7, -346.05),
									size = v(402.5, 70.5),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_INGAME_LB",
									font_size = 24,
									line_height_extra = "0",
									text = "Seleccionar heroe 1\n",
									class = "GG5Label",
									id = "label_lb",
									font_name = "fla_body",
									pos = v(-506.3, -249.8),
									size = v(258.55, 63.1),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_INGAME_AXIS_LEFT_BUTTON",
									font_size = 24,
									line_height_extra = "0",
									text = "Toggle pointer\n",
									class = "GG5Label",
									id = "label_lt",
									font_name = "fla_body",
									pos = v(-507.35, -124.55),
									size = v(241.9, 63.1),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_INGAME_AXIS_LEFT",
									font_size = 24,
									line_height_extra = "0",
									text = "Move\n",
									class = "GG5Label",
									id = "label_la",
									font_name = "fla_body",
									pos = v(-508.7, 11.25),
									size = v(209.55, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_DPAD_UP",
									font_size = 24,
									line_height_extra = "0",
									text = "controles\n",
									class = "GG5Label",
									id = "label_du",
									font_name = "fla_body",
									pos = v(-155.55, 264.5),
									size = v(283.3, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_DPAD_LEFT",
									font_size = 24,
									line_height_extra = "0",
									text = "controles\n",
									class = "GG5Label",
									id = "label_dl",
									font_name = "fla_body",
									pos = v(-177.55, 329.95),
									size = v(303.6, 63.1),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(122.5, -47.85),
									size = v(18.3871, 2.5),
									anchor = v(9.2455, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(145.35, -61.4),
									size = v(40.208, 2.4999),
									anchor = v(20.2176, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									vertical_align = "top",
									text_align = "left",
									text_key = "JOYSTICK_HELP_INGAME_DPAD_DOWN",
									font_size = 24,
									line_height_extra = "0",
									text = "controles\n",
									class = "GG5Label",
									id = "label_du",
									font_name = "fla_body",
									pos = v(-135.2, 198.9),
									size = v(262.95, 63.1),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(-112.6, 100.7),
									size = v(83.6404, 2.4999),
									anchor = v(42.0565, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-141.6, 172),
									size = v(86.4547, 2.5),
									anchor = v(43.4716, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-53.95, 55.5),
									size = v(27.596, 2.5),
									anchor = v(13.876, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-118.4, 141.8),
									size = v(18.1743, 2.5),
									anchor = v(9.1385, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								}
							}
						},
						{
							class = "KView",
							id = "MovieClip294",
							pos = v(11.6, -6.95),
							WHEN = ctx.context == "map",
							children = {
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(240.65, 5.1),
									size = v(28.5246, 2.5),
									anchor = v(14.3429, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(249.55, 86.1),
									size = v(55.2153, 2.2246),
									anchor = v(27.7636, 1.1123),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(208.85, -13.9),
									size = v(56.7553, 2.4999),
									anchor = v(28.538, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(183.7, 47.35),
									size = v(110.6185, 2.4999),
									anchor = v(55.6217, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(144.6, -178.55),
									size = v(46.1022, 2.4999),
									anchor = v(23.1813, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(26.35, -140.95),
									size = v(166.6953, 2.5),
									anchor = v(83.8186, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(52.05, -249.05),
									size = v(73.6094, 2.4999),
									anchor = v(37.0126, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-43.2, -141.5),
									size = v(165.4511, 2.5),
									anchor = v(83.1929, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(-68.95, -249.7),
									size = v(75.0819, 2.4999),
									anchor = v(37.753, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									class = "GG59View",
									r = -0.7854,
									id = "line_lb",
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									pos = v(-166.65, -178.2),
									size = v(48.0862, 2.6041),
									anchor = v(24.1789, 1.3021),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(-258.4, 20.2),
									size = v(69.0704, 2.5),
									anchor = v(34.7303, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(-190.1, -14.5),
									size = v(98.3606, 2.4999),
									anchor = v(49.4582, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									vertical_align = "top",
									text_align = "left",
									text_key = "JOYSTICK_HELP_MAP_START",
									font_size = 24,
									line_height_extra = "0",
									text = "Show/Hide options\n",
									class = "GG5Label",
									id = "label_start",
									font_name = "fla_body",
									pos = v(86.1, -297.6),
									size = v(404.05, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_MAP_RB",
									font_size = 24,
									line_height_extra = "0",
									text = "Next level/page\n",
									class = "GG5Label",
									id = "label_rb",
									font_name = "fla_body",
									pos = v(166.1, -214.4),
									size = v(330.8, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_MAP_B",
									font_size = 24,
									line_height_extra = "0",
									text = "CANCELAR / VOLVER",
									class = "GG5Label",
									id = "label_b",
									font_name = "fla_body",
									pos = v(260.3, -14.4),
									size = v(236.3, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_MAP_A",
									font_size = 24,
									line_height_extra = "0",
									text = "Select\n",
									class = "GG5Label",
									id = "label_a",
									font_name = "fla_body",
									pos = v(286.65, 69.05),
									size = v(209.3, 63.1),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_MAP_BACK",
									font_size = 24,
									line_height_extra = "0",
									text = "Show/Hide options\n",
									class = "GG5Label",
									id = "label_back",
									font_name = "fla_body",
									pos = v(-498.8, -299.55),
									size = v(396.35, 63.1),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_MAP_LB",
									font_size = 24,
									line_height_extra = "0",
									text = "Prev. level/page\n",
									class = "GG5Label",
									id = "label_lb",
									font_name = "fla_body",
									pos = v(-503.6, -213.3),
									size = v(312.65, 63.1),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_MAP_AXIS_LEFT",
									font_size = 24,
									line_height_extra = "0",
									text = "Move\n",
									class = "GG5Label",
									id = "label_la",
									font_name = "fla_body",
									pos = v(-506.8, -1.55),
									size = v(206.65, 63.1),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								}
							}
						},
						{
							class = "KView",
							id = "MovieClip295",
							pos = v(11.6, -6.95),
							WHEN = ctx.context == "slots",
							children = {
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(271.95, 19.2),
									size = v(44.2878, 2.5),
									anchor = v(22.269, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(263.05, 93.7),
									size = v(58.4001, 2.5),
									anchor = v(29.365, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(219.8, -2.75),
									size = v(88.54, 2.4999),
									anchor = v(44.5201, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(191.9, 50.85),
									size = v(124.9009, 2.4999),
									anchor = v(62.8033, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(25.6, -122),
									size = v(127.7252, 2.5),
									anchor = v(64.2234, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(50.6, -210.15),
									size = v(70.9056, 2.4999),
									anchor = v(35.6531, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 1.5708,
									pos = v(-44.7, -121.75),
									size = v(126.3626, 2.5),
									anchor = v(63.5383, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = -0.7854,
									pos = v(-69.35, -208.85),
									size = v(71.4763, 2.4999),
									anchor = v(35.9401, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									pos = v(-260.05, 25.9),
									size = v(62.0818, 2.5),
									anchor = v(31.2163, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									image_name = "gui_popups_desktop_9slice_image_controllerline_",
									class = "GG59View",
									r = 0.7854,
									pos = v(-192.15, -11.75),
									size = v(108.0887, 2.4999),
									anchor = v(54.3497, 1.25),
									slice_rect = r(4.6, 1.2, 8.6, 0.35)
								},
								{
									vertical_align = "top",
									text_align = "left",
									text_key = "JOYSTICK_HELP_SLOTS_START",
									font_size = 24,
									line_height_extra = "0",
									text = "Show/Hide options\n",
									class = "GG5Label",
									id = "label_start",
									font_name = "fla_body",
									pos = v(85.35, -258.7),
									size = v(403, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_SLOTS_B",
									font_size = 24,
									line_height_extra = "0",
									text = "Cancel/Back\n",
									class = "GG5Label",
									id = "label_b",
									font_name = "fla_body",
									pos = v(298.25, -3.3),
									size = v(196.85, 63.1),
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
									text_align = "left",
									text_key = "JOYSTICK_HELP_SLOTS_A",
									font_size = 24,
									line_height_extra = "0",
									text = "Select\n",
									class = "GG5Label",
									id = "label_a",
									font_name = "fla_body",
									pos = v(298.65, 73),
									size = v(194.85, 63.1),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_SLOTS_BACK",
									font_size = 24,
									line_height_extra = "0",
									text = "Show/Hide options\n",
									class = "GG5Label",
									id = "label_back",
									font_name = "fla_body",
									pos = v(-499.15, -257.95),
									size = v(392.7, 63.1),
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
									text_align = "right",
									text_key = "JOYSTICK_HELP_SLOTS_AXIS_LEFT",
									font_size = 24,
									line_height_extra = "0",
									text = "Move\n",
									class = "GG5Label",
									id = "label_la",
									font_name = "fla_body",
									pos = v(-506.1, 5.75),
									size = v(209.8, 63.1),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								}
							}
						}
					}
				},
				{
					title_key = "OPTIONS",
					class = "KView",
					id = "page_01",
					pos = v(-10.2, -29.4),
					children = {
						{
							class = "KView",
							id = "group_options_ingame",
							pos = v(-1.55, 85.75),
							WHEN = ctx.context == "ingame",
							children = {
								{
									text_key = "BUTTON_CONTINUE",
									class = "GG5Button",
									transition_delay = 0.15,
									id = "options_continue_button",
									transition = "up",
									template_name = "button_options_wide",
									pos = v(350.95, 283.7),
									scale = v(1, 1)
								},
								{
									text_key = "BUTTON_RESTART",
									class = "GG5Button",
									transition_delay = 0.15,
									id = "options_restart_button",
									transition = "up",
									template_name = "button_options_wide",
									pos = v(7.45, 283.7),
									scale = v(1, 1)
								},
								{
									text_key = "BUTTON_QUIT",
									class = "GG5Button",
									transition_delay = 0.15,
									id = "options_quit_button",
									transition = "up",
									template_name = "button_options_wide",
									pos = v(-336.05, 283.7),
									scale = v(1, 1)
								},
								{
									style = "sfx",
									class = "GG5Slider",
									template_name = "slider_options",
									id = "volume_fx",
									pos = v(17.35, -239.05)
								},
								{
									style = "music",
									class = "GG5Slider",
									template_name = "slider_options",
									id = "volume_music",
									pos = v(17.9, -23.55)
								},
								{
									vertical_align = "top",
									text_align = "center",
									text_key = "SFX",
									font_size = 27,
									line_height_extra = "0",
									text = "Effects volume",
									class = "GG5Label",
									id = "label_effectsvolume",
									font_name = "fla_body",
									pos = v(-374.4, -326.15),
									size = v(763.1, 42.2),
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
									text_key = "MUSIC",
									font_size = 27,
									line_height_extra = "0",
									text = "Music volume",
									class = "GG5Label",
									id = "label_musicvolume",
									font_name = "fla_body",
									pos = v(-372.1, -105.35),
									size = v(758.5, 42.2),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								}
							}
						},
						{
							class = "KView",
							id = "group_options_map",
							pos = v(-0.9, 27.75),
							WHEN = ctx.context == "map",
							children = {
								{
									vertical_align = "top",
									text_align = "center",
									font_size = 22,
									line_height_extra = "1",
									fit_size = true,
									text = "Difficulty level\n",
									text_key = "Difficulty Level",
									class = "GG5ShaderLabel",
									id = "label_difficulty",
									font_name = "fla_body",
									pos = v(-123.25, 19.3),
									scale = v(1, 1),
									size = v(271.75, 59.2),
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
									focus_image_name = "gui_popups_desktop_button_difficulty_0003",
									class = "GG5Button",
									id = "options_difficulty_button",
									default_image_name = "gui_popups_desktop_button_difficulty_0001",
									pos = v(12.9, -34.4),
									image_offset = v(-149.2, -50.9),
									hit_rect = r(-149.2, -50.9, 300, 103),
									children = {
										{
											vertical_align = "middle-caps",
											text_align = "center",
											font_size = 38,
											fit_size = true,
											line_height_extra = "2",
											text = "Normal",
											class = "GG5ShaderLabel",
											id = "label_button_difficulty",
											font_name = "fla_h",
											pos = v(-128.25, -25.6),
											scale = v(0.9999, 0.9999),
											size = v(254.05, 51.3),
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
									id = "button_twitter",
									focus_image_name = "gui_popups_desktop_button_twitter_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_twitter_0001",
									pos = v(-288.95, 323.4),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_facebook",
									focus_image_name = "gui_popups_desktop_button_facebook_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_facebook_0001",
									pos = v(-143.45, 323.4),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_instagram",
									focus_image_name = "gui_popups_desktop_button_instagram_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_instagram_0001",
									pos = v(3.65, 323.4),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_discord",
									focus_image_name = "gui_popups_desktop_button_discord_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_discord_0001",
									pos = v(147.35, 323.4),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_tiktok",
									focus_image_name = "gui_popups_desktop_button_tiktok_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_tiktok_0001",
									pos = v(287.95, 323.4),
									anchor = v(50.75, 55.95)
								},
								{
									id = "options_main_menu_button",
									focus_image_name = "gui_popups_desktop_button_main_menu_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_main_menu_0001",
									pos = v(-288.9, 146.35),
									anchor = v(56.15, 55.95)
								},
								{
									vertical_align = "top",
									text_align = "center",
									font_size = 22,
									line_height_extra = "1",
									fit_size = true,
									text = "Main Menu\n",
									text_key = "POPUP_LABEL_MAIN_MENU",
									class = "GG5ShaderLabel",
									id = "label_mainmenu",
									font_name = "fla_body",
									pos = v(-380.55, 201.25),
									scale = v(1, 1),
									size = v(181.2, 59.2),
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
									id = "button_privacy_policy",
									focus_image_name = "gui_popups_desktop_button_privacy_policy_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_privacy_policy_0001",
									pos = v(98.1, 144.6),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_more_games",
									focus_image_name = "gui_popups_desktop_button_more_games_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_more_games_0001",
									pos = v(291.35, 145.1),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_credits",
									focus_image_name = "gui_popups_desktop_button_credits_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_credits_0001",
									pos = v(-95.4, 144.25),
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
									pos = v(-184.25, 199.45),
									scale = v(1, 1),
									size = v(172.6, 59.2),
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
									text = "Privacy Policy",
									text_key = "PRIVACY_POLICY_BUTTON_LINK",
									class = "GG5ShaderLabel",
									id = "label_privacy_policy",
									font_name = "fla_body",
									pos = v(3.45, 199.45),
									scale = v(1, 1),
									size = v(182, 59.2),
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
									text = "More Games",
									text_key = "MORE_GAMES",
									class = "GG5ShaderLabel",
									id = "label_more_games",
									font_name = "fla_body",
									pos = v(200.55, 199.45),
									scale = v(1, 1),
									size = v(182, 59.2),
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
									text_key = "POPUP_label_version",
									font_size = 20,
									line_height_extra = "1",
									text = "V 1.14.5 HD.",
									class = "GG5Label",
									id = "label_version",
									font_name = "fla_body",
									pos = v(-332.95, 385),
									scale = v(1, 1),
									size = v(670.95, 32.05),
									colors = {
										text = {
											149,
											165,
											173
										}
									}
								},
								{
									style = "sfx",
									class = "GG5Slider",
									template_name = "slider_options",
									id = "volume_fx",
									pos = v(12.35, -329.85)
								},
								{
									style = "music",
									class = "GG5Slider",
									template_name = "slider_options",
									id = "volume_music",
									pos = v(12.9, -170.05)
								},
								{
									vertical_align = "top",
									text_align = "center",
									text_key = "SFX",
									font_size = 27,
									line_height_extra = "0",
									text = "Effects volume",
									class = "GG5Label",
									id = "label_effectsvolume",
									font_name = "fla_body",
									pos = v(-374.15, -416.95),
									size = v(753.9, 42.2),
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
									text_key = "MUSIC",
									font_size = 27,
									line_height_extra = "0",
									text = "Music volume",
									class = "GG5Label",
									id = "label_musicvolume",
									font_name = "fla_body",
									pos = v(-376.45, -251.85),
									size = v(755.05, 42.2),
									colors = {
										text = {
											231,
											244,
											251
										}
									}
								}
							}
						},
						{
							class = "KView",
							id = "group_options_slots",
							pos = v(-0.9, 8),
							WHEN = ctx.context == "slots",
							children = {
								{
									id = "button_twitter",
									focus_image_name = "gui_popups_desktop_button_twitter_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_twitter_0001",
									pos = v(-271.3, 297.25),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_facebook",
									focus_image_name = "gui_popups_desktop_button_facebook_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_facebook_0001",
									pos = v(-132, 297.25),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_instagram",
									focus_image_name = "gui_popups_desktop_button_instagram_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_instagram_0001",
									pos = v(8.9, 297.25),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_discord",
									focus_image_name = "gui_popups_desktop_button_discord_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_discord_0001",
									pos = v(146.4, 297.25),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_tiktok",
									focus_image_name = "gui_popups_desktop_button_tiktok_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_tiktok_0001",
									pos = v(280.8, 297.25),
									anchor = v(50.75, 55.95)
								},
								{
									id = "button_privacy_policy",
									focus_image_name = "gui_popups_desktop_button_privacy_policy_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_privacy_policy_0001",
									pos = v(96.7, 108.55),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_more_games",
									focus_image_name = "gui_popups_desktop_button_more_games_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_more_games_0001",
									pos = v(279.3, 109.05),
									anchor = v(56.15, 55.95)
								},
								{
									id = "button_credits",
									focus_image_name = "gui_popups_desktop_button_credits_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_credits_0001",
									pos = v(-86.3, 108.2),
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
									pos = v(-171.9, 163.4),
									scale = v(1, 1),
									size = v(172.6, 59.2),
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
									text = "Privacy Policy",
									text_key = "PRIVACY_POLICY_BUTTON_LINK",
									class = "GG5ShaderLabel",
									id = "label_privacy_policy",
									font_name = "fla_body",
									pos = v(6, 163.4),
									scale = v(1, 1),
									size = v(182, 59.2),
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
									text = "More Games",
									text_key = "MORE_GAMES",
									class = "GG5ShaderLabel",
									id = "label_more_games",
									font_name = "fla_body",
									pos = v(188.5, 163.4),
									scale = v(1, 1),
									size = v(182, 59.2),
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
									id = "button_language",
									focus_image_name = "gui_popups_desktop_button_language_0003",
									class = "GG5Button",
									default_image_name = "gui_popups_desktop_button_language_0001",
									pos = v(-269.3, 108.2),
									anchor = v(56.15, 55.95)
								},
								{
									vertical_align = "top",
									text_align = "center",
									font_size = 22,
									line_height_extra = "1",
									fit_size = true,
									text = "Language",
									text_key = "SETTINGS_LANGUAGE",
									class = "GG5ShaderLabel",
									id = "label_credits",
									font_name = "fla_body",
									pos = v(-355.9, 163.4),
									scale = v(1, 1),
									size = v(172.6, 59.2),
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
									style = "sfx",
									class = "GG5Slider",
									template_name = "slider_options",
									id = "volume_fx",
									pos = v(14, -267.05)
								},
								{
									style = "music",
									class = "GG5Slider",
									template_name = "slider_options",
									id = "volume_music",
									pos = v(14.55, -95.05)
								},
								{
									vertical_align = "top",
									text_align = "center",
									text_key = "SFX",
									font_size = 27,
									line_height_extra = "0",
									text = "Effects volume",
									class = "GG5Label",
									id = "label_effectsvolume",
									font_name = "fla_body",
									pos = v(-373.65, -354.15),
									size = v(756.2, 42.2),
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
									text_key = "MUSIC",
									font_size = 27,
									line_height_extra = "0",
									text = "Music volume",
									class = "GG5Label",
									id = "label_musicvolume",
									font_name = "fla_body",
									pos = v(-372.5, -176.85),
									size = v(755.05, 42.2),
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
									text_key = "POPUP_label_version",
									font_size = 20,
									line_height_extra = "1",
									text = "V 1.14.5 HD.",
									class = "GG5Label",
									id = "label_version",
									font_name = "fla_body",
									pos = v(-313.95, 402),
									scale = v(1, 1),
									size = v(646.95, 32.05),
									colors = {
										text = {
											149,
											165,
											173
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
}
