-- chunkname: @./kr5/data/kui_templates/game_gui_bag_item_button.lua

return {
	class = "BagItemButton",
	children = {
		{
			id = "item",
			class = "KImageView",
			image_name = "item_icons_cluster_bomb",
			pos = v(21, 21)
		},
		{
			id = "bag_item_purchase_hover",
			class = "KImageView",
			image_name = "ingame_ui_items_button_frame_buy_hover",
			pos = v(-15, -7)
		},
		{
			id = "bag_item_purchase",
			class = "KImageView",
			image_name = "ingame_ui_items_button_frame_buy",
			pos = v(0, -2)
		},
		{
			hidden = true,
			class = "KImageView",
			id = "hover",
			image_name = "ingame_ui_items_button_frame_highlight",
			pos = v(-13, -15)
		},
		{
			hidden = true,
			class = "KImageView",
			id = "hover_selected",
			image_name = "ingame_ui_items_button_frame_hover",
			pos = v(-13, -7)
		},
		{
			hidden = true,
			class = "KImageView",
			id = "selected",
			image_name = "ingame_ui_items_button_frame_selected",
			pos = v(0, -2)
		},
		{
			class = "KImageView",
			id = "bag_item_door",
			image_name = "ingame_ui_items_button_doors_0001",
			pos = v(14, 12),
			animation = {
				hide_at_end = true,
				prefix = "ingame_ui_items_button_doors",
				to = 13
			}
		},
		{
			id = "bag_item_button",
			default_image_name = "ingame_ui_items_button_frame",
			class = "GGImageButton",
			disabled_image_name = "ingame_ui_items_button_frame"
		},
		{
			id = "bag_item_qty_back",
			class = "KImageView",
			image_name = "ingame_ui_items_button_number_frame",
			pos = v(16, 0)
		},
		{
			text_align = "center",
			font_size = 20,
			shader_margin = 8,
			text = "6",
			class = "GGShaderLabel",
			id = "bag_item_qty",
			font_name = "numbers_italic",
			pos = v(44, 89),
			size = v(35, 14),
			colors = {
				text = {
					255,
					255,
					255,
					255
				}
			},
			shaders = {
				"p_outline",
				"p_glow"
			},
			shader_args = {
				{
					thickness = 1,
					outline_color = {
						0,
						0,
						0,
						1
					}
				},
				{
					thickness = 1,
					glow_color = {
						0,
						0,
						0,
						1
					}
				}
			}
		}
	}
}
