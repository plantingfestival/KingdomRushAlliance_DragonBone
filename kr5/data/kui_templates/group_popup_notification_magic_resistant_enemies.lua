-- chunkname: @./kr5/data/kui_templates/group_popup_notification_magic_resistant_enemies.lua

return {
	class = "KView",
	children = {
		{
			class = "GG59View",
			image_name = "ingame_notifications_9slice_notification_bg_",
			id = "bg",
			pos = v(-3.45, -19.25),
			size = v(921.8482, 668.3008),
			anchor = v(460.9241, 331.6985),
			slice_rect = r(232.75, 188.6, 1.5, 1.65)
		},
		{
			id = "title_bg",
			image_name = "ingame_notifications_image_title_bg_2_",
			class = "KImageView",
			pos = v(-0.45, -330.8),
			anchor = v(271.9, 50.1)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_armored_enemies_arrow_",
			pos = v(-30.95, -6.05),
			anchor = v(69, 15.05)
		},
		{
			image_name = "ingame_notifications_image_magic_resistant_enemy_",
			class = "KImageView",
			pos = v(-179.3, -14.8),
			scale = v(1, 1),
			anchor = v(45.45, 38.9)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_magic_resistant_tower_",
			pos = v(135.8, -28.45),
			anchor = v(70.25, 56.8)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_magic_resistant_enemies_bottom_info_",
			pos = v(2.65, 95.3),
			anchor = v(316.35, 51.5)
		},
		{
			class = "KImageView",
			image_name = "ingame_notifications_image_magic_resistant_enemies_shield_",
			pos = v(-268.65, -187.9),
			anchor = v(69.4, 72.05)
		},
		{
			vertical_align = "top",
			text_align = "center",
			font_size = 48,
			line_height_extra = "2",
			fit_size = true,
			text = " New tip",
			text_key = "NOTIFICATION_title_new_tip",
			class = "GG5ShaderLabel",
			id = "label_title_new_tip",
			font_name = "fla_h",
			pos = v(-235, -360.15),
			scale = v(1, 1),
			size = v(467.85, 47.4),
			colors = {
				text = {
					240,
					237,
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
						0,
						0.0471,
						0.2,
						1
					}
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "NOTIFICATION_magic_resistant_enemies_desc_body_1",
			font_size = 27,
			line_height_extra = "2",
			fit_size = true,
			text = "Einige Feinde genießen unterschiedliche Niveaus des magischen Widerstandes, der sie gegen magische Angriffe schützt.",
			class = "GG5Label",
			id = "label_magic_resistant_enemies_desc_body_1",
			font_name = "fla_body",
			pos = v(-199.75, -229.7),
			scale = v(1, 1),
			size = v(539.85, 121.85),
			colors = {
				text = {
					90,
					55,
					38
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			text_key = "NOTIFICATION_magic_resistant_enemies_desc_title",
			font_size = 28,
			line_height_extra = "0",
			fit_size = true,
			text = "MAGIC RESISTANT ENEMIES!",
			class = "GG5Label",
			id = "label_magic_resistant_enemies_desc_title",
			font_name = "fla_body",
			pos = v(-199.65, -272.35),
			scale = v(1, 1),
			size = v(539.65, 43.3),
			colors = {
				text = {
					154,
					12,
					12
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "center",
			text_key = "NOTIFICATION_magic_resistant_enemies_desc_body_3",
			font_size = 27,
			line_height_extra = "0",
			fit_size = true,
			text = "Los enemigos resistentes a la magia reciben menos daño de los magos",
			class = "GG5Label",
			id = "label_magic_resistant_enemies_desc_body_3",
			font_name = "fla_body",
			pos = v(-330.65, 154.95),
			scale = v(1, 1),
			size = v(670.25, 79.9),
			colors = {
				text = {
					90,
					55,
					38
				}
			}
		},
		{
			vertical_align = "bottom",
			text_align = "center",
			text_key = "NOTIFICATION_magic_resistant_enemies_desc_body_2",
			font_size = 26,
			line_height_extra = "0",
			fit_size = true,
			text = "Widersteht\nSchaden von",
			class = "GG5Label",
			id = "label_magic_resistant_enemies_desc_body_2",
			font_name = "fla_body",
			pos = v(-126, -103.25),
			scale = v(1, 1),
			size = v(201, 77),
			colors = {
				text = {
					212,
					63,
					0
				}
			}
		},
		{
			vertical_align = "middle",
			text_align = "left",
			text_key = "NOTIFICATION_magic_resistant_enemies_enemy_name",
			font_size = 25,
			line_height_extra = "2",
			fit_size = true,
			text = "Turtle Shaman",
			class = "GG5Label",
			id = "label_magic_resistant_enemies_enemy_name",
			font_name = "fla_body",
			pos = v(-217.15, 48.75),
			scale = v(1, 1),
			size = v(289.95, 39.15),
			colors = {
				text = {
					192,
					192,
					192
				}
			}
		},
		{
			focus_image_name = "ingame_notifications_button_ok_0003",
			class = "GG5Button",
			id = "button_done",
			default_image_name = "ingame_notifications_button_ok_0001",
			pos = v(252.05, 299.1),
			image_offset = v(-172.2, -61.85),
			hit_rect = r(-172.2, -61.85, 356, 125),
			children = {
				{
					vertical_align = "top",
					text_align = "center",
					font_size = 48,
					line_height_extra = "0",
					fit_size = true,
					text = "Ok",
					text_key = "NOTIFICATION_button_ok",
					class = "GG5ShaderLabel",
					id = "label_button_ok",
					font_name = "fla_h",
					pos = v(-129.8, -28.35),
					scale = v(1, 1),
					size = v(267.95, 47.4),
					colors = {
						text = {
							250,
							253,
							255
						}
					},
					shaders = {
						"p_outline_tint"
					},
					shader_args = {
						{
							thickness = 1.6666666666666667,
							outline_color = {
								0.1176,
								0.2157,
								0.3059,
								1
							}
						}
					}
				}
			}
		}
	}
}
