-- chunkname: @./kr5/game_gui_classes.lua

local log = require("klua.log"):new("game_gui_classes")
local class = require("middleclass")

require("klua.table")

local km = require("klua.macros")
local V = require("klua.vector")
local ISM = require("klove.input_state_machine")

require("constants")

MousePointer = class("MousePointer", KView)

function MousePointer:initialize()
	MousePointer.super.initialize(self)

	self.propagate_on_click = true
	self.propagate_on_down = true
	self.propagate_on_up = true
	self.scale = V.vv(0.85)

	local rally_tower = KImageView:new("pointer_set_rally_0001")

	rally_tower.anchor = V.v(rally_tower.size.x / 2, rally_tower.size.y / 2)
	rally_tower.animation = {
		to = 10,
		prefix = "pointer_set_rally",
		from = 1
	}
	rally_tower.loop = true

	local ipc = KImageView:new("error_feedback_0001")

	ipc.anchor = V.v(ipc.size.x / 2, ipc.size.y / 2)
	ipc.animation = {
		to = 14,
		prefix = "error_feedback",
		from = 1
	}

	local pirate_camp = KImageView:new("pointer_pirate_cannons")

	pirate_camp.anchor = V.v(pirate_camp.size.x / 2, pirate_camp.size.y / 2)
	pirate_camp.alpha = 0.75

	local hand = KImageView:new("pointer_hand_48_0001")

	hand.anchor = V.v(0, 0)
	hand.scale = V.v(1.8, 1.8)
	hand.when_released = true

	local hand_down = KImageView:new("pointer_hand_48_0002")

	hand_down.anchor = V.v(0, 0)
	hand_down.scale = V.v(1.8, 1.8)
	hand_down.when_pressed = true

	local pr = KImageView:new("pointer_point_0001")

	pr.anchor = V.v(pr.size.x / 2, pr.size.y / 2)
	pr.animation = {
		to = 10,
		prefix = "pointer_point",
		from = 1
	}
	pr.loop = true

	local pri = KImageView:new("pointer_power_reinforcements")

	pri.anchor = V.v(pri.size.x / 2, pri.size.y)
	pri.pos.x, pri.pos.y = pr.size.x / 2, pr.size.y / 2

	pr:add_child(pri)

	self.cross = ipc
	self.pointers = {
		[GUI_MODE_RALLY_TOWER] = {
			default = rally_tower
		},
		[GUI_MODE_RALLY_HERO] = {
			default = rally_tower
		},
		[GUI_MODE_RALLY_RE] = {
			default = rally_tower
		},
		[GUI_MODE_SELECT_POINT] = {
			default = pirate_camp
		},
		[GUI_MODE_POWER_1] = {
			default = pr
		},
		[GUI_MODE_POINTER] = {
			default = hand,
			up = hand,
			down = hand_down
		}
	}

	self:refresh_hero_pointers()
end

function MousePointer:refresh_hero_pointers()
	local ph1, ph2

	for i, hero in ipairs(game.store.hero_team) do
		local p_style = hero.info.ultimate_pointer_style == "area" and "area" or "point"
		local p = KImageView:new("pointer_" .. p_style .. "_0001")

		p.anchor = V.v(p.size.x / 2, p.size.y / 2)
		p.animation = {
			to = 10,
			from = 1,
			prefix = "pointer_" .. p_style
		}
		p.loop = true

		local pi = KImageView:new("pointer_power_" .. hero.info.ultimate_icon)

		pi.anchor = V.v(pi.size.x / 2, pi.size.y)
		pi.pos.x, pi.pos.y = p.size.x / 2, p.size.y / 2

		p:add_child(pi)
		log.debug("creating hero pointer with image %s", "pointer_power_" .. hero.info.ultimate_icon)

		if i == 1 then
			ph1 = p
		else
			ph2 = p
		end
	end

	self.pointers[GUI_MODE_POWER_2] = {
		default = ph1
	}
	self.pointers[GUI_MODE_POWER_3] = {
		default = ph2
	}
end

function MousePointer:update_pointer(mode)
	self.last_mode = mode

	local ktw = self:get_window().ktw

	ktw:cancel(self)

	if ISM.last_input == I_TOUCH then
		self.hidden = true

		love.mouse.setVisible(false)

		return
	end

	local pointer
	local pointers = self.pointers[mode]

	if pointers then
		local e = game.game_gui.selected_entity

		if e and e.user_selection and e.user_selection.custom_pointer_name and pointers[e.user_selection.custom_pointer_name] then
			pointer = pointers[e.user_selection.custom_pointer_name]
		else
			pointer = pointers.default
		end
	end

	if not pointer then
		self.hidden = true

		ISM:force_hide_mouse_pointer(nil)
	else
		ISM:force_hide_mouse_pointer(true)
		self:remove_children()
		self:add_child(pointer)

		self.hidden = false
	end

	log.paranoid("mode:%s pointer:%s hidden:%s", mode, pointer and pointer.image_name, self.hidden)
end

function MousePointer:show_cross()
	if not self.last_cursor and (not self.hidden or true) then
		self.last_cursor = self.children[1]
	end

	self:remove_children()
	self:add_child(self.cross)

	self.cross.ts = 0
	self.hidden = false

	local ktw = self:get_window().ktw

	ktw:cancel(self)
	ktw:after(self, 0.4666666666666667, function()
		self:remove_children()

		if self.last_cursor then
			self:add_child(self.last_cursor)

			self.last_cursor = nil
		else
			self.hidden = true
		end
	end)
end

function MousePointer:update(dt)
	if not self.hidden then
		local w = self:get_window()
		local x, y

		if ISM.j_pointer_active then
			x, y = ISM.j_pointer_pos.x, ISM.j_pointer_pos.y
		else
			x, y = w:get_mouse_position()
		end

		self.pos.x, self.pos.y = w:screen_to_view(x, y)

		if self.last_mode == GUI_MODE_POINTER and self.children[1] then
			if self.is_gamepad_pressed == true and self.children[1].when_released then
				self:remove_children()
				self:add_child(self.pointers[self.last_mode].down)
			elseif self.is_gamepad_pressed == false and self.children[1].when_pressed then
				self:remove_children()
				self:add_child(self.pointers[self.last_mode].up)
			end
		end
	end

	MousePointer.super.update(self, dt)
end

function MousePointer:on_gamepad_pressed(joystick, button, gui_mode)
	self.is_gamepad_pressed = true
end

function MousePointer:on_gamepad_released(joystick, button, gui_mode)
	self.is_gamepad_pressed = false
end
