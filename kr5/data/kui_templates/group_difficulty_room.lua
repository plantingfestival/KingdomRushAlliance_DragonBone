-- chunkname: @./kr5/data/kui_templates/group_difficulty_room.lua

return {
	class = "KView",
	children = {
		{
			class = "KView",
			id = "group_room_bg_desktop",
			transition = "down",
			UNLESS = ctx.is_mobile,
			children = {
				{
					class = "GG59View",
					image_name = "room_bg_desktop_9slice_bg_color_desktop_",
					id = "bg_color",
					pos = v(-4.1, 31.4),
					size = v(1473.6195, 633.381),
					anchor = v(736.1127, 316.6905),
					slice_rect = r(21.3, 20.45, 10, 10.05)
				},
				{
					class = "KView",
					id = "group_bg_textures",
					pos = v(-7.95, 21.05),
					scale = v(1.066, 0.5887),
					children = {
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_1",
							pos = v(-575, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_2",
							pos = v(-345, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_3",
							pos = v(-115, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_4",
							pos = v(115, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_5",
							pos = v(345, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_texture_desktop_",
							id = "bg_texture_6",
							pos = v(575, 31.2),
							scale = v(1.0428, 1.1723),
							anchor = v(107.45, 454.15)
						}
					}
				},
				{
					class = "GG59View",
					image_name = "room_bg_desktop_9slice_bg_frame_desktop_",
					id = "bg_frame",
					pos = v(-13.75, 6.55),
					size = v(1560.5484, 708.2832),
					anchor = v(765.8341, 307.4384),
					slice_rect = r(100.4, 75.25, 22.3, 15.4)
				},
				{
					id = "frame_top_right_corner",
					class = "KImageView",
					image_name = "room_bg_desktop_image_bg_frame_topcorner_desktop_",
					hidden = true,
					pos = v(697.65, -260.55),
					anchor = v(9.9, 29.15)
				},
				{
					class = "GG5Button",
					focus_image_name = "room_bg_desktop_button_bg_close_desktop_0003",
					id = "button_close_popup",
					default_image_name = "room_bg_desktop_button_bg_close_desktop_0001",
					pos = v(720.7, -266.3),
					scale = v(1, 1),
					anchor = v(42.7, 49.45)
				},
				{
					id = "group_rivets_left",
					class = "KView",
					pos = v(-748.75, 276.8),
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
					pos = v(728.15, 276.8),
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
					pos = v(-460.3, 360.5),
					children = {
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(-146.55, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(-45.75, -6.45),
							anchor = v(5.75, 6.4)
						},
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
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(962.25, -6.45),
							anchor = v(5.75, 6.4)
						},
						{
							class = "KImageView",
							image_name = "room_bg_desktop_image_bg_rivet_small_desktop_",
							pos = v(1063.05, -6.45),
							anchor = v(5.75, 6.4)
						}
					}
				},
				{
					class = "GG59View",
					image_name = "room_bg_desktop_9slice_bg_title_desktop_",
					id = "title_bg",
					pos = v(0.35, -327),
					size = v(738.5165, 73.5989),
					anchor = v(362.5627, 32.5995),
					slice_rect = r(99.95, 3.05, 16.8, 24.75)
				},
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 50,
					line_height_extra = "1",
					text_key = "DIFFICULTY LEVEL",
					text = "DIFFICULTY LEVEL",
					class = "GG5ShaderLabel",
					id = "title_text",
					font_name = "fla_h",
					pos = v(-400, -341),
					scale = v(1, 1),
					size = v(800, 49.9),
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
			template_name = "toggle_difficulty_level",
			class = "GG5ToggleButton",
			transition_delay = 0.15,
			id = "toggle_difficulty_level_1",
			transition = "down",
			pos = v(-504.25, 31.35)
		},
		{
			template_name = "toggle_difficulty_level",
			class = "GG5ToggleButton",
			transition_delay = 0.2,
			id = "toggle_difficulty_level_2",
			transition = "down",
			pos = v(-167.4, 31.35)
		},
		{
			template_name = "toggle_difficulty_level",
			class = "GG5ToggleButton",
			transition_delay = 0.25,
			id = "toggle_difficulty_level_3",
			transition = "down",
			pos = v(169.5, 31.35)
		},
		{
			template_name = "toggle_difficulty_level",
			class = "GG5ToggleButton",
			transition_delay = 0.3,
			id = "toggle_difficulty_level_4",
			transition = "down",
			pos = v(506.4, 31.35)
		},
		{
			class = "KView",
			transition_delay = 0.2,
			id = "MovieClip58",
			transition = "scale",
			pos = v(2.5, -273.7),
			WHEN = ctx.is_mobile,
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 44,
					line_height_extra = "0",
					text_key = "DIFFICULTY_SELECTION_TITLE",
					text = "choose the difficulty mode",
					class = "GG5ShaderLabel",
					id = "label_title",
					fit_size = true,
					font_name = "fla_body",
					pos = v(-653.65, -29.7),
					size = v(1307.35, 58.2),
					colors = {
						text = {
							220,
							245,
							253
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 2.5,
							outline_color = {
								0.0235,
								0.2235,
								0.2667,
								1
							}
						}
					}
				}
			}
		}
	}
}
