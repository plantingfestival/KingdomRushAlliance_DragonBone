return {
	entities_list = {
		{
			template = "bullywag_spawner",
			pos = {
				x = 260,
				y = 147
			},
			["spawner.pi"] = 1,
			["spawner.name"] = "object1",
			["editor.game_mode"] = 3,
		},
		{
			template = "bullywag_spawner",
			pos = {
				x = 700,
				y = 455
			},
			["spawner.pi"] = 1,
			["spawner.name"] = "object2",
			["editor.game_mode"] = 3,
		},
		{
			template = "mega_spawner",
			load_file = "level417iron_spawner",
			["editor.game_mode"] = 3,
		},
	},
	groups = {
		{
			1
		},
		som1 = {
			"object1",
		},
		som2 = {
			"object2",
		},
	},
	points = {
		{
			path = 3,
			from = {
				x = 260,
				y = 147
			},
			to = {
				x = 260,
				y = 147
			}
		},
	},
	waves = {
		[3] = {
			[1] = {
				{
					100,
					0,
					"som1",
					nil,
					nil,
					nil,
					nil,
					nil,
					nil,
					"CUSTOM",
					true
				},
				{
					101.6,
					0,
					1,
					1,
					1,
					false,
					true,
					6,
					6,
					"enemy_infuser"
				},
				{
					106,
					0,
					"som1",
					nil,
					nil,
					nil,
					nil,
					nil,
					nil,
					"CUSTOM",
					true
				},
				{
					107.6,
					0,
					1,
					1,
					1,
					false,
					true,
					6,
					6,
					"enemy_infuser"
				},
				{
					112,
					0,
					"som1",
					nil,
					nil,
					nil,
					nil,
					nil,
					nil,
					"CUSTOM",
					true
				},
				{
					113.6,
					0,
					1,
					1,
					1,
					false,
					true,
					6,
					6,
					"enemy_infuser"
				},
				{
					118,
					0,
					"som1",
					nil,
					nil,
					nil,
					nil,
					nil,
					nil,
					"CUSTOM",
					true
				},
				{
					119.6,
					0,
					1,
					1,
					1,
					false,
					true,
					6,
					6,
					"enemy_infuser"
				},
				{
					124,
					0,
					"som1",
					nil,
					nil,
					nil,
					nil,
					nil,
					nil,
					"CUSTOM",
					true
				},
				{
					125.6,
					0,
					1,
					1,
					1,
					false,
					true,
					6,
					6,
					"enemy_infuser"
				},
			},
		},
	},
}