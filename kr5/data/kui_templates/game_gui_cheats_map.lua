-- chunkname: @./kr5/data/kui_templates/game_gui_cheats_map.lua

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
			x = 64,
			y = 64
		},
		size = {
			x = 600,
			y = 220
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
					x = 32,
					y = 32
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
						image_name = "level_select_button_ui_level_select_close_0001",
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
						id = "unlock_all",
						size = {
							x = 48,
							y = 48
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
								text = "Unlock all",
								vertical_align = "middle",
								class = "GGLabel",
								font_size = 13,
								text_align = "center",
								font_name = "hud",
								size = v(48, 48),
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
						id = "next_level",
						pos = {
							x = 58,
							y = 0
						},
						size = {
							x = 48,
							y = 48
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
								text = "Next Level",
								vertical_align = "middle",
								class = "GGLabel",
								font_size = 13,
								text_align = "center",
								font_name = "hud",
								size = v(48, 48),
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
						id = "consume_iaps",
						pos = {
							x = 58,
							y = 0
						},
						size = {
							x = 48,
							y = 48
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
								text = "Consume iaps",
								vertical_align = "middle",
								class = "GGLabel",
								font_size = 13,
								text_align = "center",
								font_name = "hud",
								size = v(48, 48),
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
