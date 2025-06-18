-- chunkname: @./all-desktop/data/kui_templates/gamertag_view.lua

return {
	hidden = false,
	class = "GamertagView",
	id = "gamertag_view",
	pos = {
		y = 30,
		x = ctx.right_margin - 30
	},
	size = {
		x = 300,
		y = 80
	},
	anchor = {
		x = 300,
		y = 0
	},
	children = {
		{
			vertical_align = "middle",
			id = "gamertag_label",
			fit_lines = 1,
			font_size = 28,
			text_align = "center",
			class = "GGLabel",
			line_height = 0.9,
			text = "Gamertag goes here",
			hidden = true,
			font_name = "sans_bold",
			pos = {
				x = 10,
				y = 0
			},
			size = {
				x = 280,
				y = 60
			},
			anchor = {
				x = 0,
				y = 0
			},
			colors = {
				text = {
					255,
					255,
					153,
					200
				},
				background = {
					42,
					34,
					31,
					130
				}
			},
			shape = {
				name = "rectangle",
				args = {
					"fill",
					-10,
					0,
					300,
					60,
					10,
					10
				}
			}
		},
		{
			vertical_align = "middle-caps",
			id = "gamertag_symbol",
			fit_lines = 1,
			font_size = 50,
			text_align = "center",
			class = "GGLabel",
			line_height = 0.9,
			text = "",
			hidden = true,
			font_name = "symbols_xbox",
			pos = {
				x = 220,
				y = 0
			},
			size = {
				x = 80,
				y = 80
			},
			anchor = {
				x = 0,
				y = 0
			},
			colors = {
				text = {
					255,
					255,
					153,
					200
				},
				background = {
					42,
					34,
					31,
					130
				}
			},
			text_offset = {
				x = 0,
				y = 10
			},
			shape = {
				name = "rectangle",
				args = {
					"fill",
					0,
					0,
					80,
					80,
					10,
					10
				}
			}
		}
	}
}
