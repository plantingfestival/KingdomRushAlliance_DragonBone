-- chunkname: @./features.lua

local _ft = {
	no_gems = true,
	asset_game_fallback_for_texture_size = {
		fullhd_bc3 = {
			{
				texture_size = "ipadhd_bc3",
				path = "kr5-desktop"
			}
		}
	},
	libs = {
		"libcurl-x64",
		"khttps",
		"ksystem",
		"steam_api"
	},
	main_params = {
		image_db_uses_canvas = true,
		texture_size = "ipadhd_bc3",
		skip_settings_dialog = true,
		first_launch_fullscreen = true,
		texture_size_list = {
			{
				"FullHD+",
				"ipadhd_bc3",
				1000000000
			},
			{
				"FullHD",
				"fullhd_bc3",
				1200
			},
			{
				"XGA",
				"ipad",
				700
			}
		}
	},
	platform_services = {
		achievements = {
			src = "platform_services_steam",
			name = "steam_ach",
			enabled = true,
			order = 41
		},
		goliath = {
			src = "platform_services_mc_goliath",
			name = "goliath",
			enabled = true,
			order = 90,
			params = {
				game_id = "1944",
				platform = "steam",
				production = {
					api_url = "https://ea4ed4a2-c9ae-40f9-a3b3-20db93550dbc.goliath.atlas.bi.miniclippt.com",
					shared_secret = "9f9c7755-d50c-4384-9ee4-a95426bfff57",
					api_key = "ea4ed4a2-c9ae-40f9-a3b3-20db93550dbc"
				},
				staging = {
					api_url = "https://93b950ba-2762-451f-b960-a9acbe311742.goliath.atlas.bi.miniclippt.com",
					shared_secret = "c00480a5-e021-4129-b993-f446b728f33b",
					api_key = "93b950ba-2762-451f-b960-a9acbe311742"
				}
			}
		},
		http = {
			src = "platform_services_http",
			essential = true,
			enabled = true,
			name = "http"
		},
		iap = {
			src = "platform_services_steam",
			name = "steam_iap",
			enabled = true,
			order = 40,
			params = {
				app_id = 2849080,
				dlcs = {
					{
						id = "dlc_1",
						app_id = 3368630,
						includes = {
							"hero_lava",
							"tower_dwarf"
						}
					}
				}
			}
		},
		news = {
			src = "platform_services_news_ih_https",
			name = "news_ih",
			enabled = true,
			order = 50,
			params = {
				news_store = "steam",
				news_id = "kra-steam-win"
			}
		}
	}
}

return _ft
