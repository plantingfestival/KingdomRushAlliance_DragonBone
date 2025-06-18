-- chunkname: @./kr5/data/kui_templates/popup_dlc_desktop.lua

return {
	class = "GG5PopUp",
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
							pos = v(7.75, -79.55),
							size = v(1078.4542, 698.2065),
							anchor = v(538.7169, 349.1033),
							slice_rect = r(21.3, 20.45, 10, 10.05)
						},
						{
							class = "KView",
							id = "group_bg_textures",
							pos = v(-3.75, -88.7),
							scale = v(0.9073, 0.6564),
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
							pos = v(-1.9, -116.35),
							size = v(1162.9535, 765.6653),
							anchor = v(570.7157, 332.3457),
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
							pos = v(-542.4, 197.3),
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
									pos = v(8.65, -106.5),
									scale = v(0.7772, 0.7772),
									anchor = v(11.1, 9.6)
								}
							}
						},
						{
							id = "group_rivets_right",
							class = "KView",
							pos = v(536.55, 197.3),
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
									pos = v(8.65, -105.25),
									scale = v(0.7772, 0.7772),
									anchor = v(11.1, 9.6)
								}
							}
						},
						{
							id = "group_rivets_bottom",
							class = "KView",
							pos = v(-449.95, 268.85),
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
							pos = v(-416.65, 325.1),
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
							size = v(694.8415, 73.5989),
							anchor = v(341.1212, 32.5995),
							slice_rect = r(99.95, 3.05, 16.8, 24.75)
						},
						{
							vertical_align = "top",
							text_align = "center",
							font_size = 50,
							line_height_extra = "1",
							text_key = "SHOP_DESKTOP_TITLE",
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
					id = "group_shop_offers_desktop",
					class = "KView",
					template_name = "group_shop_offers_desktop",
					pos = v(5.35, -129.75)
				}
			}
		}
	}
}
