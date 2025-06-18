-- chunkname: @./all/remote_balance_classes.lua

local log = require("klua.log"):new("remote_balance_classes")
local class = require("middleclass")

require("klove.kui")
require("klua.table")

local PS = require("platform_services")
local V = require("klua.vector")
local km = require("klua.macros")
local kui_db = require("klove.kui_db")
local font_db = require("klove.font_db")
local signal = require("hump.signal")
local wave_db = require("wave_db")

RBView = class("RBView", KView)
RBView.signal_handlers = {
	[SGN_PS_REMOTE_BALANCE_SYNC_STARTED] = function()
		local v = RBView.singleton

		if not v then
			return
		end

		v:show_progress()
	end,
	[SGN_PS_REMOTE_BALANCE_WAVES_CACHED] = function()
		local v = RBView.singleton

		if not v then
			return
		end

		v:refresh()
		v:hide_progress()
	end
}

function RBView:initialize(size, image_name)
	RBView.super.initialize(self, size, image_name)

	RBView.singleton = self
end

function RBView:show()
	for sn, fn in pairs(RBView.signal_handlers) do
		signal.register(sn, fn)
	end

	self.hidden = false

	local RB = PS.services.remote_balance

	if RB and RB:is_in_progress() then
		self:show_progress()
	else
		self:refresh()
		self:hide_progress()
	end
end

function RBView:hide()
	for sn, fn in pairs(self.signal_handlers) do
		signal.remove(sn, fn)
	end

	self.hidden = true
end

function RBView:show_progress()
	self:ci("rb_progress").hidden = false
	self:ci("rb_progress_error").text = ""
	self:ci("rb_ui").hidden = true
end

function RBView:hide_progress()
	self:ci("rb_progress").hidden = true
	self:ci("rb_ui").hidden = false
end

function RBView:refresh()
	local store = game.store

	if not store then
		log.error("game.store is not defined. bailing out")

		return
	end

	local RB = PS.services.remote_balance

	if not RB or not RB.inited then
		log.error("remote balance is not initialized. bailing out")

		return
	end

	do
		local el = self:ci("errors_list")

		el:clear_rows()

		local rows = {}

		if RB.sync_errors then
			for _, line in pairs(RB.sync_errors) do
				table.insert(rows, line)
			end
		end

		if wave_db.parse_errors then
			for _, line in pairs(wave_db.parse_errors) do
				table.insert(rows, line)
			end
		end

		local font_size = KE_CONST.font_size * 0.8
		local font = font_db:f(KE_CONST.font_name, font_size)
		local fh = font:getHeight()

		for i, line in ipairs(rows) do
			local lines_count = math.max(#string.split(line or "", "\n"), 1)
			local l = KLabel:new(V.v(el.size.x, fh * lines_count))

			l.font_size = font_size
			l.font_name = KE_CONST.font_name
			l.text = line
			l.text_align = "left"

			el:add_row(l)

			function l.on_click()
				for ci, crow in ipairs(el.children) do
					if ci == i then
						crow.colors.background = {
							0,
							0,
							0,
							40
						}
					else
						crow.colors.background = {
							0,
							0,
							0,
							0
						}
					end
				end
			end
		end
	end

	local pl = self:ci("waves_config_list")

	pl:clear_rows()

	local wi = RB.data.waves_index
	local wd = RB.data.waves_desc
	local wa = RB.data.waves
	local index = wi and wi[store.level_idx] and wi[store.level_idx][store.level_mode]

	if index then
		local rows_data = {}

		do
			local desc = string.format("local waves file included in build (%s)", store.level_name)

			if not store.current_wave_ss_name then
				desc = ">> " .. desc
			else
				desc = "   " .. desc
			end

			table.insert(rows_data, {
				data = "local",
				text = desc
			})
		end

		if index.default then
			local desc

			desc = not wa[index.default] and "[DEFAULT NOT CONFIGURED]" or "[DEFAULT] " .. index.default .. " : " .. (wd[index.default] or "")

			if store.current_wave_ss_name and store.current_wave_ss_name == index.default then
				desc = ">> " .. desc
			else
				desc = "   " .. desc
			end

			table.insert(rows_data, {
				data = index.default,
				text = desc
			})
		end

		if index.alternatives then
			for _, v in pairs(index.alternatives) do
				local desc

				desc = not wa[v] and "((SHEET NOT FOUND))" or v .. " : " .. (wd[v] or "")

				if store.current_wave_ss_name and store.current_wave_ss_name == v then
					desc = ">> " .. desc
				else
					desc = "   " .. desc
				end

				table.insert(rows_data, {
					data = v,
					text = desc
				})
			end
		end

		for i, row in ipairs(rows_data) do
			local lv = GGLabel:new(V.v(pl.size.x, KE_CONST.PROP_H * 1.1))

			pl:add_row(lv)

			lv.text_align = "left"
			lv.text = row.text
			lv.data = row.data
			lv.fit_size = true
			lv.font_size = KE_CONST.font_size
			lv.font_name = KE_CONST.font_name

			function lv.on_click(this)
				log.todo("selecting wave file %s", this.data)

				self.selected_data = this.data

				for ci, crow in ipairs(pl.children) do
					if ci == i then
						crow.colors.background = {
							0,
							0,
							0,
							40
						}
					else
						crow.colors.background = {
							0,
							0,
							0,
							0
						}
					end
				end
			end
		end
	end

	self:ci("rb_close").on_click = function(this)
		self:hide()
	end

	local function deselect_tabs()
		for _, c in pairs(self:ci("rb_tabs").children) do
			c:deactivate()
		end
	end

	local function show_tab(name)
		for _, c in pairs(self:ci("rb_ui").children) do
			if c.id ~= "rb_tabs" then
				c.hidden = c.id ~= name
			end
		end
	end

	deselect_tabs()

	for _, c in pairs(self:ci("rb_tabs").children) do
		if not self:ci(c.tab).hidden then
			c:activate()
		end

		function c.on_click(this)
			deselect_tabs()
			this:activate()
			show_tab(c.tab)
		end
	end

	self:ci("rb_reload").on_click = function(this)
		wave_db.parse_errors = nil

		RB:sync(true)
	end
	self:ci("rb_apply").on_click = function(this)
		if not self.selected_data or self.selected_data == "" then
			return
		end

		if self.selected_data == "local" then
			store.current_wave_ss_data = nil
			store.current_wave_ss_name = nil
		elseif self.selected_data and RB.data.waves[self.selected_data] then
			store.current_wave_ss_data = RB.data.waves[self.selected_data]
			store.current_wave_ss_name = self.selected_data

			log.todo("DATA:\n%s", RB.data.waves[self.selected_data])
		end

		self:hide()
		game:restart()
	end
end
