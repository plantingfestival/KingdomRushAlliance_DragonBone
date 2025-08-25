local function v(v1, v2)
	return {
		x = v1,
		y = v2
	}
end

local function fts(v)
	return v / FPS
end

local heroes = {
	common = {
		melee_attack_range = 72,
		xp_level_steps = {
			1,
			nil,
			2,
			nil,
			nil,
			nil,
			3,
			[9] = 3
		},
		xp_level_steps_ulti = {
			1,
			[10] = 3,
			[5] = 2
		}
	},
	hero_king_denas = {
		dead_lifetime = 18,
		speed = 75,
		regen_cooldown = 1,
		armor = {
			0.05,
			0.06,
			0.08,
			0.1,
			0.12,
			0.15,
			0.18,
			0.22,
			0.26,
			0.31
		},
		hp_max = {
			200,
			215,
			230,
			250,
			270,
			300,
			320,
			340,
			370,
			400
		},
		melee_damage_max = {
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			15,
			16,
			18
		},
		melee_damage_min = {
			5,
			5,
			6,
			7,
			8,
			8,
			9,
			10,
			11,
			12
		},
		regen_health = {
			16,
			17,
			18,
			20,
			22,
			24,
			26,
			27,
			30,
			32
		},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 10
		},
		mighty = {
			available = true,
			cooldown = 18,
			damage_radius = 37.5,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				36,
				47,
				58,
				72
			},
			damage_min = {
				24,
				31,
				38,
				48
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				810,
				810,
				810,
				810
			}
		},
		sybarite = {
			available = true,
			lost_health = 0.65,
			cooldown = {
				25,
				25,
				25,
				25
			},
			heal_hp = {
				45,
				75,
				120,
				175
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				1125,
				1125,
				1125,
				1125
			}
		},
		kings_speech = {
			max_range = 250,
			available = true,
			min_range = 0,
			duration = {
				4,
				6,
				8,
				10
			},
			cooldown_factor = {
				0.9,
				0.85,
				0.8,
				0.75
			},
			cooldown = {
				30,
				30,
				30,
				30
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				1350,
				1350,
				1350,
				1350
			}
		},
		pounding_smash = {
			radius = 165,
			min_targets = 2,
			available = true,
			duration = {
				2,
				3,
				4,
				5
			},
			cooldown = {
				22,
				22,
				22,
				22
			},
			damage_max = {
				12,
				16,
				20,
				24
			},
			damage_min = {
				8,
				10,
				14,
				16
			},
			damage_type = DAMAGE_PHYSICAL,
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				990,
				990,
				990,
				990
			}
		},
		ultimate = {
			radius = 75,
			damage_every = 0.5,
			xp_level_steps = {
				1,
				[10] = 3,
				[5] = 2
			},
			duration = {
				4,
				6,
				8,
				10
			},
			cooldown = {
				50,
				50,
				50,
				50
			},
			damage_min = {
				8,
				10,
				14,
				16
			},
			damage_max = {
				12,
				16,
				20,
				24
			},
			damage_type = DAMAGE_PHYSICAL
		}
	},
	hero_alleria5 = {
		dead_lifetime = 22,
		block_range = 67.5,
		speed = 90,
		regen_cooldown = 1,
		armor = {
			0.03,
			0.04,
			0.05,
			0.06,
			0.07,
			0.08,
			0.09,
			0.1,
			0.11,
			0.12
		},
		hp_max = {
			175,
			185,
			200,
			210,
			220,
			235,
			250,
			260,
			280,
			300
		},
		melee_damage_max = {
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			14,
			16,
			18
		},
		melee_damage_min = {
			2,
			3,
			3,
			3,
			4,
			4,
			5,
			6,
			6,
			7
		},
		regen_health = {
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			21,
			22,
			24
		},
		basic_melee = {
			cooldown = 0.8,
			xp_gain_factor = 10
		},
		basic_ranged = {
			max_range = 215,
			xp_gain_factor = 10,
			cooldown = 0.8,
			min_range = 67.5,
			damage_max = {
				6,
				7,
				8,
				9,
				10,
				11,
				12,
				14,
				16,
				18
			},
			damage_min = {
				2,
				3,
				3,
				3,
				4,
				4,
				5,
				6,
				6,
				7
			}
		},
		go_for_the_throat = {
			bleed_every = 1,
			cooldown = 18,
			available = true,
			bleed_duration = 5,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				42,
				55,
				68,
				84
			},
			damage_min = {
				28,
				36,
				45,
				55
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				810,
				810,
				810,
				810
			},
			bleed_damage_min = {
				3,
				6,
				9,
				12
			},
			bleed_damage_max = {
				3,
				6,
				9,
				12
			}
		},
		rangers_camouflage = {
			available = true,
			distance = 150,
			min_distance_from_end = 200,
			cooldown = {
				22,
				20,
				18,
				16
			},
			duration = {
				3,
				6,
				9,
				12
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				990,
				900,
				810,
				720
			}
		},
		whistling_arrow = {
			max_range = 215,
			available = true,
			min_range = 67.5,
			bounce_range = 300,
			cooldown = {
				20,
				18,
				16,
				14
			},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				6,
				8,
				10,
				12
			},
			damage_min = {
				4,
				5,
				6,
				8
			},
			stun_duration = {
				3,
				3,
				3,
				3
			},
			bounces = {
				1,
				2,
				3,
				4
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				900,
				810,
				720,
				630
			}
		},
		chilling_roar = {
			min_targets = 2,
			available = true,
			max_range_trigger = 150,
			max_range_effect = 200,
			cooldown = {
				25,
				25,
				25,
				25
			},
			damage_factor = {
				0.25,
				0.4,
				0.6,
				0.75
			},
			debuff_duration = {
				4,
				6,
				8,
				10
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				1125,
				1125,
				1125,
				1125
			}
		},
		ultimate = {
			radius = 90,
			time_between_arrows = 0.1,
			xp_level_steps = {
				1,
				[10] = 3,
				[5] = 2
			},
			cooldown = {
				30,
				30,
				30,
				30
			},
			arrows = {
				5,
				7,
				9,
				12
			},
			damage_min = {
				32,
				42,
				52,
				65
			},
			damage_max = {
				40,
				50,
				64,
				80
			},
			damage_type = DAMAGE_PHYSICAL
		}
	},
	hero_velann = {
		dead_lifetime = 25,
		speed = 50,
		teleport_min_distance = 80,
		regen_cooldown = 1,
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			120,
			125,
			135,
			145,
			150,
			160,
			170,
			180,
			190,
			200
		},
		regen_health = {
			12,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20
		},
		basic_melee = {
			cooldown = 2,
			xp_gain_factor = 20,
			damage_max = {
				8,
				9,
				10,
				11,
				12,
				14,
				15,
				17,
				20,
				22
			},
			damage_min = {
				5,
				6,
				7,
				7,
				8,
				9,
				10,
				11,
				13,
				14
			}
		},
		basic_ranged = {
			max_range = 225,
			xp_gain_factor = 20,
			cooldown = 2,
			min_range = 67.5,
			damage_max = {
				15,
				18,
				19,
				21,
				24,
				27,
				30,
				34,
				38,
				44
			},
			damage_min = {
				10,
				12,
				13,
				14,
				16,
				18,
				20,
				22,
				25,
				28
			}
		},
		imp_config = {
			max_range = 102.4,
			duration = {
				10,
				10,
				10,
				10
			},
			cooldown = {
				1,
				1,
				1,
				1
			},
			hp_max = {
				20,
				25,
				30,
				40
			},
			damage_max = {
				3,
				3,
				4,
				5
			},
			damage_min = {
				1,
				2,
				2,
				3
			},
			xp_level_steps = {
				1,
				1,
				2,
				2,
				2,
				2,
				3,
				3,
				3,
				3
			}
		},
		void_prison = {
			max_range_effect = 175,
			min_targets = 1,
			available = true,
			max_range_trigger = 150,
			cooldown = {
				22,
				22,
				22,
				22
			},
			max_targets = {
				2,
				3,
				4,
				6
			},
			damage_type = DAMAGE_MAGICAL,
			damage = {
				30,
				52,
				64,
				100
			},
			duration = {
				3,
				4,
				4,
				5
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				990,
				990,
				990,
				990
			}
		},
		friends_on_the_other_side = {
			available = true,
			cooldown = {
				25,
				25,
				25,
				25
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				1125,
				1125,
				1125,
				1125
			},
			imp = {
				cooldown = {
					1,
					1,
					1,
					1
				},
				damage_max = {
					6,
					7,
					9,
					12
				},
				damage_min = {
					4,
					5,
					6,
					8
				},
				hp_max = {
					30,
					40,
					50,
					60
				}
			}
		},
		voices_from_beyond = {
			max_range = 150,
			available = true,
			duration = {
				5,
				7,
				8,
				10
			},
			damage_max = {
				40,
				50,
				60,
				80
			},
			damage_min = {
				20,
				30,
				35,
				40
			},
			damage_type = DAMAGE_MAGICAL,
			inflicted_damage_factor = {
				0.8,
				0.7,
				0.6,
				0.5
			},
			received_damage_factor = {
				1,
				1,
				1,
				1
			},
			cooldown = {
				30,
				30,
				30,
				30
			},
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				1350,
				1350,
				1350,
				1350
			}
		},
		void_rift = {
			radius = 60,
			min_targets = 2,
			max_range_trigger = 150,
			max_range_effect = 175,
			damage_every = 0.2,
			available = true,
			duration = {
				4,
				6,
				8,
				10
			},
			cooldown = {
				28,
				28,
				28,
				28
			},
			damage_max = {
				10,
				20,
				30,
				50
			},
			damage_min = {
				6,
				12,
				20,
				32
			},
			min_damage_to_spawn = {
				100,
				200,
				300,
				400
			},
			heal_factor = {
				0.3,
				0.5,
				0.7,
				0.9
			},
			damage_type = DAMAGE_MAGICAL,
			xp_level_steps = {
				1,
				nil,
				2,
				nil,
				nil,
				nil,
				3,
				[9] = 3
			},
			xp_gain = {
				1260,
				1260,
				1260,
				1260
			}
		},
		ultimate = {
			xp_level_steps = {
				1,
				[10] = 3,
				[5] = 2
			},
			cooldown = {
				100,
				90,
				80,
				70
			},
			entity = {
				speed = 138,
				cooldown = {
					0.5,
					0.5,
					0.5,
					0.5
				},
				damage_min = {
					8,
					10,
					12,
					12
				},
				damage_max = {
					12,
					15,
					20,
					20
				},
				damage_type = DAMAGE_PHYSICAL,
				hp_max = {
					150,
					170,
					180,
					180
				},
				regen_health = {
					30,
					34,
					36,
					36
				}
			}
		}
	},
	hero_space_elf = {
		speed = 90,
		dead_lifetime = 25,
		teleport_min_distance = 200,
		regen_cooldown = 1,
		stats = {
			cooldown = 5,
			armor = 0,
			hp = 5,
			damage = 6
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			160,
			175,
			190,
			205,
			220,
			235,
			250,
			265,
			280,
			295
		},
		regen_health = {
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			21,
			22
		},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 2.36,
			damage_max = {
				7,
				9,
				11,
				13,
				15,
				17,
				19,
				21,
				23,
				25
			},
			damage_min = {
				5,
				6,
				7,
				8,
				9,
				10,
				11,
				12,
				13,
				15
			}
		},
		basic_ranged = {
			max_range = 160,
			xp_gain_factor = 1.6,
			cooldown = 1.5,
			min_range = 0,
			damage_max = {
				20,
				23,
				26,
				29,
				32,
				35,
				38,
				41,
				44,
				48
			},
			damage_min = {
				11,
				13,
				15,
				17,
				19,
				21,
				23,
				25,
				27,
				29
			},
			damage_type = DAMAGE_MAGICAL
		},
		astral_reflection = {
			max_range = 210,
			cooldown = {
				20,
				15,
				10
			},
			xp_gain = {
				25,
				50,
				75
			},
			entity = {
				range = 45,
				duration = 20,
				hp_max = {
					50,
					100,
					150
				},
				basic_melee = {
					cooldown = 1,
					damage_type = DAMAGE_MAGICAL,
					damage_min = {
						14,
						20,
						26
					},
					damage_max = {
						25,
						35,
						45
					}
				},
				basic_ranged = {
					max_range = 160,
					min_range = 0,
					cooldown = 1.5,
					damage_type = DAMAGE_MAGICAL,
					damage_min = {
						14,
						20,
						26
					},
					damage_max = {
						25,
						35,
						45
					}
				}
			}
		},
		black_aegis = {
			range = 200,
			explosion_range = 80,
			xp_gain = {
				18,
				36,
				54
			},
			cooldown = {
				18,
				16,
				14
			},
			duration = {
				6,
				9,
				12
			},
			shield_base = {
				60,
				120,
				240
			},
			explosion_damage = {
				120,
				240,
				480
			},
			explosion_damage_type = DAMAGE_MAGICAL
		},
		void_rift = {
			radius = 100,
			min_targets = 2,
			max_range_effect = 300,
			max_range_trigger = 200,
			damage_every = 0.25,
			cooldown = {
				30,
				25,
				20
			},
			xp_gain = {
				30,
				60,
				90
			},
			duration = {
				6,
				8,
				10
			},
			cracks_amount = {
				1,
				2,
				3
			},
			damage_min = {
				3,
				6,
				9
			},
			damage_max = {
				4,
				8,
				12
			},
			damage_type = DAMAGE_MAGICAL
		},
		spatial_distortion = {
			cooldown = {
				25,
				20,
				15
			},
			duration = {
				6,
				9,
				12
			},
			xp_gain = {
				25,
				50,
				75
			},
			range_factor = {
				1.1,
				1.15,
				1.2
			},
			s_range_factor = {
				0.1,
				0.15,
				0.2
			}
		},
		ultimate = {
			radius = 100,
			cooldown = {
				45,
				40,
				35,
				30
			},
			damage = {
				30,
				90,
				210,
				390
			},
			damage_type = DAMAGE_TRUE,
			duration = {
				5,
				6,
				7,
				8
			}
		}
	},
	hero_muyrn = {
		distance_to_treewalk = 150,
		speed = 75,
		treewalk_speed = 95,
		dead_lifetime = 30,
		regen_cooldown = 1,
		stats = {
			cooldown = 5,
			armor = 0,
			hp = 6,
			damage = 7
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			125,
			150,
			175,
			200,
			225,
			250,
			275,
			300,
			325,
			350
		},
		regen_health = {
			10,
			11,
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19
		},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 2,
			damage_max = {
				10,
				12,
				14,
				16,
				18,
				20,
				22,
				24,
				26,
				28
			},
			damage_min = {
				6,
				7,
				8,
				9,
				10,
				11,
				12,
				13,
				14,
				15
			}
		},
		basic_ranged = {
			max_range = 180,
			xp_gain_factor = 1.52,
			cooldown = 1.5,
			min_range = 0,
			damage_max = {
				27,
				30,
				33,
				36,
				39,
				42,
				45,
				48,
				51,
				54
			},
			damage_min = {
				9,
				11,
				13,
				15,
				17,
				19,
				21,
				23,
				25,
				27
			},
			damage_type = DAMAGE_MAGICAL
		},
		sentinel_wisps = {
			max_range_trigger = 200,
			min_targets = 1,
			cooldown = {
				25,
				20,
				15
			},
			max_summons = {
				1,
				2,
				3
			},
			wisp = {
				shoot_range = 200,
				cooldown = 1,
				hero_max_distance = 100,
				duration = {
					6,
					9,
					12
				},
				damage_min = {
					3,
					7,
					11
				},
				damage_max = {
					4,
					10,
					16
				},
				damage_type = DAMAGE_MAGICAL
			},
			xp_gain = {
				25,
				50,
				75
			}
		},
		verdant_blast = {
			max_range = 300,
			min_range = 100,
			radius = 60,
			cooldown = {
				30,
				25,
				20
			},
			damage_max = {
				150,
				300,
				450
			},
			damage_min = {
				150,
				300,
				450
			},
			s_damage = {
				150,
				300,
				450
			},
			damage_type = DAMAGE_MAGICAL,
			xp_gain = {
				30,
				60,
				90
			}
		},
		leaf_whirlwind = {
			radius = 65,
			min_targets = 1,
			max_range_trigger = 75,
			heal_every = 0.25,
			damage_every = 0.25,
			cooldown = {
				35,
				30,
				25
			},
			duration = {
				8,
				12,
				16
			},
			damage_type = DAMAGE_MAGICAL,
			damage_max = {
				6,
				12,
				20
			},
			damage_min = {
				4,
				8,
				14
			},
			s_damage_min = {
				16,
				32,
				56
			},
			s_damage_max = {
				24,
				48,
				80
			},
			heal_max = {
				4,
				8,
				12
			},
			heal_min = {
				4,
				8,
				12
			},
			xp_gain = {
				40,
				80,
				120
			}
		},
		faery_dust = {
			radius = 100,
			min_targets = 3,
			max_range_trigger = 160,
			max_range_effect = 180,
			cooldown = {
				20,
				17,
				14
			},
			duration = {
				5,
				8,
				11
			},
			damage_factor = {
				0.4,
				0.25,
				0.1
			},
			s_damage_factor = {
				0.6,
				0.75,
				0.9
			},
			xp_gain = {
				25,
				50,
				75
			}
		},
		ultimate = {
			radius = 60,
			damage_every = 0.25,
			cooldown = {
				40,
				40,
				40,
				40
			},
			slow_factor = {
				0.6,
				0.5,
				0.4,
				0.3
			},
			roots_count = {
				10,
				15,
				20,
				25
			},
			duration = {
				4,
				6,
				8,
				10
			},
			damage_type = DAMAGE_TRUE,
			damage_min = {
				4,
				6,
				8,
				10
			},
			damage_max = {
				6,
				9,
				12,
				15
			},
			s_damage_min = {
				16,
				24,
				32,
				40
			},
			s_damage_max = {
				24,
				36,
				48,
				60
			}
		}
	},
	hero_vesper = {
		dead_lifetime = 30,
		speed = 75,
		regen_cooldown = 1,
		stats = {
			cooldown = 8,
			armor = 4,
			hp = 5,
			damage = 4
		},
		armor = {
			0,
			0.04,
			0.08,
			0.12,
			0.16,
			0.2,
			0.24,
			0.28,
			0.34,
			0.4
		},
		hp_max = {
			160,
			175,
			190,
			205,
			220,
			235,
			250,
			265,
			280,
			300
		},
		regen_health = {
			12,
			13,
			14,
			15,
			16,
			17,
			18,
			19,
			20,
			21
		},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 2,
			damage_max = {
				10,
				12,
				14,
				16,
				18,
				20,
				22,
				24,
				26,
				28
			},
			damage_min = {
				6,
				7,
				8,
				9,
				10,
				11,
				12,
				13,
				14,
				15
			}
		},
		basic_ranged_short = {
			max_range = 150,
			xp_gain_factor = 2,
			cooldown = 1,
			min_range = 50,
			damage_max = {
				10,
				12,
				14,
				16,
				18,
				20,
				22,
				24,
				26,
				28
			},
			damage_min = {
				6,
				7,
				8,
				9,
				10,
				11,
				12,
				13,
				14,
				15
			}
		},
		basic_ranged_long = {
			max_range = 250,
			xp_gain_factor = 2,
			cooldown = 2,
			min_range = 150,
			damage_max = {
				14,
				17,
				20,
				23,
				26,
				29,
				32,
				35,
				38,
				41
			},
			damage_min = {
				10,
				12,
				14,
				16,
				18,
				20,
				22,
				24,
				26,
				28
			}
		},
		arrow_to_the_knee = {
			max_range = 250,
			min_range = 50,
			cooldown = {
				14,
				12,
				10
			},
			damage_min = {
				40,
				80,
				160
			},
			damage_max = {
				40,
				80,
				160
			},
			s_damage = {
				40,
				80,
				160
			},
			stun_duration = {
				2,
				4,
				6
			},
			xp_gain = {
				14,
				24,
				30
			}
		},
		ricochet = {
			max_range = 200,
			min_range = 50,
			min_targets = 3,
			max_range_trigger = 200,
			bounce_range = 120,
			cooldown = {
				20,
				20,
				20
			},
			damage_min = {
				35,
				70,
				105
			},
			damage_max = {
				35,
				70,
				105
			},
			s_damage = {
				35,
				70,
				105
			},
			bounces = {
				2,
				4,
				7
			},
			s_bounces = {
				3,
				5,
				8
			},
			damage_type = DAMAGE_PHYSICAL,
			xp_gain = {
				20,
				40,
				60
			}
		},
		martial_flourish = {
			cooldown = {
				16,
				14,
				12
			},
			damage_min = {
				30,
				60,
				90
			},
			damage_max = {
				30,
				60,
				90
			},
			s_damage = {
				90,
				180,
				270
			},
			damage_type = DAMAGE_TRUE,
			xp_gain = {
				16,
				32,
				48
			}
		},
		disengage = {
			distance = 130,
			total_shoots = 3,
			hp_to_trigger = 0.9,
			min_distance_from_end = 300,
			cooldown = {
				20,
				18,
				16
			},
			damage_min = {
				60,
				120,
				200
			},
			damage_max = {
				60,
				120,
				200
			},
			s_damage = {
				60,
				120,
				200
			},
			xp_gain = {
				20,
				40,
				60
			}
		},
		ultimate = {
			enemies_range = 100,
			node_prediction_offset = 0,
			duration = 0.8,
			spread = {
				8,
				12,
				16,
				20
			},
			s_spread = {
				16,
				24,
				32,
				40
			},
			damage = {
				20,
				35,
				50,
				65
			},
			cooldown = {
				45,
				45,
				45,
				45
			}
		}
	},
	hero_lumenir = {
		dead_lifetime = 30,
		speed = 120,
		regen_cooldown = 1,
		stats = {
			cooldown = 4,
			armor = 4,
			hp = 8,
			damage = 9
		},
		armor = {
			0,
			0.04,
			0.08,
			0.12,
			0.16,
			0.2,
			0.24,
			0.28,
			0.32,
			0.36
		},
		hp_max = {
			275,
			300,
			325,
			350,
			375,
			400,
			425,
			450,
			475,
			500
		},
		regen_health = {
			22,
			24,
			26,
			28,
			30,
			32,
			34,
			36,
			38,
			40
		},
		mini_dragon_death = {
			max_range = 180,
			cooldown = 1,
			min_range = 0,
			damage_type = DAMAGE_TRUE,
			damage_max = {
				12,
				15,
				18,
				21,
				24,
				27,
				30,
				33,
				36,
				39
			},
			damage_min = {
				8,
				10,
				12,
				14,
				16,
				18,
				20,
				22,
				24,
				26
			}
		},
		basic_ranged_shot = {
			max_range = 240,
			xp_gain_factor = 1.46,
			cooldown = 2,
			min_range = 0,
			damage_type = DAMAGE_TRUE,
			damage_max = {
				26,
				31,
				36,
				42,
				47,
				52,
				57,
				62,
				68,
				74
			},
			damage_min = {
				14,
				17,
				20,
				22,
				25,
				28,
				31,
				34,
				36,
				38
			}
		},
		fire_balls = {
			max_range = 250,
			damage_radius = 55,
			min_targets = 3,
			damage_rate = 0.2,
			min_range = 50,
			duration = 8,
			cooldown = {
				20,
				18,
				16
			},
			damage_type = DAMAGE_TRUE,
			xp_gain = {
				20,
				40,
				60
			},
			flames_count = {
				5,
				6,
				7
			},
			flame_damage_min = {
				5,
				10,
				15
			},
			flame_damage_max = {
				7,
				14,
				21
			}
		},
		mini_dragon = {
			max_range = 180,
			min_range = 0,
			cooldown = {
				30,
				25,
				20
			},
			damage_type = DAMAGE_TRUE,
			xp_gain = {
				30,
				60,
				90
			},
			dragon = {
				max_speed = 75,
				duration = {
					15,
					20,
					25
				},
				ranged_attack = {
					max_range = 180,
					cooldown = 1,
					min_range = 0,
					damage_type = DAMAGE_PHYSICAL,
					damage_min = {
						10,
						16,
						22
					},
					damage_max = {
						14,
						24,
						34
					}
				}
			}
		},
		celestial_judgement = {
			range = 300,
			stun_range = 50,
			stun_duration = {
				2,
				3,
				4
			},
			cooldown = {
				35,
				35,
				35
			},
			damage = {
				180,
				360,
				540
			},
			damage_type = DAMAGE_TRUE,
			xp_gain = {
				35,
				70,
				105
			}
		},
		shield = {
			min_targets = 2,
			range = 1000,
			spiked_armor = {
				0.2,
				0.4,
				0.6
			},
			armor = {
				0.1,
				0.2,
				0.3
			},
			duration = {
				10,
				13,
				16
			},
			cooldown = {
				20,
				20,
				20
			},
			xp_gain = {
				20,
				40,
				60
			}
		},
		ultimate = {
			range = 200,
			stun_target_duration = 6,
			stun_range = 50,
			max_attack_count = 3,
			stun_duration = 6,
			damage_max = {
				19,
				29,
				48,
				77
			},
			damage_min = {
				13,
				19,
				32,
				51
			},
			soldier_count = {
				3,
				4,
				5,
				6
			},
			cooldown = {
				30,
				30,
				30,
				30
			},
			damage_type = DAMAGE_TRUE
		}
	},
	hero_raelyn = {
		dead_lifetime = 30,
		speed = 50,
		regen_cooldown = 1,
		stats = {
			cooldown = 4,
			armor = 5,
			hp = 8,
			damage = 6
		},
		armor = {
			0.05,
			0.1,
			0.15,
			0.2,
			0.25,
			0.3,
			0.35,
			0.4,
			0.45,
			0.5
		},
		hp_max = {
			240,
			270,
			300,
			330,
			360,
			390,
			420,
			450,
			480,
			510
		},
		melee_damage_max = {
			24,
			27,
			30,
			33,
			37,
			40,
			43,
			46,
			49,
			53
		},
		melee_damage_min = {
			20,
			22,
			24,
			26,
			28,
			30,
			32,
			34,
			36,
			38
		},
		regen_health = {
			18,
			19,
			21,
			22,
			24,
			26,
			27,
			29,
			30,
			32
		},
		basic_melee = {
			cooldown = 2,
			xp_gain_factor = 2.6
		},
		unbreakable = {
			min_targets = 2,
			max_range_trigger = 100,
			max_range_effect = 200,
			max_targets = 4,
			cooldown = {
				35,
				25,
				15
			},
			duration = {
				6,
				9,
				12
			},
			shield_base = {
				0,
				0,
				0
			},
			shield_per_enemy = {
				0.15,
				0.3,
				0.45
			},
			max_soldiers = {
				2,
				4,
				6
			},
			xp_gain = {
				35,
				70,
				105
			}
		},
		inspire_fear = {
			min_targets = 2,
			max_range_trigger = 75,
			max_range_effect = 150,
			cooldown = {
				30,
				23,
				16
			},
			damage_duration = {
				6,
				6,
				6
			},
			stun_duration = {
				2,
				2,
				2
			},
			inflicted_damage_factor = {
				0.6,
				0.4,
				0.2
			},
			s_inflicted_damage_factor = {
				0.4,
				0.6,
				0.8
			},
			xp_gain = {
				30,
				60,
				90
			}
		},
		brutal_slash = {
			cooldown = {
				30,
				25,
				20
			},
			damage_max = {
				160,
				320,
				640
			},
			damage_min = {
				160,
				320,
				640
			},
			s_damage = {
				160,
				320,
				640
			},
			damage_type = DAMAGE_TRUE,
			xp_gain = {
				30,
				60,
				90
			}
		},
		onslaught = {
			radius = 90,
			min_targets = 2,
			xp_gain_factor = 4,
			max_range_trigger = 150,
			cooldown = {
				24,
				20,
				16
			},
			melee_cooldown = {
				1,
				1,
				1
			},
			duration = {
				6,
				8,
				10
			},
			damage_type = DAMAGE_PHYSICAL,
			damage_factor = {
				0.5,
				1,
				1.5
			}
		},
		ultimate = {
			cooldown = {
				50,
				46,
				42,
				38
			},
			entity = {
				range = 72,
				duration = 20,
				speed = {
					60,
					60,
					60,
					60
				},
				cooldown = {
					1.5,
					1.5,
					1.5,
					1.5
				},
				damage_min = {
					12,
					20,
					32,
					50
				},
				damage_max = {
					16,
					28,
					46,
					73
				},
				damage_type = DAMAGE_TRUE,
				spiked_armor_damage_type = DAMAGE_TRUE,
				hp_max = {
					210,
					290,
					370,
					450
				},
				regen_health = {
					5,
					8,
					12,
					17
				},
				spiked_armor_damage = {
					0,
					15,
					30,
					45
				},
				armor = {
					0.2,
					0.3,
					0.45,
					0.65
				}
			}
		}
	},
	hero_builder = {
		dead_lifetime = 30,
		speed = 50,
		regen_cooldown = 1,
		stats = {
			cooldown = 4,
			armor = 5,
			hp = 8,
			damage = 6
		},
		hp_max = {
			250,
			280,
			310,
			340,
			370,
			400,
			430,
			460,
			490,
			520
		},
		armor = {
			0,
			0.05,
			0.1,
			0.15,
			0.2,
			0.25,
			0.3,
			0.35,
			0.4,
			0.45
		},
		regen_health = {
			15,
			22,
			25,
			27,
			30,
			32,
			34,
			37,
			39,
			42
		},
		melee_damage_max = {
			16,
			19,
			24,
			27,
			30,
			33,
			36,
			39,
			42,
			45
		},
		melee_damage_min = {
			10,
			12,
			14,
			16,
			18,
			20,
			22,
			24,
			26,
			28
		},
		basic_melee = {
			cooldown = 2,
			xp_gain_factor = 2.6
		},
		overtime_work = {
			max_range = 120,
			min_targets = 2,
			cooldown = {
				18,
				15,
				12
			},
			xp_gain = {
				18,
				36,
				54
			},
			soldier = {
				max_speed = 60,
				armor = 0.15,
				duration = 18,
				hp_max = {
					75,
					150,
					225
				},
				melee_attack = {
					cooldown = 1,
					range = 80,
					damage_min = {
						3,
						6,
						9
					},
					damage_max = {
						5,
						10,
						15
					}
				}
			}
		},
		lunch_break = {
			lost_health = 0.8,
			cooldown = {
				30,
				23,
				16
			},
			heal_hp = {
				80,
				160,
				240
			},
			xp_gain = {
				30,
				60,
				90
			}
		},
		demolition_man = {
			radius = 100,
			max_range = 75,
			damage_every = 0.1,
			min_targets = 2,
			cooldown = {
				16,
				13,
				10
			},
			duration = {
				1.25,
				1.25,
				1.25
			},
			damage_type = DAMAGE_PHYSICAL,
			damage_min = {
				6,
				12,
				24
			},
			damage_max = {
				8,
				16,
				32
			},
			s_damage_min = {
				42,
				84,
				168
			},
			s_damage_max = {
				56,
				112,
				224
			},
			xp_gain = {
				16,
				32,
				48
			}
		},
		defensive_turret = {
			max_range = 180,
			build_speed = 168,
			min_targets = 1,
			cooldown = {
				25,
				23,
				20
			},
			duration = {
				15,
				20,
				25
			},
			xp_gain = {
				25,
				50,
				75
			},
			attack = {
				range = 180,
				cooldown = {
					0.8,
					0.8,
					0.8
				},
				damage_min = {
					8,
					16,
					28
				},
				damage_max = {
					12,
					24,
					42
				}
			}
		},
		ultimate = {
			radius = 80,
			cooldown = {
				30,
				30,
				30,
				30
			},
			stun_duration = {
				2,
				4,
				6,
				8
			},
			damage = {
				100,
				200,
				300,
				400
			},
			damage_type = DAMAGE_TRUE
		}
	},
	hero_mecha = {
		dead_lifetime = 30,
		speed = 42,
		regen_cooldown = 1,
		stats = {
			cooldown = 4,
			armor = 6,
			hp = 5,
			damage = 6
		},
		hp_max = {
			200,
			215,
			230,
			245,
			260,
			275,
			290,
			305,
			320,
			335
		},
		armor = {
			0.1,
			0.16,
			0.22,
			0.28,
			0.34,
			0.4,
			0.46,
			0.52,
			0.58,
			0.64
		},
		regen_health = {
			16,
			17,
			18,
			19,
			20,
			21,
			22,
			23,
			24,
			25
		},
		basic_ranged = {
			max_range = 250,
			min_range = 0,
			cooldown = 2,
			xp_gain_factor = 2.35,
			damage_type = DAMAGE_EXPLOSION,
			damage_max = {
				17,
				20,
				23,
				26,
				29,
				32,
				35,
				38,
				41,
				44
			},
			damage_min = {
				11,
				13,
				15,
				17,
				19,
				21,
				23,
				25,
				27,
				29
			}
		},
		goblidrones = {
			units = 2,
			min_targets = 1,
			spawn_range = 110,
			cooldown = {
				25,
				20,
				15
			},
			drone = {
				max_speed = 60,
				duration = {
					8,
					12,
					16
				},
				ranged_attack = {
					max_range = 150,
					cooldown = 1,
					min_range = 0,
					damage_type = DAMAGE_EXPLOSION,
					damage_min = {
						3,
						6,
						10
					},
					damage_max = {
						5,
						10,
						16
					}
				}
			},
			xp_gain = {
				25,
				50,
				75
			}
		},
		tar_bomb = {
			max_range = 200,
			node_prediction = 60,
			min_targets = 1,
			slow_factor = 0.4,
			min_range = 50,
			cooldown = {
				20,
				15,
				10
			},
			duration = {
				5,
				7,
				10
			},
			xp_gain = {
				30,
				56,
				78
			}
		},
		power_slam = {
			min_targets = 2,
			damage_radius = 85,
			cooldown = {
				20,
				18,
				16
			},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				52,
				104,
				208
			},
			damage_min = {
				52,
				104,
				208
			},
			s_damage = {
				52,
				104,
				208
			},
			stun_time = {
				3,
				4,
				5
			},
			xp_gain = {
				20,
				40,
				60
			}
		},
		mine_drop = {
			max_range = 120,
			min_dist_between_mines = 30,
			min_range = 20,
			damage_radius = 75,
			cooldown = {
				10,
				8,
				6
			},
			max_mines = {
				2,
				4,
				6
			},
			damage_max = {
				64,
				128,
				256
			},
			damage_min = {
				48,
				96,
				192
			},
			damage_type = DAMAGE_EXPLOSION,
			xp_gain = {
				10,
				16,
				18
			}
		},
		ultimate = {
			speed_out_of_range = 200,
			attack_radius = 150,
			speed_in_range = 10,
			cooldown = {
				45,
				45,
				45,
				45
			},
			ranged_attack = {
				max_range = 200,
				damage_radius = 60,
				cooldown = 0.5,
				min_range = 0,
				damage_type = DAMAGE_TRUE,
				damage_max = {
					60,
					90,
					120,
					150
				},
				damage_min = {
					40,
					60,
					80,
					100
				}
			}
		}
	},
	hero_venom = {
		slimewalk_speed = 95,
		dead_lifetime = 30,
		speed = 75,
		shared_cooldown = 1,
		distance_to_slimewalk = 150,
		regen_cooldown = 1,
		stats = {
			cooldown = 8,
			armor = 4,
			hp = 6,
			damage = 7
		},
		hp_max = {
			180,
			205,
			230,
			255,
			280,
			305,
			330,
			355,
			380,
			405
		},
		armor = {
			0,
			0.04,
			0.08,
			0.12,
			0.16,
			0.2,
			0.24,
			0.28,
			0.32,
			0.36
		},
		regen_health = {
			14,
			16,
			18,
			20,
			22,
			24,
			26,
			28,
			30,
			32
		},
		basic_melee = {
			xp_gain_factor = 1.55,
			cooldown = 1,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				24,
				27,
				30,
				33,
				36,
				39,
				42,
				45,
				48,
				51
			},
			damage_min = {
				16,
				18,
				20,
				22,
				24,
				26,
				28,
				30,
				32,
				34
			}
		},
		ranged_tentacle = {
			max_range = 150,
			s_bleed_damage = {
				8,
				12,
				16
			},
			min_range = 0,
			node_prediction = 60,
			cooldown = {
				10,
				10,
				10
			},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				27,
				54,
				108
			},
			damage_min = {
				27,
				54,
				108
			},
			s_damage = {
				27,
				54,
				108
			},
			bleed_chance = {
				0.6,
				0.8,
				1
			},
			bleed_damage_min = {
				2,
				3,
				4
			},
			bleed_damage_max = {
				2,
				3,
				4
			},
			bleed_every = {
				0.25,
				0.25,
				0.25
			},
			bleed_duration = {
				4,
				6,
				8
			},
			xp_gain = {
				10,
				20,
				30
			}
		},
		inner_beast = {
			duration = 15,
			trigger_hp = 0.6,
			cooldown = {
				35,
				30,
				25
			},
			basic_melee = {
				regen_health = 0.09,
				xp_gain_factor = 1,
				cooldown = 2.5,
				damage_type = DAMAGE_PHYSICAL,
				damage_factor = {
					2,
					2.5,
					3
				},
				s_damage_factor = {
					1,
					1.5,
					2
				}
			},
			xp_gain = {
				0,
				0,
				0
			}
		},
		floor_spikes = {
			damage_radius = 35,
			min_targets = 3,
			range_trigger_min = 0,
			range_trigger_max = 120,
			cooldown = {
				30,
				30,
				30
			},
			damage_type = DAMAGE_TRUE,
			damage_max = {
				36,
				72,
				108
			},
			damage_min = {
				36,
				72,
				108
			},
			s_damage = {
				36,
				72,
				108
			},
			spikes = {
				15,
				20,
				25
			},
			xp_gain = {
				30,
				60,
				90
			}
		},
		eat_enemy = {
			hp_trigger = {
				0.3,
				0.5,
				0.7
			},
			cooldown = {
				38,
				34,
				30
			},
			damage_type = DAMAGE_INSTAKILL,
			regen = {
				0.45,
				0.6,
				0.75
			},
			xp_gain = {
				40,
				70,
				90
			}
		},
		ultimate = {
			radius = 80,
			slow_factor = 0.25,
			slow_delay = 0.5,
			cooldown = {
				50,
				45,
				40,
				35
			},
			duration = {
				3,
				4,
				5,
				6
			},
			damage_type = DAMAGE_TRUE,
			damage_max = {
				150,
				225,
				350,
				525
			},
			damage_min = {
				150,
				225,
				350,
				525
			},
			s_damage = {
				150,
				225,
				350,
				525
			}
		}
	},
	hero_robot = {
		distance_to_flywalk = 150,
		regen_cooldown = 1,
		speed = 42,
		shared_cooldown = 1,
		dead_lifetime = 30,
		flywalk_speed = 110,
		stats = {
			cooldown = 8,
			armor = 7,
			hp = 7,
			damage = 5
		},
		hp_max = {
			200,
			225,
			250,
			275,
			300,
			325,
			350,
			375,
			400,
			425
		},
		armor = {
			0.15,
			0.21,
			0.27,
			0.33,
			0.39,
			0.45,
			0.51,
			0.57,
			0.63,
			0.69
		},
		regen_health = {
			16,
			17,
			18,
			20,
			21,
			22,
			23,
			24,
			26,
			27
		},
		basic_melee = {
			xp_gain_factor = 2.2,
			cooldown = 1,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				20,
				22,
				24,
				26,
				28,
				30,
				32,
				34,
				36,
				38
			},
			damage_min = {
				12,
				13,
				14,
				15,
				16,
				17,
				18,
				19,
				20,
				21
			}
		},
		jump = {
			max_range = 120,
			radius = 100,
			min_range = 0,
			damage_radius = 100,
			cooldown = {
				15,
				13,
				11
			},
			stun_duration = {
				2,
				3,
				4
			},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				30,
				60,
				120
			},
			damage_min = {
				30,
				60,
				120
			},
			s_damage = {
				30,
				60,
				120
			},
			xp_gain = {
				15,
				30,
				45
			}
		},
		fire = {
			max_range = 180,
			min_targets = 3,
			slow_factor = 0.5,
			min_range = 50,
			damage_radius = 30,
			cooldown = {
				25,
				25,
				25
			},
			xp_gain = {
				25,
				50,
				75
			},
			damage_type = DAMAGE_EXPLOSION,
			damage_max = {
				56,
				112,
				175
			},
			damage_min = {
				42,
				84,
				132
			},
			smoke_duration = {
				5,
				5,
				5
			},
			slow_duration = {
				5,
				5,
				5
			},
			s_slow_duration = {
				5,
				5,
				5
			}
		},
		uppercut = {
			life_threshold = {
				25,
				45,
				65
			},
			s_life_threshold = {
				0.25,
				0.45,
				0.65
			},
			cooldown = {
				34,
				30,
				26
			}
		},
		explode = {
			max_range = 90,
			min_range = 0,
			min_targets = 2,
			damage_every = 0.25,
			damage_radius = 100,
			burning_duration = 4,
			cooldown = {
				20,
				18,
				16
			},
			damage_max = {
				60,
				120,
				180
			},
			damage_min = {
				45,
				90,
				135
			},
			damage_type = DAMAGE_EXPLOSION,
			xp_gain = {
				20,
				40,
				60
			},
			burning_damage_type = DAMAGE_TRUE,
			burning_damage_min = {
				2,
				4,
				6
			},
			burning_damage_max = {
				2,
				4,
				6
			},
			s_burning_damage = {
				8,
				16,
				24
			}
		},
		ultimate = {
			burning_duration = 8,
			radius = 70,
			s_burning_damage = {
				4,
				8,
				16,
				32
			},
			speed = 200,
			damage_every = 0.25,
			duration = 4,
			cooldown = {
				50,
				50,
				50,
				50
			},
			damage_type = DAMAGE_TRUE,
			damage_max = {
				60,
				120,
				240,
				480
			},
			damage_min = {
				60,
				120,
				240,
				480
			},
			s_damage = {
				60,
				120,
				240,
				480
			},
			burning_damage_min = {
				1,
				2,
				4,
				8
			},
			burning_damage_max = {
				1,
				2,
				4,
				8
			},
			burning_damage_type = DAMAGE_TRUE
		}
	},
	hero_hunter = {
		distance_to_flywalk = 150,
		dead_lifetime = 30,
		flywalk_speed = 95,
		speed = 75,
		shared_cooldown = 1,
		regen_cooldown = 1,
		stats = {
			cooldown = 10,
			armor = 3,
			hp = 5,
			damage = 4
		},
		hp_max = {
			150,
			170,
			190,
			210,
			230,
			250,
			270,
			290,
			310,
			330
		},
		armor = {
			0,
			0.03,
			0.06,
			0.09,
			0.12,
			0.15,
			0.18,
			0.21,
			0.24,
			0.27
		},
		regen_health = {
			14,
			16,
			17,
			18,
			19,
			20,
			22,
			23,
			24,
			25
		},
		basic_melee = {
			xp_gain_factor = 1.45,
			cooldown = 0.8,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				8,
				10,
				12,
				14,
				16,
				18,
				20,
				22,
				24,
				26
			},
			damage_min = {
				6,
				7,
				9,
				10,
				12,
				13,
				15,
				16,
				18,
				19
			}
		},
		basic_ranged = {
			max_range = 240,
			min_range = 0,
			cooldown = 2.5,
			xp_gain_factor = 1.8,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				24,
				30,
				36,
				42,
				48,
				54,
				60,
				66,
				72,
				78
			},
			damage_min = {
				16,
				20,
				24,
				28,
				32,
				36,
				40,
				44,
				48,
				52
			}
		},
		heal_strike = {
			damage_type = DAMAGE_TRUE,
			hits_to_trigger = {
				7,
				6,
				5
			},
			damage_max = {
				24,
				48,
				72
			},
			damage_min = {
				20,
				40,
				60
			},
			heal_factor = {
				0.1,
				0.2,
				0.3
			},
			xp_gain = {
				5,
				10,
				15
			}
		},
		ricochet = {
			bounce_range = 120,
			min_targets = 3,
			max_range_trigger = 200,
			cooldown = {
				15,
				15,
				15
			},
			damage_type = DAMAGE_TRUE,
			damage_max = {
				34,
				68,
				102
			},
			damage_min = {
				24,
				48,
				72
			},
			bounces = {
				2,
				3,
				4
			},
			s_bounces = {
				3,
				4,
				5
			},
			xp_gain = {
				15,
				30,
				45
			}
		},
		shoot_around = {
			max_range = 90,
			radius = 90,
			min_targets = 3,
			cooldown = {
				20,
				20,
				20
			},
			damage_type = DAMAGE_TRUE,
			damage_every = fts(3),
			damage_min = {
				4,
				6,
				8
			},
			damage_max = {
				7,
				9,
				11
			},
			s_damage_min = {
				40,
				60,
				80
			},
			s_damage_max = {
				70,
				90,
				110
			},
			duration = {
				3,
				4,
				5
			},
			xp_gain = {
				20,
				40,
				60
			}
		},
		beasts = {
			max_range = 150,
			attack_range = 200,
			attack_cooldown = 0.5,
			max_distance_from_owner = 600,
			chance_to_steal = 45,
			s_chance = 0.45,
			cooldown = {
				18,
				16,
				14
			},
			damage_min = {
				3,
				6,
				9
			},
			damage_max = {
				4,
				8,
				12
			},
			duration = {
				8,
				10,
				12
			},
			gold_to_steal = {
				2,
				3,
				4
			},
			damage_type = DAMAGE_TRUE,
			xp_gain = {
				18,
				36,
				54
			}
		},
		ultimate = {
			duration = 15,
			slow_duration = 0.5,
			distance_to_revive = 150,
			slow_factor = 0.5,
			slow_radius = 80,
			cooldown = {
				45,
				45,
				45,
				45
			},
			entity = {
				basic_ranged = {
					max_range = 180,
					cooldown = 1,
					min_range = 0,
					damage_min = {
						10,
						20,
						35,
						55
					},
					damage_max = {
						15,
						30,
						50,
						75
					},
					damage_type = DAMAGE_TRUE
				}
			}
		}
	},
	hero_dragon_gem = {
		speed = 100,
		dead_lifetime = 30,
		regen_cooldown = 1,
		stats = {
			cooldown = 4,
			armor = 0,
			hp = 10,
			damage = 8
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			300,
			330,
			360,
			390,
			420,
			450,
			480,
			510,
			545,
			580
		},
		regen_health = {
			24,
			26,
			29,
			31,
			34,
			36,
			38,
			41,
			43,
			46
		},
		basic_ranged_shot = {
			max_range = 220,
			damage_range = 75,
			cooldown = 2,
			min_range = 0,
			xp_gain_factor = 1.82,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				18,
				23,
				26,
				30,
				34,
				37,
				41,
				44,
				49,
				55
			},
			damage_min = {
				13,
				15,
				18,
				20,
				22,
				25,
				27,
				30,
				32,
				35
			}
		},
		stun = {
			range = 180,
			min_targets = 2,
			stun_radius = 100,
			duration = {
				2,
				3,
				4
			},
			cooldown = {
				16,
				16,
				16
			},
			xp_gain = {
				16,
				32,
				48
			}
		},
		floor_impact = {
			damage_range = 50,
			min_targets = 3,
			max_nodes_trigger = 30,
			nodes_between_shards = 8,
			shards = 3,
			min_nodes_trigger = 0,
			stun_duration = 1,
			cooldown = {
				25,
				25,
				25
			},
			xp_gain = {
				25,
				50,
				75
			},
			damage_type = DAMAGE_PHYSICAL,
			damage_min = {
				24,
				48,
				72
			},
			damage_max = {
				36,
				72,
				108
			}
		},
		crystal_instakill = {
			max_range = 200,
			damage_range = 100,
			hp_max = {
				400,
				800,
				1200
			},
			cooldown = {
				35,
				35,
				35
			},
			xp_gain = {
				35,
				70,
				105
			},
			damage_aoe_min = {
				44,
				88,
				132
			},
			damage_aoe_max = {
				44,
				88,
				132
			},
			s_damage = {
				44,
				88,
				132
			},
			explode_time = fts(27)
		},
		crystal_totem = {
			max_range_trigger = 160,
			slow_duration = 1,
			min_targets = 2,
			slow_factor = 0.75,
			aura_radius = 80,
			cooldown = {
				20,
				20,
				20
			},
			xp_gain = {
				20,
				40,
				60
			},
			duration = {
				6,
				8,
				10
			},
			damage_min = {
				8,
				16,
				25
			},
			damage_max = {
				8,
				16,
				25
			},
			s_damage = {
				8,
				16,
				25
			},
			trigger_every = 0.5
		},
		passive_charge = {
			distance_threshold = 300,
			shots_amount = 3,
			damage_factor = 3
		},
		ultimate = {
			damage_range = 30,
			range = 500,
			random_ni_spread = 30,
			distance_between_shards = 10,
			damage_max = {
				108,
				144,
				180,
				216
			},
			damage_min = {
				96,
				128,
				160,
				192
			},
			damage_type = DAMAGE_TRUE,
			cooldown = {
				45,
				45,
				45,
				45
			},
			max_shards = {
				3,
				4,
				6,
				8
			}
		}
	},
	hero_bird = {
		dead_lifetime = 30,
		speed = 120,
		regen_cooldown = 1,
		stats = {
			cooldown = 5,
			armor = 0,
			hp = 7,
			damage = 5
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			280,
			300,
			320,
			340,
			360,
			380,
			400,
			420,
			440,
			460
		},
		regen_health = {
			22,
			24,
			26,
			27,
			29,
			30,
			32,
			34,
			35,
			37
		},
		basic_attack = {
			max_range = 200,
			xp_gain_factor = 1.7,
			cooldown = 1.5,
			min_range = 0,
			damage_radius = 75,
			damage_type = DAMAGE_EXPLOSION,
			damage_max = {
				18,
				21,
				24,
				27,
				30,
				33,
				36,
				39,
				42,
				45
			},
			damage_min = {
				12,
				14,
				16,
				18,
				20,
				22,
				24,
				26,
				28,
				30
			}
		},
		cluster_bomb = {
			max_range = 220,
			min_targets = 2,
			min_range = 0,
			first_explosion_height = 150,
			fire_radius = 50,
			explosion_damage_radius = 75,
			cooldown = {
				20,
				20,
				20
			},
			xp_gain = {
				20,
				40,
				60
			},
			explosion_damage_type = DAMAGE_EXPLOSION,
			explosion_damage_min = {
				12,
				24,
				36
			},
			explosion_damage_max = {
				12,
				24,
				36
			},
			fire_duration = {
				3,
				6,
				9
			},
			burning = {
				cycle_time = 0.25,
				s_total_damage = {
					12,
					24,
					36
				},
				duration = 3,
				damage = {
					1,
					2,
					3
				},
				damage_type = DAMAGE_TRUE
			}
		},
		shout_stun = {
			radius = 100,
			min_targets = 2,
			slow_factor = 0.5,
			cooldown = {
				20,
				18,
				16
			},
			xp_gain = {
				20,
				36,
				48
			},
			stun_duration = {
				1,
				2,
				3
			},
			slow_duration = {
				3,
				5,
				7
			}
		},
		gattling = {
			max_range = 190,
			min_range = 0,
			cooldown = {
				12,
				11,
				10
			},
			xp_gain = {
				12,
				24,
				36
			},
			duration = {
				3,
				3,
				3
			},
			damage_min = {
				4,
				8,
				12
			},
			damage_max = {
				5,
				10,
				15
			},
			damage_type = DAMAGE_PHYSICAL,
			shoot_every = fts(4),
			s_damage_min = {
				84,
				168,
				252
			},
			s_damage_max = {
				105,
				210,
				315
			}
		},
		eat_instakill = {
			max_range = 50,
			min_range = 0,
			cooldown = {
				25,
				23,
				20
			},
			xp_gain = {
				25,
				44,
				60
			},
			hp_max = {
				300,
				500,
				800
			}
		},
		ultimate = {
			cooldown = {
				35,
				35,
				35,
				35
			},
			bird = {
				chase_range = 250,
				target_range = 180,
				duration = {
					8,
					10,
					12,
					14
				},
				melee_attack = {
					range = 30,
					cooldown = 0.1,
					damage_max = {
						25,
						40,
						55,
						70
					},
					damage_min = {
						25,
						40,
						55,
						70
					},
					damage_type = DAMAGE_TRUE
				}
			}
		}
	},
	hero_lava = {
		dead_lifetime = 15,
		speed = 55,
		regen_cooldown = 1,
		stats = {
			cooldown = 6,
			armor = 0,
			hp = 5,
			damage = 6
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			180,
			195,
			210,
			225,
			240,
			255,
			270,
			285,
			300,
			315
		},
		melee_damage_max = {
			15,
			18,
			21,
			24,
			27,
			30,
			33,
			36,
			39,
			42
		},
		melee_damage_min = {
			10,
			12,
			14,
			16,
			18,
			20,
			22,
			24,
			26,
			28
		},
		regen_health = {
			9,
			9,
			9,
			9,
			9,
			9,
			9,
			9,
			9,
			9
		},
		basic_melee = {
			cooldown = 1.25,
			xp_gain_factor = 1.8
		},
		temper_tantrum = {
			stun_duration = 2,
			cooldown = {
				15,
				15,
				15
			},
			duration = {
				2,
				3,
				4
			},
			s_damage_min = {
				57,
				114,
				228
			},
			s_damage_max = {
				84,
				168,
				336
			},
			damage_min = {
				19,
				38,
				76
			},
			damage_max = {
				28,
				56,
				112
			},
			damage_type = DAMAGE_PHYSICAL,
			xp_gain = {
				15,
				30,
				45
			}
		},
		hotheaded = {
			range = 300,
			cooldown = {
				5,
				5,
				5
			},
			s_damage_factors = {
				0.2,
				0.3,
				0.4
			},
			damage_factors = {
				1.2,
				1.3,
				1.4
			},
			durations = {
				6,
				9,
				12
			},
			xp_gain = {
				320,
				450,
				580
			}
		},
		double_trouble = {
			max_range = 150,
			min_range = 75,
			damage_radius = 70,
			cooldown = {
				20,
				18,
				16
			},
			s_damage = {
				30,
				60,
				120
			},
			damage_min = {
				30,
				60,
				120
			},
			damage_max = {
				30,
				60,
				120
			},
			damage_type = DAMAGE_EXPLOSION,
			xp_gain = {
				20,
				40,
				60
			},
			soldier = {
				armor = 0,
				max_speed = 36,
				cooldown = 1,
				duration = 20,
				hp_max = {
					75,
					150,
					225
				},
				damage_min = {
					10,
					15,
					20
				},
				damage_max = {
					14,
					21,
					28
				}
			}
		},
		death_aura = {
			damage_min = 5,
			damage_radius = 70,
			cycle_time = 0.25,
			damage_max = 9,
			slow_factor = 0.65,
			damage_type = DAMAGE_TRUE
		},
		wild_eruption = {
			max_range_effect = 100,
			radius = 90,
			min_targets = 3,
			damage_every = 0.25,
			max_range_trigger = 60,
			loop_duration = 1.5,
			cooldown = {
				30,
				30,
				30
			},
			duration = {
				4,
				4,
				4
			},
			damage_min = {
				10,
				20,
				30
			},
			damage_max = {
				10,
				20,
				30
			},
			s_damage = {
				40,
				80,
				120
			},
			damage_type = DAMAGE_TRUE,
			xp_gain = {
				30,
				60,
				90
			}
		},
		ultimate = {
			max_spread = 30,
			cooldown = {
				60,
				60,
				60,
				60
			},
			fireball_count = {
				3,
				4,
				5,
				6
			},
			bullet = {
				damage_radius = 60,
				s_damage = {
					40,
					80,
					130,
					200
				},
				damage_min = {
					40,
					80,
					130,
					200
				},
				damage_max = {
					40,
					80,
					130,
					200
				},
				damage_type = DAMAGE_TRUE,
				scorch = {
					duration = 5,
					damage_radius = 60,
					cycle_time = 0.25,
					damage_min = {
						1,
						2,
						3,
						4
					},
					damage_max = {
						1,
						2,
						3,
						4
					},
					damage_type = DAMAGE_TRUE
				}
			}
		},
		ultimate_combo = {
			max_targets = 12,
			max_radius = 800,
			min_radius = 90
		}
	},
	hero_witch = {
		dead_lifetime = 30,
		speed = 180,
		regen_cooldown = 1,
		stats = {
			cooldown = 5,
			armor = 0,
			hp = 6,
			damage = 7
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			200,
			220,
			240,
			260,
			280,
			300,
			320,
			340,
			360,
			380
		},
		melee_damage_max = {
			9,
			11,
			13,
			15,
			17,
			19,
			21,
			23,
			25,
			27
		},
		melee_damage_min = {
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			14,
			15
		},
		ranged_damage_max = {
			9,
			11,
			13,
			15,
			17,
			19,
			21,
			23,
			25,
			27
		},
		ranged_damage_min = {
			6,
			7,
			8,
			9,
			10,
			11,
			12,
			13,
			14,
			15
		},
		regen_health = {
			12,
			14,
			16,
			18,
			20,
			22,
			24,
			26,
			28,
			30
		},
		basic_melee = {
			cooldown = 1,
			xp_gain_factor = 2.2
		},
		ranged_attack = {
			max_range = 200,
			xp_gain_factor = 1.7,
			cooldown = 1.5,
			min_range = 0,
			damage_type = DAMAGE_MAGICAL
		},
		skill_soldiers = {
			min_targets = 2,
			max_range = 120,
			cooldown = {
				18,
				16,
				14
			},
			xp_gain = {
				18,
				36,
				54
			},
			soldiers_amount = {
				2,
				3,
				4
			},
			soldier = {
				max_speed = 60,
				armor = 0,
				duration = 12,
				hp_max = {
					80,
					120,
					160
				},
				melee_attack = {
					cooldown = 1,
					range = 100,
					damage_min = {
						3,
						6,
						9
					},
					damage_max = {
						4,
						8,
						12
					}
				}
			}
		},
		skill_polymorph = {
			range = 200,
			max_nodes_to_goal = 30,
			cooldown = {
				20,
				20,
				20
			},
			hp_max = {
				600,
				1200,
				2400
			},
			duration = {
				8,
				12,
				16
			},
			xp_gain = {
				20,
				40,
				60
			},
			pumpkin = {
				speed = 20,
				armor = 0,
				magic_armor = 0,
				hp = {
					0.75,
					0.5,
					0.25
				}
			}
		},
		skill_path_aoe = {
			max_range = 180,
			min_targets = 2,
			slow_factor = 0.5,
			min_range = 0,
			node_prediction = 22,
			cooldown = {
				16,
				16,
				16
			},
			duration = {
				6,
				9,
				12
			},
			xp_gain = {
				16,
				32,
				48
			},
			damage_min = {
				50,
				100,
				200
			},
			damage_max = {
				50,
				100,
				200
			},
			s_damage = {
				50,
				100,
				200
			},
			damage_type = DAMAGE_MAGICAL
		},
		disengage = {
			min_distance_from_end = 300,
			distance = 160,
			hp_to_trigger = 0.9,
			cooldown = {
				18,
				18,
				18
			},
			xp_gain = {
				20,
				40,
				60
			},
			decoy = {
				max_speed = 60,
				armor = 0,
				duration = 15,
				hp_max = {
					100,
					200,
					300
				},
				melee_attack = {
					cooldown = 1,
					range = 80,
					damage_min = {
						8,
						12,
						16
					},
					damage_max = {
						12,
						18,
						24
					}
				},
				explotion = {
					radius = 60,
					stun_duration = {
						2,
						3,
						4
					}
				}
			}
		},
		ultimate = {
			radius = 100,
			nodes_teleport = 30,
			nodes_limit = 20,
			cooldown = {
				35,
				32,
				29,
				26
			},
			duration = {
				2,
				3,
				5,
				8
			},
			max_targets = {
				4,
				6,
				9,
				13
			}
		}
	},
	hero_dragon_bone = {
		dead_lifetime = 30,
		speed = 130,
		regen_cooldown = 1,
		stats = {
			cooldown = 4,
			armor = 0,
			hp = 9,
			damage = 7
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			315,
			340,
			365,
			390,
			415,
			440,
			465,
			490,
			515,
			540
		},
		regen_health = {
			25,
			27,
			29,
			31,
			33,
			35,
			37,
			39,
			41,
			43
		},
		basic_attack = {
			max_range = 220,
			radius = 60,
			cooldown = 2,
			min_range = 0,
			xp_gain_factor = 1.4,
			damage_type = DAMAGE_TRUE,
			damage_max = {
				17,
				20,
				24,
				27,
				30,
				34,
				37,
				40,
				44,
				46
			},
			damage_min = {
				11,
				13,
				16,
				18,
				20,
				22,
				25,
				27,
				29,
				32
			}
		},
		plague = {
			damage_min = 1,
			every = 0.25,
			duration = 4,
			damage_max = 1,
			explotion = {
				damage_radius = 60,
				damage_min = 10,
				damage_max = 20,
				damage_type = DAMAGE_EXPLOSION
			}
		},
		cloud = {
			max_range = 225,
			radius = 100,
			min_targets = 2,
			slow_factor = 0.5,
			min_range = 0,
			cooldown = {
				15,
				15,
				15
			},
			duration = {
				4,
				8,
				12
			},
			xp_gain = {
				15,
				30,
				45
			}
		},
		nova = {
			max_range = 75,
			min_targets = 3,
			min_range = 0,
			damage_radius = 75,
			cooldown = {
				24,
				20,
				16
			},
			damage_type = DAMAGE_EXPLOSION,
			damage_max = {
				40,
				120,
				200
			},
			damage_min = {
				21,
				63,
				105
			},
			xp_gain = {
				24,
				48,
				72
			}
		},
		rain = {
			max_range = 200,
			min_targets = 2,
			min_range = 0,
			stun_time = {
				1,
				1.5,
				2
			},
			cooldown = {
				20,
				18,
				16
			},
			damage_max = {
				18,
				36,
				54
			},
			damage_min = {
				12,
				24,
				36
			},
			damage_type = DAMAGE_TRUE,
			bones_count = {
				3,
				6,
				9
			},
			xp_gain = {
				20,
				40,
				50
			}
		},
		burst = {
			max_range = 300,
			min_targets = 5,
			min_range = 0,
			cooldown = {
				32,
				28,
				24
			},
			damage_max = {
				36,
				90,
				144
			},
			damage_min = {
				24,
				60,
				96
			},
			damage_type = DAMAGE_TRUE,
			proj_count = {
				6,
				9,
				12
			},
			xp_gain = {
				30,
				60,
				90
			}
		},
		ultimate = {
			cooldown = {
				45,
				45,
				45,
				45
			},
			dog = {
				speed = 95,
				armor = 0.1,
				cooldown = 1,
				duration = {
					10,
					15,
					20,
					25
				},
				hp = {
					100,
					150,
					225,
					325
				},
				melee_attack = {
					cooldown = 1,
					damage_type = DAMAGE_PHYSICAL,
					damage_max = {
						14,
						28,
						42,
						56
					},
					damage_min = {
						10,
						20,
						30,
						40
					}
				}
			}
		}
	},
	hero_dragon_arb = {
		dead_lifetime = 30,
		speed = 130,
		regen_cooldown = 1,
		stats = {
			cooldown = 5,
			armor = 0,
			hp = 7,
			damage = 7
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		magic_armor = {
			0.03,
			0.06,
			0.09,
			0.12,
			0.15,
			0.18,
			0.21,
			0.24,
			0.27,
			0.3
		},
		hp_max = {
			195,
			220,
			245,
			270,
			295,
			320,
			345,
			370,
			395,
			420
		},
		regen_health = {
			24,
			27,
			30,
			33,
			36,
			39,
			42,
			45,
			48,
			51
		},
		passive_plant_zones = {
			zone_duration = 25,
			radius = 15,
			expansion_cooldown = 0.3,
			slow_factor = 0.5
		},
		basic_breath_attack = {
			max_range = 300,
			xp_gain_factor = 1.82,
			cooldown = 1.75,
			min_range = 10,
			damage_type = DAMAGE_MAGICAL,
			damage_max = {
				15,
				19,
				23,
				27,
				32,
				36,
				40,
				44,
				49,
				53
			},
			damage_min = {
				10,
				13,
				16,
				19,
				22,
				25,
				28,
				31,
				34,
				37
			}
		},
		arborean_spawn = {
			max_range = 10000,
			spawn_max_range_to_enemy = 200,
			min_targets = 2,
			min_range = 0,
			max_targets = 3,
			cooldown = {
				35,
				35,
				35
			},
			xp_gain = {
				35,
				70,
				105
			},
			arborean = {
				speed = 30,
				armor = 0.16,
				magic_armor = 0,
				hp = {
					80,
					120,
					160
				},
				duration = {
					10,
					15,
					20
				},
				basic_attack = {
					cooldown = 2,
					damage_type = DAMAGE_PHYSICAL,
					damage_max = {
						6,
						9,
						12
					},
					damage_min = {
						4,
						6,
						8
					}
				}
			},
			paragon = {
				speed = 40,
				armor = 0.32,
				magic_armor = 0,
				hp = {
					120,
					180,
					240
				},
				duration = {
					14,
					21,
					28
				},
				basic_attack = {
					cooldown = 1,
					damage_type = DAMAGE_PHYSICAL,
					damage_max = {
						12,
						18,
						24
					},
					damage_min = {
						8,
						12,
						16
					}
				}
			}
		},
		tower_runes = {
			max_range = 300,
			min_range = 0,
			cooldown = {
				35,
				30,
				25
			},
			xp_gain = {
				35,
				70,
				105
			},
			max_targets = {
				3,
				4,
				5
			},
			duration = {
				6,
				9,
				12
			},
			damage_factor = {
				1.15,
				1.3,
				1.45
			},
			s_damage_factor = {
				0.15,
				0.3,
				0.45
			}
		},
		thorn_bleed = {
			damage_every = 0.75,
			damage_type = DAMAGE_MAGICAL,
			xp_gain = {
				35,
				70,
				105
			},
			damage_speed_ratio = {
				0.375,
				0.564,
				0.825
			},
			cooldown = {
				12,
				10,
				8
			},
			instakill_chance = {
				0.3,
				0.3,
				0.3
			},
			duration = {
				5,
				5,
				5
			}
		},
		tower_plants = {
			max_range = 300,
			min_range = 0,
			cooldown = {
				20,
				20,
				20
			},
			xp_gain = {
				22,
				44,
				66
			},
			max_targets = {
				1,
				2,
				3
			},
			duration = {
				8,
				10,
				12
			},
			linirea = {
				cooldown_min = 0.5,
				range = 240,
				heal_every = 0.2,
				heal_duration = 1.5,
				cooldown_max = 0.5,
				heal_max = {
					15,
					15,
					15
				},
				heal_min = {
					15,
					15,
					15
				}
			},
			dark_army = {
				cooldown_min = 2,
				range = 120,
				damage_every = 0.25,
				cooldown_max = 2,
				duration = 0.5,
				slow_factor = {
					0.5,
					0.4,
					0.3
				},
				damage_type = DAMAGE_MAGICAL,
				damage_min = {
					5,
					7,
					9
				},
				damage_max = {
					5,
					7,
					9
				}
			}
		},
		ultimate = {
			duration = {
				8,
				10,
				13,
				17
			},
			cooldown = {
				45,
				45,
				45,
				45
			},
			extra_armor = {
				0.3,
				0.4,
				0.5,
				0.6
			},
			extra_magic_armor = {
				0.3,
				0.4,
				0.5,
				0.6
			},
			speed_factor = {
				1.25,
				1.5,
				1.75,
				2
			},
			inflicted_damage_factor = {
				1.25,
				1.5,
				1.75,
				2
			},
			s_bonuses = {
				0.25,
				0.5,
				0.75,
				1
			}
		}
	},
	hero_spider = {
		dead_lifetime = 25,
		tp_delay = 0,
		speed = 90,
		tp_duration = 0,
		teleport_min_distance = 200,
		shared_cooldown = 0,
		regen_cooldown = 1,
		stats = {
			cooldown = 5,
			armor = 0,
			hp = 7,
			damage = 6
		},
		armor = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		},
		hp_max = {
			270,
			290,
			310,
			330,
			350,
			370,
			390,
			410,
			430,
			450
		},
		regen_health = {
			13,
			14,
			14,
			15,
			16,
			17,
			18,
			18,
			19,
			20
		},
		basic_melee = {
			xp_gain_factor = 2.36,
			cooldown = 1,
			damage_max = {
				11,
				13,
				15,
				17,
				19,
				21,
				23,
				25,
				27,
				30
			},
			damage_min = {
				9,
				11,
				13,
				15,
				17,
				19,
				21,
				23,
				25,
				27
			},
			damage_type = DAMAGE_PHYSICAL,
			dot = {
				poison_mod_duration = 1.5,
				poison_damage_every = 0.25,
				poison_radius = 80,
				poison_damage_min = {
					2,
					2,
					2,
					2,
					3,
					3,
					3,
					4,
					4,
					4
				},
				poison_damage_max = {
					2,
					2,
					2,
					2,
					3,
					3,
					3,
					4,
					4,
					4
				},
				damage_type = DAMAGE_PHYSICAL
			}
		},
		basic_ranged = {
			max_range = 160,
			xp_gain_factor = 1.5,
			cooldown = 1.5,
			min_range = 68,
			damage_max = {
				20,
				23,
				26,
				29,
				32,
				35,
				38,
				41,
				44,
				48
			},
			damage_min = {
				11,
				13,
				15,
				17,
				19,
				20,
				22,
				24,
				26,
				28
			},
			damage_type = DAMAGE_MAGICAL
		},
		instakill_melee = {
			use_current_health_instead_of_max = true,
			life_threshold = {
				600,
				900,
				1200
			},
			cooldown = {
				7,
				6,
				5
			},
			xp_gain = {
				20,
				40,
				60
			}
		},
		area_attack = {
			min_targets = 3,
			damage_radius = 85,
			cooldown = {
				18,
				16,
				14
			},
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				30,
				60,
				90
			},
			damage_min = {
				30,
				60,
				90
			},
			s_damage = {
				30,
				60,
				90
			},
			stun_time = {
				90,
				120,
				150
			},
			s_stun_time = {
				3,
				4,
				5
			},
			xp_gain = {
				18,
				34,
				48
			}
		},
		tunneling = {
			min_targets = 1,
			damage_radius = 85,
			damage_type = DAMAGE_PHYSICAL,
			damage_max = {
				36,
				72,
				108
			},
			damage_min = {
				24,
				48,
				72
			},
			s_damage = {
				36,
				54,
				84
			},
			xp_gain = {
				7,
				7,
				7
			}
		},
		supreme_hunter = {
			min_targets = 1,
			cooldown = {
				25,
				20,
				15
			},
			damage_type = DAMAGE_TRUE,
			damage_max = {
				84,
				168,
				336
			},
			damage_min = {
				56,
				112,
				224
			},
			s_damage = {
				50,
				80,
				115
			},
			xp_gain = {
				25,
				50,
				75
			}
		},
		ultimate = {
			cooldown = {
				35,
				35,
				35,
				35
			},
			spawn_amount = {
				2,
				3,
				4,
				5
			},
			spider = {
				speed = 95,
				armor = 0,
				stun_duration = 3,
				cooldown = 1,
				stun_chance = 0.2,
				duration = {
					6,
					9,
					12,
					15
				},
				hp = {
					150,
					180,
					210,
					240
				},
				melee_attack = {
					cooldown = 1,
					damage_type = DAMAGE_TRUE,
					damage_max = {
						12,
						15,
						18,
						21
					},
					damage_min = {
						8,
						10,
						12,
						14
					}
				}
			}
		}
	},
	hero_10yr = {
		ultimate = {
			cooldown = {
				60,
				60,
				60,
				60
			}
		}
	},
	hero_dracolich = {
		basic_attack = {
			attack_filter = false,
			damage_type = DAMAGE_MAGICAL
		},
		bonegolem = {
			nav_grid = true
		},
		plaguecarrier = {
			range_nodes_max = 30,
			range_nodes_min = 10
		},
		ultimate = {
			cooldown = {
				70,
				70,
				70,
				70
			}
		}
	},
	hero_dragon = {
		attack_filter = false,
		basic_attack = {
			max_range = 140,
			damage_radius = 40,
			damage_min = {
				15,
				20,
				26,
				31,
				37,
				42,
				48,
				53,
				59,
				64
			},
			damage_max = {
				20,
				28,
				37,
				45,
				54,
				62,
				71,
				79,
				88,
				96
			}
		},
		blazingbreath = {
			cooldown = 8,
			min_range = 0,
			damage = {
				150,
				250,
				350
			}
		},
		fierymist = {
			min_range = 0,
			cooldown = 10,
			slow_factor = {
				0.6,
				0.5,
				0.4
			}
		},
		wildfirebarrage = {
			min_range = 90,
			damage = 30
		},
		feast = {
			damage_type = DAMAGE_TRUE,
			damage = {
				100,
				200,
				300
			}
		}
	},
	hero_wilbur = {
		speed = 86,
		basic_attack = {
			damage_type = DAMAGE_TRUE
		},
		box = {
			damage_type = DAMAGE_TRUE,
			range_nodes_max = 60,
			range_nodes_min = 20
		},
		smoke = {
			duration = {
				3,
				5,
				8
			}
		},
		ultimate = {
			cooldown = {
				50,
				50,
				50,
				50
			}
		}
	},
	hero_dianyun = {
		basic_attack = {
			min_range = 0,
			max_range = 200
		},
		ricochet = {
			min_range = 0,
			max_range = 200,
			damage_min = {
				45,
				60,
				75
			},
			damage_max = {
				45,
				60,
				75
			},
			bounce = {
				3,
				5,
				7
			}
		},
		divine_rain = {
			min_range = 0,
			max_range = 110,
			radius = 60,
			healing_points_tick = {
				8,
				16,
				24
			}
		},
		supreme_wave = {
			min_range = 0,
			max_range = 100,
			damage_type = DAMAGE_MAGICAL,
			damage = 15
		},
		passive = {
			gold_reward = 2
		},
		ultimate = {
			min_range = 0,
			max_range = 160,
			duration = 240,
			stun = fts(20),
			damage_type = DAMAGE_TRUE,
			cooldown = {
				70,
				70,
				70,
				70
			}
		}
	},
	hero_eiskalt = {
		basic_attack = {
			damage_type = DAMAGE_MAGICAL,
			min_range = 0,
			max_range = 175
		},
		fierce_breath = {
			damage_area = {
				30,
				50,
				70
			}
		},
		cold_fury = {
			min_range = 190,
			max_range = 300,
			damage_min = 90,
			damage_max = 120,
		},
		ice_ball = {
			min_range = 25,
			max_range = 160,
			damage_min = 60,
			damage_max = 90,
			damage_over_time = {
				8,
				16,
				24
			}
		},
		ice_peaks = {
			min_range = 20,
			max_range = 150,
			cooldown = 30,
			damage_boss = {
				100,
				200,
				300
			}
		},
		ultimate = {
			cooldown = {
				70,
				70,
				70,
				70
			},
			duration = {
				3,
				6,
				9,
				12
			}
		}
	}
}
local relics = {
	banner_of_command = {
		cooldown = {
			20,
			20,
			20,
			20
		},
		soldier = {
			cooldown = 1,
			duration = 15,
			damage_min = {
				5,
				6,
				8,
				10
			},
			damage_max = {
				7,
				8,
				12,
				14
			},
			hp = {
				30,
				40,
				50,
				70
			},
			armor = {
				0,
				0,
				0,
				0
			},
			regen_health = {
				3,
				4,
				5,
				7
			}
		}
	},
	locket_of_the_unforgiven = {
		range = 100,
		max_skeletons = {
			2,
			3,
			4,
			5
		},
		skeleton = {
			cooldown = 1,
			duration = 15,
			damage_min = {
				2,
				3,
				4,
				5
			},
			damage_max = {
				4,
				5,
				6,
				7
			},
			hp = {
				50,
				60,
				75,
				85
			}
		}
	},
	guardian_orb = {
		hero_max_distance = 200,
		hero_idle_distance = 50,
		shoot_range = 25,
		cooldown = 1.5,
		search_cooldown = 0.25,
		search_range = 150,
		damage_min = {
			4,
			5,
			6,
			8
		},
		damage_max = {
			8,
			10,
			12,
			18
		},
		damage_type = DAMAGE_MAGICAL
	},
	mirror_of_inversion = {},
	hammer_of_the_blessed = {
		range = 50,
		cooldown = 12,
		heal_percent = {
			0.15,
			0.2,
			0.25,
			0.3
		}
	}
}
local enemies = {
	-- 额外的敌人，1代表敌人数量多1倍，血量多0.15倍，赏金为原来的0.6倍(原有的敌人不受影响)。
	-- 2代表敌人数量多2倍，血量多0.15*2倍，赏金为原来的0.6*0.85倍，如此类推。
	extra_enemies = 2,
	frame_splitting = true,
	werebeasts = {
		hog_invader = {
			speed = 36,
			armor = 0,
			hp = 48,
			gold = 5,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 2,
				damage_max = 4
			}
		},
		tusked_brawler = {
			speed = 36,
			armor = 0.2,
			hp = 96,
			gold = 10,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 4,
				damage_max = 6
			}
		},
		turtle_shaman = {
			speed = 20,
			armor = 0,
			hp = 300,
			gold = 25,
			magic_armor = 0.8,
			basic_attack = {
				cooldown = 1.5,
				damage_min = 5,
				damage_max = 6
			},
			ranged_attack = {
				max_range = 100,
				min_range = 60,
				damage_min = 12,
				cooldown = 1.5,
				damage_max = 20
			},
			natures_vigor = {
				hp_trigger_factor = 0.75,
				range = 200,
				heal_min = 10,
				heal_every = 0.25,
				cooldown = 4,
				duration = 5,
				heal_max = 10
			}
		},
		bear_vanguard = {
			speed = 20,
			armor = 0.6,
			hp = 600,
			gold = 30,
			magic_armor = 0,
			basic_attack = {
				cooldown = 2,
				damage_min = 24,
				damage_radius = 50,
				damage_max = 40,
				damage_type = DAMAGE_PHYSICAL
			},
			wrath_of_the_fallen = {
				duration = 10,
				radius = 100,
				inflicted_damage_factor = 2,
				speed_factor = 2
			}
		},
		bear_woodcutter = {
			speed = 20,
			armor = 0.4,
			hp = 900,
			gold = 50,
			magic_armor = 0,
			basic_attack = {
				cooldown = 2,
				damage_min = 36,
				damage_radius = 50,
				damage_max = 60,
				damage_type = DAMAGE_PHYSICAL
			},
			wrath_of_the_fallen = {
				radius = 100
			}
		},
		cutthroat_rat = {
			speed = 64,
			armor = 0,
			hp = 60,
			gold = 6,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 8,
				damage_max = 12
			},
			gut_stab = {
				bleed_every = 0.25,
				bleed_damage_min = 10,
				cooldown = 15,
				damage_max = 36,
				bleed_damage_max = 10,
				damage_min = 24,
				min_distance_from_end = 450,
				duration = 3,
				bleed_duration = 3,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		dreadeye_viper = {
			speed = 36,
			armor = 0,
			hp = 120,
			gold = 12,
			magic_armor = 0.3,
			basic_attack = {
				cooldown = 1.5,
				damage_min = 10,
				damage_max = 20,
				poison = {
					damage_max = 2,
					duration = 3,
					damage_min = 2,
					every = 0.25
				}
			},
			ranged_attack = {
				max_range = 150,
				min_range = 60,
				damage_min = 18,
				cooldown = 2,
				damage_max = 24,
				poison = {
					damage_max = 2,
					duration = 3,
					damage_min = 2,
					every = 0.25
				}
			}
		},
		surveyor_harpy = {
			speed = 50,
			armor = 0,
			hp = 50,
			gold = 5,
			magic_armor = 0
		},
		skunk_bombardier = {
			speed = 36,
			armor = 0,
			hp = 160,
			gold = 15,
			magic_armor = 0.6,
			melee_attack = {
				cooldown = 1,
				damage_min = 6,
				damage_max = 8
			},
			ranged_attack = {
				max_range = 150,
				radius = 45,
				damage_min = 15,
				min_range = 40,
				cooldown = 2.5,
				mod_duration = 4,
				damage_max = 20,
				received_damage_factor = 2
			}
		},
		hyena5 = {
			speed = 50,
			armor = 0.2,
			hp = 200,
			gold = 15,
			magic_armor = 0,
			melee_attack = {
				cooldown = 1.5,
				damage_min = 14,
				damage_max = 22
			},
			feast = {
				heal_every = 0.25,
				hp_min_trigger = 120,
				cooldown = 10,
				heal = 20,
				duration = 1.5
			}
		},
		rhino = {
			gold = 80,
			magic_armor = 0.4,
			speed = 20,
			armor = 0.4,
			hp = 1500,
			lives_cost = 2,
			basic_attack = {
				cooldown = 2,
				damage_min = 48,
				damage_max = 64
			},
			instakill = {
				cooldown = 5,
				damage_max = 300,
				damage_min = 300,
				damage_type = DAMAGE_INSTAKILL
			},
			charge = {
				range = 50,
				trigger_range = 120,
				damage_soldier_max = 56,
				cooldown = 20,
				min_range = 90,
				damage_enemy_min = 56,
				speed = 120,
				damage_enemy_max = 56,
				min_distance_from_end = 50,
				duration = 1.8,
				damage_soldier_min = 56,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		boss = {
			speed = 16,
			armor = 0.6,
			hp = 8000,
			melee_attack = {
				cooldown = 1,
				damage_min = 120,
				damage_max = 160,
				damage_radius = 60
			},
			fall = {
				damage_min = 800,
				radius = 100,
				damage_max = 500
			}
		}
	},
	cult_of_the_overseer = {
		acolyte = {
			speed = 36,
			armor = 0,
			hp = 200,
			gold = 15,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 6,
				damage_max = 10
			},
			tentacle = {
				armor = 0,
				hp = 80,
				duration = 6,
				magic_armor = 0,
				hit = {
					first_cooldown_min = 1,
					radius = 45,
					damage_min = 6,
					first_cooldown_max = 2,
					cooldown = 1,
					damage_max = 10
				}
			}
		},
		lesser_sister = {
			gold = 50,
			magic_armor = 0.6,
			speed = 28,
			armor = 0,
			hp = 600,
			crooked_souls = {
				max_range = 300,
				max_total = 10,
				max_targets = 1,
				nodes_limit = 60,
				cooldown = 8,
				nodes_random_min = 5,
				nodes_random_max = 10
			},
			melee_attack = {
				cooldown = 1,
				damage_min = 4,
				damage_max = 8
			},
			ranged_attack = {
				max_range = 120,
				damage_min = 12,
				cooldown = 1.5,
				damage_max = 18,
				damage_type = DAMAGE_MAGICAL
			},
			nightmare = {
				speed = 50,
				armor = 0,
				hp = 120,
				magic_armor = 0,
				lives_cost = 1,
				basic_attack = {
					cooldown = 1,
					damage_max = 10,
					damage_min = 6
				}
			}
		},
		small_stalker = {
			speed = 50,
			armor = 0,
			hp = 180,
			gold = 10,
			magic_armor = 0,
			dodge = {
				cooldown = 50,
				nodes_advance = 25,
				nodes_before_exit = 80,
				wait_between_teleport = fts(3)
			}
		},
		unblinded_priest = {
			gold = 25,
			health_trigger_factor = 0.25,
			magic_armor = 0.9,
			speed = 28,
			armor = 0,
			hp = 400,
			transformation_time = 4,
			basic_attack = {
				cooldown = 1,
				damage_min = 7,
				damage_max = 11
			},
			ranged_attack = {
				max_range = 120,
				min_range = 10,
				damage_min = 18,
				cooldown = 2,
				damage_max = 28,
				damage_type = DAMAGE_MAGICAL
			},
			abomination = {
				gold = 30,
				magic_armor = 0,
				speed = 20,
				armor = 0.5,
				hp = 900,
				lives_cost = 2,
				melee_attack = {
					cooldown = 2,
					damage_min = 26,
					damage_max = 38
				},
				eat = {
					cooldown = 10,
					hp_required = 0.3
				},
				glare = {
					regen_hp = 15
				}
			}
		},
		abomination_stage_8 = {
			speed = 0,
			armor = 0,
			hp = 1000,
			regen_cooldown = 0.8,
			gold = 0,
			regen_health = 60,
			magic_armor = 0,
			melee_attack = {
				cooldown = 2,
				damage_min = 40,
				damage_max = 60
			}
		},
		spiderling = {
			speed = 64,
			armor = 0,
			hp = 200,
			gold = 10,
			magic_armor = 0.3,
			basic_attack = {
				cooldown = 1,
				damage_min = 8,
				damage_max = 12
			}
		},
		unblinded_shackler = {
			speed = 28,
			armor = 0,
			hp = 750,
			gold = 50,
			magic_armor = 0.6,
			melee_attack = {
				cooldown = 1.5,
				damage_min = 18,
				damage_max = 26
			},
			shackles = {
				max_range = 150,
				health_trigger_factor = 0.5,
				min_targets = 1,
				max_targets = 2
			}
		},
		armored_nightmare = {
			speed = 28,
			armor = 0.8,
			hp = 350,
			gold = 20,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 12,
				damage_max = 18,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		corrupted_stalker = {
			speed = 20,
			armor = 0,
			hp = 1500,
			gold = 100,
			magic_armor = 0,
			lives_cost = 2
		},
		crystal_golem = {
			speed = 20,
			armor = 0.8,
			hp = 2400,
			gold = 200,
			magic_armor = 0,
			lives_cost = 5,
			basic_attack = {
				cooldown = 2,
				damage_min = 30,
				damage_radius = 50,
				damage_max = 48,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		boss_corrupted_denas = {
			speed = 16,
			armor = 0.5,
			hp = 12000,
			magic_armor = 0.5,
			melee_attack = {
				damage_radius = 60,
				damage_min = 180,
				cooldown = 2,
				damage_max = 320,
				damage_type = DAMAGE_PHYSICAL
			},
			spawn_entities = {
				cooldown = 10,
				max_range = 120
			},
			life_threshold_stun = {
				stun_duration = 5,
				life_percentage = {
					50,
					25
				}
			}
		},
		glareling = {
			speed = 64,
			armor = 0,
			hp = 60,
			gold = 0,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 6,
				damage_max = 10
			},
			glare = {
				speed_factor = 1.75,
				regen_hp = 15
			}
		}
	},
	void_beyond = {
		glare = {
			range = 200,
			extra_duration = 0.25,
			regen_every = 0.25
		},
		blinker = {
			speed = 64,
			armor = 0,
			hp = 350,
			gold = 25,
			magic_armor = 0,
			ranged_attack = {
				stun_every = 0.25,
				radius = 45,
				duration = 4,
				max_range = 60,
				cooldown = 10,
				stun_duration = 1,
				min_range = 40
			},
			glare = {
				dot_damage_max = 2,
				regen_hp = 15,
				dot_duration = 0.5,
				dot_every = 0.25,
				dot_damage_min = 2
			}
		},
		mindless_husk = {
			speed = 36,
			armor = 0,
			hp = 300,
			gold = 20,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 10,
				damage_max = 15,
				damage_type = DAMAGE_PHYSICAL
			},
			spawn = {
				max_nodes_ahead = 20,
				max_nodes_to_exit = 70,
				min_nodes_ahead = 15
			},
			glare = {
				regen_hp = 15
			}
		},
		vile_spawner = {
			speed = 28,
			armor = 0,
			hp = 1000,
			gold = 75,
			magic_armor = 0.3,
			basic_attack = {
				cooldown = 1.5,
				damage_min = 14,
				damage_max = 21
			},
			lesser_spawn = {
				max_range = 80,
				max_total = 9,
				distance_between_entities = 40,
				min_distance_from_end = 400,
				cooldown = 8,
				entities_amount = 3,
				min_range = 40
			},
			glare = {
				lesser_spawn_cooldown = 6,
				regen_hp = 10
			}
		},
		lesser_eye = {
			speed = 75,
			armor = 0,
			hp = 80,
			gold = 0,
			magic_armor = 0,
			glare = {
				regen_hp = 15
			}
		},
		noxious_horror = {
			gold = 45,
			magic_armor = 0,
			speed = 36,
			armor = 0,
			hp = 600,
			basic_attack = {
				cooldown = 1,
				damage_min = 9,
				damage_max = 14,
				damage_type = DAMAGE_PHYSICAL
			},
			ranged_attack = {
				max_range = 300,
				radius = 50,
				damage_min = 18,
				cooldown = 4,
				min_range = 100,
				damage_max = 28,
				damage_type = DAMAGE_TRUE
			},
			poison = {
				damage_max = 6,
				duration = 4,
				damage_min = 4,
				every = 0.25
			},
			glare = {
				regen_hp = 15,
				magic_armor = 0.9,
				aura = {
					radius = 30
				}
			}
		},
		hardened_horror = {
			speed = 36,
			armor = 0,
			hp = 1200,
			gold = 80,
			magic_armor = 0,
			basic_attack = {
				cooldown = 2,
				damage_min = 28,
				damage_radius = 40,
				damage_max = 42,
				damage_type = DAMAGE_PHYSICAL
			},
			glare = {
				armor = 0.9,
				regen_hp = 15,
				roll_speed = 70
			}
		},
		evolving_scourge = {
			magic_armor = 0,
			armor = 0.3,
			lives_cost = 2,
			gold = {
				30,
				50,
				90
			},
			hp = {
				450,
				800,
				1500
			},
			speed = {
				50,
				36,
				20
			},
			basic_attack = {
				cooldown = {
					1,
					2,
					2
				},
				damage_max = {
					18,
					36,
					72
				},
				damage_min = {
					12,
					24,
					48
				},
				damage_type = DAMAGE_PHYSICAL
			},
			eat = {
				cooldown = 20,
				hp_required = 0.3
			},
			glare = {
				regen_hp = 15
			}
		},
		amalgam = {
			gold = 200,
			magic_armor = 0,
			speed = 20,
			armor = 0.4,
			hp = 3500,
			lives_cost = 5,
			basic_attack = {
				cooldown = 2,
				damage_min = 80,
				damage_radius = 50,
				damage_max = 120,
				damage_type = DAMAGE_PHYSICAL
			},
			explosion = {
				damage_radius = 60,
				damage_max = 200,
				damage_min = 100,
				damage_type = DAMAGE_PHYSICAL
			},
			glare = {
				regen_hp = 15
			}
		},
		boss_cult_leader = {
			open_magic_armor = 0,
			close_armor = 0.9,
			close_magic_armor = 0.9,
			denas_ray_resistance = 0.5,
			speed = 16,
			hp = 15000,
			open_armor = 0,
			glare = {
				regen_hp = 50
			},
			melee_attack = {
				damage_radius = 10,
				damage_min = 160,
				cooldown = 1,
				damage_max = 240,
				damage_type = DAMAGE_PHYSICAL
			},
			block_attack = {
				damage_min = 0,
				radius = 100,
				damage_max = 0,
				damage_type = DAMAGE_PHYSICAL
			},
			area_attack = {
				min_count = 2,
				cooldown = 4,
				damage_min = 320,
				damage_radius = 80,
				damage_max = 320,
				damage_type = DAMAGE_MAGICAL
			},
			life_threshold_teleport = {
				away_duration = 8,
				life_percentage = {
					66.67,
					33.33
				}
			}
		}
	},
	undying_hatred = {
		corrupted_elf = {
			speed = 36,
			armor = 0.25,
			hp = 350,
			gold = 30,
			spawn_nodes_limit = 60,
			magic_armor = 0,
			melee_attack = {
				cooldown = 0.8,
				damage_max = 14,
				damage_min = 10
			},
			ranged_attack = {
				max_range = 250,
				damage_max = 14,
				damage_min = 10,
				cooldown = 10,
				min_range = 80
			}
		},
		specter = {
			speed = 36,
			armor = 0,
			hp = 150,
			speed_chase = 120,
			magic_armor = 0,
			lives_cost = 1,
			basic_attack = {
				cooldown = 1,
				damage_max = 12,
				damage_min = 8
			}
		},
		dust_cryptid = {
			nodes_to_prevent_dust = 25,
			hp = 200,
			gold = 20,
			magic_armor = 0.25,
			speed = 50,
			armor = 0,
			dust_duration = 3.5,
			dust_radius = 60,
			lives_cost = 1
		},
		bane_wolf = {
			speed = 50,
			armor = 0,
			hp = 250,
			max_speed_mult = 2.2,
			gold = 10,
			magic_armor = 0,
			lives_cost = 1,
			basic_attack = {
				cooldown = 0.8,
				damage_min = 10,
				damage_max = 16,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		deathwood = {
			speed = 20,
			armor = 0.6,
			hp = 3200,
			gold = 200,
			magic_armor = 0,
			lives_cost = 2,
			basic_attack = {
				cooldown = 1.5,
				damage_min = 62,
				damage_radius = 25,
				damage_max = 94,
				damage_type = DAMAGE_PHYSICAL
			},
			ranged_attack = {
				max_range = 180,
				min_range = 80,
				damage_min = 120,
				cooldown = 6,
				damage_radius = 50,
				damage_max = 180,
				damage_type = DAMAGE_EXPLOSION
			}
		},
		animated_armor = {
			hp = 1500,
			armor = 0.8,
			gold = 100,
			magic_armor = 0,
			speed = 28,
			death_duration = 10,
			respawn_health_factor = 1,
			lives_cost = 2,
			basic_attack = {
				cooldown = 2,
				damage_min = 32,
				damage_radius = 25,
				damage_max = 48,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		revenant_soulcaller = {
			gold = 50,
			magic_armor = 0.8,
			speed = 28,
			armor = 0,
			hp = 900,
			melee_attack = {
				cooldown = 1.5,
				damage_min = 10,
				damage_max = 24
			},
			ranged_attack = {
				max_range = 120,
				damage_min = 16,
				cooldown = 2,
				damage_max = 38,
				damage_type = DAMAGE_MAGICAL
			},
			summon = {
				max_range = 300,
				max_total = 10,
				nodes_random_min = 5,
				nodes_limit = 60,
				cooldown = 10,
				nodes_random_max = 10
			},
			tower_stun = {
				max_range = 150,
				max_targets = 1,
				min_targets = 1,
				cooldown = 15,
				duration = 5
			}
		},
		revenant_harvester = {
			speed = 36,
			armor = 0,
			hp = 600,
			gold = 30,
			magic_armor = 0.25,
			melee_attack = {
				cooldown = 1,
				damage_min = 22,
				damage_max = 52
			},
			clone = {
				cooldown = 12,
				max_total = 5,
				max_range = 150,
				nodes_limit = 60
			}
		},
		boss_navira = {
			speed = 16,
			armor = 0,
			hp = 16000,
			magic_armor = 0,
			melee_attack = {
				damage_radius = 60,
				damage_min = 192,
				cooldown = 1.5,
				damage_max = 280,
				damage_type = DAMAGE_PHYSICAL
			},
			tornado = {
				damage = 15,
				cycle_time = 0.25,
				duration = 6,
				speed_mult = 1.25,
				radius = 40,
				hp_trigger = {
					0.9,
					0.6,
					0.15
				},
				fire_balls = {
					3,
					3,
					3
				},
				damage_type = DAMAGE_MAGICAL
			},
			fire_balls = {
				wait_between_balls = 5,
				wait_between_shots = 0.2,
				count = 3,
				wait_before_shoot = 1,
				cooldown = 25,
				stun_duration = 5
			},
			corruption = {
				hp = 320,
				cooldown = 10
			}
		}
	},
	crocs = {
		crocs_basic_egg = {
			speed = 50,
			armor = 0.3,
			hp = 70,
			gold = 3,
			magic_armor = 0,
			water_fixed_speed = {
				[9000] = 50,
				[21] = 80,
				[22] = 50
			},
			evolve = {
				cooldown_max = 11,
				cooldown_min = 9
			}
		},
		crocs_basic = {
			speed = 36,
			armor = 0,
			hp = 350,
			gold = 6,
			magic_armor = 0,
			water_fixed_speed = {
				[9000] = 50,
				[21] = 80,
				[22] = 50
			},
			basic_attack = {
				cooldown = 1,
				damage_min = 10,
				damage_max = 16
			}
		},
		quickfeet_gator = {
			gold = 20,
			magic_armor = 0,
			speed = 60,
			armor = 0,
			hp = 250,
			water_fixed_speed = {
				[9000] = 50,
				[21] = 80,
				[22] = 50
			},
			basic_attack = {
				cooldown = 1,
				damage_min = 11,
				damage_max = 17
			},
			ranged_attack = {
				max_range = 250,
				min_range = 70,
				damage_min = 11,
				cooldown = 3,
				damage_max = 17
			},
			chicken_leg = {
				max_range = 250,
				min_range = 70,
				target_nodes_from_start = 22,
				self_nodes_from_start = 22
			}
		},
		killertile = {
			speed = 23,
			armor = 0,
			hp = 1400,
			gold = 50,
			magic_armor = 0,
			lives_cost = 1,
			water_fixed_speed = {
				[9000] = 50,
				[21] = 80,
				[22] = 50
			},
			basic_attack = {
				cooldown = 1.5,
				damage_min = 66,
				damage_max = 99
			}
		},
		crocs_flier = {
			speed = 60,
			armor = 0,
			hp = 225,
			gold = 15,
			magic_armor = 0
		},
		crocs_ranged = {
			speed = 60,
			armor = 0,
			hp = 300,
			gold = 17,
			magic_armor = 0,
			water_fixed_speed = {
				[9000] = 50,
				[21] = 80,
				[22] = 50
			},
			basic_attack = {
				cooldown = 1.5,
				damage_min = 11,
				damage_max = 17
			},
			ranged_attack = {
				max_range = 200,
				min_range = 60,
				damage_min = 29,
				cooldown = 2,
				damage_max = 43
			}
		},
		crocs_shaman = {
			gold = 90,
			magic_armor = 0.6,
			speed = 28,
			armor = 0,
			hp = 700,
			water_fixed_speed = {
				[9000] = 50,
				[21] = 80,
				[22] = 50
			},
			melee_attack = {
				cooldown = 2,
				damage_min = 13,
				damage_max = 20
			},
			ranged_attack = {
				max_range = 120,
				damage_min = 30,
				cooldown = 1.5,
				damage_max = 45,
				damage_type = DAMAGE_MAGICAL
			},
			healing = {
				cooldown = 10,
				range = 150,
				heal_min = 15,
				min_targets = 1,
				heal_every = 0.5,
				duration = 2,
				heal_max = 45,
				max_targets = 5
			},
			debuff_towers = {
				cooldown = 8,
				stun_duration = 6,
				max_range = 200,
				nodes_limit = 40
			}
		},
		crocs_tank = {
			speed = 20,
			armor = 0.35,
			hp = 2200,
			gold = 70,
			magic_armor = 0,
			lives_cost = 2,
			basic_attack = {
				cooldown = 2,
				damage_min = 48,
				damage_max = 64
			},
			charge = {
				min_distance_from_end = 75,
				range = 50,
				damage_soldier_max = 62,
				cooldown = 13,
				speed = 120,
				blocker_charge_delay = 3,
				duration = 1.5,
				damage_soldier_min = 62,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		crocs_egg_spawner = {
			gold = 100,
			magic_armor = 0,
			speed = 20,
			armor = 0.6,
			hp = 850,
			lives_cost = 1,
			water_fixed_speed = {
				[9000] = 50,
				[21] = 80,
				[22] = 50
			},
			basic_attack = {
				cooldown = 1.5,
				damage_min = 42,
				damage_max = 63
			},
			eggs_spawn = {
				max_range = 120,
				max_total = 10,
				distance_between_entities = 40,
				min_distance_from_end = 430,
				cooldown = 10,
				entities_amount = 3,
				min_range = 90
			}
		},
		crocs_hydra = {
			gold = 250,
			magic_armor = 0.8,
			speed = 20,
			armor = 0,
			lives_cost = 5,
			hp = {
				2750,
				3800
			},
			water_fixed_speed = {
				[9000] = 30,
				[21] = 30,
				[22] = 30
			},
			basic_attack = {
				cooldown = 1.5,
				damage_min = 75,
				damage_max = 105,
				damage_type = DAMAGE_PHYSICAL
			},
			dot = {
				max_range = 200,
				radius = 60,
				duration = 6,
				cooldown = 8,
				damage_max = 12,
				damage_min = 8,
				nodes_limit = 60,
				damage_every = 0.3,
				damage_type = DAMAGE_TRUE
			}
		},
		boss_crocs = {
			hp = {
				16000,
				16000,
				16000,
				16000,
				16000
			},
			armor = {
				0,
				0,
				0,
				0,
				0
			},
			magic_armor = {
				0,
				0,
				0,
				0,
				0
			},
			speed = {
				22,
				22,
				22,
				22,
				22
			},
			eat_tower_evolution = {
				50,
				50,
				50,
				50
			},
			life_percentage_evolution = {
				0.7,
				0.65,
				0.58,
				0.47
			},
			pre_fight_towers_destroy = {
				taunt_keys_amount = 8,
				destroy_tower_time = 2,
				prevent_timed_destroy_price = 0,
				can_prevent_destroy = false,
				needs_arborean_mages_to_clean = false,
				waves = {
					3,
					5,
					7,
					9,
					11,
					13,
					15
				},
				first_cooldown = {
					5,
					7,
					1,
					5,
					15,
					12,
					10
				},
				cooldown = {
					0,
					0,
					0,
					0,
					0,
					0,
					0
				},
				max_casts = {
					1,
					1,
					1,
					1,
					1,
					1,
					1
				},
				low_priority_holders = {
					"4",
					"7",
					"8",
					"12"
				}
			},
			primordial_hunger = {
				{
					hp_evolution_method = 2,
					pre_evolution_step_cap = 0.7,
					hp_restore_fixed_amount = 4000
				},
				{
					hp_evolution_method = 2,
					pre_evolution_step_cap = 0.7,
					hp_restore_fixed_amount = 4000
				},
				{
					hp_evolution_method = 2,
					pre_evolution_step_cap = 0.7,
					hp_restore_fixed_amount = 4000
				},
				{
					hp_evolution_method = 2,
					pre_evolution_step_cap = 0.8,
					hp_restore_fixed_amount = 4000
				},
				{
					hp_evolution_method = 2,
					pre_evolution_step_cap = 0.9,
					hp_restore_fixed_amount = 4000
				}
			},
			basic_attack = {
				cooldown = 1.5,
				damage_radius = 60,
				damage_max = {
					250,
					290,
					480,
					600,
					720
				},
				damage_min = {
					150,
					240,
					360,
					430,
					500
				},
				instakill_threshold = {
					0.95,
					0.95,
					0.95,
					0.95,
					0.95
				}
			},
			tower_destruction = {
				cooldown = {
					12,
					12,
					18,
					18,
					20
				},
				max_range = {
					200,
					200,
					200,
					200,
					200
				},
				low_priority_holders = {}
			},
			eggs_spawn = {
				max_total = 1e+99,
				distance_between_entities = 12,
				cooldown = {
					25,
					25,
					25,
					25,
					25
				},
				min_range = {
					80,
					90,
					100,
					110,
					120
				},
				max_range = {
					330,
					340,
					350,
					360,
					370
				},
				loop_times = {
					2,
					3,
					4,
					4,
					5
				},
				entities_amount = {
					22,
					22,
					20,
					20,
					16
				},
				min_distance_from_end = {
					[19] = 430,
					[20] = 600,
					[12] = 430,
					[9] = 600
				}
			},
			poison_rain = {
				poison_radius = 80,
				poison_damage_every = 0.25,
				cooldown = {
					20,
					30
				},
				min_range = {
					0,
					0
				},
				max_range = {
					3000,
					3000
				},
				shots_amount = {
					5,
					10
				},
				poison_damage_min = {
					3,
					5
				},
				poison_damage_max = {
					5,
					9
				},
				poison_decal_duration = {
					6,
					6
				},
				poison_mod_duration = {
					0.4,
					0.4
				},
				damage_type = DAMAGE_PHYSICAL
			},
			stomper = {
				damage_every = 0.25,
				range = 80,
				damage_soldiers_min = 3,
				damage_soldiers_max = 6,
				damage_type = DAMAGE_PHYSICAL
			}
		}
	},
	hammer_and_anvil = {
		darksteel_hammerer = {
			speed = 28,
			armor = 0,
			hp = 450,
			gold = 22,
			magic_armor = 0,
			melee_attack = {
				cooldown = 0.8,
				damage_max = 18,
				damage_min = 12
			}
		},
		darksteel_shielder = {
			speed = 28,
			armor = 0.8,
			hp = 550,
			gold = 23,
			magic_armor = 0,
			melee_attack = {
				cooldown = 1.5,
				damage_max = 26,
				damage_min = 18
			}
		},
		surveillance_sentry = {
			speed = 50,
			armor = 0.2,
			hp = 250,
			gold = 5,
			magic_armor = 0,
			lives_cost = 1
		},
		rolling_sentry = {
			speed = 64,
			armor = 0.2,
			hp = 800,
			gold = 25,
			magic_armor = 0,
			melee_attack = {
				cooldown = 1,
				damage_max = 18,
				damage_min = 10,
				damage_type = DAMAGE_EXPLOSION
			},
			ranged_attack = {
				max_range = 150,
				damage_max = 18,
				damage_min = 10,
				cooldown = 1,
				min_range = 80,
				damage_type = DAMAGE_EXPLOSION
			}
		},
		scrap_drone = {
			speed = 75,
			armor = 0,
			hp = 100,
			gold = 0,
			magic_armor = 0,
			lives_cost = 1
		},
		mad_tinkerer = {
			speed = 50,
			armor = 0,
			hp = 1000,
			gold = 70,
			magic_armor = 0.8,
			melee_attack = {
				cooldown = 1,
				damage_min = 16,
				damage_max = 24
			},
			clone = {
				max_range = 150,
				max_total = 5,
				nodes_limit = 30,
				cooldown = 1,
				min_range = 80
			}
		},
		brute_welder = {
			speed = 24,
			armor = 0,
			hp = 1800,
			gold = 120,
			magic_armor = 0,
			lives_cost = 2,
			basic_attack = {
				cooldown = 2,
				flame = {
					radius = 40,
					duration = 1,
					cycle_time = 0.25
				},
				burn = {
					cycle_time = 0.25,
					damage_min = 5,
					duration = 2,
					damage_max = 7,
					damage_type = DAMAGE_TRUE
				}
			},
			death_missile = {
				block_duration = 10,
				range = 200
			}
		},
		scrap_speedster = {
			speed = 80,
			armor = 0,
			hp = 200,
			gold = 6,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1.5,
				damage_max = 11,
				damage_min = 7
			}
		},
		scrap = {
			duration = 6
		},
		common_clone = {
			speed = 36,
			armor = 0,
			hp = 120,
			gold = 0,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 5,
				damage_max = 10,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		darksteel_fist = {
			speed = 28,
			armor = 0.5,
			hp = 700,
			gold = 30,
			magic_armor = 0,
			basic_attack = {
				cooldown = 0,
				damage_max = 9,
				damage_min = 6,
				damage_type = DAMAGE_PHYSICAL
			},
			stun_attack = {
				cooldown = 3,
				damage_min = 48,
				damage_radius = 50,
				stun_duration = 1.5,
				damage_max = 72,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		darksteel_guardian = {
			gold = 200,
			speed = 18,
			magic_armor = 0,
			rage_hp_trigger = 0.3,
			armor = 0.8,
			hp = 3000,
			lives_cost = 5,
			basic_attack = {
				cooldown = 2,
				damage_min = 96,
				damage_radius = 50,
				damage_max = 144,
				damage_type = DAMAGE_PHYSICAL
			},
			rage_attack = {
				cooldown = 1.5,
				damage_min = 108,
				damage_max = 162,
				damage_type = DAMAGE_PHYSICAL
			},
			death_explotion = {
				damage_radius = 50,
				damage_min = 300,
				damage_max = 200,
				damage_type = DAMAGE_EXPLOSION
			}
		},
		darksteel_anvil = {
			speed = 42,
			armor = 0,
			hp = 1400,
			gold = 80,
			magic_armor = 0.5,
			basic_attack = {
				cooldown = 1,
				damage_max = 58,
				damage_min = 38,
				damage_type = DAMAGE_PHYSICAL
			},
			basic_ranged = {
				max_range = 200,
				min_range = 0,
				damage_min = 58,
				cooldown = 3,
				damage_max = 86,
				damage_type = DAMAGE_PHYSICAL
			},
			aura = {
				min_targets = 2,
				duration = 3,
				nodes_limit_end = 30,
				trigger_range = 80,
				cooldown = 8,
				nodes_limit_start = 30,
				aura_radius = 125,
				cycle_time = 0.25,
				target_self = true,
				mod = {
					duration = 4,
					speed_factor = 1.5,
					extra_armor = 0.3
				}
			}
		},
		darksteel_hulk = {
			speed = 20,
			armor = 0,
			hp = 3500,
			gold = 200,
			magic_armor = 0.8,
			lives_cost = 3,
			basic_attack = {
				cooldown = 2,
				damage_min = 104,
				damage_max = 156
			},
			charge = {
				damage_enemy_max = 72,
				health_threshold = 0.35,
				range = 50,
				damage_soldier_max = 120,
				cooldown = 20,
				damage_enemy_min = 48,
				charge_while_blocked = true,
				unstoppable_duration = 3,
				min_distance_from_end = 24,
				speed_mult = 3.2,
				damage_soldier_min = 80,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		machinist = {
			regen_health = 60,
			timeout = 30,
			gold = 0,
			magic_armor = 0,
			operation_cd = 3,
			speed = 36,
			armor = 0,
			hp = 1500,
			regen_cooldown = 0.8,
			operations_needed = 3,
			basic_attack = {
				cooldown = 1,
				damage_min = 24,
				damage_max = 36,
				damage_type = DAMAGE_PHYSICAL
			}
		},
		boss_machinist = {
			speed = 16,
			armor = 0,
			hp = 10000,
			stop_cooldown = 5,
			magic_armor = 0,
			attacks_count = 1,
			ranged_attack = {
				max_range = 300,
				min_range = 80,
				damage_min = 95,
				cooldown = 0,
				damage_radius = 60,
				damage_max = 145,
				damage_type = DAMAGE_EXPLOSION
			},
			fire_floor = {
				radius = 50,
				damage_min = 4,
				cycle_time = 0.2,
				damage_max = 6,
				damage_type = DAMAGE_TRUE,
				burn = {
					cycle_time = 0.25,
					damage_min = 1,
					duration = 4,
					damage_max = 3,
					damage_type = DAMAGE_TRUE
				}
			}
		},
		deformed_grymbeard_clone = {
			shield_hp_threshold = 0.5,
			armor = 0,
			speed_factor = 2.5,
			gold = 20,
			magic_armor = 0,
			speed = 24,
			shield_magic_armor = 0.8,
			hp = 800,
			lives_cost = 2
		},
		boss_deformed_grymbeard = {
			clones_to_die = 15
		},
		boss_grymbeard = {
			speed = 12,
			armor = 0,
			hp = 16000,
			magic_armor = 0,
			melee_attack = {
				damage_radius = 45,
				damage_min = 200,
				cooldown = 2,
				damage_max = 300,
				damage_type = DAMAGE_PHYSICAL
			},
			ranged_attack = {
				max_range = 300,
				min_range = 80,
				damage_min = 380,
				cooldown = 5,
				damage_radius = 45,
				damage_max = 570,
				damage_type = DAMAGE_EXPLOSION
			}
		}
	},
	arachnids = {
		spider_priest = {
			armor = 0,
			gold = 30,
			health_trigger_factor = 0.3,
			magic_armor = 0.9,
			speed = 32,
			transformation_nodes_limit = 30,
			hp = 700,
			transformation_time = 5.5,
			basic_attack = {
				cooldown = 1,
				damage_min = 7,
				damage_max = 11
			},
			ranged_attack = {
				max_range = 130,
				min_range = 10,
				damage_min = 36,
				cooldown = 1.2,
				damage_max = 52,
				damage_type = DAMAGE_MAGICAL
			}
		},
		glarenwarden = {
			armor = 0.9,
			hp = 1500,
			gold = 70,
			magic_armor = 0,
			speed = {
				24,
				24,
				24,
				24
			},
			basic_attack = {
				damage_min = 56,
				cooldown = 2,
				damage_max = 84,
				damage_type = DAMAGE_PHYSICAL,
				lifesteal = {
					damage_factor = 0.5,
					fixed_heal = 0
				}
			}
		},
		ballooning_spider = {
			speed = 64,
			armor = 0.45,
			hp = 160,
			speed_air = 36,
			gold = 20,
			detection_range = 100,
			magic_armor = 0
		},
		spider_sister = {
			speed = 28,
			armor = 0,
			hp = 700,
			gold = 45,
			magic_armor = 0.3,
			spiderlings_summon = {
				nodes_random_min = 5,
				max_total = 12,
				cooldown_increment = 1,
				max_range = 300,
				cooldown_max = 12,
				cooldown_init = 5,
				nodes_limit = 60,
				nodes_random_max = 10,
				cooldown = {
					2.5,
					2.5,
					2.5,
					3.5
				}
			},
			melee_attack = {
				cooldown = 1,
				damage_min = 4,
				damage_max = 8
			},
			ranged_attack = {
				max_range = 150,
				damage_min = 13,
				cooldown = 1.5,
				damage_max = 21,
				damage_type = DAMAGE_MAGICAL
			}
		},
		glarebrood_crystal = {
			armor = 0,
			hp = 150,
			gold = 1,
			transformation_time = 4,
			magic_armor = 0.9,
			spiderling_spawn = {
				gold = 1
			}
		},
		cultbrood = {
			armor = 0,
			hp = 600,
			gold = 50,
			spawn_time = 2,
			magic_armor = 0,
			speed = {
				58,
				58,
				58,
				58
			},
			basic_attack = {
				cooldown = 1,
				damage_min = 16,
				damage_max = 24,
				damage_type = DAMAGE_PHYSICAL
			},
			poison_attack = {
				damage_max = 48,
				transformation_nodes_limit = 40,
				damage_min = 32,
				cooldown = 9,
				cooldown_init = 0,
				damage_type = DAMAGE_PHYSICAL,
				poison = {
					damage_every = 0.2,
					duration = 6,
					damage = 3,
					damage_type = DAMAGE_PHYSICAL
				}
			}
		},
		drainbrood = {
			speed = 48,
			armor = 0,
			hp = 700,
			gold = 55,
			magic_armor = 0,
			basic_attack = {
				cooldown = 1,
				damage_min = 21,
				damage_max = 35,
				damage_type = DAMAGE_PHYSICAL
			},
			webspit = {
				damage_min = 30,
				cooldown = 11,
				duration = 4,
				damage_max = 50,
				damage_type = DAMAGE_PHYSICAL,
				lifesteal = {
					fixed_heal = 0,
					damage_factor = {
						3,
						3,
						3,
						4
					}
				}
			}
		},
		spidead = {
			speed = 36,
			armor = 0,
			hp = 600,
			gold = 25,
			magic_armor = 0.333,
			nodes_to_prevent_web = 25,
			basic_attack = {
				cooldown = 1,
				damage_min = 42,
				damage_max = 70,
				damage_type = DAMAGE_PHYSICAL
			},
			spiderweb = {
				duration = 14,
				cycle_time = 0.3,
				min_distance = 50
			}
		},
		boss_spider_queen = {
			spawn_node = 45,
			gold = 0,
			spawn_path = 1,
			speed = 13,
			armor = 0,
			hp = 20000,
			magic_armor = {
				0.3,
				0.3,
				0.3,
				0.6
			},
			reach_nodes = {
				76
			},
			jump_paths = {
				8
			},
			jump_nodes = {
				65
			},
			wave_spawns = {
				[3] = {
					{
						delay = 16,
						spawns = {
							{
								pi = 2,
								spi = 1,
								ni = 95
							}
						}
					}
				},
				[4] = {
					{
						delay = 3,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							}
						}
					},
					{
						delay = 7,
						spawns = {
							{
								pi = 5,
								spi = 1,
								ni = 55
							}
						}
					},
					{
						delay = 43,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							}
						}
					}
				},
				[7] = {
					{
						delay = 50,
						spawns = {
							{
								pi = 5,
								spi = 1,
								ni = 55
							}
						}
					}
				},
				[10] = {
					{
						delay = 2,
						spawns = {
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					},
					{
						delay = 28,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							},
							{
								pi = 5,
								spi = 1,
								ni = 55
							}
						}
					}
				},
				[12] = {
					{
						delay = 2,
						spawns = {
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					},
					{
						delay = 42,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							},
							{
								pi = 5,
								spi = 1,
								ni = 55
							},
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					}
				},
				[15] = {
					{
						delay = 2,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							},
							{
								pi = 5,
								spi = 1,
								ni = 55
							},
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					},
					{
						delay = 15,
						spawns = {
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					},
					{
						delay = 45,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							},
							{
								pi = 5,
								spi = 1,
								ni = 55
							},
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							},
							{
								pi = 7,
								spi = 1,
								ni = 70
							},
							{
								pi = 8,
								spi = 1,
								ni = 90
							}
						}
					}
				}
			},
			wave_spawns_impossible = {
				[3] = {
					{
						delay = 16,
						spawns = {
							{
								pi = 2,
								spi = 1,
								ni = 95
							}
						}
					}
				},
				[4] = {
					{
						delay = 3,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							}
						}
					},
					{
						delay = 7,
						spawns = {
							{
								pi = 5,
								spi = 1,
								ni = 55
							}
						}
					},
					{
						delay = 43,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							}
						}
					},
					{
						delay = 47,
						spawns = {
							{
								pi = 5,
								spi = 1,
								ni = 55
							}
						}
					}
				},
				[6] = {
					{
						delay = 50,
						spawns = {
							{
								pi = 2,
								spi = 1,
								ni = 95
							}
						}
					}
				},
				[7] = {
					{
						delay = 50,
						spawns = {
							{
								pi = 5,
								spi = 1,
								ni = 55
							}
						}
					}
				},
				[10] = {
					{
						delay = 2,
						spawns = {
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					},
					{
						delay = 28,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							},
							{
								pi = 5,
								spi = 1,
								ni = 55
							}
						}
					}
				},
				[12] = {
					{
						delay = 2,
						spawns = {
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					},
					{
						delay = 42,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							},
							{
								pi = 5,
								spi = 1,
								ni = 55
							},
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					}
				},
				[15] = {
					{
						delay = 2,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							},
							{
								pi = 5,
								spi = 1,
								ni = 55
							},
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					},
					{
						delay = 15,
						spawns = {
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							}
						}
					},
					{
						delay = 45,
						spawns = {
							{
								pi = 1,
								spi = 1,
								ni = 78
							},
							{
								pi = 5,
								spi = 1,
								ni = 55
							},
							{
								pi = 7,
								spi = 1,
								ni = 35
							},
							{
								pi = 8,
								spi = 1,
								ni = 35
							},
							{
								pi = 7,
								spi = 1,
								ni = 70
							},
							{
								pi = 8,
								spi = 1,
								ni = 90
							}
						}
					}
				}
			},
			basic_attack = {
				damage_radius = 110,
				damage_min = 258,
				cooldown = 1,
				damage_max = 372,
				damage_type = DAMAGE_PHYSICAL
			},
			ranged_attack = {
				max_range = 200,
				damage_max = 64,
				damage_min = 86,
				cooldown = 3,
				min_range = 10,
				damage_type = DAMAGE_PHYSICAL,
				poison = {
					damage_every = 0.2,
					duration = 5,
					damage_max = 5,
					damage_min = 5
				}
			},
			stun_towers = {
				max_range = 200,
				max_targets = 4,
				min_targets = 3,
				required_clics_desktop = 3,
				cooldown = 22,
				required_clics_phone_tablet = 5,
				nodes_limit = 30,
				required_clics_console = 2,
				duration = {
					5,
					5,
					5,
					4
				},
				duration_long = {
					15,
					15,
					15,
					20
				}
			},
			call_wardens = {
				nodes_spread = 6,
				nodes_offset = 8,
				first_cooldown = 15,
				use_custom_formation = false,
				cooldown = 40,
				amount = 2,
				nodes_spread_start = 3,
				nodes_limit_reverse = 60,
				nodes_limit = 20,
				custom_formation = {
					{
						{
							spi = 2,
							n = 5
						},
						{
							spi = 3,
							n = 5
						}
					},
					{
						{
							spi = 2,
							n = 5
						},
						{
							spi = 3,
							n = 5
						}
					},
					{
						{
							spi = 2,
							n = 5
						},
						{
							spi = 3,
							n = 5
						}
					}
				}
			},
			spiderweb = {
				duration = 18,
				cycle_time = 0.3,
				min_distance = 50
			},
			drain_life = {
				max_range = 106,
				min_targets = 1,
				cooldown = 21,
				cooldown_init = 30,
				nodes_limit = 50,
				max_targets = 1e+99,
				loop_duration = 5,
				lifesteal_loop = {
					damage_every = 0.3,
					fixed_heal = 0,
					damage_factor = {
						1,
						1,
						1,
						1
					},
					damage_min = {
						3,
						3,
						3,
						5
					},
					damage_max = {
						5,
						5,
						5,
						7
					},
					damage_type = DAMAGE_MAGICAL
				},
				lifesteal_end = {
					damage_factor = 1,
					fixed_heal = {
						500,
						500,
						500,
						750
					},
					damage_max = {
						750,
						750,
						750,
						900
					},
					damage_min = {
						750,
						750,
						750,
						900
					},
					damage_type = DAMAGE_MAGICAL
				}
			},
			webspit = {
				cooldown = 45,
				first_cooldown = 10,
				duration = 2,
				nodes_limit = 30
			}
		}
	}
}
local towers = {
	arcane_wizard = {
		shared_min_cooldown = 2,
		price = {
			110,
			150,
			220,
			280
		},
		stats = {
			cooldown = 3,
			range = 6,
			damage = 10
		},
		basic_attack = {
			cooldown = 2,
			damage_min = {
				12,
				25,
				48,
				70
			},
			damage_max = {
				18,
				47,
				80,
				132
			},
			range = {
				160,
				168,
				176,
				186
			},
			damage_every = fts(2)
		},
		disintegrate = {
			range = 186,
			price = {
				200,
				100,
				100
			},
			cooldown = {
				30,
				25,
				20
			},
			boss_damage = {
				900,
				1300,
				1800
			}
		},
		empowerment = {
			max_range = 300,
			min_range = 0,
			price = {
				200,
				150,
				150
			},
			cooldown = {
				1,
				1,
				1
			},
			damage_factor = {
				1.15,
				1.3,
				1.45
			},
			s_damage_factor = {
				0.15,
				0.3,
				0.45
			}
		}
	},
	elven_stargazers = {
		shared_min_cooldown = 2,
		price = {
			120,
			180,
			240,
			310
		},
		stats = {
			cooldown = 2,
			range = 6,
			damage = 10
		},
		basic_attack = {
			ray_timing = 0.2,
			cooldown = 2,
			damage_min = {
				4,
				11,
				22,
				34
			},
			damage_max = {
				6,
				18,
				32,
				52
			},
			range = {
				160,
				170,
				185,
				200
			},
			damage_every = fts(1)
		},
		teleport = {
			price = {
				250,
				100,
				100
			},
			teleport_nodes_back = {
				30,
				37,
				45
			},
			cooldown = {
				20,
				18,
				16
			},
			max_targets = {
				4,
				6,
				9
			}
		},
		stars_death = {
			max_range = 200,
			stun = 0.8,
			min_range = 0,
			duration = 1.5,
			price = {
				150,
				150,
				150
			},
			stars = {
				3,
				5,
				7
			},
			chance = {
				1,
				1,
				1
			},
			damage_min = {
				18,
				27,
				36
			},
			damage_max = {
				30,
				45,
				60
			},
			damage_type = DAMAGE_MAGICAL
		}
	},
	tricannon = {
		shared_min_cooldown = 3,
		price = {
			140,
			200,
			280,
			360
		},
		stats = {
			cooldown = 2,
			range = 6,
			damage = 9
		},
		basic_attack = {
			damage_radius = 45,
			cooldown = 3,
			bomb_amount = {
				3,
				3,
				3,
				3
			},
			damage_min = {
				3,
				8,
				16,
				28
			},
			damage_max = {
				5,
				12,
				24,
				42
			},
			range = {
				180,
				180,
				180,
				180
			},
			time_between_bombs = fts(1)
		},
		bombardment = {
			range = 180,
			damage_radius = 50,
			price = {
				250,
				250,
				250
			},
			cooldown = {
				15,
				15,
				15
			},
			damage_min = {
				24,
				32,
				40
			},
			damage_max = {
				48,
				64,
				80
			},
			spread = {
				20,
				20,
				20
			},
			node_skip = {
				11,
				6,
				4
			}
		},
		overheat = {
			price = {
				250,
				250,
				250
			},
			cooldown = {
				24,
				24,
				24
			},
			duration = {
				8,
				12,
				16
			},
			decal = {
				duration = 5,
				radius = 40,
				effect = {
					damage_every = 0.25,
					duration = 3,
					damage = {
						3,
						5,
						7
					},
					s_damage = {
						12,
						20,
						28
					}
				}
			}
		}
	},
	paladin_covenant = {
		max_soldiers = 3,
		rally_range = 145,
		price = {
			70,
			120,
			180,
			250
		},
		stats = {
			damage = 1,
			armor = 6,
			hp = 7
		},
		soldier = {
			dead_lifetime = 12,
			speed = 75,
			armor = {
				0,
				0.15,
				0.35,
				0.6
			},
			hp = {
				50,
				100,
				150,
				200
			},
			regen_hp = {
				6,
				12,
				18,
				28
			},
			basic_attack = {
				cooldown = 1,
				range = 70,
				damage_min = {
					1,
					3,
					6,
					10
				},
				damage_max = {
					3,
					5,
					9,
					15
				}
			}
		},
		lead = {
			price = {
				250
			},
			soldier_veteran = {
				s_aura_damage_buff_factor = 0.35,
				aura_duration = 16,
				aura_range = 150,
				armor = 0.8,
				hp = 250,
				aura_damage_buff_factor = 1.35,
				regen_hp = 30,
				basic_attack = {
					damage_max = 30,
					damage_min = 20
				},
				aura_cooldown = {
					20
				}
			}
		},
		healing_prayer = {
			duration = 4,
			heal_every = 0.25,
			price = {
				140,
				140,
				140
			},
			health_trigger_factor = {
				0.35,
				0.35,
				0.35
			},
			heal = {
				3,
				5,
				7
			},
			invincibility_duration = {
				4,
				5,
				6
			},
			healing_duration = {
				4,
				6,
				9
			},
			s_healing = {
				12,
				20,
				28
			},
			cooldown = {
				28,
				25,
				22
			}
		}
	},
	royal_archers = {
		stats = {
			cooldown = 8,
			range = 7,
			damage = 3
		},
		price = {
			70,
			100,
			160,
			250
		},
		basic_attack = {
			cooldown = 0.8,
			damage_min = {
				3,
				8,
				15,
				26
			},
			damage_max = {
				5,
				11,
				23,
				38
			},
			range = {
				160,
				170,
				185,
				200
			},
			damage_type = DAMAGE_PHYSICAL
		},
		armor_piercer = {
			range_trigger = 200,
			nearby_range = 100,
			range_effect = 200,
			price = {
				120,
				120,
				120
			},
			cooldown = {
				15,
				13,
				11
			},
			damage_min = {
				64,
				128,
				192
			},
			damage_max = {
				76,
				152,
				228
			},
			damage_type = DAMAGE_PHYSICAL,
			armor_penetration = {
				0.2,
				0.35,
				0.5
			}
		},
		rapacious_hunter = {
			range = 270,
			shoot_range = 25,
			max_distance_from_tower = 300,
			attack_cooldown = 2,
			price = {
				200,
				150,
				150
			},
			damage_min = {
				38,
				76,
				114
			},
			damage_max = {
				46,
				92,
				138
			},
			damage_type = DAMAGE_PHYSICAL
		}
	},
	viper_goblins = {
		price = {
			100,
			120,
			145,
			200
		},
		basic_attack = {
			modifier_duration = 3,
			range = 165,
			cooldown = 1.2,
			damage_every = 1,
			damage_min_poison = {
				1,
				8,
				15,
				6
			},
			damage_max_poison = {
				2,
				12,
				22,
				12
			},
			damage_min = {
				2,
				23,
				26,
				59
			},
			damage_max = {
				3,
				24,
				27,
				60
			},
			damage_type = DAMAGE_PHYSICAL
		},
		curse_of_the_snake = {
			damage_every = 1,
			cooldown = {
				20,
				15,
				10
			},
			damage_percentage = {
				10,
				10,
				10
			},
			damage_min = {
				20,
				25,
				30
			},
			price = {
				110,
				110,
				110
			}
		},
		snake_bomb = {
			radius = 85,
			min_targets = 2,
			price = {
				150,
				150,
				150
			},
			received_damage_factor = {
				2,
				2,
				2,
				2
			},
			cooldown = {
				15,
				15,
				15
			},
			slow_factor = {
				0.5,
				0.5,
				0.5
			},
			duration = {
				2,
				2,
				2
			}
		}
	},
	arborean_emissary = {
		rally_range = 179.20000000000002,
		shared_min_cooldown = 1,
		change_interval = 15,
		price = {
			190,
			220,
			260,
			320
		},
		stats = {
			cooldown = 3,
			range = 7,
			damage = 3
		},
		basic_attack = {
			cooldown = 1.2,
			damage_min = {
				3,
				7,
				15,
				27
			},
			damage_max = {
				6,
				13,
				27,
				48
			},
			damage_type = DAMAGE_MAGICAL,
			range = {
				160,
				180,
				200,
				220
			},
			received_damage_factor = {
				1.2,
				1.3,
				1.4,
				1.5
			},
			modifier_duration = {
				5,
				5,
				5,
				5
			}
		},
		gift_of_nature = {
			max_range = 230,
			radius = 75,
			heal_every = 0.25,
			price = {
				120,
				120,
				120
			},
			cooldown = {
				20,
				20,
				20
			},
			duration = {
				6,
				6,
				6
			},
			heal_min = {
				4,
				8,
				12
			},
			heal_max = {
				4,
				8,
				12
			},
			s_heal = {
				16,
				32,
				48
			},
			inflicted_damage_factor = {
				1,
				1,
				1
			}
		},
		wave_of_roots = {
			min_targets = 2,
			trigger_range = 200,
			effect_range = 220,
			price = {
				160,
				160,
				160
			},
			cooldown = {
				15,
				14,
				12
			},
			max_targets = {
				3,
				6,
				9
			},
			mod_duration = {
				3,
				3,
				3
			},
			damage_min = {
				40,
				50,
				60
			},
			damage_max = {
				40,
				50,
				60
			},
			s_damage = {
				40,
				50,
				60
			},
			damage_type = DAMAGE_TRUE
		}
	},
	elder_portal = {
		shared_min_cooldown = 3,
		price = {
			105,
			145,
			220,
			280
		},
		basic_attack = {
			distance_between = 30,
			cooldown = 3,
			damage_radius = 30,
			damage_min = {
				10,
				18,
				35,
				55
			},
			damage_max = {
				14,
				40,
				75,
				125
			},
			damage_type = DAMAGE_MAGICAL,
			duration = {
				10,
				10,
				10,
				10
			},
			range = {
				160,
				160,
				160,
				160
			},
			spawn_offset = fts(0)
		},
		orbital_cannon = {
			damage_radius = 80,
			price = {
				100,
				150,
				150
			},
			cooldown = {
				15,
				12,
				10
			},
			damage_min = {
				40,
				50,
				60
			},
			damage_max = {
				45,
				55,
				65
			},
			damage_type = DAMAGE_PHYSICAL
		},
		teleport = {
			min_targets = 2,
			max_times_applied = 3,
			price = {
				100,
				150,
				150
			},
			cooldown = {
				15,
				12,
				10
			},
			max_targets = {
				1,
				2,
				3
			},
			nodes_offset = {
				-20,
				-20,
				-20
			}
		}
	},
	demon_pit = {
		price = {
			80,
			140,
			220,
			280
		},
		stats = {
			damage = 1,
			armor = 0,
			hp = 3
		},
		basic_attack = {
			armor = 0,
			max_speed = 90,
			duration = 15,
			regen_health = 1,
			range = {
				160,
				160,
				160,
				160
			},
			cooldown = {
				4,
				3.7,
				3.4,
				3.1
			},
			fps = {
				30,
				30,
				31,
				34
			},
			hp_max = {
				24,
				48,
				72,
				96
			},
			melee_attack = {
				range = 60,
				cooldown = {
					1,
					1,
					1,
					1
				},
				damage_max = {
					4,
					8,
					12,
					18
				},
				damage_min = {
					2,
					5,
					8,
					12
				}
			}
		},
		big_guy = {
			max_range = 160,
			regen_health = 1,
			max_speed = 20,
			armor = 0,
			duration = 45,
			price = {
				200,
				100,
				100
			},
			cooldown = {
				20,
				20,
				20
			},
			hp_max = {
				144,
				216,
				288
			},
			explosion_damage = {
				100,
				150,
				250
			},
			explosion_range = {
				60,
				60,
				60
			},
			explosion_damage_type = DAMAGE_EXPLOSION,
			melee_attack = {
				range = 40,
				cooldown = {
					1
				},
				damage_max = {
					29,
					42,
					55
				},
				damage_min = {
					19,
					28,
					37
				}
			}
		},
		master_exploders = {
			damage_every = 0.25,
			price = {
				150,
				150,
				150
			},
			explosion_damage_factor = {
				1.2,
				1.4,
				1.6
			},
			s_damage_increase = {
				0.2,
				0.4,
				0.6
			},
			burning_duration = {
				2.75,
				3.75,
				4.75
			},
			s_burning_duration = {
				3,
				4,
				5
			},
			burning_damage_min = {
				2,
				4,
				6
			},
			burning_damage_max = {
				4,
				6,
				10
			},
			s_total_burning_damage_min = {
				8,
				16,
				24
			},
			s_total_burning_damage_max = {
				16,
				24,
				40
			},
			damage_type = DAMAGE_TRUE
		},
		demon_explosion = {
			damage_min = {
				2,
				5,
				8,
				12
			},
			damage_max = {
				4,
				8,
				12,
				18
			},
			range = {
				40,
				40,
				40,
				40
			},
			damage_type = DAMAGE_EXPLOSION,
			stun_duration = {
				0.25,
				0.4,
				0.6,
				0.8
			}
		}
	},
	rocket_gunners = {
		max_soldiers = 2,
		price = {
			100,
			140,
			190,
			270
		},
		stats = {
			damage = 4,
			armor = 3,
			hp = 4
		},
		rally_range = {
			130,
			145,
			160,
			175
		},
		sting_missiles = {
			cooldown = {
				24,
				20,
				16
			}
		},
		soldier = {
			speed_flight = 250,
			dead_lifetime = 10,
			speed_ground = 75,
			armor = {
				0.1,
				0.15,
				0.2,
				0.25
			},
			hp = {
				30,
				60,
				90,
				120
			},
			regen_hp = {
				5,
				8,
				11,
				15
			},
			melee_attack = {
				cooldown = 2,
				range = 72,
				damage_max = {
					8,
					20,
					38,
					62
				},
				damage_min = {
					5,
					13,
					25,
					41
				}
			},
			ranged_attack = {
				cooldown = 2,
				max_range = {
					150,
					155,
					160,
					165
				},
				min_range = {
					0,
					0,
					0,
					0
				},
				damage_max = {
					8,
					20,
					38,
					62
				},
				damage_min = {
					5,
					13,
					25,
					41
				}
			},
			phosphoric = {
				damage_radius = 45,
				price = {
					200,
					150,
					150
				},
				armor_reduction = {
					0.01,
					0.02,
					0.03
				},
				damage_area_max = {
					16,
					28,
					40
				},
				damage_area_min = {
					14,
					24,
					35
				},
				damage_factor = {
					1,
					1,
					1
				}
			},
			sting_missiles = {
				price = {
					200,
					100,
					100
				},
				max_range = {
					250,
					300,
					350
				},
				min_range = {
					0,
					0,
					0
				},
				damage_type = DAMAGE_INSTAKILL,
				hp_max_target = {
					450,
					900,
					1350
				}
			}
		}
	},
	necromancer = {
		shared_min_cooldown = 2,
		spawn_delay_min = 4,
		spawn_delay_max = 4,
		price = {
			100,
			140,
			200,
			260
		},
		stats = {
			cooldown = 4,
			range = 7,
			damage = 4
		},
		basic_attack = {
			cooldown = 1.5,
			damage_min = {
				4,
				12,
				20,
				36
			},
			damage_max = {
				8,
				20,
				36,
				68
			},
			range = {
				160,
				170,
				185,
				200
			},
			damage_type = DAMAGE_MAGICAL
		},
		skill_debuff = {
			range = 200,
			min_targets = 2,
			radius = 125,
			mod_duration = {
				1,
				1,
				1
			},
			damage_factor = {
				1.5,
				2,
				2.5
			},
			s_damage_factor = {
				0.5,
				1,
				1.5
			},
			aura_duration = {
				10,
				10,
				10
			},
			price = {
				120,
				120,
				120
			},
			cooldown = {
				16,
				14,
				12
			}
		},
		skill_rider = {
			range = 180,
			min_targets = 2,
			radius = 75,
			speed = 150,
			duration = 5,
			price = {
				200,
				200,
				200
			},
			damage_min = {
				65,
				130,
				195
			},
			damage_max = {
				65,
				130,
				195
			},
			s_damage = {
				65,
				130,
				195
			},
			cooldown = {
				30,
				26,
				22
			},
			damage_type = DAMAGE_TRUE
		},
		curse = {
			max_golems = {
				1,
				2,
				3,
				4
			},
			duration = 3,
			max_units_total = 100,
			max_skeletons = {
				2,
				4,
				6,
				8
			}
		},
		skeleton = {
			dead_lifetime = 10,
			max_speed = 36,
			armor = {
				0,
				0,
				0,
				0
			},
			hp_max = {
				50,
				66,
				83,
				101
			},
			melee_attack = {
				range = 72,
				cooldown = {
					1,
					1,
					1,
					1
				},
				damage_max = {
					5,
					7,
					9,
					11
				},
				damage_min = {
					3,
					4,
					5,
					6
				}
			}
		},
		skeleton_golem = {
			dead_lifetime = 10,
			max_speed = 28,
			regen_hp = 10,
			regen_cooldown = 1,
			armor = {
				0,
				0.05,
				0.1,
				0.15
			},
			hp_max = {
				150,
				180,
				210,
				240
			},
			melee_attack = {
				range = 72,
				cooldown = {
					1,
					1,
					1,
					1
				},
				damage_max = {
					12,
					15,
					18,
					21
				},
				damage_min = {
					8,
					10,
					12,
					14
				}
			}
		}
	},
	ballista = {
		turn_speed = 15,
		stats = {
			cooldown = 2,
			range = 9,
			damage = 10
		},
		price = {
			90,
			130,
			180,
			260
		},
		basic_attack = {
			burst_count = 5,
			cooldown = 2.5,
			damage_min = {
				4,
				8,
				16,
				28
			},
			damage_max = {
				6,
				12,
				23,
				39
			},
			range = {
				160,
				175,
				190,
				210
			},
			damage_type = DAMAGE_PHYSICAL
		},
		skill_final_shot = {
			stun_time = {
				2,
				3,
				4
			},
			price = {
				250,
				100,
				100
			},
			cooldown = {
				4,
				4,
				4
			},
			damage_factor = {
				2,
				3,
				4
			},
			s_damage_factor = {
				1,
				2,
				3
			}
		},
		skill_bomb = {
			max_range = 250,
			min_range = 80,
			min_targets = 2,
			node_prediction = 40,
			damage_radius = 55,
			price = {
				200,
				200,
				200
			},
			cooldown = {
				24,
				18,
				12
			},
			damage_min = {
				82,
				123,
				164
			},
			damage_max = {
				124,
				186,
				248
			},
			duration = {
				6,
				7,
				8
			},
			damage_type = DAMAGE_PHYSICAL
		}
	},
	flamespitter = {
		turn_speed = 8,
		stats = {
			cooldown = 2,
			range = 6,
			damage = 8
		},
		price = {
			130,
			190,
			270,
			370
		},
		burning = {
			cycle_time = 0.25,
			duration = 3,
			damage = {
				1,
				2,
				3,
				4
			}
		},
		basic_attack = {
			duration = 0.5,
			cooldown = 3,
			cycle_time = 0.3,
			damage_min = {
				2,
				7,
				14,
				23
			},
			damage_max = {
				3,
				10,
				19,
				30
			},
			range = {
				180,
				180,
				180,
				180
			},
			damage_type = DAMAGE_TRUE
		},
		skill_bomb = {
			max_range = 300,
			min_targets = 3,
			node_prediction = 40,
			min_range = 100,
			damage_radius = 60,
			price = {
				150,
				150,
				150
			},
			cooldown = {
				20,
				20,
				20
			},
			damage_max = {
				80,
				160,
				280
			},
			damage_min = {
				80,
				160,
				280
			},
			s_damage = {
				80,
				160,
				280
			},
			damage_type = DAMAGE_EXPLOSION,
			burning = {
				damage = 4,
				duration = 5,
				s_damage = 16,
				cycle_time = 0.25
			}
		},
		skill_columns = {
			max_range = 150,
			min_targets = 2,
			radius_out = 60,
			min_range = 0,
			radius_in = 30,
			columns = {
				6,
				7,
				8
			},
			price = {
				200,
				200,
				200
			},
			cooldown = {
				25,
				25,
				25
			},
			stun = {
				1,
				2,
				3
			},
			damage_in_max = {
				70,
				180,
				300
			},
			damage_in_min = {
				70,
				180,
				300
			},
			s_damage_in = {
				70,
				180,
				300
			},
			damage_in_type = DAMAGE_DISINTEGRATE,
			damage_out_max = {
				42,
				108,
				180
			},
			damage_out_min = {
				42,
				108,
				180
			},
			s_damage_out = {
				42,
				108,
				180
			},
			damage_out_type = DAMAGE_PHYSICAL
		}
	},
	barrel = {
		rally_range = 145,
		stats = {
			cooldown = 3,
			range = 6,
			damage = 6
		},
		price = {
			120,
			180,
			260,
			360
		},
		basic_attack = {
			damage_radius = 60,
			cooldown = 2.5,
			damage_min = {
				7,
				18,
				35,
				60
			},
			damage_max = {
				11,
				28,
				53,
				90
			},
			range = {
				170,
				170,
				170,
				170
			},
			debuff = {
				damage_reduction = {
					0.14,
					0.26,
					0.38,
					0.5
				},
				speed_factor = {
					0.92,
					0.84,
					0.76,
					0.68
				},
				duration = {
					4,
					4,
					4,
					4
				}
			}
		},
		skill_warrior = {
			range = 240,
			min_targets = 1,
			price = {
				200,
				100,
				100
			},
			cooldown = {
				12,
				12,
				12
			},
			entity = {
				range = 72,
				cooldown = 1,
				speed = 75,
				duration = 10,
				regen_hp = 15,
				damage_min = {
					26,
					37,
					48
				},
				damage_max = {
					38,
					55,
					72
				},
				damage_type = DAMAGE_ELECTRICAL,
				hp_max = {
					150,
					200,
					250
				},
				armor = {
					0,
					0.1,
					0.2
				}
			}
		},
		skill_barrel = {
			radius = 80,
			min_targets = 3,
			duration = 4,
			price = {
				200,
				200,
				200
			},
			cooldown = {
				24,
				24,
				24
			},
			range = {
				180,
				180,
				180
			},
			explosion = {
				damage_radius = 60,
				damage_min = {
					80,
					176,
					288
				},
				damage_max = {
					120,
					264,
					432
				},
				damage_type = DAMAGE_EXPLOSION
			},
			poison = {
				damage_max = 2,
				damage_min = 2,
				every = 0.25,
				duration = 5,
				s_damage = 8
			},
			slow = {
				factor = 0.5,
				duration = 1
			}
		}
	},
	sand = {
		stats = {
			cooldown = 8,
			range = 6,
			damage = 2
		},
		price = {
			80,
			120,
			170,
			260
		},
		basic_attack = {
			cooldown = 0.8,
			bounce_range = 140,
			bounce_speed_mult = 1.25,
			bounce_damage_mult = 0.7,
			damage_min = {
				3,
				6,
				11,
				18
			},
			damage_max = {
				5,
				10,
				17,
				26
			},
			range = {
				145,
				155,
				170,
				190
			},
			damage_type = DAMAGE_PHYSICAL,
			max_bounces = {
				1,
				2,
				3,
				4
			}
		},
		skill_gold = {
			range_trigger = 150,
			gold_chance = 1,
			max_bounces = 4,
			range_effect = 190,
			bounce_damage_mult = 1.0,
			price = {
				250,
				250,
				250
			},
			cooldown = {
				8,
				8,
				8
			},
			damage_min = {
				56,
				118,
				184
			},
			damage_max = {
				56,
				118,
				184
			},
			s_damage = {
				56,
				118,
				184
			},
			damage_type = DAMAGE_PHYSICAL,
			gold_extra = {
				4,
				8,
				12
			}
		},
		skill_big_blade = {
			range = 200,
			min_targets = 2,
			slow_factor = 0.75,
			radius = 50,
			damage_every = 0.25,
			slow_duration = 0.5,
			price = {
				200,
				200,
				200
			},
			damage_min = {
				7,
				14,
				21
			},
			damage_max = {
				10,
				20,
				30
			},
			s_damage_min = {
				28,
				56,
				84
			},
			s_damage_max = {
				40,
				80,
				120
			},
			cooldown = {
				16,
				16,
				16
			},
			duration = {
				4,
				5,
				6
			},
			damage_type = DAMAGE_PHYSICAL
		}
	},
	ghost = {
		max_soldiers = 2,
		rally_range = 155,
		price = {
			90,
			150,
			220,
			300
		},
		stats = {
			damage = 2,
			armor = 7,
			hp = 5
		},
		soldier = {
			dead_lifetime = 8,
			speed = 75,
			armor = {
				0.2,
				0.3,
				0.45,
				0.65
			},
			hp = {
				30,
				60,
				100,
				150
			},
			regen_hp = {
				5,
				8,
				12,
				18
			},
			basic_attack = {
				range = 70,
				cooldown = 1,
				damage_min = {
					4,
					8,
					14,
					22
				},
				damage_max = {
					6,
					12,
					20,
					30
				},
				damage_type = DAMAGE_TRUE
			}
		},
		extra_damage = {
			duration = 8,
			cooldown_start = {
				5,
				4,
				3
			},
			price = {
				150,
				100,
				100
			},
			damage_factor = {
				1.5,
				1.75,
				2
			},
			s_damage = {
				0.5,
				0.75,
				1
			}
		},
		soul_attack = {
			max_targets = {
				3,
				6,
				9
			},
			slow_duration = {
				3,
				4,
				5
			},
			range = 120,
			slow_factor = {
				0.6,
				0.5,
				0.4
			},
			damage_factor = 0.5,
			damage_factor_duration = {
				3,
				4,
				5
			},
			price = {
				150,
				150,
				150
			},
			damage_type = DAMAGE_TRUE,
			damage_min = {
				60,
				120,
				180
			},
			damage_max = {
				60,
				120,
				180
			},
			s_damage = {
				60,
				120,
				180
			}
		}
	},
	ray = {
		shared_min_cooldown = 1,
		stats = {
			cooldown = 1,
			range = 6,
			damage = 10
		},
		price = {
			120,
			170,
			230,
			330
		},
		basic_attack = {
			cooldown = 1.5,
			damage_every = 0.25,
			extra_range_to_stay = 20,
			duration = 4,
			range = {
				150,
				160,
				170,
				180
			},
			damage_min = {
				40,
				90,
				160,
				265
			},
			damage_max = {
				40,
				90,
				160,
				265
			},
			damage_type = DAMAGE_MAGICAL,
			damage_per_second = {
				0.1,
				0.2,
				0.35,
				0.35
			},
			slow = {
				0.8,
				0.75,
				0.7,
				0.65
			}
		},
		skill_chain = {
			chain_delay = 0.1,
			s_max_enemies = {
				3,
				4,
				5
			},
			max_enemies = {
				4,
				5,
				6
			},
			chain_range = 100,
			price = {
				150,
				150,
				150
			},
			damage_mult = {
				0.25,
				0.55,
				0.9
			},
			damage_type = DAMAGE_MAGICAL
		},
		skill_sheep = {
			range = 200,
			price = {
				200
			},
			cooldown = {
				20
			},
			sheep = {
				speed = 28,
				armor = 0,
				clicks_to_destroy = 3,
				magic_armor = 0,
				hp_mult = 0.5
			}
		}
	},
	dark_elf = {
		rally_range = 145,
		stats = {
			cooldown = 2,
			range = 10,
			damage = 10
		},
		soldier = {
			dead_lifetime = 10,
			speed = 75,
			armor = {
				0.25,
				0.25,
				0.25
			},
			hp = {
				60,
				100,
				150
			},
			regen_hp = {
				6,
				9,
				12
			},
			basic_attack = {
				range = 70,
				cooldown = 1,
				damage_min = {
					12,
					16,
					22
				},
				damage_max = {
					16,
					24,
					34
				},
				damage_type = DAMAGE_PHYSICAL
			},
			dodge_chance = {
				0.6,
				0.6,
				0.6
			}
		},
		price = {
			90,
			130,
			180,
			240
		},
		basic_attack = {
			cooldown = 2,
			damage_min = {
				14,
				35,
				77,
				140
			},
			damage_max = {
				18,
				48,
				108,
				198
			},
			range = {
				200,
				230,
				260,
				300
			},
			damage_type = DAMAGE_PHYSICAL
		},
		skill_soldiers = {
			price = {
				150,
				150,
				150
			},
			cooldown = {
				1,
				1,
				1
			}
		},
		skill_buff = {
			max_fps = 60,
			max_armor_reduction = 15,
			price = {
				200,
				200
			},
			extra_damage_min = {
				2,
				2
			},
			extra_damage_max = {
				2,
				2
			},
			s_extra_damage_total = {
				2,
				2
			},
			fps_increment = {
				0,
				1
			},
			armor_reduction = {
				0,
				0.5
			}
		}
	},
	hermit_toad = {
		stats = {
			cooldown = 5,
			range = 7,
			damage = 5
		},
		price = {
			120,
			160,
			240,
			280
		},
		engineer_basic_attack = {
			damage_radius = 60,
			cooldown = 2.5,
			damage_min = {
				7,
				17,
				30,
				46
			},
			damage_max = {
				9,
				23,
				40,
				60
			},
			range = {
				180,
				200,
				220,
				240
			},
			slow_factor = {
				0.65,
				0.6,
				0.55,
				0.5
			},
			slow_decal_duration = {
				2,
				2,
				2,
				2
			},
			slow_mod_duration = {
				0.2,
				0.2,
				0.2,
				0.2
			},
			damage_type = DAMAGE_PHYSICAL
		},
		mage_basic_attack = {
			cooldown = 1.2,
			damage_min = {
				8,
				20,
				34,
				50
			},
			damage_max = {
				10,
				24,
				42,
				64
			},
			range = {
				160,
				175,
				190,
				205
			},
			damage_type = DAMAGE_MAGICAL
		},
		power_jump = {
			radius = 100,
			range = 220,
			min_targets = 2,
			price = {
				120,
				120,
				120
			},
			cooldown = {
				35,
				30,
				25
			},
			stun_duration = {
				2,
				3,
				4
			},
			damage_min = {
				80,
				140,
				180
			},
			damage_max = {
				80,
				140,
				180
			},
			damage_type = DAMAGE_PHYSICAL
		},
		power_instakill = {
			range = 240,
			price = {
				300
			},
			cooldown = {
				18
			}
		}
	},
	dwarf = {
		max_soldiers = 2,
		rally_range = 180,
		price = {
			60,
			130,
			180,
			240
		},
		stats = {
			damage = 3,
			armor = 3,
			hp = 5
		},
		soldier = {
			dead_lifetime = 8,
			speed = 75,
			armor = {
				0,
				0.1,
				0.2,
				0.3
			},
			hp = {
				35,
				70,
				105,
				140
			},
			regen_hp = {
				6,
				12,
				18,
				28
			},
			melee_attack = {
				cooldown = 1,
				range = 72,
				damage_max = {
					4,
					10,
					18,
					26
				},
				damage_min = {
					3,
					6,
					12,
					17
				}
			},
			ranged_attack = {
				cooldown = 1.5,
				max_range = {
					180,
					180,
					180,
					180
				},
				min_range = {
					70,
					70,
					70,
					70
				},
				damage_max = {
					6,
					14,
					26,
					38
				},
				damage_min = {
					4,
					10,
					18,
					26
				}
			}
		},
		formation = {
			price = {
				120,
				180,
				240
			}
		},
		incendiary_ammo = {
			damage_radius = 60,
			cooldown = 12,
			price = {
				150,
				150,
				150
			},
			damages_min = {
				20,
				38,
				52
			},
			damages_max = {
				28,
				58,
				80
			},
			damage_type = DAMAGE_EXPLOSION,
			burn = {
				damage_every = 0.25,
				duration = 2,
				s_damage = {
					24,
					64,
					112
				},
				damage = {
					3,
					8,
					14
				},
				damage_type = DAMAGE_TRUE,
				aura = {
					duration = 0.1,
					radius = 50,
					cycle_time = 0.1
				}
			}
		}
	},
	sparking_geode = {
		shared_min_cooldown = 1,
		price = {
			110,
			130,
			210,
			290
		},
		stats = {
			cooldown = 10,
			range = 5,
			damage = 1
		},
		basic_attack = {
			cooldown = 2,
			bounce_range = 140,
			targeting_style = 0,
			damage_min = {
				9,
				9,
				9,
				9
			},
			damage_max = {
				12,
				12,
				12,
				12
			},
			range = {
				160,
				160,
				160,
				160
			},
			ray_timing_min = {
				0.9,
				0.75,
				0.6,
				0.45
			},
			ray_timing_max = {
				1,
				0.85,
				0.7,
				0.55
			},
			damage_type = DAMAGE_TRUE,
			bounces_min = {
				1,
				2,
				3,
				4
			},
			bounces_max = {
				2,
				3,
				4,
				5
			},
			bounce_damage_factor = {
				1.05,
				1.1,
				1.15,
				1.2
			}
		},
		crystalize = {
			price = {
				150,
				100,
				100
			},
			cooldown = {
				30,
				25,
				20
			},
			max_targets = {
				3,
				5,
				7
			},
			duration = {
				5,
				6,
				7
			},
			received_damage_factor = {
				1.3,
				1.35,
				1.4
			},
			s_received_damage_factor = {
				0.3,
				0.35,
				0.4
			}
		},
		spike_burst = {
			damage_every = 0.5,
			radius = 200,
			price = {
				200,
				200,
				200
			},
			cooldown = {
				30,
				25,
				20
			},
			duration = {
				8,
				10,
				12
			},
			damage_min = {
				8,
				10,
				12
			},
			damage_max = {
				8,
				10,
				12
			},
			damage_type = DAMAGE_TRUE,
			speed_factor = {
				0.7,
				0.6,
				0.5
			}
		}
	},
	-- customization
	crossbow = {
		multishot = {
			cooldown = 5
		}
	},
	totem = {
		weakness = {
			cooldown = 10
		},
		silence = {
			cooldown = 8
		}
	},
	musketeer = {
		sniper = {
			cooldown = 14
		},
		shrapnel = {
			cooldown = 9
		}
	},
	archer_dwarf = {
		barrel = {
			cooldown = 10
		}
	},
	entwood = {
		fiery_nuts = {
			cooldown = 25.5
		},
		clobber = {
			cooldown = 14
		}
	},
	rock_thrower = {
		sylvan = {
			cooldown = {
				15,
				15,
				15
			}
		}
	},
	spirit_mausoleum = {
		spectral_communion = {
			cooldown = {
				30,
				15
			},
			hp = {
				150,
				200
			}
		},
		possession = {
			cooldown = {
				23,
				20,
				17
			},
			duration = {
				10,
				12,
				14
			}
		}
	},
	faerie_dragon = {
		improve_shot = {
			damage = {
				20,
				30
			}
		}
	},
	wild_magus = {
		eldritch = {
			cooldowns = {
				28,
				24,
				20
			}
		},
		ward = {
			cooldown = 10
		}
	},
	arcane_archer = {
		slumber = {
			cooldown = 24
		},
		burst = {
			cooldown = 12
		}
	},
	silver = {
		mark = {
			cooldown = 12
		}
	},
	high_elven = {
		timelapse = {
			cooldown = 16
		}
	},
	ignis_altar = {
		single_extinction = {
			cooldown = {
				18,
				18,
				18
			}
		}
	},
	bfg = {
		missile = {
			cooldown = 6.5
		},
		cluster = {
			cooldown = 17
		}
	},
	dwaarp = {
		lava = {
			cooldown = 15
		},
		drill = {
			cooldown = 26
		},
		batteries = {
			cooldown = 25
		}
	},
	mecha = {
		missile = {
			cooldown = 6
		},
		oil = {
			cooldown = 10
		}
	},
	sorcerer = {
		polymorph = {
			cooldown = 20
		}
	},
	archmage = {
		twister = {
			cooldown = 22
		}
	},
	deep_devils = {
		storm = {
			cooldowns = {
				10,
				10,
				10
			}
		}
	},
	random = {
		allowed_templates = {
			"tower_mage_1",-- 秘法师高台
			"tower_pirate_watchtower",-- 海盗瞭望塔
			"tower_pixie",-- 侏儒花园
			"tower_faerie_dragon",-- 仙女龙巢穴
			"tower_ewok",-- 阿渥克小屋
			"tower_stage_28_priests_barrack",-- 无明教会
			"tower_barrack_pirates",-- 海盗酒馆(雇佣海盗)
			"tower_barrack_pirates_w_flamer",-- 海盗酒馆(雇佣海盗水手)
			"tower_barrack_pirates_w_anchor",-- 海盗酒馆(雇佣水手长)
			"tower_barrack_mercenaries",-- 佣兵营地(雇佣巨灵)
			"tower_sunray",-- 日光之塔
			"tower_bastion",-- 刀片堡垒
			"tower_wild_magus",-- 狂野魔法师
		}
	}
}
local specials = {
	trees = {
		arborean_sages = {
			cooldown_min = 3,
			range = 175,
			damage_min = 10,
			cooldown_max = 3,
			damage_max = 20,
			damage_type = DAMAGE_MAGICAL
		},
		fruity_tree = {
			max_range = 150,
			cooldown_min = 4,
			cooldown_max = 6,
			consume_range = 25,
			heal = 100,
			duration = 5,
			max_fruits = 3
		},
		guardian_tree = {
			max_range = 450,
			cooldown_min = 16,
			sep_nodes_min = 4,
			immune_for_seconds = 3,
			effect_duration = 4,
			cooldown_max = 16,
			min_range = 15,
			roots_count = 14,
			show_delay_max = 0.04,
			show_delay_min = 0.04,
			disabled = false,
			sep_nodes_max = 5,
			wave_config = {
				true,
				true,
				true,
				true,
				true,
				true,
				true,
				true
			}
		},
		heart_of_the_arborean = {
			max_range = 1400,
			cooldown_min = 90,
			min_targets = 10,
			damage_radius = 80,
			min_dist_between_tgts = 130,
			cooldown_max = 90,
			damage_max = 40,
			damage_min = 30,
			max_targets = 10,
			damage_type = DAMAGE_TRUE,
			wait_between_shots = fts(2)
		},
		blocked_holders = {
			price = 60
		}
	},
	terrain_2 = {
		blocked_holders = {
			price = 100
		}
	},
	terrain_3 = {
		blocked_holders = {
			price = 150
		}
	},
	terrain_4 = {
		blocked_holders = {
			price = 150
		}
	},
	terrain_6 = {
		blocked_holders = {
			price = 150
		}
	},
	terrain_7 = {
		spider_floor_webs = {
			sprint_factor = 1.7,
			slow_factor = 0.3
		}
	},
	stage07_temple = {
		activation_wave = 10
	},
	stage08_elf_rescue = {
		spawn_cooldown = 90,
		elf = {
			cooldown_min = 1.2,
			range = 202,
			damage_min = 36,
			stun_duration = 24,
			cooldown_max = 1.6,
			damage_max = 54,
			damage_type = DAMAGE_PHYSICAL
		}
	},
	stage09_spawn_nightmares = {
		path_portal_off_delay = 10,
		wave_config = {
			{
				{},
				{},
				{
					{
						duration = 28,
						time_start = 10
					}
				},
				{
					{
						duration = 28,
						time_start = 10
					}
				},
				{},
				{},
				{
					{
						duration = 30,
						time_start = 10
					}
				},
				{},
				{
					{
						duration = 30,
						time_start = 10
					}
				},
				{},
				{
					{
						duration = 52,
						time_start = 10
					}
				},
				{
					{
						duration = 40,
						time_start = 10
					}
				},
				{},
				{
					{
						duration = 40,
						time_start = 12
					}
				},
				{
					{
						duration = 70,
						time_start = 10
					}
				}
			},
			{
				{},
				{},
				{},
				{
					{
						duration = 70,
						time_start = 20
					}
				},
				{},
				{
					{
						duration = 107,
						time_start = 21
					}
				}
			},
			{
				{
					{
						duration = 110,
						time_start = 74
					},
					{
						duration = 330,
						time_start = 310
					}
				}
			}
		}
	},
	stage10_obelisk = {
		mode_first_delay = 1,
		change_mode_every = 4,
		min_enemies = 2,
		start_delay = {
			20,
			0,
			30
		},
		per_wave_config_campaign = {
			{
				delay = 30,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 30,
				mode = "heal",
				duration = 12
			},
			{
				delay = 8,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 1,
				mode = "sacrifice"
			},
			{
				delay = 20,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 20,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 1,
				mode = "sacrifice"
			},
			{
				delay = 25,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 20,
				mode = "heal",
				duration = 12
			},
			{
				delay = 12,
				mode = "teleport",
				duration = 12
			},
			{
				delay = 10,
				mode = "sacrifice"
			}
		},
		per_wave_config_heroic = {
			{
				delay = 30,
				mode = "heal",
				duration = 10
			},
			{
				delay = 48,
				mode = "heal",
				duration = 10
			},
			{
				delay = 20,
				mode = "heal",
				duration = 10
			},
			{
				delay = 45,
				mode = "heal",
				duration = 10
			},
			{
				delay = 30,
				mode = "heal",
				duration = 10
			},
			{
				delay = 120,
				mode = "heal",
				duration = 10
			}
		},
		iron_config = {
			golem_activate_delay = {
				50,
				190,
				270,
				350,
				370
			}
		},
		stun = {
			cooldown = 26,
			stun_duration = 3,
			mode_duration = 90
		},
		heal = {
			heal_duration = 10,
			cooldown = 50,
			heal_min = 1,
			heal_every = 0.25,
			heal_max = 3,
			mode_duration = 55
		},
		teleport = {
			max_targets = 4,
			nodes_advance = 25,
			aura_radius = 100,
			nodes_limit = 30,
			cooldown = 5,
			nodes_from_selectable = 30,
			nodes_to_goal_selectable = 80,
			mode_duration = 75
		},
		sacrifice = {
			inactive_time = 20,
			waves = {
				5,
				10,
				15
			}
		}
	},
	stage10_ymca = {
		soldier = {
			armor = 0,
			hp = 100,
			max_speed = 90,
			melee_attack = {
				cooldown = 1,
				damage_min = 6,
				damage_max = 12
			}
		}
	},
	stage11_cult_leader = {
		deck_chain_ability = 1,
		ability_cooldown_bossfight = 30,
		ability_first_delay = 30,
		stun_time = 15,
		ability_cooldown = 90,
		deck_total_cards = 2,
		illusion = {
			max_speed = 20,
			hp_max = 1500,
			magic_armor = 0.3,
			armor = 0.3,
			spawn_charge_time = 5,
			nodes_limit = 20,
			melee_attack = {
				cooldown = 1,
				damage_min = 25,
				damage_max = 25
			},
			ranged_attack = {
				max_range = 150,
				damage_max = 36,
				damage_min = 24,
				cooldown = 1.5,
				min_range = 0,
				damage_type = DAMAGE_PHYSICAL
			},
			chain = {
				max_range = 160,
				duration = 12,
				cooldown = 1
			},
			shield = {
				duration = 12,
				radius = 80
			}
		},
		config_per_wave = {
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 1
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 2
			},
			{
				illusions = 3
			},
			{
				illusions = 3
			}
		}
	},
	stage11_portal = {
		waves_campaign = {
			3,
			4,
			5,
			6,
			7,
			8,
			9,
			10,
			12,
			13,
			14,
			15
		},
		waves_heroic = {
			2,
			3,
			4,
			5,
			6
		},
		waves_iron = {
			1
		}
	},
	stage11_veznan = {
		cooldown = 12,
		skill_soldiers = {
			soldier = {
				armor = 0.3,
				regen_health = 10,
				max_speed = 30,
				hp_max = 330,
				nodes_from_start = 20,
				melee_attack = {
					damage_min = 24,
					range = 50,
					damage_max = 40
				}
			}
		},
		skill_cage = {
			duration = 5
		}
	},
	stage14_amalgam = {
		sacrifices_to_show_2 = 2,
		sacrifices_to_show_1 = 1,
		sacrifices_to_spawn = 5
	},
	stage15_denas = {
		damage_max = 49,
		spawn_stun_radius = 50,
		hp_max = 600,
		cooldown = 30,
		regen_health = 15,
		spawn_stun_duration = 1,
		attack_cooldown = 2,
		damage_special_max = 500,
		attack_cooldown_special = 8,
		duration = 20,
		range = 72,
		magic_armor = 0.5,
		speed = 60,
		armor = 0.5,
		damage_min = 30,
		damage_special_min = 400,
		damage_type = DAMAGE_TRUE
	},
	stage15_cult_leader_tower = {
		aura_duration = 7.5,
		aura_time_before_stun = 5,
		aura_radius = 40,
		config_per_wave = {
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 40
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 25
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 1,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			},
			{
				tentacle_duration = 6,
				targets_amount = 2,
				tentacle_cd = 30
			}
		}
	},
	stage16_overseer = {
		hp = 30000,
		first_time_cooldown = 5,
		destroy_tower_cooldown = 10,
		disable_tower_recover_price = 100,
		phase_per_hp_threshold = {
			100,
			90,
			75,
			70,
			50,
			10
		},
		phase_per_time = {
			30,
			75,
			50,
			120,
			150
		},
		change_tower_cooldown = {
			nil,
			60,
			60,
			45,
			30
		},
		change_tower_amount = {
			nil,
			1,
			1,
			1,
			1
		},
		disable_tower_cooldown = {},
		destroy_holder = {
			cooldown = {
				nil,
				nil,
				nil,
				nil,
				nil,
				15
			}
		},
		tentacle_spawns_per_phase = {
			0,
			0,
			3,
			3,
			4,
			4
		},
		tentacle_left = {
			cooldown = {
				nil,
				nil,
				nil,
				30,
				20,
				10
			}
		},
		tentacle_right = {
			cooldown = {
				nil,
				nil,
				30,
				30,
				20,
				12
			}
		},
		tentacle_bullet_explosion_damage = {
			damage_max = 180,
			range = 70,
			damage_min = 120,
			damage_type = DAMAGE_PHYSICAL
		},
		glare1 = {
			{
				-1,
				0
			},
			{
				-1,
				0
			},
			{
				-1,
				0
			},
			{
				6,
				30
			},
			{
				6,
				20
			},
			{
				60,
				30
			}
		},
		glare2 = {
			{
				-1,
				0
			},
			{
				8,
				25
			},
			{
				6,
				30
			},
			{
				-1,
				0
			},
			{
				-1,
				0
			},
			{
				6,
				30
			}
		}
	},
	stage18_eridan = {
		ranged_attack = {
			range = 380,
			damage_min = 18,
			cooldown = 4,
			damage_max = 30,
			damage_type = DAMAGE_PHYSICAL
		},
		instakill = {
			hp_threshold = 700,
			range = 250,
			cooldown = 18,
			damage_type = DAMAGE_INSTAKILL
		}
	},
	stage19_mausoleum = {
		path_portal_off_delay = 10,
		wave_config = {
			{
				{},
				{},
				{},
				{
					{
						duration = 60,
						time_start = 2
					}
				},
				{},
				{
					{
						duration = 42,
						time_start = 2
					}
				},
				{},
				{
					{
						duration = 50,
						time_start = 2
					}
				},
				{
					{
						duration = 55,
						time_start = 2
					}
				},
				{},
				{
					{
						duration = 30,
						time_start = 2
					}
				},
				{},
				{},
				{
					{
						duration = 68,
						time_start = 2
					}
				},
				{
					{
						duration = 75,
						time_start = 2
					}
				}
			},
			{
				{},
				{
					{
						duration = 55,
						time_start = 2
					}
				},
				{
					{
						duration = 27,
						time_start = 2
					}
				},
				{
					{
						duration = 56,
						time_start = 2
					}
				},
				{},
				{
					{
						duration = 75,
						time_start = 2
					}
				}
			},
			{
				{
					{
						duration = 325,
						time_start = 2
					}
				}
			}
		}
	},
	stage20_arborean_house = {
		armor = 0.3,
		magic_armor = 0,
		hp_max = 280
	},
	stage21_falling_rocks = {
		damage_radius = 60,
		damage = 2000,
		damage_type = DAMAGE_PHYSICAL
	},
	stage22_remolino = {
		{
			[3] = {
				{
					28,
					41
				}
			},
			[4] = {
				{
					35,
					48
				},
				{
					67,
					80
				}
			},
			[6] = {
				{
					12,
					25
				},
				{
					32,
					45
				}
			},
			[7] = {
				{
					25,
					95
				}
			},
			[9] = {
				{
					15,
					24
				},
				{
					75,
					84
				}
			},
			[10] = {
				{
					5,
					52
				}
			},
			[12] = {
				{
					12,
					21
				},
				{
					42,
					51
				}
			},
			[13] = {
				{
					5,
					48
				}
			},
			[14] = {
				{
					5,
					20
				},
				{
					70,
					85
				}
			},
			[15] = {
				{
					8,
					18
				},
				{
					48,
					58
				}
			},
			BOSS = {
				{
					31,
					480
				}
			}
		},
		{
			[2] = {
				{
					19.5,
					27.5
				},
				{
					43,
					51.5
				}
			},
			[3] = {
				{
					0.2,
					4
				}
			},
			[4] = {
				{
					27,
					90
				}
			},
			[5] = {
				{
					14,
					24
				}
			},
			[6] = {
				{
					0,
					5
				},
				{
					25,
					63
				}
			}
		},
		{
			{
				{
					115,
					319
				}
			}
		}
	},
	stage22_tower_destroyed = {
		repair_cost = 220
	},
	stage23_roboboots = {
		wave_config = {
			{
				{},
				{
					{
						leg = 2,
						timings = {
							{
								0
							}
						}
					}
				},
				{
					{
						leg = 2,
						timings = {
							{
								nil,
								1
							}
						}
					}
				},
				{},
				{
					{
						leg = 1,
						timings = {
							{
								10
							}
						}
					}
				},
				{
					{
						leg = 1,
						timings = {
							{
								nil,
								7
							}
						}
					},
					{
						leg = 2,
						timings = {
							{
								17
							}
						}
					}
				},
				{
					{
						leg = 2,
						timings = {
							{
								nil,
								8
							}
						}
					}
				},
				{},
				{
					{
						leg = 1,
						timings = {
							{
								1
							}
						}
					}
				},
				{
					{
						leg = 1,
						timings = {
							{
								nil,
								8
							}
						}
					},
					{
						leg = 2,
						timings = {
							{
								1
							}
						}
					}
				},
				{
					{
						leg = 1,
						timings = {
							{
								5,
								25
							}
						}
					},
					{
						leg = 2,
						timings = {
							{
								nil,
								10
							}
						}
					}
				},
				{},
				{
					{
						leg = 2,
						timings = {
							{
								1
							}
						}
					}
				},
				{
					{
						leg = 2,
						timings = {
							{
								nil,
								5
							}
						}
					}
				},
				{
					{
						leg = 1,
						timings = {
							{
								10,
								76
							}
						}
					},
					{
						leg = 2,
						timings = {
							{
								1,
								72
							}
						}
					}
				}
			},
			{
				{},
				{},
				{
					{
						leg = 1,
						timings = {
							{
								1
							}
						}
					}
				},
				{
					{
						leg = 1,
						timings = {
							{
								nil,
								6
							}
						}
					},
					{
						leg = 2,
						timings = {
							{
								1
							}
						}
					}
				},
				{
					{
						leg = 2,
						timings = {
							{
								nil,
								6
							}
						}
					}
				},
				{
					{
						leg = 1,
						timings = {
							{
								20,
								46
							}
						}
					},
					{
						leg = 2,
						timings = {
							{
								13,
								72
							}
						}
					}
				}
			},
			{
				{
					{
						leg = 1,
						timings = {
							{
								2,
								45
							},
							{
								114,
								163
							},
							{
								200,
								230
							},
							{
								295,
								340
							},
							{
								345,
								370
							}
						}
					},
					{
						leg = 2,
						timings = {
							{
								170,
								205
							},
							{
								280,
								345
							}
						}
					}
				}
			}
		}
	},
	stage24_factory = {
		wave_config = {
			{
				{},
				{},
				{},
				{},
				{},
				{},
				{
					{
						duration = 40,
						time_start = 10
					}
				},
				{},
				{
					{
						duration = 40,
						time_start = 10
					}
				},
				{},
				{
					{
						duration = 40,
						time_start = 8
					}
				},
				{},
				{
					{
						duration = 40,
						time_start = 12
					}
				},
				{},
				{
					{
						duration = 40,
						time_start = 15
					}
				}
			},
			{
				{},
				{},
				{},
				{},
				{},
				{}
			},
			{
				{}
			}
		}
	},
	stage24_upgrade_station = {
		wave_config = {
			{
				{},
				{},
				{},
				{},
				{
					{
						duration = 60,
						time_start = 1
					}
				},
				{},
				{},
				{
					{
						duration = 60,
						time_start = 10
					}
				},
				{},
				{},
				{},
				{
					{
						duration = 50,
						time_start = 1
					}
				},
				{},
				{
					{
						duration = 45,
						time_start = 1
					}
				},
				{}
			},
			{
				{},
				{
					{
						duration = 55,
						time_start = 2
					}
				},
				{},
				{},
				{
					{
						duration = 56,
						time_start = 2
					}
				},
				{}
			},
			{
				{
					{
						duration = 560,
						time_start = 2
					}
				}
			}
		}
	},
	stage25_torso = {
		fist = {
			radius = 140
		},
		missile = {
			repair_cost = 50,
			max_duration = 30
		},
		wave_config = {
			{
				{},
				{},
				{},
				{},
				{},
				{},
				{},
				{
					{
						action = "open",
						time_start = 8
					},
					{
						action = "fist",
						time_start = 13
					},
					{
						action = "close",
						time_start = 23
					}
				},
				{
					{
						action = "open",
						time_start = 13
					},
					{
						action = "missile",
						time_start = 18
					},
					{
						action = "close",
						time_start = 28
					}
				},
				{},
				{
					{
						action = "open",
						time_start = 2
					},
					{
						action = "fist",
						time_start = 8
					},
					{
						action = "fist",
						time_start = 16
					}
				},
				{
					{
						action = "missile",
						time_start = 12
					},
					{
						action = "missile",
						time_start = 22
					}
				},
				{
					{
						action = "fist",
						time_start = 10
					},
					{
						action = "fist",
						time_start = 26
					}
				},
				{
					{
						action = "missile",
						time_start = 2
					},
					{
						action = "missile",
						time_start = 9
					},
					{
						action = "missile",
						time_start = 17
					}
				},
				{
					{
						action = "missile",
						time_start = 11
					},
					{
						action = "missile",
						time_start = 23
					},
					{
						action = "missile",
						time_start = 33
					},
					{
						action = "missile",
						time_start = 47
					},
					{
						action = "missile",
						time_start = 57
					},
					{
						action = "missile",
						time_start = 67
					},
					{
						action = "missile",
						time_start = 77
					},
					{
						action = "missile",
						time_start = 87
					},
					{
						action = "missile",
						time_start = 97
					}
				}
			},
			{
				{
					{
						action = "open",
						time_start = 2
					},
					{
						action = "fist",
						time_start = 17
					},
					{
						action = "fist",
						time_start = 27
					}
				},
				{
					{
						action = "missile",
						time_start = 12
					},
					{
						action = "missile",
						time_start = 22
					},
					{
						action = "missile",
						time_start = 32
					}
				},
				{
					{
						action = "missile",
						time_start = 8
					},
					{
						action = "missile",
						time_start = 26
					},
					{
						action = "missile",
						time_start = 38
					}
				},
				{
					{
						action = "fist",
						time_start = 12
					},
					{
						action = "fist",
						time_start = 28
					}
				},
				{
					{
						action = "fist",
						time_start = 17
					},
					{
						action = "fist",
						time_start = 26
					}
				},
				{
					{
						action = "fist",
						time_start = 17
					},
					{
						action = "missile",
						time_start = 24
					},
					{
						action = "missile",
						time_start = 34
					},
					{
						action = "fist",
						time_start = 46
					},
					{
						action = "missile",
						time_start = 59
					},
					{
						action = "missile",
						time_start = 72
					},
					{
						action = "missile",
						time_start = 83
					},
					{
						action = "missile",
						time_start = 94
					},
					{
						action = "missile",
						time_start = 106
					},
					{
						action = "missile",
						time_start = 120
					}
				}
			},
			{
				{
					{
						action = "open",
						time_start = 12
					},
					{
						action = "missile",
						time_start = 24
					},
					{
						action = "missile",
						time_start = 48
					},
					{
						action = "fist",
						time_start = 66
					},
					{
						action = "missile",
						time_start = 84
					},
					{
						action = "missile",
						time_start = 104
					},
					{
						action = "missile",
						time_start = 132
					},
					{
						action = "missile",
						time_start = 145
					},
					{
						action = "fist",
						time_start = 160
					},
					{
						action = "fist",
						time_start = 180
					},
					{
						action = "missile",
						time_start = 230
					},
					{
						action = "missile",
						time_start = 260
					},
					{
						action = "missile",
						time_start = 272
					},
					{
						action = "missile",
						time_start = 300
					},
					{
						action = "fist",
						time_start = 312
					},
					{
						action = "missile",
						time_start = 325
					},
					{
						action = "missile",
						time_start = 347
					},
					{
						action = "fist",
						time_start = 360
					},
					{
						action = "missile",
						time_start = 372
					},
					{
						action = "missile",
						time_start = 383
					},
					{
						action = "missile",
						time_start = 405
					},
					{
						action = "missile",
						time_start = 416
					},
					{
						action = "fist",
						time_start = 430
					},
					{
						action = "missile",
						time_start = 442
					},
					{
						action = "missile",
						time_start = 455
					},
					{
						action = "missile",
						time_start = 472
					},
					{
						action = "missile",
						time_start = 483
					},
					{
						action = "missile",
						time_start = 505
					},
					{
						action = "missile",
						time_start = 516
					},
					{
						action = "missile",
						time_start = 527
					}
				}
			}
		}
	},
	stage26_spawners = {
		wave_config = {
			{
				{},
				{},
				{
					{
						action = "open",
						time_start = 8,
						spawner = "fist",
						count = 2
					},
					{
						action = "close",
						time_start = 17,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 18,
						spawner = "fist",
						count = 2
					},
					{
						action = "close",
						time_start = 27,
						spawner = "fist"
					}
				},
				{},
				{
					{
						action = "open",
						time_start = 1,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 6,
						spawner = "fist",
						count = 2
					},
					{
						action = "close",
						time_start = 11,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 16,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 18,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 38,
						spawner = "clone_left"
					}
				},
				{
					{
						action = "activate",
						time_start = 1,
						spawner = "hulk"
					},
					{
						action = "open",
						time_start = 4,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 25,
						spawner = "fist"
					}
				},
				{
					{
						action = "open",
						time_start = 1,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 9,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 10,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 19,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 23,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 32,
						spawner = "clone_right"
					}
				},
				{
					{
						action = "open",
						time_start = 1,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 4,
						spawner = "fist",
						count = 2
					},
					{
						action = "close",
						time_start = 13,
						spawner = "fist"
					},
					{
						action = "close",
						time_start = 11,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 12,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 14,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 24,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 26,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 30,
						spawner = "fist"
					},
					{
						action = "close",
						time_start = 36,
						spawner = "clone_left"
					}
				},
				{
					{
						action = "activate",
						time_start = 1,
						spawner = "hulk"
					}
				},
				{
					{
						action = "activate",
						time_start = 1,
						spawner = "hulk"
					}
				},
				{
					{
						action = "open",
						time_start = 2,
						spawner = "fist",
						count = 4
					},
					{
						action = "open",
						time_start = 9,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 18,
						spawner = "fist"
					},
					{
						action = "close",
						time_start = 19,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 31,
						spawner = "fist",
						count = 4
					},
					{
						action = "open",
						time_start = 38,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 47,
						spawner = "fist"
					},
					{
						action = "close",
						time_start = 48,
						spawner = "clone_right"
					}
				},
				{
					{
						action = "open",
						time_start = 1,
						spawner = "fist",
						count = 2
					},
					{
						action = "open",
						time_start = 4,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 10,
						spawner = "fist"
					},
					{
						action = "close",
						time_start = 15,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 16,
						spawner = "fist",
						count = 2
					},
					{
						action = "open",
						time_start = 20,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 26,
						spawner = "fist"
					},
					{
						action = "close",
						time_start = 31,
						spawner = "clone_left"
					}
				},
				{
					{
						action = "activate",
						time_start = 1,
						spawner = "hulk"
					},
					{
						action = "open",
						time_start = 3,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 14,
						spawner = "clone_right"
					},
					{
						action = "activate",
						time_start = 20,
						spawner = "hulk"
					},
					{
						action = "open",
						time_start = 26,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 38,
						spawner = "clone_right"
					}
				},
				{
					{
						action = "open",
						time_start = 1,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 3,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 5,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 13,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 14,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 15,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 17,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 20.5,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 20.5,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 28,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 30,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 37,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 38,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 40,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 48,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 50,
						spawner = "clone_right"
					}
				},
				{
					{
						action = "open",
						time_start = 1,
						spawner = "fist",
						count = 4
					},
					{
						action = "activate",
						time_start = 3,
						spawner = "hulk"
					},
					{
						action = "close",
						time_start = 16,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 23,
						spawner = "fist",
						count = 4
					},
					{
						action = "activate",
						time_start = 27,
						spawner = "hulk"
					},
					{
						action = "close",
						time_start = 38,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 48,
						spawner = "fist",
						count = 4
					},
					{
						action = "activate",
						time_start = 52,
						spawner = "hulk"
					},
					{
						action = "close",
						time_start = 63,
						spawner = "fist"
					}
				}
			},
			{
				{},
				{
					{
						action = "open",
						time_start = 0,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 16,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 34,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 50,
						spawner = "fist"
					}
				},
				{
					{
						action = "activate",
						time_start = 0,
						spawner = "hulk"
					},
					{
						action = "open",
						time_start = 4,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 15,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 33,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 43,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 53,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 63,
						spawner = "clone_right"
					}
				},
				{
					{
						action = "activate",
						time_start = 0,
						spawner = "hulk"
					}
				},
				{
					{
						action = "open",
						time_start = 0,
						spawner = "fist",
						count = 4
					},
					{
						action = "open",
						time_start = 7,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 16,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 21,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 23,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 28,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 37,
						spawner = "fist"
					},
					{
						action = "close",
						time_start = 42,
						spawner = "clone_left"
					}
				},
				{
					{
						action = "open",
						time_start = 0,
						spawner = "fist",
						count = 4
					},
					{
						action = "activate",
						time_start = 10,
						spawner = "hulk"
					},
					{
						action = "close",
						time_start = 16,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 34,
						spawner = "clone_left"
					},
					{
						action = "activate",
						time_start = 56,
						spawner = "hulk"
					},
					{
						action = "close",
						time_start = 62,
						spawner = "clone_left"
					},
					{
						action = "activate",
						time_start = 74,
						spawner = "hulk"
					},
					{
						action = "open",
						time_start = 76,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 92,
						spawner = "fist"
					}
				}
			},
			{
				{
					{
						action = "open",
						time_start = 1,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 9,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 15,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 24,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 54,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 64,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 79,
						spawner = "fist",
						count = 6
					},
					{
						action = "close",
						time_start = 105,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 108,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 124,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 138,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 141,
						spawner = "fist",
						count = 3
					},
					{
						action = "close",
						time_start = 147,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 150,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 154,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 155,
						spawner = "fist",
						count = 7
					},
					{
						action = "close",
						time_start = 159,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 169,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 184,
						spawner = "fist"
					},
					{
						action = "close",
						time_start = 191,
						spawner = "clone_right"
					},
					{
						action = "activate",
						time_start = 256,
						spawner = "hulk"
					},
					{
						action = "open",
						time_start = 260,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 275,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 290,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 291,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 301,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 305,
						spawner = "fist"
					},
					{
						action = "open",
						time_start = 321,
						spawner = "clone_right"
					},
					{
						action = "close",
						time_start = 331,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 338,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 348,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 366,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 376,
						spawner = "clone_left"
					},
					{
						action = "open",
						time_start = 393,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 396,
						spawner = "clone_left"
					},
					{
						action = "activate",
						time_start = 415,
						spawner = "hulk"
					},
					{
						action = "close",
						time_start = 426,
						spawner = "clone_right"
					},
					{
						action = "open",
						time_start = 427,
						spawner = "fist",
						count = 4
					},
					{
						action = "close",
						time_start = 428,
						spawner = "clone_left"
					},
					{
						action = "close",
						time_start = 441,
						spawner = "fist"
					},
					{
						action = "activate",
						time_start = 460,
						spawner = "hulk"
					},
					{
						action = "open",
						time_start = 465,
						spawner = "fist",
						count = 8
					},
					{
						action = "close",
						time_start = 502,
						spawner = "fist"
					}
				}
			}
		}
	},
	stage27_head = {
		ray_stun_duration = 15,
		taps_to_cancel = 20,
		attack_duration = 6,
		towers_to_stun = 13,
		charge_time = 3,
		scrap_attack = {
			damage_radius = 50,
			damage_max = 72,
			damage_min = 48,
			damage_type = DAMAGE_EXPLOSION
		},
		tower_stun_repair_cost = {
			50,
			75,
			100,
			125,
			150,
			175,
			200,
			225,
			250,
			275
		}
	},
	stage29_holder_block = {
		time_to_up = 2,
		time_to_down = 3,
		time_netting = 5,
		taps_to_cancel = 3,
		waves = {
			{
				5,
				6,
				7,
				9,
				10,
				11,
				12,
				13,
				14,
				15
			},
			{
				2,
				3,
				4,
				5,
				6
			},
			{
				1
			}
		},
		first_cooldown = {
			{
				5,
				40,
				5,
				45,
				1,
				22,
				1,
				1,
				1,
				1
			},
			{
				1,
				35,
				5,
				25,
				40
			},
			{
				30
			}
		},
		cooldown = {
			{
				35,
				20,
				0,
				0,
				30,
				30,
				40,
				30,
				30,
				25
			},
			{
				0,
				0,
				42,
				0,
				20
			},
			{
				50
			}
		},
		max_casts = {
			{
				2,
				2,
				1,
				1,
				3,
				2,
				2,
				3,
				3,
				4
			},
			{
				1,
				1,
				2,
				1,
				2
			},
			{
				50
			}
		},
		blocked_holders = {
			price = {
				65,
				65,
				30
			}
		},
		game_start_blocked_holders = {
			{},
			{},
			{
				"1",
				"2",
				"3",
				"4",
				"5",
				"6",
				"7",
				"8",
				"9",
				"10",
				"11",
				"12",
				"13",
				"14",
				"15"
			}
		}
	},
	stage30_door = {
		{
			[5] = {
				{
					32,
					42
				},
				{
					58,
					68
				}
			},
			[9] = {
				{
					21,
					31
				},
				{
					48,
					58
				}
			},
			[11] = {
				{
					10,
					25
				},
				{
					43,
					58
				}
			},
			[13] = {
				{
					1,
					10
				},
				{
					18,
					28
				},
				{
					41,
					55
				}
			},
			[15] = {
				{
					1,
					10
				},
				{
					18,
					28
				},
				{
					52,
					62
				}
			}
		},
		{
			{
				{
					44,
					52
				}
			},
			{
				{
					57,
					67
				}
			},
			{
				{
					0.2,
					10
				},
				{
					44,
					60
				}
			},
			{
				{
					46,
					60
				}
			},
			{
				{
					0.5,
					19
				}
			},
			{
				{
					24,
					34
				},
				{
					70,
					80
				}
			}
		},
		{
			{
				{
					155,
					180
				},
				{
					220,
					250
				}
			}
		}
	},
	towers = {
		arborean_sentinels = {
			spearmen = {
				armor = 0.1,
				regen_health = 8,
				max_speed = 75,
				hp_max = 100,
				price = 50,
				dead_lifetime = 10,
				melee_attack = {
					cooldown = 1.2,
					range = 60,
					damage_min = 12,
					damage_max = 18
				},
				ranged_attack = {
					max_range = 165,
					min_range = 0,
					damage_min = 15,
					cooldown = 1.5,
					damage_max = 21,
					damage_type = DAMAGE_PHYSICAL
				}
			},
			barkshield = {
				max_speed = 50,
				regen_health = 30,
				armor = 0.5,
				hp_max = 300,
				price = 90,
				dead_lifetime = 15,
				melee_attack = {
					cooldown = 3,
					range = 70,
					damage_min = 25,
					damage_max = 50
				}
			}
		},
		stage_13_sunray = {
			price = 250,
			attacks_before_special_min_iron = 6,
			attacks_before_special_max = 12,
			attacks_before_special_max_iron = 10,
			attacks_before_special_min = 8,
			repair_cost = {
				200,
				150,
				100,
				50
			},
			repair_cost_iron = {
				200,
				150,
				100,
				50
			},
			basic_attack = {
				range = 250,
				damage_min = 140,
				cooldown = 2,
				damage_max = 260,
				damage_every = fts(2),
				duration = fts(40),
				damage_type = DAMAGE_TRUE
			},
			special_attack = {
				radius = 60,
				range = 350,
				cooldown = 2,
				damage_max = 780,
				speed = 20,
				damage_min = 560,
				damage_every = fts(2),
				duration = fts(60),
				damage_type = DAMAGE_DISINTEGRATE
			}
		},
		stage_17_weirdwood = {
			corruption_limit = 3,
			holder_cost = 150,
			basic_attack = {
				max_range = 190,
				min_range = 40,
				damage_min = 28,
				damage_radius = 55,
				cooldown = 5,
				damage_max = 50
			},
			corruption_phases = {
				1,
				2,
				3
			}
		},
		stage_18_elven_barrack = {
			corruption_limit = 3,
			max_soldiers = 3,
			rally_range = 160,
			spawn_cooldown = 5,
			soldier = {
				speed = 75,
				armor = 0.5,
				hp = 120,
				dead_lifetime = 10,
				regen_hp = 10,
				price = {
					50,
					75,
					100
				},
				basic_attack = {
					cooldown = 1,
					range = 75,
					damage_max = 24,
					damage_min = 16
				}
			},
			corruption_phases = {
				1,
				2,
				3
			}
		},
		stage_20_arborean_oldtree = {
			max_range = 50,
			path_index_iron = 3,
			node_index_iron = 105,
			cooldown = 90,
			price_iron = 100,
			path_index = 2,
			damage_max = 450,
			damage_min = 350,
			node_index = 170,
			price = 100,
			damage_type = DAMAGE_PHYSICAL
		},
		stage_20_arborean_honey = {
			max_range = 180,
			aura_duration = 5,
			price_heroic = 250,
			slow_factor = 0.5,
			cooldown = 2.5,
			damage_radius = 50,
			damage_max = 60,
			damage_min = 40,
			slow_mod_duration = 0.5,
			price = 250,
			damage_type = DAMAGE_PHYSICAL,
			soldiers_price = 25,
			cooldown_disable = 2,
			spawn_cooldown_min = 0.3,
			spawn_cooldown_max = 0.6,
			spawns = 5
		},
		tower_stage_20_arborean_barrack = {
			soldier_hp_max = 120,
			spawn_cooldown_max = 0.6,
			hp_max = 500,
			spawn_cooldown_min = 0.3,
			cooldown_disable = 2,
			magic_armor = 0,
			price = 25,
			armor = 0.3,
			soldier_damage_max = 8,
			soldier_damage_min = 4,
			spawns = 5,
			soldier_armor = 0.1,
			life_thresholds = {
				0.7,
				0.4,
				0
			}
		},
		stage_20_arborean_watchtower = {
			tunnel_check_cooldown = 3,
			basic_attack = {
				max_range = 260,
				damage_min = 19,
				cooldown = 2.4,
				damage_max = 28,
				damage_type = DAMAGE_PHYSICAL
			},
			picked_enemies_to_destroy = {
				2,
				4,
				6
			}
		},
		stage_22_arborean_mages_tower = {
			armor = 0.3,
			magic_armor = 0,
			hp_max = 500,
			basic_attack = {
				max_range = 260,
				damage_min = 38,
				cooldown = 2.5,
				damage_max = 52,
				damage_type = DAMAGE_MAGICAL
			}
		},
		tower_stage_28_priests_barrack = {
			cooldown_disable = 2,
			max_soldiers = 0,
			spawn_cooldown_max = 0.6,
			spawn_cooldown_min = 0.3,
			price = 60,
			priest = {
				regen_health = 0,
				armor = 0,
				max_speed = 45,
				hp_max = 110,
				price = {
					160,
					160,
					160
				},
				transform_chances = {
					50,
					50
				},
				melee = {
					cooldown = 1,
					damage_min = 10,
					damage_max = 15,
					damage_type = DAMAGE_MAGICAL
				},
				ranged = {
					range = 180,
					damage_min = 30,
					cooldown = 2.5,
					damage_max = 45,
					damage_type = DAMAGE_MAGICAL
				}
			},
			abomination = {
				armor = 0,
				max_speed = 25,
				regen_health = 0,
				hp_max = 500,
				duration = 20,
				melee_attack = {
					cooldown = 2,
					damage_min = 45,
					damage_max = 60
				},
				eat = {
					cooldown = 10,
					hp_required = 0.3
				}
			},
			tentacle = {
				duration = 15,
				area_attack = {
					radius = 60,
					cooldown_min = 1,
					damage_min = 12,
					cooldown_max = 1,
					damage_max = 20,
					damage_type = DAMAGE_PHYSICAL
				}
			}
		}
	}
}
local reinforcements = {
	soldier = {
		armor = 0,
		regen_health = 8,
		max_speed = 64,
		hp_max = 40,
		cooldown = 15,
		duration = 12,
		melee_attack = {
			cooldown = 1,
			range = 72,
			damage_min = 1,
			damage_max = 2
		}
	}
}
local upgrades = {
	towers_war_rations = {
		hp_factor = 1.1
	},
	towers_wise_investment = {
		refund_factor = 0.9
	},
	towers_scoping_mechanism = {
		range_factor = 1.1,
		rally_range_factor = 1.1
	},
	towers_golden_time = {
		early_wave_reward_per_second_factor = 1.8
	},
	towers_improved_formulas = {
		range_factor = 1.25
	},
	towers_royal_training = {
		reduce_cooldown = 2,
		reinforcements_cooldown = 3
	},
	towers_favorite_customer = {
		refund_cost_factor_one_level = 0.2,
		refund_cost_factor = 0.5
	},
	towers_keen_accuracy = {
		cooldown_mult = 0.8
	},
	heroes_desperate_effort = {
		armor_penetration = 0.2
	},
	heroes_lone_wolves = {
		distance_to_trigger = 150,
		duration = 3,
		xp_gain_factor = 1.5
	},
	heroes_visual_learning = {
		distance_to_trigger = 200,
		duration = 3,
		armor_bonus = 0.1
	},
	heroes_unlimited_vigor = {
		cooldown_factor = 0.9
	},
	heroes_lethal_focus = {
		damage_factor_area = 1.5,
		damage_factor = 2,
		deck_data = {
			total_cards = 5,
			trigger_cards = 1
		}
	},
	heroes_nimble_physique = {
		deck_data = {
			total_cards = 5,
			trigger_cards = 1
		}
	},
	heroes_limit_pushing = {
		deck_data = {
			total_cards = 5,
			trigger_cards = 1
		}
	},
	reinforcements_master_blacksmiths = {
		damage_factor = 1.1,
		armor = 0.2
	},
	reinforcements_intense_workout = {
		duration_extra = 3,
		hp_factor = 1.25
	},
	reinforcements_rebel_militia = {
		soldier = {
			armor = 0.4,
			regen_health = 14,
			max_speed = 64,
			hp_max = 120,
			cooldown = 15,
			duration = 16,
			melee_attack = {
				cooldown = 1,
				range = 70,
				damage_min = 4,
				damage_max = 8
			}
		}
	},
	reinforcements_shadow_archer = {
		soldier = {
			armor = 0.2,
			regen_health = 10,
			max_speed = 64,
			hp_max = 60,
			cooldown = 15,
			duration = 14,
			melee_attack = {
				cooldown = 1,
				range = 50,
				damage_min = 10,
				damage_max = 14
			},
			ranged_attack = {
				max_range = 160,
				damage_max = 21,
				damage_min = 15,
				cooldown = 1.5,
				min_range = 50
			}
		}
	},
	reinforcements_thorny_armor = {
		spiked_armor = 0.2
	},
	reinforcements_night_veil = {
		cooldown_red = 0.5,
		extra_range = 50
	},
	reinforcements_special_linirea = {
		soldier = {
			armor = 0.6,
			regen_health = 24,
			spiked_armor = 0.2,
			hp_max = 180,
			cooldown = 15,
			duration = 16,
			max_speed = 64,
			melee_attack = {
				cooldown = 1,
				range = 72,
				damage_min = 10,
				damage_max = 14
			}
		}
	},
	reinforcements_special_dark_army = {
		soldier = {
			armor = 0.1,
			regen_health = 12,
			max_speed = 60,
			hp_max = 60,
			cooldown = 15,
			duration = 14,
			melee_attack = {
				cooldown = 1,
				range = 50,
				damage_min = 8,
				damage_max = 12
			}
		},
		crow = {
			chase_range = 300,
			max_speed = 100,
			target_range = 200,
			melee_attack = {
				range = 10,
				damage_min = 4,
				cooldown = 0.25,
				damage_max = 6,
				damage_type = DAMAGE_PHYSICAL
			}
		}
	},
	alliance_merciless = {
		damage_factor_per_tower = 0.03
	},
	alliance_corageous_stand = {
		hp_factor_per_tower = 0.04
	},
	alliance_shady_company = {
		damage_extra = 0.05
	},
	alliance_friends_of_the_crown = {
		cost_red_per_hero = 8
	},
	alliance_shared_reserves = {
		extra_gold = 100
	},
	alliance_seal_of_punishment = {
		duration = 4,
		radius = 50,
		damage_min = 10,
		cooldown = 180,
		cycle_time = 0.25,
		damage_max = 20
	},
	alliance_flux_altering_coils = {
		cooldown = 150,
		radius = 100,
		nodes_teleport = 25,
		nodes_limit = 20
	},
	alliance_display_of_true_might_linirea = {
		slowdown_factor = 0.5,
		slowdown_duration = 3
	},
	alliance_display_of_true_might_dark = {
		slowdown_factor = 0.5,
		slowdown_duration = 5
	},
	points_distribution = {
		0,
		3,
		6,
		9,
		12,
		18,
		21,
		24,
		27,
		30,
		38,
		41,
		44,
		47,
		52,
		60
	}
}
local items = {
	cluster_bomb = {
		damage_radius_small = 45,
		damage_min = 48,
		damage_max_small = 36,
		damage_radius = 45,
		damage_max = 72,
		damage_min_small = 24,
		damage_type = DAMAGE_PHYSICAL
	},
	portable_coil = {
		chain_range = 120,
		range = 80,
		damage_max = 72,
		damage_max_chain = 36,
		max_chain_length = 3,
		damage_min = 48,
		max_targets = 5,
		stun_duration = 4,
		damage_min_chain = 24,
		damage_type = DAMAGE_ELECTRICAL
	},
	deaths_touch = {
		damage_boss = 1000,
		radius = 55
	},
	scroll_of_spaceshift = {
		max_targets = 10,
		radius = 75,
		nodes_teleport = 75,
		nodes_limit = 20
	},
	loot_box = {
		gold_amount = 300,
		radius = 45,
		damage_min = 300,
		damage_max = 300,
		damage_type = DAMAGE_PHYSICAL
	},
	medical_kit = {
		hearts = 3
	},
	winter_age = {
		stun_duration = 15
	},
	summon_blackburn = {
		regen_health = 15,
		hp_max = 2000,
		cooldown = 25,
		speed = 50,
		armor = 0.5,
		range = 65,
		attack_cooldown_special = 0,
		duration = 60,
		spawn = {
			damage_min = 500,
			damage_radius = 75,
			stun_duration = 0.5,
			damage_max = 500,
			damage_type = DAMAGE_PHYSICAL
		},
		basic_attack = {
			damage_radius = 60,
			damage_min = 250,
			cooldown = 1.5,
			damage_max = 300,
			damage_type = DAMAGE_PHYSICAL
		},
		special_attack = {
			max_range = 320,
			damage_max = 180,
			damage_min = 120,
			cooldown = 6,
			damage_radius = 75,
			min_range = 200,
			damage_type = DAMAGE_TRUE
		}
	},
	veznan_wrath = {
		damage_max = 2000,
		damage_min = 2000
	}
}
local balance = {
	heroes = heroes,
	enemies = enemies,
	towers = towers,
	relics = relics,
	specials = specials,
	reinforcements = reinforcements,
	upgrades = upgrades,
	items = items
}

if game and game.store and game.store.level_mode then
	if game.store.level_mode == GAME_MODE_IRON then
		balance.specials.trees.guardian_tree.cooldown_max = 30
		balance.specials.trees.guardian_tree.cooldown_min = 30
		balance.specials.trees.guardian_tree.wave_config = {
			true
		}
		balance.specials.trees.guardian_tree.max_range = 450
		balance.specials.trees.guardian_tree.min_range = 15
		balance.specials.stage07_temple.activation_wave = 1
	elseif game.store.level_mode == GAME_MODE_HEROIC then
		balance.specials.trees.guardian_tree.cooldown_max = 30
		balance.specials.trees.guardian_tree.cooldown_min = 30
		balance.specials.trees.guardian_tree.aura_duration = 5
		balance.specials.trees.guardian_tree.wave_config = {
			true,
			true,
			true,
			true,
			true,
			true
		}
		balance.specials.trees.guardian_tree.max_range = 450
		balance.specials.trees.guardian_tree.min_range = 15
		balance.specials.stage07_temple.activation_wave = 1
	end
end

return balance
