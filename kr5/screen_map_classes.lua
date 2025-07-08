local log = require("klua.log"):new("screen_map_classes")
local class = require("middleclass")

require("klua.table")

local km = require("klua.macros")
local V = require("klua.vector")

require("klove.kui")

local kui_db = require("klove.kui_db")
local E = require("entity_db")
local i18n = require("i18n")
local LU = require("level_utils")
local GS = require("game_settings")
local GU = require("gui_utils")
local PS = require("platform_services")
local S = require("sound_db")
local SU = require("screen_utils")
local SH = require("klove.shader_db")
local UPGR = require("upgrades")
local RC = require("remote_config")
local signal = require("hump.signal")
local storage = require("storage")
local U = require("utils")
local utf8_string = require("klove.utf8_string")
local achievements_data = require("data.achievements_data")
local balance = require("balance/balance")
local iap_data = require("data.iap_data")
local features = require("features")

require("constants")

RoomView = class("RoomView", KView)
RoomView.static.init_arg_names = {
	"size",
	"image_name",
	"base_scale"
}
RoomView.static.base_scale = nil

function RoomView:initialize(size, image_name, base_scale)
	RoomView.super.initialize(self, size, image_name)

	self.base_scale = base_scale or RoomView.static.base_scale or V.v(1, 1)
	self.propagating = false
	self.propagate_on_click = false
	self.trans_scale_min_amp = 0.82
	self.trans_scale_max_amp = 1.03
	self.trans_slide_in_amp = 60
	self.trans_slide_out_amp = 30

	if not self.content_id then
		log.error("RoomView %s has no content_id value", self.id)
	end

	if not self.background_id then
		log.error("RoomView %s has no background_id value", self.id)
	end

	for _, view in pairs(self:get_child_by_id(self.content_id).children) do
		view.alpha = 0
	end
end

function RoomView:destroy()
	RoomView.super.destroy(self)
end

function RoomView:update(dt)
	if self.hidden then
		return
	end

	RoomView.super.update(self, dt)

	if self._timer then
		local slow_factor = DEBUG_TIMER_SLOW_FACTOR or 1

		self._timer:update(dt / slow_factor)
	end
end

function RoomView:show(done_callback)
	self.done_callback = done_callback

	local ktw = self:get_window().ktw

	local function fade_in(v, delay)
		v.hidden = false

		ktw:cancel(v)
		ktw:tween(v, 0.1, v, {
			alpha = 1
		}, "in-quad")
	end

	local function slide_in(view, vect, delay)
		ktw:cancel(view)

		local pos_shown = view.pos_shown

		view.pos.x = pos_shown.x - vect.x
		view.pos.y = pos_shown.y - vect.y
		delay = delay or 0.016666666666666666

		ktw:script(view, function(wait)
			wait(delay)
			ktw:tween(view, 0.11666666666666667, view, {
				alpha = 1
			}, "out-quad")
			ktw:tween(view, 0.11666666666666667, view.pos, {
				x = view.pos_shown.x + 0.08 * vect.x,
				y = view.pos_shown.y + 0.08 * vect.y
			}, "out-quad", function()
				ktw:tween(view, 0.03333333333333333, view.pos, {
					x = view.pos_shown.x,
					y = view.pos_shown.y
				}, "out-quad", function()
					view.pos.x = view.pos_shown.x
					view.pos.y = view.pos_shown.y
				end)
			end)
		end)
	end

	local function scale_in(view, min_scale, max_scale, delay)
		if not view.scale_shown then
			view.scale_shown = V.vclone(view.scale)
		end

		ktw:cancel(view)

		view.scale.x = view.scale_shown.x * min_scale
		view.scale.y = view.scale_shown.y * min_scale
		view.alpha = 0

		ktw:script(view, function(wait)
			wait(delay)
			ktw:tween(view, 0.11666666666666667, view, {
				alpha = 1
			}, "out-quad")
			ktw:tween(view, 0.11666666666666667, view.scale, {
				x = view.scale_shown.x * max_scale,
				y = view.scale_shown.y * max_scale
			}, "out-quad", function()
				ktw:tween(view, 0.03333333333333333, view.scale, {
					x = view.scale_shown.x,
					y = view.scale_shown.y
				}, "out-quad", function()
					view.scale.x = view.scale_shown.x
					view.scale.y = view.scale_shown.y
				end)
			end)
		end)
	end

	if self.content_id then
		local delay_acc = 0
		local delay_inc = 0.016666666666666666

		for _, view in pairs(self:get_child_by_id(self.content_id).children) do
			if view.transition and not view.pos_shown then
				view.pos_shown = V.vclone(view.pos)
			end

			local slide_amp = self.trans_slide_in_amp
			local slide_v, scale_b

			if view.transition == "left" then
				slide_v = V.v(-slide_amp, 0)
			elseif view.transition == "right" then
				slide_v = V.v(slide_amp, 0)
			elseif view.transition == "up" then
				slide_v = V.v(0, -slide_amp)
			elseif view.transition == "down" then
				slide_v = V.v(0, slide_amp)
			elseif view.transition == "scale" then
				scale_b = true
			end

			local delay = delay_acc

			if view.transition_delay then
				delay = view.transition_delay + delay_inc
			else
				delay_acc = delay_acc + delay_inc
			end

			if view.pos_shown then
				view.pos.x = view.pos_shown.x
				view.pos.y = view.pos_shown.y
			end

			if scale_b then
				scale_in(view, self.trans_scale_min_amp, self.trans_scale_max_amp, delay)
			elseif slide_v then
				slide_in(view, slide_v, delay)
			else
				view.alpha = 1
			end
		end

		self.hidden = false
		self.alpha = 1
	end

	if self.background_id then
		self:get_window():ci(self.background_id):show(self.background_params, self)
	end

	local w = self:get_window()

	if w then
		if w.responder and w.responder ~= w then
			self._last_responder = w.responder
		end

		w:set_responder(self)

		if w.focused then
			self._last_focused = w.focused
		end
	end

	local initial_focus = self.initial_focus_id and self:get_child_by_id(self.initial_focus_id)

	log.debug("self.initial_focus_id:%s -> %s", self.initial_focus_id, initial_focus)

	if initial_focus then
		log.debug("focusing: %s", initial_focus)
		initial_focus:focus(true)
	end
end

function RoomView:hide()
	local ktw = self:get_window().ktw

	local function fade_out(v)
		ktw:cancel(v)
		ktw:tween(v, 0.16666666666666666, v, {
			alpha = 0
		}, "in-quad", function()
			v.hidden = true

			if v.done_callback then
				v.done_callback()
			end
		end)
	end

	local function slide_out(view, vect, delay)
		ktw:cancel(view)

		local pos_shown = V.vclone(view.pos)

		ktw:script(view, function(wait)
			ktw:tween(view, 0.016666666666666666, view.pos, {
				x = pos_shown.x - 0.1 * vect.x,
				y = pos_shown.y - 0.1 * vect.y
			}, "in-quad")
			wait(0.016666666666666666)
			ktw:tween(view, 0.08333333333333333, view, {
				alpha = 0
			}, "in-quad")
			ktw:tween(view, 0.08333333333333333, view.pos, {
				x = pos_shown.x + 1 * vect.x,
				y = pos_shown.y + 1 * vect.y
			}, "in-quad")
		end)
	end

	if self.content_id then
		local slide_v = V.v(0, self.trans_slide_out_amp)

		for _, view in pairs(self:ci(self.content_id).children) do
			if view.transition then
				slide_out(view, slide_v)
			end
		end

		fade_out(self)
	end

	if self.background_id then
		self:get_window():ci(self.background_id):hide()
	end

	local w = self:get_window()

	if w then
		if self._last_focused then
			self._last_focused:focus(true)

			self._last_focused = nil
		end

		w:set_responder(self._last_responder or w)

		self._last_responder = nil
	end
end

RoomBackgroundView = class("RoomBackgroundView", KView)

function RoomBackgroundView:initialize(size, image_name)
	RoomBackgroundView.super.initialize(self, size, image_name)

	if self.exo_animations and type(self.exo_animations) == "table" then
		for _, c in pairs(self.children) do
			if c.class == GGExo then
				self.exo = c

				break
			end
		end
	end

	self.propagate_drag = false
	self.propagate_on_down = false
	self.propagate_on_touch_move = false
	self.propagate_on_touch_down = false
	self.propagate_on_enter = false

	if self.block_id then
		local block = self:ci(self.block_id)

		if block then
			function block.on_click(this)
				this:get_window():focus_view(nil)
			end
		end
	end
end

function RoomBackgroundView:destroy()
	RoomBackgroundView.super.destroy(self)
end

function RoomBackgroundView:update(dt)
	RoomBackgroundView.super.update(self, dt)

	if self._timer then
		local slow_factor = DEBUG_TIMER_SLOW_FACTOR or 1

		self._timer:update(dt / slow_factor)
	end
end

function RoomBackgroundView:show()
	if self.exo and self.exo_animations then
		self.exo.ts = -0.08
		self.exo.loop = false
		self.exo.exo_animation = self.exo_animations[1]

		function self.exo.on_exo_finished(this, runs)
			if this.exo_animation == self.exo_animations[1] then
				this.exo_animation = self.exo_animations[2]
				this.ts = 0
				this.loop = true
			end
		end
	end

	self.hidden = false

	local ktw = self:get_window().ktw

	ktw:cancel(self)
	ktw:tween(self, 0.1, self, {
		alpha = 1
	}, "out-quad")
end

function RoomBackgroundView:hide()
	if self.exo and self.exo_animations then
		self.exo.exo_animation = self.exo_animations[3]
		self.exo.ts = 0
		self.exo.loop = false
		self.exo.on_exo_finished = nil
	end

	local ktw = self:get_window().ktw

	ktw:cancel(self)
	ktw:tween(self, 0.3333333333333333, self, {
		alpha = 0
	}, "out-linear", function()
		self.hidden = true
	end)
end

HeroRoomView = class("HeroRoomView", RoomView)

function HeroRoomView.static:get_hero_level(xp)
	local level, factor = 1, 0

	while level < 10 and xp >= GS.hero_xp_thresholds[level] do
		level = level + 1
	end

	if level > #GS.hero_xp_thresholds then
		factor = 1
	elseif xp == GS.hero_xp_thresholds[level] then
		factor = 0
	else
		local this_xp = GS.hero_xp_thresholds[level - 1] or 0
		local next_xp = GS.hero_xp_thresholds[level]

		factor = (xp - this_xp) / (next_xp - this_xp)
	end

	return level, factor
end

function HeroRoomView.static:get_hero_stats(hero_name)
	local damage_icons = {
		default = "heroroom_attackIcons_0001",
		magic = "heroroom_attackIcons_0002",
		sword = "heroroom_attackIcons_0001",
		fireball = "heroroom_attackIcons_0004",
		arrow = "heroroom_attackIcons_0003",
		shot = "heroroom_attackIcons_0001"
	}
	local user_data = storage:load_slot()
	local out = {}
	local status = user_data.heroes.status[hero_name]
	local data = screen_map.hero_data[hero_name]
	local h = E:create_entity(hero_name)

	if not h then
		log.error("hero %s not found in templates", hero_name)

		return nil
	end

	h.hero.xp = status.xp

	local level, level_progress = HeroRoomView:get_hero_level(h.hero.xp)

	h.hero.level = level

	if h.hero.level < data.starting_level then
		h.hero.level = data.starting_level
		h.hero.xp = GS.hero_xp_thresholds[h.hero.level]
	end

	out.skill_names = {}

	local used_points = 0

	for k, v in pairs(status.skills) do
		if not h.hero.skills[k] then
			log.error("skill %s from slot missing in hero %s template.", k, hero_name)
		else
			h.hero.skills[k].level = v
			out.skill_names[h.hero.skills[k].hr_order] = k

			for j = 1, v do
				used_points = used_points + h.hero.skills[k].hr_cost[j]
			end
		end
	end

	used_points = used_points - 1
	out.skill_names[5] = "ultimate"

	h.hero.fn_level_up(h, {}, true)

	local info = h.info.fn(h)
	local key = h.info.i18n_key or string.upper(hero_name)

	out.new_hero = false

	local last_level_won = 1

	for i, v in ipairs(user_data.levels) do
		if v.stars ~= nil then
			last_level_won = i
		else
			break
		end
	end

	local hd = screen_map.hero_data[hero_name]

	out.unlocked = false

	if hd and screen_map:is_content_stage_unlocked(hd, user_data) then
		if not screen_map:is_seen(hero_name) then
			out.new_hero = true
		end

		out.unlocked = true
	elseif hd and not hd.available_at_stage then
		out.unlocked = true
	end

	out.hero_class = _(key .. "_CLASS")
	out.hero_name = _(key .. "_NAME")
	out.hero_desc = _(key .. "_DESC")
	out.level = h.hero.level
	out.xp = h.hero.xp
	out.level_progress = level_progress
	out.taunt = h.sound_events.hero_room_select
	out.health = info.hp_max
	out.damage = info.damage_min .. " - " .. info.damage_max
	out.damage_min = info.damage_min
	out.damage_max = info.damage_max
	out.armor = GU.armor_value_desc(info.armor)
	out.armor_value = info.armor
	out.attack_rate = _(key .. "_ATTACKRATE")
	out.damage_icon = h.info.damage_icon or "default"
	out.damage_icon_name = damage_icons[out.damage_icon]
	out.skills = h.hero.skills
	out.remaining_points = GS.skill_points_for_hero_level[h.hero.level] - used_points
	out.respawn_time = h.health.dead_lifetime
	out.stats = {}
	out.stats.hp = h.info.stat_hp
	out.stats.armor = h.info.stat_armor
	out.stats.damage = h.info.stat_damage
	out.stats.cooldown = h.info.stat_cooldown

	return out
end

function HeroRoomView.static:get_hero_stats_range(heroes)
	local ranges = {
		health = {
			1e+99,
			0
		},
		armor_value = {
			0,
			1
		},
		damage_max = {
			1e+99,
			0
		},
		respawn_time = {
			0,
			0
		}
	}

	for _, hero_name in pairs(heroes) do
		local stats = HeroRoomView:get_hero_stats(hero_name)

		if not stats then
			-- block empty
		else
			for k, v in pairs(ranges) do
				v[1] = math.min(v[1], stats[k])
				v[2] = math.max(v[2], stats[k])
			end
		end
	end

	return ranges
end

function HeroRoomView.static:is_new_hero_available()
	if DBG_SHOW_BALLOONS then
		log.error("DBG_SHOW_BALLOONS is on!")

		return true
	end

	for k, v in pairs(screen_map.hero_data) do
		local stats = HeroRoomView:get_hero_stats(k)

		if stats.new_hero then
			return true
		end
	end

	return false
end

function HeroRoomView.static:has_hero_points_to_spend()
	local user_data = storage:load_slot()

	for _, v in ipairs(user_data.heroes.team) do
		local stats = HeroRoomView:get_hero_stats(v)

		if stats.remaining_points > 0 then
			for i, s in pairs(stats.skills) do
				if s.level < 3 and s.hr_cost[s.level + 1] <= stats.remaining_points then
					return true
				end
			end
		end
	end

	return false
end

function HeroRoomView:initialize(size, image_name, base_scale)
	HeroRoomView.super.initialize(self, size, image_name, base_scale)

	self.overlay = self:ci("hero_room_roster_sel_overlay")
	self.overlay.colors = {
		background = {
			0,
			0,
			0,
			150
		}
	}
	self.overlay.hidden = true
	self.overlay.propagate_drag = false
	self.overlay.propagate_on_down = false
	self.overlay.propagate_on_touch_move = false
	self.overlay.propagate_on_touch_down = false
	self.overlay.propagate_on_enter = false

	function self.overlay.on_click(this)
		self:pick_team_slot_stop()
	end

	if self.base_scale.y ~= 1 then
		self.overlay.scale = V.v(3, 3)
		self.overlay.anchor.x = self.overlay.size.x / 2
		self.overlay.anchor.y = self.overlay.size.y / 2
		self.overlay.pos.x = 0
		self.overlay.pos.y = 0
	end

	self:ci("hero_room_done_button"):ci("label_button_room_small").text = _("BUTTON_DONE")
	self:ci("hero_room_done_button").on_click = function(this)
		S:queue("GUIButtonOut")
		self:hide()
	end

	if not self.initial_focus_id then
		self.initial_focus_id = "hero_room_done_button"
	end

	self:ci("hero_room_reset_button"):ci("label_button_room_small").text = _("BUTTON_RESET")
	self:ci("hero_room_reset_button").on_click = function(this)
		S:queue("GUIResetUpgrade")

		local hr = this:get_parent_of_class(HeroRoomView)

		hr:reset_skills(hr:get_skill_items())
		this:disable()
	end

	if self:ci("button_close_popup") then
		self:ci("button_close_popup").on_click = function(this)
			S:queue("GUIButtonOut")
			self:hide()
		end
	end

	self:ci("button_hero_room_big_buy").on_click = function(this)
		S:queue("GUIBuyUpgrade")
		this:get_parent_of_class(HeroRoomView):buy_iap()
	end
	self:ci("button_hero_room_big_select").on_click = function(this)
		S:queue("GUIButtonCommon")
		this:get_parent_of_class(HeroRoomView):pick_team_slot_start()
	end

	self:update_hero_data()

	local owned_dlcs = PS.services.iap and PS.services.iap:get_dlcs(true) or {}

	if not IS_MOBILE then
		local hr = self:ci("hero_room_heroes")
		local ctx = SU.new_screen_ctx(screen_map)

		for i = 1, #screen_map.hero_order do
			local bp = hr:ci(string.format("button_hero_roster_%02i", i))

			if not bp then
				log.error("There are not enough buttons for all the heroes. %s", i)
			else
				local tt = kui_db:get_table("button_hero_roster_thumb_desktop", ctx)
				local hs = HeroSliderItemView:new_from_table(tt)
				local n = screen_map.hero_order[i]

				hs:set_hero(n)

				hs.pos = bp.pos
				hs.id = bp.id

				hr:add_child(hs)

				local dlc_p = PS.services.iap and PS.services.iap:get_container_dlc(n) or nil

				for _, v in pairs(GS.dlc_names) do
					hs:ci("image_" .. v.id .. "_badge_small").hidden = not dlc_p or dlc_p.id ~= v.id or dlc_p.owned
				end

				bp.hidden = true

				bp:remove_from_parent()
			end
		end
	else
		local hrh = self:ci("hero_room_heroes")

		hrh.clip = true

		local hsl = KInertialView:new()

		hsl.id = "hero_room_heroes_slider"
		hsl.size = table.deepclone(hrh.size)
		hsl.size.x = hsl.size.x
		hsl.pos = table.deepclone(hrh.pos)
		hsl.can_drag = true
		hsl.inertia_damping = 0.8
		hsl.inertia_stop_speed = 0.01

		hrh:add_child(hsl)

		local ctx = SU.new_screen_ctx(screen_map)
		local hs_width = 0
		local hslb = hsl:get_bounds_rect(true)
		local fade_s = hsl:view_to_screen(hslb.pos.x, hslb.pos.y)
		local fade_f = hsl:view_to_screen(hslb.pos.x + hslb.size.x, hslb.pos.y)
		local gradient = 0

		for i, n in ipairs(screen_map.hero_order) do
			local tt = kui_db:get_table("button_hero_roster_thumb", ctx)
			local hs = HeroSliderItemView:new_from_table(tt)

			hs:set_hero(n)

			hs.pos.x = (i - 1) * (hs.size.x + 1) + hs.size.x / 2
			hs.pos.y = hsl.size.y / 2

			hsl:add_child(hs)

			hs_width = hs.size.x

			local dlc_p = PS.services.iap and PS.services.iap:get_container_dlc(n) or nil

			for _, v in pairs(GS.dlc_names) do
				hs:ci("image_" .. v.id .. "_badge_small").hidden = not dlc_p or dlc_p.id ~= v.id or dlc_p.owned
			end
		end

		local drag_width = hsl.size.x - #screen_map.hero_order * (hs_width + 1)

		drag_width = drag_width > 0 and 0 or drag_width
		hsl.drag_limits = V.r(0, 0, drag_width, 0)
		hsl.elastic_limits = V.r(hs_width, 0, drag_width - 2 * hs_width, 0)

		local hrs_count = #screen_map.hero_order + 2
		local hrs_w = hsl.size.x + 1

		hsl.size.x = hrs_w * hrs_count
	end

	local user_data = storage:load_slot()

	self.roster_sel_items = {
		self:ci("group_hero_roster_sel"):ci("button_hero_roster_sel_01"),
		self:ci("group_hero_roster_sel"):ci("button_hero_roster_sel_02")
	}
	self.roster_sel_positions = {
		V.vclone(self.roster_sel_items[1].pos),
		V.vclone(self.roster_sel_items[2].pos)
	}

	self.roster_sel_items[1]:set_hero(user_data.heroes.team[1], true)
	self.roster_sel_items[2]:set_hero(user_data.heroes.team[2], true)

	if not HeroRoomView:get_hero_stats("hero_raelyn").unlocked then
		self.roster_sel_items[2]:set_locked()
	end

	for i = 1, #GS.dlc_names do
		self.roster_sel_items[1]:ci("image_dlc_" .. i .. "_badge_small").hidden = true
		self.roster_sel_items[2]:ci("image_dlc_" .. i .. "_badge_small").hidden = true
	end

	self:ci("hero_room_skill_tooltip").hidden = true
	self:ci("group_dlc_tooltip").hidden = true

	for _, v in pairs(GS.dlc_names) do
		self:ci("image_" .. v.id .. "_badge_big").on_enter = function(this)
			self:hide_skill_tooltip()
			self:show_dlc_tooltip(v.id)
		end
		self:ci("image_" .. v.id .. "_badge_big").on_exit = function(this)
			self:hide_dlc_tooltip()
		end
	end

	local hrpf = self:ci("hero_room_portrait_flash")

	hrpf.propagate_on_down = true
	hrpf.propagate_on_up = true
	hrpf.propagate_on_click = true
	hrpf.propagate_drag = true
	hrpf.alpha = 0
	hrpf.colors.background = {
		255,
		255,
		255,
		255
	}

	for i = 1, 4 do
		self:ci("hero_stat_icon_" .. i).pos.x = self:ci("hero_stat_icon_" .. i).pos.x + 4
		self:ci("hero_stat_icon_" .. i).pos.y = self:ci("hero_stat_icon_" .. i).pos.y + 4
	end

	self:ci("hero_room_cheat_level").hidden = false
	self:ci("hero_room_cheat_level").on_click = function(this)
		local slider = self:ci("hero_room_heroes_slider")
		local hero_name = self.hero_shown

		if not hero_name then
			log.error("no hero name")

			return
		end

		local user_data = storage:load_slot()
		local hero = user_data.heroes.status[hero_name]
		local level, _ = HeroRoomView:get_hero_level(hero.xp)
		local new_xp = 0

		level = level + 1

		if level > 10 then
			-- block empty
		else
			new_xp = GS.hero_xp_thresholds[level - 1]
		end

		hero.xp = new_xp

		storage:save_slot(user_data)
		self:show_hero(hero_name, true)
	end
end

function HeroRoomView:destroy()
	HeroRoomView.super.destroy(self)
end

function HeroRoomView:show(show_hero_name, just_purchased)
	HeroRoomView.super.show(self)

	local hero_room = self

	self:get_window():ci(self.background_id).on_click = function(this)
		if not self.hidden then
			hero_room:hide()
		end
	end

	local preload_open = show_hero_name == false
	local user_data = storage:load_slot()

	show_hero_name = show_hero_name or user_data.heroes.team[1]

	if IS_MOBILE then
		local hsl = self:ci("hero_room_heroes_slider")

		for k, v in pairs(hsl.children) do
			v:update_discount()
		end
	end

	self:show_hero(show_hero_name)

	if not preload_open and not screen_map:is_seen("tutorial_hero_room") or DBG_SHOW_BALLOONS then
		screen_map:set_seen("tutorial_hero_room")

		local ktw = self:get_window().ktw

		local function fade_in(v, delay)
			v.hidden = false

			ktw:cancel(v)
			ktw:tween(v, delay, v, {
				alpha = 1
			}, "in-quad")
		end

		local function fade_out(v, delay)
			v.hidden = false

			ktw:cancel(v)
			ktw:tween(v, delay, v, {
				alpha = 0
			}, "in-quad")
		end

		local function scale_in(view, min_scale, max_scale, delay)
			if not view.scale_shown then
				view.scale_shown = V.vclone(view.scale)
			end

			ktw:cancel(view)

			view.scale.x = view.scale_shown.x * min_scale
			view.scale.y = view.scale_shown.y * min_scale
			view.alpha = 0

			ktw:script(view, function(wait)
				wait(delay)
				ktw:tween(view, 0.11666666666666667, view, {
					alpha = 1
				}, "out-quad")
				ktw:tween(view, 0.11666666666666667, view.scale, {
					x = view.scale_shown.x * max_scale,
					y = view.scale_shown.y * max_scale
				}, "out-quad", function()
					ktw:tween(view, 0.03333333333333333, view.scale, {
						x = view.scale_shown.x,
						y = view.scale_shown.y
					}, "out-quad", function()
						view.scale.x = view.scale_shown.x
						view.scale.y = view.scale_shown.y
					end)
				end)
			end)
		end

		local sw, sh = screen_map.sw, screen_map.sh

		self.tutorial_overlay = KView:new(V.v(sw * 2, sh * 2))
		self.tutorial_overlay.colors = {
			background = {
				0,
				0,
				0,
				140
			}
		}
		self.tutorial_overlay.alpha = 0
		self.tutorial_overlay.pos.x, self.tutorial_overlay.pos.y = -sw / 2, 0
		self.tutorial_overlay.propagate_on_click = true
		self.tutorial_overlay.propagate_drag = false
		self.tutorial_overlay.propagate_on_enter = false
		self.tutorial_overlay.propagate_on_exit = false
		self.can_close_tutorial = false

		table.insert(self:ci("group_hero_room_tutorial_overlay").children, self.tutorial_overlay)

		self:ci("group_hero_room_tutorial").hidden = false
		self:ci("group_hero_room_tutorial").alpha = 0

		for _, v in ipairs(self:ci("group_hero_room_tutorial").children) do
			v.propagate_on_click = true
			v.propagate_on_touch_down = true
			v.propagate_on_touch_up = true

			for _, v2 in ipairs(v.children) do
				v2.propagate_on_click = true
				v2.propagate_on_touch_down = true
				v2.propagate_on_touch_up = true
			end
		end

		ktw:script(self, function(wait)
			screen_map:set_modal_view(self.tutorial_overlay)
			fade_in(self.tutorial_overlay, 0.5)
			fade_in(self:ci("group_hero_room_tutorial"), 0.5)

			for _, v in ipairs(self:ci("group_hero_room_tutorial").children) do
				scale_in(v, 0.9, 1.1, 0.5)
			end

			wait(0.5)

			self.can_close_tutorial = true
		end)

		function self.tutorial_overlay.on_click(this)
			this:hide()
		end

		function self.tutorial_overlay.hide(this)
			if self.can_close_tutorial then
				self.can_close_tutorial = false

				ktw:script(self, function(wait)
					screen_map:remove_modal_view()
					fade_out(self.tutorial_overlay, 0.5)
					fade_out(self:ci("group_hero_room_tutorial"), 0.5)
					wait(0.5)

					self.tutorial_overlay.hidden = true
					self:ci("group_hero_room_tutorial").hidden = true
				end)
			end
		end
	end

	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = true
	end
end

function HeroRoomView:hide()
	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = false
	end

	HeroRoomView.super.hide(self)

	self:get_window():ci(self.background_id).on_click = nil

	self:hide_skill_tooltip()
	self:hide_dlc_tooltip()
	screen_map:update_badges()
end

function HeroRoomView:tooltip_hidden()
	local t = self:ci("hero_room_skill_tooltip")

	return t.hidden
end

function HeroRoomView:show_skill_tooltip(item)
	local t = self:ci("hero_room_skill_tooltip")

	self:ci("label_hero_room_skill_tooltip_title").text = item.title
	self:ci("label_hero_room_skill_tooltip_desc").text = GU.balance_format(item.desc, balance)

	for i = 1, 5 do
		self:ci("hero_room_skill_tooltip_arrow_" .. i).hidden = i ~= item.idx
	end

	local function show_tooltip(ktw)
		t.hidden = false

		ktw:cancel(t)
		ktw:cancel(self:ci("label_hero_name"))
		ktw:cancel(self:ci("label_hero_desc"))

		t.scale = {
			x = 0.77,
			y = 0.77
		}
		t.alpha = 0.74

		ktw:tween(t, 0.233, nil, {
			alpha = 1,
			scale = {
				x = 1,
				y = 1
			}
		}, "out-back")

		local talpha = 0.4

		ktw:tween(self:ci("label_hero_name"), 0.1, nil, {
			alpha = talpha
		})
		ktw:tween(self:ci("label_hero_desc"), 0.1, nil, {
			alpha = talpha
		})
	end

	local ktw = self:get_window().ktw

	if not t.hidden then
		t.alpha = 0
		t.hidden = true
	end

	local title = self:ci("label_hero_room_skill_tooltip_title")
	local description = self:ci("label_hero_room_skill_tooltip_desc")
	local background = self:ci("hero_room_skill_tooltip_bg")

	title.fit_size = false
	description.fit_size = false

	local tw_title, twc_title = title:get_wrap_lines()
	local font_height_title = title:get_font_height()
	local tw_description, twc_description = description:get_wrap_lines()
	local font_height_description = description:get_font_height()
	local blank_space = font_height_description

	background.size.y = twc_description * font_height_description + twc_title * font_height_title + blank_space
	background.anchor_factor.x = background.anchor.x / background.size.x
	background.anchor_factor.y = background.size.y / background.size.y
	background.anchor.y = background.size.y
	background.pos.y = 73

	background:redraw()

	title.anchor.y = background.size.y
	title.pos.y = 83
	description.anchor.y = background.size.y
	description.pos.y = 85 + twc_title * font_height_title

	show_tooltip(ktw)

	if self.focus_image then
		self.focus_image.hidden = false
	end
end

function HeroRoomView:hide_skill_tooltip()
	local t = self:ci("hero_room_skill_tooltip")
	local lhn = self:ci("label_hero_name")
	local lhd = self:ci("label_hero_desc")
	local ktw = self:get_window().ktw

	ktw:cancel(t)
	ktw:cancel(lhn)
	ktw:cancel(lhd)

	t._hiding = true

	ktw:tween(t, 0.1, nil, {
		alpha = 0
	}, "in-quad", function()
		t.hidden = true
	end)
	ktw:after(lhn, 0.2, function()
		ktw:tween(lhn, 0.2, lhn, {
			alpha = 1
		}, "in-quad")
	end)
	ktw:after(lhd, 0.2, function()
		ktw:tween(lhd, 0.2, lhd, {
			alpha = 1
		}, "in-quad")
	end)

	if self.focus_image then
		self.focus_image.hidden = true
	end
end

function HeroRoomView:show_dlc_tooltip(dlc)
	local t = self:ci("group_dlc_tooltip")

	t:ci("label_info_tooltip_title").text = _("HERO_ROOM_DLC_BADGE_TOOLTIP_TITLE_KR5_" .. string.upper(dlc))
	t:ci("label_info_tooltip_desc").text = _("HERO_ROOM_DLC_BADGE_TOOLTIP_DESC_KR5_" .. string.upper(dlc))
	t:ci("image_mode_tooltip_arrow").hidden = false

	local ktw = self:get_window().ktw

	if not t.hidden then
		t.alpha = 0
	end

	t.hidden = false

	ktw:cancel(t)
	ktw:cancel(self:ci("label_hero_name"))
	ktw:cancel(self:ci("label_hero_desc"))

	t.scale = {
		x = 0.77,
		y = 0.77
	}
	t.alpha = 0.74

	ktw:tween(t, 0.233, nil, {
		alpha = 1,
		scale = {
			x = 1,
			y = 1
		}
	}, "out-back")

	local talpha = 0.4

	ktw:tween(self:ci("label_hero_name"), 0.1, nil, {
		alpha = talpha
	})
	ktw:tween(self:ci("label_hero_desc"), 0.1, nil, {
		alpha = talpha
	})
end

function HeroRoomView:hide_dlc_tooltip()
	local t = self:ci("group_dlc_tooltip")
	local lhn = self:ci("label_hero_name")
	local lhd = self:ci("label_hero_desc")
	local ktw = self:get_window().ktw

	ktw:cancel(t)
	ktw:cancel(lhn)
	ktw:cancel(lhd)
	ktw:tween(t, 0.1, nil, {
		alpha = 0
	}, "in-quad", function()
		t.hidden = true
	end)
	ktw:after(lhn, 0.2, function()
		ktw:tween(lhn, 0.2, lhn, {
			alpha = 1
		}, "in-quad")
	end)
	ktw:after(lhd, 0.2, function()
		ktw:tween(lhd, 0.2, lhd, {
			alpha = 1
		}, "in-quad")
	end)
end

function HeroRoomView:show_hero(hero_name, flash)
	self.hero_shown = hero_name

	local heroes_on_sale = PS.services.iap and PS.services.iap:get_hero_sales() or {}
	local user_data = storage:load_slot()
	local stats = HeroRoomView:get_hero_stats(hero_name)
	local hd = screen_map.hero_data[hero_name]
	local ht = E:get_template(hero_name)
	local ktw = self:get_window().ktw

	self:ci("label_hero_level").text = stats.level
	self:ci("hero_xp_bar").scale.x = stats.level_progress

	if ht.hero.team == TEAM_LINIREA then
		self:ci("image_heroroom_goodside").hidden = false
		self:ci("image_heroroom_badside").hidden = true
	else
		self:ci("image_heroroom_goodside").hidden = true
		self:ci("image_heroroom_badside").hidden = false
	end

	if IS_MOBILE then
		self:ci("group_sale_label_big").hidden = true
	end

	self:ci("hero_stat_icon_1"):set_image("heroroom_stats_icons_0001")
	self:ci("hero_stat_icon_2"):set_image("heroroom_stats_icons_0002")
	self:ci("hero_stat_icon_3"):set_image("heroroom_stats_icons_000" .. (stats.damage_icon == "magic" and "5" or "3"))
	self:ci("hero_stat_icon_4"):set_image("heroroom_stats_icons_0004")

	local function scale_stat_bar(id, value)
		ktw:cancel(self:ci(id))
		ktw:tween(self:ci(id), 0.2, nil, {
			scale = {
				y = 1,
				x = value
			}
		})
	end

	local stat_index = 1

	scale_stat_bar("hero_stat_bar_1", stats.stats.hp / 10)
	scale_stat_bar("hero_stat_bar_2", stats.stats.armor / 10)
	scale_stat_bar("hero_stat_bar_3", stats.stats.damage / 10)
	scale_stat_bar("hero_stat_bar_4", stats.stats.cooldown / 10)

	self:ci("label_hero_name").text = stats.hero_name
	self:ci("label_hero_desc").text = stats.hero_desc

	self:ci("hero_room_portrait"):set_image(string.format("hero_room_portraits_big_%s_0001", hero_name))

	for _, v in pairs(self:get_slider_items()) do
		if v.focus_image then
			if v.hero_name == hero_name then
				v.focus_image.hidden = false
			else
				v.focus_image.hidden = true
			end
		end
	end

	if flash then
		local v = self:ci("hero_room_portrait_flash")

		ktw:cancel(v)

		v.alpha = 1

		ktw:tween(v, flash == "long" and 0.8 or 0.2, v, {
			alpha = 0
		}, "in-quad")
		self:get_slider_item(hero_name):flash()
	end

	self:ci("hero_room_reset_button"):disable()

	local skill_views = self:ci("group_hero_room_skills").children

	for i, n in ipairs(stats.skill_names) do
		skill_views[i]:load(hero_name, n, stats.skills[n], stats.remaining_points, i)
	end

	self:ci("label_heropoints").text = stats.remaining_points

	for _, v in pairs(self:get_slider_items()) do
		if v.check_image then
			v.check_image.hidden = not table.contains(user_data.heroes.team, v.hero_name) or not HeroRoomView:get_hero_stats(v.hero_name).unlocked
		end
	end

	if stats.new_hero then
		screen_map:set_seen(hero_name)
	end

	local product = hd.iap and PS.services.iap and PS.services.iap:get_product(hero_name)
	local premium, exceptions = PS.services.iap:is_premium()

	self:ci("button_hero_room_big_disabled").hidden = true
	self:ci("button_hero_room_big_locked").hidden = true
	self:ci("button_hero_room_big_buy").hidden = true
	self:ci("button_hero_room_big_select").hidden = true
	self:ci("button_hero_room_big_disabled"):ci("label_button_selected").text = _("MAP_HERO_ROOM_SELECTED")
	self:ci("button_hero_room_big_select"):ci("label_button_select").text = _("MAP_HERO_ROOM_SELECT")

	self:ci("button_hero_room_big_disabled"):disable(false)
	self:ci("button_hero_room_big_locked"):disable(false)

	if #user_data.levels <= 2 and hero_name == "hero_raelyn" then
		if not hd.available_at_stage then
			signal.emit("debug-event", "missing_available_at_stage", hero_name)
		end

		self:ci("button_hero_room_big_locked").hidden = false
		self:ci("label_button_locked").text = string.format(_("MAP_HERO_ROOM_UNLOCK"), hd.available_at_stage or 0)
	elseif user_data.heroes.team and table.contains(user_data.heroes.team, hero_name) then
		self:ci("button_hero_room_big_disabled").hidden = false
	elseif not screen_map:is_content_stage_unlocked(hd, user_data) then
		self:ci("button_hero_room_big_locked").hidden = false

		if hd.available_at_stage == GS.main_campaign_levels + 1 then
			self:ci("label_button_locked").text = _("MAP_HERO_ROOM_UNLOCK_AFTER_CAMPAIGN")
		else
			self:ci("label_button_locked").text = string.format(_("MAP_HERO_ROOM_UNLOCK"), hd.available_at_stage or 0)
		end
	elseif hd.iap and (not premium or premium and exceptions) and (not product or not product.owned) then
		self:ci("button_hero_room_big_buy").hidden = false

		local dlc_p = PS.services.iap and PS.services.iap:get_container_dlc(hero_name) or nil

		if dlc_p then
			self:ci("label_button_price").text = _("HERO_ROOM_GET_DLC")
			self:ci("button_hero_room_big_buy").on_click = function(this)
				S:queue("GUIButtonCommon")
				screen_map:hide_hero_room()
				screen_map:show_shop_dlc()
			end
		else
			self:ci("label_button_price").text = product and product.price or "?"

			if PS.services.iap then
				local sale_prod = marketing:get_sale_offer(hero_name)

				if sale_prod then
					local discount_big = self:ci("group_sale_label_big")

					discount_big.hidden = false
					discount_big:ci("label_sale_big").text = sale_prod.discount_str
					self:ci("label_button_price").text = sale_prod.price
				end
			end
		end
	else
		self:ci("button_hero_room_big_select").hidden = false

		self:init_fullads_counter(hero_name, product)
	end

	local dlc_p = PS.services.iap and PS.services.iap:get_container_dlc(hero_name) or nil

	for _, v in pairs(GS.dlc_names) do
		self:ci("image_" .. v.id .. "_badge_big").hidden = not dlc_p or dlc_p.id ~= v.id
	end
end

function HeroRoomView:can_select_hero(hero_name)
	return self.hero_shown == hero_name and not self:ci("button_hero_room_big_select").hidden
end

function HeroRoomView:select_hero(hero_name, team_idx)
	self:pick_team_slot_stop()
	S:queue("GUIHeroTowerSelect")

	local user_data = storage:load_slot()

	user_data.heroes.team[team_idx] = hero_name

	local hd = screen_map.hero_data[hero_name]
	local h = user_data.heroes.status[hero_name]
	local starting_xp = hd.starting_level < 2 and 0 or GS.hero_xp_thresholds[hd.starting_level - 1]

	h.xp = math.max(h.xp, starting_xp)

	storage:save_slot(user_data)

	local team_item = self.roster_sel_items[team_idx]

	team_item:set_hero(hero_name, true)
	self:show_hero(hero_name, "long")

	local stats = HeroRoomView:get_hero_stats(hero_name)

	S:queue(stats.taunt)
	screen_map:update_badges()
end

function HeroRoomView:deselect_hero()
	return
end

function HeroRoomView:pick_team_slot_start()
	for _, v in pairs(self.roster_sel_items) do
		v:set_team_target(true)

		v.can_drag = false
	end

	self:highlight_selected_heroes()
end

function HeroRoomView:highlight_selected_heroes()
	for _, v in pairs(self.roster_sel_items) do
		v:shake(true)
	end

	self.picking_team_slot = true

	self:ci("group_hero_roster_sel"):order_above(self:ci("hero_room_roster_sel_overlay"))
	self:ci("group_hero_roster"):order_below(self:ci("hero_room_roster_sel_overlay"))

	self.overlay.alpha = 0
	self.overlay.hidden = false

	local ktw = self:get_window().ktw

	ktw:cancel(self.overlay)
	ktw:tween(self.overlay, 0.08, self.overlay, {
		alpha = 1
	}, "linear")
	S:queue("GUITowerWheelTapOn")

	local hrsv = self:ci("group_hero_roster_sel")

	self:get_window():set_responder(hrsv)
	hrsv:flatten(function(v)
		return v and v:isInstanceOf(HeroSliderItemView)
	end)[1]:focus(true)
end

function HeroRoomView:pick_team_slot_stop()
	self.picking_team_slot = nil

	self:ci("group_hero_roster"):order_above(self:ci("hero_room_roster_sel_overlay"))
	self:ci("group_hero_roster_sel"):order_below(self:ci("hero_room_roster_sel_overlay"))

	self.overlay.hidden = false

	local ktw = self:get_window().ktw

	ktw:cancel(self.overlay)
	ktw:tween(self.overlay, 0.08, self.overlay, {
		alpha = 0
	}, "linear", function()
		self.overlay.hidden = true
	end)
	S:queue("GUITowerWheelTapOff")

	for _, v in pairs(self.roster_sel_items) do
		v.can_drag = true

		v:set_team_target(false)
		v:shake(false)
	end

	self:get_window():set_responder(self)
end

function HeroRoomView:get_slider_item(hero_name)
	local items = self:get_slider_items()

	return table.filter(items, function(k, v)
		return v.hero_name == hero_name
	end)[1]
end

function HeroRoomView:get_slider_items()
	if KR_TARGET == "desktop" or KR_TARGET == "console" then
		return self:ci("hero_room_heroes").children
	else
		return self:ci("hero_room_heroes_slider").children
	end
end

function HeroRoomView:defocus_all_sliders()
	for _, v in pairs(self:get_slider_items()) do
		v.focus_image.hidden = true
	end
end

function HeroRoomView:get_skill_items()
	return self:ci("group_hero_room_skills").children
end

function HeroRoomView:update_hero_data()
	local map_data = require("data.map_data")

	if features.censored_cn then
		screen_map.hero_data = map_data.hero_data_iap
		screen_map.hero_order = map_data.hero_order_censored_cn
	elseif not PS.services.iap or PS.services.iap:is_premium() then
		screen_map.hero_data = table.deepclone(map_data.hero_data_free)
		screen_map.hero_order = map_data.hero_order_free
	else
		screen_map.hero_data = map_data.hero_data_iap
		screen_map.hero_order = map_data.hero_order_iap
	end

	if PS.services.remoteconfig and RC.v.available_heroes then
		local user_data = storage:load_slot()
		local to_remove = {}

		for h, value in pairs(screen_map.hero_data) do
			if not table.contains(RC.v.available_heroes, h) then
				table.insert(to_remove, h)
			end
		end

		for _, h in ipairs(to_remove) do
			table.removeobject(screen_map.hero_data, h)
			table.removeobject(screen_map.hero_order, h)

			for _, hn in ipairs(user_data.heroes.team) do
				if hn == h then
					user_data.heroes.team = GS.default_team

					storage:save_slot(user_data)
				end
			end
		end
	end

	if PS.services.iap then
		if PS.services.iap:is_premium() then
			local global = storage:load_global()

			if global.purchased_heroes then
				for _, n in pairs(global.purchased_heroes) do
					log.debug("unlocking hero %s owned before buying premium pass", n)

					local d = screen_map.hero_data

					d[n].available_at_stage = 1
				end
			end
		elseif not DEBUG then
			local user_data = storage:load_slot()
			local reassign_on_error = false

			for _, hn in ipairs(user_data.heroes.team) do
				if not hn or not screen_map.hero_data[hn] or not screen_map.hero_data[hn].iap then
					-- block empty
				else
					local p = PS.services.iap:get_product(hn)

					if not p.owned then
						reassign_on_error = true

						break
					end
				end
			end

			if reassign_on_error then
				log.debug("at least one of the heroes was not owned")

				user_data.heroes.team = GS.default_team

				storage:save_slot(user_data)
			end
		end
	end
end

function HeroRoomView:init_fullads_counter(hero_name, product)
	return
end

function HeroRoomView:buy_iap(currency, immediate)
	local hn = self.hero_shown

	if PS.services.iap then
		local ps = marketing:get_sale_offer(hn)

		if ps then
			hn = ps.id
		end
	end

	if not PS.services.iap or not PS.services.iap:purchase_product(hn, currency) then
		screen_map:show_error("iap_error")
		log.error("Error trying to purchase product %s", hn)

		return
	end

	if not immediate then
		screen_map:show_iap_progress()
	end
end

function HeroRoomView:restore_iap()
	return
end

function HeroRoomView:reset_skills()
	local user_data = storage:load_slot()
	local h = user_data.heroes.status[self.hero_shown]

	for k, v in pairs(h.skills) do
		h.skills[k] = 0
	end

	h.skills.ultimate = 1

	storage:save_slot(user_data)
	self:show_hero(self.hero_shown)
end

HeroSliderItemView = class("HeroSliderItemView", GG5Button)
HeroSliderItemView.static.instance_keys = {
	"id",
	"pos",
	"hero_name"
}
HeroSliderItemView.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function HeroSliderItemView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self.propagate_drag = true
	self.propagate_on_down = true
	self.thumb_image = self:ci("image_roster_thumb")
	self.check_image = self:ci("image_roster_thumb_tick")
	self.locked_image = self:ci("image_roster_thumb_locked")
	self.new_image = self:ci("image_roster_thumb_new")
	self.new_label = self:ci("label_roster_thumb_new")
	self.check_image.hidden = true
	self.locked_image.hidden = true
	self.new_image.hidden = not DBG_SHOW_BALLOONS and true
	self.new_label.hidden = not DBG_SHOW_BALLOONS and true
	self.flash_view = self:ci("roster_flash")
	self.flash_view.propagate_on_down = true
	self.flash_view.propagate_on_up = true
	self.flash_view.propagate_on_click = true
	self.flash_view.propagate_drag = true
	self.flash_view.alpha = 0
	self.drag_threshold = self.size.y / 4 / 768 * 320

	if KR_PLATFORM == "android" or KR_PLATFORM == "ios" then
		local h = KImageView:new(focus_image_name)

		h.hidden = true

		if self.image_offset then
			h.image_offset = self.image_offset
		end

		self:add_child(h)

		self.focus_image = h
	end
end

function HeroSliderItemView:set_shader_fade(min, max, grad)
	self.thumb_image.shader = SH:get("p_edge_fade")
	self.thumb_image.shader_args = {
		min_max = {
			min,
			max
		},
		gradient = grad
	}
	self.check_image.shader = SH:get("p_edge_fade")
	self.check_image.shader_args = {
		min_max = {
			min,
			max
		},
		gradient = grad
	}
	self.new_image.shader = SH:get("p_edge_fade")
	self.new_image.shader_args = {
		min_max = {
			min,
			max
		},
		gradient = grad
	}
end

function HeroSliderItemView:set_hero(hero_name, is_team)
	local user_data = storage:load_slot()

	self.hero_name = hero_name
	self.is_team = is_team

	if IS_MOBILE then
		local discount = self:ci("group_sale_label_small")

		discount.hidden = true
	end

	local thumb_fmt = "hero_room_portraits_small_thumb_%s_0001"

	self.thumb_image:set_image(string.format(thumb_fmt, hero_name))

	if is_team then
		self.can_drag = true
		self.propagate_drag = false
		self.propagate_on_down = false
		self.propagate_on_drop = false
	else
		self.can_drag = false
		self.check_image.hidden = not table.contains(user_data.heroes.team, self.hero_name) or not HeroRoomView:get_hero_stats(self.hero_name).unlocked

		local stats = HeroRoomView:get_hero_stats(hero_name)

		if stats.new_hero then
			self.new_image.hidden = false
			self.new_label.hidden = false
		elseif not stats.unlocked then
			self.locked_image.hidden = false
		end
	end
end

function HeroSliderItemView:update_discount()
	if IS_MOBILE then
		local discount = self:ci("group_sale_label_small")

		discount.hidden = true

		if PS.services.iap then
			local sale_prod = marketing:get_sale_offer(self.hero_name)
			local hd = screen_map.hero_data[self.hero_name]
			local prod = hd.iap and PS.services.iap:get_product(self.hero_name)

			if prod and sale_prod and not sale_prod.owned and not prod.owned then
				discount.hidden = false
				discount:ci("label_sale_small").text = sale_prod.discount_str
			end
		end
	end
end

function HeroSliderItemView:set_locked()
	self.can_drag = false
	self.locked_image.hidden = false

	self:disable()
end

function HeroSliderItemView:flash()
	self.flash_view.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(self.flash_view)
	ktw:tween(self.flash_view, 0.2, self.flash_view, {
		alpha = 0
	}, "in-quad")
end

function HeroSliderItemView:on_enter(drag_view)
	if self.is_team and drag_view and drag_view.is_team and self ~= drag_view and not self._swapping then
		local hr = self:get_parent_of_class(HeroRoomView)
		local drag_idx = table.keyforobject(hr.roster_sel_items, drag_view)
		local this_idx = table.keyforobject(hr.roster_sel_items, self)

		hr.roster_sel_items[drag_idx] = self
		hr.roster_sel_items[this_idx] = drag_view

		local dest = hr.roster_sel_positions[drag_idx]

		self._swapping = true

		local ktw = self:get_window().ktw

		ktw:tween(self, 0.25, self.pos, {
			x = dest.x,
			y = dest.y
		}, "out-quad", function()
			self._swapping = nil
		end)
	else
		HeroSliderItemView.super.on_enter(self, drag_view)
	end
end

function HeroSliderItemView:on_drag()
	self.disable_mouse_enter = true

	if self.parent.children[1] ~= self then
		self:order_to_front()
	end

	self.is_dragging = true

	local hr = self:get_parent_of_class(HeroRoomView)

	if not hr.picking_team_slot then
		hr:highlight_selected_heroes()
	end
end

function HeroSliderItemView:on_dropped(istouch)
	if not self.is_team then
		return
	end

	local hr = self:get_parent_of_class(HeroRoomView)

	hr:pick_team_slot_stop()

	self.is_dragging = false

	local this_idx = table.keyforobject(hr.roster_sel_items, self)
	local dest = hr.roster_sel_positions[this_idx]

	self._swapping = true

	local ktw = self:get_window().ktw

	ktw:tween(self, 0.15, self.pos, {
		x = dest.x,
		y = dest.y
	}, "out-quad", function()
		self._swapping = nil
	end)

	self.disable_mouse_enter = nil

	local user_data = storage:load_slot()

	for i, v in ipairs(hr.roster_sel_items) do
		user_data.heroes.team[i] = v.hero_name
	end

	storage:save_slot(user_data)
end

function HeroSliderItemView:on_click()
	S:queue("GUIHeroScroll")

	if self._swapping then
		local hr = self:get_parent_of_class(HeroRoomView)
		local this_idx = table.keyforobject(hr.roster_sel_items, self)
		local dest = hr.roster_sel_positions[this_idx]

		self.pos.x, self.pos.y = dest.x, dest.y
		self._swapping = false

		return
	end

	local hr = self:get_parent_of_class(HeroRoomView)

	if self.team_target then
		local team_idx = table.keyforobject(hr.roster_sel_items, self)

		hr:select_hero(hr.hero_shown, team_idx)
	elseif not IS_MOBILE and hr.hero_shown == self.hero_name and hr:can_select_hero(self.hero_name) then
		hr:pick_team_slot_start()
	else
		hr:show_hero(self.hero_name, true)

		self.new_image.hidden = true
		self.new_label.hidden = true

		if self.picking_team_slot then
			hr:pick_team_slot_stop()
		end
	end

	if not self.is_team and self.focus_image then
		hr:defocus_all_sliders()

		self.focus_image.hidden = false
	end
end

function HeroSliderItemView:on_up()
	if self.is_team then
		local hr = self:get_parent_of_class(HeroRoomView)
		local this_idx = table.keyforobject(hr.roster_sel_items, self)
		local dest = hr.roster_sel_positions[this_idx]

		self.pos.x, self.pos.y = dest.x, dest.y

		log.paranoid("HeroSliderItemView ON UP REDIRECTED TO ON CLICK")
		self:on_click()
	end
end

function HeroSliderItemView:set_team_target(value)
	self.team_target = value and self.locked_image.hidden
end

function HeroSliderItemView:shake(mode)
	if mode then
		self.rot_amp = U.frandom(0.005, 0.01)
		self.rot_speed = U.frandom(5.2, 5.6)
		self.shaking = true
	else
		self.r = 0
		self.shaking = false
	end
end

function HeroSliderItemView:update(dt)
	HeroSliderItemView.super.update(self, dt)

	if self.shaking and not self.is_dragging and self.locked_image.hidden then
		self.r = self.rot_amp * math.cos(2 * math.pi * self.ts * self.rot_speed)
	end
end

function HeroSliderItemView:focus(silent)
	if self.locked_image.hidden then
		HeroSliderItemView.super.focus(self, silent)
	end
end

HeroSkillItemView = class("HeroSkillItemView", GG5Button)
HeroSkillItemView.static.instance_keys = {
	"id",
	"pos"
}

function HeroSkillItemView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self.image_name_bullet_off = self:ci("hero_skill_bullet_1").image_name
	self.image_name_bullet_sel = self:ci("hero_skill_bullet_2").image_name
	self.image_name_bullet_on = self:ci("hero_skill_bullet_3").image_name
	self:ci("animation_skill_select_fx").hidden = true
	self:ci("animation_skill_select_fx").loop = false
	self:ci("animation_skill_select_fx").hide_at_end = true

	if KR_PLATFORM == "android" or KR_PLATFORM == "ios" then
		local h = KImageView:new(focus_image_name)

		h.hidden = true

		if self.image_offset then
			h.image_offset = self.image_offset
		end

		self:add_child(h)
		h:order_below(self:ci("image_skill_cost_bg"))

		self.focus_image = h
	end

	self:set_focus_below_child(self:ci("image_skill_cost_bg"))
end

function HeroSkillItemView:load(hero_name, skill_name, skill, remaining_points, idx)
	self.skill_name = skill_name
	self.remaining_points = remaining_points
	self.cost = skill.hr_cost[skill.level + 1]
	self.level = skill.level
	self.idx = idx
	self.hero_name = hero_name

	local skill_level_for_text = skill.level

	if self.skill_name == "ultimate" then
		skill_level_for_text = skill.level - 1
	end

	local title_suffix = skill_level_for_text >= 2 and "III" or skill_level_for_text == 1 and "II" or "I"

	if features.censored_cn then
		title_suffix = skill_level_for_text >= 2 and "3" or skill_level_for_text == 1 and "2" or "1"
	end

	local h = E:get_template(hero_name)
	local key = h.info.i18n_key or string.upper(hero_name)
	local skill_key = skill.key or string.upper(skill_name)

	self.title = _(string.format("%s_%s_TITLE", key, skill_key)) .. " " .. title_suffix
	self.desc = _(string.format("%s_%s_DESCRIPTION_%i", key, skill_key, km.clamp(1, 3, skill_level_for_text + 1)))

	self:ci("hero_skill_icon"):set_image(string.format("hero_room_skill_icons_%s_%04i", hero_name, skill.hr_order))

	if not self.cost then
		self:ci("image_skill_cost_bg").hidden = true
		self:ci("label_hero_skill_cost").hidden = true
		self:ci("image_skill_cost_bg_disabled").hidden = true
		self:ci("label_hero_skill_cost_disabled").hidden = true
	elseif self.cost <= self.remaining_points then
		self:ci("image_skill_cost_bg").hidden = false
		self:ci("label_hero_skill_cost").hidden = false
		self:ci("image_skill_cost_bg_disabled").hidden = true
		self:ci("label_hero_skill_cost_disabled").hidden = true
	else
		self:ci("image_skill_cost_bg").hidden = true
		self:ci("label_hero_skill_cost").hidden = true
		self:ci("image_skill_cost_bg_disabled").hidden = false
		self:ci("label_hero_skill_cost_disabled").hidden = false
	end

	self:ci("label_hero_skill_cost").text = self.cost or ""
	self:ci("label_hero_skill_cost_disabled").text = self.cost or ""
	self:ci("image_skill_level_up").hidden = true
	self:ci("image_skill_level_up_disabled").hidden = true
	self:ci("image_skill_select").hidden = true
	self:ci("image_skill_select_full").hidden = true
	self:ci("hero_skill_flash").alpha = 0

	for i = 1, 3 do
		local b = self:ci("hero_skill_bullet_" .. i)
		local level = self.level

		if self.skill_name == "ultimate" then
			level = level - 1
		end

		if i <= level then
			b:set_image(self.image_name_bullet_on)
		else
			b:set_image(self.image_name_bullet_off)
		end
	end

	if skill.level > 0 and self.skill_name ~= "ultimate" or skill.level > 1 and self.skill_name == "ultimate" then
		self:get_parent_of_class(HeroRoomView):ci("hero_room_reset_button"):enable()
	end

	self:get_parent_of_class(HeroRoomView):hide_skill_tooltip()
end

function HeroSkillItemView:deselect()
	self.is_selected = false

	for i = 1, 3 do
		local b = self:ci("hero_skill_bullet_" .. i)

		if b.image_name == self.image_name_bullet_sel then
			b:set_image(self.image_name_bullet_off)

			break
		end
	end

	self:ci("image_skill_level_up").hidden = true
	self:ci("image_skill_level_up_disabled").hidden = true
	self:ci("image_skill_select").hidden = true
	self:ci("image_skill_select_full").hidden = true

	self:get_parent_of_class(HeroRoomView):hide_skill_tooltip()
end

function HeroSkillItemView:select()
	self.is_selected = true

	if self.cost then
		local hero_stats = HeroRoomView:get_hero_stats(self.hero_name)

		if hero_stats.unlocked and self.remaining_points >= self.cost then
			self:ci("image_skill_level_up").hidden = false
			self:ci("image_skill_level_up_disabled").hidden = true

			local level = self.level

			if self.skill_name == "ultimate" then
				level = level - 1
			end

			if level < 3 then
				self:ci("hero_skill_bullet_" .. level + 1):set_image(self.image_name_bullet_sel)
			end
		else
			self:ci("image_skill_level_up").hidden = true
			self:ci("image_skill_level_up_disabled").hidden = false
		end
	end

	if self.skill_name == "ultimate" and self.level == 4 or self.skill_name ~= "ultimate" and self.level == 3 then
		self:ci("image_skill_select").hidden = true
		self:ci("image_skill_select_full").hidden = false
	else
		self:ci("image_skill_select").hidden = true
		self:ci("image_skill_select_full").hidden = true
	end

	self:get_parent_of_class(HeroRoomView):show_skill_tooltip(self)
end

function HeroSkillItemView:on_exit(drag_view)
	self.class.super.on_exit(self, drag_view)
	self:deselect()
end

function HeroSkillItemView:on_enter(drag_view)
	local skill_views = self:get_parent_of_class(HeroRoomView):ci("group_hero_room_skills").children

	for _, v in pairs(skill_views) do
		if v:isInstanceOf(HeroSkillItemView) and v ~= self then
			v:on_exit()
		end
	end

	self.class.super.on_enter(self, drag_view)

	if not IS_MOBILE then
		self:select()
	end
end

function HeroSkillItemView:train()
	local hero_stats = HeroRoomView:get_hero_stats(self.hero_name)

	if not hero_stats.unlocked then
		return
	end

	local hd = screen_map.hero_data[self.hero_name]

	if hd.iap and PS.services.iap then
		local p = PS.services.iap:get_product(self.hero_name)
		local premium, exceptions = PS.services.iap:is_premium()

		if p and not p.owned and (not premium or not not exceptions) then
			return
		end
	end

	if self.level >= 3 and self.skill_name ~= "ultimate" or self.level >= 4 and self.skill_name == "ultimate" then
		S:queue("GUIHeroSkillSelect")

		return false
	end

	if self.remaining_points < self.cost then
		S:queue("GUIButtonUnavailable")

		return false
	end

	S:queue("GUIHeroSkillConfirm")

	local hero_shown = self:get_parent_of_class(HeroRoomView).hero_shown
	local user_data = storage:load_slot()
	local h = user_data.heroes.status[hero_shown]

	h.skills[self.skill_name] = h.skills[self.skill_name] + 1

	storage:save_slot(user_data)

	self:ci("animation_skill_select_fx").ts = 0
	self:ci("animation_skill_select_fx").hidden = false

	self:get_parent_of_class(HeroRoomView):show_hero(hero_shown)

	return true
end

function HeroSkillItemView:on_click()
	if self.is_selected then
		if self:train() then
			if IS_MOBILE then
				self:deselect()
			else
				self:select()
			end
		end
	else
		S:queue("GUIHeroSkillSelect")
		self:select()

		local flash_view = self:ci("hero_skill_flash")

		flash_view.alpha = 1

		local ktw = self:get_window().ktw

		ktw:cancel(flash_view)
		ktw:tween(flash_view, 0.2, flash_view, {
			alpha = 0
		}, "in-quad")
	end
end

TowerRoomView = class("TowerRoomView", RoomView)

function TowerRoomView.static:get_tower_stats(tower_name)
	local out = {}
	local t = E:create_entity("tower_" .. tower_name .. "_lvl4")

	if not t then
		log.error("tower %s not found in templates", tower_name)

		return nil
	end

	out.skill_names = {}
	out.skills = {}

	for k, v in pairs(t.powers) do
		if v.enc_icon then
			table.insert(out.skill_names, k)
			table.insert(out.skills, t.powers[k])
		end
	end

	local user_data = storage:load_slot()

	out.new_tower = false

	local last_level_won = 1

	for i, v in ipairs(user_data.levels) do
		if v.stars ~= nil then
			last_level_won = i
		else
			break
		end
	end

	local td = screen_map.tower_data[tower_name]

	out.unlocked = false

	if td and screen_map:is_content_stage_unlocked(td, user_data) then
		if not screen_map:is_seen(tower_name) then
			out.new_tower = true
		end

		out.unlocked = true
	elseif td and not td.available_at_stage then
		out.unlocked = true
	end

	local key = "TOWER_" .. string.upper(tower_name)

	out.tower_name = _(key .. "_NAME")
	out.tower_desc = _(key .. "_DESC")
	out.stats = {}
	out.stats.damage = t.info.stat_damage
	out.stats.cooldown = t.info.stat_cooldown
	out.stats.range = t.info.stat_range
	out.stats.armor = t.info.stat_armor
	out.stats.hp = t.info.stat_hp
	out.damage_icon = t.info.damage_icon or "default"
	out.taunt = t.sound_events.tower_room_select

	return out
end

function TowerRoomView.static:is_new_tower_available()
	if DBG_SHOW_BALLOONS then
		log.error("DBG_SHOW_BALLOONS is on!")

		return true
	end

	for k, v in pairs(screen_map.tower_data) do
		local stats = TowerRoomView:get_tower_stats(k)

		if stats.new_tower then
			return true
		end
	end

	return false
end

function TowerRoomView:initialize(size, image_name, base_scale)
	TowerRoomView.super.initialize(self, size, image_name, base_scale)

	local user_data = storage:load_slot()

	if #user_data.towers.selected < 4 and #user_data.levels > 1 then
		table.insert(user_data.towers.selected, "tricannon")
		storage:save_slot(user_data)
	end

	if #user_data.towers.selected < 5 and #user_data.levels > 4 then
		table.insert(user_data.towers.selected, "ballista")
		storage:save_slot(user_data)
	end

	local hrov = self:ci("tower_room_roster_sel_overlay")

	hrov.colors = {
		background = {
			0,
			0,
			0,
			150
		}
	}
	hrov.hidden = true
	hrov.propagate_drag = false
	hrov.propagate_on_down = false
	hrov.propagate_on_touch_move = false
	hrov.propagate_on_touch_down = false
	hrov.propagate_on_enter = false

	function hrov.on_click(this)
		self:pick_tower_slot_stop()
	end

	if self.base_scale.y ~= 1 then
		hrov.scale = V.v(3, 3)
		hrov.anchor.x = hrov.size.x / 2
		hrov.anchor.y = hrov.size.y / 2
		hrov.pos.x = 0
		hrov.pos.y = 0
	end

	self:ci("tower_room_done_button"):ci("label_button_room_small").text = _("BUTTON_DONE")
	self:ci("tower_room_done_button").on_click = function(this)
		S:queue("GUIButtonOut")
		self:hide()
	end

	if not self.initial_focus_id then
		self.initial_focus_id = "tower_room_done_button"
	end

	if self:ci("button_close_popup") then
		self:ci("button_close_popup").on_click = function(this)
			S:queue("GUIButtonOut")
			self:hide()
		end
	end

	self:ci("button_tower_room_big_buy").on_click = function(this)
		S:queue("GUIBuyUpgrade")
		this:get_parent_of_class(TowerRoomView):buy_iap()
	end
	self:ci("button_tower_room_big_select").on_click = function(this)
		S:queue("GUIButtonCommon")
		this:get_parent_of_class(TowerRoomView):pick_tower_slot_start()
	end

	self:update_tower_data()

	local owned_dlcs = PS.services.iap and PS.services.iap:get_dlcs(true) or {}

	if not IS_MOBILE then
		local tr = self:ci("tower_room_towers")
		tr.clip = true
		local hsl = KInertialView:new()
		hsl.id = "tower_room_towers_slider"
		hsl.size = table.deepclone(tr.size)
		hsl.pos = table.deepclone(tr.pos)
		hsl.can_drag = true
		hsl.elastic_limits = true
		hsl.inertia_damping = 0.95
		hsl.inertia_stop_speed = 0.01
		tr:add_child(hsl)
		local ts_width = 0
		local start_offset_x = 4
		local eachRow = 10
		local ctx = SU.new_screen_ctx(screen_map)
		for i, n in ipairs(screen_map.tower_order) do
			local tt = kui_db:get_table("button_tower_roster_thumb_desktop", ctx)
			local ts = TowerSliderItemView:new_from_table(tt)
			local dlc_p = PS.services.iap and PS.services.iap:get_container_dlc("tower_" .. n) or nil

			for _, v in pairs(GS.dlc_names) do
				ts:ci("image_" .. v.id .. "_badge_small").hidden = not dlc_p or dlc_p.id ~= v.id or dlc_p.owned
			end

			ts:set_tower(n)

			if i <= eachRow then
				ts.pos.x = (i - 1) * (ts.size.x + 1) + ts.size.x / 2 + start_offset_x
				ts.pos.y = ts.size.y / 2
			elseif i <= 2 * eachRow then
				ts.pos.x = (i - eachRow - 1) * (ts.size.x + 1) + ts.size.x / 2 + start_offset_x
				ts.pos.y = ts.size.y * 3 / 2
			elseif i <= 3 * eachRow then
				ts.pos.x = (i - 2 * eachRow - 1) * (ts.size.x + 1) + ts.size.x / 2 + start_offset_x
				ts.pos.y = ts.size.y * 5 / 2
			end
			ts.id = string.format("button_tower_roster_%02i", i)

			hsl:add_child(ts)
			ts_width = ts.size.x
		end

		local drag_width = hsl.size.x - eachRow * (ts_width + 2)
		drag_width = drag_width > 0 and 0 or drag_width
		hsl.drag_limits = V.r(0, 0, drag_width, 0)
		hsl.elastic_limits = V.r(ts_width, 0, drag_width - 2 * ts_width, 0)
		local hrs_count = eachRow + 2
		local hrs_w = self:ci("tower_room_towers_slider").children[1].size.x + 1
		hsl.size.x = hrs_w * hrs_count
	else
		local hrh = self:ci("tower_room_towers")

		hrh.clip = true

		local hsl = KInertialView:new()

		hsl.id = "tower_room_towers_slider"
		hsl.size = table.deepclone(hrh.size)
		hsl.pos = table.deepclone(hrh.pos)
		hsl.can_drag = true
		hsl.elastic_limits = true
		hsl.inertia_damping = 0.95
		hsl.inertia_stop_speed = 0.01

		hrh:add_child(hsl)

		local ctx = SU.new_screen_ctx(screen_map)
		local ts_width = 0
		local start_offset_x = 7

		for i, n in ipairs(screen_map.tower_order) do
			local tt = kui_db:get_table("button_tower_roster_thumb", ctx)
			local ts = TowerSliderItemView:new_from_table(tt)

			ts:set_tower(n)

			ts.pos.x = (i - 1) * (ts.size.x + 1) + ts.size.x / 2 + start_offset_x
			ts.pos.y = hsl.size.y / 2

			hsl:add_child(ts)

			ts_width = ts.size.x

			local dlc_p = PS.services.iap and PS.services.iap:get_container_dlc("tower_" .. n) or nil

			for _, v in pairs(GS.dlc_names) do
				ts:ci("image_" .. v.id .. "_badge_small").hidden = not dlc_p or dlc_p.id ~= v.id or dlc_p.owned
			end
		end

		local drag_width = hsl.size.x - #screen_map.tower_order * (ts_width + 2)

		drag_width = drag_width > 0 and 0 or drag_width
		hsl.drag_limits = V.r(0, 0, drag_width, 0)
		hsl.elastic_limits = V.r(ts_width, 0, drag_width - 2 * ts_width, 0)

		local hrs_count = #screen_map.tower_order + 2
		local hrs_w = self:ci("tower_room_towers_slider").children[1].size.x + 1

		hsl.size.x = hrs_w * hrs_count
	end

	self.roster_sel_items = {
		self:ci("button_tower_ring_sel_01"),
		self:ci("button_tower_ring_sel_02"),
		self:ci("button_tower_ring_sel_03"),
		self:ci("button_tower_ring_sel_04"),
		self:ci("button_tower_ring_sel_05")
	}
	self.roster_sel_positions = {
		V.vclone(self.roster_sel_items[1].pos),
		V.vclone(self.roster_sel_items[2].pos),
		V.vclone(self.roster_sel_items[3].pos),
		V.vclone(self.roster_sel_items[4].pos),
		V.vclone(self.roster_sel_items[5].pos)
	}

	self:ci("button_tower_roster_sel"):set_tower(screen_map.tower_order[1], true)

	self:ci("button_tower_roster_sel").hidden = true

	for i, tower in ipairs(user_data.towers.selected) do
		self.roster_sel_items[i]:set_tower(tower)
	end

	self:ci("button_tower_room_big_disabled"):ci("label_button_selected").text = _("MAP_TOWER_ROOM_SELECTED")
	self:ci("button_tower_room_big_select"):ci("label_button_select").text = _("MAP_TOWER_ROOM_SELECT")
	self:ci("tower_room_skill_tooltip").hidden = true
	self:ci("group_dlc_tooltip").hidden = true

	for _, v in pairs(GS.dlc_names) do
		self:ci("image_" .. v.id .. "_badge_big").on_enter = function(this)
			self:hide_skill_tooltip()
			self:show_dlc_tooltip(v.id)
		end
		self:ci("image_" .. v.id .. "_badge_big").on_exit = function(this)
			self:hide_dlc_tooltip()
		end
	end

	local hrpf = self:ci("tower_room_portrait_flash")

	hrpf.propagate_on_down = true
	hrpf.propagate_on_up = true
	hrpf.propagate_on_click = true
	hrpf.propagate_drag = true
	hrpf.alpha = 0
	hrpf.colors.background = {
		255,
		255,
		255,
		255
	}
end

function TowerRoomView:destroy()
	TowerRoomView.super.destroy(self)
end

function TowerRoomView:show(show_tower_name, just_purchased)
	TowerRoomView.super.show(self)

	local tower_room = self

	self:get_window():ci(self.background_id).on_click = function(this)
		if not self.hidden then
			tower_room:hide()
		end
	end

	local preload_open = show_tower_name == false
	local user_data = storage:load_slot()

	show_tower_name = show_tower_name or screen_map.tower_order[1]

	if IS_MOBILE then
		local hsl = self:ci("tower_room_towers_slider")

		for k, v in pairs(hsl.children) do
			v:update_discount()
		end
	end

	self:show_tower(show_tower_name)

	if not preload_open and not screen_map:is_seen("tutorial_tower_room") or DBG_SHOW_BALLOONS then
		screen_map:set_seen("tutorial_tower_room")

		local ktw = self:get_window().ktw

		local function fade_in(v, delay)
			v.hidden = false

			ktw:cancel(v)
			ktw:tween(v, delay, v, {
				alpha = 1
			}, "in-quad")
		end

		local function fade_out(v, delay)
			v.hidden = false

			ktw:cancel(v)
			ktw:tween(v, delay, v, {
				alpha = 0
			}, "in-quad")
		end

		local function scale_in(view, min_scale, max_scale, delay)
			if not view.scale_shown then
				view.scale_shown = V.vclone(view.scale)
			end

			ktw:cancel(view)

			view.scale.x = view.scale_shown.x * min_scale
			view.scale.y = view.scale_shown.y * min_scale
			view.alpha = 0

			ktw:script(view, function(wait)
				wait(delay)
				ktw:tween(view, 0.11666666666666667, view, {
					alpha = 1
				}, "out-quad")
				ktw:tween(view, 0.11666666666666667, view.scale, {
					x = view.scale_shown.x * max_scale,
					y = view.scale_shown.y * max_scale
				}, "out-quad", function()
					ktw:tween(view, 0.03333333333333333, view.scale, {
						x = view.scale_shown.x,
						y = view.scale_shown.y
					}, "out-quad", function()
						view.scale.x = view.scale_shown.x
						view.scale.y = view.scale_shown.y
					end)
				end)
			end)
		end

		local sw, sh = screen_map.sw, screen_map.sh

		self.overlay = KView:new(V.v(sw * 2, sh * 2))
		self.overlay.colors = {
			background = {
				0,
				0,
				0,
				140
			}
		}
		self.overlay.alpha = 0
		self.overlay.pos.x, self.overlay.pos.y = -sw / 2, 0
		self.overlay.propagate_on_click = true
		self.overlay.propagate_drag = false
		self.overlay.propagate_on_enter = false
		self.overlay.propagate_on_exit = false
		self.can_close_tutorial = false

		table.insert(self:ci("group_tower_room_tutorial_overlay").children, self.overlay)

		self:ci("group_tower_room_tutorial").alpha = 0
		self:ci("group_tower_room_tutorial").hidden = false

		for _, v in ipairs(self:ci("group_tower_room_tutorial").children) do
			v.propagate_on_click = true
			v.propagate_on_touch_down = true
			v.propagate_on_touch_up = true

			for _, v2 in ipairs(v.children) do
				v2.propagate_on_click = true
				v2.propagate_on_touch_down = true
				v2.propagate_on_touch_up = true
			end
		end

		ktw:script(self, function(wait)
			screen_map:set_modal_view(self.overlay)
			fade_in(self.overlay, 0.5)
			fade_in(self:ci("group_tower_room_tutorial"), 0.5)

			for _, v in ipairs(self:ci("group_tower_room_tutorial").children) do
				scale_in(v, 0.9, 1.1, 0.5)
			end

			wait(0.5)

			self.can_close_tutorial = true
		end)

		function self.overlay.on_click(this)
			this:hide()
		end

		function self.overlay.hide(this)
			if self.can_close_tutorial then
				self.can_close_tutorial = false

				ktw:script(self, function(wait)
					screen_map:remove_modal_view()
					fade_out(self.overlay, 0.5)
					fade_out(self:ci("group_tower_room_tutorial"), 0.5)
					wait(0.5)

					self.overlay.hidden = true
					self:ci("group_tower_room_tutorial").hidden = true
				end)
			end
		end
	end

	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = true
	end
end

function TowerRoomView:hide()
	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = false
	end

	TowerRoomView.super.hide(self)

	self:get_window():ci(self.background_id).on_click = nil

	self:hide_skill_tooltip()
	self:hide_dlc_tooltip()
	screen_map:update_badges()
end

function TowerRoomView:show_skill_tooltip(item)
	local t = self:ci("tower_room_skill_tooltip")

	self:ci("label_tower_room_skill_tooltip_title").text = item.title
	self:ci("label_tower_room_skill_tooltip_desc").text = GU.balance_format(item.desc, balance)

	for i = 1, 2 do
		self:ci("hero_room_skill_tooltip_arrow_" .. i).hidden = i ~= item.idx
	end

	local function show_tooltip(ktw)
		t.hidden = false

		ktw:cancel(t)
		ktw:cancel(self:ci("label_tower_name"))
		ktw:cancel(self:ci("label_tower_desc"))

		t.scale = {
			x = 0.77,
			y = 0.77
		}
		t.alpha = 0.74

		ktw:tween(t, 0.233, nil, {
			alpha = 1,
			scale = {
				x = 1,
				y = 1
			}
		}, "out-back")

		local talpha = 0.4

		ktw:tween(self:ci("label_tower_name"), 0.1, nil, {
			alpha = talpha
		})
		ktw:tween(self:ci("label_tower_desc"), 0.1, nil, {
			alpha = talpha
		})
	end

	local ktw = self:get_window().ktw

	if not t.hidden then
		t.alpha = 0
		t.hidden = true
	end

	local title = self:ci("label_tower_room_skill_tooltip_title")
	local description = self:ci("label_tower_room_skill_tooltip_desc")
	local background = self:ci("hero_room_skill_tooltip_bg")

	title.fit_size = false
	description.fit_size = false

	local tw_title, twc_title = title:get_wrap_lines()
	local font_height_title = title:get_font_height()
	local tw_description, twc_description = description:get_wrap_lines()
	local font_height_description = description:get_font_height()
	local blank_space = font_height_description

	background.size.y = twc_description * font_height_description + twc_title * font_height_title + blank_space
	background.anchor_factor.x = background.anchor.x / background.size.x
	background.anchor_factor.y = background.size.y / background.size.y
	background.anchor.y = background.size.y
	background.pos.y = 73

	background:redraw()

	title.anchor.y = background.size.y
	title.pos.y = 83
	description.anchor.y = background.size.y
	description.pos.y = 85 + twc_title * font_height_title

	show_tooltip(ktw)
end

function TowerRoomView:hide_skill_tooltip()
	local t = self:ci("tower_room_skill_tooltip")
	local lhn = self:ci("label_tower_name")
	local lhd = self:ci("label_tower_desc")
	local ktw = self:get_window().ktw

	ktw:cancel(t)
	ktw:cancel(lhn)
	ktw:cancel(lhd)
	ktw:tween(t, 0.1, nil, {
		alpha = 0
	}, "in-quad", function()
		t.hidden = true
	end)
	ktw:after(lhn, 0.2, function()
		ktw:tween(lhn, 0.2, lhn, {
			alpha = 1
		}, "in-quad")
	end)
	ktw:after(lhd, 0.2, function()
		ktw:tween(lhd, 0.2, lhd, {
			alpha = 1
		}, "in-quad")
	end)
end

function TowerRoomView:show_dlc_tooltip(dlc)
	local t = self:ci("group_dlc_tooltip")

	t:ci("label_info_tooltip_title").text = _("TOWER_ROOM_DLC_BADGE_TOOLTIP_TITLE_KR5_" .. string.upper(dlc))
	t:ci("label_info_tooltip_desc").text = _("TOWER_ROOM_DLC_BADGE_TOOLTIP_DESC_KR5_" .. string.upper(dlc))
	t:ci("image_dlc_arrow").hidden = false

	local ktw = self:get_window().ktw

	if not t.hidden then
		t.alpha = 0
	end

	t.hidden = false

	ktw:cancel(t)
	ktw:cancel(self:ci("label_tower_name"))
	ktw:cancel(self:ci("label_tower_desc"))

	t.scale = {
		x = 0.77,
		y = 0.77
	}
	t.alpha = 0.74

	ktw:tween(t, 0.233, nil, {
		alpha = 1,
		scale = {
			x = 1,
			y = 1
		}
	}, "out-back")

	local talpha = 0.4

	ktw:tween(self:ci("label_tower_name"), 0.1, nil, {
		alpha = talpha
	})
	ktw:tween(self:ci("label_tower_desc"), 0.1, nil, {
		alpha = talpha
	})
end

function TowerRoomView:hide_dlc_tooltip()
	local t = self:ci("group_dlc_tooltip")
	local lhn = self:ci("label_tower_name")
	local lhd = self:ci("label_tower_desc")
	local ktw = self:get_window().ktw

	ktw:cancel(t)
	ktw:cancel(lhn)
	ktw:cancel(lhd)
	ktw:tween(t, 0.1, nil, {
		alpha = 0
	}, "in-quad", function()
		t.hidden = true
	end)
	ktw:after(lhn, 0.2, function()
		ktw:tween(lhn, 0.2, lhn, {
			alpha = 1
		}, "in-quad")
	end)
	ktw:after(lhd, 0.2, function()
		ktw:tween(lhd, 0.2, lhd, {
			alpha = 1
		}, "in-quad")
	end)
end

function TowerRoomView:show_tower(tower_name, flash)
	local ktw = self:get_window().ktw

	self.tower_shown = tower_name

	local towers_on_sale = PS.services.iap and {}
	local user_data = storage:load_slot()
	local stats = TowerRoomView:get_tower_stats(tower_name)
	local td = screen_map.tower_data[tower_name]
	local tt = E:get_template("tower_" .. tower_name .. "_lvl4")

	if IS_MOBILE then
		self:ci("group_sale_label_big").hidden = true
	end

	local dlc_p = PS.services.iap and PS.services.iap:get_container_dlc("tower_" .. tower_name) or nil

	for _, v in pairs(GS.dlc_names) do
		self:ci("image_" .. v.id .. "_badge_big").hidden = not dlc_p or dlc_p.id ~= v.id
	end

	local function scale_stat_bar(id, value)
		ktw:cancel(self:ci(id))
		ktw:tween(self:ci(id), 0.2, nil, {
			scale = {
				y = 1,
				x = value
			}
		})
	end

	local stat_index = 1

	if stats.stats.damage then
		self:ci("tower_stat_icon_" .. stat_index):set_image("tower_room_stats_icons_000" .. (stats.damage_icon == "magic" and "2" or "1"))
		scale_stat_bar("tower_stat_bar_" .. stat_index, stats.stats.damage / 10)

		stat_index = stat_index + 1
	end

	if stats.stats.hp then
		self:ci("tower_stat_icon_" .. stat_index):set_image("tower_room_stats_icons_0007")
		scale_stat_bar("tower_stat_bar_" .. stat_index, stats.stats.hp / 10)

		stat_index = stat_index + 1
	end

	if stats.stats.armor then
		self:ci("tower_stat_icon_" .. stat_index):set_image("tower_room_stats_icons_0005")
		scale_stat_bar("tower_stat_bar_" .. stat_index, stats.stats.armor / 10)

		stat_index = stat_index + 1
	end

	if stats.stats.cooldown then
		self:ci("tower_stat_icon_" .. stat_index):set_image("tower_room_stats_icons_0003")
		scale_stat_bar("tower_stat_bar_" .. stat_index, stats.stats.cooldown / 10)

		stat_index = stat_index + 1
	end

	if stats.stats.range then
		self:ci("tower_stat_icon_" .. stat_index):set_image("tower_room_stats_icons_0004")
		scale_stat_bar("tower_stat_bar_" .. stat_index, stats.stats.range / 10)

		stat_index = stat_index + 1
	end

	if stats.new_tower then
		screen_map:set_seen(tower_name)
	end

	self:ci("label_tower_name").text = stats.tower_name
	self:ci("label_tower_desc").text = stats.tower_desc

	self:ci("tower_room_portrait"):set_image(string.format("tower_room_portraits_big_tower_%s_0001", tower_name))

	if flash then
		local v = self:ci("tower_room_portrait_flash")

		v.alpha = 1

		ktw:tween(v, 0.2, v, {
			alpha = 0
		}, "in-quad")
	end

	if tt.tower.team == TEAM_LINIREA then
		self:ci("image_towerroom_goodside").hidden = false
		self:ci("image_towerroom_badside").hidden = true
	else
		self:ci("image_towerroom_goodside").hidden = true
		self:ci("image_towerroom_badside").hidden = false
	end

	local skill_views = self:ci("group_tower_skills").children
	local skill_index = 1

	for i, skill_view in ipairs(skill_views) do
		if skill_view:isInstanceOf(TowerSkillItemView) then
			skill_view:load(tower_name, skill_index, stats.skills, stats.skill_names)

			skill_index = skill_index + 1
		end
	end

	for _, v in pairs(self:get_slider_items()) do
		if v.focus_image then
			if v.tower_name == tower_name then
				v.focus_image.hidden = false
			else
				v.focus_image.hidden = true
			end
		end
	end

	self:get_slider_item(tower_name):flash()

	local product = td.iap and PS.services.iap and PS.services.iap:get_product("tower_" .. tower_name)
	local premium, exceptions = PS.services.iap:is_premium()

	self:ci("button_tower_room_big_disabled").hidden = true
	self:ci("button_tower_room_big_locked").hidden = true
	self:ci("button_tower_room_big_buy").hidden = true
	self:ci("button_tower_room_big_select").hidden = true

	self:ci("button_tower_room_big_disabled"):disable(false)
	self:ci("button_tower_room_big_locked"):disable(false)

	if user_data.towers.selected and table.contains(user_data.towers.selected, tower_name) then
		self:ci("button_tower_room_big_disabled").hidden = false
	elseif not screen_map:is_content_stage_unlocked(td, user_data) then
		self:ci("button_tower_room_big_locked").hidden = false
		self:ci("label_button_locked").text = string.format(_("MAP_HERO_ROOM_UNLOCK"), td.available_at_stage)
	elseif td.iap and (not premium or premium and exceptions) and (not product or not product.owned) then
		self:ci("button_tower_room_big_buy").hidden = false

		local dlc_p = PS.services.iap and PS.services.iap:get_container_dlc("tower_" .. tower_name) or nil

		if dlc_p then
			self:ci("label_button_price").text = _("TOWER_ROOM_GET_DLC")
			self:ci("button_tower_room_big_buy").on_click = function(this)
				S:queue("GUIButtonCommon")
				screen_map:hide_tower_room()
				screen_map:show_shop_dlc()
			end
		else
			self:ci("label_button_price").text = product and product.price or "?"

			if PS.services.iap then
				local sale_prod = marketing:get_sale_offer("tower_" .. tower_name)

				if sale_prod then
					local discount_big = self:ci("group_sale_label_big")

					discount_big.hidden = false
					discount_big:ci("label_sale_big").text = sale_prod.discount_str
					self:ci("label_button_price").text = sale_prod.price
				end
			end
		end
	else
		self:ci("button_tower_room_big_select").hidden = false

		self:init_fullads_counter(tower_name, product)
	end
end

function TowerRoomView:can_select_tower(tower_name)
	return not self:ci("button_tower_room_big_select").hidden
end

function TowerRoomView:select_tower(tower_name, team_idx)
	self:pick_tower_slot_stop()
	S:queue("GUIHeroTowerSelect")

	local user_data = storage:load_slot()

	user_data.towers.selected[team_idx] = tower_name

	storage:save_slot(user_data)

	for _, v in pairs(self:get_slider_items()) do
		if v.check_image then
			v.check_image.hidden = not table.contains(user_data.towers.selected, v.tower_name)
		end
	end

	local team_item = self.roster_sel_items[team_idx]

	team_item:set_tower(tower_name, true)
	self:get_slider_item(tower_name):flash()

	local portrait = self:ci("tower_room_portrait_flash")

	portrait.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(portrait)
	ktw:tween(portrait, 0.6, portrait, {
		alpha = 0
	}, "in-quad")

	local stats = TowerRoomView:get_tower_stats(tower_name)

	S:queue(stats.taunt)
	self:show_tower(tower_name)
	screen_map:update_badges()
end

function TowerRoomView:deselect_tower()
	return
end

function TowerRoomView:defocus_all_sliders()
	for _, v in pairs(self:get_slider_items()) do
		v.focus_image.hidden = true
	end
end

function TowerRoomView:pick_tower_slot_start()
	if not self.picking_team_slot then
		self.picking_team_slot = true

		local overlay = self:ci("tower_room_roster_sel_overlay")

		overlay.alpha = 0
		overlay.hidden = false

		local ktw = self:get_window().ktw

		ktw:cancel(overlay)
		ktw:tween(overlay, 0.08, overlay, {
			alpha = 1
		}, "linear")
		S:queue("GUITowerWheelTapOn")

		local tower_ring = self:ci("group_tower_ring")

		self:get_window():set_responder(tower_ring)
		tower_ring:flatten(function(v)
			return v and v:isInstanceOf(TowerRingItemButton)
		end)[1]:focus()

		for _, v in pairs(self.roster_sel_items) do
			v:set_team_target(true)

			v.can_drag = false
		end
	end
end

function TowerRoomView:pick_tower_slot_stop()
	self.picking_team_slot = nil

	local overlay = self:ci("tower_room_roster_sel_overlay")

	overlay.hidden = false

	local ktw = self:get_window().ktw

	ktw:cancel(overlay)
	ktw:tween(overlay, 0.08, overlay, {
		alpha = 0
	}, "linear", function()
		overlay.hidden = true
	end)
	S:queue("GUITowerWheelTapOff")

	for _, v in pairs(self.roster_sel_items) do
		v.can_drag = true

		v:set_team_target(false)
	end

	self:get_window():set_responder(self)
end

function TowerRoomView:get_slider_item(tower_name)
	local items = self:get_slider_items()

	return table.filter(items, function(k, v)
		return v.tower_name == tower_name
	end)[1]
end

function TowerRoomView:get_slider_items()
	return self:ci("tower_room_towers_slider").children
	-- if IS_MOBILE then
	-- 	return self:ci("tower_room_towers_slider").children
	-- else
	-- 	return self:ci("tower_room_towers").children
	-- end
end

function TowerRoomView:get_skill_items()
	return self:ci("group_tower_skills").children
end

function TowerRoomView:update_tower_data()
	local map_data = require("data.map_data")

	if features.censored_cn then
		screen_map.tower_data = map_data.tower_data_iap
		screen_map.tower_order = map_data.tower_order_censored_cn
	elseif not PS.services.iap or PS.services.iap:is_premium() then
		screen_map.tower_data = table.deepclone(map_data.tower_data_free)
		screen_map.tower_order = map_data.tower_order_free
	else
		screen_map.tower_data = map_data.tower_data_iap
		screen_map.tower_order = map_data.tower_order_iap
	end

	if PS.services.iap then
		if PS.services.iap:is_premium() then
			local global = storage:load_global()

			if global.purchased_towers then
				for _, n in pairs(global.purchased_towers) do
					log.debug("unlocking tower %s owned before buying premium pass", n)

					local d = screen_map.tower_data
					local tower = string.gsub(n, "tower_", "")

					d[tower].available_at_stage = 2
				end
			end
		else
			local user_data = storage:load_slot()

			for _, tn in ipairs(user_data.towers.selected) do
				if not tn or not screen_map.tower_data[tn] or not screen_map.tower_data[tn].iap then
					-- block empty
				else
					local p = PS.services.iap:get_product(tn)

					if p and not p.owned then
						log.debug("deselecting tower not owned %s", tn)
						table.remove(user_data.towers.selected, tn)
					end
				end
			end

			storage:save_slot(user_data)
		end
	end
end

function TowerRoomView:init_fullads_counter(tower_name, product)
	return
end

function TowerRoomView:buy_iap(currency, immediate)
	local tn = "tower_" .. self.tower_shown

	if PS.services.iap then
		local ps = marketing:get_sale_offer(tn)

		if ps then
			tn = ps.id
		end
	end

	if not PS.services.iap or not PS.services.iap:purchase_product(tn, currency) then
		screen_map:show_error("iap_error")
		log.error("Error trying to purchase product %s", tn)

		return
	end

	if not immediate then
		screen_map:show_iap_progress()
	end
end

function TowerRoomView:restore_iap()
	return
end

TowerSliderItemView = class("TowerSliderItemView", GG5Button)
TowerSliderItemView.static.instance_keys = {
	"id",
	"pos",
	"tower_name"
}
TowerSliderItemView.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function TowerSliderItemView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self.propagate_drag = true
	self.propagate_on_down = true
	self.thumb_image = self:ci("image_roster_thumb")
	self.check_image = self:ci("image_roster_thumb_tick")
	self.locked_image = self:ci("image_roster_thumb_locked")
	self.new_image = self:ci("image_roster_thumb_new")
	self.new_label = self:ci("label_roster_thumb_new")
	self.check_image.hidden = true
	self.locked_image.hidden = true
	self.new_image.hidden = not DBG_SHOW_BALLOONS and true
	self.new_label.hidden = not DBG_SHOW_BALLOONS and true
	self.flash_view = self:ci("roster_flash")
	self.flash_view.propagate_on_down = true
	self.flash_view.propagate_on_up = true
	self.flash_view.propagate_on_click = true
	self.flash_view.propagate_drag = true
	self.flash_view.alpha = 0
	self.drag_threshold = self.size.y / 4 / 768 * 320

	if KR_PLATFORM == "android" or KR_PLATFORM == "ios" then
		local h = KImageView:new(focus_image_name)

		h.hidden = true

		if self.image_offset then
			h.image_offset = self.image_offset
		end

		self:add_child(h)

		self.focus_image = h
	end
end

function TowerSliderItemView:set_tower(tower_name)
	local user_data = storage:load_slot()

	self.tower_name = tower_name

	local thumb_fmt = "tower_room_portraits_small_tower_%s_0001"

	self.thumb_image:set_image(string.format(thumb_fmt, tower_name))

	self.check_image.hidden = not table.contains(user_data.towers.selected, self.tower_name)

	local stats = TowerRoomView:get_tower_stats(tower_name)

	if stats.new_tower then
		self.new_image.hidden = false
		self.new_label.hidden = false
	elseif not stats.unlocked then
		self.locked_image.hidden = false
	end
end

function TowerSliderItemView:update_discount()
	if IS_MOBILE then
		local discount = self:ci("group_sale_label_small")

		discount.hidden = true

		if PS.services.iap then
			local sale_prod = marketing:get_sale_offer("tower_" .. self.tower_name)
			local td = screen_map.tower_data[self.tower_name]
			local prod = td.iap and PS.services.iap:get_product("tower_" .. self.tower_name)

			if prod and sale_prod and not sale_prod.owned and not prod.owned then
				discount.hidden = false
				discount:ci("label_sale_small").text = sale_prod.discount_str
			end
		end
	end
end

function TowerSliderItemView:flash()
	self.flash_view.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(self.flash_view)
	ktw:tween(self.flash_view, 0.2, self.flash_view, {
		alpha = 0
	}, "in-quad")
end

function TowerSliderItemView:on_click()
	S:queue("GUIHeroScroll")

	local tr = self:get_parent_of_class(TowerRoomView)

	if not IS_MOBILE and tr.tower_shown == self.tower_name and tr:can_select_tower(self.tower_name) then
		tr:pick_tower_slot_start()
	else
		tr:show_tower(self.tower_name, true)
	end

	self.new_image.hidden = true
	self.new_label.hidden = true

	if self.focus_image then
		tr:defocus_all_sliders()

		self.focus_image.hidden = false
	end
end

function TowerSliderItemView:set_team_target(value)
	self.team_target = value

	if value then
		self.rot_amp = U.frandom(0.02, 0.04)
		self.rot_speed = U.frandom(3.2, 3.6)
	else
		self.r = 0
	end
end

function TowerSliderItemView:update(dt)
	TowerSliderItemView.super.update(self, dt)

	if self.team_target then
		self.r = self.rot_amp * math.cos(2 * math.pi * self.ts * self.rot_speed)
	end
end

TowerRingItemButton = class("TowerRingItemButton", GG5Button)
TowerRingItemButton.static.instance_keys = {
	"id",
	"pos",
	"tower_name"
}
TowerRingItemButton.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function TowerRingItemButton:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self.thumb_image = self:ci("image_slot_icon")
	self.locked_image = self:ci("image_slot_locked")
	self.higlight_swap = self:ci("image_tower_icon_equip_highligth")
	self.higlight_swap.hidden = true
	self.locked_image.hidden = false

	self:disable(false)

	self.disable_mouse_enter = true
	self.flash_view = self:ci("image_tower_icon_flash_01")
	self.flash_view.alpha = 0
	self.propagate_drag = true
	self.propagate_on_down = true
	self.can_drag = true
	self.drag_threshold = self.size.y / 4 / 768 * 320

	if KR_PLATFORM == "android" or KR_PLATFORM == "ios" then
		local h = KImageView:new(focus_image_name)

		h.hidden = true

		if self.image_offset then
			h.image_offset = self.image_offset
		end

		self:add_child(h)

		self.focus_image = h
	end

	self.is_dragging = false
end

function TowerRingItemButton:set_team_target(value)
	self.team_target = value

	if value and not self.disable_mouse_enter then
		self.rot_amp = U.frandom(0.01, 0.015)
		self.rot_speed = U.frandom(5.6, 5.9)
		self.higlight_swap.hidden = false
	else
		self.r = 0
		self.higlight_swap.hidden = true
	end

	self:on_defocus()
end

function TowerRingItemButton:update(dt)
	TowerRingItemButton.super.update(self, dt)

	if (KR_PLATFORM == "android" or KR_PLATFORM == "ios") and #love.touch.getTouches() == 0 and self.is_dragging then
		self:on_dropped(true)
	end

	if self.team_target then
		if not self.disable_mouse_enter then
			local tr = self:get_parent_of_class(TowerRoomView)

			if self.focus_image and not tr.picking_team_slot then
				self.focus_image.hidden = false
			end

			self.r = self.rot_amp * math.cos(2 * math.pi * self.ts * self.rot_speed)

			local freq = 1.5
			local amp = 0.1

			self.higlight_swap.alpha = 1 - amp + amp * math.cos(2 * math.pi * self.ts * freq)
		end
	elseif self.focus_image then
		self.focus_image.hidden = true
	end
end

function TowerRingItemButton:flash(duration)
	self.flash_view.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(self.flash_view)
	ktw:tween(self.flash_view, duration, self.flash_view, {
		alpha = 0
	}, "in-quad")
end

function TowerRingItemButton:on_click()
	S:queue("GUIQuickMenuOpen")

	local tr = self:get_parent_of_class(TowerRoomView)

	if self.is_dragging then
		self:on_dropped()

		return
	end

	if self.team_target then
		for _, v in pairs(tr.roster_sel_items) do
			if v ~= self then
				v:set_team_target(false)
			end
		end

		local team_idx = table.keyforobject(tr.roster_sel_items, self)

		tr:select_tower(tr.tower_shown, team_idx)
		self:flash(0.5)
	else
		tr:show_tower(self.tower_name, true)
		self:flash(0.2)
	end
end

function TowerRingItemButton:set_tower(tower_name)
	self.tower_name = tower_name

	local tt = E:get_template("tower_" .. tower_name .. "_lvl4")

	self.thumb_image:set_image(tt.info.room_portrait)

	self.locked_image.hidden = true
	self.disable_mouse_enter = false

	self:enable()
end

function TowerRingItemButton:on_enter(drag_view)
	local tr = self:get_parent_of_class(TowerRoomView)
	local this_idx = table.keyforobject(tr.roster_sel_items, self)
	local drag_idx = table.keyforobject(tr.roster_sel_items, drag_view)

	if drag_view and self ~= drag_view and drag_idx and this_idx then
		tr._this_idx = this_idx
		tr._drag_idx = drag_idx

		local ktw = self:get_window().ktw

		ktw:tween(self, 0.1, nil, {
			scale = {
				x = 1.15,
				y = 1.15
			}
		})
	else
		TowerRingItemButton.super.on_enter(self, drag_view)
	end
end

function TowerRingItemButton:on_exit(drag_view)
	local tr = self:get_parent_of_class(TowerRoomView)
	local drag_idx = table.keyforobject(tr.roster_sel_items, drag_view)

	if tr._drag_idx and drag_idx == tr._drag_idx then
		tr._this_idx = nil
		tr._drag_idx = nil

		local ktw = self:get_window().ktw

		ktw:tween(self, 0.1, nil, {
			scale = {
				x = 1,
				y = 1
			}
		})
	else
		TowerRingItemButton.super.on_exit(self, drag_view)
	end
end

function TowerRingItemButton:on_drag()
	self.is_dragging = true
	self.disable_mouse_enter = true

	if self.parent.children[1] ~= self then
		self:order_to_front()

		local tr = self:get_parent_of_class(TowerRoomView)

		tr:pick_tower_slot_start()

		for _, v in ipairs(tr.roster_sel_items) do
			v.can_drag = true
		end
	end
end

function TowerRingItemButton:on_dropped(istouch)
	self.is_dragging = false

	local tr = self:get_parent_of_class(TowerRoomView)
	local drag_idx = table.keyforobject(tr.roster_sel_items, self)
	local ktw = self:get_window().ktw

	if tr._drag_idx and tr._this_idx and tr._drag_idx == drag_idx then
		local destination_slot = tr.roster_sel_items[tr._drag_idx]
		local origin_slot = tr.roster_sel_items[tr._this_idx]
		local destination_position = tr.roster_sel_positions[tr._drag_idx]
		local origin_position = tr.roster_sel_positions[tr._this_idx]

		ktw:tween(origin_slot, 0.15, origin_slot.pos, {
			x = destination_position.x,
			y = destination_position.y
		}, "out-quad")
		ktw:tween(destination_slot, 0.15, destination_slot.pos, {
			x = origin_position.x,
			y = origin_position.y
		}, "out-quad")

		origin_slot.scale = {
			x = 1,
			y = 1
		}
		destination_slot.scale = {
			x = 1,
			y = 1
		}
		self.disable_mouse_enter = nil
		tr.roster_sel_items[tr._drag_idx] = origin_slot
		tr.roster_sel_items[tr._this_idx] = destination_slot

		local user_data = storage:load_slot()

		for i, v in ipairs(tr.roster_sel_items) do
			user_data.towers.selected[i] = v.tower_name
		end

		storage:save_slot(user_data)
		tr:pick_tower_slot_stop()
	else
		self.disable_mouse_enter = nil

		local this_idx = table.keyforobject(tr.roster_sel_items, self)
		local origin_slot = tr.roster_sel_items[this_idx]
		local origin_position = tr.roster_sel_positions[this_idx]
		local drop_distance = math.abs(origin_position.x - origin_slot.pos.x) + math.abs(origin_position.y - origin_slot.pos.y)

		if drop_distance <= 10 then
			origin_slot.pos = V.vclone(origin_position)
		else
			ktw:tween(origin_slot, 0.15, origin_slot.pos, {
				x = origin_position.x,
				y = origin_position.y
			}, "out-quad", function()
				self._swapping = nil
			end)
		end

		tr:pick_tower_slot_stop()

		for _, roster_sel_item in ipairs(tr.roster_sel_items) do
			roster_sel_item.scale = {
				x = 1,
				y = 1
			}
		end
	end
end

TowerSkillItemView = class("TowerSkillItemView", GG5Button)
TowerSkillItemView.static.instance_keys = {
	"id",
	"pos"
}

function TowerSkillItemView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self:ci("image_tower_skill_button_select").hidden = true
end

function TowerSkillItemView:load(tower_name, idx, skills, skill_names)
	self.skill_name = skill_names[idx]

	local t = E:get_template("tower_" .. tower_name .. "_lvl4")
	local key = t.info.i18n_key or string.upper(tower_name)
	local skill_key = (skills[idx].key or string.upper(self.skill_name)) .. "_1"

	self.title = _(string.format("%s_%s_NAME", key, skill_key))

	if string.sub(self.title, -2) == " I" then
		self.title = string.sub(self.title, 0, #self.title - 2)
	end

	self.desc = _(string.format("%s_%s_DESCRIPTION", key, skill_key))
	self.idx = idx

	self:ci("image_tower_skill_icon"):set_image(string.format("quickmenu_special_icons_%04i_%04i", skills[idx].enc_icon, 1))

	self.mute_sfx = true

	self:on_defocus()

	self.mute_sfx = false
	self.loaded = true
end

function TowerSkillItemView:on_exit(drag_view)
	TowerSkillItemView.super.on_exit(self, drag_view)
	self:get_parent_of_class(TowerRoomView):hide_skill_tooltip()
end

function TowerSkillItemView:on_enter(drag_view)
	TowerSkillItemView.super.on_enter(self, drag_view)
	self:get_parent_of_class(TowerRoomView):show_skill_tooltip(self)
end

function TowerSkillItemView:on_click()
	if not IS_MOBILE then
		S:queue("GUIBalloonIn")
	end
end

ItemRoomView = class("ItemRoomView", RoomView)

function ItemRoomView:initialize(size, image_name, base_scale)
	ItemRoomView.super.initialize(self, size, image_name, base_scale)

	local irov = self:ci("item_room_wheel_sel_overlay")

	irov.colors = {
		background = {
			0,
			0,
			0,
			150
		}
	}
	irov.hidden = true
	irov.propagate_drag = false
	irov.propagate_on_down = false
	irov.propagate_on_touch_move = false
	irov.propagate_on_touch_down = false
	irov.propagate_on_enter = false

	function irov.on_click(this)
		self:pick_item_slot_stop()
	end

	if self.base_scale.y ~= 1 then
		irov.scale = V.v(3, 3)
		irov.anchor.y = irov.size.y / 2
		irov.pos.y = 384
	end

	local user_data = storage:load_slot()
	local gems_label = self:ci("label_item_room_gems")

	gems_label.text = string.format("%s", user_data.gems)

	local gems_button = self:ci("button_item_room_buy_gems")

	function gems_button.on_click(this)
		S:queue("GUIButtonCommon")
		local user_data = storage:load_slot()
		user_data.gems = user_data.gems + 1000
		storage:save_slot(user_data)
		gems_label.text = string.format("%s", user_data.gems)
		screen_map:update_gems()
		-- screen_map:hide_item_room()
		-- screen_map:show_shop_gems()
	end

	if self:ci("button_close_popup") then
		self:ci("button_close_popup").on_click = function(this)
			S:queue("GUIButtonOut")
			screen_map:hide_item_room()
		end
	end

	if IS_MOBILE and PS.services.iap and PS.services.iap:is_premium() then
		gems_button.hidden = nil
	end

	local button_confirm = self:ci("item_room_button_confirm_ok")

	button_confirm:ci("label_button_room_small").text = _("BUTTON_DONE")

	function button_confirm.on_click(this)
		S:queue("GUIButtonOut")
		screen_map:hide_item_room()
	end

	local button_buy = self:ci("item_room_button_item_price")

	function button_buy.on_click(this)
		local info = ItemRoomView:get_item_info(self.item_shown)
		local user_data = storage:load_slot()

		if user_data.gems < info.item_cost then
			S:queue("GUIButtonUnavailable")

			if not IS_MOBILE or not PS.services.iap or not PS.services.iap:is_premium() then
				screen_map.window:get_child_by_id("message_view"):show("no_gems")
			end

			return
		end

		S:queue("GUIBuyUpgrade")

		user_data.items.status[self.item_shown] = user_data.items.status[self.item_shown] + 1
		user_data.gems = user_data.gems - info.item_cost

		storage:save_slot(user_data)

		local gems_label = self:ci("label_item_room_gems")

		gems_label.text = string.format("%s", user_data.gems)

		screen_map:update_gems()
		self:show_item(self.item_shown, true)

		for i, v in pairs(user_data.items.selected) do
			if v == self.item_shown then
				self.wheel_sel_items[i]:update_stock_label(user_data)
			end
		end

		self.slider_items[self.item_shown]:update_stock_label(user_data)

		self.buy_fx.ts = 0
	end

	local button_equip = self:ci("item_room_button_item_equip")

	button_equip:ci("label_button_select").text = _("ITEM_ROOM_EQUIP")

	function button_equip.on_click(this)
		S:queue("GUIButtonCommon")
		self:pick_item_slot_start()

		for _, v in pairs(self.wheel_sel_items) do
			v.thumb_image.can_drag = false
		end
	end

	local button_equipped = self:ci("item_room_button_item_equipped")

	button_equipped:ci("label_button_selected").text = _("ITEM_ROOM_EQUIPPED")

	button_equipped:disable(false)

	local text_equipped_items = self:ci("group_title_equipped_items")

	text_equipped_items:ci("label_title_equipped_items").text = _("ITEM_ROOM_EQUIPPED_ITEMS")

	if not self.initial_focus_id then
		self.initial_focus_id = "item_room_button_confirm_ok"
	end

	self.buy_fx = self:ci("animation_item_buy_fx")
	self.buy_fx.loop = false

	local iri = self:ci("item_room_items")

	iri.clip = true

	local placeholder_item = self:ci("button_item_roster_sel")

	placeholder_item.hidden = true

	local isl = KInertialView:new()

	isl.id = "item_room_items_slider"
	isl.size = table.deepclone(iri.size)
	isl.pos = table.deepclone(iri.pos)
	isl.can_drag = true
	isl.inertia_damping = 0.8
	isl.inertia_stop_speed = 0.01

	iri:add_child(isl)

	local ctx = SU.new_screen_ctx(screen_map)
	local siv_width = 0

	self.slider_items = {}

	local start_offset_x = 7
	local new_item = false

	for i, n in ipairs(screen_map.item_order) do
		if not user_data.items.status[n] then
			user_data.items.status[n] = 0
			new_item = true
		end

		local tt = kui_db:get_table("button_item_roster_thumb", ctx)
		local siv = ItemSliderItemView:new_from_table(tt)

		siv:set_item(user_data, n)

		siv.pos.x = (i - 1) * (siv.size.x + 1) + siv.size.x / 2 + start_offset_x
		siv.pos.y = isl.size.y / 2

		isl:add_child(siv)

		siv_width = siv.size.x
		self.slider_items[n] = siv
	end

	if new_item then
		storage:save_slot(user_data)
	end

	local drag_width = isl.size.x - #screen_map.item_order * (siv_width + 2)
	drag_width = drag_width > 0 and 0 or drag_width
	isl.drag_limits = V.r(0, 0, drag_width, 0)
	isl.elastic_limits = V.r(siv_width, 0, drag_width - 2 * siv_width, 0)

	local hrs_count = #screen_map.item_order + 2
	local hrs_w = self:ci("item_room_items_slider").children[1].size.x + 1
	isl.size.x = hrs_w * hrs_count

	local wheel = self:ci("group_items_wheel")
	local user_data = storage:load_slot()

	self.wheel_sel_items = {
		wheel:ci("button_item_ring_sel_01"),
		wheel:ci("button_item_ring_sel_02"),
		wheel:ci("button_item_ring_sel_03")
	}
	self.wheel_sel_positions = {
		V.vclone(self.wheel_sel_items[1].thumb_image.pos),
		V.vclone(self.wheel_sel_items[2].thumb_image.pos),
		V.vclone(self.wheel_sel_items[3].thumb_image.pos)
	}

	for i, v in pairs(user_data.items.selected) do
		self.wheel_sel_items[i]:set_item(user_data, v)
	end

	local irpf = self:ci("item_room_portrait_flash")

	irpf.propagate_on_down = true
	irpf.propagate_on_up = true
	irpf.propagate_on_click = true
	irpf.propagate_drag = true
	irpf.alpha = 0
	irpf.colors.background = {
		255,
		255,
		255,
		255
	}

	self:update_item_data()
end

function ItemRoomView:destroy()
	ItemRoomView.super.destroy(self)
end

function ItemRoomView:show(show_item_name, just_purchased)
	ItemRoomView.super.show(self)

	local item_room = self

	self:get_window():ci(self.background_id).on_click = function(this)
		if not self.hidden then
			screen_map:hide_item_room()
		end
	end

	local preload_open = show_item_name == false
	local user_data = storage:load_slot()

	show_item_name = show_item_name or screen_map.item_order[1]

	self:show_item(show_item_name)

	local gems_label = self:ci("label_item_room_gems")

	gems_label.text = string.format("%s", user_data.gems)

	for i, v in pairs(self.wheel_sel_items) do
		v:update_stock_label(user_data)
	end

	for i, v in pairs(self.slider_items) do
		v:update_stock_label(user_data)
	end

	if not preload_open and not screen_map:is_seen("tutorial_item_room") or DBG_SHOW_BALLOONS then
		screen_map:set_seen("tutorial_item_room")

		local ktw = self:get_window().ktw

		local function fade_in(v, delay)
			v.hidden = false

			ktw:cancel(v)
			ktw:tween(v, delay, v, {
				alpha = 1
			}, "in-quad")
		end

		local function fade_out(v, delay)
			v.hidden = false

			ktw:cancel(v)
			ktw:tween(v, delay, v, {
				alpha = 0
			}, "in-quad")
		end

		local function scale_in(view, min_scale, max_scale, delay)
			if not view.scale_shown then
				view.scale_shown = V.vclone(view.scale)
			end

			ktw:cancel(view)

			view.scale.x = view.scale_shown.x * min_scale
			view.scale.y = view.scale_shown.y * min_scale
			view.alpha = 0

			ktw:script(view, function(wait)
				wait(delay)
				ktw:tween(view, 0.11666666666666667, view, {
					alpha = 1
				}, "out-quad")
				ktw:tween(view, 0.11666666666666667, view.scale, {
					x = view.scale_shown.x * max_scale,
					y = view.scale_shown.y * max_scale
				}, "out-quad", function()
					ktw:tween(view, 0.03333333333333333, view.scale, {
						x = view.scale_shown.x,
						y = view.scale_shown.y
					}, "out-quad", function()
						view.scale.x = view.scale_shown.x
						view.scale.y = view.scale_shown.y
					end)
				end)
			end)
		end

		local sw, sh = screen_map.sw, screen_map.sh

		self.overlay = KView:new(V.v(sw * 2, sh * 2))
		self.overlay.colors = {
			background = {
				0,
				0,
				0,
				140
			}
		}
		self.overlay.alpha = 0
		self.overlay.pos.x, self.overlay.pos.y = -sw / 2, 0
		self.overlay.propagate_on_click = true
		self.overlay.propagate_drag = false
		self.overlay.propagate_on_enter = false
		self.overlay.propagate_on_exit = false
		self.can_close_tutorial = false

		table.insert(self:ci("group_item_room_tutorial_overlay").children, self.overlay)

		self:ci("group_item_room_tutorial").alpha = 0
		self:ci("group_item_room_tutorial").hidden = false

		for _, v in ipairs(self:ci("group_item_room_tutorial").children) do
			v.propagate_on_click = true
			v.propagate_on_touch_down = true
			v.propagate_on_touch_up = true

			for _, v2 in ipairs(v.children) do
				v2.propagate_on_click = true
				v2.propagate_on_touch_down = true
				v2.propagate_on_touch_up = true
			end
		end

		ktw:script(self, function(wait)
			screen_map:set_modal_view(self.overlay)
			fade_in(self.overlay, 0.5)
			fade_in(self:ci("group_item_room_tutorial"), 0.5)

			for _, v in ipairs(self:ci("group_item_room_tutorial").children) do
				scale_in(v, 0.9, 1.1, 0.5)
			end

			wait(0.5)

			self.can_close_tutorial = true
		end)

		function self.overlay.on_click(this)
			this:hide()
		end

		function self.overlay.hide(this)
			if self.can_close_tutorial then
				self.can_close_tutorial = false

				ktw:script(self, function(wait)
					screen_map:remove_modal_view()
					fade_out(self.overlay, 0.5)
					fade_out(self:ci("group_item_room_tutorial"), 0.5)
					wait(0.5)

					self.overlay.hidden = true
					self:ci("group_item_room_tutorial").hidden = true
				end)
			end
		end
	end

	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = true
	end
end

function ItemRoomView:hide()
	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = false
	end

	ItemRoomView.super.hide(self)

	self:get_window():ci(self.background_id).on_click = nil

	screen_map:update_badges()
end

function ItemRoomView:show_item(item_name, flash)
	local ktw = self:get_window().ktw

	self.item_shown = item_name

	local user_data = storage:load_slot()
	local stock = ItemRoomView:get_item_stock(user_data, item_name)
	local info = ItemRoomView:get_item_info(item_name)
	local info_view = self:ci("group_item_info_panel")

	info_view:ci("label_item_name").text = info.item_name
	info_view:ci("label_item_desc").text = info.item_desc
	info_view:ci("label_item_bottom_desc").text = info.item_bottom_desc

	self:ci("item_room_portrait"):set_image(string.format("item_room_portrait_%s", item_name))

	if flash then
		local v = self:ci("item_room_portrait_flash")

		v.alpha = 0.8

		ktw:tween(v, 0.2, v, {
			alpha = 0
		}, "in-quad")
	else
		self:ci("item_room_portrait_flash").alpha = 0
	end

	self:ci("label_portrait_item_quantity").text = string.format("%s", stock)

	for _, v in pairs(self:get_slider_items()) do
		if v.focus_image then
			if v.item_name == item_name then
				v.focus_image.hidden = false
			else
				v.focus_image.hidden = true
			end
		end
	end

	if flash then
		self:get_slider_item(item_name):flash()
	end

	self:ci("item_room_button_item_price"):ci("label_button_price").text = info.item_price

	if user_data.items.selected and table.contains(user_data.items.selected, item_name) then
		self:ci("item_room_button_item_equipped").hidden = false
		self:ci("item_room_button_item_equip").hidden = true
	else
		self:ci("item_room_button_item_equip").hidden = false
		self:ci("item_room_button_item_equipped").hidden = true
	end

	self:ci("label_button_price").text = string.format("%s", info.item_cost)
end

function ItemRoomView:select_item(item_name, team_idx)
	self:pick_item_slot_stop()
	S:queue("GUIHeroSelect")

	local user_data = storage:load_slot()

	user_data.items.selected[team_idx] = item_name

	storage:save_slot(user_data)

	local team_item = self.wheel_sel_items[team_idx]

	team_item:set_item(user_data, item_name)
	self:get_slider_item(item_name):flash()
	self:show_item(item_name)

	local flash = self:ci("item_room_portrait_flash")

	flash.hidden = false
	flash.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(flash)
	ktw:tween(flash, 0.5, flash, {
		alpha = 0
	}, "in-quad")
end

function ItemRoomView:defocus_all_sliders()
	for _, v in pairs(self:get_slider_items()) do
		v.focus_image.hidden = true
	end
end

function ItemRoomView:pick_item_slot_start(drag_item)
	if not self.picking_team_slot then
		local overlay = self:ci("item_room_wheel_sel_overlay")

		overlay.alpha = 0
		overlay.hidden = false

		local ktw = self:get_window().ktw

		ktw:cancel(overlay)
		ktw:tween(overlay, 0.08, overlay, {
			alpha = 1
		}, "linear")
		S:queue("GUITowerWheelTapOn")

		self.drag_item = drag_item

		local items_wheel = self:ci("group_items_wheel")

		self:get_window():set_responder(items_wheel)

		self.picking_team_slot = true

		for _, v in pairs(self.wheel_sel_items) do
			v:set_team_target(true)
		end
	end
end

function ItemRoomView:pick_item_slot_stop()
	self.picking_team_slot = nil

	local overlay = self:ci("item_room_wheel_sel_overlay")

	overlay.hidden = false

	local ktw = self:get_window().ktw

	ktw:cancel(overlay)
	ktw:tween(overlay, 0.08, overlay, {
		alpha = 0
	}, "linear", function()
		overlay.hidden = true
	end)
	S:queue("GUITowerWheelTapOff")

	for k, v in pairs(self.wheel_sel_items) do
		v.thumb_image.can_drag = true

		v:set_team_target(false)
		ktw:tween(v.item_frame, 0.1, nil, {
			scale = {
				x = 1,
				y = 1
			}
		})
		ktw:tween(v.highlight_image, 0.1, nil, {
			scale = {
				x = 1,
				y = 1
			}
		})
		ktw:tween(v.thumb_image, 0.1, nil, {
			scale = {
				x = 1,
				y = 1
			}
		})
	end

	self:get_window():set_responder(self)
end

function ItemRoomView:get_slider_item(item_name)
	local items = self:get_slider_items()

	return table.filter(items, function(k, v)
		return v.item_name == item_name
	end)[1]
end

function ItemRoomView:get_slider_items()
	return self.slider_items
end

function ItemRoomView:update_item_data()
	local map_data = require("data.map_data")

	screen_map.item_data = table.deepclone(iap_data.shop_data)

	if features.censored_cn then
		screen_map.item_order = map_data.item_order_censored_cn
	else
		screen_map.item_order = map_data.item_order
	end
end

function ItemRoomView.static:get_item_stock(data, item_name)
	return data.items.status[item_name]
end

function ItemRoomView.static:get_item_info(item_name)
	local out = {}
	local key = "ITEM_" .. string.upper(item_name)

	out.item_name = _(key .. "_NAME")
	out.item_desc = _(key .. "_DESC")
	out.item_bottom_desc = _(key .. "_BOTTOM_DESC")
	out.item_cost = screen_map.item_data[item_name].cost

	return out
end

ItemSliderItemView = class("ItemSliderItemView", GG5Button)
ItemSliderItemView.static.instance_keys = {
	"id",
	"pos",
	"item_name"
}
ItemSliderItemView.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function ItemSliderItemView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self.propagate_drag = true
	self.propagate_on_down = true
	self.thumb_image = self:ci("image_roster_thumb")
	self.quantity_label = self:ci("group_roster_item_quantity")
	self.quantity_label_text = self.quantity_label:ci("label_roster_item_quantity")
	self.quantity_label.propagate_on_down = true
	self.quantity_label.propagate_on_up = true
	self.quantity_label.propagate_on_click = true
	self.quantity_label.propagate_drag = true
	self.quantity_label.propagate_enter = true
	self.quantity_label.on_click = nil
	self.quantity_label.testing_label = true
	self.quantity_label_text.propagate_on_down = true
	self.quantity_label_text.propagate_on_up = true
	self.quantity_label_text.propagate_on_click = true
	self.quantity_label_text.propagate_drag = true
	self.quantity_label_text.propagate_enter = true
	self.quantity_label_text.on_click = nil
	self.quantity_label_text.testing_label = true
	self.testing_label = true
	self.flash_view = self:ci("roster_flash")
	self.flash_view.propagate_on_down = true
	self.flash_view.propagate_on_up = true
	self.flash_view.propagate_on_click = true
	self.flash_view.propagate_drag = true
	self.flash_view.alpha = 0

	if KR_PLATFORM == "android" or KR_PLATFORM == "ios" then
		local h = KImageView:new(focus_image_name)

		h.hidden = true

		if self.image_offset then
			h.image_offset = self.image_offset
		end

		self:add_child(h)

		self.focus_image = h
	end
end

function ItemSliderItemView:update_stock_label(data)
	local stock = ItemRoomView:get_item_stock(data, self.item_name)

	self.quantity_label.hidden = stock == 0
	self.quantity_label_text.text = string.format("%s", stock)
end

function ItemSliderItemView:set_item(data, item_name)
	self.item_name = item_name

	local thumb_fmt = "item_room_thumb_%s"

	self.thumb_image:set_image(string.format(thumb_fmt, item_name))
	self:update_stock_label(data)
end

function ItemSliderItemView:flash()
	self.flash_view.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(self.flash_view)
	ktw:tween(self.flash_view, 0.2, self.flash_view, {
		alpha = 0
	}, "in-quad")
end

function ItemSliderItemView:on_click()
	S:queue("GUIHeroScroll")

	local ir = self:get_parent_of_class(ItemRoomView)

	ir:show_item(self.item_name, true)

	if self.focus_image then
		ir:defocus_all_sliders()

		self.focus_image.hidden = false
	end
end

function ItemSliderItemView:update(dt)
	ItemSliderItemView.super.update(self, dt)
end

ItemRingItemButton = class("ItemRingItemButton", GG5Button)
ItemRingItemButton.static.instance_keys = {
	"id",
	"pos",
	"item_name"
}
ItemRingItemButton.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function ItemRingItemButton:initialize(default_image_name, focus_image_name)
	self.is_item_ring_button = true

	GG5Button.initialize(self, default_image_name, focus_image_name)

	local function v(v1, v2)
		return {
			x = v1,
			y = v2
		}
	end

	local function r(x, y, w, h)
		return {
			pos = v(x, y),
			size = v(w, h)
		}
	end

	self.thumb_image = self:ci("group_item_icon_01")
	self.thumb_image.can_drag = true
	self.thumb_image.hit_rect = r(-70, -70, 140, 140)
	self.flash_view = self:ci("image_item_icon_flash_01")
	self.flash_view.alpha = 0

	self:disable(false)

	self.disable_mouse_enter = true
	self.highlight_image = self:ci("image_item_icon_equip_highligth_01")
	self.highlight_image.hidden = true
	self.quantity_label = self:ci("label_item_quantity")
	self.item_frame = self:ci("group_item_icon_frame")
	self.propagate_drag = true
	self.propagate_on_down = true
	self.can_drag = false

	local increase_hit = 0

	self.hit_rect.pos.x = self.hit_rect.pos.x - increase_hit
	self.hit_rect.pos.y = self.hit_rect.pos.y - increase_hit
	self.hit_rect.size.x = self.hit_rect.size.x + increase_hit * 2
	self.hit_rect.size.y = self.hit_rect.size.y + increase_hit * 2
	self.drag_threshold = self.size.y / 4 / 768 * 320

	if KR_PLATFORM == "android" or KR_PLATFORM == "ios" then
		local h = KImageView:new(focus_image_name)

		h.hidden = true

		if self.image_offset then
			h.image_offset = self.image_offset
		end

		self:add_child(h)

		self.focus_image = h
	end

	self.is_dragging = false
end

function ItemRingItemButton:set_team_target(value)
	self.team_target = value

	if value then
		self.rot_amp = U.frandom(0.01, 0.015)
		self.rot_speed = U.frandom(5.6, 5.9)
		self.highlight_image.hidden = false
		self.highlighting_slot = true
		self.highlight_up = true
	else
		self.r = 0
		self.highlight_image.hidden = true
		self.highlighting_slot = false
	end

	self:on_defocus()
end

function ItemRingItemButton:update(dt)
	ItemRingItemButton.super.update(self, dt)

	if (KR_PLATFORM == "android" or KR_PLATFORM == "ios") and #love.touch.getTouches() == 0 and self.is_dragging then
		self:on_dropped(true)
	end

	if self.team_target then
		if not self.disable_mouse_enter then
			local ir = self:get_parent_of_class(ItemRoomView)

			if self.focus_image and not ir.picking_team_slot then
				self.focus_image.hidden = false
			end

			if self.thumb_image.is_dragging then
				self.item_frame.r = self.rot_amp * math.cos(2 * math.pi * self.ts * self.rot_speed)
			else
				self.r = self.rot_amp * math.cos(2 * math.pi * self.ts * self.rot_speed)
			end

			local freq = 1.5
			local amp = 0.1

			self.highlight_image.alpha = 1 - amp + amp * math.cos(2 * math.pi * self.ts * freq)
		end
	elseif self.focus_image then
		self.focus_image.hidden = true
	end
end

function ItemRingItemButton:flash(duration)
	self.flash_view.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(self.flash_view)
	ktw:tween(self.flash_view, duration, self.flash_view, {
		alpha = 0
	}, "in-quad")
end

function ItemRingItemButton:on_click()
	if self.thumb_image.is_dragging then
		self.thumb_image:on_dropped()

		return
	end

	S:queue("GUIQuickMenuOpen")

	local ir = self:get_parent_of_class(ItemRoomView)

	if self.team_target then
		for _, v in pairs(ir.wheel_sel_items) do
			if v ~= self then
				v:set_team_target(false)
			end
		end

		local item_idx = table.keyforobject(ir.wheel_sel_items, self)

		ir:select_item(ir.item_shown, item_idx)
		self:flash(0.5)
	else
		ir:show_item(self.item_name, true)
		self:flash(0.2)
	end
end

function ItemRingItemButton:update_stock_label(user_data)
	local stock = ItemRoomView:get_item_stock(user_data, self.item_name)

	self.quantity_label.text = string.format("%s", stock)
end

function ItemRingItemButton:set_item(data, item_name)
	self.item_name = item_name

	self.thumb_image.children[1]:set_image(string.format("item_room_button_%s", item_name))
	self:update_stock_label(data)

	self.disable_mouse_enter = false

	self:enable()
end

function ItemRingItemButton:on_enter(drag_view)
	local ir = self:get_parent_of_class(ItemRoomView)
	local this_idx = table.keyforobject(ir.wheel_sel_items, self)
	local drag_idx

	if drag_view then
		drag_idx = table.keyforobject(ir.wheel_sel_items, drag_view.parent)
	end

	if drag_view and self.thumb_image ~= drag_view and drag_idx and this_idx or ir.picking_team_slot and not ir.drag_item then
		ir._drag_dest_idx = this_idx
		ir._drag_origin_idx = drag_idx

		local ktw = self:get_window().ktw

		ktw:tween(self, 0.1, nil, {
			scale = {
				x = 1.15,
				y = 1.15
			}
		})
	else
		if ir.picking_team_slot then
			return
		end

		ItemRingItemButton.super.on_enter(self, drag_view)
	end
end

function ItemRingItemButton:on_exit(drag_view)
	local ir = self:get_parent_of_class(ItemRoomView)
	local drag_idx

	if drag_view then
		drag_idx = table.keyforobject(ir.wheel_sel_items, drag_view.parent)
	end

	if ir._drag_origin_idx and drag_idx == ir._drag_origin_idx or ir.picking_team_slot and not ir.drag_item then
		ir._drag_dest_idx = nil
		ir._drag_origin_idx = nil

		local ktw = self:get_window().ktw

		ktw:tween(self, 0.1, nil, {
			scale = {
				x = 1,
				y = 1
			}
		})
	else
		ItemRingItemButton.super.on_exit(self, drag_view)
	end
end

ItemRingItemButtonThumb = class("ItemRingItemButtonThumb", KImageView)
ItemRingItemButtonThumb.static.instance_keys = {
	"id",
	"pos",
	"item_name"
}
ItemRingItemButtonThumb.static.init_arg_names = {
	"image_name",
	"size"
}

function ItemRingItemButtonThumb:initialize(image_name, size)
	self.is_item_ring_button_thumb = true

	KImageView.initialize(self, image_name, size)

	self.can_drag = true
end

function ItemRingItemButtonThumb:on_drag()
	self.is_dragging = true
	self.disable_mouse_enter = true

	self.parent:order_to_front()
	self:order_to_front()

	local ir = self:get_parent_of_class(ItemRoomView)

	ir:pick_item_slot_start(self.parent)
end

function ItemRingItemButtonThumb:on_dropped(istouch)
	self.is_dragging = false

	self:order_above(self.parent.children[1])

	local ir = self:get_parent_of_class(ItemRoomView)
	local drag_idx = table.keyforobject(ir.wheel_sel_items, self.parent)
	local ktw = self:get_window().ktw

	if ir._drag_origin_idx and ir._drag_dest_idx and ir._drag_origin_idx == drag_idx then
		local destination_slot = ir.wheel_sel_items[ir._drag_dest_idx].thumb_image
		local origin_slot = ir.wheel_sel_items[ir._drag_origin_idx].thumb_image
		local destination_pos = ir.wheel_sel_positions[ir._drag_dest_idx]
		local origin_pos = ir.wheel_sel_positions[ir._drag_origin_idx]

		origin_slot.parent.pos, destination_slot.parent.pos = destination_slot.parent.pos, origin_slot.parent.pos

		local x, y = V.sub(origin_slot.parent.pos.x, origin_slot.parent.pos.y, destination_slot.parent.pos.x, destination_slot.parent.pos.y)
		local parent_dist = V.v(x, y)
		local origin_start_pos = V.vclone(origin_slot.pos)

		x, y = V.sub(origin_start_pos.x, origin_start_pos.y, parent_dist.x, parent_dist.y)
		origin_slot.pos = V.v(x, y)

		ktw:tween(origin_slot, 0.15, origin_slot.pos, {
			x = destination_pos.x,
			y = destination_pos.y
		}, "out-quad")

		local destination_start_pos = V.vclone(destination_slot.pos)

		x, y = V.add(destination_start_pos.x, destination_start_pos.y, parent_dist.x, parent_dist.y)
		destination_slot.pos = V.v(x, y)

		ktw:tween(destination_slot, 0.15, destination_slot.pos, {
			x = origin_pos.x,
			y = origin_pos.y
		}, "out-quad")

		origin_slot.scale = {
			x = 1,
			y = 1
		}
		destination_slot.scale = {
			x = 1,
			y = 1
		}
		origin_slot.parent.scale = {
			x = 1,
			y = 1
		}
		destination_slot.parent.scale = {
			x = 1,
			y = 1
		}
		self.disable_mouse_enter = nil
		ir.wheel_sel_items[ir._drag_origin_idx] = destination_slot.parent
		ir.wheel_sel_items[ir._drag_dest_idx] = origin_slot.parent

		local user_data = storage:load_slot()

		for i, v in ipairs(ir.wheel_sel_items) do
			user_data.items.selected[i] = v.item_name
		end

		storage:save_slot(user_data)
		ir:pick_item_slot_stop()
	else
		self.disable_mouse_enter = nil

		local this_idx = table.keyforobject(ir.wheel_sel_items, self.parent)
		local origin_slot = ir.wheel_sel_items[this_idx].thumb_image
		local origin_position = ir.wheel_sel_positions[this_idx]

		ktw:tween(origin_slot, 0.15, origin_slot.pos, {
			x = origin_position.x,
			y = origin_position.y
		}, "out-quad", function()
			self._swapping = nil
		end)
		ir:pick_item_slot_stop()

		for _, wheel_sel_item in ipairs(ir.wheel_sel_items) do
			wheel_sel_item.scale = {
				x = 1,
				y = 1
			}
		end
	end
end

GG5PopUpLevelSelect = class("GG5PopUpLevelSelect", GG5PopUp)

function GG5PopUpLevelSelect:initialize(size, image_name, base_scale)
	if not self.initial_focus_id then
		self.initial_focus_id = "button_fight"
	end

	GG5PopUpLevelSelect.super.initialize(self, size, image_name, base_scale)
end

function GG5PopUpLevelSelect:show(level_idx, stars, diff_campaign, diff_heroic, diff_iron)
	GG5PopUpLevelSelect.super.show(self)

	if not screen_map:is_seen("difficulty") then
		screen_map:set_seen("difficulty")
		self:get_window():ci("difficulty_room_view"):show(function()
			self:update_difficulty()
		end)
	end

	self.level_idx = level_idx
	self.stars = stars
	self.modes_diff = {
		diff_campaign,
		diff_heroic,
		diff_iron
	}

	local terrain = 1

	for i, v in ipairs(GS.level_areas) do
		if level_idx >= v[1] and level_idx <= v[2] then
			terrain = i

			break
		end
	end

	if features.censored_cn and terrain == 3 then
		terrain = 4
	end

	self:ci("label_title_1").hidden = true
	self:ci("label_title_2").hidden = true
	self:ci("label_title_3").hidden = true
	self:ci("label_title_4").hidden = true
	self:ci("label_title_5").hidden = true
	self:ci("label_title_6").hidden = true
	self:ci("label_title_7").hidden = true
	self:ci("label_title_8").hidden = true
	self:ci("label_title_" .. terrain).hidden = false
	self:ci("label_title_" .. terrain).text = string.format("%s", utf8_string.upper(_("LEVEL_" .. level_idx .. "_TITLE")))
	self:ci("title_bg").size.x = self:ci("label_title_" .. terrain):get_wrap_lines() + 2 * self:ci("title_bg").slice_rect.pos.x

	self:ci("image_thumb"):set_image(string.format("%s_%i_0001", "level_select_thumbs_thumb_stage", level_idx))

	self:ci("title_bg").propagate_on_click = true
	self:ci("image_txt_bg").propagate_on_click = true

	if level_idx == 16 then
		self:ci("top_shadow_s16").hidden = false
		self:ci("image_badges_bg_s16").hidden = false
		self:ci("image_badges_star_01_s16").hidden = false
		self:ci("image_badges_star_02_s16").hidden = false
		self:ci("image_badges_star_03_s16").hidden = false
		self:ci("top_shadow").hidden = true
		self:ci("image_badges_bg").hidden = true
		self:ci("image_badges_star_01").hidden = true
		self:ci("image_badges_star_02").hidden = true
		self:ci("image_badges_star_03").hidden = true
	else
		self:ci("top_shadow_s16").hidden = true
		self:ci("image_badges_bg_s16").hidden = true
		self:ci("image_badges_star_01_s16").hidden = true
		self:ci("image_badges_star_02_s16").hidden = true
		self:ci("image_badges_star_03_s16").hidden = true
		self:ci("top_shadow").hidden = false
		self:ci("image_badges_bg").hidden = false
		self:ci("image_badges_star_01").hidden = false
		self:ci("image_badges_star_02").hidden = false
		self:ci("image_badges_star_03").hidden = false
	end
	self:ci("top_shadow_s16").hidden = true
	self:ci("image_badges_bg_s16").hidden = true
	self:ci("top_shadow").hidden = false
	self:ci("image_badges_bg").hidden = false

	for i = 1, 3 do
		self:ci("image_badges_star_0" .. i .. "_s16").hidden = true
		self:ci("image_badges_star_0" .. i).hidden = stars < i
	end

	self:ci("image_badges_heroic").hidden = not diff_heroic or diff_heroic < 1
	self:ci("image_badges_iron").hidden = not diff_iron or diff_iron < 1

	self:show_mode(GAME_MODE_CAMPAIGN)
	self:update_difficulty()

	self:ci("group_mode_tooltip_2").alpha = 0
	self:ci("group_mode_tooltip_2").hidden = true
	self:ci("group_mode_tooltip_2").propagate_on_click = true
	self:ci("group_mode_tooltip_2").on_click = function(this)
		self:hide_mode_tooltip()
	end

	if features.censored_cn then
		self:ci("group_mode_tooltip_2"):ci("label_mode_tooltip_title").colors.text = {
			0,
			0,
			0
		}
	end

	self:ci("group_mode_tooltip_3").alpha = 0
	self:ci("group_mode_tooltip_3").hidden = true
	self:ci("group_mode_tooltip_3").propagate_on_click = true
	self:ci("group_mode_tooltip_3").on_click = function(this)
		self:hide_mode_tooltip()
	end

	if features.censored_cn then
		self:ci("group_mode_tooltip_3"):ci("label_mode_tooltip_title").colors.text = {
			0,
			0,
			0
		}
	end

	self:ci("button_buy"):disable()

	self:ci("button_buy").hidden = true

	self:ci("button_fight"):enable()

	self:ci("button_fight").hidden = false

	local dlc

	for k, v in pairs(GS.dlc_names) do
		local range = U.get_dlc_level_range(v.id)

		if level_idx >= range[1] and level_idx <= range[2] then
			dlc = v.id

			break
		end
	end

	if PS.services.iap then
		local owned_dlcs = PS.services.iap:get_dlcs(true)

		if dlc and not table.contains(owned_dlcs, dlc) then
			self:ci("button_fight"):disable()

			self:ci("button_fight").hidden = true

			self:ci("button_buy"):enable()

			self:ci("button_buy").hidden = false
			self:ci("button_buy"):ci("label_campaign_fight").text = _("LEVEL_SELECT_GET_DLC")
			self:ci("button_buy").on_click = function(this)
				self:hide()
				screen_map:show_shop_dlc()
			end
		end
	end

	self:ci("toggle_mode_1"):set_mode(GAME_MODE_CAMPAIGN)
	self:ci("toggle_mode_1"):set_value(true)
	self:ci("toggle_mode_2"):set_value(false)
	self:ci("toggle_mode_3"):set_value(false)

	if stars > 0 then
		self:ci("toggle_mode_2"):set_mode(GAME_MODE_HEROIC)
		self:ci("toggle_mode_3"):set_mode(GAME_MODE_IRON)
	else
		self:ci("toggle_mode_2"):set_mode(0)
		self:ci("toggle_mode_3"):set_mode(0)
	end

	self:ci("group_mode_tooltip_2"):ci("label_mode_tooltip_title").text = _("LEVEL_SELECT_MODE_LOCKED1")
	self:ci("group_mode_tooltip_2"):ci("label_mode_tooltip_desc").text = _("LEVEL_SELECT_MODE_LOCKED2")
	self:ci("group_mode_tooltip_3"):ci("label_mode_tooltip_title").text = _("LEVEL_SELECT_MODE_LOCKED1")
	self:ci("group_mode_tooltip_3"):ci("label_mode_tooltip_desc").text = _("LEVEL_SELECT_MODE_LOCKED2")

	if level_idx == 16 then
		self:ci("toggle_mode_2").hidden = false
		self:ci("toggle_mode_3").hidden = false
	else
		self:ci("toggle_mode_2").hidden = false
		self:ci("toggle_mode_3").hidden = false
	end

	if features.censored_cn then
		self:ci("label_high_difficulty").colors.text = {
			140,
			201,
			102
		}
	end

	self:ci("button_fight").on_click = function(this)
		S:queue("GUIButtonCommon")
		screen_map:start_level(self.level_idx, self.game_mode)
	end

	function self.on_click(this)
		self:hide_mode_tooltip()
	end

	screen_map:hide_bars()

	self:ci("button_fight_debug").hidden = true

	if DEBUG then
		self:ci("button_fight_debug").hidden = false
		self:ci("button_fight_debug").on_click = function(this)
			UPGR:set_upgrades_current_for(self.level_idx)
			S:queue("GUIButtonCommon")
			screen_map:start_level(self.level_idx, self.game_mode)
		end
	end

	self:ci("button_extra_enemies").on_click = function(this)
		S:queue("GUIButtonCommon")
		screen_map:start_level(self.level_idx, self.game_mode, balance.enemies.extra_enemies)
	end
end

function GG5PopUpLevelSelect:show_mode(game_mode)
	self:ci("label_completed_difficulty").text = self.modes_diff[game_mode] and GU.difficulty_completed_desc(self.modes_diff[game_mode]) or ""
	self:ci("label_high_difficulty").hidden = game_mode ~= GAME_MODE_CAMPAIGN or self.modes_diff[game_mode] or self.level_idx <= 16
	self:ci("image_icon_high_difficulty").hidden = game_mode ~= GAME_MODE_CAMPAIGN or self.modes_diff[game_mode] or self.level_idx <= 16
	self:ci("label_campaign_brief").text = _("LEVEL_" .. self.level_idx .. "_HISTORY")
	self:ci("label_rules").text = _("LEVEL_SELECT_CHALLENGE_RULES")
	self:ci("label_rules_2").text = _("LEVEL_SELECT_CHALLENGE_ONE_LIFE")
	self:ci("label_available_towers").text = _("LEVEL_SELECT_AVAILABLE_TOWERS")

	self:ci("toggle_mode_1"):set_value(game_mode == GAME_MODE_CAMPAIGN)
	self:ci("toggle_mode_2"):set_value(game_mode == GAME_MODE_HEROIC)
	self:ci("toggle_mode_3"):set_value(game_mode == GAME_MODE_IRON)

	if game_mode == GAME_MODE_CAMPAIGN then
		self:ci("label_mode").hidden = true
		self:ci("group_mode_campaign").hidden = false
		self:ci("group_mode_rules").hidden = true
		self:ci("group_mode_towers").hidden = true
	elseif game_mode == GAME_MODE_HEROIC then
		self:ci("label_mode").hidden = false
		self:ci("label_mode").text = _("LEVEL_MODE_HEROIC")
		self:ci("label_rules_1").text = _("LEVEL_SELECT_CHALLENGE_SIX_ELITE_WAVE")
		self:ci("group_mode_campaign").hidden = true
		self:ci("group_mode_rules").hidden = false
		self:ci("group_mode_towers").hidden = true
	elseif game_mode == GAME_MODE_IRON then
		self:ci("label_mode").hidden = false
		self:ci("label_mode").text = _("LEVEL_MODE_IRON")
		self:ci("label_rules_1").text = _("LEVEL_SELECT_CHALLENGE_ONE_ELITE_WAVE")
		self:ci("group_mode_campaign").hidden = true
		self:ci("group_mode_rules").hidden = false
		self:ci("group_mode_towers").hidden = false

		local level_data = LU.load_data({
			level_name = string.format("level%02i", self.level_idx),
			level_mode = game_mode
		})
		local tower_menu_data = require("data.tower_menus_data")
		local avail = {}

		for _, n in pairs(screen_map.tower_order) do
			local fn = "tower_build_" .. n

			if level_data.available_towers and table.contains(level_data.available_towers, fn) and (not level_data.locked_towers or level_data.locked_towers and not table.contains(level_data.locked_towers, fn)) then
				local icon

				for _, a in pairs(tower_menu_data.holder[1]) do
					if a.type == n then
						icon = "level_select_" .. a.image .. "_0001"
					end
				end

				table.insert(avail, {
					n,
					icon
				})
			end
		end

		for i = 1, 5 do
			self:ci("image_available_tower_" .. i).hidden = true
		end

		if #avail == 1 then
			self:ci("image_available_tower_3").hidden = false

			self:ci("image_available_tower_3"):set_image(avail[1][2])
		elseif #avail == 2 then
			self:ci("image_available_tower_2").hidden = false
			self:ci("image_available_tower_4").hidden = false

			self:ci("image_available_tower_2"):set_image(avail[1][2])
			self:ci("image_available_tower_4"):set_image(avail[2][2])
		elseif #avail == 3 then
			self:ci("image_available_tower_1").hidden = false
			self:ci("image_available_tower_3").hidden = false
			self:ci("image_available_tower_5").hidden = false

			self:ci("image_available_tower_1"):set_image(avail[1][2])
			self:ci("image_available_tower_3"):set_image(avail[2][2])
			self:ci("image_available_tower_5"):set_image(avail[3][2])
		else
			log.error("Wrong number of available towers: %s", getfulldump(avail))
		end
	end

	self.game_mode = game_mode
end

function GG5PopUpLevelSelect:update_difficulty()
	local user_data = storage:load_slot()
end

function GG5PopUpLevelSelect:hide()
	GG5PopUpLevelSelect.super.hide(self)
	screen_map:show_bars()
end

function GG5PopUpLevelSelect:show_mode_tooltip(button_id)
	local is_heroic = string.ends(button_id, "2")

	if is_heroic then
		local t = self:ci("group_mode_tooltip_3")
		local ktw = self:get_window().ktw

		ktw:cancel(t)
		ktw:tween(t, 0.1, nil, {
			alpha = 0
		}, "in-quad", function()
			t.hidden = true
		end)
	else
		local t = self:ci("group_mode_tooltip_2")
		local ktw = self:get_window().ktw

		ktw:cancel(t)
		ktw:tween(t, 0.1, nil, {
			alpha = 0
		}, "in-quad", function()
			t.hidden = true
		end)
	end

	local ktw = self:get_window().ktw
	local t = self:ci(is_heroic and "group_mode_tooltip_2" or "group_mode_tooltip_3")

	t.hidden = false
	t.alpha = 0

	ktw:cancel(t)
	ktw:tween(t, 0.15, nil, {
		alpha = 1
	}, "out-quad")
end

function GG5PopUpLevelSelect:hide_mode_tooltip()
	local t = self:ci("group_mode_tooltip_2")
	local ktw = self:get_window().ktw

	ktw:cancel(t)
	ktw:tween(t, 0.1, nil, {
		alpha = 0
	}, "in-quad", function()
		t.hidden = true
	end)

	t = self:ci("group_mode_tooltip_3")

	ktw:cancel(t)
	ktw:tween(t, 0.1, nil, {
		alpha = 0
	}, "in-quad", function()
		t.hidden = true
	end)

	self:ci("toggle_mode_1").showing_tooltip = false
	self:ci("toggle_mode_2").showing_tooltip = false
	self:ci("toggle_mode_3").showing_tooltip = false
end

LevelSelectModeButton = class("LevelSelectModeButton", GG5ToggleButton)

function LevelSelectModeButton:set_mode(mode)
	self.mode = mode

	local suffixes = {
		[0] = "locked",
		"campaign",
		"heroic",
		"iron"
	}

	self:ci("image_mode_icon"):set_image("level_select_mode_icons_" .. suffixes[mode] .. "_0001")

	self.showing_tooltip = false

	if mode == 0 or mode == 1 then
		self:ci("notification_dot").hidden = true
	else
		local user_data = storage:load_slot()
		local p = self:get_parent_of_class(GG5PopUpLevelSelect)

		self:ci("notification_dot").hidden = user_data.levels[p.level_idx][mode]
	end
end

function LevelSelectModeButton:on_click()
	local p = self:get_parent_of_class(GG5PopUpLevelSelect)

	self:focus(true)
	S:queue("GUIButtonSoft1")

	if self.mode == 0 then
		if self.showing_tooltip then
			p:hide_mode_tooltip()

			self.showing_tooltip = false
		else
			p:show_mode_tooltip(self.id)

			self.showing_tooltip = true

			self:set_value(false)
		end
	else
		p:hide_mode_tooltip()
		p:show_mode(self.mode)
	end
end

DifficultyRoomView = class("DifficultyRoomView", RoomView)

function DifficultyRoomView:show(done_callback)
	DifficultyRoomView.super.show(self)

	self.done_callback = done_callback

	if self:ci("button_close_popup") then
		self:ci("button_close_popup").on_click = function(this)
			S:queue("GUIButtonOut")
			self:hide()
		end
	end

	local current_difficulty = storage:load_slot().difficulty
	local b_texts = {
		{
			_("LEVEL_SELECT_DIFFICULTY_CASUAL"),
			_("DIFFICULTY_SELECTION_EASY_DESCRIPTION")
		},
		{
			_("LEVEL_SELECT_DIFFICULTY_NORMAL"),
			_("DIFFICULTY_SELECTION_NORMAL_DESCRIPTION")
		},
		{
			_("LEVEL_SELECT_DIFFICULTY_VETERAN"),
			_("DIFFICULTY_SELECTION_HARD_DESCRIPTION")
		},
		{
			_("LEVEL_SELECT_DIFFICULTY_IMPOSSIBLE"),
			_("DIFFICULTY_SELECTION_IMPOSSIBLE_DESCRIPTION")
		}
	}

	for i = 1, 4 do
		local b = self:ci("toggle_difficulty_level_" .. i)

		b.difficulty = i

		function b.on_click(this)
			S:queue("GUIButtonCommon")

			local user_data = storage:load_slot()

			user_data.difficulty = this.difficulty

			storage:save_slot(user_data)
			self:hide()
		end

		b:enable()
		b:set_value(i ~= current_difficulty)
		b:ci("image_difficulty_icon"):set_image("difficulty_room_icons_difficulty_icon_" .. i .. "_0001")

		b:ci("label_difficulty_title").text = b_texts[i][1]
		b:ci("label_difficulty_desc").text = b_texts[i][2]

		if i == current_difficulty then
			b:focus(true)
		end

		if i == 4 then
			local user_data = storage:load_slot()

			if #user_data.levels < GS.main_campaign_levels or not user_data.levels[GS.main_campaign_levels][1] or user_data.levels[GS.main_campaign_levels][1] == 0 then
				b:disable()

				b:ci("label_difficulty_desc").text = _("DIFFICULTY_SELECTION_IMPOSSIBLE_LOCKED_DESCRIPTION")
			end
		end
	end
end

function DifficultyRoomView:hide()
	for i = 1, 4 do
		local b = self:ci("toggle_difficulty_level_" .. i)

		b:disable()
	end

	DifficultyRoomView.super.hide(self)
end

UpgradesRoomView = class("UpgradesRoomView", RoomView)

function UpgradesRoomView:initialize(size, image_name, base_scale)
	UpgradesRoomView.super.initialize(self, size, image_name, base_scale)

	local function hide_tooltips(group)
		for _, c in ipairs(self:ci(group).children) do
			if c.id == "upgrades_room_tooltip" then
				c.hidden = true
			end
		end
	end

	local function hide_upgrade_links(group)
		for _, c in ipairs(self:ci(group).children) do
			if string.find(c.id, "link") then
				c.hidden = true

				table.insert(self.links, c)
			end
		end
	end

	local function load_upgrades(group)
		for _, c in ipairs(self:ci(group).children) do
			if c.class == UpgradeRoomUpgradeView then
				local idx = string.sub(c.id, -2)

				c:load(group, tonumber(idx))
				table.insert(self.upgrades, c)
			end
		end
	end

	local groups = {
		"group_upgrades_towers",
		"group_upgrades_heroes",
		"group_upgrades_reinforcements",
		"group_upgrades_alliance"
	}

	self.upgrades = {}
	self.links = {}

	for _, group in ipairs(groups) do
		hide_tooltips(group)
		hide_upgrade_links(group)
		load_upgrades(group)
	end

	self:ci("upgrades_room_done_button"):ci("label_button_room_small").text = _("BUTTON_DONE")
	self:ci("upgrades_room_done_button").on_click = function(this)
		S:queue("GUIButtonOut")
		self:hide()
	end

	if not self.initial_focus_id then
		self.initial_focus_id = "upgrades_room_done_button"
	end

	self:ci("upgrades_room_reset_button"):ci("label_button_room_small").text = _("BUTTON_RESET")
	self:ci("upgrades_room_reset_button").on_click = function(this)
		S:queue("GUIResetUpgrade")
		self:reset_all()
		this:disable()
	end

	if self:ci("button_close_popup") then
		self:ci("button_close_popup").on_click = function(this)
			S:queue("GUIButtonOut")
			self:hide()
		end
	end

	for _, c in ipairs(self.children[1].children) do
		if c.class == UpgradeTooltipView then
			self.tooltip_view = c
			c.hidden = true

			break
		end
	end

	self.tooltip_view.propagate_on_down = true
	self.tooltip_view.propagate_on_up = true
	self.tooltip_view.propagate_on_click = true
	self.tooltip_view.propagate_drag = true
	self.tooltip_view.propagate_on_touch_move = true
	self.tooltip_view.propagate_on_touch_down = true
end

function UpgradesRoomView:reset_all()
	local user_data = storage:load_slot()

	for group, value in pairs(user_data.upgrades) do
		user_data.upgrades[group] = {}
	end

	storage:save_slot(user_data)

	for _, l in ipairs(self.links) do
		l.hidden = true
	end

	self:update_available_points()
end

function UpgradesRoomView:destroy()
	UpgradesRoomView.super.destroy(self)
end

function UpgradesRoomView:show(can_show_tutorial)
	UpgradesRoomView.super.show(self)
	self:update_available_points()
	self:update_links()

	if can_show_tutorial == nil then
		can_show_tutorial = true
	end

	if can_show_tutorial and not screen_map:is_seen("tutorial_upgrades_room") or DBG_SHOW_BALLOONS then
		screen_map:set_seen("tutorial_upgrades_room")

		local ktw = self:get_window().ktw

		local function fade_in(v, delay)
			v.hidden = false

			ktw:cancel(v)
			ktw:tween(v, delay, v, {
				alpha = 1
			}, "in-quad")
		end

		local function fade_out(v, delay)
			v.hidden = false

			ktw:cancel(v)
			ktw:tween(v, delay, v, {
				alpha = 0
			}, "in-quad")
		end

		local function scale_in(view, min_scale, max_scale, delay)
			if not view.scale_shown then
				view.scale_shown = V.vclone(view.scale)
			end

			ktw:cancel(view)

			view.scale.x = view.scale_shown.x * min_scale
			view.scale.y = view.scale_shown.y * min_scale
			view.alpha = 0

			ktw:script(view, function(wait)
				wait(delay)
				ktw:tween(view, 0.11666666666666667, view, {
					alpha = 1
				}, "out-quad")
				ktw:tween(view, 0.11666666666666667, view.scale, {
					x = view.scale_shown.x * max_scale,
					y = view.scale_shown.y * max_scale
				}, "out-quad", function()
					ktw:tween(view, 0.03333333333333333, view.scale, {
						x = view.scale_shown.x,
						y = view.scale_shown.y
					}, "out-quad", function()
						view.scale.x = view.scale_shown.x
						view.scale.y = view.scale_shown.y
					end)
				end)
			end)
		end

		local sw, sh = screen_map.sw, screen_map.sh

		self.overlay = KView:new(V.v(sw * 2, sh * 2))
		self.overlay.colors = {
			background = {
				0,
				0,
				0,
				140
			}
		}
		self.overlay.alpha = 0
		self.overlay.pos.x, self.overlay.pos.y = -sw / 2, 0
		self.overlay.propagate_on_click = true
		self.overlay.propagate_on_enter = false
		self.overlay.propagate_on_exit = false
		self.can_close_tutorial = false

		table.insert(self:ci("group_upgrades_room_tutorial_overlay").children, self.overlay)

		self:ci("group_upgrades_tutorial").alpha = 0
		self:ci("group_upgrades_tutorial").hidden = false

		for _, v in ipairs(self:ci("group_upgrades_tutorial").children) do
			v.propagate_on_click = true
			v.propagate_on_touch_down = true
			v.propagate_on_touch_up = true

			for _, v2 in ipairs(v.children) do
				v2.propagate_on_click = true
				v2.propagate_on_touch_down = true
				v2.propagate_on_touch_up = true
			end
		end

		ktw:script(self, function(wait)
			screen_map:set_modal_view(self.overlay)
			fade_in(self.overlay, 0.5)
			fade_in(self:ci("group_upgrades_tutorial"), 0.5)

			for _, v in ipairs(self:ci("group_upgrades_tutorial").children) do
				scale_in(v, 0.9, 1.1, 0.5)
			end

			wait(0.5)

			self.can_close_tutorial = true
		end)

		function self.overlay.on_click(this)
			this:hide()
		end

		function self.overlay.hide(this)
			if self.can_close_tutorial then
				self.can_close_tutorial = false

				ktw:script(self, function(wait)
					screen_map:remove_modal_view()
					fade_out(self.overlay, 0.5)
					fade_out(self:ci("group_upgrades_tutorial"), 0.5)
					wait(0.5)

					self.overlay.hidden = true
					self:ci("group_upgrades_tutorial").hidden = true
				end)
			end
		end
	end

	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = true
	end
end

function UpgradesRoomView:hide()
	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = false
	end

	UpgradesRoomView.super.hide(self)

	self:get_window():ci(self.background_id).on_click = nil

	self:hide_upgrade_tooltip()
	screen_map:update_badges()
end

function UpgradesRoomView:update_available_points()
	local remaining_points = self:get_remaining_points()

	self:ci("label_upgrade_points").text = remaining_points

	local user_data = storage:load_slot()

	for _, u in ipairs(self.upgrades) do
		if remaining_points < u.cost then
			u:set_unavailable()
		elseif table.contains(user_data.upgrades[u.group], u.idx) then
			u:set_picked()
		else
			local previous_upgrades = UPGR:get_previous_upgrades(u.group, u.idx)

			if not previous_upgrades or #previous_upgrades == 0 then
				u:set_available()
			elseif previous_upgrades then
				local previous_is_picked = false

				for _, previous_upgrade in ipairs(previous_upgrades) do
					if table.contains(user_data.upgrades[u.group], previous_upgrade.id) then
						previous_is_picked = true

						break
					end
				end

				if previous_is_picked then
					u:set_available()
				else
					u:set_unavailable()
				end
			else
				u:set_unavailable()
			end
		end
	end

	local some_upgrade_picked = false

	for _, u in ipairs(self.upgrades) do
		if u:is_upgrade_picked() then
			some_upgrade_picked = true

			if u.upgrade.blocks and #u.upgrade.blocks > 0 then
				for _, block_id in ipairs(u.upgrade.blocks) do
					for _, search_upgrade in ipairs(self.upgrades) do
						if search_upgrade.idx == block_id and search_upgrade.group == u.group then
							search_upgrade:set_unavailable()
						end
					end
				end
			end
		end
	end

	if some_upgrade_picked then
		self:ci("upgrades_room_reset_button"):enable()
	else
		self:ci("upgrades_room_reset_button"):disable()
	end
end

function UpgradesRoomView:update_links()
	for _, l in ipairs(self.links) do
		l.hidden = true
	end

	local user_data = storage:load_slot()

	for _, u in pairs(UPGR.list) do
		if table.contains(user_data.upgrades[u.class], u.id) then
			local previous_upgrades = UPGR:get_previous_upgrades(u.class, u.id)

			if previous_upgrades and #previous_upgrades > 0 then
				for _, previous_upgrade in ipairs(previous_upgrades) do
					if table.contains(user_data.upgrades[previous_upgrade.class], previous_upgrade.id) then
						local link_name = string.format("%s_link_%02d_%02d", u.class, previous_upgrade.id, u.id)

						self:ci(link_name).hidden = false
					end
				end
			end
		end
	end
end

function UpgradesRoomView:spent(cost)
	self:ci("upgrades_room_reset_button"):enable()
	self:update_available_points()
end

function UpgradesRoomView:show_upgrade_tooltip(upgrade)
	local function set_arrow(tooltip_left)
		for i = 1, 4 do
			self.tooltip_view:ci("upgrade_tooltip_arrow_" .. i).hidden = true
		end

		local turn_on

		if tooltip_left then
			turn_on = 3
		end

		if not tooltip_left then
			turn_on = 1
		end

		local arrow = self.tooltip_view:ci("upgrade_tooltip_arrow_" .. turn_on)

		arrow.hidden = false

		return arrow
	end

	local function set_size_and_pos_tooltip(upgrade, tooltip_left)
		local title = self.tooltip_view:ci("label_upgrades_room_tooltip_title")
		local description = self.tooltip_view:ci("label_upgrades_room_tooltip_desc")
		local background = self.tooltip_view:ci("hero_room_skill_tooltip_bg")

		title.fit_size = false
		description.fit_size = false

		local tw_title, twc_title = title:get_wrap_lines()
		local font_height_title = title:get_font_height()
		local tw_description, twc_description = description:get_wrap_lines()
		local font_height_description = description:get_font_height()
		local blank_space = font_height_description / 2

		background.size.y = twc_description * font_height_description + twc_title * font_height_title + title.pos.y + blank_space
		background.pos.y = background.size.y / 2
		description.pos.y = 40 + (twc_title - 1) * font_height_title
		self.tooltip_view:ci("upgrade_tooltip_arrow_3").pos.y = background.size.y / 2
		self.tooltip_view:ci("upgrade_tooltip_arrow_1").pos.y = background.size.y / 2

		local pos_y_adjustment = 0

		pos_y_adjustment = pos_y_adjustment + self.tooltip_view:ci("upgrade_tooltip_arrow_3").size.y

		if twc_description < 2 then
			pos_y_adjustment = font_height_description / 2
		elseif twc_description == 2 then
			pos_y_adjustment = blank_space
		elseif twc_description > 2 then
			pos_y_adjustment = font_height_description * (twc_description - 3) / 2 * -1
		end

		local pos_y = pos_y_adjustment

		pos_y = pos_y + self:ci("group_upgrades_" .. upgrade.group).pos.y + upgrade.pos.y - upgrade.size.y / 2

		local tooltip_up = upgrade.pos.y < -200
		local tooltip_down = upgrade.pos.y >= 200

		if tooltip_up then
			local diff = background.size.y - upgrade.size.y

			pos_y = pos_y + diff / 2
			self.tooltip_view:ci("upgrade_tooltip_arrow_3").pos.y = background.size.y / 2 - diff / 2 - blank_space / 2
			self.tooltip_view:ci("upgrade_tooltip_arrow_1").pos.y = background.size.y / 2 - diff / 2 - blank_space / 2
		elseif tooltip_down then
			if background.size.y > upgrade.size.y then
				local diff = background.size.y - upgrade.size.y

				pos_y = pos_y - diff / 2
				self.tooltip_view:ci("upgrade_tooltip_arrow_3").pos.y = background.size.y / 2 + diff / 2 - 5
				self.tooltip_view:ci("upgrade_tooltip_arrow_1").pos.y = background.size.y / 2 + diff / 2 - 5
			end
		else
			self.tooltip_view:ci("upgrade_tooltip_arrow_3").pos.y = self.tooltip_view:ci("upgrade_tooltip_arrow_3").pos.y - 8
			self.tooltip_view:ci("upgrade_tooltip_arrow_1").pos.y = self.tooltip_view:ci("upgrade_tooltip_arrow_1").pos.y - 8
		end

		self.tooltip_view.pos.y = pos_y

		local pos_x = self:ci("group_upgrades_" .. upgrade.group).pos.x + upgrade.pos.x

		if tooltip_left then
			pos_x = pos_x - upgrade.size.x / 2
			pos_x = pos_x - self.tooltip_view:ci("hero_room_skill_tooltip_bg").size.x
			pos_x = pos_x - self.tooltip_view:ci("upgrade_tooltip_arrow_1").size.x
		else
			pos_x = pos_x + upgrade.size.x / 2
			pos_x = pos_x + self.tooltip_view:ci("upgrade_tooltip_arrow_1").size.x
		end

		self.tooltip_view.pos.x = pos_x
	end

	local tooltip_left = table.contains({
		"reinforcements",
		"alliance"
	}, upgrade.group)

	self.tooltip_view:ci("label_upgrades_room_tooltip_title").text = _(upgrade.upgrade.key .. "_NAME")
	self.tooltip_view:ci("label_upgrades_room_tooltip_desc").text = GU.balance_format(_(upgrade.upgrade.key .. "_DESCRIPTION"), balance)

	set_size_and_pos_tooltip(upgrade, tooltip_left)
	set_arrow(tooltip_left)

	local background = self.tooltip_view:ci("hero_room_skill_tooltip_bg")
	local t = self.tooltip_view

	t.alpha = 0
	t.hidden = false
	t.anchor.y = background.size.y / 2
	t.pos.y = t.pos.y + background.size.y / 2

	if tooltip_left then
		t.anchor.x = background.size.x
		t.pos.x = t.pos.x + background.size.x
	else
		t.anchor.x = 0
	end

	local ktw = self:get_window().ktw

	ktw:cancel(t)

	t.scale = {
		x = 0.77,
		y = 0.77
	}
	t.alpha = 0.74

	ktw:tween(t, 0.233, nil, {
		alpha = 1,
		scale = {
			x = 1,
			y = 1
		}
	}, "out-back")
end

function UpgradesRoomView:hide_upgrade_tooltip()
	if self.tooltip_view then
		local t = self.tooltip_view
		local ktw = self:get_window().ktw

		ktw:cancel(t)
		ktw:tween(t, 0.2, nil, {
			alpha = 0
		}, "in-quad", function()
			t.hidden = true
		end)
	end
end

function UpgradesRoomView:get_remaining_points()
	return UPGR:get_current_points_by_level() - UPGR:get_spent_points()
end

UpgradeRoomLinkOnView = class("UpgradeRoomLinkOnView", KImageView)
UpgradeTooltipView = class("UpgradeTooltipView", KImageView)

function UpgradeTooltipView:initialize(image_name)
	KImageView.initialize(self, image_name)

	for _, c in pairs(self.children) do
		c.propagate_on_click = true
		c.propagate_on_up = true
		c.propagate_on_down = true
	end
end

UpgradeRoomUpgradeView = class("UpgradeRoomUpgradeView", GG5Button)
UpgradeRoomUpgradeView.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function UpgradeRoomUpgradeView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self:ci("animation_upgrade_select_fx").hidden = true
	self:ci("animation_upgrade_select_fx").loop = false
	self:ci("animation_upgrade_select_fx").hide_at_end = true
	self:ci("image_upgrade_cost_bg_disabled").hidden = true
	self:ci("label_upgrade_cost_disabled").hidden = true
	self:ci("image_upgrade_bought").hidden = true
	self:ci("image_upgrade_level_up").hidden = true
	self:ci("image_upgrade_level_up_disabled").hidden = true
	self:ci("image_upgrade_sell").hidden = true
	self:ci("image_upgrade_sell_disabled").hidden = true
	self.image_offset.x = self.image_offset.x - 2
	self.image_offset.y = self.image_offset.y + 1

	self:set_focus_below_child(self:ci("image_upgrade_cost_bg"))

	self.flash_view = self:ci("upgrade_flash")
	self.flash_view.propagate_on_down = true
	self.flash_view.propagate_on_up = true
	self.flash_view.propagate_on_click = true
	self.flash_view.propagate_drag = true
	self.flash_view.alpha = 0

	if KR_PLATFORM == "android" or KR_PLATFORM == "ios" then
		local h = KImageView:new(focus_image_name)

		h.hidden = true

		if self.image_offset then
			h.image_offset = self.image_offset
		end

		self:add_child(h)
		h:order_below(self:ci("image_upgrade_cost_bg"))

		self.focus_image = h
	end
end

function UpgradeRoomUpgradeView:load(group, idx)
	local group_extracted = string.split(group, "_")[3]

	self.group = group_extracted
	self.idx = idx

	local u = UPGR:get_by_group_idx(group_extracted, idx)

	self.upgrade = u
	self.cost = u.price

	self:ci("upgrade_icon"):set_image(string.format("upgrades_room_icons_%s_%02i_%04i", self.group, idx, 1))

	self:ci("label_upgrade_cost").text = self.cost
	self:ci("label_upgrade_cost_disabled").text = self.cost

	if self:is_upgrade_picked() then
		self:set_picked()
		self:get_parent_of_class(UpgradesRoomView):spent(self.cost)
	else
		self:set_unavailable()
	end
end

function UpgradeRoomUpgradeView:is_upgrade_picked()
	local user_data = storage:load_slot()

	return table.contains(user_data.upgrades[self.group], self.idx)
end

function UpgradeRoomUpgradeView:set_picked()
	self:ci("image_upgrade_bought").hidden = false
	self:ci("image_upgrade_cost_bg").hidden = true
	self:ci("image_upgrade_cost_bg_disabled").hidden = true
	self:ci("label_upgrade_cost").hidden = true
	self:ci("label_upgrade_cost_disabled").hidden = true
end

function UpgradeRoomUpgradeView:set_available()
	self:ci("upgrade_icon"):set_image(string.format("upgrades_room_icons_%s_%02i_%04i", self.group, self.idx, 1))

	self:ci("image_upgrade_bought").hidden = true
	self:ci("image_upgrade_cost_bg").hidden = false
	self:ci("image_upgrade_cost_bg_disabled").hidden = true
	self:ci("label_upgrade_cost").hidden = false
	self:ci("label_upgrade_cost_disabled").hidden = true
	self.unavailable = false
end

function UpgradeRoomUpgradeView:set_unavailable()
	if not self:is_upgrade_picked() then
		self:ci("image_upgrade_cost_bg_disabled").hidden = false
		self:ci("label_upgrade_cost_disabled").hidden = false

		self:ci("upgrade_icon"):set_image(string.format("upgrades_room_icons_%s_disabled_%02i_%04i", self.group, self.idx, 1))

		self:ci("image_upgrade_bought").hidden = true
		self.unavailable = true
	end
end

function UpgradeRoomUpgradeView:deselect()
	self.is_selected = false

	self:get_parent_of_class(UpgradesRoomView):hide_upgrade_tooltip()

	self:ci("image_upgrade_level_up").hidden = true
	self:ci("image_upgrade_level_up_disabled").hidden = true
	self:ci("image_upgrade_sell").hidden = true

	if self.focus_image then
		self.focus_image.hidden = true
	end
end

function UpgradeRoomUpgradeView:select()
	self.is_selected = true

	self:get_parent_of_class(UpgradesRoomView):show_upgrade_tooltip(self)

	if self:is_upgrade_picked() then
		self:ci("image_upgrade_sell").hidden = false
	else
		local remaining_points = self:get_parent_of_class(UpgradesRoomView):get_remaining_points()

		if self.cost then
			if remaining_points >= self.cost and not self.unavailable then
				self:ci("image_upgrade_level_up").hidden = false
				self:ci("image_upgrade_level_up_disabled").hidden = true
			else
				self:ci("image_upgrade_level_up").hidden = true
				self:ci("image_upgrade_level_up_disabled").hidden = false
			end
		end
	end

	if self.focus_image then
		self.focus_image.hidden = false
	end
end

function UpgradeRoomUpgradeView:on_exit(drag_view)
	self.class.super.on_exit(self, drag_view)
	self:deselect()
end

function UpgradeRoomUpgradeView:on_enter(drag_view)
	for _, v in pairs(self:get_parent_of_class(UpgradesRoomView):flatten()) do
		if v ~= self and v:isInstanceOf(UpgradeRoomUpgradeView) then
			v:on_exit()
		end
	end

	self.class.super.on_enter(self, drag_view)

	if not IS_MOBILE then
		self:select()
	end
end

function UpgradeRoomUpgradeView:on_click()
	if self.is_selected then
		self:pick_upgrade()
		self:deselect()

		if not IS_MOBILE then
			self:select()
		end
	else
		S:queue("GUIHeroSkillSelect")
		self:select()

		if not self:is_upgrade_picked() then
			self:flash()
		end
	end
end

function UpgradeRoomUpgradeView:flash()
	self.flash_view.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(self.flash_view)
	ktw:tween(self.flash_view, 0.2, self.flash_view, {
		alpha = 0
	}, "in-quad")
end

function UpgradeRoomUpgradeView:pick_upgrade()
	if self:is_upgrade_picked() then
		local user_data = storage:load_slot()
		local recovered_points = 0

		local function sell_upgrade(upg)
			recovered_points = recovered_points + upg.price

			for upg_idx, upg_id in ipairs(user_data.upgrades[upg.class]) do
				if upg_id == upg.id then
					table.remove(user_data.upgrades[upg.class], upg_idx)

					break
				end
			end

			for _, upg_id in ipairs(upg.next) do
				if table.contains(user_data.upgrades[upg.class], upg_id) then
					local previous_upgrades = UPGR:get_previous_upgrades(upg.class, upg_id)

					if not previous_upgrades or #previous_upgrades <= 1 then
						sell_upgrade(UPGR:get_by_group_idx(upg.class, upg_id))
					else
						local previous_is_picked = false

						for _, previous_upgrade in ipairs(previous_upgrades) do
							if table.contains(user_data.upgrades[upg.class], previous_upgrade.id) then
								previous_is_picked = true

								break
							end
						end

						if not previous_is_picked then
							sell_upgrade(UPGR:get_by_group_idx(upg.class, upg_id))
						end
					end
				end
			end
		end

		sell_upgrade(UPGR:get_by_group_idx(self.group, self.idx))
		S:queue("GUIResetUpgrade")
		storage:save_slot(user_data)
		self:get_parent_of_class(UpgradesRoomView):spent(-recovered_points)
		self:get_parent_of_class(UpgradesRoomView):update_links()
	else
		local remaining_points = self:get_parent_of_class(UpgradesRoomView):get_remaining_points()

		if remaining_points < self.cost then
			S:queue("GUIButtonUnavailable")

			return
		end

		if self.unavailable then
			S:queue("GUIButtonUnavailable")

			return
		end

		S:queue("GUIHeroSkillConfirm")

		local user_data = storage:load_slot()

		table.insert(user_data.upgrades[self.group], self.idx)
		storage:save_slot(user_data)

		self:ci("animation_upgrade_select_fx").ts = 0
		self:ci("animation_upgrade_select_fx").hidden = false

		self:set_picked()
		self:get_parent_of_class(UpgradesRoomView):spent(self.cost)
		self:get_parent_of_class(UpgradesRoomView):update_links()
	end
end

AchievementItem = class("AchievementItem", KView)

function AchievementItem:initialize(ach)
	AchievementItem.super.initialize(self)

	self.ach = ach

	local user_data = storage:load_slot()

	self.completed = user_data.achievements[ach.name]
	self.claimed = user_data.achievements_claimed and table.contains(user_data.achievements_claimed, ach.name)

	if not IS_MOBILE then
		self.claimed = true
	end

	local card

	if self.completed then
		card = KView:new_from_table(kui_db:get_table("group_achievement_room_achievement"))

		self:add_child(card)

		card:ci("label_achievement_room_desc").text = _("ACHIEVEMENT_" .. ach.name .. "_DESCRIPTION")
		card:ci("label_achievement_room_name").text = _("ACHIEVEMENT_" .. ach.name .. "_NAME")

		local icon = card:ci("image_achievements_room_achievement_icon")

		icon:set_image("achievements_icons_" .. string.format("%03i", ach.icon) .. "_0001")

		if self.claimed then
			if not IS_MOBILE then
				function icon.on_click(this)
					log.info("Manually retriggering achievement signal for ach %s", ach.name)
					signal.emit("got-achievement", ach.name)
				end
			end
		else
			card.hidden = true

			local card_claim = KView:new_from_table(kui_db:get_table("group_achievement_room_claim"))

			self:add_child(card_claim)

			card_claim:ci("label_achievement_room_claim_gems").text = ach.reward
			card_claim:ci("image_achievement_room_claim_glow_fx").alpha = 0
			card_claim:ci("animation_achievement_room_claim_gems").hidden = true
			card_claim:ci("achievement_room_achievement_claim_button").hidden = true

			local icon_claim = card_claim:ci("image_achievements_room_achievement_icon")

			icon_claim:set_image("achievements_icons_" .. string.format("%03i", ach.icon) .. "_0001")

			local button = card_claim:ci("achievement_room_achievement_claim_button")

			button.elapsed_time = 0
			button.fade_out_time = 0
			button.ach = ach
			button.hidden = false

			for _, v in pairs(GS.dlc_names) do
				button:ci("image_" .. v.id .. "_flag").hidden = not ach.dlc or ach.dlc ~= v.id
			end

			function button.on_click(this)
				this:disable(false)

				self.claimed = true
				card.hidden = false

				local ktw = this:get_window().ktw

				ktw:tween(this, 1, this, {
					alpha = 0
				}, "out-quad")

				local gems_anim = self:ci("animation_achievement_room_claim_gems")

				gems_anim.ts = 0
				gems_anim.hidden = false
				gems_anim.loop = false

				local fx = self:ci("image_achievement_room_claim_glow_fx")

				ktw:tween(fx, 0.1, fx, {
					alpha = 0
				}, "out-quad")
				S:queue("GUIAchievementClaim")

				if user_data.achievements_claimed and not user_data.achievements_claimed[ach.name] then
					table.insert(user_data.achievements_claimed, ach.name)

					user_data.gems = (user_data.gems or 0) + ach.reward

					storage:save_slot(user_data)
					screen_map:update_gems(user_data.gems)
				end
			end
		end
	else
		card = KView:new_from_table(kui_db:get_table("group_achievement_room_achievement_disabled"))

		self:add_child(card)

		card:ci("label_achievement_room_desc_disabled").text = _("ACHIEVEMENT_" .. ach.name .. "_DESCRIPTION")
		card:ci("label_achievement_room_name_disabled").text = _("ACHIEVEMENT_" .. ach.name .. "_NAME")
		card:ci("label_achievement_room_gem_reward").text = ach.reward

		local icon = card:ci("image_achievements_room_achievement_icon")

		icon:set_image("achievements_icons_" .. string.format("%03i", ach.icon) .. "_disabled_0001")

		if not IS_MOBILE then
			card:ci("label_achievement_room_gem_reward").hidden = true
			card:ci("image_achievements_room_gems_bg").hidden = true
		end

		if ach.goal then
			local progress = 0

			if user_data.achievement_counters then
				progress = user_data.achievement_counters[ach.name] or 0
			end

			if ach.name == "RUNEQUEST" then
				local runes = {
					1,
					2,
					4,
					8,
					16,
					32
				}
				local collected_runes = 0

				for _, rune in ipairs(runes) do
					if bit.band(progress, rune) ~= 0 then
						collected_runes = collected_runes + 1
					end
				end

				progress = collected_runes
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/6"

				local progress_value = progress * 222 / 6

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			elseif ach.name == "IRONCLAD" then
				local iron_completed = 0

				for i = 1, 15 do
					if bit.band(progress, 2^(i - 1)) ~= 0 then
						iron_completed = iron_completed + 1
					end
				end

				progress = iron_completed
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/15"

				local progress_value = progress * 222 / 15

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			elseif ach.name == "AGE_OF_HEROES" then
				local hero_completed = 0

				for i = 1, 15 do
					if bit.band(progress, 2^(i - 1)) ~= 0 then
						hero_completed = hero_completed + 1
					end
				end

				progress = hero_completed
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/15"

				local progress_value = progress * 222 / 15

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			elseif ach.name == "SEASONED_GENERAL" then
				local hard_completed = 0

				for i = 1, 16 do
					if bit.band(progress, 2^(i - 1)) ~= 0 then
						hard_completed = hard_completed + 1
					end
				end

				progress = hard_completed
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/16"

				local progress_value = progress * 222 / 16

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			elseif ach.name == "MASTER_TACTICIAN" then
				local impossible_completed = 0

				for i = 1, 16 do
					if bit.band(progress, 2^(i - 1)) ~= 0 then
						impossible_completed = impossible_completed + 1
					end
				end

				progress = impossible_completed
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/16"

				local progress_value = progress * 222 / 16

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			elseif ach.name == "OVINE_JOURNALISM" then
				local sheepy_taps = 0

				for i = 0, 2 do
					if bit.band(progress, 2^i) ~= 0 then
						sheepy_taps = sheepy_taps + 1
					end
				end

				progress = sheepy_taps
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/3"

				local progress_value = progress * 222 / 3

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			elseif ach.name == "WE_ARE_ALL_MAD_HERE" then
				local cheshine_cat_taps = 0

				for i = 0, 2 do
					if bit.band(progress, 2^i) ~= 0 then
						cheshine_cat_taps = cheshine_cat_taps + 1
					end
				end

				progress = cheshine_cat_taps
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/3"

				local progress_value = progress * 222 / 3

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			elseif ach.name == "OBLITERATE" then
				local exodia_parts = 0

				for i = 0, 4 do
					if bit.band(progress, 2^i) ~= 0 then
						exodia_parts = exodia_parts + 1
					end
				end

				progress = exodia_parts
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/5"

				local progress_value = progress * 222 / 5

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			else
				card:ci("label_achievement_room_achievement_progress").text = progress .. "/" .. ach.goal

				local progress_value = progress * 222 / ach.goal

				if progress_value >= 1 then
					card:ci("image_achievements_room_progress_bar").size.x = progress_value
				else
					card:ci("image_achievements_room_progress_bar").hidden = true
				end
			end
		else
			card:ci("label_achievement_room_achievement_progress").text = "0/1"
			card:ci("image_achievements_room_progress_bar").hidden = true
		end
	end

	for _, v in pairs(GS.dlc_names) do
		card:ci("image_" .. v.id .. "_flag").hidden = not ach.dlc or ach.dlc ~= v.id
	end

	self.image_claim_glow_fx = self:ci("image_achievement_room_claim_glow_fx")
end

function AchievementItem:update(dt)
	if IS_MOBILE then
		if math.abs(self.pos.x - self.room.slider_container.pos.x * -1) > screen_map.sw + 1012 then
			self.hidden = true

			return
		else
			self.hidden = false
		end
	end

	AchievementItem.super.update(self, dt)

	if self.completed and not self.claimed then
		local amplitude = 0.05
		local frecuency = 0.9
		local offset = 0.05
		local alpha_value = amplitude * math.sin(2 * math.pi * frecuency * self.ts) + offset

		self.image_claim_glow_fx.alpha = alpha_value
	end
end

AchievementsRoomView = class("AchievementsRoomView", RoomView)

function AchievementsRoomView:initialize(size, image_name, base_scale)
	AchievementsRoomView.super.initialize(self, size, image_name, base_scale)

	self:ci("group_achievements_room_cards_container"):ci("group_achievement_room_claim").hidden = true
	self:ci("group_achievement_room_achievement_disabled").hidden = true
	self:ci("group_achievement_room_achievement").hidden = true
	self:ci("achievement_room_amount_indicator_left_button").hidden = true
	self:ci("achievement_room_amount_indicator_button").hidden = true
	self:ci("group_achievements_room_container"):ci("button_achievements_room_confirm_ok").hidden = not IS_MOBILE
	self:ci("group_achievements_room_container"):ci("button_achievements_room_confirm_ok"):ci("label_button_ok").text = _("BUTTON_DONE")
	self:ci("group_achievements_room_container"):ci("button_achievements_room_confirm_ok").on_click = function(this)
		S:queue("GUIButtonOut")
		self:hide()
	end
	self.last_indicators_ts = nil

	if not IS_MOBILE then
		self.page_idx = 1
		self.item_positions = {}

		local page = self:ci("achievements_page_desktop")

		for i = 1, #page.children do
			local c = page:ci(string.format("ach_%02i", i))

			table.insert(self.item_positions, {
				id = c.id,
				pos = c.pos
			})
		end

		page:remove_children()
		self:ci("pager"):setup(math.ceil(#achievements_data / #self.item_positions), self, self.show_page)
		self:ci("pager"):show_page(1)

		self:ci("button_close_popup").on_click = function(this)
			S:queue("GUIButtonOut")
			self:hide()
		end
	else
		local row = 0
		local column = 0
		local card_separation_x = 20
		local card_separation_y = 20
		local size_x = 506 + card_separation_x
		local size_y = 180 + card_separation_y
		local offset_x = 120
		local card_container = self:ci("group_achievements_room_cards_container")
		local safe_frame = SU.get_safe_frame(screen_map.w, screen_map.h, screen_map.ref_w, screen_map.ref_h)

		card_container.pos.x, card_container.pos.y = safe_frame.l, safe_frame.t + 22.5

		if IS_TABLET then
			card_container.pos.x = card_container.pos.x - 150
		end

		self.slider_container = KInertialView:new()
		self.slider_container.id = "achievement_room_slider_container"
		self.slider_container.size = V.v(math.ceil(#achievements_data / 3) * size_x + offset_x, size_y * 3)
		self.slider_container.can_drag = true
		self.sides_extend = 300
		self.slider_container.inertia_damping = 0.976

		local drag_limit_x = (card_container.pos.x + math.ceil(#achievements_data / 3) * size_x - screen_map.sw + offset_x * 2 + self.sides_extend * 2) * -1

		if IS_TABLET then
			drag_limit_x = drag_limit_x - 150 + size_x / 2
		end

		self.slider_container.drag_limits = V.r(self.sides_extend, 0, drag_limit_x, 0)
		self.slider_container.drag_threshold = 30

		card_container:add_child(self.slider_container)

		local group = KView:new(V.vclone(self.slider_container.size))

		group.id = "items_group"

		self.slider_container:add_child(group)

		for i = 1, #achievements_data do
			local ach = achievements_data[i]
			local item = AchievementItem:new(ach)

			item.room = self

			local calculated_x = (column + 1) * size_x - size_x / 2

			calculated_x = calculated_x + offset_x

			local calculated_y = (row + 1) * size_y - size_y / 2

			item.pos.x, item.pos.y = calculated_x, calculated_y

			group:add_child(item)

			row = row + 1

			if row == 3 then
				row = 0
				column = column + 1
			end
		end

		local function scroll_to_next(button, direction)
			local left = direction == "left"
			local closest_distance = 1e+99
			local closest_achievement
			local room = button:get_parent_of_class(AchievementsRoomView)

			for _, item in pairs(room.slider_container:ci("items_group").children) do
				if item.completed and not item.claimed then
					local dist = left and room.slider_container.pos.x * -1 - item.pos.x or item.pos.x - room.slider_container.pos.x * -1
					local is_towards

					if left then
						is_towards = item.pos.x < room.slider_container.pos.x * -1
					else
						is_towards = item.pos.x > (room.slider_container.pos.x - screen_map.sw) * -1
					end

					if is_towards and dist < closest_distance then
						closest_distance = dist
						closest_achievement = item
					end
				end
			end

			if closest_achievement then
				room.slider_container:kmdi_reset_inertia()

				local move_destination = closest_achievement.pos.x

				move_destination = km.clamp(0, room.slider_container.size.x, move_destination - screen_map.sw / 2 + offset_x - card_separation_x * 2)

				local ktw = room:get_window().ktw

				ktw:cancel(room.slider_container)
				ktw:tween(room.slider_container, 0.5, room.slider_container.pos, {
					x = move_destination * -1,
					y = room.slider_container.pos.y
				}, "out-quad")
			end
		end

		self:ci("achievement_room_amount_indicator_left_button").on_click = function(this)
			scroll_to_next(this, "left")
		end
		self:ci("achievement_room_amount_indicator_button").on_click = function(this)
			scroll_to_next(this, "right")
		end
	end
end

function AchievementsRoomView:destroy()
	AchievementsRoomView.super.destroy(self)
end

function AchievementsRoomView:change_page(dir)
	local items_per_page = #self.item_positions
	local page_count = math.ceil(#achievements_data / items_per_page)

	self.page_idx = self.page_idx or 1

	if dir == "next" then
		self.page_idx = km.clamp(1, page_count, self.page_idx + 1)
	elseif dir == "prev" then
		self.page_idx = km.clamp(1, page_count, self.page_idx - 1)
	end

	local pager = self:ci("pager")

	if pager and pager:isInstanceOf(GG5Pager) then
		pager:show_page(self.page_idx)
	else
		self:show_page(self.page_idx)
	end
end

function AchievementsRoomView:show_page(page_idx)
	local page = self:ci("achievements_page_desktop")

	page:remove_children()

	self.page_idx = page_idx

	local items_per_page = #self.item_positions
	local first_item_idx = (page_idx - 1) * items_per_page + 1

	for i = 1, items_per_page do
		local ach = achievements_data[first_item_idx + i - 1]

		if not ach then
			break
		end

		local id = self.item_positions[i].id
		local pos = self.item_positions[i].pos
		local item = AchievementItem:new(ach)

		item.id = id
		item.pos = pos
		item.room = self

		page:add_child(item)
	end
end

function AchievementsRoomView:show()
	AchievementsRoomView.super.show(self)

	if self.slider_container then
		self.slider_container:ci("items_group").clip_view = self:get_window()

		self.slider_container:kmdi_reset_inertia()

		self.slider_container.pos.x = 0
	end
end

function AchievementsRoomView:hide()
	AchievementsRoomView.super.hide(self)

	self:get_window():ci(self.background_id).on_click = nil
end

function AchievementsRoomView:update(dt)
	AchievementsRoomView.super.update(self, dt)

	if not self.elapsed_time then
		self.elapsed_time = 0
	end

	if not self.last_indicators_ts then
		self.last_indicators_ts = 0
	end

	self.elapsed_time = self.elapsed_time + dt

	if KR_PLATFORM == "android" or KR_PLATFORM == "ios" then
		if #love.touch.getTouches() == 0 then
			if self.slider_container.pos.x > 0 then
				if self.slider_container.pos.x >= self.sides_extend then
					self.slider_container:kmdi_reset_inertia()
				end

				local new_pos_x = self.slider_container.pos.x + (0 - self.slider_container.pos.x) * (self.elapsed_time / 2)

				self.slider_container.pos.x = km.clamp(self.sides_extend, 0, new_pos_x)
			elseif self.slider_container.pos.x < self.slider_container.drag_limits.size.x + self.sides_extend * 2 then
				if self.slider_container.pos.x <= self.slider_container.drag_limits.size.x + self.sides_extend then
					self.slider_container:kmdi_reset_inertia()
				end

				local max_pos = self.slider_container.drag_limits.size.x + self.sides_extend * 2
				local new_pos_x = self.slider_container.pos.x + (max_pos - self.slider_container.pos.x) * (self.elapsed_time / 2)

				self.slider_container.pos.x = km.clamp(max_pos, max_pos - self.sides_extend * 2, new_pos_x)
			end
		else
			self.elapsed_time = 0
			self.last_indicators_ts = 0
		end
	end

	if self.slider_container and self.elapsed_time - self.last_indicators_ts >= 0.2 then
		self.last_indicators_ts = self.elapsed_time

		local total_on_left = 0
		local total_on_right = 0

		for _, item in pairs(self.slider_container:ci("items_group").children) do
			if item.completed and not item.claimed then
				if item.pos.x < self.slider_container.pos.x * -1 then
					total_on_left = total_on_left + 1
				end

				if item.pos.x > (self.slider_container.pos.x - screen_map.sw) * -1 then
					total_on_right = total_on_right + 1
				end
			end
		end

		if total_on_left > 0 then
			self:ci("achievement_room_amount_indicator_left_button").hidden = false
			self:ci("achievement_room_amount_indicator_left_button"):ci("label_achievement_room_amount_indicator").text = total_on_left
		else
			self:ci("achievement_room_amount_indicator_left_button").hidden = true
		end

		if total_on_right > 0 then
			self:ci("achievement_room_amount_indicator_button").hidden = false
			self:ci("achievement_room_amount_indicator_button"):ci("label_achievement_room_amount_indicator").text = total_on_right
		else
			self:ci("achievement_room_amount_indicator_button").hidden = true
		end
	end
end

ShopOfferBubbleView = class("ShopOfferBubbleView", GG5Button)
ShopOfferBubbleView.static.instance_keys = {
	"id",
	"pos",
	"item_name"
}
ShopOfferBubbleView.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function ShopOfferBubbleView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self.propagate_drag = true
	self.propagate_on_down = true

	if self.season then
		self.hidden = false
		self.time_label = self:ci("label_map_shop")

		if self.time_label then
			self.time_label.hidden = true
		end
	else
		self.time_label = self:ci("label_map_shop")
		self.time_label.propagate_on_down = true
		self.time_label.propagate_on_up = true
		self.time_label.propagate_on_click = true
		self.time_label.propagate_drag = true
		self.time_label.propagate_enter = true
		self.hidden = not self.offer or not self.exp_time
	end

	self:ci("button_map_offer").on_click = function()
		S:queue("GUIButtonCommon")

		if self.season then
			screen_map:show_shop_season()
		else
			screen_map:show_shop_offer()
		end
	end
end

function ShopOfferBubbleView:update_offer(offer, exp_time)
	self.offer = offer
	self.exp_time = exp_time
	self.hidden = not self.offer or not self.exp_time
end

function ShopOfferBubbleView:update(dt)
	ShopOfferBubbleView.super.update(self, dt)

	if not self.hidden and not self.season then
		if not self.offer or not self.exp_time then
			self.hidden = true
		else
			local rem_time = os.difftime(self.exp_time, os.time())

			if rem_time < 0 then
				self.hidden = true
			else
				self.time_label.text = GU.format_countdown_time(rem_time, false)
			end
		end
	end
end

ShopRoomView = class("ShopRoomView", RoomView)

function ShopRoomView:initialize(size, image_name, base_scale)
	ShopRoomView.super.initialize(self, size, image_name, base_scale)

	local group = KView:new(V.v(screen_map.sw, screen_map.sh))
	local user_data = storage:load_slot()

	if not IS_MOBILE and PS.services.iap then
		local premium, exceptions = PS.services.iap:is_premium()

		if exceptions then
			self.page_idx = 1
			self.item_positions = {}

			local page = self:ci("pager")
			local dlc_count = #PS.services.iap:get_dlcs()

			self:ci("pager"):setup(1, self, self.show_page)
			self:ci("pager"):show_page(1)
		end

		self:ci("button_close_popup").on_click = function(this)
			S:queue("GUIButtonOut")
			self:hide()
		end
	else
		local hsl = KInertialView:new()

		self.shop_slider = hsl
		hsl.id = "shop_room_offer_slider"
		hsl.can_drag = true
		hsl.inertia_damping = 0.97
		hsl.inertia_stop_speed = 0.01

		self:add_child(hsl)

		local hrs_count = 6
		local hrs_w = hsl.size.x + 1
	end

	self.buttons_to_update = {}
end

function ShopRoomView:show_page(page_idx)
	local premium, exceptions = PS.services.iap:is_premium()

	self.page_idx = page_idx

	local container = self:ci("group_shop_offers_desktop")

	container:remove_children()

	local ctx = SU.new_screen_ctx(screen_map)

	for i, v in pairs(exceptions) do
		if v == "dlcs" then
			local dlcs = PS.services.iap:get_dlcs()

			log.info("mmmasdf asdf")
			log.info(getfulldump(dlcs))

			local dlc = dlcs[page_idx]
			local tt = kui_db:get_table("group_shop_offers_" .. dlc, ctx)
			local hs = ShopDesktopItemView:new_from_table(tt)

			hs:set_product(dlc)
			container:add_child(hs)
		end
	end
end

function ShopRoomView:refresh_offers(force)
	local hsl = self.shop_slider
	local ctx = SU.new_screen_ctx(screen_map)
	local hs_width = 0
	local hs_height = 0
	local items_name = iap_data.gems_order
	local width = 0
	local distance = 40
	local offset_y = -20
	local offset_x = IS_TABLET and 0 or 200

	if PS.services.iap and not PS.services.iap:is_premium() then
		if not features.censored_cn then
			local offer, exp_time = marketing:get_active_offer()

			if offer then
				if self.active_offer_id and offer.id == self.active_offer_id and not force then
					return
				else
					self.active_offer_id = offer.id
				end
			end

			hsl:remove_children()

			local peristent_offers = marketing:get_candidate_offers(true) or {}

			for k, v in pairs(peristent_offers) do
				local hs, cw = self:create_offer(v.id)

				if hs then
					hsl:add_child(hs)

					hs.pos.x = width + cw / 2

					if v.season_offer then
						self.pos_offer_season = -(width + cw / 2 - screen_map.sw / 2)
					end

					if v.dlc_offer then
						self.pos_offer_dlc = -(width + cw / 2 - screen_map.sw / 2)
					end

					hs.pos.y = 260
					width = width + cw + distance
				end
			end

			if RC and RC.v.one_time_gifts then
				local slot = storage:load_slot()

				if slot then
					if not slot.claimed_gifts then
						slot.claimed_gifts = {}
					end

					for k, v in pairs(RC.v.one_time_gifts) do
						if not table.contains(slot.claimed_gifts, v.id) then
							local hs, cw = self:create_gift(v)

							if hs then
								hsl:add_child(hs)

								hs.pos.x = width + cw / 2
								hs.pos.y = 260
								width = width + cw + distance
							end
						end
					end
				end
			end

			local offer, exp_time = marketing:get_active_offer()

			if offer then
				local hs, cw = self:create_offer(offer.id, exp_time)

				if hs then
					hsl:add_child(hs)

					hs.pos.x = width + cw / 2
					self.pos_offer_active = -(width + cw / 2 - screen_map.sw / 2)
					hs.pos.y = 260
					width = width + cw + distance

					signal.emit(SGN_MARKETING_OFFER_SHOWN, offer.id)
				end
			end

			self.pos_offer_gems = -(width - offset_x)
		end

		for i, v in ipairs(iap_data.gems_order) do
			local gems_item_data = iap_data.gems_data[v]
			local tt = kui_db:get_table("button_shop_gems_portrait", ctx)
			local hs = ShopSliderItemView:new_from_table(tt)

			hs:set_portrait("store_portraits_000" .. i)

			if gems_item_data.is_most_popular then
				hs:show_most_popular()
			end

			if gems_item_data.is_best_value then
				hs:show_best_value()
			end

			local product = PS.services.iap and PS.services.iap:get_product(items_name[i]) or {}

			hs:ci("label_shop_portrait_gems_quantity").text = product.reward or ""

			local price = "?"

			if product.price then
				price = string.gsub(product.price, " ", "")
			end

			hs:ci("label_shop_portrait_gems_cost").text = price
			hs.item_name = items_name[i]

			hs:set_name(i)

			hs.pos.x = width + (i - 1) * (hs.size.x + 4 + distance) + hs.size.x / 2
			hs.pos.y = hs.size.y * 0.5

			hsl:add_child(hs)

			hs_width = hs.size.x
			hs_height = hs.size.y
		end

		local hslb_gems = self:ci("group_shop_gems"):get_bounds_rect(true)
		local hslb_done = self:ci("group_shop_done"):get_bounds_rect(true)

		hsl.pos.x = hslb_gems.pos.x
		hsl.pos.y = hsl.pos.y - hs_height

		local drag_width = width + (hs_width + 3 + distance) * 6

		hsl.size = V.v(drag_width, hs_height)
		hsl.drag_limits = V.r(hslb_gems.pos.x, screen_map.sh / 2 - hs_height * 0.5 + offset_y, -drag_width + hslb_done.pos.x + hslb_done.size.x - offset_x, 0)
		hsl.elastic_limits = V.r(-drag_width * 2, screen_map.sh / 2 - hs_height * 0.5 + offset_y, (drag_width + hslb_gems.pos.x) * 2.5, 0)
	end
end

function ShopRoomView:create_offer(offer_name, exp_time)
	local ctx = SU.new_screen_ctx(screen_map)
	local width = 900

	ctx.small_offers = false
	ctx.big_offer = true
	ctx.all_heroes = false
	ctx.all_towers = false
	ctx.custom_offer = false

	local title = _("OFFER_ICON_BANNER")
	local description = _("OFFER_PACK_DESCRIPTION_TEXT_02")
	local prod = PS.services.iap:get_product(offer_name)

	if offer_name == "offer_allheroes" or prod.all_heroes then
		ctx.custom_offer = true
		ctx.all_heroes = true
		title = _("OFFER_PACK_TITLE_ALL_HEROES")
		description = _("OFFER_PACK_DESCRIPTION_ALL_HEROES")
	elseif offer_name == "offer_alltowers" or prod.all_towers then
		ctx.custom_offer = true
		ctx.all_towers = true
		title = _("OFFER_PACK_TITLE_ALL_TOWERS")
		description = _("OFFER_PACK_DESCRIPTION_ALL_TOWERS")
	end

	if not prod.price or not prod.price_micros then
		return nil, nil
	end

	if prod.custom_title then
		title = _(prod.custom_title)
	end

	if prod.custom_description then
		description = _(prod.custom_description)
	end

	marketing:patch_offer_prices(prod)

	local tn = "group_shop_offers"

	if prod.includes_consumables and #prod.includes_consumables < 3 or prod.includes and #prod.includes < 3 then
		tn = "group_shop_offers_x2"
		width = 700
	end

	local dlc = prod.includes and string.starts(prod.includes[1], "dlc") and prod.includes[1]

	if prod.season_offer then
		tn = "group_shop_offers_" .. prod.season_offer
	elseif dlc then
		tn = "group_shop_offers_" .. dlc
	end

	if prod.season_offer == "crocs" or prod.season_offer == "spider" or dlc then
		width = 950
	end

	local tt = kui_db:get_table(tn, ctx)
	local item = ShopOfferItemView:new_from_table(tt)

	item:set_offer(prod, title, description, exp_time)

	return item, width
end

function ShopRoomView:create_gift(gift)
	local ctx = SU.new_screen_ctx(screen_map)
	local width = 900

	ctx.small_offers = false
	ctx.big_offer = true
	ctx.all_heroes = false
	ctx.all_towers = false
	ctx.custom_offer = false

	local title = _("OFFER_ICON_BANNER")
	local description = _("OFFER_PACK_DESCRIPTION_TEXT_02")

	if gift.custom_title then
		title = _(gift.custom_title)
	end

	if gift.custom_description then
		description = _(gift.custom_description)
	end

	local tn = "group_shop_offers"

	if gift.includes_consumables and #gift.includes_consumables < 3 then
		tn = "group_shop_offers_x2"
		width = 700
	end

	local tt = kui_db:get_table(tn, ctx)
	local item = ShopOfferItemView:new_from_table(tt)

	item:set_gift(gift, title, description)

	return item, width
end

function ShopRoomView:destroy()
	ShopRoomView.super.destroy(self)
end

function ShopRoomView:show(go_to_section)
	ShopRoomView.super.show(self)
	self:refresh_offers()

	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = true

		local hslb_gems = self:ci("group_shop_gems"):get_bounds_rect(true)

		self.shop_slider.pos.x = hslb_gems.pos.x

		if go_to_section == "gems" and self.pos_offer_gems then
			self.shop_slider.pos.x = self.pos_offer_gems
		end

		if go_to_section == "offer" and self.pos_offer_active then
			self.shop_slider.pos.x = self.pos_offer_active
		end

		if go_to_section == "season" and self.pos_offer_season then
			self.shop_slider.pos.x = self.pos_offer_season
		end

		if go_to_section == "dlc" and self.pos_offer_dlc then
			self.shop_slider.pos.x = self.pos_offer_dlc
		end

		self:ci("button_shop_room_confirm_ok"):ci("label_button_ok").text = _("BUTTON_DONE")
		self:ci("button_shop_room_confirm_ok").on_click = function(this)
			S:queue("GUIButtonOut")
			self:hide()
		end

		local user_data = storage:load_slot()

		self:ci("label_shop_room_total_gems").text = string.format("%s", user_data.gems)

		self.shop_slider:kmdi_reset_inertia()
	end
end

function ShopRoomView:hide()
	if IS_MOBILE then
		self:get_window():ci("map_view").hidden = false
	end

	ShopRoomView.super.hide(self)

	self:get_window():ci(self.background_id).on_click = nil

	screen_map:process_new_dlc()
end

function ShopRoomView:update_gems(amount)
	if IS_MOBILE then
		self:ci("label_shop_room_total_gems").text = string.format("%s", amount)
	end
end

ShopDesktopItemView = class("ShopDesktopItemView", KView)

ShopDesktopItemView:append_serialize_keys("layout", "space")

ShopDesktopItemView.static.init_arg_names = {
	"size",
	"layout",
	"space"
}

function ShopDesktopItemView:set_product(prod_id)
	local tooltip = self:ci("group_mode_tooltip_2")

	tooltip.hidden = true

	local info_button = self:ci("button_offer_info")

	info_button.propagate_on_click = false
	info_button.propagate_on_down = false
	info_button.propagate_on_up = false

	function info_button.on_click(this)
		S:queue("GUIButtonCommon")

		tooltip.hidden = not tooltip.hidden
	end

	function info_button.on_exit(this)
		tooltip.hidden = true
	end

	local buy_button = self:ci("button_buy_dlc")
	local owned = table.contains(PS.services.iap:get_dlcs(true), prod_id)

	buy_button.hidden = owned
	buy_button:ci("label_button_price").text = "GET IT"
	buy_button:ci("label_button_price").on_click = function()
		PS.services.iap:purchase_product(prod_id)
	end

	local label_owned = self:ci("label_shop_dlc_purchased")

	label_owned.hidden = not owned
	label_owned.text = _("DLC_OWNED")
	self.prod_id = prod_id
end

ShopSliderItemView = class("ShopSliderItemView", GG5Button)
ShopSliderItemView.static.instance_keys = {
	"id",
	"pos",
	"tower_name"
}
ShopSliderItemView.static.init_arg_names = {
	"default_image_name",
	"focus_image_name"
}

function ShopSliderItemView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self.propagate_drag = true
	self.propagate_on_down = true
	self:ci("image_shop_gems_tag").hidden = true
	self:ci("label_shop_best_value").hidden = true
	self:ci("label_shop_most_popular").hidden = true
	self.drag_threshold = self.size.y / 4 / 768 * 320
end

function ShopSliderItemView:flash()
	self.flash_view.alpha = 1

	local ktw = self:get_window().ktw

	ktw:cancel(self.flash_view)
	ktw:tween(self.flash_view, 0.2, self.flash_view, {
		alpha = 0
	}, "in-quad")
end

function ShopSliderItemView:set_portrait(image)
	self:ci("image_shop_room_portrait"):set_image(image)
end

function ShopSliderItemView:show_best_value()
	self:ci("image_shop_gems_tag").hidden = false
	self:ci("label_shop_best_value").hidden = false
end

function ShopSliderItemView:set_name(index)
	self:ci("label_shop_title_gems").text = _("MAP_INAPP_GEM_PACK_" .. index)
end

function ShopSliderItemView:show_most_popular()
	self:ci("image_shop_gems_tag").hidden = false
	self:ci("label_shop_most_popular").hidden = false
end

function ShopSliderItemView:on_click()
	S:queue("GUIButtonCommon")

	if not PS.services.iap or not PS.services.iap:purchase_product(self.item_name) then
		signal.emit(SGN_SHOP_SHOW_MESSAGE, "iap_error")
		log.error("Error trying to purchase product %s", self.item_name)

		return
	end

	signal.emit(SGN_SHOP_SHOW_IAP_PROGRESS)
end

ShopOfferItemView = class("ShopOfferItemView", KView)

ShopOfferItemView:append_serialize_keys("layout", "space")

ShopOfferItemView.static.init_arg_names = {
	"size",
	"layout",
	"space"
}

function ShopOfferItemView:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	self.last_update = 0

	local function set_propagate_options(item, depth)
		if item.children and depth > 0 then
			for _, v2 in ipairs(item.children) do
				v2.propagate_on_click = true
				v2.propagate_on_down = true
				v2.propagate_on_up = true
				v2.propagate_drag = true

				set_propagate_options(v2, depth - 1)
			end
		end
	end

	set_propagate_options(self, 2)

	local button = self:ci("button_shop_offers_bg")

	button.drag_threshold = button.size.y / 4 / 768 * 320
end

function ShopOfferItemView:set_portrait(image)
	self:ci("image_shop_room_portrait"):set_image(image)
end

function ShopOfferItemView:set_name(index)
	self:ci("label_shop_title_gems").text = _("MAP_INAPP_GEM_PACK_" .. index)
end

function ShopOfferItemView:update(dt)
	ShopOfferItemView.super.update(self, dt)

	self.last_update = self.last_update + dt

	if self.update_text and self.last_update > 1 then
		self.last_update = 0

		local rem_time = os.difftime(self.expiration, os.time())

		self.update_text.text = self.end_time_text .. GU.format_countdown_time(rem_time, false)
	end
end

function ShopOfferItemView:set_offer(prod, title, sub_title, expiration)
	local offer_name = prod.id
	local price = "?"

	if prod.price then
		price = string.gsub(prod.price, " ", "")
	end

	self:ci("label_shop_offer_cost").text = price

	local discount_label = self:ci("label_shop_offer_discount")

	if discount_label and prod.price_micros and prod.price_micros ~= 0 and prod.old_price and prod.old_price ~= 0 then
		discount_label.text = math.ceil((prod.old_price - prod.price_micros) / prod.old_price * 100) .. "%"
	end

	if expiration then
		self.update_text = self:ci("label_shop_offer_ends_time")
		self.end_time_text = _("OFFER_PACK_TIMELEFT_TEXT") .. " "
		self.expiration = expiration

		local rem_time = os.difftime(expiration, os.time())

		self:ci("label_shop_offer_ends_time").text = self.end_time_text .. GU.format_countdown_time(rem_time, false)
	elseif self:ci("label_shop_offer_ends_time") then
		self:ci("label_shop_offer_ends_time").hidden = true
	end

	self:ci("label_shop_special_offer_title").text = title
	self:ci("label_shop_offer_desc").text = sub_title

	local button = self:ci("button_shop_offers_bg")

	button.offer_name = offer_name

	function button.on_click(this)
		S:queue("GUIButtonCommon")

		if not PS.services.iap or not PS.services.iap:purchase_product(this.offer_name) then
			signal.emit(SGN_SHOP_SHOW_MESSAGE, "iap_error")
			log.error("Error trying to purchase product %s", this.offer_name)

			return
		end

		signal.emit(SGN_MARKETING_OFFER_CLICKED, prod.id, "map_shop")
		signal.emit(SGN_SHOP_SHOW_IAP_PROGRESS)
	end

	if prod.includes_consumables then
		local card_pos = 1

		for i, v in pairs(prod.includes_consumables) do
			local image_name = "shop_offer_card_" .. v.name

			if string.find(v.name, "item_") and v.count then
				if v.count > 1 then
					button:ci("card_" .. card_pos).hidden = true

					local cards = button:ci("multi_card_" .. card_pos)

					cards:ci("image_shop_offer_card_bundle1"):set_image(image_name)
					cards:ci("image_shop_offer_card_bundle2"):set_image(image_name)
					cards:ci("image_shop_offer_card_bundle3"):set_image(image_name)

					cards:ci("label_shop_offer_bundle_quantity").text = "X" .. v.count
					cards:ci("label_shop_offer_card_bundle_title").text = _(string.upper(v.name) .. "_NAME")
				else
					button:ci("multi_card_" .. card_pos).hidden = true

					local card = button:ci("card_" .. card_pos)

					card:ci("image_shop_offer_card"):set_image(image_name)

					card:ci("group_gems_label").hidden = true
					card:ci("label_shop_offer_card_title").text = _(string.upper(v.name) .. "_NAME")
				end
			elseif string.find(v.name, "gems_") then
				button:ci("multi_card_" .. card_pos).hidden = true

				local card = button:ci("card_" .. card_pos)

				card:ci("image_shop_offer_card"):set_image(image_name)

				card:ci("label_shop_offer_card_title").text = _(string.upper(v.name) .. "_NAME")

				local gems_count = "?"

				if PS.services.iap then
					local prod = PS.services.iap:get_product(v.name)

					if prod.reward then
						gems_count = prod.reward
					end
				end

				button:ci("card_" .. card_pos):ci("group_gems_label"):ci("label_shop_offer_gems_amount").text = gems_count
			end

			card_pos = card_pos + 1
		end
	elseif #prod.includes == 1 then
		local tooltip = self:ci("group_mode_tooltip_2")

		tooltip.hidden = true
		tooltip:ci("label_info_tooltip_title").text = _("SHOP_ROOM_DLC_1_TOOLTIP_TITLE")
		tooltip:ci("label_info_tooltip_desc").text = _("SHOP_ROOM_DLC_1_TOOLTIP_DESCRIPTION")

		local info_button = self:ci("button_offer_info")
		local info_button_hotspot = info_button:ci("image_button_hotspot")

		if IS_MOBILE then
			info_button_hotspot.propagate_on_click = false
			info_button_hotspot.propagate_on_down = false
			info_button_hotspot.propagate_on_up = false

			function info_button_hotspot.on_click(this)
				S:queue("GUIButtonCommon")

				tooltip.hidden = not tooltip.hidden
			end

			function info_button_hotspot.on_exit(this)
				tooltip.hidden = true
			end
		else
			info_button.propagate_on_click = false
			info_button.propagate_on_down = false
			info_button.propagate_on_up = false

			function info_button.on_enter(this)
				S:queue("GUIButtonCommon")

				tooltip.hidden = false
			end

			function info_button.on_exit(this)
				tooltip.hidden = true
			end

			info_button_hotspot.hidden = true
		end

		local buy_button = self:ci("button_buy_dlc")

		buy_button.hidden = IS_MOBILE or prod.owned
		buy_button:ci("label_button_price").text = prod.price or "?"

		local label_owned = self:ci("label_shop_dlc_purchased")

		label_owned.hidden = IS_MOBILE or not prod.owned
		label_owned.text = _("DLC_OWNED")
	elseif prod.includes and #prod.includes <= 3 then
		local card_pos = 1

		for i, v in pairs(prod.includes) do
			local image_name = "shop_offer_card_" .. v

			button:ci("multi_card_" .. card_pos).hidden = true

			local card = button:ci("card_" .. card_pos)

			card:ci("image_shop_offer_card"):set_image(image_name)

			card:ci("group_gems_label").hidden = true
			card:ci("label_shop_offer_card_title").text = _(string.upper(v) .. "_NAME")
			card_pos = card_pos + 1
		end
	end
end

function ShopOfferItemView:set_gift(prod, title, sub_title)
	self:ci("label_shop_offer_cost").text = _("PRICE_FREE")
	self:ci("label_shop_offer_cost").font_name = "fla_h"
	self:ci("label_shop_offer_discount").hidden = true
	self:ci("label_shop_offer_discount_off").hidden = true
	self:ci("image_shop_offer_discount_bg").hidden = true
	self:ci("label_shop_offer_ends_time").hidden = true
	self:ci("label_shop_special_offer_title").text = title
	self:ci("label_shop_offer_desc").text = sub_title

	local button = self:ci("button_shop_offers_bg")

	button.product = prod

	function button.on_click(this)
		S:queue("GUIButtonCommon")

		local slot = storage:load_slot()

		if slot then
			for _, v in pairs(this.product.includes_consumables) do
				if string.find(v.name, "item_") then
					local item_id = string.gsub(v.name, "item_", "")

					if slot.items.status[item_id] and v.count then
						slot.items.status[item_id] = slot.items.status[item_id] + v.count
					else
						log.error("id:%s item not found in slot", v.item)
					end
				elseif string.find(v.name, "gems_") then
					local g = PS.services.iap:get_product(v.name, true)

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

			if slot.claimed_gifts then
				slot.claimed_gifts = {}
			end

			table.insert(slot.claimed_gifts, this.product.id)
			storage:save_slot(slot, nil, true)

			if PS.services.iap then
				screen_map:give_free_gift(this.product.includes_consumables)
				this:disable()
			end
		end
	end

	if prod.includes_consumables then
		log.info(" includes " .. getfulldump(prod.includes_consumables, 2))

		local card_pos = 1

		for i, v in pairs(prod.includes_consumables) do
			local image_name = "shop_offer_card_" .. v.name

			if string.find(v.name, "item_") and v.count then
				if v.count > 1 then
					button:ci("card_" .. card_pos).hidden = true

					local cards = button:ci("multi_card_" .. card_pos)

					cards:ci("image_shop_offer_card_bundle1"):set_image(image_name)
					cards:ci("image_shop_offer_card_bundle2"):set_image(image_name)
					cards:ci("image_shop_offer_card_bundle3"):set_image(image_name)

					cards:ci("label_shop_offer_bundle_quantity").text = "X" .. v.count
					cards:ci("label_shop_offer_card_bundle_title").text = _(string.upper(v.name) .. "_NAME")
				else
					button:ci("multi_card_" .. card_pos).hidden = true

					local card = button:ci("card_" .. card_pos)

					card:ci("image_shop_offer_card"):set_image(image_name)

					card:ci("group_gems_label").hidden = true
					card:ci("label_shop_offer_card_title").text = _(string.upper(v.name) .. "_NAME")
				end
			elseif string.find(v.name, "gems_") then
				button:ci("multi_card_" .. card_pos).hidden = true

				local card = button:ci("card_" .. card_pos)

				card:ci("image_shop_offer_card"):set_image(image_name)

				card:ci("label_shop_offer_card_title").text = _(string.upper(v.name) .. "_NAME")

				local gems_count = "?"

				if PS.services.iap then
					local gp = PS.services.iap:get_product(v.name)

					if gp.reward then
						gems_count = gp.reward
					end
				end

				button:ci("card_" .. card_pos):ci("group_gems_label"):ci("label_shop_offer_gems_amount").text = gems_count
			end

			card_pos = card_pos + 1
		end
	end
end

StageFlag5 = class("StageFlag5", GG5Button)

function StageFlag5:initialize(default_image_name, focus_image_name)
	GG5Button.initialize(self, default_image_name, focus_image_name)

	local level_str = string.match(self.id, "_(%d+)$")

	if not level_str then
		log.error("flag name is wrong:%s", self.id)

		return
	end

	self.level_idx = tonumber(level_str)
	self.drag_threshold = self.size.y / 4
	self.idle_flap_delay = {
		5,
		20
	}
	self.next_idle_flap_ts = nil
	self.flap_anis = {
		campaign = "campaign_flap",
		iron = "iron_flap",
		nostar = "nostar_flap"
	}
	self.vstars = {
		self:ci("star1"),
		self:ci("star2"),
		self:ci("star3")
	}
	self.vwings = self:ci("wings")
	self.vflag = self:ci("flag")
	self.vstars[1].hidden = true
	self.vstars[2].hidden = true
	self.vstars[3].hidden = true
	self.vwings.hidden = true

	self:set_flag_ani("hidden")
	self:set_focus_below_child(self.vflag)

	if DEBUG then
		local label = self:ci("level_number")

		if label then
			label.text = self.level_idx
			label.colors.text = {
				0,
				0,
				0,
				255
			}
			label.colors.background = {
				220,
				220,
				220,
				255
			}
		end
	end

	self:ci("level_number").hidden = true

	local user_data = storage:load_slot()

	if user_data.seen["flag_" .. self.level_idx] then
		self:show_noti(false)
	end
end

function StageFlag5:destroy()
	StageFlag5.super.destroy(self)

	self.stars = nil
	self.wings = nil
	self.flag = nil
end

function StageFlag5:set_flag_ani(name)
	self.vflag:start_animation(name)
end

function StageFlag5:set_data(data)
	self.stars = data.stars or 0
	self.campaign = data[GAME_MODE_CAMPAIGN]
	self.heroic = data[GAME_MODE_HEROIC]
	self.iron = data[GAME_MODE_IRON]
end

function StageFlag5:set_stars(count)
	log.debug("flag:%s count:%s", self.id, count)

	for i = 1, 3 do
		local s = self.vstars[i]

		s.hidden = false

		s:start_animation(count < i and "off" or "on", 1000000000)
	end
end

function StageFlag5:animate_star(i)
	log.debug("flag:%s i:%s", self.id, i)

	local s = self.vstars[i]

	s.hidden = false

	s:start_animation("on")
end

function StageFlag5:set_heroic()
	self:animate_heroic(false)
end

function StageFlag5:animate_heroic(animate)
	if animate == nil then
		animate = true
	end

	local wings = self.vwings

	wings.hidden = false
	wings.ts = animate and 0 or 1000000000
end

function StageFlag5:set_mode(mode, animate)
	log.debug("setting mode %s for flag %s", mode, self.id)

	self.mode = mode

	local flag = self.vflag
	local wings = self.vwings

	self.hidden = false
	self.next_idle_flap_ts = nil

	if mode == "hidden" then
		self.hidden = true
		wings.hidden = true

		for _, v in pairs(self.vstars) do
			v.hidden = true
		end

		return
	elseif mode == "new_flag" then
		flag:start_animation("nostar_in", animate and 0 or 1000000000, function()
			flag:start_animation("nostar_fixed")

			self.mode = "nostar"
		end)
	elseif mode == "nostar" then
		flag:start_animation("nostar_fixed", 0)
	elseif mode == "campaign" then
		flag:start_animation("campaign_in", animate and 0 or 1000000000, function()
			flag:start_animation("campaign_idle")
		end)
	elseif mode == "iron" then
		flag:start_animation("iron_in", animate and 0 or 1000000000, function()
			flag:start_animation("iron_idle")
		end)
	else
		log.error("mode unknown %s", mode)

		return
	end
end

function StageFlag5:show_noti(show)
	if show and self:ci("notification_dot").hidden then
		self.ts = 0
	else
		self.ts = 1000000000
	end

	self:ci("notification_dot").hidden = not show
end

function StageFlag5:update(dt)
	StageFlag5.super.update(self, dt)

	local ani = self.flap_anis[self.mode]

	if ani and not self.hidden then
		if self.next_idle_flap_ts and (not self.halo_image or self.halo_image.hidden) then
			if self.vflag.ts >= self.next_idle_flap_ts then
				self.vflag:start_animation(ani, 0)

				self.next_idle_flap_ts = nil
			end
		elseif self.idle_flap_delay then
			self.next_idle_flap_ts = self.vflag.ts + U.frandom(self.idle_flap_delay[1], self.idle_flap_delay[2])
		end
	end
end

function StageFlag5:on_click()
	S:queue("GUIButtonSoft2")
	self:focus(true)

	if not self:ci("notification_dot").hidden then
		local user_data = storage:load_slot()

		user_data.seen["flag_" .. self.level_idx] = true

		storage:save_slot(user_data)
		self:show_noti(false)
	end

	screen_map:show_level(self.level_idx, self.stars, self.campaign, self.heroic, self.iron)
	self:disable(false)

	local ktw = self:get_window().ktw

	if ktw then
		ktw:cancel(self)
		ktw:after(self, 0.5, function()
			self:enable()
		end)
	end
end

function StageFlag5:on_focus()
	StageFlag5.super.on_focus(self)
	signal.emit("map-pan-to-flag", self)
end

MapView = class("MapView", KImageView)

function MapView:initialize(image_name, size)
	KImageView.initialize(self, image_name, size)
end

function MapView:pan_to_map_coord(x, y, animated)
	local mx, my = self:view_to_view(x, y, self.parent)

	mx = mx - self.pos.x
	my = my - self.pos.y

	local sw, sh = screen_map.sw, screen_map.sh

	mx = sw / 2 - mx
	my = sh / 2 - my

	local dl = self.drag_limits
	local dx = km.clamp(dl.pos.x, dl.pos.x + dl.size.x, mx)
	local dy = km.clamp(dl.pos.y, dl.pos.y + dl.size.y, my)

	log.debug("panning map_view to:%s,%s  for flag at:%s,%s", dx, dy, x, y)

	if not animated then
		self.pos.x = dx
		self.pos.y = dy
	else
		local ktw = self:get_window().ktw

		ktw:cancel(self)
		ktw:tween(self, 0.5, self.pos, {
			x = dx,
			y = dy
		}, "out-quad")
	end
end

function MapView:focus_next_flag(dir)
	local flags = self:ci("group_map_flags")
	local idx = 1
	local w = screen_map.window

	if w and w.focused and w.focused.id and w.focused:isInstanceOf(StageFlag5) then
		local nn = string.gsub(w.focused.id, "flag_", "")

		log.todo("nn:%s", nn)

		idx = tonumber(nn)
		idx = km.clamp(1, #flags.children, idx + dir)
	end

	local nid = string.format("flag_%02i", idx)
	local new_flag = flags:ci(nid)

	if not new_flag or new_flag.hidden then
		S:queue("GUIButtonCommon")
	else
		new_flag:focus(true)
	end
end

function MapView:clear_flags()
	local flags = self:ci("group_map_flags")
	local paths = self:ci("group_map_paths")

	if flags then
		for _, c in pairs(flags.children) do
			c:set_mode("hidden")
		end
	end

	if paths then
		for _, c in pairs(paths.children) do
			c.hidden = true
		end
	end
end

function MapView:show_decos()
	local ud = screen_map.unlock_data
	local user_data = storage:load_slot()
	local paths = self:ci("group_map_paths")

	local function check_after_level(level)
		if #ud.unlocked_levels > 1 then
			if table.contains(ud.unlocked_levels, level + 1) then
				return false
			elseif user_data.levels[level + 1] then
				return true
			else
				return false
			end
		elseif user_data.levels[level + 1] then
			return true
		else
			return false
		end
	end

	local after_level_06 = check_after_level(6)
	local after_level_07 = check_after_level(7)
	local after_level_11 = check_after_level(11)
	local after_level_15 = check_after_level(15)

	if after_level_06 then
		local sword = paths:ci("image_sword")

		sword.hidden = true
		self:ci("map_deco_sword").hidden = true
	else
		local sword = paths:ci("image_sword")

		sword.hidden = false
	end

	if after_level_07 then
		if ud.new_level == 8 then
			local temple = paths:ci("timeline_portal_t2")

			temple.ts = 0
			temple.hidden = false

			temple:jump(0, true)
		else
			local temple = paths:ci("timeline_portal_t2")

			temple.ts = 0
			temple.hidden = false

			temple:jump(1e+99, true)

			local timeline_flames = paths:ci("timeline_flames")

			timeline_flames.hidden = false

			timeline_flames:start()
		end
	else
		local temple = paths:ci("timeline_portal_t2")

		temple.ts = 0
		temple.hidden = false

		temple:jump(0, true)
	end

	if after_level_11 then
		local portal1 = paths:ci("timeline_portal_1")

		portal1.hidden = false

		portal1:start()

		local portal2 = paths:ci("timeline_portal_2")

		portal2.hidden = false

		portal2:start()

		local stones = paths:ci("timeline_stones_portal_t3")

		stones.hidden = false

		stones:start()

		if ud.new_level == 12 then
			local clouds = self:ci("decos_map_clouds")

			clouds.hidden = false
		else
			local clouds = self:ci("decos_map_clouds")

			clouds.hidden = true
		end

		local thunder = self:ci("decos_map_thunder")

		thunder.hidden = true
	else
		local clouds = self:ci("decos_map_clouds")

		clouds.hidden = false

		local thunder = self:ci("decos_map_thunder")

		thunder.hidden = false
	end

	if after_level_15 then
		local overseer = self:ci("decos_map_overseer")

		overseer.exo_animation = "loop_active"
		overseer.ts = 0
	end
end

function MapView:show_dlc_unlock(dlc_id)
	local dlc_first_level = U.get_dlc_level_range(dlc_id)[1]
	local user_data = storage:load_slot()

	if user_data.levels[dlc_first_level] and #user_data.levels[dlc_first_level] > 0 then
		screen_map:show_bars()

		return
	end

	local function hide_dlc_flag(flag)
		flag.hidden = true
		flag.disabled = true
		flag.propagate_on_down = true
		flag.propagate_on_up = true
		flag.propagate_on_click = true
	end

	local function wid(name)
		return self:get_window():ci(name)
	end

	wid("map_touch_view"):disable()
	wid("group_map_flags"):disable(false)

	local dlc_flag = self:ci("map_dlc_special_flag"):ci("group_flag_" .. dlc_id)
	local dlc_first_level = U.get_dlc_level_range(dlc_id)[1]
	local first_flag = self:ci("group_map_flags"):ci("flag_" .. dlc_first_level)

	first_flag.hidden = false

	first_flag:enable()
	first_flag:set_data({})
	first_flag:set_mode("nostar")
	first_flag:show_noti(false)

	local dlc_flag_anim = self:ci("map_dlc_special_flag"):ci("flag_unlock_anim_" .. dlc_id)

	dlc_flag_anim.ts = 0

	dlc_flag_anim:start()

	dlc_flag_anim.disabled = true
	dlc_flag_anim.propagate_on_down = true
	dlc_flag_anim.propagate_on_up = true
	dlc_flag_anim.propagate_on_click = true

	local ktw = self:get_window().ktw

	ktw:cancel(self)
	ktw:script(self, function(wait)
		wait(0.15)
		hide_dlc_flag(dlc_flag)
		wait(dlc_flag_anim.frame_duration / FPS - 0.25)

		dlc_flag_anim.hidden = true

		if not screen_map:process_new_dlc() then
			wid("map_touch_view"):enable()
			wid("group_map_flags"):enable()
			screen_map:show_bars()
		end
	end)
end

function MapView:show_dlcs_flags()
	local function hide_dlc_flag(flag)
		flag.hidden = true
		flag.disabled = true
		flag.propagate_on_down = true
		flag.propagate_on_up = true
		flag.propagate_on_click = true
	end

	local user_data = storage:load_slot()
	local reached_min_level = user_data.levels[GS.dlcs_unlock_level + 1]
	local flags_group = self:ci("map_dlc_special_flag")

	flags_group.propagate_on_down = true
	flags_group.propagate_on_up = true
	flags_group.propagate_on_click = true

	if reached_min_level and PS.services.iap then
		local all_dlcs = PS.services.iap:get_dlcs()
		local owned_dlcs = PS.services.iap:get_dlcs(true)
		local global = storage:load_global() or {}
		local unlocked_dlcs = global.unlocked_dlcs or {}
		local is_premium, premium_excludes = PS.services.iap:is_premium()

		for _, v in pairs(all_dlcs) do
			local dlc_flag = self:ci("map_dlc_special_flag"):ci("group_flag_" .. v)

			if is_premium and premium_excludes == nil or table.contains(owned_dlcs, v) and table.contains(unlocked_dlcs, v) then
				hide_dlc_flag(dlc_flag)
			else
				local dlc_first_level = U.get_dlc_level_range(v)[1]
				local user_data = storage:load_slot()

				if user_data.levels[dlc_first_level] and #user_data.levels[dlc_first_level] > 0 then
					hide_dlc_flag(dlc_flag)
				else
					for k, v in pairs(dlc_flag.children) do
						if v.class.name == "GGTimeline" then
							v.ts = 0

							v:start()
						elseif v.class.name == "GG5Button" then
							function v.on_click()
								S:queue("GUIButtonCommon")
								screen_map:show_shop_dlc()
							end
						end
					end

					local flags = self:ci("group_map_flags")

					flags:ci("flag_" .. dlc_first_level).hidden = true
				end
			end
		end
	else
		for i = 1, #GS.dlc_names do
			local dlc_flag = self:ci("map_dlc_special_flag"):ci("group_flag_dlc_" .. i)

			hide_dlc_flag(dlc_flag)

			if not reached_min_level then
				local dlc_first_level = U.get_dlc_level_range(GS.dlc_names[i].id)[1]
				local flags = self:ci("group_map_flags")

				flags:ci("flag_" .. dlc_first_level).hidden = true
			end
		end
	end
end

function MapView:center_map_on_flags(new_flag_id, last_flag_id)
	local flags = self:ci("group_map_flags")
	local fcenter = flags and flags:ci(string.format("flag_%02i", new_flag_id))
	local fcenter_prev = flags and flags:ci(string.format("flag_%02i", last_flag_id))
	local mx, my = 0, 0

	if fcenter and fcenter_prev then
		local mx_new, my_new = fcenter:view_to_view(0, 0, self)
		local mx_prev, my_prev = fcenter_prev:view_to_view(0, 0, self)

		mx, my = (mx_new + mx_prev) / 2, (my_new + my_prev) / 2
	else
		mx, my = self.size.x / 2, self.size.y / 2
	end

	self:pan_to_map_coord(mx, my, false)
end

function MapView:center_map()
	local flags = self:ci("group_map_flags")
	local ud = screen_map.unlock_data
	local user_data = storage:load_slot()
	local lowest_pending_stage = -1

	for i = 1, #user_data.levels do
		if #user_data.levels[i] == 0 then
			lowest_pending_stage = i

			break
		end
	end

	local center_flag_id = lowest_pending_stage
	local last_flag_id = lowest_pending_stage - 1

	if ud.heroic_level then
		center_flag_id = ud.heroic_level
		last_flag_id = ud.heroic_level
	elseif ud.iron_level then
		center_flag_id = ud.iron_level
		last_flag_id = ud.iron_level
	elseif ud.new_level then
		center_flag_id = ud.new_level
		last_flag_id = ud.new_level - 1
	elseif ud.show_stars_level then
		center_flag_id = ud.show_stars_level
		last_flag_id = ud.show_stars_level
	elseif last_flag_id < 1 then
		last_flag_id = center_flag_id
	end

	self:center_map_on_flags(center_flag_id, last_flag_id)
end

function MapView:show_flags()
	local extra_levels = GS.extra_levels

	self:clear_flags()
	self:show_decos()

	local flags = self:ci("group_map_flags")
	local paths = self:ci("group_map_paths")
	local last_level = GS.last_level
	local ud = screen_map.unlock_data
	local user_data = storage:load_slot()

	local function wid(name)
		return self:get_window():ci(name)
	end

	wid("map_touch_view"):disable()
	wid("group_map_flags"):disable(false)

	if last_level == 0 then
		ud.unlocked_levels = {}
	end

	local myLastLevel = 549
	local save = false
	for i = 1, myLastLevel do
		local level = user_data.levels[i]
		if not level then
			level = extra_levels[i]
			if level then
				user_data.levels[i] = level
				save = true
			end
		end

		if not level then
			-- block empty
		else
			local path = paths and paths:ci(string.format("path_%02i", i))

			if path and not table.contains(ud.unlocked_levels, i) then
				path.hidden = false

				path:jump(1000000000, true)
			end

			local flag = flags and flags:ci(string.format("flag_%02i", i))

			if not flag then
				log.error("could not find flag index %i", i)
			else
				flag:set_data(level)
				flag:set_mode("nostar")
				flag:show_noti(false)

				if table.contains(ud.unlocked_levels, i) then
					flag.hidden = true
				end

				if level[GAME_MODE_CAMPAIGN] and level.stars then
					if ud.show_stars_level ~= i or ud.star_count_before > 0 then
						flag:set_mode("campaign")
					end

					if ud.show_stars_level == i then
						flag:set_stars(ud.star_count_before)
					else
						flag:set_stars(level.stars)
					end

					flag:show_noti(not user_data.seen["flag_" .. i] and not table.contains(ud.unlocked_levels, i) and not table.contains(ud.unlocked_levels, i + 1))
				end

				if level[GAME_MODE_IRON] and ud.iron_level ~= i then
					flag:set_mode("iron")
					flag:show_noti(false)
				end

				if level[GAME_MODE_HEROIC] and ud.heroic_level ~= i then
					flag:set_heroic()
					flag:show_noti(false)
				end
			end
		end
	end
	if save then
		storage:save_slot(user_data)
	end

	self:center_map()
	self:show_dlcs_flags()

	local ktw = self:get_window().ktw

	ktw:cancel(self)
	ktw:script(self, function(wait)
		wait(0)

		for i = 1, myLastLevel do
			local level = user_data.levels[i]

			if not level then
				-- block empty
			else
				local flag = flags and flags:ci(string.format("flag_%02i", i))

				if flag and ud.show_stars_level == i then
					flag:disable(false)
					flag:set_stars(ud.star_count_before)
					wait(0.5)

					if not level[GAME_MODE_IRON] then
						flag:set_mode("campaign", true)
						wait(1)
					end

					for j = ud.star_count_before + 1, level.stars do
						flag:animate_star(j)
						wait(0.43)
					end

					flag:enable()
				end

				if flag and ud.iron_level == i then
					flag:disable(false)
					wait(0.5)
					flag:set_mode("iron", true)
					wait(1.25)
					flag:enable()
				end

				if flag and ud.heroic_level == i then
					flag:disable(false)
					wait(0.5)
					flag:animate_heroic()
					wait(1.25)
					flag:enable()
				end

				local path = paths and paths:ci(string.format("path_%02i", i))

				if path and path.hidden and i == ud.new_level then
					path.hidden = false

					path:start()

					local anim_delay = 0

					if i == 8 then
						local timeline_temple = paths:ci("timeline_portal_t2")

						timeline_temple.hidden = false

						timeline_temple:start()
						S:queue("GUIMapCultistBridgeAppear")

						anim_delay = 50

						wait(anim_delay / (path.fps or FPS))

						local timeline_flames = paths:ci("timeline_flames")

						timeline_flames.hidden = false

						timeline_flames:start()
					end

					if i == 12 then
						S:queue("GUIMapCloudRemoval")
						wait(50 / (path.fps or FPS))

						local clouds = self:ci("decos_map_clouds")

						clouds.exo_animation = "out"
						clouds.ts = 0
						clouds.loop = false
					end

					wait((path.frame_duration - anim_delay) / (path.fps or FPS))
				end

				if flag and table.contains(ud.unlocked_levels, i) then
					flag:disable(false)
					flag:set_mode("new_flag", true)
					wait(1)
					flag:enable()

					local last_flag = flags:ci(string.format("flag_%02i", i - 1))

					if last_flag then
						last_flag:show_noti(true)
					end
				end
			end
		end

		if not screen_map:process_new_dlc() then
			wid("map_touch_view"):enable()
			wid("group_map_flags"):enable()
			screen_map:show_bars()
		end
	end)
end

function MapView:show_flags_unlocked()
	self:clear_flags()
	self:show_decos()

	local flags = self:ci("group_map_flags")
	local paths = self:ci("group_map_paths")
	local last_level = GS.last_level
	local ud = screen_map.unlock_data
	local user_data = storage:load_slot()

	if last_level == 0 then
		ud.unlocked_levels = {}
	end

	for i = 1, last_level do
		local level = user_data.levels[i]

		if not level then
			-- block empty
		else
			local path = paths and paths:ci(string.format("path_%02i", i))

			if path and not table.contains(ud.unlocked_levels, i) then
				path.hidden = false

				path:jump(1000000000, true)
			end

			local flag = flags and flags:ci(string.format("flag_%02i", i))

			if not flag then
				log.error("could not find flag index %i", i)
			else
				flag:set_data(level)
				flag:set_mode("nostar")
				flag:show_noti(false)

				if table.contains(ud.unlocked_levels, i) then
					flag.hidden = true
				end

				if level[GAME_MODE_CAMPAIGN] and level.stars then
					if ud.show_stars_level ~= i or ud.star_count_before > 0 then
						flag:set_mode("campaign")
					end

					if ud.show_stars_level == i then
						flag:set_stars(ud.star_count_before)
					else
						flag:set_stars(level.stars)
					end

					flag:show_noti(not user_data.seen["flag_" .. i] and not table.contains(ud.unlocked_levels, i) and not table.contains(ud.unlocked_levels, i + 1))
				end

				if level[GAME_MODE_IRON] and ud.iron_level ~= i then
					flag:set_mode("iron")
					flag:show_noti(false)
				end

				if level[GAME_MODE_HEROIC] and ud.heroic_level ~= i then
					flag:set_heroic()
					flag:show_noti(false)
				end
			end
		end
	end

	local unlocked_campaign
	local lowest_pending_stage = 1

	for i = 1, #user_data.levels do
		if #user_data.levels[i] == 0 then
			lowest_pending_stage = i

			break
		end
	end

	local lowest_unlocked_level = #ud.unlocked_levels > 0 and ud.unlocked_levels[1]

	for k, v in pairs(ud.unlocked_levels) do
		if v < lowest_unlocked_level then
			lowest_unlocked_level = v
		end
	end

	self:center_map()
	self:show_dlcs_flags()
end

MapView:include(KMDragInertia)

MapTouchView = class("MapTouchView", KView)

function MapTouchView:initialize(size)
	KView.initialize(self, size)

	self.forced_min_zoom = OVT(0.2, OV_PHONE, 1, OV_TABLET, 0.8)
	self.zoom_range = OVT(0.2, OV_PHONE, 0.4)
	self.zoom = 1
	self.min_zoom = 1
	self.max_zoom = 1
	self.touch_fingers = {}
	self.mousestate = {}
	self.min_scale_factor = 0.95
	self.max_scale_factor = 1.05
end

function MapTouchView:set_puppet(view)
	self.puppet = view

	local w = self:get_window()

	if not w then
		log.error("window not set yet... skipping min zoom adjusts.")

		return
	end

	local asp_p = self.puppet.size.x / self.puppet.size.y
	local asp_s = w.size.x / w.size.y

	if asp_s < asp_p then
		self.min_zoom = w.size.y / self.puppet.size.y
	else
		self.min_zoom = w.size.x / self.puppet.size.x
	end

	self.min_zoom = math.max(self.forced_min_zoom, self.min_zoom)
	self.max_zoom = self.min_zoom + self.zoom_range

	if IS_MOBILE then
		self.zoom = (self.max_zoom + self.min_zoom) * 0.5
	else
		self.zoom = self.min_zoom
	end

	self.puppet.scale.x = self.zoom
	self.puppet.scale.y = self.zoom

	self:update_drag_limits()
end

function MapTouchView:update_drag_limits(no_clamp)
	local pup = self.puppet

	if not pup then
		return
	end

	local sf = pup.scale.x
	local dl = pup.drag_limits or V.r(0, 0, 0, 0)

	pup.drag_limits = dl

	local ws = self:get_window().size

	dl.size.x = -(pup.size.x * sf - ws.x)
	dl.size.y = -(pup.size.y * sf - ws.y)

	if not no_clamp then
		pup.pos.x = km.clamp(dl.pos.x, dl.pos.x + dl.size.x, pup.pos.x)
		pup.pos.y = km.clamp(dl.pos.y, dl.pos.y + dl.size.y, pup.pos.y)
	end
end

function MapTouchView:on_scroll(button, x, y, istouch)
	if istouch or not self.puppet then
		return
	end

	local zoom = self.zoom

	if button == "wd" then
		zoom = zoom * 0.95
	elseif button == "wu" then
		zoom = zoom * 1.05
	end

	zoom = km.clamp(self.min_zoom, self.max_zoom, zoom)
	self.zoom = zoom

	local p = self.puppet
	local si = p.scale.x
	local sf = zoom

	p.pos.x = x * (1 - sf / si) + p.pos.x * sf / si
	p.pos.y = y * (1 - sf / si) + p.pos.y * sf / si
	p.scale.x = zoom
	p.scale.y = zoom

	if p.drag_limits then
		self:update_drag_limits()
	end
end

function MapTouchView:on_touch_down(id, x, y, dx, dy, pressure)
	log.paranoid("MapTouchView:on_touch_down(%s,%s,%s)", id, x, y)

	for i, v in pairs(self.touch_fingers) do
		if v[1] == id then
			goto label_408_0
		end
	end

	table.insert(self.touch_fingers, {
		id,
		x,
		y,
		x,
		y
	})

	::label_408_0::

	if #self.touch_fingers > 1 then
		self.drag_enable = false
		self.propagate_on_down = false
		self.propagate_on_up = false
		self.propagate_on_click = false

		if self.puppet then
			self.puppet.can_drag = false
		end
	end
end

function MapTouchView:on_touch_up(id, x, y, dx, dy, pressure)
	log.paranoid("MapTouchView:on_touch_up(%s,%s,%s)", id, x, y)

	for i = #self.touch_fingers, 1, -1 do
		if self.touch_fingers[i][1] == id then
			table.remove(self.touch_fingers, i)

			break
		end
	end

	if not self.drag_enable and #self.touch_fingers == 0 then
		self.drag_enable = true
		self.propagate_on_down = true
		self.propagate_on_up = true
		self.propagate_on_click = true

		if self.puppet then
			self.puppet.can_drag = true
		end
	end

	if #self.touch_fingers > 0 and self.puppet and self.puppet.reset_inertia then
		self.puppet:reset_inertia()
	end
end

function MapTouchView:on_touch_move(id, x, y, dx, dy, pressure)
	local fingers = self.touch_fingers
	local pup = self.puppet

	if #fingers > 1 and pup then
		local f1x, f1y, f2x, f2y

		if fingers[1][1] == id then
			f1x, f1y, f2x, f2y = fingers[1][4], fingers[1][5], fingers[2][4], fingers[2][5]
			fingers[1][4], fingers[1][5] = x, y
		elseif fingers[2][1] == id then
			f1x, f1y, f2x, f2y = fingers[2][4], fingers[2][5], fingers[1][4], fingers[1][5]
			fingers[2][4], fingers[2][5] = x, y
		else
			return
		end

		local di = V.dist(f1x, f1y, f2x, f2y)
		local df = V.dist(x, y, f2x, f2y)
		local ds = km.clamp(self.min_scale_factor, self.max_scale_factor, df / di)
		local si = pup.scale.x
		local sf = si * ds

		sf = km.clamp(self.min_zoom, self.max_zoom, sf)

		local bix, biy = 0.5 * (f1x + f2x), 0.5 * (f1y + f2y)
		local bfx, bfy = 0.5 * (x + f2x), 0.5 * (y + f2y)
		local mix, miy = pup.pos.x, pup.pos.y
		local mfx, mfy = bfx - sf / si * (bix - mix), bfy - sf / si * (biy - miy)

		pup.scale.x, pup.scale.y = sf, sf
		pup.pos.x, pup.pos.y = mfx, mfy

		self:update_drag_limits()

		if pup.reset_inertia then
			pup:reset_inertia()
		end
	end
end

function MapTouchView:on_exit(drag_view)
	log.paranoid("TouchView:on_exit")
end

function MapTouchView:enable()
	MapTouchView.super.enable(self)

	self.propagate_on_down = true
	self.propagate_on_up = true
	self.propagate_on_click = true

	if self.puppet then
		self.puppet.can_drag = true
	end
end

function MapTouchView:disable()
	MapTouchView.super.disable(self, false)

	self.propagate_on_down = false
	self.propagate_on_up = false
	self.propagate_on_click = false

	if self.puppet then
		self.puppet.can_drag = false
	end
end

GGExoOverseer = class("GGExoOverseer", GGExo)

function GGExoOverseer:initialize(size, exo_name, exo_animation, exo_scale_factor)
	GGExo.initialize(self, size, exo_name, exo_animation, exo_scale_factor)

	self.hidden = false
	self.ts = 0
	self.runs = 0
	self.action_cooldown = 8
	self.tick_ts = 0
	self.action_ts = 0
end

function GGExoOverseer:update(dt)
	GGExo.update(self, dt)

	self.tick_ts = self.tick_ts + dt

	if not self.hidden and self.exo_animation ~= "loop_inactive" and self.tick_ts - self.action_ts >= self.action_cooldown then
		self.exo_animation = "action"
		self.ts = 0
		self.action_ts = self.tick_ts
		self.loop = false
	end
end

function GGExoOverseer:on_exo_finished(runs)
	if self.exo_animation == "action" and runs == 1 then
		self.exo_animation = "loop_active"
		self.loop = true
		self.ts = 0
	end
end

CardRewardsView = class("CardRewardsView", KView)

function CardRewardsView:initialize(size)
	KView.initialize(self, size)

	self.can_close_view = false
end

function CardRewardsView:update(dt)
	CardRewardsView.super.update(self, dt)
end

function CardRewardsView:show(level_idx, cards)
	local ktw = self:get_window().ktw

	local function wid(name)
		return self:get_window():ci(name)
	end

	local function fade_in(v, delay)
		v.hidden = false

		ktw:cancel(v)
		ktw:tween(v, delay, v, {
			alpha = 1
		}, "in-quad")
	end

	local function get_cards(level_idx)
		local cards = {}
		local current_points = UPGR:get_points_by_level(level_idx)
		local previous_points = 0

		if level_idx > 1 then
			previous_points = UPGR:get_points_by_level(level_idx - 1)
		end

		if current_points - previous_points > 0 then
			local points = current_points - previous_points
			local card = {
				card = "CardUpgradesDef",
				top_label = _("CARD_REWARDS_UPGRADES"),
				bot_label = "X" .. points
			}

			table.insert(cards, card)
		end

		local premium, exceptions

		if PS.services.iap then
			premium, exceptions = PS.services.iap:is_premium()
		end

		for k, v in pairs(screen_map.hero_data) do
			if v.available_at_stage == level_idx + 1 and (not v.iap or not exceptions) then
				local bot_label = _(string.upper(k) .. "_NAME")

				table.insert(cards, {
					card = "Card_" .. k .. "_Def",
					top_label = _("CARD_REWARDS_HERO"),
					bot_label = bot_label
				})
			end
		end

		for k, v in pairs(screen_map.tower_data) do
			if v.available_at_stage == level_idx + 1 and (not v.iap or not exceptions) then
				local bot_label = _("TOWER_" .. string.upper(k) .. "_NAME")

				table.insert(cards, {
					card = "Card_tower_" .. k .. "_Def",
					top_label = _("CARD_REWARDS_TOWER"),
					bot_label = bot_label
				})
			end
		end

		if level_idx == 1 then
			local bot_label = _("CARD_REWARDS_TOWER_LEVEL_PREFIX") .. " 2"

			table.insert(cards, {
				card = "CardTower_lvl_1Def",
				top_label = _("CARD_REWARDS_TOWER_LEVEL"),
				bot_label = bot_label
			})
		elseif level_idx == 2 then
			local bot_label = _("CARD_REWARDS_TOWER_LEVEL_PREFIX") .. " 3"

			table.insert(cards, {
				card = "CardTower_lvl_2Def",
				top_label = _("CARD_REWARDS_TOWER_LEVEL"),
				bot_label = bot_label
			})
		elseif level_idx == 3 then
			local bot_label = _("CARD_REWARDS_TOWER_LEVEL_PREFIX") .. " 4"

			table.insert(cards, {
				card = "CardTower_lvl_3Def",
				top_label = _("CARD_REWARDS_TOWER_LEVEL"),
				bot_label = bot_label
			})
		end

		local counter = 2

		for i = 2, #GS.level_ranges do
			if U.is_dlc_level(GS.level_ranges[i][1]) then
				-- block empty
			else
				local name = GS.level_range_names[i]
				local u_idx = GS.expansions_unlock_level[name] or GS.expansions_unlock_level.default

				if level_idx == u_idx then
					local update_id = string.format("%02d", counter - 1)
					local bot_label = _("CARD_REWARDS_UPDATE_" .. update_id)

					table.insert(cards, {
						new_page = true,
						card = "Card_update_" .. update_id .. "_Def",
						top_label = _("CARD_REWARDS_CAMPAIGN"),
						bot_label = bot_label
					})
				end

				counter = counter + 1
			end
		end

		return cards
	end

	local function get_cards_from_def(items)
		if not items then
			return nil
		end

		local cards = {}

		for k, v in pairs(items) do
			if v.card and v.top_label and v.bot_label then
				table.insert(cards, v)
			else
				local name = v.name or v

				if string.find(name, "item_") then
					local bot_label = _(string.upper(name) .. "_NAME")

					table.insert(cards, {
						bot_number = true,
						card = "Card_" .. name .. "_Def",
						top_label = bot_label,
						bot_label = "X" .. v.count
					})
				elseif string.find(name, "gems_") then
					local bot_label = _(string.upper(name) .. "_NAME")

					table.insert(cards, {
						bot_label = "",
						card = "Card_" .. name .. "_Def",
						top_label = bot_label
					})
				elseif string.find(name, "tower_") then
					local bot_label = _(string.upper(name) .. "_NAME")

					table.insert(cards, {
						card = "Card_" .. name .. "_Def",
						top_label = _("CARD_REWARDS_TOWER"),
						bot_label = bot_label
					})
				elseif string.find(name, "hero_") then
					local bot_label = _(string.upper(name) .. "_NAME")

					table.insert(cards, {
						card = "Card_" .. name .. "_Def",
						top_label = _("CARD_REWARDS_HERO"),
						bot_label = bot_label
					})
				elseif string.find(name, "update_") or string.find(name, "dlc_") then
					local bot_label = _("CARD_REWARDS_" .. string.upper(name))

					table.insert(cards, {
						card = "Card_" .. name .. "_Def",
						top_label = _("CARD_REWARDS_CAMPAIGN"),
						bot_label = bot_label
					})
				else
					local bot_label = _(string.upper(name) .. "_NAME")

					table.insert(cards, {
						card = "Card_" .. name .. "_Def",
						top_label = _("NEW"),
						bot_label = bot_label
					})
				end
			end
		end

		return cards
	end

	local function create_card(group_idx, id, card_type)
		local card_reference = self:ci(string.format("image_card_%d_%d", group_idx, id))
		local card_pos = card_reference.pos
		local card = CardRewardsCards(nil, card_type, "card_in", nil)

		card.pos.x, card.pos.y = card_pos.x, card_pos.y
		card.out_transition_delay = card_reference.transition_delay

		local fx_back = CardRewardsCardsFxBack(nil, "CardFxDef", "card_in", nil)

		fx_back.pos.x, fx_back.pos.y = card.pos.x, card.pos.y
		card.fx_exo_back = fx_back

		local fx_front = CardRewardsCardsFxFront(nil, "CardSpawnDef", "card_in", nil)

		fx_front.pos.x, fx_front.pos.y = card.pos.x, card.pos.y
		card.fx_exo_front = fx_front

		return card
	end

	screen_map:set_modal_view(self)
	wid("map_touch_view"):disable()
	wid("group_map_flags"):disable(false)

	self.show_flags = self.show_flags or not cards or type(cards[1]) == "string" and string.find(cards[1], "update_")
	self.show_dlc_unlock = self.show_dlc_unlock or cards and type(cards[1]) == "string" and string.find(cards[1], "dlc_")

	if self.show_dlc_unlock then
		self.dlc_to_unlock = cards[1]
	end

	if cards then
		screen_map:hide_bars()
	end

	local first_page = not self.pending_cards or #self.pending_cards == 0

	if cards and #cards > 3 then
		local cards_to_show = {}

		self.pending_cards = {}

		for k, v in pairs(cards) do
			if k < 4 then
				table.insert(cards_to_show, v)
			else
				table.insert(self.pending_cards, v)
			end
		end

		cards = cards_to_show
	else
		self.pending_cards = nil
	end

	self.cards = {}
	self.cards_label_group = {}

	local cards_to_show_aux = get_cards_from_def(cards) or get_cards(level_idx)
	local cards_to_show = {}
	local more_pages = false

	for k, v in pairs(cards_to_show_aux) do
		if v.new_page and not self.pending_cards and #cards_to_show > 0 then
			self.pending_cards = {}
			more_pages = true
			first_page = false
		end

		if more_pages then
			table.insert(self.pending_cards, v)
		else
			table.insert(cards_to_show, v)
		end
	end

	local card_group = self:ci("group_card_" .. #cards_to_show)

	card_group:ci("label_tap_continue_1").text = _("CINEMATICS_TAP_TO_CONTINUE_KR5")

	for i = 1, 4 do
		if i ~= #cards_to_show then
			local group = self:ci("group_card_" .. i)

			if group ~= nil then
				group.hidden = true
			end
		end
	end

	card_group.hidden = false
	self.overlay = card_group:ci("rewards_overlay")
	self.overlay.colors = {
		background = {
			0,
			0,
			0,
			220
		}
	}

	if first_page then
		self.overlay.alpha = 0
	else
		self.overlay.alpha = 1
	end

	self.overlay.propagate_on_click = true

	local base_scale = self.base_scale and self.base_scale.x or 1

	self.overlay.scale.x = screen_map.sw / base_scale
	self.overlay.scale.y = screen_map.sh / base_scale
	self.overlay.pos.x = screen_map.sw / 2
	self.overlay.pos.y = screen_map.sh / 2
	self.overlay.anchor.x = screen_map.sw / 2
	self.overlay.anchor.y = screen_map.sh / 2

	function self.overlay.on_click()
		if self.can_close_view then
			self.can_close_view = false

			self:hide()
		end
	end

	self.card_group_showing = card_group
	self.inserted_children = {}

	for i, card_to_show in ipairs(cards_to_show) do
		local card = create_card(#cards_to_show, i, card_to_show.card)
		local next_card = self:ci(string.format("image_card_%d_%d", #cards_to_show, i + 1))

		if next_card ~= nil and next_card.transition_delay ~= nil then
			card.transition_delay = next_card.transition_delay
		end

		table.insert(card_group.children, card.fx_exo_back)
		table.insert(card_group.children, card)
		table.insert(card_group.children, card.fx_exo_front)
		table.insert(self.cards, card)
		table.insert(self.inserted_children, #card_group.children - 2)
		table.insert(self.inserted_children, #card_group.children - 1)
		table.insert(self.inserted_children, #card_group.children)

		local card_label_group = card_group:ci(string.format("group_card_txt_%d_%d", #cards_to_show, i))

		card_label_group.alpha = 0
		card_label_group:ci("label_card_amount_1_1").text = cards_to_show[i].bot_label

		if card_to_show.bot_number then
			card_label_group:ci("label_card_amount_1_1").font_name = "fla_numbers_2"
		end

		card_label_group:ci("label_card_amount_1_1").vertical_align = "top"
		card_label_group:ci("label_card_title_1_1").text = cards_to_show[i].top_label
		card_label_group:ci("label_card_title_1_1").vertical_align = "bottom"

		table.insert(self.cards_label_group, card_label_group)

		self.label_tap_continue = card_group:ci(string.format("group_txt_continue_%d_1", #cards_to_show))
		self.label_tap_continue.alpha = 0
	end

	self.hidden = false

	ktw:script(self, function(wait)
		fade_in(self.overlay, 1)
		S:queue("GUICardPreGlow")
		wait(1)

		for i, card in ipairs(self.cards) do
			S:queue("GUICardAppear", {
				delay = i * 0.15
			})
			S:queue("GUICardUnlock", {
				delay = 1.8 + i * 0.15
			})
		end

		for i, card in ipairs(self.cards) do
			card.fx_exo_back:open()
			card:open()
			card.fx_exo_front:open()

			local transition_delay = card.transition_delay

			if transition_delay then
				wait(transition_delay)
			end
		end

		wait(2)

		for i = 1, #cards_to_show do
			fade_in(self.cards_label_group[i], 0.3)

			if self.cards[i].transition_delay then
				wait(self.cards[i].transition_delay)
			end
		end

		wait(1)
		fade_in(self.label_tap_continue, 0.3)

		self.can_close_view = true
	end)
end

function CardRewardsView:hide()
	local ktw = self:get_window().ktw

	local function wid(name)
		return self:get_window():ci(name)
	end

	local function fade_out(v, delay)
		v.hidden = false

		ktw:cancel(v)
		ktw:tween(v, delay, v, {
			alpha = 0
		}, "in-quad")
	end

	ktw:script(self, function(wait)
		for i = #self.cards, 1, -1 do
			S:queue("GUICardUnlockFade", {
				delay = (i - 1) * 0.15
			})
		end

		for i = #self.cards, 1, -1 do
			self.cards[i].fx_exo_back:close()
			self.cards[i]:close()
			fade_out(self.cards_label_group[i], 0.3)

			local delay = self.cards[i].out_transition_delay

			if delay and delay > 0 then
				wait(delay)
			end
		end

		fade_out(self.label_tap_continue, 0.3)

		for i = #self.inserted_children, 1, -1 do
			table.remove(self.card_group_showing.children, self.inserted_children[i])
		end

		if self.pending_cards then
			wait(0.5)
			self:show(nil, table.deepclone(self.pending_cards))
		else
			fade_out(self.overlay, 1)
			wait(1)

			self.hidden = true

			if self.show_flags or self.show_dlc_unlock then
				wait(0.5)
			end

			wid("map_touch_view"):enable()
			wid("group_map_flags"):enable()

			if self.show_flags then
				wid("map_view"):show_flags()

				self.show_flags = false
			elseif self.show_dlc_unlock then
				wid("map_view"):show_dlc_unlock(self.dlc_to_unlock)

				self.show_dlc_unlock = false
				self.dlc_to_unlock = nil
			else
				screen_map:show_bars()
			end

			screen_map:remove_modal_view()
		end
	end)
end

CardRewardsCards = class("CardRewardsCards", GGExo)

function CardRewardsCards:initialize(size, exo_name, exo_animation, exo_scale_factor)
	GGExo.initialize(self, size, exo_name, exo_animation, exo_scale_factor)

	self.hidden = true
	self.ts = 0
	self.runs = 0
	self.exo_animation = "card_in"
end

function CardRewardsCards:update(dt)
	GGExo.update(self, dt)
end

function CardRewardsCards:on_exo_finished(runs)
	if self.exo_animation == "card_in" and runs == 1 then
		self.exo_animation = "loop"
		self.loop = true
		self.ts = 0
	end
end

function CardRewardsCards:open()
	self.exo_animation = "card_in"
	self.ts = 0.2
	self.runs = 0
	self.hidden = false
end

function CardRewardsCards:close()
	self.exo_animation = "card_out"
	self.loop = false
	self.ts = 0
end

CardRewardsCardsFxBack = class("CardRewardsCardsFxBack", CardRewardsCards)
CardRewardsCardsFxFront = class("CardRewardsCardsFxFront", CardRewardsCards)

function CardRewardsCardsFxFront:on_exo_finished(runs)
	if self.exo_animation == "card_in" and runs == 1 then
		self.hidden = true
	end
end

EncycTowerThumbView = class("EncycTowerThumbView", KImageView)
EncycTowerThumbView.static.instance_keys = {
	"id",
	"pos",
	"entity",
	"always_shown"
}

function EncycTowerThumbView:initialize()
	local IS_PHONE = KR_TARGET == "phone"

	self.image_name = "encyclopedia_tower_thumbs_" .. "0121"

	KImageView.initialize(self, self.image_name)

	if screen_map:is_seen(self.entity) or self.always_shown then
		local t = E:get_template(self.entity)

		self.image_name = string.format("encyclopedia_tower_thumbs_00%02d", t.info.enc_icon)

		self:set_image(self.image_name)
	else
		self:disable(false)
	end

	if IS_PHONE then
		self.border = KImageView:new("encyclopedia_creep_thumbs_frame_0001")
		self.highlight = KImageView:new("encyclopedia_creep_thumbs_frame_0002")
	else
		self.border = KImageView:new("encyclopedia_tower_thumbs_frames_0001")
		self.highlight = KImageView:new("encyclopedia_tower_thumbs_frames_0002")
	end

	self.border.propagate_on_down = true
	self.border.propagate_on_click = true
	self.highlight.hidden = true
	self.highlight.propagate_on_down = true
	self.highlight.propagate_on_click = true

	self:add_child(self.border)
	self:add_child(self.highlight)
end

function EncycTowerThumbView:select()
	if self.parent then
		for _, c in pairs(self.parent.children) do
			if c:isInstanceOf(EncycTowerThumbView) then
				c.highlight.hidden = true
			end
		end
	end

	self.highlight.hidden = false

	local dt = E:create_entity(self.entity)
	local di = dt.info.fn(dt)
	local d = self.entity_data
	local key = dt.info.i18n_key or string.upper(self.entity)
	local tower_fmts = {
		kr2 = "encyclopedia_tower_01%02d",
		kr3 = "encyclopedia_towers_00%02d",
		kr1 = "encyclopedia_tower_00%02d",
		kr5 = "encyclopedia_towers_00%02d"
	}

	local function wid(name)
		return self:get_window():ci(name)
	end

	wid("encyclopedia_towers_portrait"):set_image(string.format(tower_fmts[KR_GAME], dt.info.enc_icon))

	wid("encyclopedia_towers_name_label").text = _(key .. "_NAME")
	wid("encyclopedia_towers_desc_label").text = _(key .. "_DESCRIPTION")
	wid("encyclopedia_towers_info").hidden = true
	wid("encyclopedia_towers_info_magical").hidden = true
	wid("encyclopedia_towers_info_barracks").hidden = true

	if di.type == STATS_TYPE_TOWER_BARRACK then
		wid("encyclopedia_towers_info_barracks").hidden = false
		wid("encyclopedia_towers_info_barracks_health").text = di.hp_max
		wid("encyclopedia_towers_info_barracks_attack").text = di.damage_min .. "-" .. di.damage_max
		wid("encyclopedia_towers_info_barracks_armor").text = GU.armor_value_desc(di.armor)
		wid("encyclopedia_towers_info_barracks_respawn").text = string.format(_("%i sec."), di.respawn)
	elseif di.type == STATS_TYPE_TOWER_MAGE then
		wid("encyclopedia_towers_info_magical").hidden = false
		wid("encyclopedia_towers_info_magical_attack").text = di.damage_min .. "-" .. di.damage_max
		wid("encyclopedia_towers_info_magical_reload").text = GU.cooldown_value_desc(di.cooldown)
		wid("encyclopedia_towers_info_magical_range").text = GU.range_value_desc(di.range)
	else
		wid("encyclopedia_towers_info").hidden = false
		wid("encyclopedia_towers_info_attack").text = di.damage_min .. "-" .. di.damage_max
		wid("encyclopedia_towers_info_reload").text = GU.cooldown_value_desc(di.cooldown)
		wid("encyclopedia_towers_info_range").text = GU.range_value_desc(di.range)
	end

	if dt.powers then
		local out = {}

		for k, v in pairs(dt.powers) do
			table.insert(out, _(string.upper(string.format("%s_%s_NAME", key, v.name or k))))
		end

		wid("encyclopedia_towers_specials_label").text = table.concat(out, ", ")
	else
		wid("encyclopedia_towers_specials_label").text = _("None")
	end
end

function EncycTowerThumbView:on_click()
	S:queue("GUINotificationPaperOver")
	self:select()
end

EncycEnemyThumbView = class("EncycEnemyThumbView", KImageView)
EncycEnemyThumbView.static.instance_keys = {
	"id",
	"pos"
}

function EncycEnemyThumbView.static:load_page(thumbs, pi)
	local bi = (pi - 1) * #thumbs

	for i, c in pairs(thumbs) do
		if c:isInstanceOf(EncycEnemyThumbView) then
			local cd = GS.encyclopedia_enemies[bi + i]

			if not cd then
				c.hidden = true
			elseif screen_map:is_seen(cd.name) or cd.always_shown then
				local t = E:get_template(cd.name)

				c:set_entity(cd.name, t.info.enc_icon)
			else
				c:set_locked()
			end
		end
	end

	local function wid(name)
		return self:get_window():ci(name)
	end

	local pager = wid("encyclopedia_enemies_pager")

	if pager then
		for _, v in pairs(pager.children) do
			if pi == v.page_idx then
				v:select()
			else
				v:deselect()
			end
		end
	end
end

function EncycEnemyThumbView:initialize()
	if IS_TABLET then
		self.lock_image = "encyclopedia_creep_thumbs_lock"
	else
		self.lock_image = "encyclopedia_tower_thumbs_" .. "0121"
	end

	KImageView.initialize(self, self.lock_image)

	self.border = KImageView:new("encyclopedia_creep_thumbs_frame_0001")
	self.highlight = KImageView:new("encyclopedia_creep_thumbs_frame_0002")
	self.border.propagate_on_down = true
	self.border.propagate_on_click = true
	self.highlight.hidden = true
	self.highlight.propagate_on_down = true
	self.highlight.propagate_on_click = true

	self:add_child(self.border)
	self:add_child(self.highlight)
	self:disable(false)
end

function EncycEnemyThumbView:set_locked()
	self.hidden = false

	self:disable(false)
	self:set_image(self.lock_image)

	self.highlight.hidden = true
end

function EncycEnemyThumbView:set_entity(name, icon)
	self.hidden = false

	self:enable()
	self:set_image(string.format("encyclopedia_creep_thumbs_00%02i", icon))

	self.entity_name = name
	self.entity_icon = icon
end

function EncycEnemyThumbView:select()
	if self.parent then
		for _, c in pairs(self.parent.children) do
			if c:isInstanceOf(EncycEnemyThumbView) then
				c.highlight.hidden = true
			end
		end
	end

	self.highlight.hidden = false

	local ce = E:create_entity(self.entity_name)
	local ci = ce.info.fn(ce)
	local key = ce.info.i18n_key or string.upper(self.entity_name)

	local function wid(name)
		return self:get_window():ci(name)
	end

	wid("encyclopedia_enemies_name_label").text = _(key .. "_NAME")
	wid("encyclopedia_enemies_desc_label").text = _(key .. "_DESCRIPTION")
	wid("encyclopedia_enemies_specials_label").text = _(key .. "_SPECIAL", "")

	if IS_TABLET then
		wid("encyclopedia_enemies_specials_title").hidden = wid("encyclopedia_enemies_specials_label").text == ""
	end

	wid("encyclopedia_enemies_info_health").text = ci.hp_max
	wid("encyclopedia_enemies_info_armor").text = GU.armor_value_desc(ci.armor)
	wid("encyclopedia_enemies_info_speed").text = GU.speed_value_desc(ce.motion.max_speed)
	wid("encyclopedia_enemies_info_damage").text = GU.damage_value_desc(ci.damage_min, ci.damage_max)
	wid("encyclopedia_enemies_info_magic_armor").text = GU.armor_value_desc(ci.magic_armor)
	wid("encyclopedia_enemies_info_cost").text = GU.lives_desc(ci.lives)

	local creep_fmts = {
		kr2 = "encyclopedia_creep_02%02d",
		kr3 = "encyclopedia_creeps_00%02d",
		kr1 = "encyclopedia_creep_00%02d",
		kr5 = "encyclopedia_creeps_00%02d"
	}

	wid("encyclopedia_enemies_portrait"):set_image(string.format(creep_fmts[KR_GAME], self.entity_icon))
end

function EncycEnemyThumbView:on_click()
	S:queue("GUINotificationPaperOver")
	self:select()
end
