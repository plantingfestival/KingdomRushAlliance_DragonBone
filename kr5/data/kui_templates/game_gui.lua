local SF = ctx.safe_frame
local BS_HUD = ctx.bs.hud
local BS_BOSS_BAR = ctx.bs.boss_bar
local BS_ACHIEVEMENT = ctx.bs.achievement
local BS_BOTTOM = ctx.bs.bottom
local BS_INFO = ctx.bs.info
local BS_VICTORY = ctx.bs.victory
local BS_DEFEAT = ctx.bs.defeat
local BS_OPTIONS = ctx.bs.popup_ingame_options
local BS_TOWER_TOOLTIP = ctx.bs.tower_tooltip
local BS_TOWER_MENU = ctx.bs.tower_menu
local BS_SHOP_INGAME = ctx.bs.shop_ingame

return {
	class = "KWindow",
	size = v(ctx.sw, ctx.sh),
	children = {
		{
			id = "touch_view",
			class = "TouchView",
			size = v(ctx.sw, ctx.sh)
		},
		{
			propagate_on_up = true,
			propagate_on_down = true,
			class = "KView",
			id = "layer_gui",
			propagate_on_click = true,
			size = v(ctx.sw, ctx.sh),
			children = {
				{
					id = "layer_gui_world",
					class = "KView",
					children = {
						{
							propagate_on_up = true,
							propagate_on_down = true,
							class = "KView",
							id = "layer_wave_flags",
							propagate_on_click = true
						},
						{
							id = "incoming_tooltip",
							hidden = true,
							class = "IncomingTooltip"
						},
						{
							id = "feedback_error_view",
							class = "WorldImageView",
							hidden = true,
							image_name = "error_feedback_0001",
							scale = ctx.bs.feedback,
							anchor = v(27, 26),
							animation = {
								hide_at_end = true,
								prefix = "error_feedback",
								to = 15
							}
						},
						{
							id = "feedback_ok_view",
							class = "WorldImageView",
							hidden = true,
							image_name = "confirm_feedback_0001",
							scale = ctx.bs.feedback,
							anchor = v(38, 18),
							animation = {
								hide_at_end = true,
								prefix = "confirm_feedback",
								to = 12
							}
						},
						{
							hidden = true,
							template_name = "game_gui_tower_menu_tooltip",
							class = "TowerMenuTooltip",
							wide_offset = 25,
							id = "tower_menu_tooltip",
							max_scale = BS_TOWER_TOOLTIP
						},
						{
							id = "tower_menu",
							hidden = true,
							class = "TowerMenu",
							max_scale = BS_TOWER_MENU
						}
					}
				},
				{
					propagate_on_up = true,
					propagate_on_down = true,
					class = "KView",
					id = "layer_gui_hud",
					propagate_on_click = true,
					size = v(ctx.sw, ctx.sh),
					children = {
						{
							hidden = true,
							class = "KView",
							id = "safe_area",
							pos = v(SF.l, SF.t),
							size = v(ctx.sw - SF.l - SF.r, ctx.sh - SF.t - SF.b),
							colors = {
								background = {
									255,
									0,
									0,
									100
								}
							}
						},
						{
							id = "hud_view",
							image_name = "ingame_ui_gui_top_info_background",
							class = "KImageView",
							pos = v(SF.lt, SF.tl),
							anchor = v(10, 10),
							base_scale = BS_HUD,
							children = {
								{
									text_align = "left",
									fit_lines = 1,
									font_size = 18,
									text = "20",
									class = "GGLabel",
									id = "hud_lives_label",
									font_name = "numbers_italic",
									pos = v(44, 13),
									size = v(52, 30),
									colors = {
										text = {
											243,
											236,
											207,
											255
										}
									}
								},
								{
									text_align = "left",
									fit_lines = 1,
									font_size = 18,
									text = "9999",
									class = "GGLabel",
									id = "hud_gold_label",
									font_name = "numbers_italic",
									pos = v(136, 13),
									size = v(64, 30),
									colors = {
										text = {
											243,
											236,
											207,
											255
										}
									}
								},
								{
									text_align = "center",
									fit_lines = 1,
									font_size = 18,
									text = "1/15",
									class = "GGLabel",
									id = "hud_waves_label",
									font_name = "numbers_italic",
									pos = v(44, 48),
									size = v(52, 30),
									colors = {
										text = {
											243,
											236,
											207,
											255
										}
									}
								},
								{
									id = "hud_gold_tutorial",
									image_name = "tutorial_circle_glow",
									class = "KImageView",
									hidden = true,
									pos = v(74, -15)
								},
								{
									class = "KView",
									id = "cheat_button",
									pos = v(106, 16),
									size = v(94, 20),
									colors = {
										background = {
											255,
											255,
											255,
											0
										}
									}
								},
								{
									class = "KView",
									id = "health_texts_button",
									pos = v(10, 16),
									size = v(94, 20),
									colors = {
										background = {
											255,
											255,
											255,
											0
										}
									}
								}
							}
						},
						{
							class = "KView",
							id = "pause_button_view",
							pos = v(ctx.sw - SF.rt, SF.tr),
							size = v(0, 106),
							base_scale = BS_HUD,
							anchor = v(22, -22),
							children = {
								{
									id = "pause_button",
									focus_image_name = "ingame_ui_hud_buttons_0001_hover",
									class = "GG5Button",
									default_image_name = "ingame_ui_hud_buttons_0001",
									pos = v(0, 0),
									anchor = v(46, 53)
								}
							}
						},
						{
							class = "KView",
							WHEN = ctx.remote_balance,
							pos = v(ctx.sw / 2, SF.tr),
							size = v(0, 106),
							base_scale = BS_HUD,
							anchor = v(22, -22),
							children = {
								{
									id = "remote_balance_button",
									class = "KView",
									anchor = v(30, 30),
									size = v(60, 60),
									colors = {
										background = {
											255,
											255,
											255,
											100
										}
									},
									children = {
										{
											vertical_align = "middle",
											text_align = "center",
											font_size = 16,
											text = "RB",
											class = "GGLabel",
											font_name = "hud",
											pos = v(30, 30),
											size = v(60, 60),
											anchor = v(30, 30),
											colors = {
												text = {
													255,
													255,
													255,
													255
												}
											}
										}
									}
								}
							}
						},
						{
							propagate_on_down = true,
							propagate_on_up = true,
							hidden = true,
							propagate_on_click = true,
							class = "BossHealthBar",
							id = "boss_health_bar",
							pos = v(ctx.sw / 2, SF.tl - 23),
							anchor = v(193, 0),
							base_scale = BS_BOSS_BAR,
							size = v(386, 24),
							children = {
								{
									propagate_on_down = true,
									class = "KView",
									propagate_on_click = true,
									id = "boss_health_bar_frame",
									propagate_on_up = true,
									pos = v(14, 15),
									shape = {
										name = "rectangle",
										args = {
											"fill",
											0,
											0,
											386,
											39,
											5,
											5,
											5
										}
									},
									colors = {
										background = {
											0,
											0,
											0,
											180
										}
									}
								},
								{
									vertical_align = "middle",
									text_align = "left",
									font_size = 12.8,
									text = "BOSS_NAME",
									class = "GGLabel",
									id = "boss_health_bar_title",
									fit_size = true,
									font_name = "hud",
									pos = v(64, 7.8),
									size = v(400, 41.6),
									colors = {
										text = {
											255,
											255,
											255,
											255
										},
										background = {
											0,
											255,
											0,
											0
										}
									}
								},
								{
									id = "portrait",
									class = "KImageView",
									image_name = "boss_health_bar_icon_0001",
									pos = v(16, 16)
								},
								{
									id = "boss_health_bar_back",
									class = "KImageView",
									image_name = "boss_fight_bars_0004",
									pos = v(64, 36.8)
								},
								{
									id = "boss_health_bar_front",
									class = "KImageView",
									image_name = "boss_fight_bars_0003",
									pos = v(64, 36.8)
								}
							}
						},
						{
							class = "KView",
							propagate_on_click = true,
							propagate_on_down = true,
							propagate_on_up = true,
							id = "infobar_view",
							hidden_y = ctx.sh + 100 * BS_INFO.y,
							shown_y = ctx.sh - SF.br,
							pos = v(33, ctx.sh + 100 * BS_INFO.y),
							size = v(390, 59),
							anchor = v(195, 70),
							base_scale = BS_INFO,
							colors = {
								background = {
									0,
									0,
									255,
									0
								}
							},
							children = {
								{
									propagate_on_down = true,
									propagate_on_click = true,
									propagate_on_up = true,
									class = "KView",
									id = "infobar_part_a",
									pos = v(0, 0),
									shape = {
										name = "rectangle",
										args = {
											"fill",
											0,
											0,
											390,
											59,
											5,
											5,
											5
										}
									},
									colors = {
										background = {
											0,
											0,
											0,
											180
										}
									},
									children = {
										{
											propagate_on_down = true,
											class = "KView",
											id = "with_portrait",
											propagate_on_up = true,
											propagate_on_click = true,
											pos = v(11.2, 11.2),
											children = {
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 16,
													text = "Name of soldierrrrrrrrrrrr",
													class = "GGLabel",
													id = "title",
													fit_size = true,
													font_name = "hud",
													pos = v(49.6, -6),
													size = v(176, 24),
													colors = {
														text = {
															255,
															255,
															255,
															255
														},
														background = {
															0,
															255,
															0,
															0
														}
													}
												},
												{
													id = "portrait",
													image_name = "gui_bottom_info_image_soldiers_0001",
													class = "KImageView",
													pos = v(23.4, 22.4),
													anchor = v(30.4, 30.4)
												}
											}
										},
										{
											id = "with_health",
											propagate_on_down = true,
											class = "KView",
											hidden = false,
											propagate_on_up = true,
											propagate_on_click = true,
											pos = v(7, 7),
											children = {
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 22,
													text = "Name of soldierrrrrrrrrrrr",
													class = "GGLabel",
													id = "title",
													fit_size = true,
													font_name = "hud",
													pos = v(54, 0),
													size = v(176, 20.8),
													colors = {
														text = {
															255,
															255,
															255,
															255
														},
														background = {
															0,
															255,
															0,
															0
														}
													}
												},
												{
													class = "KImageView",
													image_name = "menu_bottom_lifeBar_bg_0001",
													pos = v(54, 26.4)
												},
												{
													image_name = "menu_bottom_lifeBar",
													class = "KImageView",
													id = "health_bar",
													pos = v(54, 26.4),
													anchor = v(0, 0)
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14,
													text = "999/999",
													class = "GGLabel",
													id = "health",
													font_name = "numbers_italic",
													pos = v(56, 24.5),
													size = v(128, 19.2),
													colors = {
														text = {
															255,
															255,
															255,
															255
														},
														background = {
															0,
															255,
															0,
															0
														}
													}
												},
												{
													id = "portrait",
													focus_image_name = "gui_bottom_info_image_soldiers_0001",
													class = "GG5Button",
													default_image_name = "gui_bottom_info_image_soldiers_0001",
													pos = v(23.4, 22.4),
													anchor = v(26, 26)
												}
											}
										},
										{
											propagate_on_click = true,
											propagate_on_down = true,
											class = "KView",
											id = "text_only",
											propagate_on_up = true,
											hidden = true,
											pos = v(11, 7),
											shape = {
												name = "rectangle",
												args = {
													"fill",
													0,
													-0.5,
													185.6,
													46.4,
													5,
													5,
													4
												}
											},
											colors = {
												background = {
													0,
													0,
													0,
													0
												}
											},
											children = {
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 16,
													text = "Title text very longgg",
													class = "GGLabel",
													id = "title",
													font_name = "hud",
													pos = v(0, -5),
													size = v(176, 24),
													colors = {
														text = {
															255,
															255,
															255,
															255
														},
														background = {
															0,
															255,
															0,
															0
														}
													}
												}
											}
										},
										{
											id = "infobar_stats_type_1",
											class = "KView",
											hidden = true,
											pos = v(144.8, 6.4),
											children = {
												{
													id = "damage_icon",
													class = "KImageView",
													image_name = "icon_0007",
													pos = v(30, 23.4)
												},
												{
													id = "armor_icon",
													class = "KImageView",
													image_name = "icon_0004",
													pos = v(122.4, 2.2)
												},
												{
													id = "armor_bg_icon_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(144.8, 7)
												},
												{
													id = "armor_bg_icon_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(154.4, 7)
												},
												{
													id = "armor_bg_icon_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(164, 7)
												},
												{
													id = "armor_icon_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(144.8, 7)
												},
												{
													id = "armor_icon_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(154.4, 7)
												},
												{
													id = "armor_icon_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(164, 7)
												},
												{
													class = "KImageView",
													image_name = "icon_0003",
													pos = v(185.8, 0)
												},
												{
													id = "armor_icon_magic",
													class = "KImageView",
													image_name = "icon_0005",
													pos = v(122.4, 24.6)
												},
												{
													id = "armor_bg_icon_magic_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(144.8, 29.4)
												},
												{
													id = "armor_bg_icon_magic_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(154.4, 29.4)
												},
												{
													id = "armor_bg_icon_magic_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(164, 29.4)
												},
												{
													id = "armor_icon_magic_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(144.8, 29.4)
												},
												{
													id = "armor_icon_magic_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(154.4, 29.4)
												},
												{
													id = "armor_icon_magic_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(164, 29.4)
												},
												{
													vertical_align = "middle",
													text_align = "left",
													font_size = 14.4,
													text = "50-90",
													class = "GGLabel",
													id = "damage",
													font_name = "numbers_italic",
													pos = v(50.8, 16),
													size = v(70, 39),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													hidden = true,
													font_size = 14.4,
													text = "Low",
													class = "GGLabel",
													id = "armor",
													font_name = "numbers_italic",
													pos = v(128, -4.4),
													size = v(38.4, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													font_size = 14.4,
													text = "20 s",
													class = "GGLabel",
													id = "lives",
													font_name = "numbers_italic",
													pos = v(208, -7),
													size = v(48, 39),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												}
											}
										},
										{
											id = "infobar_stats_type_2",
											class = "KView",
											hidden = false,
											pos = v(144.8, 6.4),
											children = {
												{
													id = "damage_icon",
													class = "KImageView",
													image_name = "icon_0007",
													pos = v(20, 23.4)
												},
												{
													id = "armor_icon",
													class = "KImageView",
													image_name = "icon_0004",
													pos = v(117.6, 2.2)
												},
												{
													id = "armor_bg_icon_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(140, 7)
												},
												{
													id = "armor_bg_icon_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(149.6, 7)
												},
												{
													id = "armor_bg_icon_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(159.2, 7)
												},
												{
													id = "armor_icon_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(140, 7)
												},
												{
													id = "armor_icon_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(149.6, 7)
												},
												{
													id = "armor_icon_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(159.2, 7)
												},
												{
													class = "KImageView",
													image_name = "icon_0001",
													pos = v(185.8, 0)
												},
												{
													id = "armor_icon_magic",
													class = "KImageView",
													image_name = "icon_0005",
													pos = v(117.6, 24.6)
												},
												{
													id = "armor_bg_icon_magic_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(140, 29.4)
												},
												{
													id = "armor_bg_icon_magic_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(149.6, 29.4)
												},
												{
													id = "armor_bg_icon_magic_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(159.2, 29.4)
												},
												{
													id = "armor_icon_magic_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(140, 31)
												},
												{
													id = "armor_icon_magic_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(149.6, 31)
												},
												{
													id = "armor_icon_magic_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(159.2, 31)
												},
												{
													vertical_align = "middle",
													text_align = "left",
													font_size = 14.4,
													text = "50-90",
													class = "GGLabel",
													id = "damage",
													fit_size = true,
													font_name = "numbers_italic",
													pos = v(40.8, 16.2),
													size = v(80, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													hidden = true,
													font_size = 14.4,
													text = "Low",
													class = "GGLabel",
													id = "armor",
													font_name = "numbers_italic",
													pos = v(128, -4.4),
													size = v(38.4, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													font_size = 14.4,
													text = "20 s",
													class = "GGLabel",
													id = "respawn",
													font_name = "numbers_italic",
													pos = v(208, -8),
													size = v(48, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												}
											}
										},
										{
											id = "infobar_stats_type_3",
											class = "KView",
											hidden = true,
											pos = v(139.2, 6.4),
											children = {
												{
													class = "KImageView",
													image_name = "icon_0007",
													pos = v(-81.6, 24.6)
												},
												{
													class = "KImageView",
													image_name = "icon_0009",
													pos = v(30, 24.6)
												},
												{
													class = "KImageView",
													image_name = "icon_0008",
													pos = v(165, 24.6)
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14.4,
													text = "999",
													class = "GGLabel",
													id = "damage",
													font_name = "hud",
													pos = v(-57.6, 17.4),
													size = v(80, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14.4,
													text = "Slow",
													class = "GGLabel",
													id = "cooldown",
													fit_size = true,
													font_name = "hud",
													pos = v(52, 17),
													size = v(100, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14.4,
													text = "Short",
													class = "GGLabel",
													id = "range",
													fit_size = true,
													font_name = "hud",
													pos = v(190, 17),
													size = v(55, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												}
											}
										},
										{
											id = "infobar_stats_type_4",
											class = "KView",
											hidden = true,
											pos = v(136, 6.4),
											children = {
												{
													id = "damage_icon",
													class = "KImageView",
													image_name = "icon_0007",
													pos = v(-3.2, 24.6)
												},
												{
													id = "armor_icon",
													class = "KImageView",
													image_name = "icon_0004",
													pos = v(102.4, 2.2)
												},
												{
													id = "armor_bg_icon_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(124.8, 7)
												},
												{
													id = "armor_bg_icon_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(134.4, 7)
												},
												{
													id = "armor_bg_icon_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(144, 7)
												},
												{
													id = "armor_icon_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(124.8, 7)
												},
												{
													id = "armor_icon_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(134.4, 7)
												},
												{
													id = "armor_icon_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(144, 7)
												},
												{
													id = "health_icon",
													class = "KImageView",
													image_name = "icon_0006",
													pos = v(-81.6, 24.6)
												},
												{
													id = "armor_icon_magic",
													class = "KImageView",
													image_name = "icon_0005",
													pos = v(102.4, 24.6)
												},
												{
													id = "armor_bg_icon_magic_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(124.8, 29.4)
												},
												{
													id = "armor_bg_icon_magic_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(134.4, 29.4)
												},
												{
													id = "armor_bg_icon_magic_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0003",
													pos = v(144, 29.4)
												},
												{
													id = "armor_icon_magic_01",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(124.8, 31)
												},
												{
													id = "armor_icon_magic_02",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(134.4, 31)
												},
												{
													id = "armor_icon_magic_03",
													class = "KImageView",
													image_name = "gui_bottom_info_armor_0002",
													pos = v(144, 31)
												},
												{
													vertical_align = "middle",
													text_align = "left",
													font_size = 14.4,
													text = "50-90",
													class = "GGLabel",
													id = "damage",
													font_name = "numbers_italic",
													pos = v(19.2, 16.4),
													size = v(64, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													hidden = true,
													font_size = 14.4,
													text = "Low",
													class = "GGLabel",
													id = "armor",
													font_name = "numbers_italic",
													pos = v(128, -4.4),
													size = v(38.4, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													font_size = 14.4,
													text = "20 s",
													class = "GGLabel",
													id = "health",
													font_name = "numbers_italic",
													pos = v(-57.6, 16.4),
													size = v(48, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												}
											}
										},
										{
											id = "infobar_stats_type_5",
											class = "KView",
											hidden = true,
											pos = v(139.2, 6.4),
											children = {
												{
													class = "KImageView",
													image_name = "icon_0010",
													pos = v(-81.6, 24.6)
												},
												{
													class = "KImageView",
													image_name = "icon_0009",
													pos = v(30, 24.6)
												},
												{
													class = "KImageView",
													image_name = "icon_0008",
													pos = v(165, 24.6)
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14.4,
													text = "999",
													class = "GGLabel",
													id = "damage",
													font_name = "numbers_italic",
													pos = v(-57.6, 17),
													size = v(80, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14.4,
													text = "Slow",
													class = "GGLabel",
													id = "cooldown",
													fit_size = true,
													font_name = "hud",
													pos = v(52, 17),
													size = v(100, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14.4,
													text = "Short",
													class = "GGLabel",
													id = "range",
													fit_size = true,
													font_name = "hud",
													pos = v(190, 17),
													size = v(55, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												}
											}
										},
										{
											id = "infobar_stats_type_6",
											class = "KView",
											hidden = true,
											pos = v(102.4, 4.8),
											children = {
												{
													class = "KImageView",
													image_name = "icon_0007",
													pos = v(0, 4.8)
												},
												{
													class = "KImageView",
													image_name = "icon_0009",
													pos = v(115.2, 4.8)
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14.4,
													text = "999",
													class = "GGLabel",
													id = "damage",
													fit_size = true,
													font_name = "numbers_italic",
													pos = v(28.8, 1),
													size = v(100, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												},
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 1,
													font_size = 14.4,
													text = "Slow",
													class = "GGLabel",
													id = "cooldown",
													fit_size = true,
													font_name = "numbers_italic",
													pos = v(147.2, 1),
													size = v(55, 38.4),
													colors = {
														text = {
															255,
															255,
															255,
															255
														}
													}
												}
											}
										},
										{
											id = "infobar_stats_type_9",
											hidden = true,
											class = "KView",
											children = {
												{
													vertical_align = "middle",
													text_align = "left",
													fit_lines = 2,
													line_height = 0.7,
													font_size = 14.4,
													text = "This is a long text.This is a long text.This is a long texttt.",
													class = "GGLabel",
													id = "desc",
													font_name = "hud",
													pos = v(59, 31),
													size = v(325, 16.5),
													colors = {
														text = {
															255,
															219,
															50,
															255
														},
														background = {
															0,
															255,
															0,
															0
														}
													}
												}
											}
										}
									}
								}
							}
						},
						{
							propagate_on_click = true,
							propagate_on_down = true,
							propagate_on_up = true,
							class = "KView",
							id = "hero_portraits_view",
							base_scale = BS_BOTTOM,
							shown_y = ctx.sh - SF.bl,
							hidden_y = ctx.sh + 170,
							pos = v(SF.lb, ctx.sh - SF.bl),
							anchor = v(18, 136),
							size = v(0, 0),
							colors = {
								background = {
									0,
									0,
									255,
									100
								}
							},
							scale = v(0.98, 0.98),
							children = {
								{
									id = "hero_portrait_1",
									class = "HeroPortrait",
									template_name = "game_gui_hero_portrait",
									hidden = true,
									pos = v(0, 0)
								},
								{
									id = "hero_portrait_2",
									class = "HeroPortrait",
									template_name = "game_gui_hero_portrait",
									hidden = true,
									pos = v(110, 0)
								}
							}
						},
						{
							class = "KView",
							propagate_on_up = true,
							propagate_on_down = true,
							propagate_on_click = true,
							id = "powers_view",
							base_scale = BS_BOTTOM,
							pos = v(0, ctx.sh - SF.bl),
							anchor = v(0, 87),
							hidden_y = ctx.sh + 170,
							shown_y = ctx.sh - SF.bl,
							size = v(0, 0),
							colors = {
								background = {
									100,
									0,
									0,
									100
								}
							},
							scale = v(0.98, 0.98),
							children = {
								{
									i18n_desc = "POWER_SUMMON_DESCRIPTION",
									image_name = "power_portrait_reinforcement_0001",
									template_name = "game_gui_power_button",
									power_id = 1,
									can_be_unlocked = true,
									class = "PowerButton",
									id = "power_button_1",
									i18n_title = "POWER_SUMMON_NAME",
									pos = v(0, 0)
								},
								{
									i18n_desc = "POWER_HERO_DESCRIPTION",
									i18n_title = "POWER_HERO_NAME",
									class = "PowerButton",
									template_name = "game_gui_power_button",
									id = "power_button_2",
									image_name = "portraits_power_hero_0001",
									power_id = 2,
									pos = v(98, 0)
								},
								{
									i18n_desc = "POWER_HERO_DESCRIPTION",
									i18n_title = "POWER_HERO_NAME",
									class = "PowerButton",
									template_name = "game_gui_power_button",
									id = "power_button_3",
									image_name = "portraits_power_hero_0001",
									power_id = 3,
									pos = v(196, 0)
								}
							}
						},
						{
							class = "KView",
							propagate_on_up = true,
							propagate_on_down = true,
							propagate_on_click = true,
							hidden = false,
							id = "bag_view",
							base_scale = v(BS_BOTTOM.x, BS_BOTTOM.y),
							pos = v(ctx.sw - SF.rb, ctx.sh - SF.br),
							anchor = v(302, 117),
							shown_y = ctx.sh - SF.br,
							size = v(0, 0),
							hidden_y = ctx.sh + 170,
							children = {
								{
									item_id = 1,
									class = "BagItemButton",
									template_name = "game_gui_bag_item_button",
									id = "bag_item_1",
									pos = v(-98, 0),
									anchor = v(0, 0)
								},
								{
									item_id = 2,
									class = "BagItemButton",
									template_name = "game_gui_bag_item_button",
									id = "bag_item_2",
									pos = v(98, 0),
									anchor = v(0, 0)
								},
								{
									item_id = 3,
									class = "BagItemButton",
									template_name = "game_gui_bag_item_button",
									id = "bag_item_3",
									pos = v(0, 0),
									anchor = v(0, 0)
								},
								{
									item_id = 4,
									class = "BagItemButton",
									template_name = "game_gui_bag_item_button",
									id = "bag_item_4",
									pos = v(-196, 0),
									anchor = v(0, 0)
								},
								{
									item_id = 5,
									class = "BagItemButton",
									template_name = "game_gui_bag_item_button",
									id = "bag_item_5",
									pos = v(196, 0),
									anchor = v(0, 0)
								}
							}
						},
						{
							propagate_on_down = true,
							class = "KView",
							propagate_on_up = true,
							hidden = false,
							propagate_on_click = true,
							icon_space_y = 2,
							id = "notification_queue_view",
							pos = v(0, 0),
							size = v(96, 300),
							base_scale = ctx.bs.noti_icons,
							colors = {
								background = {
									0,
									0,
									0,
									0
								}
							}
						},
						{
							id = "alerts_view",
							propagate_on_down = true,
							class = "AlertsView",
							propagate_on_up = true,
							hidden = true,
							propagate_on_click = true,
							size = v(592, 320)
						},
						{
							class = "KView",
							hidden = true,
							id = "overlay_view",
							size = v(ctx.sw, ctx.sh),
							colors = {
								background = {
									0,
									0,
									0,
									0
								}
							}
						},
						{
							propagate_on_click = true,
							propagate_on_down = true,
							class = "KView",
							propagate_on_up = true,
							id = "item_fx_container",
							pos = v(0, 0),
							size = v(ctx.sw, ctx.sh)
						},
						{
							id = "mouse_pointer",
							hidden = true,
							class = "MousePointer"
						}
					}
				},
				{
					propagate_on_up = true,
					propagate_on_down = true,
					class = "KView",
					id = "layer_gui_top",
					propagate_on_click = true,
					size = v(ctx.sw, ctx.sh),
					children = {
						{
							class = "KView",
							propagate_on_down = false,
							propagate_drag = false,
							id = "modal_bg_transparent_view",
							hidden = true,
							size = v(ctx.sw, ctx.sh),
							colors = {
								background = {
									0,
									0,
									0,
									160
								}
							}
						},
						{
							hidden_y = 0,
							class = "KView",
							hidden = true,
							id = "curtain_top_view",
							pos = v(-1, 0),
							anchor = v(0, ctx.sh / 5),
							size = v(ctx.sw + 2, ctx.sh / 5),
							shown_y = ctx.OVT(ctx.sh / 10, "tablet", ctx.sh / 13, "desktop", ctx.sh / 13),
							colors = {
								background = {
									0,
									0,
									0,
									255
								}
							}
						},
						{
							class = "KView",
							hidden = true,
							id = "curtain_bottom_view",
							pos = v(-1, ctx.sh),
							anchor = v(0, 0),
							size = v(ctx.sw + 2, ctx.sh / 5),
							shown_y = ctx.sh - ctx.OVT(ctx.sh / 10, "tablet", ctx.sh / 13, "desktop", ctx.sh / 13),
							hidden_y = ctx.sh,
							colors = {
								background = {
									0,
									0,
									0,
									255
								}
							}
						},
						{
							class = "AchievementView",
							shown_y = 15,
							id = "achievement_view",
							template_name = "ingame_achievement_ui",
							hidden = true,
							pos = v(ctx.sw / 2, -90 * BS_ACHIEVEMENT.y),
							anchor = v(150.5, 0),
							hidden_y = -90 * BS_ACHIEVEMENT.y,
							base_scale = BS_ACHIEVEMENT
						},
						{
							hidden = true,
							class = "KView",
							id = "victory_view",
							size = v(ctx.sw, ctx.sh),
							pos = v(0, 0),
							children = {
								{
									id = "group_victory",
									class = "VictoryView",
									template_name = "victory_defeat",
									pos = v(ctx.sw / 2, ctx.sh / 2),
									anchor = v(ctx.sw / 2, ctx.sh / 2),
									base_scale = BS_VICTORY
								}
							}
						},
						{
							hidden = true,
							class = "KView",
							id = "defeat_view",
							size = v(ctx.sw, ctx.sh),
							pos = v(0, 0),
							children = {
								{
									id = "group_defeat",
									class = "DefeatView",
									template_name = "victory_defeat",
									pos = v(ctx.sw / 2, ctx.sh / 2),
									anchor = v(ctx.sw / 2, ctx.sh / 2),
									base_scale = BS_DEFEAT
								}
							}
						},
						{
							class = "GG5PopUpIngameOptions",
							template_name = "popup_ingame_options",
							id = "popup_ingame_options",
							WHEN = ctx.is_mobile,
							pos = v(ctx.sw / 2, ctx.sh / 2),
							size = v(ctx.sw, ctx.sh),
							base_scale = BS_OPTIONS
						},
						{
							context = "ingame",
							template_name = "popup_options_desktop",
							class = "GG5PopUpOptionsDesktop",
							id = "popup_ingame_options",
							UNLESS = ctx.is_mobile,
							pos = v(ctx.sw / 2, ctx.sh / 2),
							size = v(ctx.sw, ctx.sh)
						},
						{
							hidden = true,
							class = "GG5PopupIngameShop",
							id = "popup_ingame_shop_container",
							WHEN = ctx.has_iap,
							size = v(ctx.sw, ctx.sh),
							pos = v(ctx.sw / 2, ctx.sh / 2),
							base_scale = BS_SHOP_INGAME,
							children = {
								{
									hidden = false,
									class = "GG5ViewIngameShopItem",
									id = "popup_ingame_shop_item",
									size = v(ctx.sw, ctx.sh),
									pos = v(ctx.sw / 2, ctx.sh / 2),
									base_scale = BS_SHOP_INGAME,
									children = {
										{
											class = "KView",
											id = "group_item_portraits",
											transition = "down",
											pos = v(0, 0),
											children = {
												{
													id = "group_item_portrait_01",
													class = "KView",
													template_name = "group_ingame_shop_item_portrait",
													pos = v(-376.15, -384.9)
												},
												{
													id = "group_item_portrait_02",
													class = "KView",
													template_name = "group_ingame_shop_item_portrait",
													pos = v(-1.2, -384.9)
												},
												{
													id = "group_item_portrait_03",
													class = "KView",
													template_name = "group_ingame_shop_item_portrait",
													pos = v(373.75, -384.9)
												}
											}
										},
										{
											id = "group_ingame_shop_button_ok_item",
											class = "KView",
											pos = v(ctx.sw / 2, ctx.sh / 2),
											children = {
												{
													id = "button_ingame_shop_confirm_ok_item",
													class = "GG5Button",
													template_name = "button_ingame_shop_confirm_ok",
													text_key = "BUTTON_DONE",
													pos = v(-SF.r - 101.2, -SF.b - 35.5),
													scale = v(1, 1)
												}
											}
										}
									}
								},
								{
									hidden = false,
									class = "GG5ViewIngameShopGems",
									id = "popup_ingame_shop_gems",
									size = v(ctx.sw, ctx.sh),
									pos = v(0, ctx.sh / 2),
									base_scale = BS_SHOP_INGAME,
									children = {
										{
											id = "group_shop_room_cards_container",
											class = "GG5ViewIngameShopGemsContainer",
											pos = v(0, ctx.sh / 2)
										}
									}
								},
								{
									hidden = false,
									class = "KView",
									id = "popup_ingame_shop_gems_button",
									size = v(ctx.sw, ctx.sh),
									pos = v(ctx.sw / 2, ctx.sh / 2),
									base_scale = BS_SHOP_INGAME,
									children = {
										{
											class = "KView",
											id = "group_ingame_shop_button_ok_gems",
											transition = "up",
											pos = v(ctx.sw / 2, ctx.sh / 2),
											children = {
												{
													class = "GG5Button",
													template_name = "button_ingame_shop_confirm_ok",
													id = "button_ingame_shop_confirm_ok_gems",
													pos = v(-SF.r - 101.2, -SF.b - 35.5),
													scale = v(1, 1)
												}
											}
										}
									}
								},
								{
									template_name = "group_ingame_shop_item_gems",
									class = "KView",
									id = "group_item_gems",
									transition = "down",
									pos = v(ctx.safe_frame.l, 0),
									base_scale = BS_SHOP_INGAME
								}
							}
						},
						{
							class = "GG5PopUpMessage",
							template_name = "popup_message",
							id = "popup_message",
							pos = v(ctx.sw / 2, 362),
							size = v(ctx.sw, ctx.sh),
							base_scale = BS_OPTIONS
						},
						{
							hidden = true,
							class = "GG5PopUpPurchasing",
							template_name = "popup_purchasing",
							id = "processing_view",
							pos = v(ctx.sw / 2, 362),
							size = v(ctx.sw, ctx.sh)
						}
					}
				},
				{
					id = "remote_balance_view",
					class = "RBView",
					template_name = "remote_balance_view",
					hidden = true,
					WHEN = ctx.remote_balance
				}
			}
		}
	}
}
