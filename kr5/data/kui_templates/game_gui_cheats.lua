local function v(x, y)
	return {
		x = x,
		y = y
	}
end

return {
	main_ui = {
		class = "KView",
		id = "cheat_view",
		can_drag = true,
		pos = {
			x = 32,
			y = 64
		},
		size = {
			x = 900,
			y = 340
		},
		colors = {
			background = {
				200,
				200,
				200,
				200
			}
		},
		scale = v(1.3, 1.3),
		children = {
			{
				class = "KView",
				id = "close",
				pos = {
					x = -8,
					y = -8
				},
				size = {
					x = 16,
					y = 16
				},
				colors = {
					background = {
						100,
						100,
						100,
						0
					}
				},
				children = {
					{
						class = "KImageView",
						image_name = "options_close_0001",
						pos = v(-4.8, -4.8),
						scale = v(0.4, 0.4)
					}
				}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_main_bar",
				pos = {
					x = 16,
					y = 16
				},
				children = {
					{
						class = "KView",
						id = "cheat_gold_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "nextwave_coin_0007",
								pos = v(6.4, 4.8)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_lives_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "heart_0001",
								pos = v(3.2, 3.2)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_skip_wave_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "creepAlert",
								pos = v(0, 0),
								scale = v(0.7, 0.7)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_kill_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								image_name = "icon_0003",
								class = "KImageView",
								pos = v(3.2, 3.2),
								scale = v(1, 1),
								colors = {
									tint = {
										255,
										0,
										0,
										255
									}
								}
							}
						}
					},
					{
						class = "KView",
						id = "cheat_damage_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "icon_0003",
								pos = v(3.2, 3.2),
								scale = v(1, 1)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_win_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "backPack_icons_0001",
								pos = v(-12.8, -12.8),
								scale = v(0.65, 0.65)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_auto_play",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "backPack_icons_0005",
								pos = v(-12.8, -12.8),
								scale = v(0.65, 0.65)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_speed",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						selected_color = {
							255,
							0,
							0,
							255
						},
						children = {
							{
								vertical_align = "middle",
								fit_lines = 1,
								font_size = 17.6,
								text_align = "center",
								text = "x1",
								class = "GGLabel",
								id = "label",
								font_name = "hud",
								size = v(32, 32),
								colors = {
									text = {
										243,
										236,
										207,
										255
									}
								}
							}
						}
					},
					{
						class = "KView",
						id = "cheat_unlock_towers",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "cheat_unlock_towers",
								pos = v(0, 4.8),
								scale = v(0.4, 0.4)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_dump_entities",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "icon_0003",
								pos = v(0, 3.2),
								scale = v(1, 1)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_preview_animations_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "icon_0003",
								pos = v(0, 3.2),
								scale = v(1, 1)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_hide_ui_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								255,
								255,
								0,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "icon_0003",
								pos = v(0, 3.2),
								scale = v(1, 1)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_safe_area",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								255,
								0,
								0,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "icon_0003",
								pos = v(0, 3.2),
								scale = v(1, 1)
							}
						}
					},
					{
						class = "KView",
						id = "cheat_change_fps_ui_button",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								0,
								0,
								0,
								255
							}
						},
						children = {
							{
								vertical_align = "middle",
								fit_lines = 1,
								font_size = 17.6,
								text_align = "center",
								text = "60fps",
								class = "GGLabel",
								id = "label",
								font_name = "hud",
								size = v(32, 32),
								colors = {
									text = {
										243,
										236,
										207,
										255
									}
								}
							}
						}
					},
					{
						class = "KView",
						id = "cheat_stop_auto_play",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								255,
								0,
								0,
								255
							}
						},
						children = {
							{
								class = "KImageView",
								image_name = "backPack_icons_0005",
								pos = v(-12.8, -12.8),
								scale = v(0.65, 0.65)
							}
						}
					}
				}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_enemies_1",
				pos = {
					x = 16,
					y = 56
				},
				children = {}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_enemies_2",
				pos = {
					x = 16,
					y = 96
				},
				children = {}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_enemies_3",
				pos = {
					x = 16,
					y = 136
				},
				children = {}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_enemies_4",
				pos = {
					x = 16,
					y = 176
				},
				children = {}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_enemies_5",
				pos = {
					x = 16,
					y = 216
				},
				children = {}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_enemies_6",
				pos = {
					x = 16,
					y = 256
				},
				children = {}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_paths",
				pos = {
					x = 16,
					y = 296
				},
				children = {}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_pages",
				pos = {
					x = 16,
					y = 336
				},
				children = {}
			},
			{
				style = "horizontal",
				class = "KELayout",
				id = "cheat_view_custom",
				pos = {
					x = 16,
					y = 376
				},
				children = {}
			}
		}
	},
	enemy_button = {
		class = "KView",
		size = {
			x = 32,
			y = 32
		},
		colors = {
			background = {
				100,
				100,
				100,
				255
			}
		},
		children = {
			{
				image_name = "gui_bottom_info_image_soldiers_0001",
				class = "KImageView",
				id = "enemy_image",
				pos = v(-3, -3),
				scale = v(0.7, 0.7)
			}
		}
	},
	path_button = {
		class = "KView",
		size = {
			x = 32,
			y = 32
		},
		colors = {
			background = {
				100,
				100,
				100,
				255
			}
		},
		selected_color = {
			255,
			0,
			0,
			255
		},
		children = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				font_size = 17.6,
				text_align = "center",
				text = "1",
				class = "GGLabel",
				id = "path_number",
				font_name = "hud",
				size = v(32, 32),
				colors = {
					text = {
						243,
						236,
						207,
						255
					}
				}
			}
		}
	},
	text_button = {
		class = "KView",
		size = {
			x = 32,
			y = 32
		},
		colors = {
			background = {
				100,
				100,
				100,
				255
			}
		},
		selected_color = {
			255,
			0,
			0,
			255
		},
		children = {
			{
				vertical_align = "middle",
				fit_lines = 1,
				font_size = 17.6,
				text_align = "center",
				text = "1",
				class = "GGLabel",
				id = "text",
				font_name = "hud",
				size = v(32, 32),
				colors = {
					text = {
						243,
						236,
						207,
						255
					}
				}
			}
		}
	},
	animation_view = {
		class = "KView",
		id = "animation_view",
		can_drag = true,
		pos = {
			x = 32,
			y = 32
		},
		size = {
			x = 336,
			y = 320
		},
		colors = {
			background = {
				200,
				200,
				200,
				100
			}
		},
		scale = v(1.3, 1.3),
		children = {
			{
				style = "vertical",
				class = "KELayout",
				pos = {
					x = 16,
					y = 16
				},
				children = {
					{
						class = "KView",
						id = "animation_view_search_button",
						size = {
							x = 304,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								vertical_align = "middle",
								fit_lines = 1,
								font_size = 17.6,
								text_align = "center",
								text = "search",
								class = "GGLabel",
								font_name = "hud",
								size = v(320, 32),
								colors = {
									text = {
										243,
										236,
										207,
										255
									}
								}
							}
						}
					},
					{
						id = "animation_view_list",
						propagate_drag = false,
						class = "KEList"
					}
				}
			}
		}
	},
	time_control_ui = {
		can_drag = true,
		class = "KView",
		id = "cheat_time_control_view",
		pos = {
			x = 144,
			y = 4.8
		},
		size = {
			x = 244,
			y = 64
		},
		colors = {
			background = {
				200,
				200,
				200,
				100
			}
		},
		children = {
			{
				style = "horizontal",
				class = "KELayout",
				pos = {
					x = 16,
					y = 16
				},
				separation = v(24, 16),
				children = {
					{
						class = "KView",
						id = "time-1",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								vertical_align = "middle",
								fit_lines = 1,
								font_size = 17.6,
								text_align = "center",
								text = "-1",
								class = "GGLabel",
								id = "text",
								font_name = "hud",
								size = v(32, 32),
								colors = {
									text = {
										243,
										236,
										207,
										255
									}
								}
							}
						}
					},
					{
						class = "KView",
						id = "time-label",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								vertical_align = "middle",
								fit_lines = 1,
								font_size = 17.6,
								text_align = "center",
								text = "x1",
								class = "GGLabel",
								id = "text",
								font_name = "hud",
								size = v(32, 32),
								colors = {
									text = {
										243,
										236,
										207,
										255
									}
								}
							}
						}
					},
					{
						class = "KView",
						id = "time+1",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						children = {
							{
								vertical_align = "middle",
								fit_lines = 1,
								font_size = 17.6,
								text_align = "center",
								text = "1",
								class = "GGLabel",
								id = "text",
								font_name = "hud",
								size = v(32, 32),
								colors = {
									text = {
										243,
										236,
										207,
										255
									}
								}
							}
						}
					},
					{
						class = "KView",
						id = "step",
						size = {
							x = 32,
							y = 32
						},
						colors = {
							background = {
								100,
								100,
								100,
								255
							}
						},
						color_enabled = {
							255,
							100,
							100,
							255
						},
						color_disabled = {
							100,
							100,
							100,
							255
						},
						children = {
							{
								vertical_align = "middle",
								fit_lines = 1,
								font_size = 17.6,
								text_align = "center",
								text = "S",
								class = "GGLabel",
								id = "text",
								font_name = "hud",
								size = v(32, 32),
								colors = {
									text = {
										243,
										236,
										207,
										255
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
