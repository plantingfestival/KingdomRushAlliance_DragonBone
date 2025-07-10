-- chunkname: @./all/platform_services.lua

local var_0_0 = require("klua.log"):new("platform_services")
local var_0_1 = require("hump.signal")
local var_0_2 = require("storage")
local var_0_3 = require("features")
local var_0_4 = 60
local platform_services = {
	services = {},
	signal_handlers = {}
}

platform_services.paused = nil

function platform_services.on_init_signal(arg_1_0, arg_1_1, arg_1_2, arg_1_3, ...)
	if arg_1_2.inited then
		var_0_0.debug("Service %s already inited, skipping delayed init on signal %s", arg_1_1, arg_1_3)

		return
	end

	local var_1_0 = require(arg_1_2.src)

	if not var_1_0 then
		var_0_0.error("Error requiring service %s src %s", arg_1_1, arg_1_2.src)

		return
	end

	var_0_0.debug("Initializing service %s (src=%s) on signal %s", arg_1_1, arg_1_2.src, arg_1_3)

	if var_1_0:init(arg_1_1, arg_1_2.params) then
		arg_1_0.services[arg_1_1] = var_1_0
		var_1_0.name = arg_1_2.name

		if arg_1_2.name ~= arg_1_1 then
			arg_1_0.services[arg_1_2.name] = var_1_0
		end

		var_1_0.ts = 0
	end
end

function platform_services.init(arg_2_0, arg_2_1)
	if not var_0_3.platform_services then
		var_0_0.debug("Platform services not defined. Skipping init")

		return
	end

	local function var_2_0(arg_3_0, arg_3_1)
		if arg_2_1 and not arg_3_1.essential then
			-- block empty
		elseif not arg_3_1.enabled then
			var_0_0.debug("Service %s disabled", arg_3_0)
		elseif not arg_3_1.src then
			var_0_0.error("Service %s has no src param", arg_3_0)
		else
			if arg_3_1.init_cond then
				if arg_3_1.init_cond.only_for_debug and not DEBUG then
					goto label_3_1
				end

				if arg_3_1.init_cond.min_launch_count then
					local var_3_0 = var_0_2:load_global()

					if not var_3_0.launch_count or var_3_0.launch_count < arg_3_1.init_cond.min_launch_count then
						var_0_0.warning("service %s fails init condition min_launch_count < %s", arg_3_0, arg_3_1.init_cond.min_launch_count)

						goto label_3_1
					end
				end

				if arg_3_1.init_cond.on_signals then
					for iter_3_0, iter_3_1 in pairs(arg_3_1.init_cond.on_signals) do
						for iter_3_2, iter_3_3 in pairs(platform_services.signal_handlers) do
							if iter_3_3.service_key == arg_3_0 and iter_3_3.signal_name == iter_3_1 then
								var_0_0.error("service %s has already registered signal %s, skipping", arg_3_0, iter_3_1)

								goto label_3_0
							end
						end

						var_0_0.info("service %s init delayed until signal %s", arg_3_0, iter_3_1)

						do
							local var_3_1 = {
								service_name = arg_3_0,
								signal_name = iter_3_1,
								fn = function(...)
									platform_services:on_init_signal(arg_3_0, arg_3_1, iter_3_1, ...)
								end
							}

							table.insert(platform_services.signal_handlers, var_3_1)
							var_0_1.register(iter_3_1, var_3_1.fn)
						end

						::label_3_0::
					end

					goto label_3_1
				end
			end

			local var_3_2 = require(arg_3_1.src)

			if not var_3_2 then
				var_0_0.error("Error requiring service %s src %s", arg_3_0, arg_3_1.src)
			elseif var_3_2:init(arg_3_0, arg_3_1.params) then
				var_0_0.debug("Service %s (src=%s) initialized", arg_3_0, arg_3_1.src)

				arg_2_0.services[arg_3_0] = var_3_2
				var_3_2.name = arg_3_1.name

				if arg_3_1.name ~= arg_3_0 then
					arg_2_0.services[arg_3_1.name] = var_3_2
				end

				var_3_2.ts = 0
			end
		end

		::label_3_1::
	end

	local var_2_1 = table.keys(var_0_3.platform_services)

	table.sort(var_2_1, function(arg_5_0, arg_5_1)
		local var_5_0 = var_0_3.platform_services[arg_5_0]
		local var_5_1 = var_0_3.platform_services[arg_5_1]

		return (var_5_0.order or var_5_0.essential and 10 or 50) < (var_5_1.order or var_5_1.essential and 10 or 50)
	end)

	for iter_2_0, iter_2_1 in pairs(var_2_1) do
		var_2_0(iter_2_1, var_0_3.platform_services[iter_2_1])
	end
end

function platform_services.shutdown(arg_6_0)
	for iter_6_0, iter_6_1 in pairs(arg_6_0.services) do
		if type(iter_6_1.shutdown) == "function" then
			iter_6_1:shutdown()
		end
	end

	for iter_6_2, iter_6_3 in pairs(arg_6_0.signal_handlers) do
		var_0_1.remove(iter_6_3.signal_name, iter_6_3.fn)
	end
end

function platform_services.update(arg_7_0, arg_7_1)
	for iter_7_0, iter_7_1 in pairs(arg_7_0.services) do
		if type(iter_7_1.update) == "function" then
			if not iter_7_1.can_be_paused or not iter_7_1.paused then
				iter_7_1:update(arg_7_1)
			end

			if not iter_7_1.call_default_update then
				goto label_7_0
			end
		end

		if not iter_7_1.inited then
			-- block empty
		else
			if iter_7_1.update_interval then
				iter_7_1.ts = iter_7_1.ts + arg_7_1

				if iter_7_1.update_interval and iter_7_1.last_ts and iter_7_1.ts - iter_7_1.last_ts < iter_7_1.update_interval then
					goto label_7_0
				end
			end

			if type(iter_7_1.get_status) == "function" then
				local var_7_0 = iter_7_1:get_status()

				if var_7_0 ~= iter_7_1.last_status or iter_7_1.last_ts == nil then
					iter_7_1.last_status = var_7_0

					for iter_7_2, iter_7_3 in pairs(iter_7_1.names) do
						var_0_0.paranoid("status changed for %s: %s", iter_7_3, iter_7_1.last_status)
						var_0_1.emit(SGN_PS_STATUS_CHANGED, iter_7_3, iter_7_1.last_status)
					end
				end
			end

			if type(iter_7_1.update_requests) == "function" then
				iter_7_1:update_requests(arg_7_1)
			end

			if type(iter_7_1.get_pending_requests) == "function" then
				local var_7_1 = {}

				for iter_7_4, iter_7_5 in pairs(iter_7_1:get_pending_requests()) do
					local var_7_2 = iter_7_1:get_request_status(iter_7_4)

					if var_7_2 == 1 then
						if iter_7_5.timeout == -1 then
							-- block empty
						else
							local var_7_3 = love.timer.getTime()
							local var_7_4 = iter_7_5.timeout or var_0_4

							if var_7_4 < var_7_3 - iter_7_5.ts then
								var_0_0.error("request (%s)%s timed out (%s)", iter_7_4, iter_7_5.kind, var_7_4)
								table.insert(var_7_1, iter_7_4)
							end
						end
					else
						if var_7_2 == -1 then
							-- block empty
						elseif iter_7_5.callback then
							iter_7_5.callback(var_7_2, iter_7_5)
						end

						table.insert(var_7_1, iter_7_4)
					end
				end

				for iter_7_6, iter_7_7 in pairs(var_7_1) do
					iter_7_1:cancel_request(iter_7_7)
				end
			end

			if type(iter_7_1.late_update) == "function" and (not iter_7_1.can_be_paused or not iter_7_1.paused) then
				iter_7_1:late_update(arg_7_1)
			end

			iter_7_1.last_ts = iter_7_1.ts
		end

		::label_7_0::
	end
end

return platform_services
