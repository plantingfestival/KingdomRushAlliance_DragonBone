-- chunkname: @./kr5/data/kui_templates/group_achievement_room_claim.lua

return {
	class = "KView",
	children = {
		{
			focus_image_name = "achievements_room_button_achievements_room_achievement_bg_claim_0003",
			class = "GG5Button",
			id = "achievement_room_achievement_claim_button",
			default_image_name = "achievements_room_button_achievements_room_achievement_bg_claim_0001",
			pos = v(0.05, -0.25),
			image_offset = v(-273.65, -111),
			hit_rect = r(-273.65, -111, 553, 230),
			children = {
				{
					id = "image_achievements_room_achievement_icon",
					image_name = "achievements_room_image_achievements_room_achievement_icon_",
					class = "KImageView",
					pos = v(-184.15, -19.05),
					anchor = v(58.3, 58.05)
				},
				{
					vertical_align = "top",
					text_align = "center",
					text_key = "ACHIEVEMENT_ROOM_achievement_claim",
					font_size = 31,
					line_height_extra = "2",
					fit_size = true,
					text = "Claim Reward!",
					class = "GG5Label",
					id = "label_achievement_room_claim",
					font_name = "fla_body",
					pos = v(-110.65, -70.35),
					scale = v(1, 1),
					size = v(334.45, 42.2),
					colors = {
						text = {
							255,
							226,
							0
						}
					}
				},
				{
					vertical_align = "top",
					text_align = "left",
					line_height_extra = "0",
					font_size = 46,
					fit_size = true,
					text = "30",
					class = "GG5Label",
					id = "label_achievement_room_claim_gems",
					font_name = "fla_numbers",
					pos = v(35.15, -19),
					scale = v(1, 1),
					size = v(149.5, 60.7),
					colors = {
						text = {
							222,
							247,
							255
						}
					}
				},
				{
					id = "image_achievement_room_claim_glow_fx",
					class = "KView",
					pos = v(-0.45, 3.55),
					children = {
						{
							image_name = "achievements_room_image_achievement_room_claim_glow_fx_",
							class = "KImageView",
							pos = v(-135.05, -18.6),
							scale = v(1, 1),
							anchor = v(121.95, 74.25)
						}
					}
				},
				{
					id = "image_dlc_1_flag",
					image_name = "achievements_room_image_dlc_dwarf_flag_",
					class = "KImageView",
					pos = v(-218.9, -68.45),
					anchor = v(23.9, 26.3)
				}
			}
		},
		{
			loop = true,
			id = "animation_achievement_room_claim_gems",
			class = "GGAni",
			pos = v(38.75, 30.95),
			anchor = v(144.95, 182),
			animation = {
				to = 22,
				prefix = "achievements_room_animation_achievement_room_claim_gems",
				from = 1
			}
		}
	}
}
