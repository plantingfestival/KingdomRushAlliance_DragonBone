-- chunkname: @./kr5/data/kui_templates/game_gui_tower_menu_tooltip.lua

return {
	propagate_on_up = true,
	propagate_on_down = true,
	class = "TowerMenuTooltip",
	propagate_on_click = true,
	size = v(220, 352),
	children = {
		{
			id = "bg",
			propagate_on_down = true,
			class = "GG9SlicesView",
			propagate_on_up = true,
			slices_prefix = "tooltip_bg_slices",
			propagate_on_click = true,
			size = v(220, 352)
		},
		{
			vertical_align = "base",
			text_align = "left",
			fit_lines = 1,
			font_size = 18,
			class = "GGLabel",
			id = "title",
			font_name = "tooltip",
			pos = v(16, 28.8),
			size = v(215, 30.4),
			colors = {
				text = {
					190,
					254,
					5,
					255
				}
			}
		},
		{
			vertical_align = "top",
			text_align = "left",
			font_size = 16,
			line_height = 0.85,
			class = "GGLabel",
			id = "desc",
			font_name = "tooltip",
			pos = v(16, 32.2),
			size = v(215, 96),
			colors = {
				text = {
					253,
					254,
					250,
					255
				}
			}
		},
		{
			propagate_on_click = true,
			propagate_on_down = true,
			class = "KView",
			id = "bottom_views",
			propagate_on_up = true,
			pos = v(16, 32),
			size = v(220, 43),
			children = {
				{
					propagate_on_up = true,
					propagate_on_down = true,
					class = "KView",
					id = "bottom_type_barrack",
					propagate_on_click = true,
					children = {
						{
							vertical_align = "middle",
							image_name = "tooltip_icons_0006",
							font_size = 14,
							text_align = "left",
							line_height = 0.9,
							class = "GGLabel",
							id = "health",
							font_name = "numbers_italic",
							pos = v(0, 6.4),
							size = v(76, 32),
							scale = v(1.1, 1.1),
							text_offset = v(24, -5.2),
							colors = {
								text = {
									253,
									254,
									250,
									255
								}
							}
						},
						{
							vertical_align = "middle",
							image_name = "tooltip_icons_0007",
							font_size = 14,
							text_align = "left",
							line_height = 0.9,
							class = "GGLabel",
							id = "damage",
							font_name = "numbers_italic",
							pos = v(64, 6.4),
							size = v(76, 32),
							scale = v(1.1, 1.1),
							text_offset = v(20, -5.2),
							colors = {
								text = {
									253,
									254,
									250,
									255
								}
							}
						},
						{
							vertical_align = "middle",
							image_name = "tooltip_icons_0004",
							font_size = 14,
							text_align = "left",
							line_height = 0.9,
							class = "GGLabel",
							id = "armor",
							font_name = "body",
							pos = v(140, 6.4),
							size = v(76, 32),
							scale = v(1.1, 1.1),
							text_offset = v(24, -5.2),
							colors = {
								text = {
									253,
									254,
									250,
									255
								}
							}
						}
					}
				},
				{
					propagate_on_up = true,
					propagate_on_down = true,
					class = "KView",
					id = "bottom_type_tower",
					propagate_on_click = true,
					children = {
						{
							vertical_align = "middle",
							image_name = "tooltip_icons_0007",
							font_size = 14,
							text_align = "left",
							line_height = 0.9,
							class = "GGLabel",
							id = "damage",
							font_name = "numbers_italic",
							pos = v(-5, 6.4),
							size = v(96, 32),
							scale = v(1.1, 1.1),
							text_offset = v(24, -5.2),
							colors = {
								text = {
									253,
									254,
									250,
									255
								}
							}
						},
						{
							vertical_align = "middle",
							image_name = "tooltip_icons_0009",
							font_size = 14,
							text_align = "left",
							fit_size = true,
							line_height = 0.9,
							class = "GGLabel",
							id = "cooldown",
							font_name = "body",
							pos = v(91, 6.4),
							size = v(100, 32),
							scale = v(1.1, 1.1),
							text_offset = v(24, -5.2),
							colors = {
								text = {
									253,
									254,
									250,
									255
								}
							}
						}
					}
				},
				{
					propagate_on_up = true,
					propagate_on_down = true,
					class = "KView",
					id = "bottom_type_phrase",
					propagate_on_click = true,
					children = {
						{
							vertical_align = "top",
							text_align = "left",
							font_size = 14,
							line_height = 0.85,
							class = "GGLabel",
							id = "phrase",
							font_name = "tooltip",
							pos = v(0, 6.4),
							size = v(220, 32),
							colors = {
								text = {
									170,
									160,
									125,
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
