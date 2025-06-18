-- chunkname: @./kr5/data/kui_templates/group_slot.lua

return {
	class = "SlotView",
	children = {
		{
			default_image_name = "screen_slots_slot_bg_deleteornew_0001",
			class = "GG5Button",
			id = "slot_empty",
			focus_image_name = "screen_slots_slot_bg_deleteornew_0003",
			image_offset = v(-319.05, -80.3),
			hit_rect = r(-319.05, -80.3, 634, 168),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 46,
					line_height_extra = "2",
					text_key = "SLOT_NEW_GAME",
					text = "NEW GAME",
					class = "GG5ShaderLabel",
					id = "label_slot_new",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-266.6, -24.2),
					size = v(531.35, 45.55),
					colors = {
						text = {
							255,
							255,
							0
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
								0.9843,
								0.9961,
								0.0157,
								1
							},
							c2 = {
								0.9569,
								0.8275,
								0.0078,
								1
							},
							c3 = {
								0.9569,
								0.8275,
								0.0078,
								1
							}
						},
						{
							thickness = 3.3333333333333335,
							outline_color = {
								0.2549,
								0.3529,
								0.3804,
								1
							}
						}
					}
				}
			}
		},
		{
			default_image_name = "screen_slots_slot_bg_deleteornew_0001",
			class = "GG5Button",
			id = "slot_delete",
			focus_image_name = "screen_slots_slot_bg_deleteornew_0003",
			image_offset = v(-319.05, -80.3),
			hit_rect = r(-319.05, -80.3, 634, 168),
			children = {
				{
					id = "slot_delete_cancel",
					focus_image_name = "screen_slots_button_slot_delete_cancel_0003",
					class = "GG5Button",
					default_image_name = "screen_slots_button_slot_delete_cancel_0001",
					pos = v(246.7, -22.2),
					anchor = v(40.65, 18.65)
				},
				{
					id = "slot_delete_confirm",
					focus_image_name = "screen_slots_button_slot_delete_confirm_0003",
					class = "GG5Button",
					default_image_name = "screen_slots_button_slot_delete_confirm_0001",
					pos = v(151.3, -23.25),
					anchor = v(40.65, 18.65)
				},
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 46,
					line_height_extra = "2",
					text_key = "SLOT_DELETE_SLOT",
					text = "DELETE SLOT?",
					class = "GG5ShaderLabel",
					id = "label_slot_delete",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-289.7, -23),
					size = v(384.8, 45.55),
					colors = {
						text = {
							255,
							255,
							0
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
								0.9843,
								0.9961,
								0.0157,
								1
							},
							c2 = {
								0.9569,
								0.8275,
								0.0078,
								1
							},
							c3 = {
								0.9569,
								0.8275,
								0.0078,
								1
							}
						},
						{
							thickness = 3.3333333333333335,
							outline_color = {
								0.2549,
								0.3529,
								0.3804,
								1
							}
						}
					}
				}
			}
		},
		{
			default_image_name = "screen_slots_slot_bg_0001",
			class = "GG5Button",
			id = "slot_used",
			focus_image_name = "screen_slots_slot_bg_0003",
			image_offset = v(-319.05, -80.3),
			hit_rect = r(-319.05, -80.3, 634, 168),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					class = "GG5ShaderLabel",
					font_size = 46,
					line_height_extra = "0",
					text = "SLOT 1",
					id = "label_slot_name",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-284.95, -27.1),
					size = v(201.95, 45.55),
					colors = {
						text = {
							251,
							254,
							4
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
								0.9843,
								0.9961,
								0.0157,
								1
							},
							c2 = {
								0.9569,
								0.8275,
								0.0078,
								1
							},
							c3 = {
								0.9569,
								0.8275,
								0.0078,
								1
							}
						},
						{
							thickness = 3.3333333333333335,
							outline_color = {
								0.2549,
								0.3529,
								0.3804,
								1
							}
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 30,
					text = "199/199",
					id = "label_stars",
					fit_size = true,
					font_name = "fla_numbers",
					pos = v(12.85, -53.8),
					size = v(139.95, 40.95),
					colors = {
						text = {
							224,
							248,
							255
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 30,
					text = "99",
					id = "label_heroic",
					fit_size = true,
					font_name = "fla_numbers",
					pos = v(11.7, 3.7),
					size = v(52.05, 40.95),
					colors = {
						text = {
							224,
							248,
							255
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 30,
					text = "99",
					id = "label_iron",
					fit_size = true,
					font_name = "fla_numbers",
					pos = v(120.15, 3.7),
					size = v(53.45, 40.95),
					colors = {
						text = {
							224,
							248,
							255
						}
					}
				},
				{
					id = "slot_delete_request",
					focus_image_name = "screen_slots_button_slot_delete_0003",
					class = "GG5Button",
					default_image_name = "screen_slots_button_slot_delete_0001",
					pos = v(249.5, -28.15),
					anchor = v(40.3, 17.15)
				},
				{
					class = "KImageView",
					image_name = "screen_slots_image_slot_badges_",
					id = "slot_badges",
					pos = v(2.4, -26.05),
					scale = v(1.1974, 1.1974),
					anchor = v(43.1, 22.6)
				}
			}
		}
	}
}
