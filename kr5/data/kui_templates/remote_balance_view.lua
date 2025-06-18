-- chunkname: @./kr5/data/kui_templates/remote_balance_view.lua

local TW = ctx.rb_prop_w
local BH = ctx.rb_prop_h
local M = ctx.rb_m
local FN = ctx.rb_font_name
local FS = ctx.rb_font_size
local H = 450

return {
	can_drag = "true",
	class = "RBView",
	id = "remote_balance_view",
	pos = v(30, 30),
	size = v(TW + 2 * M, H + M),
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
			class = "KButton",
			text = "X",
			id = "rb_close",
			font_name = FN,
			font_size = FS,
			colors = {
				background = {
					120,
					120,
					120,
					255
				}
			},
			size = {
				x = BH,
				y = BH
			},
			pos = {
				x = 0,
				y = 0
			},
			text_offset = {
				x = 0,
				y = 6
			}
		},
		{
			class = "KLabel",
			text_align = "left",
			text = "REMOTE BALANCE",
			id = "rb_title",
			font_name = FN,
			font_size = FS,
			colors = {
				background = {
					180,
					180,
					180,
					255
				}
			},
			size = {
				x = TW - BH + 2 * M,
				y = BH
			},
			pos = {
				y = 0,
				x = BH
			},
			text_offset = {
				x = 10,
				y = 6
			}
		},
		{
			id = "rb_progress",
			style = "vertical",
			class = "KELayout",
			hidden = false,
			pos = v(M, BH + M),
			children = {
				{
					text = "DOWNLOADING...",
					class = "KLabel",
					font_name = FN,
					font_size = FS,
					size = v(TW, BH)
				},
				{
					text = "",
					class = "KLabel",
					id = "rb_progress_error",
					font_name = FN,
					font_size = FS,
					size = v(TW, BH)
				}
			}
		},
		{
			id = "rb_ui",
			class = "KView",
			hidden = true,
			pos = v(0, BH + M),
			children = {
				{
					style = "horizontal",
					class = "KELayout",
					id = "rb_tabs",
					pos = v(M, 0),
					children = {
						{
							class = "KEButton",
							id = "rb_tab_waves",
							title = "WAVES",
							tab = "rb_waves",
							size = v(100, BH)
						},
						{
							class = "KEButton",
							id = "rb_tab_balance",
							title = "BALANCE",
							tab = "rb_balance",
							size = v(100, BH)
						},
						{
							class = "KEButton",
							id = "rb_tab_errors",
							title = "ERRORS",
							tab = "rb_errors",
							size = v(100, BH)
						}
					}
				},
				{
					id = "rb_waves",
					style = "vertical",
					class = "KELayout",
					hidden = false,
					pos = v(M, BH + M),
					children = {
						{
							text = "WAVES CONFIGURATION",
							class = "KLabel",
							text_align = "left",
							font_name = FN,
							size = {
								x = TW,
								y = BH * 0.6
							}
						},
						{
							id = "waves_config_list",
							class = "KEList",
							size = {
								y = 200,
								x = TW
							}
						},
						{
							style = "horizontal",
							class = "KELayout",
							children = {
								{
									id = "rb_reload",
									title = "reload",
									class = "KEButton",
									size = {
										x = 100,
										y = BH
									}
								},
								{
									id = "rb_apply",
									title = "apply",
									class = "KEButton",
									size = {
										x = 100,
										y = BH
									}
								}
							}
						}
					}
				},
				{
					id = "rb_balance",
					style = "vertical",
					class = "KELayout",
					hidden = true,
					pos = v(M, BH + M),
					children = {
						{
							text = "BALANCE CONFIGURATION",
							class = "KLabel",
							text_align = "left",
							font_name = FN,
							size = {
								x = TW,
								y = BH * 0.6
							}
						},
						{
							text = "TODO!",
							class = "KLabel",
							text_align = "left",
							font_name = FN,
							size = {
								x = TW,
								y = BH
							}
						}
					}
				},
				{
					id = "rb_errors",
					style = "vertical",
					class = "KELayout",
					hidden = true,
					pos = v(M, BH + M),
					children = {
						{
							text = "LAST ERRORS",
							class = "KLabel",
							text_align = "left",
							font_name = FN,
							size = {
								x = TW,
								y = BH * 0.6
							}
						},
						{
							id = "errors_list",
							class = "KEList",
							size = v(TW, H - 4 * BH)
						}
					}
				}
			}
		}
	}
}
