-- chunkname: @./kr5/data/levels/level9000.lua

local log = require("klua.log"):new("level9000")
local signal = require("hump.signal")
local E = require("entity_db")
local S = require("sound_db")
local U = require("utils")
local LU = require("level_utils")
local V = require("klua.vector")
local P = require("path_db")

require("constants")

local TU = require("test.test_utils")

local function fts(v)
	return v / FPS
end

local level = {}
local test_case_path = "test-cases." .. main.params.custom

level.test_case = require(test_case_path)

function level:preprocess(store)
	local test_update = self.update

	if self.test_case.preprocess then
		self.test_case:preprocess(self, store)
	end

	self.update = test_update
end

function level:load(store)
	package.loaded[test_case_path] = nil
	level.test_case = require(test_case_path)

	if self.test_case.load then
		self.test_case:load(self, store)
	end
end

function level:update(store)
	if self.test_case.update then
		self.test_case:update(self, store)
	end
end

return level
