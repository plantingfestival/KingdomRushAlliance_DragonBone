-- chunkname: @./all-desktop/data/kui_templates/game_editor_gui.lua

local function v(x, y)
	return {
		x = x,
		y = y
	}
end

return {
	class = "KWindow",
	r = 0,
	alpha = 1,
	clip = false,
	id = "window",
	anchor = {
		x = 0,
		y = 0
	},
	colors = {
		background = {
			0,
			0,
			0,
			0
		}
	},
	disabled_tint_color = {
		150,
		150,
		150,
		255
	},
	origin = {
		x = 0,
		y = 0
	},
	padding = {
		x = 0,
		y = 0
	},
	pos = {
		x = 0,
		y = 0
	},
	scale = {
		x = 1,
		y = 1
	},
	size = {
		x = 1440,
		y = 1080
	},
	children = {
		{
			id = "picker",
			class = "KEPicker",
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
			can_drag = true,
			class = "KView",
			id = "tools",
			pos = {
				x = 100,
				y = 100
			},
			size = {
				x = 200,
				y = 500
			},
			colors = {
				background = {
					200,
					200,
					200,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "tools_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "KR EDITOR",
					class = "KLabel",
					id = "tools_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							class = "KEPointerPos",
							id = "tools_pointer_pos"
						},
						{
							class = "KESep",
							title = "Level"
						},
						{
							id = "tools_level_name",
							title = "Level name",
							class = "KEPropNum",
							value = 1
						},
						{
							id = "tools_game_mode",
							title = "Game mode",
							class = "KEPropNum",
							value = 1
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "tools_save",
									class = "KEButton",
									title = "save",
									size = {
										x = 86,
										y = 20
									}
								},
								{
									id = "tools_load",
									class = "KEButton",
									title = "load",
									size = {
										x = 86,
										y = 20
									}
								}
							}
						},
						{
							id = "tools_undo",
							title = "undo",
							class = "KEButton"
						},
						{
							class = "KESep",
							title = "Tools"
						},
						{
							id = "tools_general",
							title = "general",
							class = "KEButton"
						},
						{
							id = "tools_entities",
							title = "entities",
							class = "KEButton"
						},
						{
							id = "tools_paths",
							title = "paths",
							class = "KEButton"
						},
						{
							id = "tools_grid",
							title = "grid",
							class = "KEButton"
						},
						{
							id = "tools_nav",
							title = "nav",
							class = "KEButton"
						},
						{
							id = "tools_particles",
							title = "particles",
							class = "KEButton"
						},
						{
							class = "KESep",
							title = "Toggles"
						},
						{
							id = "tg_safe_frame",
							title = "Toggle safe frame",
							class = "KEButton"
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "general",
			pos = {
				x = 300,
				y = 100
			},
			size = {
				x = 200,
				y = 200
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "general_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "GENERAL",
					class = "KLabel",
					id = "general_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "entities",
			pos = {
				x = 500,
				y = 100
			},
			size = {
				x = 200,
				y = 500
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "entities_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "ENTITIES",
					class = "KLabel",
					id = "entities_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					id = "entities_selected",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							id = "entities_delete",
							title = "delete",
							class = "KEButton"
						},
						{
							id = "entities_duplicate",
							title = "duplicate",
							class = "KEButton"
						},
						{
							id = "entities_id",
							title = "Id",
							class = "KEProp",
							prop_name = "id"
						},
						{
							id = "entities_template",
							title = "Template",
							class = "KEProp",
							prop_name = "template_name"
						},
						{
							id = "entities_pos",
							title = "pos",
							class = "KEPropCoords",
							prop_name = "pos"
						},
						{
							id = "entities_custom_props",
							style = "vertical",
							class = "KELayout"
						}
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					id = "entities_deselected",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "entities_show",
									title = "show",
									class = "KEButton",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "entities_hide",
									title = "hide",
									class = "KEButton",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							id = "entities_insert",
							title = "insert",
							class = "KEButton"
						},
						{
							id = "entities_insert_template",
							title = "Template",
							class = "KEProp",
							editable = true
						},
						{
							id = "entities_search",
							title = "search",
							class = "KEButton"
						},
						{
							class = "KEList",
							id = "entities_search_suggestions"
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "paths",
			pos = {
				x = 700,
				y = 100
			},
			size = {
				x = 200,
				y = 700
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "paths_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "PATHS",
					class = "KLabel",
					id = "paths_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					id = "paths_props",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							style = "vertical",
							class = "KELayout",
							id = "paths_list_section",
							pos = {
								x = 10,
								y = 30
							},
							children = {
								{
									class = "KESep",
									title = "Paths list"
								},
								{
									id = "paths_list",
									class = "KEList",
									size = {
										x = 0,
										y = 80
									}
								},
								{
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "path_create",
											title = "create",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										},
										{
											id = "path_remove",
											title = "remove",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										}
									}
								},
								{
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "path_move_up",
											title = "move up",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										},
										{
											id = "path_move_down",
											title = "move down",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										}
									}
								},
								{
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "path_duplicate",
											title = "duplicate",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										},
										{
											id = "path_flip",
											title = "flip",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										}
									}
								},
								{
									id = "path_preview",
									title = "preview points",
									class = "KEButton"
								},
								{
									id = "path_active",
									class = "KEPropBool",
									value = true,
									title = "active",
									inactive_title = "inactive"
								},
								{
									id = "path_connects_to",
									title = "Connects to",
									class = "KEPropNum",
									value = -1
								}
							}
						},
						{
							style = "vertical",
							class = "KELayout",
							id = "paths_node_selected",
							pos = {
								x = 10,
								y = 30
							},
							children = {
								{
									class = "KESep",
									title = "Node"
								},
								{
									id = "path_node_id",
									title = "Node id",
									class = "KEProp"
								},
								{
									id = "path_node_pos",
									title = "pos",
									class = "KEPropCoords"
								},
								{
									id = "path_node_width",
									title = "node width",
									class = "KEPropNum",
									value = 20
								},
								{
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "path_node_subdivide",
											title = "subdivide",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										},
										{
											id = "path_node_extend",
											title = "extend",
											class = "KEButton",
											size = {
												x = 88,
												y = 20
											}
										}
									}
								},
								{
									id = "path_node_remove",
									title = "remove",
									class = "KEButton"
								}
							}
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "grid",
			pos = {
				x = 900,
				y = 100
			},
			size = {
				x = 200,
				y = 500
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "grid_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "GRID",
					class = "KLabel",
					id = "grid_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					pos = {
						x = 10,
						y = 30
					},
					children = {
						{
							class = "KECellInfo",
							id = "cell_info"
						},
						{
							class = "KESep",
							title = "Terrains"
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_type_none",
									class = "KEButton",
									title = "None",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "paint_type_land",
									class = "KEButton",
									title = "Land",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_type_water",
									class = "KEButton",
									title = "Water",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "paint_type_cliff",
									class = "KEButton",
									title = "Cliff",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							class = "KESep",
							title = "Flags"
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_flag_shallow",
									class = "KEButton",
									title = "shallow",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "paint_flag_nowalk",
									class = "KEButton",
									title = "no-walk",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_flag_faerie",
									class = "KEButton",
									title = "faerie",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "paint_flag_ice",
									class = "KEButton",
									title = "ice",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "paint_flag_flying_nw",
									class = "KEButton",
									title = "flying-nw",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							class = "KESep",
							title = "Brush size"
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "brush_size_inc",
									class = "KEButton",
									title = "+",
									size = {
										x = 88,
										y = 20
									}
								},
								{
									id = "brush_size_dec",
									class = "KEButton",
									title = "-",
									size = {
										x = 88,
										y = 20
									}
								}
							}
						},
						{
							class = "KESep",
							title = "Grid"
						},
						{
							style = "vertical",
							class = "KELayout",
							children = {
								{
									prop_name = "grid_size",
									class = "KEPropCoords",
									id = "grid_size",
									title = "size (cells)",
									step = 2
								},
								{
									prop_name = "grid_offset",
									class = "KEPropCoords",
									id = "grid_offset",
									title = "offset (px)",
									step = 16
								}
							}
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "nav",
			pos = {
				x = 300,
				y = 100
			},
			size = {
				x = 200,
				y = 440
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "nav_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "NAV MESH",
					class = "KLabel",
					id = "nav_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 180,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					style = "vertical",
					class = "KELayout",
					pos = v(10, 30),
					children = {
						{
							class = "KESep",
							title = "mode override"
						},
						{
							id = "nav_mode_override_active",
							class = "KEPropBool",
							value = true,
							title = "mode mesh",
							inactive_title = "use default mesh"
						},
						{
							id = "nav_sel_id",
							title = "selected id",
							class = "KEProp",
							prop_name = "nav_sel_id"
						},
						{
							id = "nav_holder_id",
							title = "holder id",
							class = "KEProp",
							prop_name = "nav_holder_id"
						},
						{
							class = "KESep",
							title = "top/left/right/bottom"
						},
						{
							class = "KEEnum",
							id = "nav_id_top"
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "nav_id_left",
									style = "half",
									class = "KEEnum"
								},
								{
									id = "nav_id_right",
									style = "half",
									class = "KEEnum"
								}
							}
						},
						{
							class = "KEEnum",
							id = "nav_id_bottom"
						},
						{
							class = "KESep",
							title = "actions"
						},
						{
							id = "nav_adds_missing_numbers",
							title = "adds missing numbers",
							class = "KEButton"
						},
						{
							id = "nav_nearest_sel",
							title = "nearest selected",
							class = "KEButton"
						},
						{
							id = "nav_nearest_all",
							title = "nearest all",
							class = "KEButton"
						},
						{
							id = "nav_clear_all",
							title = "clear all",
							class = "KEButton"
						},
						{
							id = "nav_renumber_holders",
							title = "renumber (WARN!)",
							class = "KEButton"
						}
					}
				}
			}
		},
		{
			can_drag = true,
			class = "KView",
			id = "particles",
			pos = {
				x = 900,
				y = 100
			},
			size = {
				x = 400,
				y = 640
			},
			colors = {
				background = {
					220,
					220,
					220,
					255
				}
			},
			children = {
				{
					text = "X",
					class = "KButton",
					id = "particles_close",
					colors = {
						background = {
							120,
							120,
							120,
							255
						}
					},
					size = {
						x = 20,
						y = 20
					},
					pos = {
						x = 0,
						y = 0
					},
					text_offset = {
						x = 0,
						y = 4
					}
				},
				{
					text = "PARTICLES",
					class = "KLabel",
					id = "particles_title",
					text_align = "left",
					colors = {
						background = {
							180,
							180,
							180,
							255
						}
					},
					size = {
						x = 380,
						y = 20
					},
					pos = {
						x = 20,
						y = 0
					},
					text_offset = {
						x = 10,
						y = 4
					}
				},
				{
					text = "",
					class = "KLabel",
					id = "ps_stats",
					text_align = "left",
					pos = v(10, 30),
					size = {
						x = 380,
						y = 20
					}
				},
				{
					style = "horizontal",
					class = "KELayout",
					id = "particles_data",
					pos = {
						x = 10,
						y = 50
					},
					children = {
						{
							style = "vertical",
							class = "KELayout",
							id = "particles_data_left",
							pos = {
								x = 10,
								y = 30
							},
							children = {
								{
									id = "ps_list",
									class = "KEList",
									size = {
										x = 0,
										y = 60
									}
								},
								{
									id = "particles_data_buttons",
									style = "horizontal",
									class = "KELayout",
									children = {
										{
											id = "ps_create",
											title = "add",
											class = "KEButton",
											size = {
												x = 40,
												y = 20
											}
										},
										{
											id = "ps_remove",
											title = "rem",
											class = "KEButton",
											size = {
												x = 40,
												y = 20
											}
										},
										{
											id = "ps_copy",
											title = "copy",
											class = "KEButton",
											size = {
												x = 40,
												y = 20
											}
										},
										{
											id = "ps_paste",
											title = "paste",
											class = "KEButton",
											size = {
												x = 40,
												y = 20
											}
										}
									}
								},
								{
									prop_name = "emit",
									class = "KEPropBool",
									value = true,
									title = "running",
									inactive_title = "paused"
								},
								{
									prop_name = "emission_rate",
									class = "KEPropNum",
									value = 1,
									title = "emission rate parts/sec",
									step = 5,
									range = {
										0,
										100
									}
								},
								{
									title = "area spread (x,y)",
									class = "KEPropCoords",
									prop_name = "emit_area_spread",
									ranges = {
										{
											-800,
											800
										},
										{
											-400,
											400
										}
									}
								},
								{
									prop_name = "emit_direction",
									class = "KEPropNum",
									value = 0,
									title = "direction (rad)",
									range = {
										-math.pi,
										math.pi
									},
									step = math.pi / 18
								},
								{
									prop_name = "emit_spread",
									class = "KEPropNum",
									value = 0,
									title = "direction spread angle",
									range = {
										0,
										math.pi
									},
									step = math.pi / 18
								},
								{
									title = "emit offset (x,y)",
									class = "KEPropCoords",
									prop_name = "emit_offset",
									ranges = {
										{
											-100,
											100
										},
										{
											-100,
											100
										}
									}
								},
								{
									prop_name = "emit_rotation",
									class = "KEPropNum",
									nil_value = 0,
									value = 0,
									title = "rotation angle",
									range = {
										-math.pi,
										math.pi
									},
									step = math.pi / 18
								},
								{
									prop_name = "emit_rotation_spread",
									class = "KEPropNum",
									value = 0,
									title = "rotation spread (rad)",
									range = {
										0,
										math.pi
									},
									step = math.pi / 18
								},
								{
									prop_name = "emit_speed",
									class = "KEPropPair",
									title = "speed (min,max)",
									step = 5,
									ranges = {
										{
											-150,
											150
										},
										{
											-150,
											150
										}
									}
								},
								{
									prop_name = "spin",
									class = "KEPropPair",
									title = "spin (min,max)",
									step = 0.5,
									ranges = {
										{
											-50,
											50
										},
										{
											-50,
											50
										}
									}
								}
							}
						},
						{
							style = "vertical",
							class = "KELayout",
							id = "particles_data_right",
							pos = {
								x = 10,
								y = 30
							},
							children = {
								{
									id = "ps_images",
									class = "KEList",
									size = {
										x = 0,
										y = 90
									}
								},
								{
									id = "ps_animated",
									prop_name = "animated",
									class = "KEPropBool",
									value = false,
									title = "animated",
									inactive_title = "single frame"
								},
								{
									prop_name = "loop",
									class = "KEPropBool",
									value = false,
									title = "loop ani",
									inactive_title = "one time ani"
								},
								{
									title = "anchor",
									class = "KEPropCoords",
									prop_name = "anchor",
									ranges = {
										{
											0,
											1
										},
										{
											0,
											1
										}
									}
								},
								{
									prop_name = "alphas",
									class = "KEPropTrio",
									title = "alphas",
									value_format = "%d",
									step = 10,
									ranges = {
										{
											0,
											255
										},
										{
											0,
											255
										},
										{
											0,
											255
										}
									}
								},
								{
									title = "particle life (min,max)",
									class = "KEPropPair",
									prop_name = "particle_lifetime",
									ranges = {
										{
											0,
											20
										},
										{
											0,
											20
										}
									}
								},
								{
									prop_name = "emit_duration",
									class = "KEPropNum",
									nil_value = 0,
									value = 0,
									title = "emission duration",
									range = {
										0,
										20
									}
								},
								{
									prop_name = "scale_var",
									class = "KEPropPair",
									title = "initial scale (min,max)",
									step = 0.1,
									ranges = {
										{
											-10,
											10
										},
										{
											-10,
											10
										}
									}
								},
								{
									prop_name = "scales_x",
									class = "KEPropTrio",
									title = "scales x",
									ranges = {
										{
											-10,
											10
										},
										{
											-10,
											10
										},
										{
											-10,
											10
										}
									},
									nil_value = {
										0,
										0,
										0
									}
								},
								{
									prop_name = "scales_y",
									class = "KEPropTrio",
									title = "scales y",
									ranges = {
										{
											-10,
											10
										},
										{
											-10,
											10
										},
										{
											-10,
											10
										}
									},
									nil_value = {
										0,
										0,
										0
									}
								},
								{
									prop_name = "scale_same_aspect",
									class = "KEPropBool",
									value = true,
									title = "same scale x/y",
									inactive_title = "different scale x/y"
								}
							}
						}
					}
				}
			}
		}
	}
}
