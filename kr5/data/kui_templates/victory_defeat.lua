-- chunkname: @./kr5/data/kui_templates/victory_defeat.lua

return {
	class = "KWindow",
	size = {
		x = ctx.sw,
		y = ctx.sh
	},
	children = {
		{
			id = "timeline_victorychallengescape",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 64,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_challenges_cape_",
					id = "image_challenges_cape",
					pos = v(-0.5, -163.65),
					scale = v(0.8431, 0.4095),
					anchor = v(318.9, 113.4)
				}
			},
			timeline = {
				{
					id = "image_challenges_cape",
					a_from = 1,
					play = "single",
					f = 25,
					frame_duration = 6,
					ease = 0,
					alpha = 0.05,
					a_to = 1,
					pos = v(-0.5, -163.65),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "image_challenges_cape",
					a_from = 1,
					play = "loop",
					f = 31,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-3.3, -308.95),
					scale = v(0.9941, 1.1387)
				},
				{
					id = "image_challenges_cape",
					a_from = 1,
					play = "single",
					f = 35,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-3.3, -282.55),
					scale = v(1.0101, 0.9775)
				},
				{
					id = "image_challenges_cape",
					a_from = 1,
					play = "single",
					f = 37,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-3.3, -291.45),
					scale = v(0.9904, 1.024)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 26,
					id = "image_challenges_cape",
					f = 39,
					pos = v(-3.3, -288.75)
				}
			}
		},
		{
			id = "timeline_victoryheroicshield",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 64,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_heroic_shield_",
					id = "image_heroic_shield",
					pos = v(6.85, -287.95),
					scale = v(0.8431, 0.4095),
					anchor = v(169.35, 137.75)
				},
				{
					id = "image_shield_glow_1",
					image_name = "victory_defeat_image_shield_glow_1_",
					class = "KImageView",
					pos = v(-127.85, -442.85),
					anchor = v(37.35, 100.45)
				},
				{
					id = "image_shield_glow_2",
					image_name = "victory_defeat_image_shield_glow_2_",
					class = "KImageView",
					pos = v(-71, -412.9),
					anchor = v(94.2, 137.85)
				},
				{
					id = "image_shield_glow_3",
					image_name = "victory_defeat_image_shield_glow_3_",
					class = "KImageView",
					pos = v(-33.4, -412.9),
					anchor = v(131.8, 137.85)
				},
				{
					id = "image_shield_glow_4",
					image_name = "victory_defeat_image_shield_glow_4_",
					class = "KImageView",
					pos = v(39.95, -406.9),
					anchor = v(121.25, 123.7)
				},
				{
					id = "image_shield_glow_5",
					image_name = "victory_defeat_image_shield_glow_5_",
					class = "KImageView",
					pos = v(120, -455.65),
					anchor = v(53.3, 95.1)
				},
				{
					id = "image_shield_glow_6",
					image_name = "victory_defeat_image_shield_glow_6_",
					class = "KImageView",
					pos = v(152.55, -480.15),
					anchor = v(20.8, 70.6)
				},
				{
					id = "animation_glowstar",
					class = "GGAni",
					pos = v(-108.75, -472.5),
					anchor = v(24.05, 24.05),
					animation = {
						to = 20,
						prefix = "victory_defeat_animation_glowstar",
						from = 1
					}
				},
				{
					id = "animation_glowstar",
					class = "GGAni",
					pos = v(-108.75, -472.5),
					anchor = v(24.05, 24.05),
					animation = {
						to = 20,
						prefix = "victory_defeat_animation_glowstar",
						from = 1
					}
				},
				{
					id = "animation_glowstar",
					class = "GGAni",
					pos = v(-108.75, -472.5),
					anchor = v(24.05, 24.05),
					animation = {
						to = 20,
						prefix = "victory_defeat_animation_glowstar",
						from = 1
					}
				}
			},
			timeline = {
				{
					id = "image_heroic_shield",
					a_from = 1,
					play = "single",
					f = 23,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(6.85, -287.95),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "image_heroic_shield",
					a_from = 1,
					play = "loop",
					f = 29,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(4.05, -433.25),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 32,
					id = "image_heroic_shield",
					f = 33,
					pos = v(4.05, -413.05)
				},
				{
					a_from = 1,
					play = "loop",
					id = "image_shield_glow_1",
					alpha = 0.7,
					a_to = 1,
					f = 33,
					frame_duration = 1,
					pos = v(-127.85, -442.85)
				},
				{
					a_from = 1,
					play = "loop",
					id = "image_shield_glow_2",
					alpha = 0.7,
					a_to = 1,
					f = 34,
					frame_duration = 1,
					pos = v(-71, -412.9)
				},
				{
					a_from = 1,
					play = "loop",
					id = "image_shield_glow_3",
					alpha = 0.7,
					a_to = 1,
					f = 35,
					frame_duration = 1,
					pos = v(-33.4, -412.9)
				},
				{
					a_from = 1,
					play = "loop",
					id = "image_shield_glow_4",
					alpha = 0.7,
					a_to = 1,
					f = 36,
					frame_duration = 1,
					pos = v(39.95, -406.9)
				},
				{
					a_from = 1,
					play = "loop",
					id = "image_shield_glow_5",
					alpha = 0.7,
					a_to = 1,
					f = 37,
					frame_duration = 1,
					pos = v(120, -455.65)
				},
				{
					a_from = 1,
					play = "loop",
					id = "image_shield_glow_6",
					alpha = 0.7,
					a_to = 1,
					f = 38,
					frame_duration = 1,
					pos = v(152.55, -480.15)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 20,
					frame_duration = 20,
					id = "animation_glowstar",
					f = 32,
					pos = v(-108.75, -472.5)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 20,
					frame_duration = 20,
					id = "animation_glowstar",
					f = 36,
					pos = v(70.05, -333.8)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 20,
					frame_duration = 20,
					id = "animation_glowstar",
					f = 40,
					pos = v(126.35, -514.85)
				}
			}
		},
		{
			id = "timeline_victory_heroic_soldier_start",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 29,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_soldier_2_",
					id = "soldier",
					pos = v(-220.45, -266.1),
					scale = v(0.8431, 0.4095),
					anchor = v(106.8, 153.15)
				}
			},
			timeline = {
				{
					id = "soldier",
					a_from = 1,
					play = "single",
					f = 19,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(-220.45, -266.1),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "soldier",
					a_from = 1,
					play = "loop",
					f = 25,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-223.25, -411.4),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 1,
					id = "soldier",
					f = 29,
					pos = v(-223.25, -391.2)
				}
			}
		},
		{
			id = "timeline_victory_heroic_soldier_loop",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 18,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					r = 0.1538,
					id = "soldier_torso",
					image_name = "victory_defeat_image_soldier_torso_2_",
					pos = v(-165, -308.35),
					scale = v(0.9995, 0.9995),
					anchor = v(65.4, 47.8)
				},
				{
					class = "KImageView",
					r = 0.1538,
					id = "soldier_head",
					image_name = "victory_defeat_image_soldier_head_",
					pos = v(-180.1, -398.8),
					scale = v(0.9993, 0.9995),
					anchor = v(58.4, 66.85)
				},
				{
					class = "KImageView",
					r = 0.1538,
					id = "soldier_medal",
					image_name = "victory_defeat_image_soldier_medal_",
					pos = v(-166.6, -344.6),
					scale = v(0.9995, 0.9995),
					anchor = v(39.65, 32.8)
				},
				{
					class = "KImageView",
					r = 0.1538,
					id = "soldier_sword",
					image_name = "victory_defeat_image_soldier_sword_",
					pos = v(-214.45, -418.9),
					scale = v(0.9995, 0.9995),
					anchor = v(113.7, 116.7)
				}
			},
			timeline = {
				{
					id = "soldier_torso",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 9,
					ease = 100,
					f = 1,
					a_to = 1,
					pos = v(-165, -308.35),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_torso",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 8,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(-165.35, -310.6),
					scale = v(0.9882, 1.0147)
				},
				{
					id = "soldier_torso",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 1,
					ease = 0,
					f = 18,
					a_to = 1,
					pos = v(-165, -308.35),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 2,
					ease = 0,
					f = 1,
					a_to = 1,
					pos = v(-180.1, -398.8),
					scale = v(0.9993, 0.9995)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 9,
					ease = 100,
					f = 3,
					a_to = 1,
					pos = v(-180.15, -398.85),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 6,
					ease = 0,
					f = 12,
					a_to = 1,
					pos = v(-180.5, -401.35),
					scale = v(0.9893, 1.0055)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 1,
					ease = 0,
					f = 18,
					a_to = 1,
					pos = v(-180.15, -398.85),
					scale = v(0.9988, 0.9998)
				},
				{
					id = "soldier_medal",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 9,
					ease = 100,
					f = 1,
					a_to = 1,
					pos = v(-166.6, -344.6),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_medal",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 8,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(-167, -346.4),
					scale = v(0.9882, 1.0147)
				},
				{
					id = "soldier_medal",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 1,
					ease = 0,
					f = 18,
					a_to = 1,
					pos = v(-166.6, -344.6),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_sword",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 9,
					ease = 100,
					f = 1,
					a_to = 1,
					pos = v(-214.45, -418.9),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_sword",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 8,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(-215.25, -424.15),
					scale = v(0.9889, 1.0222)
				},
				{
					id = "soldier_sword",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 1,
					ease = 0,
					f = 18,
					a_to = 1,
					pos = v(-214.45, -418.9),
					scale = v(0.9995, 0.9995)
				}
			}
		},
		{
			id = "timeline_victory_heroic_goblin_start",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 25,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_goblin_",
					id = "goblin",
					pos = v(195, -265.75),
					scale = v(0.8431, 0.4095),
					anchor = v(89.25, 92.85)
				}
			},
			timeline = {
				{
					id = "goblin",
					a_from = 1,
					play = "single",
					f = 15,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(195, -265.75),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "goblin",
					a_from = 1,
					play = "single",
					f = 21,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(182.4, -373.8),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 1,
					id = "goblin",
					f = 25,
					pos = v(182.05, -360.7)
				}
			}
		},
		{
			id = "timeline_victory_heroic_goblin_loop",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 10,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					id = "goblin_torso",
					image_name = "victory_defeat_image_goblin_torso_",
					class = "KImageView",
					pos = v(189.65, -299.25),
					anchor = v(52.95, 33.15)
				},
				{
					id = "goblin_arm_r",
					image_name = "victory_defeat_image_goblin_arm_r_",
					class = "KImageView",
					pos = v(129.2, -333.6),
					anchor = v(37.4, 28.95)
				},
				{
					class = "KImageView",
					r = 0.0055,
					id = "goblin_hair",
					image_name = "victory_defeat_image_goblin_hair_",
					pos = v(193.3, -424.3),
					scale = v(0.9491, 0.9404),
					anchor = v(46.9, 31.65)
				},
				{
					id = "goblin_head",
					image_name = "victory_defeat_image_goblin_head_",
					class = "KImageView",
					pos = v(200.3, -392.55),
					anchor = v(70, 55.05)
				},
				{
					id = "goblin_arm_l",
					image_name = "victory_defeat_image_goblin_arm_l_",
					class = "KImageView",
					pos = v(183.65, -322),
					anchor = v(59.95, 33.3)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_torso",
					pos = v(189.65, -299.25)
				},
				{
					id = "goblin_torso",
					a_from = 1,
					play = "loop",
					r = -0.0431,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(191.85, -301.25),
					scale = v(0.9576, 1.0639)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_torso",
					pos = v(189.65, -299.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_arm_r",
					pos = v(129.2, -333.6)
				},
				{
					id = "goblin_arm_r",
					a_from = 1,
					play = "loop",
					r = 0.0201,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(130.8, -334.25),
					scale = v(1.0158, 0.9705)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_arm_r",
					pos = v(129.2, -333.6)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0055,
					frame_duration = 2,
					ease = 0,
					f = 1,
					a_to = 1,
					pos = v(193.3, -424.3),
					scale = v(0.9491, 0.9404)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					f = 3,
					frame_duration = 5,
					ease = 0,
					a_to = 1,
					pos = v(194.05, -425.05),
					scale = v(0.9446, 0.9446)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0275,
					frame_duration = 2,
					ease = 0,
					f = 8,
					a_to = 1,
					pos = v(191.55, -421.45),
					scale = v(0.9669, 0.9235)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0123,
					frame_duration = 1,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(192.7, -423.35),
					scale = v(0.955, 0.9348)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 6,
					ease = 0,
					f = 1,
					id = "goblin_head",
					pos = v(200.3, -392.55)
				},
				{
					id = "goblin_head",
					a_from = 1,
					play = "loop",
					r = 0.0308,
					frame_duration = 3,
					ease = 0,
					f = 7,
					a_to = 1,
					pos = v(199.1, -390),
					scale = v(1.0234, 0.9773)
				},
				{
					id = "goblin_head",
					a_from = 1,
					play = "loop",
					r = 0.0046,
					frame_duration = 1,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(199.95, -391.8),
					scale = v(1.0058, 0.9943)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_arm_l",
					pos = v(183.65, -322)
				},
				{
					id = "goblin_arm_l",
					a_from = 1,
					play = "loop",
					r = 0.0201,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(184.95, -323.9),
					scale = v(1.0158, 0.9513)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_arm_l",
					pos = v(183.65, -322)
				}
			}
		},
		{
			id = "timeline_victoryiron_fist",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 64,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_iron_fist_",
					id = "image_iron_fist",
					pos = v(-0.25, -284.05),
					scale = v(0.8431, 0.4095),
					anchor = v(103.6, 158.8)
				},
				{
					id = "animation_glowstar",
					class = "GGAni",
					pos = v(-80.35, -518.65),
					anchor = v(24.05, 24.05),
					animation = {
						to = 20,
						prefix = "victory_defeat_animation_glowstar",
						from = 1
					}
				},
				{
					id = "animation_glowstar",
					class = "GGAni",
					pos = v(-80.35, -518.65),
					anchor = v(24.05, 24.05),
					animation = {
						to = 20,
						prefix = "victory_defeat_animation_glowstar",
						from = 1
					}
				},
				{
					id = "animation_glowstar",
					class = "GGAni",
					pos = v(-80.35, -518.65),
					anchor = v(24.05, 24.05),
					animation = {
						to = 20,
						prefix = "victory_defeat_animation_glowstar",
						from = 1
					}
				}
			},
			timeline = {
				{
					id = "image_iron_fist",
					a_from = 1,
					play = "single",
					f = 23,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(-0.25, -284.05),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "image_iron_fist",
					a_from = 1,
					play = "loop",
					f = 29,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-3.05, -429.35),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 32,
					id = "image_iron_fist",
					f = 33,
					pos = v(-3.05, -409.15)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 20,
					frame_duration = 20,
					id = "animation_glowstar",
					f = 32,
					pos = v(-80.35, -518.65)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 20,
					frame_duration = 20,
					id = "animation_glowstar",
					f = 38,
					pos = v(68.55, -417.85)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 20,
					frame_duration = 20,
					id = "animation_glowstar",
					f = 44,
					pos = v(49.05, -561)
				}
			}
		},
		{
			id = "timeline_victory_iron_soldier_start",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 29,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_soldier_2_",
					id = "soldier",
					pos = v(-203.75, -266.1),
					scale = v(0.8431, 0.4095),
					anchor = v(106.8, 153.15)
				}
			},
			timeline = {
				{
					id = "soldier",
					a_from = 1,
					play = "single",
					f = 19,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(-203.75, -266.1),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "soldier",
					a_from = 1,
					play = "loop",
					f = 25,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-206.55, -411.4),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 1,
					id = "soldier",
					f = 29,
					pos = v(-206.55, -391.2)
				}
			}
		},
		{
			id = "timeline_victory_iron_soldier_loop",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 18,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					r = 0.1538,
					id = "soldier_torso",
					image_name = "victory_defeat_image_soldier_torso_2_",
					pos = v(-149, -307.35),
					scale = v(0.9995, 0.9995),
					anchor = v(65.4, 47.8)
				},
				{
					class = "KImageView",
					r = 0.1538,
					id = "soldier_head",
					image_name = "victory_defeat_image_soldier_head_",
					pos = v(-164.1, -397.8),
					scale = v(0.9993, 0.9995),
					anchor = v(58.4, 66.85)
				},
				{
					class = "KImageView",
					r = 0.1538,
					id = "soldier_medal",
					image_name = "victory_defeat_image_soldier_medal_",
					pos = v(-150.6, -343.6),
					scale = v(0.9995, 0.9995),
					anchor = v(39.65, 32.8)
				},
				{
					class = "KImageView",
					r = 0.1538,
					id = "soldier_sword",
					image_name = "victory_defeat_image_soldier_sword_",
					pos = v(-198.45, -417.9),
					scale = v(0.9995, 0.9995),
					anchor = v(113.7, 116.7)
				}
			},
			timeline = {
				{
					id = "soldier_torso",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 9,
					ease = 100,
					f = 1,
					a_to = 1,
					pos = v(-149, -307.35),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_torso",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 8,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(-149.35, -309.6),
					scale = v(0.9882, 1.0147)
				},
				{
					id = "soldier_torso",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 1,
					ease = 0,
					f = 18,
					a_to = 1,
					pos = v(-149, -307.35),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 2,
					ease = 0,
					f = 1,
					a_to = 1,
					pos = v(-164.1, -397.8),
					scale = v(0.9993, 0.9995)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 9,
					ease = 100,
					f = 3,
					a_to = 1,
					pos = v(-164.15, -397.85),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 6,
					ease = 0,
					f = 12,
					a_to = 1,
					pos = v(-164.5, -400.35),
					scale = v(0.9893, 1.0055)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 1,
					ease = 0,
					f = 18,
					a_to = 1,
					pos = v(-164.15, -397.85),
					scale = v(0.9988, 0.9998)
				},
				{
					id = "soldier_medal",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 9,
					ease = 100,
					f = 1,
					a_to = 1,
					pos = v(-150.6, -343.6),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_medal",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 8,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(-151, -345.4),
					scale = v(0.9882, 1.0147)
				},
				{
					id = "soldier_medal",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 1,
					ease = 0,
					f = 18,
					a_to = 1,
					pos = v(-150.6, -343.6),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_sword",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 9,
					ease = 100,
					f = 1,
					a_to = 1,
					pos = v(-198.45, -417.9),
					scale = v(0.9995, 0.9995)
				},
				{
					id = "soldier_sword",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 8,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(-199.25, -423.15),
					scale = v(0.9889, 1.0222)
				},
				{
					id = "soldier_sword",
					a_from = 1,
					play = "loop",
					r = 0.1538,
					frame_duration = 1,
					ease = 0,
					f = 18,
					a_to = 1,
					pos = v(-198.45, -417.9),
					scale = v(0.9995, 0.9995)
				}
			}
		},
		{
			id = "timeline_victory_iron_goblin_start",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 25,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_goblin_",
					id = "goblin",
					pos = v(170.1, -266.05),
					scale = v(0.8431, 0.4095),
					anchor = v(89.25, 92.85)
				}
			},
			timeline = {
				{
					id = "goblin",
					a_from = 1,
					play = "single",
					f = 15,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(170.1, -266.05),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "goblin",
					a_from = 1,
					play = "single",
					f = 21,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(157.5, -374.1),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 1,
					id = "goblin",
					f = 25,
					pos = v(157.15, -361)
				}
			}
		},
		{
			id = "timeline_victory_iron_goblin_loop",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 10,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					id = "goblin_torso",
					image_name = "victory_defeat_image_goblin_torso_",
					class = "KImageView",
					pos = v(166.65, -298.25),
					anchor = v(52.95, 33.15)
				},
				{
					id = "goblin_arm_r",
					image_name = "victory_defeat_image_goblin_arm_r_",
					class = "KImageView",
					pos = v(106.2, -332.6),
					anchor = v(37.4, 28.95)
				},
				{
					class = "KImageView",
					r = 0.0055,
					id = "goblin_hair",
					image_name = "victory_defeat_image_goblin_hair_",
					pos = v(170.3, -423.3),
					scale = v(0.9491, 0.9404),
					anchor = v(46.9, 31.65)
				},
				{
					id = "goblin_head",
					image_name = "victory_defeat_image_goblin_head_",
					class = "KImageView",
					pos = v(177.3, -391.55),
					anchor = v(70, 55.05)
				},
				{
					id = "goblin_arm_l",
					image_name = "victory_defeat_image_goblin_arm_l_",
					class = "KImageView",
					pos = v(160.65, -321),
					anchor = v(59.95, 33.3)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_torso",
					pos = v(166.65, -298.25)
				},
				{
					id = "goblin_torso",
					a_from = 1,
					play = "loop",
					r = -0.0431,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(168.85, -300.25),
					scale = v(0.9576, 1.0639)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_torso",
					pos = v(166.65, -298.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_arm_r",
					pos = v(106.2, -332.6)
				},
				{
					id = "goblin_arm_r",
					a_from = 1,
					play = "loop",
					r = 0.0201,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(107.8, -333.25),
					scale = v(1.0158, 0.9705)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_arm_r",
					pos = v(106.2, -332.6)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0055,
					frame_duration = 2,
					ease = 0,
					f = 1,
					a_to = 1,
					pos = v(170.3, -423.3),
					scale = v(0.9491, 0.9404)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					f = 3,
					frame_duration = 5,
					ease = 0,
					a_to = 1,
					pos = v(171.05, -424.05),
					scale = v(0.9446, 0.9446)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0275,
					frame_duration = 2,
					ease = 0,
					f = 8,
					a_to = 1,
					pos = v(168.55, -420.45),
					scale = v(0.9669, 0.9235)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0123,
					frame_duration = 1,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(169.7, -422.35),
					scale = v(0.955, 0.9348)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 6,
					ease = 0,
					f = 1,
					id = "goblin_head",
					pos = v(177.3, -391.55)
				},
				{
					id = "goblin_head",
					a_from = 1,
					play = "loop",
					r = 0.0308,
					frame_duration = 3,
					ease = 0,
					f = 7,
					a_to = 1,
					pos = v(176.1, -389),
					scale = v(1.0234, 0.9773)
				},
				{
					id = "goblin_head",
					a_from = 1,
					play = "loop",
					r = 0.0046,
					frame_duration = 1,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(176.95, -390.8),
					scale = v(1.0058, 0.9943)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_arm_l",
					pos = v(160.65, -321)
				},
				{
					id = "goblin_arm_l",
					a_from = 1,
					play = "loop",
					r = 0.0201,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(161.95, -322.9),
					scale = v(1.0158, 0.9513)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_arm_l",
					pos = v(160.65, -321)
				}
			}
		},
		{
			id = "timeline_victorychallenges",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 64,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					id = "chain",
					image_name = "victory_defeat_image_chain_",
					class = "KImageView",
					pos = v(57.1, -240.25),
					anchor = v(29.6, 13.45)
				},
				{
					id = "chain2",
					image_name = "victory_defeat_image_chain_",
					class = "KImageView",
					pos = v(-84.65, -240.25),
					anchor = v(29.6, 13.45)
				},
				{
					focus_image_name = "victory_defeat_button_ingame_quit_0003",
					class = "GG5Button",
					id = "button_continue",
					default_image_name = "victory_defeat_button_ingame_quit_0001",
					pos = v(72.55, -119.1),
					image_offset = v(-56.05, -52.45),
					hit_rect = r(-56.05, -52.45, 108.6, 108),
					children = {
						{
							id = "image_icon_continue",
							image_name = "victory_defeat_image_icon_continue_",
							class = "KImageView",
							pos = v(0, -2.1),
							anchor = v(18.4, 20.9)
						}
					}
				},
				{
					focus_image_name = "victory_defeat_button_ingame_quit_0003",
					class = "GG5Button",
					id = "button_restart",
					default_image_name = "victory_defeat_button_ingame_quit_0001",
					pos = v(-74.2, -107),
					image_offset = v(-56.05, -52.45),
					hit_rect = r(-56.05, -52.45, 108.6, 108),
					children = {
						{
							id = "image_icon_restart",
							image_name = "victory_defeat_image_icon_restart_",
							class = "KImageView",
							pos = v(-0.15, -1.65),
							anchor = v(22.05, 23)
						}
					}
				},
				{
					image_name = "victory_defeat_image_subframe_desktop_",
					class = "KImageView",
					id = "subframe_desktop",
					pos = v(-6.85, -207.45),
					UNLESS = ctx.is_mobile,
					anchor = v(149.7, 55.55)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_subframe_",
					id = "subframe",
					pos = v(-4, -205.75),
					WHEN = ctx.is_mobile,
					anchor = v(172.25, 47.3)
				},
				{
					id = "main_shadow",
					image_name = "victory_defeat_image_main_shadow_",
					class = "KImageView",
					pos = v(-5.2, -224.25),
					anchor = v(318.6, 114)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_mainframe_",
					id = "mainframe",
					pos = v(0.8, -225.65),
					scale = v(0.6883, 0.6883),
					anchor = v(292.85, 86.05)
				},
				{
					id = "animation_gem",
					class = "GGAni",
					pos = v(-3.6, -284.25),
					anchor = v(95.2, -95.9),
					animation = {
						to = 25,
						prefix = "victory_defeat_animation_gem",
						from = 1
					}
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = -50,
					f = 33,
					id = "chain",
					pos = v(57.1, -240.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain",
					f = 38,
					pos = v(57.1, -173.1)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain",
					f = 40,
					pos = v(57.1, -180.3)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 23,
					id = "chain",
					f = 42,
					pos = v(57.1, -177.3)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = -50,
					f = 35,
					id = "chain2",
					pos = v(-84.65, -240.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain2",
					f = 40,
					pos = v(-84.65, -173.1)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain2",
					f = 42,
					pos = v(-84.65, -180.3)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 21,
					id = "chain2",
					f = 44,
					pos = v(-84.65, -177.3)
				},
				{
					id = "button_continue",
					frame_duration = 2,
					ease = 0,
					f = 31,
					pos = v(72.55, -119.1)
				},
				{
					id = "button_continue",
					frame_duration = 5,
					ease = -50,
					f = 33,
					pos = v(72.55, -76)
				},
				{
					id = "button_continue",
					f = 38,
					frame_duration = 2,
					pos = v(72.55, -8.9)
				},
				{
					id = "button_continue",
					f = 40,
					frame_duration = 2,
					pos = v(72.55, -16.2)
				},
				{
					id = "button_continue",
					f = 42,
					frame_duration = 23,
					pos = v(72.55, -13.3)
				},
				{
					id = "button_restart",
					frame_duration = 2,
					ease = 0,
					f = 33,
					pos = v(-74.2, -107)
				},
				{
					id = "button_restart",
					frame_duration = 5,
					ease = -50,
					f = 35,
					pos = v(-74.2, -76.15)
				},
				{
					id = "button_restart",
					f = 40,
					frame_duration = 2,
					pos = v(-74.2, -9.05)
				},
				{
					id = "button_restart",
					f = 42,
					frame_duration = 2,
					pos = v(-74.2, -16.25)
				},
				{
					id = "button_restart",
					f = 44,
					frame_duration = 21,
					pos = v(-74.2, -13.3)
				},
				{
					id = "subframe_desktop",
					frame_duration = 12,
					ease = 100,
					f = 10,
					pos = v(-6.85, -207.45)
				},
				{
					id = "subframe_desktop",
					f = 22,
					frame_duration = 43,
					pos = v(-6.5, -154.65)
				},
				{
					id = "subframe",
					frame_duration = 12,
					ease = 100,
					f = 10,
					pos = v(-4, -205.75)
				},
				{
					id = "subframe",
					f = 22,
					frame_duration = 43,
					pos = v(-3.65, -140.55)
				},
				{
					alpha = 0.33,
					a_from = 1,
					play = "loop",
					id = "main_shadow",
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					f = 9,
					pos = v(-5.2, -224.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 54,
					id = "main_shadow",
					f = 11,
					pos = v(-5.2, -224.25)
				},
				{
					id = "mainframe",
					a_from = 1,
					play = "loop",
					f = 1,
					frame_duration = 8,
					ease = 0,
					alpha = 0.02,
					a_to = 1,
					pos = v(0.8, -225.65),
					scale = v(0.6883, 0.6883)
				},
				{
					id = "mainframe",
					a_from = 1,
					play = "loop",
					f = 9,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-3.65, -239.65),
					scale = v(1.0932, 1.0932)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 54,
					id = "mainframe",
					f = 11,
					pos = v(-3.6, -239.65)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 25,
					frame_duration = 41,
					id = "animation_gem",
					f = 24,
					pos = v(-3.6, -284.25)
				}
			}
		},
		{
			id = "group_victorytextchallenges",
			class = "KView",
			template_name = "group_victorytextchallenges",
			pos = v(ctx.sw / 2, 367.25)
		},
		{
			id = "timeline_angry_start",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 29,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_angry_",
					id = "angry",
					pos = v(-2.55, -294.9),
					scale = v(0.8431, 0.4095),
					anchor = v(229.45, 115.5)
				}
			},
			timeline = {
				{
					id = "angry",
					a_from = 1,
					play = "loop",
					f = 19,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(-2.55, -294.9),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "angry",
					a_from = 1,
					play = "loop",
					f = 25,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-5.35, -440.2),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					id = "angry",
					f = 29,
					pos = v(-5.35, -420)
				}
			}
		},
		{
			id = "timeline_angry_loop",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 32,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					id = "animation_fire",
					class = "GGAni",
					pos = v(91.7, -508.5),
					anchor = v(14, 41.6),
					animation = {
						to = 8,
						prefix = "victory_defeat_animation_fire",
						from = 1
					}
				},
				{
					id = "image_cape_behind",
					image_name = "victory_defeat_image_cape_behind_",
					class = "KImageView",
					pos = v(-44.9, -345.65),
					anchor = v(189.9, 40.75)
				},
				{
					id = "image_soldier_defeat_arm_r",
					image_name = "victory_defeat_image_soldier_defeat_arm_r_",
					class = "KImageView",
					pos = v(-25.05, -406.25),
					anchor = v(34.3, 24.45)
				},
				{
					id = "image_goblin_defeat_arm",
					image_name = "victory_defeat_image_goblin_defeat_arm_",
					class = "KImageView",
					pos = v(-158.2, -341.95),
					anchor = v(46.9, 30.6)
				},
				{
					id = "image_goblin_defeat_torso",
					image_name = "victory_defeat_image_goblin_defeat_torso_",
					class = "KImageView",
					pos = v(-89.2, -322.6),
					anchor = v(65.6, 31.5)
				},
				{
					id = "image_goblin_defeat_head",
					image_name = "victory_defeat_image_goblin_defeat_head_",
					class = "KImageView",
					pos = v(-115.6, -436.85),
					anchor = v(86.95, 48.4)
				},
				{
					id = "image_soldier_defeat_torso",
					image_name = "victory_defeat_image_soldier_defeat_torso_",
					class = "KImageView",
					pos = v(69.05, -334.1),
					anchor = v(60.45, 56.15)
				},
				{
					id = "image_soldier_defeat_cape",
					image_name = "victory_defeat_image_soldier_defeat_cape_",
					class = "KImageView",
					pos = v(138.9, -359.2),
					anchor = v(76.7, 69)
				},
				{
					id = "image_soldier_defeat_head",
					image_name = "victory_defeat_image_soldier_defeat_head_",
					class = "KImageView",
					pos = v(46.55, -443.1),
					anchor = v(68.45, 58.65)
				},
				{
					id = "image_soldier_defeat_arm_l",
					image_name = "victory_defeat_image_soldier_defeat_arm_l_",
					class = "KImageView",
					pos = v(-8.35, -371.65),
					anchor = v(119.1, 42)
				},
				{
					id = "image_defeat_arrow",
					image_name = "victory_defeat_image_defeat_arrow_",
					class = "KImageView",
					pos = v(134.45, -370.9),
					anchor = v(39.9, 29.6)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "loop",
					a_to = 8,
					frame_duration = 32,
					id = "animation_fire",
					f = 1,
					pos = v(91.7, -508.5)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_cape_behind",
					pos = v(-44.9, -345.65)
				},
				{
					id = "image_cape_behind",
					a_from = 1,
					play = "loop",
					f = 5,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-44.9, -344.8),
					scale = v(0.9934, 1.0119)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_cape_behind",
					pos = v(-44.9, -345.65)
				},
				{
					id = "image_cape_behind",
					a_from = 1,
					play = "loop",
					f = 13,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-44.9, -344.8),
					scale = v(0.9934, 1.0119)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_cape_behind",
					pos = v(-44.9, -345.65)
				},
				{
					id = "image_cape_behind",
					a_from = 1,
					play = "loop",
					f = 21,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-44.9, -344.8),
					scale = v(0.9934, 1.0119)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_cape_behind",
					pos = v(-44.9, -345.65)
				},
				{
					id = "image_cape_behind",
					a_from = 1,
					play = "loop",
					f = 29,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-44.9, -344.8),
					scale = v(0.9934, 1.0119)
				},
				{
					id = "image_cape_behind",
					a_from = 1,
					play = "loop",
					f = 31,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(-44.9, -345.15),
					scale = v(0.9967, 1.006)
				},
				{
					id = "image_cape_behind",
					a_from = 1,
					play = "loop",
					f = 32,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(-44.85, -345.4),
					scale = v(0.9983, 1.0029)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_soldier_defeat_arm_r",
					pos = v(-25.05, -406.25)
				},
				{
					id = "image_soldier_defeat_arm_r",
					a_from = 1,
					play = "loop",
					f = 5,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-22.5, -406.25),
					scale = v(0.9269, 1.0491)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_soldier_defeat_arm_r",
					pos = v(-25.05, -406.25)
				},
				{
					id = "image_soldier_defeat_arm_r",
					a_from = 1,
					play = "loop",
					f = 13,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-23.65, -406.25),
					scale = v(0.9595, 1.0491)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_soldier_defeat_arm_r",
					pos = v(-25.05, -406.25)
				},
				{
					id = "image_soldier_defeat_arm_r",
					a_from = 1,
					play = "loop",
					f = 21,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-23.65, -406.25),
					scale = v(0.9595, 1.0491)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_soldier_defeat_arm_r",
					pos = v(-25.05, -406.25)
				},
				{
					id = "image_soldier_defeat_arm_r",
					a_from = 1,
					play = "loop",
					f = 29,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-23.65, -406.25),
					scale = v(0.9595, 1.0491)
				},
				{
					id = "image_soldier_defeat_arm_r",
					a_from = 1,
					play = "loop",
					f = 31,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(-24.25, -406.25),
					scale = v(0.9797, 1.0245)
				},
				{
					id = "image_soldier_defeat_arm_r",
					a_from = 1,
					play = "loop",
					f = 32,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(-24.5, -406.25),
					scale = v(0.9898, 1.0122)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_goblin_defeat_arm",
					pos = v(-158.2, -341.95)
				},
				{
					id = "image_goblin_defeat_arm",
					a_from = 1,
					play = "loop",
					r = -0.0751,
					frame_duration = 4,
					ease = 0,
					f = 5,
					a_to = 1,
					pos = v(-155.75, -346.5),
					scale = v(1.0179, 0.9672)
				},
				{
					id = "image_goblin_defeat_arm",
					a_from = 1,
					play = "loop",
					r = 0.0561,
					frame_duration = 4,
					ease = 0,
					f = 9,
					a_to = 1,
					pos = v(-157.2, -339.7),
					scale = v(1, 1)
				},
				{
					id = "image_goblin_defeat_arm",
					a_from = 1,
					play = "loop",
					r = -0.019,
					frame_duration = 4,
					ease = 0,
					f = 13,
					a_to = 1,
					pos = v(-155, -344.35),
					scale = v(1.0179, 0.9672)
				},
				{
					id = "image_goblin_defeat_arm",
					a_from = 1,
					play = "loop",
					r = 0.0561,
					frame_duration = 4,
					ease = 0,
					f = 17,
					a_to = 1,
					pos = v(-157.2, -339.7),
					scale = v(1, 1)
				},
				{
					id = "image_goblin_defeat_arm",
					a_from = 1,
					play = "loop",
					r = -0.019,
					frame_duration = 4,
					ease = 0,
					f = 21,
					a_to = 1,
					pos = v(-155, -344.35),
					scale = v(1.0179, 0.9672)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_goblin_defeat_arm",
					pos = v(-158.2, -341.95)
				},
				{
					id = "image_goblin_defeat_arm",
					a_from = 1,
					play = "loop",
					r = -0.0751,
					frame_duration = 2,
					ease = 0,
					f = 29,
					a_to = 1,
					pos = v(-155.75, -346.5),
					scale = v(1.0179, 0.9672)
				},
				{
					id = "image_goblin_defeat_arm",
					a_from = 1,
					play = "loop",
					r = -0.0376,
					frame_duration = 1,
					ease = 0,
					f = 31,
					a_to = 1,
					pos = v(-156.95, -344.25),
					scale = v(1.0089, 0.9836)
				},
				{
					id = "image_goblin_defeat_arm",
					a_from = 1,
					play = "loop",
					r = -0.0188,
					frame_duration = 1,
					ease = 0,
					f = 32,
					a_to = 1,
					pos = v(-157.5, -343.15),
					scale = v(1.0044, 0.9918)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_goblin_defeat_torso",
					pos = v(-89.2, -322.6)
				},
				{
					id = "image_goblin_defeat_torso",
					a_from = 1,
					play = "loop",
					r = -0.0515,
					frame_duration = 4,
					ease = 0,
					f = 5,
					a_to = 1,
					pos = v(-88.8, -320.55),
					scale = v(0.9635, 1.0479)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_goblin_defeat_torso",
					pos = v(-89.2, -322.6)
				},
				{
					id = "image_goblin_defeat_torso",
					a_from = 1,
					play = "loop",
					r = -0.017,
					frame_duration = 4,
					ease = 0,
					f = 13,
					a_to = 1,
					pos = v(-87.2, -320.5),
					scale = v(0.9634, 1.0479)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_goblin_defeat_torso",
					pos = v(-89.2, -322.6)
				},
				{
					id = "image_goblin_defeat_torso",
					a_from = 1,
					play = "loop",
					r = -0.0515,
					frame_duration = 4,
					ease = 0,
					f = 21,
					a_to = 1,
					pos = v(-88.8, -320.55),
					scale = v(0.9635, 1.0479)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_goblin_defeat_torso",
					pos = v(-89.2, -322.6)
				},
				{
					id = "image_goblin_defeat_torso",
					a_from = 1,
					play = "loop",
					r = 0.0095,
					frame_duration = 2,
					ease = 0,
					f = 29,
					a_to = 1,
					pos = v(-86, -320.5),
					scale = v(0.9634, 1.0479)
				},
				{
					id = "image_goblin_defeat_torso",
					a_from = 1,
					play = "loop",
					r = 0.0047,
					frame_duration = 1,
					ease = 0,
					f = 31,
					a_to = 1,
					pos = v(-87.5, -321.55),
					scale = v(0.9817, 1.024)
				},
				{
					id = "image_goblin_defeat_torso",
					a_from = 1,
					play = "loop",
					r = 0.0024,
					frame_duration = 1,
					ease = 0,
					f = 32,
					a_to = 1,
					pos = v(-88.3, -322.1),
					scale = v(0.9908, 1.0119)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_goblin_defeat_head",
					pos = v(-115.6, -436.85)
				},
				{
					id = "image_goblin_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.056,
					frame_duration = 4,
					ease = 0,
					f = 5,
					a_to = 1,
					pos = v(-112.1, -440.2),
					scale = v(0.9612, 1.0761)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_goblin_defeat_head",
					pos = v(-115.6, -436.85)
				},
				{
					id = "image_goblin_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.056,
					frame_duration = 4,
					ease = 0,
					f = 13,
					a_to = 1,
					pos = v(-112.1, -440.2),
					scale = v(0.9612, 1.0761)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_goblin_defeat_head",
					pos = v(-115.6, -436.85)
				},
				{
					id = "image_goblin_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.056,
					frame_duration = 4,
					ease = 0,
					f = 21,
					a_to = 1,
					pos = v(-112.1, -440.2),
					scale = v(0.9612, 1.0761)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_goblin_defeat_head",
					pos = v(-115.6, -436.85)
				},
				{
					id = "image_goblin_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.056,
					frame_duration = 3,
					ease = 0,
					f = 29,
					a_to = 1,
					pos = v(-112.1, -440.2),
					scale = v(0.9612, 1.0761)
				},
				{
					id = "image_goblin_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.014,
					frame_duration = 1,
					ease = 0,
					f = 32,
					a_to = 1,
					pos = v(-114.55, -437.45),
					scale = v(0.9903, 1.019)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_soldier_defeat_torso",
					pos = v(69.05, -334.1)
				},
				{
					id = "image_soldier_defeat_torso",
					a_from = 1,
					play = "loop",
					f = 5,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(69, -333.2),
					scale = v(1.0082, 0.9764)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_soldier_defeat_torso",
					pos = v(69.05, -334.1)
				},
				{
					id = "image_soldier_defeat_torso",
					a_from = 1,
					play = "loop",
					f = 13,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(69, -333.2),
					scale = v(1.0082, 0.9764)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_soldier_defeat_torso",
					pos = v(69.05, -334.1)
				},
				{
					id = "image_soldier_defeat_torso",
					a_from = 1,
					play = "loop",
					f = 21,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(69, -333.2),
					scale = v(1.0082, 0.9764)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_soldier_defeat_torso",
					pos = v(69.05, -334.1)
				},
				{
					id = "image_soldier_defeat_torso",
					a_from = 1,
					play = "loop",
					f = 29,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(69, -333.2),
					scale = v(1.0082, 0.9764)
				},
				{
					id = "image_soldier_defeat_torso",
					a_from = 1,
					play = "loop",
					f = 31,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(68.95, -333.7),
					scale = v(1.0041, 0.9882)
				},
				{
					id = "image_soldier_defeat_torso",
					a_from = 1,
					play = "loop",
					f = 32,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(68.95, -333.95),
					scale = v(1.002, 0.9941)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_soldier_defeat_cape",
					pos = v(138.9, -359.2)
				},
				{
					id = "image_soldier_defeat_cape",
					a_from = 1,
					play = "loop",
					f = 5,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(138.45, -358.5),
					scale = v(0.9917, 1.0152)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_soldier_defeat_cape",
					pos = v(138.9, -359.2)
				},
				{
					id = "image_soldier_defeat_cape",
					a_from = 1,
					play = "loop",
					f = 13,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(138.45, -358.5),
					scale = v(0.9917, 1.0152)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_soldier_defeat_cape",
					pos = v(138.9, -359.2)
				},
				{
					id = "image_soldier_defeat_cape",
					a_from = 1,
					play = "loop",
					f = 21,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(138.45, -358.5),
					scale = v(0.9917, 1.0152)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_soldier_defeat_cape",
					pos = v(138.9, -359.2)
				},
				{
					id = "image_soldier_defeat_cape",
					a_from = 1,
					play = "loop",
					f = 29,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(138.45, -358.5),
					scale = v(0.9917, 1.0152)
				},
				{
					id = "image_soldier_defeat_cape",
					a_from = 1,
					play = "loop",
					f = 31,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(138.7, -358.8),
					scale = v(0.9958, 1.0076)
				},
				{
					id = "image_soldier_defeat_cape",
					a_from = 1,
					play = "loop",
					f = 32,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(138.8, -358.95),
					scale = v(0.9979, 1.0038)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_soldier_defeat_head",
					pos = v(46.55, -443.1)
				},
				{
					id = "image_soldier_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.0123,
					frame_duration = 4,
					ease = 0,
					f = 5,
					a_to = 1,
					pos = v(46.1, -442.45),
					scale = v(1.006, 0.9891)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_soldier_defeat_head",
					pos = v(46.55, -443.1)
				},
				{
					id = "image_soldier_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.0123,
					frame_duration = 4,
					ease = 0,
					f = 13,
					a_to = 1,
					pos = v(46.1, -442.45),
					scale = v(1.006, 0.9891)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_soldier_defeat_head",
					pos = v(46.55, -443.1)
				},
				{
					id = "image_soldier_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.0123,
					frame_duration = 4,
					ease = 0,
					f = 21,
					a_to = 1,
					pos = v(46.1, -442.45),
					scale = v(1.006, 0.9891)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_soldier_defeat_head",
					pos = v(46.55, -443.1)
				},
				{
					id = "image_soldier_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.0123,
					frame_duration = 2,
					ease = 0,
					f = 29,
					a_to = 1,
					pos = v(46.1, -442.45),
					scale = v(1.006, 0.9891)
				},
				{
					id = "image_soldier_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.0062,
					frame_duration = 1,
					ease = 0,
					f = 31,
					a_to = 1,
					pos = v(46.3, -442.65),
					scale = v(1.003, 0.9945)
				},
				{
					id = "image_soldier_defeat_head",
					a_from = 1,
					play = "loop",
					r = 0.0031,
					frame_duration = 1,
					ease = 0,
					f = 32,
					a_to = 1,
					pos = v(46.4, -442.75),
					scale = v(1.0014, 0.9973)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_soldier_defeat_arm_l",
					pos = v(-8.35, -371.65)
				},
				{
					id = "image_soldier_defeat_arm_l",
					a_from = 1,
					play = "loop",
					r = -0.0078,
					frame_duration = 4,
					ease = 0,
					f = 5,
					a_to = 1,
					pos = v(-5.75, -372.1),
					scale = v(0.9799, 1.0222)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_soldier_defeat_arm_l",
					pos = v(-8.35, -371.65)
				},
				{
					id = "image_soldier_defeat_arm_l",
					a_from = 1,
					play = "loop",
					r = -0.0078,
					frame_duration = 4,
					ease = 0,
					f = 13,
					a_to = 1,
					pos = v(-5.75, -372.1),
					scale = v(0.9799, 1.0222)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_soldier_defeat_arm_l",
					pos = v(-8.35, -371.65)
				},
				{
					id = "image_soldier_defeat_arm_l",
					a_from = 1,
					play = "loop",
					r = -0.0078,
					frame_duration = 4,
					ease = 0,
					f = 21,
					a_to = 1,
					pos = v(-5.75, -372.1),
					scale = v(0.9799, 1.0222)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_soldier_defeat_arm_l",
					pos = v(-8.35, -371.65)
				},
				{
					id = "image_soldier_defeat_arm_l",
					a_from = 1,
					play = "loop",
					r = -0.0078,
					frame_duration = 2,
					ease = 0,
					f = 29,
					a_to = 1,
					pos = v(-5.75, -372.1),
					scale = v(0.9799, 1.0222)
				},
				{
					id = "image_soldier_defeat_arm_l",
					a_from = 1,
					play = "loop",
					r = -0.0039,
					frame_duration = 1,
					ease = 0,
					f = 31,
					a_to = 1,
					pos = v(-7.5, -371.85),
					scale = v(0.9947, 1.0111)
				},
				{
					id = "image_soldier_defeat_arm_l",
					a_from = 1,
					play = "loop",
					r = -0.002,
					frame_duration = 1,
					ease = 0,
					f = 32,
					a_to = 1,
					pos = v(-7.85, -371.8),
					scale = v(0.9973, 1.0055)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "image_defeat_arrow",
					pos = v(134.45, -370.9)
				},
				{
					id = "image_defeat_arrow",
					a_from = 1,
					play = "loop",
					r = -0.0302,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					f = 5,
					pos = v(135.1, -368.95)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 9,
					id = "image_defeat_arrow",
					pos = v(134.45, -370.9)
				},
				{
					id = "image_defeat_arrow",
					a_from = 1,
					play = "loop",
					r = -0.0302,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					f = 13,
					pos = v(135.1, -368.95)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 17,
					id = "image_defeat_arrow",
					pos = v(134.45, -370.9)
				},
				{
					id = "image_defeat_arrow",
					a_from = 1,
					play = "loop",
					r = -0.0302,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					f = 21,
					pos = v(135.1, -368.95)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 25,
					id = "image_defeat_arrow",
					pos = v(134.45, -370.9)
				},
				{
					id = "image_defeat_arrow",
					a_from = 1,
					play = "loop",
					r = -0.0302,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					f = 29,
					pos = v(135.1, -368.95)
				},
				{
					id = "image_defeat_arrow",
					a_from = 1,
					play = "loop",
					r = -0.0151,
					frame_duration = 1,
					ease = 0,
					f = 31,
					a_to = 1,
					pos = v(134.8, -369.9),
					scale = v(1, 1)
				},
				{
					id = "image_defeat_arrow",
					a_from = 1,
					play = "loop",
					r = -0.0076,
					frame_duration = 1,
					ease = 0,
					f = 32,
					a_to = 1,
					pos = v(134.65, -370.35),
					scale = v(1, 1)
				}
			}
		},
		{
			id = "timeline_defeat",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 48,
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					r = -0.0743,
					id = "image_arrow5b",
					image_name = "victory_defeat_image_arrow5_",
					pos = v(443.5, -328.55),
					scale = v(1.5177, 0.807),
					anchor = v(42, 41.05)
				},
				{
					class = "KImageView",
					r = -0.0823,
					id = "image_arrow4",
					image_name = "victory_defeat_image_arrow4_",
					pos = v(304.6, -261.95),
					scale = v(0.8677, 1.1419),
					anchor = v(48.15, 20.4)
				},
				{
					class = "KImageView",
					r = -0.5316,
					id = "image_arrow2b",
					image_name = "victory_defeat_image_arrow2_",
					pos = v(-456.6, -468.95),
					scale = v(1.329, 0.8451),
					anchor = v(32.85, 23.8)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_arrow3_",
					id = "image_arrow3",
					pos = v(-287.45, -343.05),
					scale = v(0.8204, 1.0593),
					anchor = v(47.55, 46.25)
				},
				{
					id = "chain",
					image_name = "victory_defeat_image_chain_",
					class = "KImageView",
					pos = v(57.1, -240.25),
					anchor = v(29.6, 13.45)
				},
				{
					id = "chain2",
					image_name = "victory_defeat_image_chain_",
					class = "KImageView",
					pos = v(-84.65, -240.25),
					anchor = v(29.6, 13.45)
				},
				{
					focus_image_name = "victory_defeat_button_ingame_quit_0003",
					class = "GG5Button",
					id = "button_continue",
					default_image_name = "victory_defeat_button_ingame_quit_0001",
					pos = v(72.55, -119.1),
					image_offset = v(-56.05, -52.45),
					hit_rect = r(-56.05, -52.45, 108.6, 108),
					children = {
						{
							id = "image_icon_continue",
							image_name = "victory_defeat_image_icon_continue_",
							class = "KImageView",
							pos = v(0, -2.1),
							anchor = v(18.4, 20.9)
						}
					}
				},
				{
					focus_image_name = "victory_defeat_button_ingame_quit_0003",
					class = "GG5Button",
					id = "button_restart",
					default_image_name = "victory_defeat_button_ingame_quit_0001",
					pos = v(-74.2, -107),
					image_offset = v(-56.05, -52.45),
					hit_rect = r(-56.05, -52.45, 108.6, 108),
					children = {
						{
							id = "image_icon_restart",
							image_name = "victory_defeat_image_icon_restart_",
							class = "KImageView",
							pos = v(-0.15, -1.65),
							anchor = v(22.05, 23)
						}
					}
				},
				{
					id = "image_defeatflag1",
					image_name = "victory_defeat_image_defeatflag1_",
					class = "KImageView",
					pos = v(-186.7, -223.25),
					anchor = v(84.95, 94.5)
				},
				{
					id = "image_defeatflag2",
					image_name = "victory_defeat_image_defeatflag2_",
					class = "KImageView",
					pos = v(181.3, -227.4),
					anchor = v(87.35, 109.85)
				},
				{
					id = "subframe_desktop",
					image_name = "victory_defeat_image_subframe_desktop_",
					class = "KImageView",
					pos = v(-6.85, -207.45),
					anchor = v(149.7, 55.55)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_subframe_",
					id = "subframe",
					pos = v(-4, -205.75),
					WHEN = ctx.is_mobile,
					anchor = v(172.25, 47.3)
				},
				{
					id = "main_shadow",
					image_name = "victory_defeat_image_main_shadow_",
					class = "KImageView",
					pos = v(-5.2, -224.25),
					anchor = v(318.6, 114)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_mainframe_",
					id = "mainframe",
					pos = v(-3.6, -239.65),
					scale = v(0.6883, 0.6883),
					anchor = v(292.85, 86.05)
				},
				{
					id = "animation_gem",
					class = "GGAni",
					pos = v(-3.6, -284.25),
					anchor = v(95.2, -95.9),
					animation = {
						to = 25,
						prefix = "victory_defeat_animation_gem",
						from = 1
					}
				},
				{
					class = "KImageView",
					r = -0.0563,
					id = "image_arrow2",
					image_name = "victory_defeat_image_arrow2_",
					pos = v(-450.5, -278.5),
					scale = v(1.3291, 0.8452),
					anchor = v(32.85, 23.8)
				},
				{
					class = "KImageView",
					r = 0.1161,
					id = "image_arrow1",
					image_name = "victory_defeat_image_arrow1_",
					pos = v(-296.95, -242),
					scale = v(0.8272, 1.2087),
					anchor = v(32.85, 23.8)
				},
				{
					class = "KImageView",
					r = 0.3645,
					id = "image_arrow5",
					image_name = "victory_defeat_image_arrow5_",
					pos = v(358.15, -436),
					scale = v(1.5177, 0.8071),
					anchor = v(42, 41.05)
				},
				{
					class = "KImageView",
					r = 0.056,
					id = "image_arrow6",
					image_name = "victory_defeat_image_arrow6_",
					pos = v(266.8, -330.2),
					scale = v(0.8503, 1.0303),
					anchor = v(42, 41.05)
				}
			},
			timeline = {
				{
					alpha = 0.5,
					a_from = 1,
					play = "loop",
					r = -0.0743,
					frame_duration = 1,
					ease = 0,
					f = 29,
					a_to = 1,
					id = "image_arrow5b",
					pos = v(443.5, -328.55),
					scale = v(1.5177, 0.807)
				},
				{
					alpha = 0.75,
					a_from = 1,
					play = "loop",
					r = -0.2286,
					frame_duration = 1,
					a_to = 1,
					f = 30,
					id = "image_arrow5b",
					pos = v(359.45, -290.2),
					scale = v(1.1839, 0.9186)
				},
				{
					id = "image_arrow4",
					a_from = 1,
					play = "loop",
					r = -0.0823,
					frame_duration = 1,
					ease = 0,
					f = 31,
					a_to = 1,
					pos = v(304.6, -261.95),
					scale = v(0.8677, 1.1419)
				},
				{
					id = "image_arrow4",
					a_from = 1,
					play = "loop",
					r = 0.2036,
					frame_duration = 2,
					ease = 0,
					f = 32,
					a_to = 1,
					pos = v(306.75, -269.95),
					scale = v(1.0492, 0.9287)
				},
				{
					id = "image_arrow4",
					a_from = 1,
					play = "loop",
					r = -0.0566,
					frame_duration = 2,
					ease = 0,
					f = 34,
					a_to = 1,
					pos = v(309.55, -260.3),
					scale = v(1, 1)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 13,
					id = "image_arrow4",
					f = 36,
					pos = v(308.7, -262.65)
				},
				{
					alpha = 0.5,
					a_from = 1,
					play = "loop",
					r = -0.5316,
					frame_duration = 1,
					ease = 0,
					f = 27,
					a_to = 1,
					id = "image_arrow2b",
					pos = v(-456.6, -468.95),
					scale = v(1.329, 0.8451)
				},
				{
					alpha = 0.75,
					a_from = 1,
					play = "loop",
					r = -0.4455,
					frame_duration = 1,
					a_to = 1,
					f = 28,
					id = "image_arrow2b",
					pos = v(-336.35, -375.95),
					scale = v(1.078, 1.0268)
				},
				{
					id = "image_arrow3",
					a_from = 1,
					play = "loop",
					f = 29,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(-287.45, -343.05),
					scale = v(0.8204, 1.0593)
				},
				{
					id = "image_arrow3",
					a_from = 1,
					play = "loop",
					f = 30,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-301.1, -335.8),
					scale = v(1.1392, 0.8808)
				},
				{
					id = "image_arrow3",
					a_from = 1,
					play = "loop",
					r = -0.0521,
					frame_duration = 2,
					ease = 0,
					f = 32,
					a_to = 1,
					pos = v(-293, -342.8),
					scale = v(1, 1)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 15,
					id = "image_arrow3",
					f = 34,
					pos = v(-295.2, -340.65)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = -50,
					f = 33,
					id = "chain",
					pos = v(57.1, -240.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain",
					f = 38,
					pos = v(57.1, -173.1)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain",
					f = 40,
					pos = v(57.1, -180.3)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 7,
					id = "chain",
					f = 42,
					pos = v(57.1, -177.3)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = -50,
					f = 35,
					id = "chain2",
					pos = v(-84.65, -240.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain2",
					f = 40,
					pos = v(-84.65, -173.1)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain2",
					f = 42,
					pos = v(-84.65, -180.3)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					id = "chain2",
					f = 44,
					pos = v(-84.65, -177.3)
				},
				{
					id = "button_continue",
					frame_duration = 2,
					ease = 0,
					f = 31,
					pos = v(72.55, -119.1)
				},
				{
					id = "button_continue",
					frame_duration = 5,
					ease = -50,
					f = 33,
					pos = v(72.55, -76)
				},
				{
					id = "button_continue",
					f = 38,
					frame_duration = 2,
					pos = v(72.55, -8.9)
				},
				{
					id = "button_continue",
					f = 40,
					frame_duration = 2,
					pos = v(72.55, -16.2)
				},
				{
					id = "button_continue",
					f = 42,
					frame_duration = 7,
					pos = v(72.55, -13.3)
				},
				{
					id = "button_restart",
					frame_duration = 2,
					ease = 0,
					f = 33,
					pos = v(-74.2, -107)
				},
				{
					id = "button_restart",
					frame_duration = 5,
					ease = -50,
					f = 35,
					pos = v(-74.2, -76.15)
				},
				{
					id = "button_restart",
					f = 40,
					frame_duration = 2,
					pos = v(-74.2, -9.05)
				},
				{
					id = "button_restart",
					f = 42,
					frame_duration = 2,
					pos = v(-74.2, -16.25)
				},
				{
					id = "button_restart",
					f = 44,
					frame_duration = 5,
					pos = v(-74.2, -13.3)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 3,
					ease = 0,
					f = 19,
					id = "image_defeatflag1",
					pos = v(-186.7, -223.25)
				},
				{
					id = "image_defeatflag1",
					a_from = 1,
					play = "loop",
					f = 22,
					frame_duration = 3,
					ease = 0,
					a_to = 1,
					pos = v(-186.7, -127.2),
					scale = v(0.937, 1.0652)
				},
				{
					id = "image_defeatflag1",
					a_from = 1,
					play = "loop",
					f = 25,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-186.7, -146.25),
					scale = v(1.0509, 0.9352)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 22,
					id = "image_defeatflag1",
					f = 27,
					pos = v(-186.7, -141.85)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 3,
					ease = 0,
					f = 22,
					id = "image_defeatflag2",
					pos = v(181.3, -227.4)
				},
				{
					id = "image_defeatflag2",
					a_from = 1,
					play = "loop",
					f = 25,
					frame_duration = 3,
					ease = 0,
					a_to = 1,
					pos = v(181.3, -136.85),
					scale = v(0.9536, 1.0818)
				},
				{
					id = "image_defeatflag2",
					a_from = 1,
					play = "loop",
					f = 28,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(181.3, -148.8),
					scale = v(1.0703, 0.9378)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 19,
					id = "image_defeatflag2",
					f = 30,
					pos = v(181.3, -143.6)
				},
				{
					id = "subframe_desktop",
					frame_duration = 12,
					ease = 100,
					f = 10,
					pos = v(-6.85, -207.45)
				},
				{
					id = "subframe_desktop",
					f = 22,
					frame_duration = 27,
					pos = v(-6.5, -154.65)
				},
				{
					id = "subframe",
					frame_duration = 12,
					ease = 100,
					f = 10,
					pos = v(-4, -205.75)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 1,
					frame_duration = 27,
					id = "subframe",
					f = 22,
					pos = v(-3.65, -140.55)
				},
				{
					alpha = 0.33,
					a_from = 1,
					play = "loop",
					id = "main_shadow",
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					f = 9,
					pos = v(-5.2, -224.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 38,
					id = "main_shadow",
					f = 11,
					pos = v(-5.2, -224.25)
				},
				{
					id = "mainframe",
					a_from = 1,
					play = "loop",
					f = 1,
					frame_duration = 8,
					ease = 0,
					alpha = 0.02,
					a_to = 1,
					pos = v(-3.6, -239.65),
					scale = v(0.6883, 0.6883)
				},
				{
					id = "mainframe",
					a_from = 1,
					play = "loop",
					f = 9,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-3.65, -239.65),
					scale = v(1.0932, 1.0932)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 38,
					id = "mainframe",
					f = 11,
					pos = v(-3.6, -239.65)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 25,
					frame_duration = 25,
					id = "animation_gem",
					f = 24,
					pos = v(-3.6, -284.25)
				},
				{
					alpha = 0.5,
					a_from = 1,
					play = "loop",
					r = -0.0563,
					frame_duration = 2,
					ease = 0,
					f = 25,
					a_to = 1,
					id = "image_arrow2",
					pos = v(-450.5, -278.5),
					scale = v(1.3291, 0.8452)
				},
				{
					id = "image_arrow1",
					a_from = 1,
					play = "loop",
					r = 0.1161,
					frame_duration = 1,
					ease = 0,
					f = 27,
					a_to = 1,
					pos = v(-296.95, -242),
					scale = v(0.8272, 1.2087)
				},
				{
					id = "image_arrow1",
					a_from = 1,
					play = "loop",
					r = -0.1213,
					frame_duration = 2,
					ease = 0,
					f = 28,
					a_to = 1,
					pos = v(-310, -250.85),
					scale = v(1.0749, 0.9174)
				},
				{
					id = "image_arrow1",
					a_from = 1,
					play = "loop",
					r = 0.0515,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					f = 30,
					pos = v(-308.15, -242.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 17,
					id = "image_arrow1",
					f = 32,
					pos = v(-307.7, -245)
				},
				{
					alpha = 0.5,
					a_from = 1,
					play = "loop",
					r = 0.3645,
					frame_duration = 2,
					ease = 0,
					f = 27,
					a_to = 1,
					id = "image_arrow5",
					pos = v(358.15, -436),
					scale = v(1.5177, 0.8071)
				},
				{
					id = "image_arrow6",
					a_from = 1,
					play = "loop",
					r = 0.056,
					frame_duration = 1,
					ease = 0,
					f = 29,
					a_to = 1,
					pos = v(266.8, -330.2),
					scale = v(0.8503, 1.0303)
				},
				{
					id = "image_arrow6",
					a_from = 1,
					play = "loop",
					r = 0.3038,
					frame_duration = 2,
					ease = 0,
					f = 30,
					a_to = 1,
					pos = v(265.35, -337.65),
					scale = v(1, 1)
				},
				{
					id = "image_arrow6",
					a_from = 1,
					play = "loop",
					r = 0.0647,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					f = 32,
					pos = v(273.25, -332.2)
				},
				{
					a_from = 1,
					play = "loop",
					r = 0.1387,
					id = "image_arrow6",
					a_to = 1,
					f = 34,
					frame_duration = 15,
					pos = v(270.95, -334.1)
				}
			}
		},
		{
			id = "group_defeattext",
			class = "KView",
			template_name = "group_defeattext",
			pos = v(ctx.sw / 2, 369.7)
		},
		{
			id = "timeline_victory_soldier_start",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 29,
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_soldier_cape_",
					id = "soldier_cape",
					pos = v(-2.55, -278.25),
					scale = v(0.8431, 0.4095),
					anchor = v(223.7, 44)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_soldier_",
					id = "soldier",
					pos = v(-2.55, -314),
					scale = v(0.8431, 0.4095),
					anchor = v(96.85, 144.7)
				}
			},
			timeline = {
				{
					id = "soldier_cape",
					a_from = 1,
					play = "single",
					f = 19,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(-2.55, -278.25),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "soldier_cape",
					a_from = 1,
					play = "loop",
					f = 25,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-5.3, -359.8),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 1,
					id = "soldier_cape",
					f = 29,
					pos = v(-5.35, -351.8)
				},
				{
					id = "soldier",
					a_from = 1,
					play = "single",
					f = 19,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(-2.55, -314),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "soldier",
					a_from = 1,
					play = "loop",
					f = 25,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-5.35, -459.3),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 1,
					id = "soldier",
					f = 29,
					pos = v(-5.35, -439.1)
				}
			}
		},
		{
			id = "timeline_victory_soldier_loop",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 18,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_soldier_cape_",
					id = "soldier_cape",
					pos = v(-5.35, -351.75),
					scale = v(1.0056, 0.9783),
					anchor = v(223.7, 44)
				},
				{
					id = "soldier_torso",
					image_name = "victory_defeat_image_soldier_torso_",
					class = "KImageView",
					pos = v(43.45, -350.25),
					anchor = v(65.4, 47.8)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_soldier_head_",
					id = "soldier_head",
					pos = v(42.35, -441.95),
					scale = v(0.9998, 1.0001),
					anchor = v(58.4, 66.85)
				},
				{
					id = "soldier_medal",
					image_name = "victory_defeat_image_soldier_medal_",
					class = "KImageView",
					pos = v(47.4, -386.3),
					anchor = v(39.65, 32.8)
				},
				{
					id = "soldier_sword",
					image_name = "victory_defeat_image_soldier_sword_",
					class = "KImageView",
					pos = v(11.5, -467.1),
					anchor = v(113.7, 116.7)
				},
				{
					id = "soldier_fist",
					image_name = "victory_defeat_image_soldier_fist_",
					class = "KImageView",
					pos = v(133.7, -344.85),
					anchor = v(27.3, 40.5)
				}
			},
			timeline = {
				{
					id = "soldier_cape",
					a_from = 1,
					play = "loop",
					f = 1,
					frame_duration = 5,
					ease = 0,
					a_to = 1,
					pos = v(-5.35, -351.75),
					scale = v(1.0056, 0.9783)
				},
				{
					id = "soldier_cape",
					a_from = 1,
					play = "loop",
					f = 6,
					frame_duration = 9,
					ease = 0,
					a_to = 1,
					pos = v(-5.35, -351.3),
					scale = v(1.0085, 0.9671)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 3,
					ease = 100,
					f = 15,
					id = "soldier_cape",
					pos = v(-5.35, -352.85)
				},
				{
					id = "soldier_cape",
					a_from = 1,
					play = "loop",
					f = 18,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(-5.35, -352),
					scale = v(1.0043, 0.9833)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 9,
					ease = 100,
					f = 1,
					id = "soldier_torso",
					pos = v(43.45, -350.25)
				},
				{
					id = "soldier_torso",
					a_from = 1,
					play = "loop",
					f = 10,
					frame_duration = 8,
					ease = 0,
					a_to = 1,
					pos = v(43.45, -352.5),
					scale = v(0.9887, 1.0153)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 18,
					id = "soldier_torso",
					pos = v(43.45, -350.25)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					f = 1,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(42.35, -441.95),
					scale = v(0.9998, 1.0001)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 9,
					ease = 100,
					f = 3,
					id = "soldier_head",
					pos = v(42.35, -442.05)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					f = 12,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(42.35, -444.55),
					scale = v(0.9898, 1.006)
				},
				{
					id = "soldier_head",
					a_from = 1,
					play = "loop",
					f = 18,
					frame_duration = 1,
					ease = 0,
					a_to = 1,
					pos = v(42.35, -442.05),
					scale = v(0.9993, 1.0003)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 9,
					ease = 100,
					f = 1,
					id = "soldier_medal",
					pos = v(47.4, -386.3)
				},
				{
					id = "soldier_medal",
					a_from = 1,
					play = "loop",
					f = 10,
					frame_duration = 8,
					ease = 0,
					a_to = 1,
					pos = v(47.3, -388.15),
					scale = v(0.9887, 1.0153)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 18,
					id = "soldier_medal",
					pos = v(47.4, -386.3)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 9,
					ease = 100,
					f = 1,
					id = "soldier_sword",
					pos = v(11.5, -467.1)
				},
				{
					id = "soldier_sword",
					a_from = 1,
					play = "loop",
					f = 10,
					frame_duration = 8,
					ease = 0,
					a_to = 1,
					pos = v(11.5, -472.4),
					scale = v(0.9894, 1.0227)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 18,
					id = "soldier_sword",
					pos = v(11.5, -467.1)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 1,
					id = "soldier_fist",
					pos = v(133.7, -344.85)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 9,
					ease = 100,
					f = 5,
					id = "soldier_fist",
					pos = v(133.7, -344.1)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 4,
					ease = 0,
					f = 14,
					id = "soldier_fist",
					pos = v(133.7, -346.35)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 18,
					id = "soldier_fist",
					pos = v(133.7, -345.15)
				}
			}
		},
		{
			id = "timeline_victory_goblin_start",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 25,
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					class = "KImageView",
					image_name = "victory_defeat_image_goblin_",
					id = "goblin",
					pos = v(-57.05, -293.2),
					scale = v(0.8431, 0.4095),
					anchor = v(89.25, 92.85)
				}
			},
			timeline = {
				{
					id = "goblin",
					a_from = 1,
					play = "single",
					f = 15,
					frame_duration = 6,
					ease = 0,
					a_to = 1,
					pos = v(-57.05, -293.2),
					scale = v(0.8431, 0.4095)
				},
				{
					id = "goblin",
					a_from = 1,
					play = "single",
					f = 21,
					frame_duration = 4,
					ease = 0,
					a_to = 1,
					pos = v(-69.65, -401.25),
					scale = v(0.9941, 1.1387)
				},
				{
					a_from = 1,
					play = "single",
					a_to = 1,
					frame_duration = 1,
					id = "goblin",
					f = 25,
					pos = v(-70, -388.15)
				}
			}
		},
		{
			id = "timeline_victory_goblin_loop",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 10,
			play = "loop",
			pos = v(ctx.sw / 2, 611.9),
			children = {
				{
					id = "goblin_torso",
					image_name = "victory_defeat_image_goblin_torso_",
					class = "KImageView",
					pos = v(-61.4, -326.25),
					anchor = v(52.95, 33.15)
				},
				{
					id = "goblin_arm_r",
					image_name = "victory_defeat_image_goblin_arm_r_",
					class = "KImageView",
					pos = v(-121.85, -360.6),
					anchor = v(37.4, 28.95)
				},
				{
					class = "KImageView",
					r = 0.0055,
					id = "goblin_hair",
					image_name = "victory_defeat_image_goblin_hair_",
					pos = v(-57.75, -451.3),
					scale = v(0.9491, 0.9404),
					anchor = v(46.9, 31.65)
				},
				{
					id = "goblin_head",
					image_name = "victory_defeat_image_goblin_head_",
					class = "KImageView",
					pos = v(-50.75, -419.55),
					anchor = v(70, 55.05)
				},
				{
					id = "goblin_arm_l",
					image_name = "victory_defeat_image_goblin_arm_l_",
					class = "KImageView",
					pos = v(-67.4, -349),
					anchor = v(59.95, 33.3)
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_torso",
					pos = v(-61.4, -326.25)
				},
				{
					id = "goblin_torso",
					a_from = 1,
					play = "loop",
					r = -0.0431,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(-59.2, -328.25),
					scale = v(0.9576, 1.0639)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_torso",
					pos = v(-61.4, -326.25)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_arm_r",
					pos = v(-121.85, -360.6)
				},
				{
					id = "goblin_arm_r",
					a_from = 1,
					play = "loop",
					r = 0.0201,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(-120.25, -361.25),
					scale = v(1.0158, 0.9705)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_arm_r",
					pos = v(-121.85, -360.6)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0055,
					frame_duration = 2,
					ease = 0,
					f = 1,
					a_to = 1,
					pos = v(-57.75, -451.3),
					scale = v(0.9491, 0.9404)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					f = 3,
					frame_duration = 5,
					ease = 0,
					a_to = 1,
					pos = v(-57, -452.05),
					scale = v(0.9446, 0.9446)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0275,
					frame_duration = 2,
					ease = 0,
					f = 8,
					a_to = 1,
					pos = v(-59.5, -448.45),
					scale = v(0.9669, 0.9235)
				},
				{
					id = "goblin_hair",
					a_from = 1,
					play = "loop",
					r = 0.0123,
					frame_duration = 1,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(-58.35, -450.35),
					scale = v(0.955, 0.9348)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 6,
					ease = 0,
					f = 1,
					id = "goblin_head",
					pos = v(-50.75, -419.55)
				},
				{
					id = "goblin_head",
					a_from = 1,
					play = "loop",
					r = 0.0308,
					frame_duration = 3,
					ease = 0,
					f = 7,
					a_to = 1,
					pos = v(-51.95, -417),
					scale = v(1.0234, 0.9773)
				},
				{
					id = "goblin_head",
					a_from = 1,
					play = "loop",
					r = 0.0046,
					frame_duration = 1,
					ease = 0,
					f = 10,
					a_to = 1,
					pos = v(-51.1, -418.8),
					scale = v(1.0058, 0.9943)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = 0,
					f = 1,
					id = "goblin_arm_l",
					pos = v(-67.4, -349)
				},
				{
					id = "goblin_arm_l",
					a_from = 1,
					play = "loop",
					r = 0.0201,
					frame_duration = 4,
					ease = 0,
					f = 6,
					a_to = 1,
					pos = v(-66.1, -350.9),
					scale = v(1.0158, 0.9513)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 1,
					ease = 0,
					f = 10,
					id = "goblin_arm_l",
					pos = v(-67.4, -349)
				}
			}
		},
		{
			id = "timeline_victory",
			fps = 30,
			class = "GGTimeline",
			frame_duration = 138,
			pos = v(ctx.sw / 2, 607.4),
			children = {
				{
					id = "chain",
					image_name = "victory_defeat_image_chain_",
					class = "KImageView",
					pos = v(61.1, -166.35),
					anchor = v(29.6, 13.45)
				},
				{
					id = "chain2",
					image_name = "victory_defeat_image_chain_",
					class = "KImageView",
					pos = v(-81.7, -166.35),
					anchor = v(29.6, 13.45)
				},
				{
					focus_image_name = "victory_defeat_button_ingame_quit_0003",
					class = "GG5Button",
					id = "button_continue",
					default_image_name = "victory_defeat_button_ingame_quit_0001",
					pos = v(76.55, -45.2),
					image_offset = v(-56.05, -52.45),
					hit_rect = r(-56.05, -52.45, 108.6, 108),
					children = {
						{
							id = "image_icon_continue",
							image_name = "victory_defeat_image_icon_continue_",
							class = "KImageView",
							pos = v(0, -2.1),
							anchor = v(18.4, 20.9)
						}
					}
				},
				{
					focus_image_name = "victory_defeat_button_ingame_quit_0003",
					class = "GG5Button",
					id = "button_restart",
					default_image_name = "victory_defeat_button_ingame_quit_0001",
					pos = v(-70.2, -33.1),
					image_offset = v(-56.05, -52.45),
					hit_rect = r(-56.05, -52.45, 108.6, 108),
					children = {
						{
							id = "image_icon_restart",
							image_name = "victory_defeat_image_icon_restart_",
							class = "KImageView",
							pos = v(-0.15, -1.65),
							anchor = v(22.05, 23)
						}
					}
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_subflag_",
					id = "subflag",
					pos = v(-79.85, -184),
					scale = v(0.8404, 1.062),
					anchor = v(94, 58.45)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_subflag_2_",
					id = "subflag_2",
					pos = v(72.75, -183.95),
					scale = v(0.8404, 1.062),
					anchor = v(78.8, 58.45)
				},
				{
					id = "animation_mainflag",
					class = "GGAni",
					pos = v(-3.6, -303.35),
					anchor = v(168.3, -20.5),
					animation = {
						to = 31,
						prefix = "victory_defeat_animation_mainflag",
						from = 1
					}
				},
				{
					id = "animation_star_3",
					class = "GGAni",
					pos = v(35.7, -104.6),
					anchor = v(28.85, 59.35),
					animation = {
						to = 33,
						prefix = "victory_defeat_animation_star_3",
						from = 1
					}
				},
				{
					id = "animation_star_2",
					class = "GGAni",
					pos = v(-25.8, -92.95),
					anchor = v(27.1, 52.45),
					animation = {
						to = 33,
						prefix = "victory_defeat_animation_star_2",
						from = 1
					}
				},
				{
					id = "animation_star_1",
					class = "GGAni",
					pos = v(-86.7, -104.9),
					anchor = v(27.65, 56.7),
					animation = {
						to = 33,
						prefix = "victory_defeat_animation_star_1",
						from = 1
					}
				},
				{
					image_name = "victory_defeat_image_subframe_desktop_",
					class = "KImageView",
					id = "subframe_desktop",
					pos = v(-2.65, -207.45),
					UNLESS = ctx.is_mobile,
					anchor = v(149.7, 55.55)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_subframe_",
					id = "subframe",
					pos = v(-4, -224.85),
					WHEN = ctx.is_mobile,
					anchor = v(172.25, 47.3)
				},
				{
					id = "main_shadow",
					image_name = "victory_defeat_image_main_shadow_",
					class = "KImageView",
					pos = v(-5.1, -243.35),
					anchor = v(318.6, 114)
				},
				{
					class = "KImageView",
					image_name = "victory_defeat_image_mainframe_",
					id = "mainframe",
					pos = v(-3.6, -258.75),
					scale = v(0.6883, 0.6883),
					anchor = v(292.85, 86.05)
				},
				{
					class = "GGAni",
					id = "animation_glow",
					pos = v(-21.3, -341.5),
					scale = v(2, 2),
					anchor = v(147.85, 31.85),
					animation = {
						to = 22,
						prefix = "victory_defeat_animation_glow",
						from = 1
					}
				},
				{
					class = "GGAni",
					id = "animation_gem",
					pos = v(5.6, -316.85),
					scale = v(1.0975, 1.0975),
					anchor = v(95.2, -95.9),
					animation = {
						to = 25,
						prefix = "victory_defeat_animation_gem",
						from = 1
					}
				}
			},
			timeline = {
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = -50,
					f = 71,
					id = "chain",
					pos = v(61.1, -166.35)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain",
					f = 76,
					pos = v(61.1, -99.2)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain",
					f = 78,
					pos = v(61.1, -106.4)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 59,
					id = "chain",
					f = 80,
					pos = v(61.1, -103.4)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 5,
					ease = -50,
					f = 73,
					id = "chain2",
					pos = v(-81.7, -166.35)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain2",
					f = 78,
					pos = v(-81.7, -99.2)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 2,
					id = "chain2",
					f = 80,
					pos = v(-81.7, -106.4)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 57,
					id = "chain2",
					f = 82,
					pos = v(-81.7, -103.4)
				},
				{
					id = "button_continue",
					frame_duration = 2,
					ease = 0,
					f = 69,
					pos = v(76.55, -45.2)
				},
				{
					id = "button_continue",
					frame_duration = 5,
					ease = -50,
					f = 71,
					pos = v(76.55, -2.1)
				},
				{
					id = "button_continue",
					f = 76,
					frame_duration = 2,
					pos = v(76.55, 65)
				},
				{
					id = "button_continue",
					f = 78,
					frame_duration = 2,
					pos = v(76.55, 57.7)
				},
				{
					id = "button_continue",
					f = 80,
					frame_duration = 59,
					pos = v(76.55, 60.6)
				},
				{
					id = "button_restart",
					frame_duration = 2,
					ease = 0,
					f = 71,
					pos = v(-70.2, -33.1)
				},
				{
					id = "button_restart",
					frame_duration = 5,
					ease = -50,
					f = 73,
					pos = v(-70.2, -2.25)
				},
				{
					id = "button_restart",
					f = 78,
					frame_duration = 2,
					pos = v(-70.2, 64.85)
				},
				{
					id = "button_restart",
					f = 80,
					frame_duration = 2,
					pos = v(-70.2, 57.65)
				},
				{
					id = "button_restart",
					f = 82,
					frame_duration = 57,
					pos = v(-70.2, 60.6)
				},
				{
					id = "subflag",
					a_from = 1,
					play = "loop",
					f = 52,
					frame_duration = 3,
					ease = 0,
					a_to = 1,
					pos = v(-79.85, -184),
					scale = v(0.8404, 1.062)
				},
				{
					id = "subflag",
					a_from = 1,
					play = "loop",
					f = 55,
					frame_duration = 3,
					ease = 0,
					a_to = 1,
					pos = v(-214.95, -184),
					scale = v(1.1334, 0.8962)
				},
				{
					id = "subflag",
					a_from = 1,
					play = "loop",
					f = 58,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-182.4, -184),
					scale = v(0.9398, 1.0517)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 79,
					id = "subflag",
					f = 60,
					pos = v(-187.15, -184)
				},
				{
					id = "subflag_2",
					a_from = 1,
					play = "loop",
					f = 52,
					frame_duration = 3,
					ease = 0,
					a_to = 1,
					pos = v(72.75, -183.95),
					scale = v(0.8404, 1.062)
				},
				{
					id = "subflag_2",
					a_from = 1,
					play = "loop",
					f = 55,
					frame_duration = 3,
					ease = 0,
					a_to = 1,
					pos = v(207.85, -183.95),
					scale = v(1.1334, 0.8962)
				},
				{
					id = "subflag_2",
					a_from = 1,
					play = "loop",
					f = 58,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(175.4, -183.95),
					scale = v(0.9398, 1.0516)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 79,
					id = "subflag_2",
					f = 60,
					pos = v(179.9, -184)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 31,
					frame_duration = 87,
					id = "animation_mainflag",
					f = 52,
					pos = v(-3.6, -303.35)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 33,
					frame_duration = 34,
					id = "animation_star_3",
					f = 105,
					pos = v(35.7, -104.6)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 33,
					frame_duration = 48,
					id = "animation_star_2",
					f = 91,
					pos = v(-25.8, -92.95)
				},
				{
					a_from = 1,
					play = "once",
					a_to = 33,
					frame_duration = 60,
					id = "animation_star_1",
					f = 79,
					pos = v(-86.7, -104.9)
				},
				{
					id = "subframe_desktop",
					frame_duration = 12,
					ease = 100,
					f = 10,
					pos = v(-2.65, -207.45)
				},
				{
					id = "subframe_desktop",
					f = 22,
					frame_duration = 117,
					pos = v(-2.3, -175.35)
				},
				{
					id = "subframe",
					frame_duration = 12,
					ease = 100,
					f = 10,
					pos = v(-4, -224.85)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 117,
					id = "subframe",
					f = 22,
					pos = v(-3.65, -159.65)
				},
				{
					alpha = 0.33,
					a_from = 1,
					play = "loop",
					id = "main_shadow",
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					f = 9,
					pos = v(-5.1, -243.35)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 128,
					id = "main_shadow",
					f = 11,
					pos = v(-5.1, -243.35)
				},
				{
					id = "mainframe",
					a_from = 1,
					play = "loop",
					f = 1,
					frame_duration = 8,
					ease = 0,
					alpha = 0.02,
					a_to = 1,
					pos = v(-3.6, -258.75),
					scale = v(0.6883, 0.6883)
				},
				{
					id = "mainframe",
					a_from = 1,
					play = "loop",
					f = 9,
					frame_duration = 2,
					ease = 0,
					a_to = 1,
					pos = v(-3.65, -258.75),
					scale = v(1.0932, 1.0932)
				},
				{
					a_from = 1,
					play = "loop",
					a_to = 1,
					frame_duration = 128,
					id = "mainframe",
					f = 11,
					pos = v(-3.6, -258.75)
				},
				{
					f = 10,
					a_from = 1,
					play = "once",
					id = "animation_glow",
					a_to = 22,
					frame_duration = 22,
					pos = v(-21.3, -341.5),
					scale = v(2, 2)
				},
				{
					f = 24,
					a_from = 1,
					play = "once",
					id = "animation_gem",
					a_to = 25,
					frame_duration = 115,
					pos = v(5.6, -316.85),
					scale = v(1.0975, 1.0975)
				}
			}
		},
		{
			id = "group_victorytext",
			class = "KView",
			template_name = "group_victorytext",
			pos = v(ctx.sw / 2, 348.05)
		}
	}
}
