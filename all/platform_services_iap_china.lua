-- chunkname: @./all/platform_services_iap_china.lua

local log = require("klua.log"):new("test_platform_services_iap")

log.level = log.DEBUG_LEVEL

require("klua.table")

local signal = require("hump.signal")
local storage = require("storage")
local PSU = require("platform_services_utils")
local RC = require("remote_config")
local tiap = {}

tiap.can_be_paused = true
tiap.update_interval = 1
tiap.rc_suffix = "gpiab"
tiap.purchases_cache = {}
tiap.products_cache = {}
tiap.sync_times = {}
tiap._request_delay = 2
tiap._rid = 1

if KR_GAME == "kr1" then
	tiap._purchases = {
		"hero_oni",
		"offer2"
	}
	tiap._products = {
		{
			id = "premium_unlock",
			premium = true,
			sku = "com.ironhidegames.kingdomrush.googlepass"
		},
		{
			description = "",
			price = "$1.96",
			price_micros = 1960000,
			price_currency_code = "USD",
			id = "gem_pack_bag",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.gempackbag"
		},
		{
			description = "",
			price = "$6.96",
			price_micros = 6960000,
			price_currency_code = "USD",
			id = "gem_pack_barrel",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.gempackbarrel"
		},
		{
			description = "",
			price = "$7.96",
			price_micros = 7960000,
			price_currency_code = "USD",
			id = "gem_pack_chest",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.gempackchest"
		},
		{
			description = "",
			price = "$8.96",
			price_micros = 8960000,
			price_currency_code = "USD",
			id = "gem_pack_wagon",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.gempackwagon"
		},
		{
			description = "",
			price = "$9.96",
			price_micros = 9960000,
			price_currency_code = "USD",
			id = "gem_pack_vault",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.gempackvault"
		},
		{
			description = "",
			price = "$3.86",
			price_micros = 3860000,
			price_currency_code = "USD",
			id = "hero_bolin",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.herobolin"
		},
		{
			description = "",
			price = "$4.86",
			price_micros = 4860000,
			price_currency_code = "USD",
			id = "hero_magnus",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.heromagnus"
		},
		{
			description = "",
			price = "$6.86",
			price_micros = 6860000,
			price_currency_code = "USD",
			id = "hero_ignus",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.heroignus"
		},
		{
			description = "",
			price = "$7.86",
			price_micros = 7860000,
			price_currency_code = "USD",
			id = "hero_denas",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.herodenas"
		},
		{
			description = "",
			price = "$8.86",
			price_micros = 8860000,
			price_currency_code = "USD",
			id = "hero_elora",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.herofrost"
		},
		{
			description = "",
			price = "$9.86",
			price_micros = 9860000,
			price_currency_code = "USD",
			id = "hero_ingvar",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.heroviking"
		},
		{
			description = "",
			price = "$1.86",
			price_micros = 1860000,
			price_currency_code = "USD",
			id = "hero_hacksaw",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.herorobot"
		},
		{
			description = "",
			price = "$2.86",
			price_micros = 2860000,
			price_currency_code = "USD",
			id = "hero_oni",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.herosamurai"
		},
		{
			description = "",
			price = "$3.86",
			price_micros = 3860000,
			price_currency_code = "USD",
			id = "hero_thor",
			title = "",
			sku = "com.armorgames.kingdomrushiphone.herothor1"
		},
		{
			description = "",
			price = "$4.76",
			price_micros = 4760000,
			price_currency_code = "USD",
			id = "offer1",
			title = "",
			sku = "com.ironhidegames.kingdomrush.offer.heropacks1"
		},
		{
			description = "",
			price = "$5.76",
			price_micros = 5760000,
			price_currency_code = "USD",
			id = "offer2",
			title = "",
			sku = "com.ironhidegames.kingdomrush.offer.heropacks2"
		},
		{
			description = "",
			price = "$6.76",
			price_micros = 6760000,
			price_currency_code = "USD",
			id = "offer3",
			title = "",
			sku = "com.ironhidegames.kingdomrush.offer.heropacks3"
		},
		{
			description = "",
			price = "$7.76",
			price_micros = 7760000,
			price_currency_code = "USD",
			id = "offer4",
			title = "",
			sku = "com.ironhidegames.kingdomrush.offer.heropacks4"
		},
		{
			description = "",
			price = "$8.76",
			price_micros = 8760000,
			price_currency_code = "USD",
			id = "offer5",
			title = "",
			sku = "com.ironhidegames.kingdomrush.offer.heropacks5"
		},
		{
			description = "",
			price = "$9.76",
			price_micros = 9760000,
			price_currency_code = "USD",
			id = "offerall",
			title = "",
			sku = "com.ironhidegames.kingdomrush.offer.heropackall"
		}
	}
elseif KR_GAME == "kr2" then
	tiap._purchases = {
		"hero_pirate",
		"offer3"
	}
	tiap._products = {
		{
			id = "premium_unlock",
			premium = true,
			sku = "com.ironhidegames.kingdomrush.frontiers.googlepass"
		},
		{
			description = "",
			price = "$0.79",
			price_micros = 790000,
			price_currency_code = "USD",
			id = "gem_pack_bag",
			title = "",
			sku = "com.ironhidegames.frontiers.gempackbag"
		},
		{
			description = "",
			price = "$1.79",
			price_micros = 1790000,
			price_currency_code = "USD",
			id = "gem_pack_barrel",
			title = "",
			sku = "com.ironhidegames.frontiers.gempackbarrel"
		},
		{
			description = "",
			price = "$2.79",
			price_micros = 2790000,
			price_currency_code = "USD",
			id = "gem_pack_chest",
			title = "",
			sku = "com.ironhidegames.frontiers.gempackchest"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_dracolich",
			title = "",
			sku = "com.ironhidegames.frontiers.dracolich"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_alien",
			title = "",
			sku = "com.ironhidegames.frontiers.heroalien"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_dragon",
			title = "",
			sku = "com.ironhidegames.frontiers.herodragon"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_giant",
			title = "",
			sku = "com.ironhidegames.frontiers.herogolem"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_crab",
			title = "",
			sku = "com.ironhidegames.frontiers.herokarkinos"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_minotaur",
			title = "",
			sku = "com.ironhidegames.frontiers.herominotaur2"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_monk",
			title = "",
			sku = "com.ironhidegames.frontiers.heromonk"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_monkey_god",
			title = "",
			sku = "com.ironhidegames.frontiers.heromonkeygod"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_pirate",
			title = "",
			sku = "com.ironhidegames.frontiers.heropirate"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_priest",
			title = "",
			sku = "com.ironhidegames.frontiers.heropriest"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_van_helsing",
			title = "",
			sku = "com.ironhidegames.frontiers.herovanhelsing2"
		},
		{
			description = "",
			price = "$3.33",
			price_micros = 3330000,
			price_currency_code = "USD",
			id = "hero_wizard",
			title = "",
			sku = "com.ironhidegames.frontiers.herowizard"
		},
		{
			description = "",
			price = "$5.79",
			price_micros = 5790000,
			price_currency_code = "USD",
			id = "offer1",
			title = "",
			sku = "com.ironhidegames.kingdomrush.frontiers.offer.heroalien"
		},
		{
			description = "",
			price = "$6.79",
			price_micros = 6790000,
			price_currency_code = "USD",
			id = "offer2",
			title = "",
			sku = "com.ironhidegames.kingdomrush.frontiers.offer.heropack1"
		},
		{
			description = "",
			price = "$7.79",
			price_micros = 7790000,
			price_currency_code = "USD",
			id = "offer3",
			title = "",
			sku = "com.ironhidegames.kingdomrush.frontiers.offer.heropack2"
		},
		{
			description = "",
			price = "$8.79",
			price_micros = 8790000,
			price_currency_code = "USD",
			id = "offer7",
			title = "",
			sku = "com.ironhidegames.kingdomrush.frontiers.offer.heromonkeygod2"
		},
		{
			description = "",
			price = "$9.79",
			price_micros = 9790000,
			price_currency_code = "USD",
			id = "offerall",
			title = "",
			sku = "com.ironhidegames.kingdomrush.frontiers.offer.heropackall2"
		}
	}
elseif KR_GAME == "kr3" then
	tiap._purchases = {
		"hero_phoenix",
		"offer2",
		"gem_pack_barrel"
	}
	tiap._products = {
		{
			id = "premium_unlock",
			premium = true,
			sku = "com.ironhidegames.kingdomrush.origins.googlepass"
		},
		{
			description = "",
			price = "$0.39",
			price_micros = 390000,
			price_currency_code = "USD",
			id = "gem_pack_bag",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.gempackbag"
		},
		{
			description = "",
			price = "$1.39",
			price_micros = 1390000,
			price_currency_code = "USD",
			id = "gem_pack_barrel",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.gempackbarrel"
		},
		{
			description = "",
			price = "$2.39",
			price_micros = 2390000,
			price_currency_code = "USD",
			id = "gem_pack_chest",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.gempackchest"
		},
		{
			description = "",
			price = "$3.39",
			price_micros = 3390000,
			price_currency_code = "USD",
			id = "gem_pack_wagon",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.gempackwagon"
		},
		{
			description = "",
			price = "$4.39",
			price_micros = 4390000,
			price_currency_code = "USD",
			id = "gem_pack_vault",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.gempackvault"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_regson",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.heroregson"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_xin",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.heropanda"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_veznan",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.heroveznan"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_elves_denas",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.herodenas"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_bravebark",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.herobravebark"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_faustus",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.herofaustus"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_phoenix",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.herophoenix"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_durax",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.herodurax"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_lynn",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.herolynn"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_bruce",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.herobruce"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_wilbur",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.herogyro"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "offer1",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.offer.herofaustus"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "offer2",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.offer.heropacks1"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "offer8",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.offer.heropack7"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "offerall5",
			title = "",
			sku = "com.ironhidegames.kingdomrush.origins.offer.heropackall5"
		}
	}
elseif KR_GAME == "kr5" then
	tiap._purchases = {
		"hero_space_elf",
		"hero_builder",
		"hero_lumenir",
		"hero_mecha",
		"hero_bird",
		"hero_dragon_gem",
		"hero_hunter",
		"hero_robot",
		"hero_witch",
		"hero_dragon_bone",
		"tower_elven_stargazers",
		"tower_necromancer",
		"tower_barrel",
		"tower_sand",
		"tower_ghost",
		"tower_dark_elf"
	}
	tiap._products = {
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_space_elf",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_space_elf"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_builder",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_builder"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_lumenir",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_lumenir"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_mecha",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_mecha"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_bird",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_bird"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_dragon_gem",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_dragon_gem"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_hunter",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_hunter"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_robot",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_robot"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_witch",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_witch"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "hero_dragon_bone",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.hero_dragon_bone"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "tower_elven_stargazers",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.tower_elven_stargazers"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "tower_necromancer",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.tower_necromancer"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "tower_barrel",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.tower_barrel"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "tower_sand",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.tower_sand"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "tower_ghost",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.tower_ghost"
		},
		{
			description = "",
			price = "$9.39",
			price_micros = 9390000,
			price_currency_code = "USD",
			id = "tower_dark_elf",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.tower_dark_elf"
		},
		{
			description = "Reward: 1200 Gems",
			price = "$1.99",
			price_micros = 1990000,
			price_currency_code = "USD",
			id = "gems_handful",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.gems_handful"
		},
		{
			description = "Reward: 2200 Gems",
			price = "$3.99",
			price_micros = 3990000,
			price_currency_code = "USD",
			id = "gems_pouch",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.gems_pouch"
		},
		{
			description = "Reward: 5000 Gems",
			price = "$7.99",
			price_micros = 7990000,
			price_currency_code = "USD",
			id = "gems_barrel",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.gems_barrel"
		},
		{
			description = "Reward: 11000 Gems",
			price = "$15.99",
			price_micros = 15990000,
			price_currency_code = "USD",
			id = "gems_chest",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.gems_chest"
		},
		{
			description = "Reward: 30000 Gems",
			price = "$39.99",
			price_micros = 39990000,
			price_currency_code = "USD",
			id = "gems_wagon",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.gems_wagon"
		},
		{
			description = "Reward: 70000 Gems",
			price = "$79.99",
			price_micros = 79990000,
			price_currency_code = "USD",
			id = "gems_mountain",
			title = "",
			sku = "com.ironhidegames.kingdomrush5.gems_mountain"
		}
	}
end

tiap.signal_handlers = {}

function tiap:init(name, params)
	log.error("TEST IAP / test_platform_services_iap loaded")

	tiap.rc_suffix = params.rc_suffix

	if self.inited then
		log.debug("TEST IAP service %s already inited", name)
	else
		if not RC.v["products_" .. self.rc_suffix] then
			log.error("products_%s not defined in remote_config", self.rc_suffix)

			return nil
		end

		self.prq = PSU:new_prq()

		for sn, fn in pairs(self.signal_handlers) do
			signal.register(sn, fn)
		end

		self.inited = true
	end

	if not self.names then
		self.names = {}
	end

	if not table.contains(self.names, name) then
		table.insert(self.names, name)
	end

	return true
end

function tiap:shutdown(name)
	if self.inited then
		for sn, fn in pairs(self.signal_handlers) do
			signal.remove(sn, fn)
		end
	end

	self.names = nil
	self.inited = nil
end

function tiap:deliver_purchase(id)
	log.debug("TEST IAP delivering purchase for id: %s", id)

	local p = self:get_product(id, true)

	if not p then
		log.error("TEST IAP id:%s not found in remote_config", id)

		return false
	end

	if not self.purchases_cache[id] then
		self.purchases_cache[id] = {}
	end

	local cp = self.purchases_cache[id]

	if p.includes then
		for _, subid in pairs(p.includes) do
			log.debug("TEST IAP   delivering product pack:%s item:%s", id, subid)
			self:deliver_purchase(subid)
		end

		cp.owned = true
	elseif p.gems then
		local slot = storage:load_slot()

		if slot then
			slot.gems = slot.gems + p.reward

			if not slot.gems_purchased then
				slot.gems_purchased = 0
			end

			slot.gems_purchased = slot.gems_purchased + p.reward

			storage:save_slot(slot, nil, true)
		end
	else
		cp.owned = true
	end

	return true
end

function tiap:get_status()
	return true
end

function tiap:is_premium()
	return self.premium
end

function tiap:is_premium_valid()
	return true
end

function tiap:get_pending_requests()
	return self.prq
end

function tiap:get_sync_status()
	return self.sync_times
end

function tiap:get_request_status(rid)
	local req = self.prq[rid]

	if not req then
		return -1
	elseif love.timer.getTime() - req.ts < self._request_delay then
		return 1
	else
		return 0
	end
end

function tiap:cancel_request(rid)
	self.prq:remove(rid)
end

function tiap:restore_purchases()
	self:sync_purchases()
	signal.emit(SGN_PS_RESTORE_PURCHASES_FINISHED, "iap", status == 0)
end

function tiap:sync_purchases(silent)
	log.error("TEST IAP")

	local was_premium = tiap.premium

	tiap.premium = nil

	for _, v in pairs(self._purchases) do
		local p = self:get_product(v, true)

		if p and p.premium then
			if not was_premium then
				signal.emit(SGN_PS_PREMIUM_UNLOCKED, "iap", "test_iap")
			end

			tiap.premium = true
		end
	end

	if not tiap.premium then
		for _, v in pairs(self._purchases) do
			self:deliver_purchase(v)
		end

		local ph = {}

		for id, p in pairs(self.purchases_cache) do
			if string.starts(id, "hero_") then
				table.insert(ph, id)
			end
		end

		local global = storage:load_global()

		global.purchased_heroes = ph

		storage:save_global(global)
	end

	self.sync_times.purchases = os.time()
end

function tiap:purchase_product(id)
	local function cb_consume(status, req)
		tiap:deliver_purchase(req.product_id)
		signal.emit(SGN_PS_PURCHASE_PRODUCT_FINISHED, "iap", status == 0, req.product_id)
	end

	local function cb_purchase(status, req)
		local success = true

		if req.consumable then
			local crid = self._rid

			self._rid = self._rid + 1

			local creq = self.prq:add(crid, "consume", cb_consume)

			creq.product_id = req.product_id
			creq.sku = req.sku

			log.debug("TEST IAP chaining consume product request id:%s for sku:%s token:%s", crid, req.product_id, token)

			return
		end

		tiap:deliver_purchase(req.product_id)
		signal.emit(SGN_PS_PURCHASE_PRODUCT_FINISHED, "iap", success, req.product_id)
	end

	local p = self:get_product(id, true)

	if not p then
		log.error("TEST IAP could not initiate purchase of product %s. not found in remote_config", id)

		return nil
	end

	log.debug("TEST IAP purchasing product:%s consume:%s", id, p.consumable)

	local sku = p.skus and (p.skus[self.rc_suffix] or p.skus.default)

	if not sku then
		log.error("TEST IAP missing sku for product: %s", id)

		return nil
	end

	local rid = self._rid

	self._rid = self._rid + 1

	local req = self.prq:add(rid, "purchase", cb_purchase)

	req.product_id = id
	req.sku = sku
	req.consumable = p.consumable

	return rid
end

function tiap:get_product(id, reference)
	local k = "product_" .. id
	local p = RC.v[k]

	if not p then
		log.error("TEST IAP product %s not found in remote_config %s", id, k)

		return nil
	end

	if reference then
		return p
	end

	local o = table.deepclone(p)

	if self.products_cache[id] then
		o = table.merge(o, self.products_cache[id])
	end

	if self.purchases_cache[id] then
		o = table.merge(o, self.purchases_cache[id])
	end

	o.id = id

	return o
end

function tiap:get_offers()
	if self:is_premium() then
		log.error("hero_sales_gpiab is premium. no hero sales shown")

		return {}
	end

	local offers = RC.v["offers_" .. self.rc_suffix]

	if not offers then
		log.error("TEST IAP offers_%s not found in remote_config", self.rc_suffix)

		return {}
	end

	return offers
end

function tiap:get_hero_sales()
	if self:is_premium() then
		log.error("hero_sales_gpiab is premium. no hero sales shown")

		return {}
	end

	local offers = RC.v["hero_sales_" .. self.rc_suffix]

	if not offers then
		log.error("TEST IAP hero_sales_%s not found in remote_config", self.rc_suffix)

		return {}
	end

	return offers
end

function tiap:get_tower_sales()
	if self:is_premium() then
		log.error("tower_sales_gpiab is premium. no hero sales shown")

		return {}
	end

	local offers = RC.v["tower_sales_" .. self.rc_suffix]

	if not offers then
		log.error("TEST IAP tower_sales_%s not found in remote_config", self.rc_suffix)

		return {}
	end

	return offers
end

function tiap:get_dlcs(owned)
	local dlcs = {}

	for _, n in pairs(RC.v["products_" .. self.rc_suffix]) do
		if string.starts(n, "dlc_") then
			if owned then
				local p = self:get_product(n)

				if p and p.owned then
					table.insert(dlcs, n)
				end
			else
				table.insert(dlcs, n)
			end
		end
	end

	return dlcs
end

function tiap:get_formatted_currency(amount_micros, currency_code)
	return string.format("$%.2f", amount_micros / 1000000)
end

function tiap:sync_products()
	local function cb_sync_products(status, req)
		log.debug("TEST IAP sync_products complete for req.id:%s status:%s", req.id, status)

		local success = true

		for _, sp in pairs(self._products) do
			local p = self:get_product(sp.id, true)

			if not p then
				log.error("TEST IAP iap product %s not found in remote_config", sp.id)
			else
				if not self.products_cache[sp.id] then
					self.products_cache[sp.id] = {}
				end

				local cp = self.products_cache[sp.id]

				cp.sku = sp.sku
				cp.title = sp.title
				cp.description = sp.description
				cp.price = sp.price
				cp.price_micros = sp.price_micros
				cp.price_currency_code = sp.price_currency_code

				log.debug("TEST IAP iap cached product %s: %s", sp.id, "")
			end
		end

		signal.emit(SGN_PS_SYNC_PRODUCTS_FINISHED, "iap", success)
	end

	self.sync_times.products = os.time()

	local rid = self._rid

	self._rid = self._rid + 1

	self.prq:add(rid, "sync_products", cb_sync_products)

	return rid
end

function tiap:get_container_dlc(id)
	local dlcs = self:get_dlcs()

	for _, v in pairs(dlcs) do
		local p = self:get_product(v)

		if p and p.includes and table.contains(p.includes, id) then
			return p
		end
	end
end

return tiap
