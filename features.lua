local _ft = {
	-- no_gems = true,
	default_locale = "zh-Hans",
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
		skip_settings_dialog = false,
		first_launch_fullscreen = true,
		texture_size_list = {
			{
				"FullHD+",
				"ipadhd_bc3",
				1000000000
			},
			-- {
			-- 	"FullHD",
			-- 	"fullhd_bc3",
			-- 	-- 1200
			-- },
			-- {
			-- 	"XGA",
			-- 	"ipad",
			-- 	-- 700
			-- }
		}
	},
	platform_services = {
		achievements = {
			src = "platform_services_steam",
			name = "steam",
			enabled = "true",
			params = {
				app_id = 2849080
			}
		},
		goliath = {
			src = "platform_services_mc_goliath",
			name = "goliath",
			enabled = true,
			order = 90,
			params = {
				game_id = "1703",
				platform = "steam",
				production = {
					api_url = "https://c010a959-8074-4f88-9c05-d78dbc841229.goliath.atlas.bi.miniclippt.com",
					shared_secret = "c07bb7cd-57fd-4d8b-8aaa-0caee3eaed54",
					api_key = "c010a959-8074-4f88-9c05-d78dbc841229"
				},
				staging = {
					api_url = "https://cf9cbfa6-54d1-4a47-bc20-fe2c9b240879.goliath.atlas.bi.miniclippt.com",
					shared_secret = "8920c81d-db13-4762-b324-ee3f75861e2b",
					api_key = "cf9cbfa6-54d1-4a47-bc20-fe2c9b240879"
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
			src = "platform_services_iap_premium",
			name = "iap_premium",
			enabled = true
		},
		news = {
			src = "platform_services_news_ih_https",
			name = "news_ih",
			enabled = true,
			params = {
				news_store = "steam",
				news_id = "kra-steam-win"
			}
		}
	}
}

return _ft