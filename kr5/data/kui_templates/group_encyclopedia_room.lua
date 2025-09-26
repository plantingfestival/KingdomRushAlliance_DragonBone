-- chunkname: @./kr5/data/kui_templates/group_encyclopedia_room.lua

return {
	class = "KView",
	children = {
		{
			class = "KView",
			id = "group_encyclopedia_room_desktop",
			pos = v(-4.45, 1.2),
			UNLESS = ctx.is_mobile,
			children = {
				{
					class = "GG5Button",
					r = -1.5359,
					id = "button_tab_enemies_selected",
					default_image_name = "room_encyclopedia_button_tab_enemies_selected_0001",
					focus_image_name = "room_encyclopedia_button_tab_enemies_selected_0003",
					pos = v(-450.05, -494.6),
					scale = v(0.9999, 0.9999),
					anchor = v(78.55, 58.7)
				},
				{
					class = "GG5Button",
					r = -1.5359,
					id = "button_tab_towers_selected",
					default_image_name = "room_encyclopedia_button_tab_towers_selected_0001",
					focus_image_name = "room_encyclopedia_button_tab_towers_selected_0003",
					pos = v(-560.55, -481.6),
					scale = v(0.9999, 0.9999),
					anchor = v(83.35, 51.3)
				},
				{
					class = "GG5Button",
					r = -1.5359,
					id = "button_tab_towers",
					default_image_name = "room_encyclopedia_button_tab_towers_0001",
					focus_image_name = "room_encyclopedia_button_tab_towers_0003",
					pos = v(-560.55, -481.6),
					scale = v(0.9999, 0.9999),
					anchor = v(83.35, 51.3)
				},
				{
					class = "GG5Button",
					r = -1.5359,
					id = "button_tab_enemies",
					default_image_name = "room_encyclopedia_button_tab_enemies_0001",
					focus_image_name = "room_encyclopedia_button_tab_enemies_0003",
					pos = v(-450.05, -494.6),
					scale = v(0.9999, 0.9999),
					anchor = v(78.55, 58.7)
				},
				{
					class = "KImageView",
					image_name = "room_encyclopedia_image_book_background_desktop_",
					pos = v(-1.2, 16.25),
					anchor = v(729.1, 515.6)
				},
				{
					id = "group_thumbs",
					class = "KView",
					pos = v(-321.35, -50.65),
					children = {
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_03",
							pos = v(61.8, -230.1),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_04",
							pos = v(179.5, -230.1),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_02",
							pos = v(-55.85, -230.1),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_01",
							pos = v(-173.5, -230.1),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_07",
							pos = v(61.8, -114.5),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_08",
							pos = v(179.5, -114.5),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_06",
							pos = v(-55.85, -114.5),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_05",
							pos = v(-173.5, -114.5),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_11",
							pos = v(61.8, 1.1),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_12",
							pos = v(179.5, 1.1),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_10",
							pos = v(-55.85, 1.1),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_09",
							pos = v(-173.5, 1.1),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_15",
							pos = v(61.8, 116.7),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_16",
							pos = v(179.5, 116.7),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_14",
							pos = v(-55.85, 116.7),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_13",
							pos = v(-173.5, 116.7),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_19",
							pos = v(61.8, 232.45),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_20",
							pos = v(179.5, 232.45),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_18",
							pos = v(-55.85, 232.45),
							scale = v(1, 1)
						},
						{
							class = "GG5Button",
							template_name = "button_encyclopedia_thumb_desktop",
							id = "button_thumbs_17",
							pos = v(-173.5, 232.45),
							scale = v(1, 1)
						}
					}
				},
				{
					id = "group_stats_enemy",
					class = "KView",
					pos = v(340.8, 130.9),
					children = {
						{
							image_name = "room_encyclopedia_9slice_image_line_divider_ornament_",
							class = "GG59View",
							pos = v(-6.3, 2.45),
							size = v(438.723, 142.3979),
							anchor = v(224.7272, 72.1703),
							slice_rect = r(24.7, 27.95, 20.8, 15.75)
						},
						{
							image_name = "room_encyclopedia_image_flourish_divider_ornament_",
							class = "KImageView",
							r = -1.5708,
							pos = v(204.8, -1.75),
							scale = v(1, 1),
							anchor = v(23.75, 12.85)
						},
						{
							image_name = "room_encyclopedia_image_flourish_divider_ornament_",
							class = "KImageView",
							r = -1.5708,
							pos = v(-228.95, -1.75),
							scale = v(1, 1),
							anchor = v(23.75, 12.85)
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_damage_",
							class = "KImageView",
							pos = v(-176.5, -30.9),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "3-6",
							class = "GG5Label",
							id = "label_stats_enemy_damage",
							font_name = "fla_body",
							pos = v(-157.8, -45.9),
							scale = v(1, 1),
							size = v(135.7, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_armor_",
							class = "KImageView",
							pos = v(-176.5, 1.6),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "None",
							class = "GG5Label",
							id = "label_stats_enemy_armor",
							font_name = "fla_body",
							pos = v(-157.8, -13.4),
							scale = v(1, 1),
							size = v(135.7, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_speed_",
							class = "KImageView",
							pos = v(-176.5, 34),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "Slow",
							class = "GG5Label",
							id = "label_stats_enemy_speed",
							font_name = "fla_body",
							pos = v(-157.8, 19),
							scale = v(1, 1),
							size = v(134.8, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_health_",
							class = "KImageView",
							pos = v(31.45, -30.9),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "250",
							class = "GG5Label",
							id = "label_stats_enemy_health",
							font_name = "fla_body",
							pos = v(50.15, -45.9),
							scale = v(1, 1),
							size = v(106.7, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_armor_magical_",
							class = "KImageView",
							pos = v(31.45, 1.6),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "None",
							class = "GG5Label",
							id = "label_stats_enemy_armor_magical",
							font_name = "fla_body",
							pos = v(50.15, -13.4),
							scale = v(1, 1),
							size = v(106.25, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_lives_",
							class = "KImageView",
							pos = v(31.45, 34),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "1",
							class = "GG5Label",
							id = "label_stats_enemy_lives",
							font_name = "fla_body",
							pos = v(50.15, 19),
							scale = v(1, 1),
							size = v(105.85, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						}
					}
				},
				{
					id = "group_stats_barracks",
					class = "KView",
					pos = v(329.7, 95.05),
					children = {
						{
							image_name = "room_encyclopedia_9slice_image_line_divider_ornament_",
							class = "GG59View",
							pos = v(4.7, -1.25),
							size = v(438.723, 95.9333),
							anchor = v(224.7272, 48.6211),
							slice_rect = r(24.7, 27.95, 20.8, 15.75)
						},
						{
							image_name = "room_encyclopedia_image_flourish_divider_ornament_",
							class = "KImageView",
							r = -1.5708,
							pos = v(218.45, -3.9),
							scale = v(1, 1),
							anchor = v(23.75, 12.85)
						},
						{
							image_name = "room_encyclopedia_image_flourish_divider_ornament_",
							class = "KImageView",
							r = -1.5708,
							pos = v(-216.8, -3.9),
							scale = v(1, 1),
							anchor = v(23.75, 12.85)
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_damage_",
							class = "KImageView",
							pos = v(-165.9, -19.35),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "3-6",
							class = "GG5Label",
							id = "label_stats_barracks_damage",
							font_name = "fla_body",
							pos = v(-147.2, -34.35),
							scale = v(1, 1),
							size = v(135.35, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_health_",
							class = "KImageView",
							pos = v(-165.9, 15.55),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "250",
							class = "GG5Label",
							id = "label_stats_barracks_health",
							font_name = "fla_body",
							pos = v(-147.2, 0.55),
							scale = v(1, 1),
							size = v(135.35, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_respawn_",
							class = "KImageView",
							pos = v(40.65, -19.35),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "Slow",
							class = "GG5Label",
							id = "label_stats_barracks_respawn",
							font_name = "fla_body",
							pos = v(59.35, -34.35),
							scale = v(1, 1),
							size = v(108.75, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_armor_",
							class = "KImageView",
							pos = v(40.65, 15.55),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "None",
							class = "GG5Label",
							id = "label_stats_barracks_armor",
							font_name = "fla_body",
							pos = v(59.35, 0.55),
							scale = v(1, 1),
							size = v(108.35, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						}
					}
				},
				{
					id = "group_stats_tower",
					class = "KView",
					pos = v(329.7, 95.05),
					children = {
						{
							image_name = "room_encyclopedia_9slice_image_line_divider_ornament_",
							class = "GG59View",
							pos = v(4.7, -1.25),
							size = v(438.723, 95.9333),
							anchor = v(224.7272, 48.6211),
							slice_rect = r(24.7, 27.95, 20.8, 15.75)
						},
						{
							image_name = "room_encyclopedia_image_flourish_divider_ornament_",
							class = "KImageView",
							r = -1.5708,
							pos = v(218.45, -3.9),
							scale = v(1, 1),
							anchor = v(23.75, 12.85)
						},
						{
							image_name = "room_encyclopedia_image_flourish_divider_ornament_",
							class = "KImageView",
							r = -1.5708,
							pos = v(-216.8, -3.9),
							scale = v(1, 1),
							anchor = v(23.75, 12.85)
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_damage_",
							class = "KImageView",
							pos = v(-165.9, -19.35),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "3-6",
							class = "GG5Label",
							id = "label_stats_tower_damage",
							font_name = "fla_body",
							pos = v(-147.2, -34.35),
							scale = v(1, 1),
							size = v(134.5, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_range_",
							class = "KImageView",
							pos = v(-165.9, 15.55),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "3-6",
							class = "GG5Label",
							id = "label_stats_tower_range",
							font_name = "fla_body",
							pos = v(-147.2, 0.55),
							scale = v(1, 1),
							size = v(134.5, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						},
						{
							image_name = "room_encyclopedia_image_stat_icon_cooldown_",
							class = "KImageView",
							pos = v(41.65, -19.35),
							scale = v(0.9, 0.9),
							anchor = v(15, 15)
						},
						{
							text_align = "left",
							line_height_extra = "2",
							fit_size = true,
							font_size = 21,
							text = "3-6",
							class = "GG5Label",
							id = "label_stats_tower_cooldown",
							font_name = "fla_body",
							pos = v(60.35, -34.35),
							scale = v(1, 1),
							size = v(109.65, 29.85),
							colors = {
								text = {
									97,
									56,
									41
								}
							}
						}
					}
				},
				{
					class = "GG5Pager",
					id = "pager",
					align = "center",
					pos = v(-312, 274),
					children = {
						{
							id = "button_page_01",
							class = "GG5ToggleButton",
							template_name = "toggle_encyclopedia_pager",
							pos = v(0.05, 0)
						}
					}
				},
				{
					id = "group_skills_tower",
					class = "KView",
					pos = v(325.8, 214),
					children = {
						{
							id = "group_skill_tower_01",
							class = "KView",
							pos = v(-104.1, -8.2),
							children = {
								{
									class = "KImageView",
									image_name = "room_encyclopedia_image_skill_tower_icon_",
									id = "image_skill_tower_icon",
									pos = v(0, 3),
									scale = v(0.9, 0.9),
									anchor = v(50, 50)
								},
								{
									vertical_align = "middle-caps",
									text_align = "center",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 19,
									text = "healing prayer",
									id = "label_skill_tower",
									fit_size = true,
									font_name = "fla_body",
									pos = v(-97.25, 46.2),
									size = v(192.2, 33.75),
									colors = {
										text = {
											96,
											55,
											40
										}
									}
								}
							}
						},
						{
							id = "group_skill_tower_02",
							class = "KView",
							pos = v(102.85, -8.2),
							children = {
								{
									class = "KImageView",
									image_name = "room_encyclopedia_image_skill_tower_icon_",
									id = "image_skill_tower_icon",
									pos = v(0, 3),
									scale = v(0.9, 0.9),
									anchor = v(50, 50)
								},
								{
									vertical_align = "middle-caps",
									text_align = "center",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 19,
									text = "healing prayer",
									id = "label_skill_tower",
									fit_size = true,
									font_name = "fla_body",
									pos = v(-97.25, 46.2),
									size = v(192.2, 33.75),
									colors = {
										text = {
											96,
											55,
											40
										}
									}
								}
							}
						}
					}
				},
				{
					id = "group_skills_tower_triple",
					class = "KView",
					pos = v(325.8, 215.1),
					children = {
						{
							id = "group_skill_tower_02",
							class = "KView",
							pos = v(2.5, -8.2),
							children = {
								{
									class = "KImageView",
									image_name = "room_encyclopedia_image_skill_tower_icon_",
									id = "image_skill_tower_icon",
									pos = v(0, 3),
									scale = v(0.9, 0.9),
									anchor = v(50, 50)
								},
								{
									vertical_align = "middle-caps",
									text_align = "center",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 19,
									text = "healing prayer",
									id = "label_skill_tower",
									fit_size = true,
									font_name = "fla_body",
									pos = v(-97.25, 46.2),
									size = v(192.2, 33.75),
									colors = {
										text = {
											96,
											55,
											40
										}
									}
								}
							}
						},
						{
							id = "group_skill_tower_01",
							class = "KView",
							pos = v(-191.4, -8.2),
							children = {
								{
									class = "KImageView",
									image_name = "room_encyclopedia_image_skill_tower_icon_",
									id = "image_skill_tower_icon",
									pos = v(0, 3),
									scale = v(0.9, 0.9),
									anchor = v(50, 50)
								},
								{
									vertical_align = "middle-caps",
									text_align = "center",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 19,
									text = "healing prayer",
									id = "label_skill_tower",
									fit_size = true,
									font_name = "fla_body",
									pos = v(-97.25, 46.2),
									size = v(192.2, 33.75),
									colors = {
										text = {
											96,
											55,
											40
										}
									}
								}
							}
						},
						{
							id = "group_skill_tower_03",
							class = "KView",
							pos = v(196.45, -8.2),
							children = {
								{
									class = "KImageView",
									image_name = "room_encyclopedia_image_skill_tower_icon_",
									id = "image_skill_tower_icon",
									pos = v(0, 3),
									scale = v(0.9, 0.9),
									anchor = v(50, 50)
								},
								{
									vertical_align = "middle-caps",
									text_align = "center",
									class = "GG5Label",
									line_height_extra = "0",
									font_size = 19,
									text = "healing prayer",
									id = "label_skill_tower",
									fit_size = true,
									font_name = "fla_body",
									pos = v(-97.25, 46.2),
									size = v(192.2, 33.75),
									colors = {
										text = {
											96,
											55,
											40
										}
									}
								}
							}
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "center",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 21,
					text = "Filthy and disorganized troublemakers.\nThe bulk of the wildbeast army.\nFilthy and disorganized troublemakers.\nThe bulk of the wildbeast army.",
					id = "label_details_desc",
					fit_size = true,
					font_name = "fla_body",
					pos = v(84.05, -97.1),
					size = v(492.2, 127),
					colors = {
						text = {
							96,
							55,
							40
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					class = "GG5Label",
					line_height_extra = "2",
					font_size = 50,
					text = "Enemies",
					id = "label_title_thumbs",
					fit_size = true,
					font_name = "fla_h",
					pos = v(-473.15, -407.4),
					size = v(306.85, 51.9),
					colors = {
						text = {
							121,
							91,
							64
						}
					}
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					class = "GG5Label",
					line_height_extra = "2",
					font_size = 40,
					text = "Hog Invader",
					id = "label_title_details",
					fit_size = true,
					font_name = "fla_h",
					pos = v(178.05, -408.95),
					size = v(306.95, 52.9),
					colors = {
						text = {
							121,
							91,
							64
						}
					}
				},
				{
					id = "firulete_thumbs_left",
					image_name = "room_encyclopedia_image_firulete_",
					class = "KImageView",
					pos = v(-472.65, -380.5),
					anchor = v(109.6, 10.25)
				},
				{
					class = "KImageView",
					image_name = "room_encyclopedia_image_firulete_",
					id = "firulete_thumbs_right",
					pos = v(-164.95, -380.5),
					scale = v(-1, 1),
					anchor = v(109.6, 10.25)
				},
				{
					id = "firulete_details_left",
					image_name = "room_encyclopedia_image_firulete_",
					class = "KImageView",
					pos = v(177.3, -380.5),
					anchor = v(109.6, 10.25)
				},
				{
					class = "KImageView",
					image_name = "room_encyclopedia_image_firulete_",
					id = "firulete_details_right",
					pos = v(486.65, -380.5),
					scale = v(-1, 1),
					anchor = v(109.6, 10.25)
				},
				{
					vertical_align = "middle-caps",
					text_align = "center",
					class = "GG5Label",
					line_height_extra = "0",
					font_size = 21,
					text = "killer, fast speed, splits into shards",
					id = "label_details_footer",
					fit_size = true,
					font_name = "fla_body",
					pos = v(84.05, 208.75),
					size = v(492.2, 125.25),
					colors = {
						text = {
							135,
							109,
							80
						}
					}
				},
				{
					id = "group_polaroid",
					class = "KView",
					pos = v(333.5, -230.7),
					children = {
						{
							class = "KImageView",
							r = 0.0431,
							id = "detail_polaroid",
							pos = v(4.85, -4.85),
							scale = v(0.6216, 0.6216),
							anchor = v(165, 165)
						},
						{
							class = "KImageView",
							r = 0.0433,
							id = "image_polaroid_frame",
							image_name = "room_encyclopedia_image_polaroid_frame_",
							pos = v(1.05, -1.7),
							scale = v(0.8086, 0.8086),
							anchor = v(147.15, 140)
						}
					}
				},
				{
					focus_image_name = "room_encyclopedia_button_bg_close_desktop_0003",
					class = "GG5Button",
					id = "button_close_popup",
					default_image_name = "room_encyclopedia_button_bg_close_desktop_0001",
					pos = v(708.85, -424.6),
					image_offset = v(-85.3, -85.95),
					hit_rect = r(-85.3, -85.95, 173.8, 159.35),
					children = {}
				}
			}
		}
	}
}
