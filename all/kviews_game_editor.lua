-- chunkname: @./all/kviews_game_editor.lua

local log = require("klua.log"):new("kviews_game_editor")

log.level = log.DEBUG_LEVEL

local km = require("klua.macros")

require("klua.table")
require("klove.kui")

local class = require("middleclass")
local V = require("klua.vector")
local v = V.v
local r = V.r
local utf8 = require("utf8")

KE_CONST = {}
KE_CONST.PROP_OX = 0
KE_CONST.PROP_W = 180
KE_CONST.PROP_H = 20
KE_CONST.PROP_VD = KE_CONST.PROP_H + 0
KE_CONST.PROP_NUM_W = 160
KE_CONST.PROP_NUM_BTN_W = 18
KE_CONST.PROP_NUM_SEP = 1
KE_CONST.font_name = "DroidSansMono"
KE_CONST.font_size = 12
KELayout = class("KELayout", KView)
KELayout.static.init_arg_names = {
	"style",
	"separation"
}
KELayout.static.serialize_children = true

KELayout:append_serialize_keys("style")

function KELayout:initialize(style, separation)
	KView.initialize(self)

	self.style = style or "vertical"
	self.separation = separation or V.v(6, 6)

	self:update_layout()
end

function KELayout:update_layout()
	local px, py = 0, 0
	local wx, wy = 0, 0
	local total_w, total_h = 0, 0

	for _, c in pairs(self.children) do
		c.pos.x = px
		c.pos.y = py

		if self.style == "vertical" then
			wx = math.max(px, c.size.x + self.separation.x)
			py = py + c.size.y + self.separation.y
		elseif self.style == "horizontal" then
			px = px + c.size.x + self.separation.x
			wy = math.max(py, c.size.y + self.separation.y)
		end

		total_w = math.max(total_w, px)
		total_h = math.max(total_h, py)
	end

	if self.style == "vertical" then
		total_w = wx
	elseif self.style == "horizontal" then
		total_h = wy
	end

	self.size = V.v(total_w, total_h)
end

KESep = class("KESep", KLabel)
KESep.static.init_arg_names = {
	"title"
}
KESep.static.serialize_children = false

function KESep:initialize(title)
	KLabel.initialize(self, V.v(KE_CONST.PROP_W, KE_CONST.PROP_H + KE_CONST.PROP_H / 2))

	self.text = title
	self.text_offset = V.v(0, KE_CONST.PROP_H / 2)
	self.font_name = KE_CONST.font_name
	self.font_size = KE_CONST.font_size
end

KENum = class("KENum", KView)
KENum.static.init_arg_names = {
	"style",
	"value",
	"step",
	"range"
}
KENum.static.serialize_children = false

function KENum:initialize(style, value, step, range)
	KView.initialize(self)

	self.value = value or 0
	self.step = step or 1
	self.range = range
	self.shift_mult = 10
	self.ctrl_mult = 0.1
	self.alt_mult = 0.01
	self.value_format = "%.2f"

	local w = KE_CONST.PROP_W - KE_CONST.PROP_NUM_BTN_W

	if style == "half" then
		w = KE_CONST.PROP_W / 2 - KE_CONST.PROP_NUM_BTN_W - 2 * KE_CONST.PROP_NUM_SEP
	elseif style == "third" then
		w = KE_CONST.PROP_W / 3 - KE_CONST.PROP_NUM_BTN_W - 3 * KE_CONST.PROP_NUM_SEP
	end

	if range then
		self.propagate_drag = false
		self.propagate_on_down = false
		self.propagate_on_up = false
		self.propagate_on_click = false

		local lr = KView:new(V.v(w, KE_CONST.PROP_H))

		lr.propagate_drag = true
		lr.propagate_on_down = true
		lr.propagate_on_up = true
		lr.propagate_on_click = true
		lr.propagate_on_scroll = true

		local min, max = unpack(self.range)

		lr.anchor.x = 0
		lr.pos.x = lr.size.x * (-min / (max - min))

		self:add_child(lr)

		self.lr = lr
	end

	local lv = KLabel:new(V.v(w, KE_CONST.PROP_H))

	lv.text = self.value
	lv.text_align = "left"
	lv.text_offset.y = 0.25 * KE_CONST.font_size
	lv.colors.background = {
		0,
		0,
		0,
		20
	}
	lv.font_name = KE_CONST.font_name
	lv.font_size = KE_CONST.font_size

	self:add_child(lv)

	self.lv = lv

	if range then
		function lv.on_click(this, button, x, y)
			if button == 2 then
				self:set_value(0)
			else
				local min, max = unpack(self.range)

				self:set_value(min + x / this.size.x * (max - min))
			end
		end

		function lv.update(this, dt)
			if not this._is_down then
				return
			end

			local mx, my, any_button_down = this:get_window():get_mouse_position()
			local wx, wy = this:screen_to_view(mx, my)
			local min, max = unpack(self.range)

			self:set_value(min + wx / this.size.x * (max - min))
		end

		function lv.on_down(this, button, x, y)
			local is_inside = V.is_inside(V.v(x, y), V.r(0, 0, this.size.x, this.size.y))

			if button == 1 and is_inside then
				this._is_down = true
			end
		end

		function lv.on_up(this, button, x, y)
			this._is_down = nil
		end

		function lv.on_exit(this, button, x, y)
			this._is_down = nil
		end

		function lv.on_scroll(this, button)
			local m = 1

			m = m * (button == "wu" and 1 or -1)

			self:set_value(self.value + m * self.step)
		end
	end

	local lb = KButton:new(V.v(KE_CONST.PROP_NUM_BTN_W, KE_CONST.PROP_H / 2 - KE_CONST.PROP_NUM_SEP / 2))

	lb.text = "+"
	lb.text_offset.y = -0.5 * KE_CONST.font_size
	lb.pos = V.v(lv.pos.x + lv.size.x + KE_CONST.PROP_NUM_SEP, 0)
	lb.colors.background = {
		0,
		0,
		0,
		20
	}
	lb.font_name = KE_CONST.font_name
	lb.font_size = KE_CONST.font_size * 1.5

	function lb.on_click()
		local m = 1

		if love.keyboard.isDown("lshift", "rshift") then
			m = self.shift_mult
		end

		if love.keyboard.isDown("lctrl", "rctrl") then
			m = self.ctrl_mult
		end

		if love.keyboard.isDown("lalt", "ralt") then
			m = self.alt_mult
		end

		self:set_value(self.value + m * self.step, false, true)
	end

	self:add_child(lb)

	local lb = KButton:new(V.v(KE_CONST.PROP_NUM_BTN_W, KE_CONST.PROP_H / 2 - KE_CONST.PROP_NUM_SEP / 2))

	lb.text = "-"
	lb.text_offset.y = -0.5 * KE_CONST.font_size
	lb.pos = V.v(lv.pos.x + lv.size.x + KE_CONST.PROP_NUM_SEP, KE_CONST.PROP_H / 2 + KE_CONST.PROP_NUM_SEP / 2)
	lb.colors.background = {
		0,
		0,
		0,
		20
	}
	lb.font_name = KE_CONST.font_name
	lb.font_size = KE_CONST.font_size * 1.5

	function lb.on_click()
		local m = 1

		if love.keyboard.isDown("lshift", "rshift") then
			m = self.shift_mult
		end

		if love.keyboard.isDown("lctrl", "rctrl") then
			m = self.ctrl_mult
		end

		if love.keyboard.isDown("lalt", "ralt") then
			m = self.alt_mult
		end

		self:set_value(self.value - m * self.step, false, true)
	end

	self:add_child(lb)

	self.size = V.v(lb.pos.x + lb.size.x, KE_CONST.PROP_H)

	self:set_value(self.value)
end

function KENum:update(dt)
	self.lv.text = string.format(self.value_format, self.value)

	KENum.super.update(self, dt)
end

function KENum:set_value(value, silent, ignore_range)
	if self.range and not ignore_range then
		local lr = self.lr
		local min, max = unpack(self.range)

		value = km.clamp(min, max, value)
		lr.scale.x = value / (max - min)

		if lr.scale.x > 0 then
			lr.colors.background = {
				0,
				255,
				0,
				100
			}
		else
			lr.colors.background = {
				100,
				100,
				255,
				100
			}
		end
	end

	self.value = value
	self.lv.text = string.format(self.value_format, self.value)

	if self.on_change and not silent then
		self:on_change()
	end
end

KEEnum = class("KEEnum", KView)
KEEnum.static.init_arg_names = {
	"style",
	"list",
	"index"
}
KEEnum.static.serialize_children = false

function KEEnum:initialize(style, list, index)
	KView.initialize(self)

	self.index = index
	self.list = list or {}

	local w = KE_CONST.PROP_W - KE_CONST.PROP_NUM_BTN_W

	if style == "half" then
		w = KE_CONST.PROP_W / 2 - KE_CONST.PROP_NUM_BTN_W - 2 * KE_CONST.PROP_NUM_SEP
	end

	local lv = KLabel:new(V.v(w, KE_CONST.PROP_H))

	lv.text = self.value or ""
	lv.text_align = "left"
	lv.colors.background = {
		0,
		0,
		0,
		20
	}
	lv.font_name = KE_CONST.font_name
	lv.font_size = KE_CONST.font_size

	self:add_child(lv)

	self.lv = lv

	local lb = KButton:new(V.v(KE_CONST.PROP_NUM_BTN_W, KE_CONST.PROP_H / 2 - KE_CONST.PROP_NUM_SEP))

	lb.text = "+"
	lb.pos = V.v(lv.pos.x + lv.size.x + KE_CONST.PROP_NUM_SEP, 0)
	lb.colors.background = {
		0,
		0,
		0,
		20
	}

	function lb.on_click()
		self:set_value((self.index or 0) + 1)
	end

	self:add_child(lb)

	local lb = KButton:new(V.v(KE_CONST.PROP_NUM_BTN_W, KE_CONST.PROP_H / 2 - KE_CONST.PROP_NUM_SEP))

	lb.text = "-"
	lb.pos = V.v(lv.pos.x + lv.size.x + KE_CONST.PROP_NUM_SEP, KE_CONST.PROP_H / 2)
	lb.colors.background = {
		0,
		0,
		0,
		20
	}

	function lb.on_click()
		self:set_value((self.index or 0) - 1)
	end

	self:add_child(lb)

	self.size = V.v(lb.pos.x + lb.size.x, KE_CONST.PROP_H)
end

function KEEnum:update()
	self.lv.text = string.format("%s", self.index and self.list[self.index] or "-")
end

function KEEnum:set_value(index, silent)
	if not index then
		self.index = nil
	elseif not self.index then
		if index > 0 then
			self.index = index
		elseif index < 0 then
			self.index = #self.list
		end
	elseif self.index and (index < 1 or index > #self.list) then
		self.index = nil
	else
		self.index = index
	end

	self:update()

	if self.on_change and not silent then
		self:on_change()
	end
end

function KEEnum:get_value()
	return self.index and self.list[self.index] or nil
end

KEList = class("KEList", KScrollList)
KEList.static.serialize_children = false

function KEList:initialize(size)
	if size then
		size.x = KE_CONST.PROP_W
		size.y = size.y > 0 and size.y or 150
	else
		size = V.v(KE_CONST.PROP_W, 150)
	end

	KScrollList.initialize(self, size)

	if not self.colors.background then
		self.colors.background = {
			0,
			0,
			0,
			30
		}
	end

	self.propagate_drag = false
end

function KEList:select(value, add)
	for i, v in pairs(self.children) do
		if v:isInstanceOf(KLabel) then
			if v.text == value then
				v.colors.background = {
					0,
					0,
					0,
					40
				}
			elseif not add then
				v.colors.background = {
					0,
					0,
					0,
					0
				}
			end
		end
	end
end

function KEList:deselect()
	for i, v in pairs(self.children) do
		if v:isInstanceOf(KLabel) then
			v.colors.background = {
				0,
				0,
				0,
				0
			}
		end
	end
end

KEProp = class("KEProp", KView)
KEProp.static.init_arg_names = {
	"title",
	"value",
	"editable"
}
KEProp.static.serialize_children = false

function KEProp:initialize(title, value, editable)
	KView.initialize(self)

	self.value = value or ""
	self.editable = editable
	self.prop_type = PT_STRING

	local h = 0
	local lt = KLabel:new(V.v(KE_CONST.PROP_W, KE_CONST.PROP_H))

	lt.text = title
	lt.text_align = "left"
	lt.pos = V.v(KE_CONST.PROP_OX, 0)
	lt.font_name = KE_CONST.font_name
	lt.font_size = KE_CONST.font_size

	self:add_child(lt)

	self.lt = lt
	h = h + lt.size.y

	local lv

	lv = KLabel:new(V.v(KE_CONST.PROP_W, KE_CONST.PROP_H))
	lv.text = value or ""
	lv.text_align = "left"
	lv.font_name = KE_CONST.font_name
	lv.font_size = KE_CONST.font_size
	lv.pos = V.v(KE_CONST.PROP_OX, KE_CONST.PROP_H)
	lv.colors.background = {
		0,
		0,
		0,
		20
	}

	self:add_child(lv)

	self.lv = lv
	h = h + lv.size.y
	self.size = V.v(lt.size.x, h)
end

function KEProp:update(dt)
	return
end

function KEProp:set_value(value, silent)
	self.value = value
	self.lv.text = value

	self:update()

	if self.on_change and not silent then
		self:on_change()
	end
end

function KEProp:on_textinput(t)
	if not self.editable then
		return
	end

	self:set_value(self.value .. t)

	return true
end

function KEProp:on_keypressed(key)
	if not self.editable then
		return
	end

	if key == "backspace" then
		local text = self.value
		local byteoffset = utf8.offset(text, -1)

		if byteoffset then
			text = string.sub(text, 1, byteoffset - 1)

			self:set_value(text)
		end
	elseif key == "delete" then
		self:set_value("")
	end
end

KEPropNum = class("KEPropNum", KView)
KEPropNum.static.init_arg_names = {
	"title",
	"value",
	"step",
	"range"
}
KEPropNum.static.serialize_children = false

function KEPropNum:initialize(title, value, step, range)
	KView.initialize(self)

	self.value = value
	self.prop_type = PT_NUMBER

	if range then
		self.range = range
	end

	local h = 0
	local lt = KLabel:new(V.v(KE_CONST.PROP_W, KE_CONST.PROP_H))

	lt.text = title
	lt.text_align = "left"
	lt.font_name = KE_CONST.font_name
	lt.font_size = KE_CONST.font_size
	lt.pos = V.v(KE_CONST.PROP_OX, 0)

	self:add_child(lt)

	self.lt = lt
	h = h + lt.size.y

	local lv = KENum:new("full", value, step, self.range)

	lv.pos = V.v(KE_CONST.PROP_OX, KE_CONST.PROP_H)

	function lv.on_change(this)
		self.value = self.lv.value

		if self.on_change then
			self:on_change()
		end
	end

	self.lv = lv

	self:add_child(lv)

	h = h + lv.size.y
	self.size = V.v(lt.size.x, h)
end

function KEPropNum:update(dt)
	self.value = self.lv.value

	KEPropNum.super.update(self, dt)
end

function KEPropNum:set_value(value, silent)
	self.lv:set_value(value, true)

	self.value = self.lv.value

	if self.on_change and not silent then
		self:on_change()
	end
end

KEPropCoords = class("KEPropCoords", KView)
KEPropCoords.static.init_arg_names = {
	"title",
	"value",
	"step",
	"ranges"
}
KEPropCoords.static.serialize_children = false

function KEPropCoords:initialize(title, value, step, ranges)
	KView.initialize(self)

	step = step or 1
	value = value or V.v(0, 0)
	self.prop_type = PT_COORDS

	local h = 0

	if ranges then
		self.ranges = ranges
	end

	local lt = KLabel:new(V.v(KE_CONST.PROP_W, KE_CONST.PROP_H))

	lt.text = title
	lt.text_align = "left"
	lt.pos = V.v(KE_CONST.PROP_OX, 0)
	lt.font_name = KE_CONST.font_name
	lt.font_size = KE_CONST.font_size

	self:add_child(lt)

	self.lt = lt
	h = h + lt.size.y

	local range1 = self.ranges and self.ranges[1]
	local range2 = self.ranges and self.ranges[2]
	local lv1 = KENum:new("half", value.x, step, range1)

	lv1.pos = V.v(KE_CONST.PROP_OX, KE_CONST.PROP_H)
	self.lv1 = lv1

	self:add_child(lv1)

	local lv2 = KENum:new("half", value.y, step, range2)

	lv2.pos = V.v(lv1.pos.x + lv1.size.x + KE_CONST.PROP_NUM_SEP, KE_CONST.PROP_H)
	self.lv2 = lv2

	self:add_child(lv2)

	function lv1.on_change(this)
		self:sync_value()

		if self.on_change then
			self:on_change()
		end
	end

	lv2.on_change = lv1.on_change
	h = h + lv1.size.y
	self.size = V.v(lt.size.x, h)
end

function KEPropCoords:update(dt)
	self:sync_value()
	KView.update(self, dt)
end

function KEPropCoords:sync_value()
	self.value = V.v(self.lv1.value, self.lv2.value)
end

function KEPropCoords:set_value(value, silent)
	self.lv1:set_value(value.x, true)
	self.lv2:set_value(value.y, true)
	self:sync_value()

	if self.on_change and not silent then
		self:on_change()
	end
end

KEPropPair = class("KEPropPair", KEPropCoords)
KEPropPair.static.init_arg_names = {
	"title",
	"value",
	"step",
	"ranges"
}
KEPropPair.static.serialize_children = false

function KEPropPair:sync_value()
	self.value = {
		self.lv1.value,
		self.lv2.value
	}
end

function KEPropPair:set_value(value, silent)
	self.lv1:set_value(value[1] or 0, true)
	self.lv2:set_value(value[2] or 0, true)
	self:sync_value()

	if self.on_change and not silent then
		self:on_change()
	end
end

KEPropTrio = class("KEPropTrio", KView)
KEPropTrio.static.init_arg_names = {
	"title",
	"value",
	"step",
	"ranges"
}
KEPropTrio.static.serialize_children = false

function KEPropTrio:initialize(title, value, step, ranges)
	KView.initialize(self)

	step = step or 1
	value = value or {
		0,
		0,
		0
	}

	local h = 0
	local lt = KLabel:new(V.v(KE_CONST.PROP_W, KE_CONST.PROP_H))

	lt.text = title
	lt.text_align = "left"
	lt.pos = V.v(KE_CONST.PROP_OX, 0)
	lt.font_name = KE_CONST.font_name
	lt.font_size = KE_CONST.font_size

	self:add_child(lt)

	self.lt = lt
	h = h + lt.size.y

	local px = KE_CONST.PROP_OX

	for i = 1, 3 do
		local range = self.ranges and self.ranges[i]
		local lv = KENum:new("third", value.x, step, range)

		lv.pos = V.v(px, KE_CONST.PROP_H)
		lv.value_format = self.value_format or "%.1f"
		self["lv" .. i] = lv

		self:add_child(lv)

		px = lv.pos.x + lv.size.x + KE_CONST.PROP_NUM_SEP

		function lv.on_change(this)
			self:sync_value()

			if self.on_change then
				self:on_change()
			end
		end
	end

	h = h + self.lv1.size.y
	self.size = V.v(lt.size.x, h)
end

function KEPropTrio:update(dt)
	self:sync_value()
	KView.update(self, dt)
end

function KEPropTrio:sync_value()
	self.value = {
		self.lv1.value,
		self.lv2.value,
		self.lv3.value
	}
end

function KEPropTrio:set_value(value, silent)
	self.lv1:set_value(value[1] or 0, true)
	self.lv2:set_value(value[2] or 0, true)
	self.lv3:set_value(value[3] or 0, true)
	self:sync_value()

	if self.on_change and not silent then
		self:on_change()
	end
end

KEButton = class("KEButton", KButton)
KEButton.static.init_arg_names = {
	"title"
}

function KEButton:initialize(title)
	KButton.initialize(self, V.v(KE_CONST.PROP_W, KE_CONST.PROP_H))

	self.text = title
	self.font_name = KE_CONST.font_name
	self.font_size = KE_CONST.font_size
	self.colors.background = {
		0,
		0,
		0,
		40
	}

	if self.size and self.font_size and (not self.text_offset or self.text_offset.y == 0) then
		self.text_offset = V.v(self.text_offset.x or 0, (self.size.y - self.font_size) / 2)
	end
end

function KEButton:activate()
	self.active = true
	self.colors.background = {
		200,
		200,
		0,
		60
	}
end

function KEButton:deactivate()
	self.active = false
	self.colors.background = {
		0,
		0,
		0,
		40
	}
end

KEPropBool = class("KEPropBool", KEButton)
KEPropBool.static.init_arg_names = {
	"title",
	"value",
	"inactive_title"
}

function KEPropBool:initialize(title, value, inactive_title)
	KEButton.initialize(self, title)

	self.value = value
	self.active_title = title
	self.inactive_title = inactive_title

	self:update(0)
end

function KEPropBool:update(dt)
	if self.value ~= self.active then
		if self.value then
			self:activate()

			self.text = self.active_title
		else
			self:deactivate()

			self.text = self.inactive_title or self.active_title
		end
	end

	KEButton.update(self, dt)
end

function KEPropBool:set_value(value, silent)
	self.active = "force update"
	self.value = value

	self:update(0)

	if self.on_change and not silent then
		self:on_change()
	end
end

function KEPropBool:on_click(btn, x, y)
	self:set_value(not self.value)
end

KEPicker = class("KEPicker", KView)

function KEPicker:on_click(btn, x, y)
	self.gui:click_tool(btn, x, y)
end

function KEPicker:on_down(btn, x, y)
	self.tracking = true

	self.gui:down_tool(btn, x, y)
end

function KEPicker:on_up(btn, x, y)
	self.tracking = false

	self.gui:up_tool(btn, x, y)
end

function KEPicker:update(dt)
	local x, y = love.mouse.getPosition()

	if not self._last_pos then
		self._last_pos = {}
		self._last_pos.x = x
		self._last_pos.y = y
	end

	if self._last_pos.x ~= x or self._last_pos.y ~= y then
		local down_1 = love.mouse.isDown(1)
		local down_2 = love.mouse.isDown(2)
		local down = self.tracking and (down_1 and 1 or down_2 and 2 or nil)

		self.gui:move_tool(x, y, down)
	end

	self._last_pos.x = x
	self._last_pos.y = y
end

KEPointerPos = class("KEPointerPos", KView)
KEPointerPos.static.serialize_children = false

function KEPointerPos:initialize(size)
	KView.initialize(self, size)

	local lt = KLabel:new(V.v(KE_CONST.PROP_W, KE_CONST.PROP_H))

	lt.text = ""
	lt.text_align = "left"
	lt.pos = V.v(KE_CONST.PROP_OX, 0)
	lt.font_name = KE_CONST.font_name
	lt.font_size = KE_CONST.font_size

	self:add_child(lt)

	self.lt = lt
end

KECellInfo = class("KECellInfo", KView)
KECellInfo.static.serialize_children = false

function KECellInfo:initialize(size)
	KView.initialize(self, size)

	local lt = KLabel:new(V.v(KE_CONST.PROP_W / 2, KE_CONST.PROP_H))

	lt.text = ""
	lt.text_align = "left"
	lt.pos = V.v(KE_CONST.PROP_OX, 0)
	lt.font_name = KE_CONST.font_name
	lt.font_size = KE_CONST.font_size

	self:add_child(lt)

	self.lt = lt

	local gt = KLabel:new(V.v(KE_CONST.PROP_W / 2, KE_CONST.PROP_H))

	gt.text = ""
	gt.text_align = "right"
	gt.pos = V.v(KE_CONST.PROP_OX + KE_CONST.PROP_W / 2, 0)
	gt.font_name = KE_CONST.font_name
	gt.font_size = KE_CONST.font_size

	self:add_child(gt)

	self.gt = gt
end
