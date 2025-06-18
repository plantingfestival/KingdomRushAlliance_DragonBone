-- chunkname: @./all/marketing.lua

local log = require("klua.log"):new("marketing")
local PS = require("platform_services")
local RC = require("remote_config")
local storage = require("storage")
local signal = require("hump.signal")
local iap_data = not IS_CONSOLE and require("data.iap_data") or nil

require("klua.table")
require("constants")

marketing = {}
marketing.signal_handlers = {
	[SGN_PS_PURCHASE_PRODUCT_FINISHED] = function(service_name, success, product_id)
		log.debug(SGN_PS_PURCHASE_PRODUCT_FINISHED .. " : %s %s %s", service_name, success, product_id)

		if success then
			marketing:md_inc("purchases_count")

			local o = PS.services.iap:get_product(product_id)

			if o then
				marketing:md_set_table("offers_purchased", product_id, os.time())
				marketing:md_set("last_offer_purchase_time", os.time())
				marketing:md_set("last_offer_purchase_session", marketing:md_get("session_count"))

				return
			end
		end
	end,
	[SGN_MARKETING_OFFER_SHOWN] = function(offer_name)
		log.debug(SGN_MARKETING_OFFER_SHOWN .. " : %s", offer_name)
		marketing:md_set("last_offer_show_time", os.time())
		marketing:md_set("last_offer_show_session", marketing:md_get("session_count"))
		marketing:md_set_table("offers_shown", offer_name, os.time())
	end
}

function marketing:init()
	for sn, fn in pairs(self.signal_handlers) do
		signal.register(sn, fn)
	end

	self:md_inc("session_count")
end

function marketing:destroy()
	for sn, fn in pairs(self.signal_handlers) do
		signal.remove(sn, fn)
	end
end

function marketing:load_marketing_data()
	local global = storage:load_global()

	return global.marketing or {}
end

function marketing:save_marketing_data(md)
	local global = storage:load_global()

	if not global.marketing then
		global.marketing = {}
	end

	table.merge(global.marketing, md)
	storage:save_global(global)
end

function marketing:md_get(key)
	local md = self:load_marketing_data()

	return md[key]
end

function marketing:md_get_table(tablekey, key)
	local md = self:load_marketing_data()

	return md[tablekey] and md[tablekey][key] or nil
end

function marketing:md_inc(name)
	local md = self:load_marketing_data()

	if not md[name] then
		md[name] = 0
	end

	md[name] = md[name] + 1

	self:save_marketing_data(md)
end

function marketing:md_set(key, value)
	local md = self:load_marketing_data()

	md[key] = value

	self:save_marketing_data(md)
end

function marketing:md_set_table(tablekey, key, value)
	local md = self:load_marketing_data()

	if not md[tablekey] then
		md[tablekey] = {}
	end

	md[tablekey][key] = value

	self:save_marketing_data(md)
end

marketing.offer_condition_checks = {
	offer_includes_hero_on_sale = function(offer, cond_bool)
		local heroes_on_sale = PS.services.iap:get_hero_sales()
		local includes = false

		for _, inc_name in pairs(offer.includes or {}) do
			if table.contains(heroes_on_sale, inc_name) ~= cond_bool then
				includes = true

				break
			end
		end

		return includes == cond_bool
	end,
	offer_includes_purchased_product = function(offer, cond_bool)
		local includes = false

		for _, inc_name in pairs(offer.includes or {}) do
			local p = PS.services.iap:get_product(inc_name)

			if p and p.owned then
				includes = true

				break
			end
		end

		return includes == cond_bool
	end,
	offer_includes_unpurchased_products_count = function(offer, cond_value)
		local inc_count = 0

		if not IS_TRILOGY and offer.consumable then
			return true
		end

		for _, inc_name in pairs(offer.includes or {}) do
			local p = PS.services.iap:get_product(inc_name)

			if p and not p.owned then
				inc_count = inc_count + 1
			end
		end

		return cond_value <= inc_count
	end,
	offer_was_shown = function(offer, cond_bool)
		local md = marketing:load_marketing_data()
		local shown = md.offers_shown and md.offers_shown[offer.id] and md.offers_shown[offer.id] > 0 or false

		return shown == cond_bool
	end,
	offer_was_purchased = function(offer, cond_value)
		local p = PS.services.iap:get_product(offer.id)

		return (p and p.owned or false) == cond_value
	end,
	player_made_purchases = function(offer, cond_bool)
		local md = marketing:load_marketing_data()
		local made_purchases = md.purchases_count and md.purchases_count > 0

		return made_purchases == cond_bool
	end,
	player_reached_level = function(offer, cond_number)
		local slot = storage:load_slot()

		return slot and slot.levels and slot.levels[cond_number]
	end,
	player_not_reached_level = function(offer, cond_number)
		local slot = storage:load_slot()

		return slot and slot.levels and not slot.levels[cond_number]
	end,
	player_reached_sessions = function(offer, cond_number)
		local md = marketing:load_marketing_data()

		return md.session_count and cond_number <= md.session_count
	end,
	player_reached_stars = function(offer, cond_number)
		local slot = storage:load_slot()

		return slot and cond_number <= storage:get_slot_progress(slot)
	end,
	seconds_elapsed_since_any_offer_purchased = function(offer, cond_number)
		local p_time = marketing:md_get("last_offer_purchase_time")

		return not p_time or cond_number < os.difftime(os.time(), p_time)
	end,
	seconds_elapsed_since_any_offer_shown = function(offer, cond_number)
		local s_time = marketing:md_get("last_offer_show_time")

		return not s_time or cond_number < os.difftime(os.time(), s_time)
	end,
	sessions_passed_since_offer_purchased = function(offer, cond_number)
		local md = marketing:load_marketing_data()

		return not md.last_offer_purchase_session or cond_number <= md.session_count - md.last_offer_purchase_session
	end,
	sessions_passed_since_offer_shown = function(offer, cond_number)
		local md = marketing:load_marketing_data()

		return not md.last_offer_show_session or cond_number <= md.session_count - md.last_offer_show_session
	end
}

function marketing:get_candidate_offers(persistent)
	if not PS.services.iap then
		log.error("IAP not available")

		return
	end

	local offers_available = PS.services.iap:get_offers()

	if not offers_available or #offers_available < 1 then
		log.debug("offers not defined or empty")

		return
	end

	local candidate_offers = {}

	for _, id in pairs(offers_available) do
		do
			local offer = PS.services.iap:get_product(id)

			if not offer then
				log.error("offer %s in offers_%s list but not found in remote config", PS.services.iap.rc_suffix, id)
			elseif IS_TRILOGY and (not offer.includes or #offer.includes == 0) then
				log.error("offer %s has no inlcudes", offer.product_name, id)
			elseif not offer.price or not offer.price_micros then
				log.debug("offer %s has no price yet (not synched yet?)", id)
				log.debug("%s", getfulldump(offer))
			elseif offer.persistent ~= "any" and (persistent and not offer.persistent or not persistent and offer.persistent) then
				log.debug("offer %s does not match persistent filter %s", id, persistent)
			else
				local od = table.deepclone(offer)
				local dc = RC.v.default_offer_conditions or {}
				local conds = table.merge(dc, od.conditions, true)

				if conds.debug_skip_conditions then
					log.debug("offer %s conditions skipped! debug_skip_conditions ON", id)
				else
					for cond_name, cond_value in pairs(conds) do
						local check_fn = self.offer_condition_checks[cond_name]

						if not check_fn then
							log.error("condition check named %s not found for offer %s", cond_name, id)
						elseif cond_value ~= "any" and not check_fn(od, cond_value) then
							log.debug("offer %s failed to pass condition %s %s", id, cond_name, cond_value)

							goto label_26_0
						end
					end
				end

				table.insert(candidate_offers, od)
			end
		end

		::label_26_0::
	end

	log.debug(" candidate offers: %s", getdump(candidate_offers))

	return candidate_offers
end

function marketing:patch_offer_prices(od)
	local old_price = 0

	for _, inc_name in pairs(od.includes or {}) do
		local p = PS.services.iap:get_product(inc_name)

		old_price = old_price + (p.price_micros or 0)

		log.debug("  adding to old price:%s", p.price_micros)
	end

	local gem_base = PS.services.iap:get_product(iap_data.gem_pack_reference)

	if not gem_base.price_micros then
		od.old_price = old_price
		od.old_price_str = "?"
		od.new_price_str = "?"

		return
	end

	local gem_price = gem_base.price_micros / gem_base.reward

	for _, v in pairs(od.includes_consumables or {}) do
		if string.find(v.name, "item_") then
			local item_id = string.gsub(v.name, "item_", "")
			local gem_value = iap_data.shop_data[item_id]

			if gem_value and gem_value.cost and v.count then
				old_price = old_price + v.count * gem_value.cost * gem_price
			end
		elseif string.find(v.name, "gems_") then
			local p = PS.services.iap:get_product(v.name)

			old_price = old_price + (p.price_micros or 0)
		end
	end

	od.old_price = old_price
	od.old_price_str = PS.services.iap:get_formatted_currency(old_price, od.price_currency_code)
	od.new_price_str = od.price
end

function marketing:get_one_time_offer(persistent)
	local offers = self:get_candidate_offers(persistent)

	if offers then
		local od = table.random(offers)
		local maxPriority = -1

		for k, v in pairs(offers) do
			if v.priority and maxPriority < v.priority then
				maxPriority = v.priority
			end
		end

		local mpo = {}

		for k, v in pairs(offers) do
			if v.priority and maxPriority == v.priority then
				table.insert(mpo, v)
			end
		end

		if #mpo > 0 then
			od = table.random(mpo)
		end

		if od then
			self:patch_offer_prices(od)
		end

		return od
	end
end

function marketing:get_active_offer()
	if not PS.services.iap then
		log.error("IAP not available")

		return
	end

	local offers_available = PS.services.iap:get_offers()

	if not offers_available or #offers_available < 1 then
		log.debug("offers not defined or empty")

		return
	end

	local id = self:md_get("active_offer")
	local exp_time = self:md_get("active_offer_expiration")

	if not id or not exp_time then
		return nil
	elseif os.difftime(os.time(), exp_time) > 0 or not table.contains(offers_available, id) or not PS.services.iap:get_product(id) or PS.services.iap:get_product(id).owned then
		log.debug("offer %s expired, invalid, disabled or purchased.", id)
		self:md_set("active_offer", nil)
		self:md_set("active_offer_expiration", nil)

		return nil
	else
		local offer = PS.services.iap:get_product(id)
		local od

		if offer and offer.price and offer.price_micros then
			od = table.deepclone(offer)

			self:patch_offer_prices(od)
		end

		return od, exp_time
	end
end

function marketing:set_active_offer(offer)
	local defaults = RC.v.default_offer_params or {}
	local duration = offer.seconds_icon_is_visible or defaults.seconds_icon_is_visible or 0
	local exp_time = os.time() + duration

	marketing:md_set("active_offer", offer.id)
	marketing:md_set("active_offer_expiration", exp_time)

	return exp_time
end

function marketing:get_sale_offer(name)
	if not table.contains(PS.services.iap:get_tower_sales(), name) and not table.contains(PS.services.iap:get_hero_sales(), name) then
		return nil
	end

	local offer = table.deepclone(PS.services.iap:get_product("sale_" .. name))

	if not offer or not offer.price or not offer.price_micros then
		return nil
	end

	self:patch_offer_prices(offer)

	offer.discount_str = math.ceil((offer.old_price - offer.price_micros) / offer.old_price * 100) .. "%"

	return offer
end

return marketing
