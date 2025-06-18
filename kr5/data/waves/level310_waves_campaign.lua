-- chunkname: @./kr5/data/waves/level310_waves_campaign.lua

return {
	cash = 1200,
	groups = {
		{
			interval = 800,
			waves = {
				{
					delay = 0,
					path_index = 2,
					spawns = {
						{
							interval = 0,
							max_same = 0,
							fixed_sub_path = 1,
							creep = "enemy_tusked_brawler",
							path = 2,
							interval_next = 35,
							max = 1
						}
					}
				}
			}
		}
	}
}
