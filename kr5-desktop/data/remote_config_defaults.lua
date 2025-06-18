-- chunkname: @./kr5-desktop/data/remote_config_defaults.lua

local d = {
	premium_show_more_games = false,
	ingame_shop = true,
	news_url = "https://news.ironhidegames.com/api/v1/PromoNews",
	ask_for_rating = true,
	premium_show_news = true,
	link_more_games = {
		["com.ironhidegames.kingdomrush.alliance.windows.steam"] = "https://store.steampowered.com/franchise/ironhidegames/",
		["com.ironhidegames.kingdomrush.alliance.mac.appstore"] = "https://www.ironhidegames.com/games",
		["com.ironhidegames.kingdomrush.alliance.mac.steam"] = "https://store.steampowered.com/franchise/ironhidegames/",
		["com.ironhidegames.kingdomrush.alliance"] = "https://www.ironhidegames.com/games",
		["com.ironhidegames.android.kingdomrush.alliance"] = "https://www.ironhidegames.com/games"
	},
	url_twitter = {
		default = "https://twitter.com/ironhidegames"
	},
	url_facebook = {
		default = "http://www.facebook.com/ironhidegames"
	},
	url_instagram = {
		default = "https://www.instagram.com/ironhidegames"
	},
	url_discord = {
		default = "https://discord.gg/aqHGabqupe"
	},
	url_tiktok = {
		default = "https://www.tiktok.com/@ironhidegames"
	},
	url_ih = {
		default = "https://www.ironhidegames.com/games"
	},
	url_privacy_policy = {
		default = "https://www.ironhidegames.com/PrivacyPolicy"
	},
	url_terms_of_service = {
		default = "https://www.ironhidegames.com/TermsOfService"
	},
	url_strategy_guide = {
		default = "http://www.kingdomrushorigins.com/strategy.html"
	},
	url_store = {
		default = "http://www.kingdomrushorigins.com",
		["com.ironhidegames.kingdomrush.alliance"] = "https://apps.apple.com/us/app/kingdom-rush-5-alliance-td/id1622869542",
		["com.ironhidegames.android.kingdomrush.alliance"] = "https://play.google.com/store/apps/details?id=com.ironhidegames.android.kingdomrush.alliance"
	},
	ask_for_rating_level = {
		4,
		7,
		12
	},
	one_time_gifts = {},
	default_offer_conditions = {
		offer_includes_hero_on_sale = false,
		offer_was_purchased = false,
		offer_includes_purchased_product = false,
		player_made_purchases = "any",
		offer_includes_unpurchased_products_count = 1
	},
	default_offer_params = {
		seconds_icon_is_visible = 43200
	}
}

return d
