-- chunkname: @./all/platform_services_e2w_android.lua

local log = require("klua.log"):new("platform_services_e2w_android")

require("klua.table")

local signal = require("hump.signal")
local storage = require("storage")
local jnia = require("all.jni_android")
local PSU = require("platform_services_utils")
local RC = require("remote_config")
local md5 = require("md5")
local srv = {}

srv.can_be_paused = true
srv.update_interval = 3
srv.rc_suffix = "e2w"
srv.shared_keys_prefix = {
	purchased_dlcs = "dlc_",
	purchased_towers = "tower_",
	purchased_heroes = "hero_"
}
srv.shared_filename = "e2w_shared.lua"
srv.shared_cs_extra = "Yep... found it. Do you really want to do this?"
srv.shared_expiration = 300
srv.SRV_ID = 31
srv.SRV_DISPLAY_NAME = "E2W Android"
srv.LONG_TIMEOUT = 999
srv.late_update_status = false
srv.sku_index = {}
srv.sync_times = {}
srv.purchases_cache = {}
srv.products_cache = {}
srv.last_cached_purchases = nil
srv.sync_purchases_in_progress = nil
srv.purchase_in_progress = nil
srv._request_delay = 2
srv._rid = 1

if KR_PLATFORM == "android" then
	srv.signal_handlers = {
		["slot-saved"] = function(idx, should_sync)
			if should_sync then
				srv:push_slot(idx)
			end
		end,
		["slot-deleted"] = function(idx)
			srv:delete_slot(idx)
		end
	}
else
	srv.signal_handlers = {}
end

local proxy

if KR_PLATFORM == "android" then
	proxy = require("all.jni_android")
else
	log.error("%s does not work in platform %s", srv.SRV_DISPLAY_NAME, KR_PLATFORM)

	proxy = {}
end

function srv:deliver_purchase(id)
	log.debug("delivering purchase for id: %s", id)

	local p = self:get_product(id, true)

	if not p then
		log.error("id:%s not found in remote_config", id)

		return false
	end

	if not self.purchases_cache[id] then
		self.purchases_cache[id] = {}
	end

	local cp = self.purchases_cache[id]

	if p.includes then
		for _, subid in pairs(p.includes) do
			log.debug("delivering product pack:%s item:%s", id, subid)
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
	elseif p.includes_consumables then
		local slot = storage:load_slot()

		if slot then
			for _, v in pairs(p.includes_consumables) do
				if string.find(v.name, "item_") then
					local item_id = string.gsub(v.name, "item_", "")

					if slot.items.status[item_id] and v.count then
						slot.items.status[item_id] = slot.items.status[item_id] + v.count
					else
						log.error("id:%s item not found in slot", v.item)
					end
				elseif string.find(v.name, "gems_") then
					local g = self:get_product(v.name, true)

					if g and g.gems then
						slot.gems = slot.gems + g.reward

						if not slot.gems_purchased then
							slot.gems_purchased = 0
						end

						slot.gems_purchased = slot.gems_purchased + g.reward
					else
						log.error("id:%s gempack not found in remote_config", v.name)
					end
				end
			end

			storage:save_slot(slot, nil, true)
		end
	else
		cp.owned = true
	end

	return true
end

function srv:update_sku_index()
	for _, n in pairs(RC.v["products_" .. self.rc_suffix]) do
		local p = self:get_product(n)
		local sku = p and p.skus and (p.skus[self.rc_suffix] or p.skus.default)

		if sku then
			self.sku_index[sku] = n
		end
	end
end

function srv:parse_products(str)
	if not str or str == "" then
		return {}
	end

	local lines = string.split(str, "\n")

	if not lines or #lines == 0 then
		return {}
	end

	local out = {}

	for _, line in pairs(lines) do
		local sku, title, description, price, price_micros, price_currency_code = unpack(string.split_by_char(line, ";"))
		local id = self.sku_index[sku]

		if not id then
			log.debug("sku:%s not found in sku_index", sku)
		else
			local t = {
				sku = sku,
				title = title,
				description = description,
				price = price,
				price_micros = tonumber(price_micros),
				price_currency_code = price_currency_code
			}

			t.id = id

			table.insert(out, t)
		end
	end

	return out
end

function srv:parse_purchases(str)
	if not str or str == "" then
		return {}
	end

	local lines = string.split(str, "\n")

	if not lines or #lines == 0 then
		return {}
	end

	local out = {}

	for _, line in pairs(lines) do
		local sku = unpack(string.split_by_char(line, ";"))
		local id = self.sku_index[sku]

		if not id then
			log.debug("sku:%s not found in sku_index", sku)
		else
			local t = {
				sku = sku
			}

			t.id = id

			table.insert(out, t)
		end
	end

	return out
end

function srv:cs(t)
	local s = storage:serialize_lua(t)

	return md5.sumhexa(s .. self.shared_cs_extra .. self:get_identity())
end

function srv:validate_shared_data(data)
	if not data then
		log.debug("shared data is empty")

		return false
	end

	if not data.cs then
		log.debug("shared data has no cs")

		return false
	end

	local t = table.deepclone(data)

	t.cs = nil

	local t_cs = self:cs(t)

	if data.cs ~= t_cs then
		log.debug("shared data validation error: %s vs %s", data.cs, t_cs)

		return false
	end

	return true
end

function srv:merge_shared_data(ldata, rdata)
	local data = table.deepclone(ldata) or {}

	for k, prefix in pairs(self.shared_keys_prefix) do
		if not data[k] then
			data[k] = {}
		end

		if rdata and rdata[k] then
			for _, v in pairs(rdata[k]) do
				if not table.contains(data[k], v) then
					table.insert(data[k], v)
				end
			end
		end
	end

	return data
end

function srv:init(name, params)
	if params then
		if params.rc_suffix then
			self.rc_suffix = params.rc_suffix
		end

		if params.e2w_sku then
			self.e2w_sku = params.e2w_sku

			proxy.set_service_param("e2w_sku", params.e2w_sku)
		end
	end

	if self.inited then
		log.debug("service %s already inited", name)
	else
		if name == "iap" and not RC.v["products_" .. self.rc_suffix] then
			log.error("products_%s not defined in remote_config", self.rc_suffix)

			return nil
		end

		do
			local result = proxy.init_service(self.SRV_ID)

			if result ~= 1 then
				log.error("platform_services_e2w_android init failed")

				return nil
			end
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

function srv:shutdown(name)
	if self.inited then
		for sn, fn in pairs(self.signal_handlers) do
			signal.remove(sn, fn)
		end
	end

	self.names = nil
	self.inited = nil
end

function srv:late_update(dt)
	local status = self:is_auth()

	if not status and self.late_update_status then
		signal.emit(SGN_PS_CHANNEL_LOGOUT)
	end

	self.late_update_status = status
end

function srv:get_status()
	return proxy.get_service_status(self.SRV_ID) == 1
end

function srv:is_premium()
	return self.premium
end

function srv:is_premium_valid()
	return true
end

function srv:get_pending_requests()
	return self.prq
end

function srv:get_sync_status()
	return self.sync_times
end

function srv:get_request_status(rid)
	local result = proxy.get_request_status(rid)

	log.paranoid("get_request_status service:%s rid:%s result:%s", self.name, rid, result)

	return result
end

function srv:cancel_request(rid)
	self.prq:remove(rid)
end

function srv:get_string(key)
	return proxy.get_remote_config_string(self.SRV_ID, key)
end

function srv:get_keys()
	local out = {}
	local str = proxy.get_remote_config_keys(self.SRV_ID)

	if str then
		out = string.split(str, ",")
	end

	return out
end

function srv:sync()
	local function cb_sync_rc(status, req)
		local success = status == 0

		signal.emit(SGN_PS_REMOTE_CONFIG_SYNC_FINISHED, "remoteconfig", success)
	end

	local rid = proxy.create_request_sync_remote_config(self.SRV_ID)

	if rid < 0 then
		log.error("remote config sync error: %s", rid)

		return nil
	end

	self.prq:add(rid, "sync_remote_config", cb_sync_rc)

	return rid
end

function srv:is_auth()
	return proxy.is_auth(self.SRV_ID)
end

function srv:deauth()
	self.sync_times.slots = 0

	proxy:do_deauth(self.SRV_ID)
end

function srv:auth()
	local function cb_signin_cloud(status, req)
		local success = status == 0
		local error_msg = proxy.get_request_error_message(req.id)

		signal.emit(SGN_PS_AUTH_FINISHED, "auth", success, status, error_msg)
	end

	local function cb_auth(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		local success = status == 0
		local error_msg = proxy.get_request_error_message(req.id)

		if not success then
			log.error("e2w_sdk request error: %s", getdump(req))
			signal.emit(SGN_PS_AUTH_FINISHED, "auth", success, status, error_msg)

			return
		end

		local crid = proxy.create_request_do_signin(self.SRV_ID)

		if crid < 0 then
			log.error("error creating request to cloud auth in e2w_sdk, error:%s", crid)

			return
		end

		self.prq:add(crid, "signin", cb_signin_cloud, self.LONG_TIMEOUT)
		log.debug("chaining cloud signin request id:%s", crid)
	end

	log.debug("starting e2w_sdk auth...")

	local rid = proxy.create_request_do_auth(self.SRV_ID)

	if rid < 0 then
		log.error("error creating request to auth with e2w_sdk, error:%s", rid)

		return nil
	end

	log.debug("queued auth request id %s", rid)
	self.prq:add(rid, "auth", cb_auth, self.LONG_TIMEOUT)
	signal.emit(SGN_PS_AUTH_STARTED, "auth")

	return rid
end

function srv:get_gamertag()
	return ""
end

function srv:get_channel_name()
	return proxy.get_channel_name(self.SRV_ID)
end

function srv:get_channel_uid()
	return proxy.get_channel_uid(self.SRV_ID)
end

function srv:should_hide_quit_prompt()
	return proxy.should_hide_quit_prompt(self.SRV_ID)
end

function srv:quit_game()
	local function cb_quit_game(status, req)
		log.debug("quit game request completed with status:%s", status)
	end

	log.debug("requesting quit game...")

	local rid = proxy.create_request_quit_game(self.SRV_ID)

	if rid < 0 then
		log.error("error creating request to quit game. error:%s", rid)

		return nil
	end

	self.prq:add(rid, "quit_game", cb_quit_game, self.LONG_TIMEOUT)

	return rid
end

function srv:sync_purchases(silent)
	local function sync(silent, data, uid)
		local purchases = {}

		if not silent then
			local cached_purchases_string = proxy.get_cached_purchases(self.SRV_ID)

			log.debug("cached purchases string:%s", cached_purchases_string)

			local cached_purchases = self:parse_purchases(cached_purchases_string)

			table.append(purchases, cached_purchases)

			for _, pu in pairs(cached_purchases) do
				proxy.create_request_acknowledge_product(self.SRV_ID, pu.sku)
			end
		end

		if data then
			for k, p in pairs(self.shared_keys_prefix) do
				for _, id in pairs(data[k] or {}) do
					if table.find(purchases, function(kk, v)
						return v.id == id
					end) == nil then
						table.insert(purchases, {
							source = "restored",
							id = id
						})
					end
				end
			end
		end

		for _, pu in pairs(purchases) do
			local id = pu.id
			local p = self:get_product(id)

			if not p then
				log.error("Sync purchases error. Product with id:%s not found in remote_config", id)
			elseif p and p.owned then
				log.debug("Product already delivered. Ignoring. %s", id)
			else
				self:deliver_purchase(id)

				if not silent then
					local pu_data = {}

					signal.emit(SGN_PS_PURCHASE_PRODUCT_FINISHED, "iap", true, id, "", pu.source == "restored", pu_data)
				end
			end
		end

		for k, prefix in pairs(self.shared_keys_prefix) do
			data[k] = {}

			for id, v in pairs(self.purchases_cache) do
				if string.starts(id, prefix) and not table.contains(data[k], id) then
					table.insert(data[k], id)
				end
			end
		end

		data.timestamp = os.time()
		data.cs = nil
		data.cs = self:cs(data)

		storage:write_lua(self.shared_filename, data, true)
		srv:push_file(self.shared_filename, data, true)

		self.sync_times.purchases = os.time()

		signal.emit(SGN_PS_SYNC_PURCHASES_FINISHED, "iap", true)
	end

	local function cb_pull_file(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		local data, ldata

		if status == 0 then
			local rstr = proxy.get_cached_cloud_file(srv.SRV_ID, req.filename)

			log.paranoid("  rstr for fileslot %s:%s", req.filename, rstr)

			local rdata = storage:deserialize_lua(rstr)

			if not rdata then
				log.debug("Cloudfile %s is empty... ignoring", req.filename)
			elseif not srv:validate_shared_data(rdata) then
				log.error("Error validating cloudfile %s : %s", req.filename, getdump(rdata))
			else
				ldata = storage:load_lua(srv.shared_filename)

				if not ldata then
					log.debug("no local data to merge. just use remote data")

					data = rdata
				elseif ldata and rdata and ldata.timestamp and rdata.timestamp and ldata.timestamp ~= rdata.timestamp and srv:validate_shared_data(ldata) then
					log.debug("merge remote data and local data to preserve all purchases")

					data = srv:merge_shared_data(ldata, rdata)
				end
			end

			self.sync_times.shared_file = os.time()
		else
			data = nil
		end

		if not data then
			data = storage:load_lua(srv.shared_filename)

			if not data or type(data) ~= "table" then
				data = {}
			elseif not srv:validate_shared_data(data) then
				log.error("Resetting shared file due to validation errors. filename:%s : %s", req.filename, getdump(data))

				data = {}
			end
		end

		sync(silent, data, req.uid)
	end

	local uid = self:get_identity()

	if uid == "" then
		log.error("Cannot sync_products without a valid user id")

		return
	end

	local ldata_all = storage:load_lua(srv.shared_filename)
	local ldata = ldata_all and ldata_all[uid]

	if self.sync_times.shared_file and self.sync_times.shared_file + self.shared_expiration > os.time() and ldata and srv:validate_shared_data(ldata) then
		sync(silent, ldata)
	else
		local rid = proxy.create_request_pull_cloud_file(self.SRV_ID, self.shared_filename)

		if rid < 0 then
			log.error("error creating request to pull file %s", self.shared_filename)

			return nil
		else
			local req = self.prq:add(rid, "pull_file", cb_pull_file)

			req.filename = self.shared_filename
			req.uid = uid

			return rid
		end
	end
end

function srv:purchase_product(id)
	local function cb_purchase(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		log.info("purchase_product complete for req.id:%s status:%s", req.id, status)

		local success

		if status == 0 then
			success = true

			self:sync_purchases()
		else
			success = false
		end

		signal.emit(SGN_PS_PURCHASE_PRODUCT_FINISHED, "iap", success, req.product_id)
	end

	srv.purchase_in_progress = nil

	local p = self:get_product(id, true)

	if not p then
		log.error("could not initiate purchase of product %s. not found in remote_config", id)

		return nil
	end

	log.info("purchasing product:%s", id, p.consumable)

	local sku = p.skus and (p.skus[self.rc_suffix] or p.skus.default)

	if not sku then
		log.error("missing sku for product: %s", id)

		return nil
	end

	local rid = proxy.create_request_purchase_product(self.SRV_ID, sku, p.consumable)

	if rid < 0 then
		log.error("error creating request to purchase iap %s consume:%s", id, p.consumable)

		return nil
	else
		local req = self.prq:add(rid, "purchase", cb_purchase, self.LONG_TIMEOUT)

		req.product_id = id
		req.sku = sku
		req.consumable = p.consumable
		srv.purchase_in_progress = true

		return rid
	end
end

function srv:get_product(id, reference)
	if not id then
		log.error("trying to get product with nil id")

		return nil
	end

	local k = "product_" .. id
	local p = RC.v[k]

	if not p then
		log.error("product %s not found in remote_config %s", id, k)

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

function srv:get_offers()
	if self:is_premium() then
		log.error("is premium. no offers shown")

		return {}
	end

	local offers = RC.v["offers_" .. self.rc_suffix]

	if not offers then
		log.error("offers_%s not found in remote_config", self.rc_suffix)

		return {}
	end

	return offers
end

function srv:get_hero_sales()
	if self:is_premium() then
		log.error("is premium. no hero sales shown")

		return {}
	end

	local offers = RC.v["hero_sales_" .. self.rc_suffix]

	if not offers then
		log.error("hero_sales_%s not found in remote_config", self.rc_suffix)

		return {}
	end

	return offers
end

function srv:get_tower_sales()
	if self:is_premium() then
		log.error("is premium. no tower sales shown")

		return {}
	end

	local offers = RC.v["tower_sales_" .. self.rc_suffix]

	if not offers then
		log.error("tower_sales_%s not found in remote_config", self.rc_suffix)

		return {}
	end

	return offers
end

function srv:get_gems_sales()
	if self:is_premium() then
		log.error("is premium. no gems sales shown")

		return {}
	end

	local offers = RC.v["gems_sales_" .. self.rc_suffix]

	if not offers then
		log.error("gems_sales_%s not found in remote_config", self.rc_suffix)

		return {}
	end

	return offers
end

function srv:get_dlcs(owned)
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

function srv:get_formatted_currency(amount_micros, currency_code)
	local v = amount_micros / 1000000

	if currency_code == "RMB" then
		return string.format("%.2f元", v)
	else
		return string.format("$%.2f", v)
	end
end

function srv:sync_products()
	local function cb_sync_products(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		log.info("sync_products complete for req.id:%s status:%s", req.id, status)

		local success

		if status == 0 then
			success = true

			local products_string = proxy.get_cached_products(self.SRV_ID)

			log.debug("products_string:%s", products_string)

			local store_products = self:parse_products(products_string)

			for _, sp in pairs(store_products) do
				local p = self:get_product(sp.id)

				if not p then
					log.error("iap product %s not found in remote config", sp.id)
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

					log.debug("iap cached product %s: %s", sp.id, getfulldump(p))
				end
			end

			self.sync_times.products = os.time()
		else
			success = false
			self.sync_times.products = false
		end

		signal.emit(SGN_PS_SYNC_PRODUCTS_FINISHED, "iap", success)
	end

	self:update_sku_index()

	local skus_table = {}

	for _, n in pairs(RC.v["products_" .. self.rc_suffix]) do
		local p = self:get_product(n)

		if not p then
			log.error("product %s not defined in remote_config", n)
		elseif not p.skus or not p.skus[self.rc_suffix] and not p.skus.default then
			-- block empty
		else
			table.insert(skus_table, p.skus[self.rc_suffix] or p.skus.default)
		end
	end

	local skus = table.concat(skus_table, ";")
	local rid = proxy.create_request_sync_products(self.SRV_ID, skus)

	if rid < 0 then
		log.error("error creating request to sync products")

		return nil
	else
		self.prq:add(rid, "sync_products", cb_sync_products)

		return rid
	end
end

function srv:get_container_dlc(id)
	local dlcs = self:get_dlcs()

	for _, v in pairs(dlcs) do
		local p = self:get_product(v)

		if p and p.includes and table.contains(p.includes, id) then
			return p
		end
	end
end

function srv:redeem_code()
	return
end

function srv:show_redeem_dialog()
	local function cb_redeem_code(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		log.debug("show_redeem_dialog complete for req.id:%s status:%s", req.id, status)

		local success

		if status == 0 then
			success = true

			self:sync_purchases()
		else
			success = false
		end

		signal.emit(SGN_PS_SHOW_REDEEM_DIALOG_FINISHED, "iap", success)
	end

	local rid = proxy.create_request_show_redeem_dialog(srv.SRV_ID)

	if rid < 0 then
		log.error("error showing redeem dialog")

		return nil
	else
		self.prq:add(rid, "redeem_code", cb_redeem_code, self.LONG_TIMEOUT)

		return rid
	end
end

function srv:debug_clear_purchases()
	storage:write_lua(self.shared_filename, {}, true)
	self:push_file(self.shared_filename, {}, true)
	log.error("--- RESTART GAME TO COMPLETE PURCHASES DELETE ---")
end

function srv:no_signin()
	return true
end

function srv:do_signin()
	return
end

function srv:do_signout()
	return
end

function srv:get_sync_status()
	return self.sync_times
end

function srv:sync_slots()
	local function cb_sync_slots(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		local success

		if status == 0 then
			success = true
			self.sync_times.slots = os.time()

			for i = 1, 3 do
				local lslot = storage:load_slot(i)
				local rdata = proxy.get_cached_slot(srv.SRV_ID, i)

				log.paranoid("  rdata for slot %s:%s", i, rdata)

				if rdata then
					local rslot = storage:deserialize_lua(rdata)

					log.paranoid("  rslot:%s", rslot)
					log.paranoid("  lslot:%s", lslot)

					if rslot and (not lslot or storage:get_slot_progress(lslot) < storage:get_slot_progress(rslot)) then
						log.debug("remote slot %s is further along", i)
						storage:save_slot(rslot, i)
					else
						log.debug("local slot %s is further along", i)
					end
				end
			end
		else
			success = false
			self.sync_times.slots = false
		end

		signal.emit(SGN_PS_SYNC_SLOTS_FINISHED, "cloudsave", success, req.id, status)
	end

	log.debug("synchronizing all slots")

	local rid = proxy.create_request_sync_slots(self.SRV_ID, {
		-1,
		-1,
		-1
	})

	if rid < 0 then
		log.error("error creating request to sync slots")

		return nil
	else
		self.prq:add(rid, "sync_slots", cb_sync_slots)

		return rid
	end
end

function srv:push_slot(idx, overwrite)
	local function cb_push_slot(status, req)
		if self.prq:contains(req.id) then
			local success = status == 0

			signal.emit(SGN_PS_PUSH_SLOT_FINISHED, "cloudsave", success, req.id, req.slot_idx)
		end
	end

	local slot = storage:load_slot(idx)

	if not slot then
		return nil
	end

	local progress = storage:get_slot_progress(slot)
	local slot_data = storage:serialize_lua(slot)

	log.debug("pushing slot:%s progress:%s", idx, progress)

	local rid = proxy.create_request_push_slot(self.SRV_ID, idx, storage:get_slot_name(idx), progress, slot_data, overwrite)

	if rid < 0 then
		log.error("error creating request to push slot %s", idx)

		return nil
	else
		local req = self.prq:add(rid, "push_slot", cb_push_slot)

		req.slot_idx = idx

		return rid
	end
end

function srv:delete_slot(idx)
	local function cb_delete_slot(status, req)
		if self.prq:contains(req.id) then
			local success = status == 0

			signal.emit(SGN_PS_DELETE_SLOT_FINISHED, "cloudsave", success, req.id, req.slot_idx)
		end
	end

	log.debug("deleting slot:%s", idx)

	local rid = proxy.create_request_delete_slot(self.SRV_ID, idx)

	if rid < 0 then
		log.error("error creating request to delete slot %s", idx)

		return nil
	else
		local req = self.prq:add(rid, "delete_slot", cb_delete_slot)

		req.slot_idx = idx

		return rid
	end
end

function srv:get_identity()
	return proxy.get_cloud_identity(self.SRV_ID)
end

function srv:push_file(name, data, overwrite)
	local function cb_push_file(status, req)
		if self.prq:contains(req.id) then
			local success = status == 0

			signal.emit(SGN_PS_PUSH_CLOUDFILE_FINISHED, "cloudfile", success, req.id, req.filename)
		end
	end

	log.debug("pushing file:%s", name)

	local sdata = storage:serialize_lua(data)
	local rid = proxy.create_request_push_cloud_file(self.SRV_ID, name, sdata, overwrite)

	if rid < 0 then
		log.error("error creating request to push file %s", name)

		return nil
	else
		local req = self.prq:add(rid, "push_file", cb_push_file)

		req.filename = name

		return rid
	end
end

function srv:delete_file(name)
	local function cb_delete_file(status, req)
		if self.prq:contains(req.id) then
			local success = status == 0

			signal.emit(SGN_PS_DELETE_CLOUDFILE_FINISHED, "cloudfile", success, req.id, req.filename)
		end
	end

	log.debug("deleting file:%s", name)

	local rid = proxy.create_request_delete_cloud_file(self.SRV_ID, name)

	if rid < 0 then
		log.error("error creating request to delete file %s", name)

		return nil
	else
		local req = self.prq:add(rid, "delete_file", cb_delete_file)

		req.filename = name

		return rid
	end
end

function srv:pull_file(name)
	local function cb_pull_file(status, req)
		if not self.prq:contains(req.id) then
			return
		end

		local success, data

		if status == 0 then
			success = true

			local rdata = proxy.get_cached_cloud_file(srv.SRV_ID, req.filename)

			log.paranoid("  rdata for filename %s:%s", req.filename, rdata)

			data = storage:deserialize_lua(rdata)
		else
			success = false
			data = nil
		end

		signal.emit(SGN_PS_PULL_CLOUDFILE_FINISHED, "cloudfile", success, req.id, req.filename, data)
	end

	log.debug("pull file:%s", name)

	local rid = proxy.create_request_pull_cloud_file(self.SRV_ID, name)

	if rid < 0 then
		log.error("error creating request to pull file %s", name)

		return nil
	else
		local req = self.prq:add(rid, "pull_file", cb_pull_file)

		req.filename = name

		return rid
	end
end

return srv
