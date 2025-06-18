-- chunkname: @./kr5/data/kui_templates/group_card_3.lua

return {
	class = "KView",
	children = {
		{
			id = "rewards_overlay",
			class = "KView",
			pos = v(-864, -384),
			anchor = v(0, 0),
			size = v(1728, 768)
		},
		{
			id = "image_card_3_1",
			class = "KImageView",
			hidden = true,
			image_name = "screen_cards_main_image_card_",
			pos = v(-321.25, -2.3),
			scale = v(1, 1),
			anchor = v(114.2, 189.25)
		},
		{
			id = "image_card_3_2",
			class = "KImageView",
			transition_delay = 0.1,
			hidden = true,
			image_name = "screen_cards_main_image_card_",
			pos = v(0.3, -2.3),
			scale = v(1, 1),
			anchor = v(114.2, 189.25)
		},
		{
			id = "image_card_3_3",
			class = "KImageView",
			transition_delay = 0.2,
			hidden = true,
			image_name = "screen_cards_main_image_card_",
			pos = v(320.9, -2.3),
			scale = v(1, 1),
			anchor = v(114.2, 189.25)
		},
		{
			id = "group_card_txt_3_1",
			class = "KView",
			pos = v(-321.5, -31.75),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					class = "GG5ShaderLabel",
					font_size = 38,
					line_height_extra = "2",
					text = "x3\naaaaa",
					id = "label_card_amount_1_1",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-144.4, 163.75),
					size = v(288.8, 90.3),
					colors = {
						text = {
							255,
							255,
							255
						}
					},
					shaders = {
						"p_glow"
					},
					shader_args = {
						{
							thickness = 2,
							glow_color = {
								0.1373,
								0.1255,
								0.1255,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					class = "GG5ShaderLabel",
					font_size = 32,
					line_height_extra = "2",
					text = "upgrade points!\naaaaaa",
					id = "label_card_title_1_1",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-149, -243.9),
					size = v(297.95, 72.95),
					colors = {
						text = {
							233,
							233,
							233
						}
					},
					shaders = {
						"p_glow"
					},
					shader_args = {
						{
							thickness = 2,
							glow_color = {
								0.1373,
								0.1255,
								0.1255,
								1
							}
						}
					}
				}
			}
		},
		{
			id = "group_txt_continue_3_1",
			class = "KView",
			pos = v(0, 283),
			children = {
				{
					vertical_align = "middle",
					text_align = "center",
					class = "GG5ShaderLabel",
					font_size = 35,
					line_height_extra = "2",
					text = "tap to continue",
					id = "label_tap_continue_1",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-381.2, -43.95),
					size = v(762.45, 47.15),
					colors = {
						text = {
							255,
							255,
							255
						}
					},
					shaders = {
						"p_glow"
					},
					shader_args = {
						{
							thickness = 2,
							glow_color = {
								0.1373,
								0.1255,
								0.1255,
								1
							}
						}
					}
				}
			}
		},
		{
			id = "group_card_txt_3_2",
			class = "KView",
			pos = v(1.6, -31.75),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					class = "GG5ShaderLabel",
					font_size = 38,
					line_height_extra = "2",
					text = "x3\naaaaa",
					id = "label_card_amount_1_1",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-144.4, 163.75),
					size = v(288.8, 90.3),
					colors = {
						text = {
							255,
							255,
							255
						}
					},
					shaders = {
						"p_glow"
					},
					shader_args = {
						{
							thickness = 2,
							glow_color = {
								0.1373,
								0.1255,
								0.1255,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					class = "GG5ShaderLabel",
					font_size = 32,
					line_height_extra = "2",
					text = "upgrade points!\naaaaaa",
					id = "label_card_title_1_1",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-149, -243.9),
					size = v(297.95, 72.95),
					colors = {
						text = {
							233,
							233,
							233
						}
					},
					shaders = {
						"p_glow"
					},
					shader_args = {
						{
							thickness = 2,
							glow_color = {
								0.1373,
								0.1255,
								0.1255,
								1
							}
						}
					}
				}
			}
		},
		{
			id = "group_card_txt_3_3",
			class = "KView",
			pos = v(321.55, -31.75),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					class = "GG5ShaderLabel",
					font_size = 38,
					line_height_extra = "2",
					text = "x3\naaaaa",
					id = "label_card_amount_1_1",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-144.4, 163.75),
					size = v(288.8, 90.3),
					colors = {
						text = {
							255,
							255,
							255
						}
					},
					shaders = {
						"p_glow"
					},
					shader_args = {
						{
							thickness = 2,
							glow_color = {
								0.1373,
								0.1255,
								0.1255,
								1
							}
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					class = "GG5ShaderLabel",
					font_size = 32,
					line_height_extra = "2",
					text = "upgrade points!\naaaaaa",
					id = "label_card_title_1_1",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-149, -243.9),
					size = v(297.95, 72.95),
					colors = {
						text = {
							233,
							233,
							233
						}
					},
					shaders = {
						"p_glow"
					},
					shader_args = {
						{
							thickness = 2,
							glow_color = {
								0.1373,
								0.1255,
								0.1255,
								1
							}
						}
					}
				}
			}
		}
	}
}
