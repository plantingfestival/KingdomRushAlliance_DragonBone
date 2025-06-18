-- chunkname: @./all/helpers.lua

local helpers = {}

function helpers.command_line_has_arg(key)
	return table.contains(arg, "-" .. key)
end

function helpers.command_line_argv(key)
	return arg[table.keyforobject(arg, "-" .. key) + 1]
end

return helpers
