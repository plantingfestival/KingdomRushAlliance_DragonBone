-- chunkname: @./all/i18n.lua

local i18n = {}

i18n.msgs = {}
i18n.default_locale = "en"
i18n.current_locale = "en"
i18n.supported_locales = {
	"de",
	"en",
	"es",
	"fr",
	"ja",
	"ko",
	"pt",
	"ru",
	"zh-Hans",
	"zh-Hant"
}
i18n.locale_names = {
	ko = "한국어",
	de = "Deutsch",
	ru = "Русский",
	pt = "Português",
	["zh-Hant"] = "中文 (繁體)",
	fr = "Français",
	en = "English",
	ja = "日本語",
	["zh-Hans"] = "中文 (简体)",
	es = "Español"
}
i18n.locale_by_region = {
	["zh-HK"] = "zh-Hant",
	["zh-SG"] = "zh-Hans",
	["zh-TW"] = "zh-Hant",
	["zh-CN"] = "zh-Hans"
}
i18n.missing_keys = {}

function i18n.load_locale(locale)
	i18n.msgs[locale] = require("strings." .. locale)
	i18n.current_locale = locale
end

function _(s, default)
	local l = i18n.msgs[i18n.current_locale]

	l = l or i18n.msgs[i18n.default_locale]

	if KR_TARGET == "console" then
		local tsp = l[i18n:console_suffix(s)]

		if tsp then
			return tsp
		end
	end

	local ts = l[s]

	if ts then
		return ts
	elseif default then
		return default
	else
		if I18N_LOG_MISSING then
			i18n.missing_keys[s] = true
		end

		return s
	end
end

function i18n:sw(default, ...)
	local args = {
		...
	}

	if #args > 0 then
		for i, a in ipairs(args) do
			if i % 2 == 1 and a == self.current_locale then
				return args[i + 1]
			end
		end
	end

	return default
end

function i18n:cjk(default, zh, ja, ko)
	local cl = self.current_locale

	if (cl == "zh-Hans" or cl == "zh-Hant") and zh then
		return zh
	end

	if cl == "ja" and ja then
		return ja
	end

	if cl == "ko" and ko then
		return ko
	end

	return default
end

function i18n:console(default, xbox, ps4)
	if KR_PLATFORM == "ps4" and ps4 then
		return ps4
	elseif KR_PLATFORM == "xbox" and xbox then
		return xbox
	else
		return default
	end
end

function i18n:console_suffix(s)
	return s .. i18n:console("", "_XBOX", "_PS4")
end

function i18n:find_fallback_locale(lang, script, region)
	local l = lang or ""
	local s = script or ""
	local k1 = l
	local k2 = l .. "-" .. s

	if self.locale_names[k2] then
		return k2
	elseif self.locale_names[k1] then
		return k1
	elseif lang ~= nil and script == nil and region ~= nil then
		local v = self.locale_by_region[lang .. "-" .. region]

		if v then
			return v
		end
	else
		for _, sl in pairs(self.supported_locales) do
			local ssl = string.sub(sl, 1, string.len(l))

			if ssl == l then
				return sl
			end
		end
	end
end

return i18n
