-- chunkname: @./all/jni_android.lua

require("all.jni")

local ffi = require("ffi")
local C = ffi.C
local log = {}

log.logger_name = "jni_android"

function log.get_klog()
	if not log.klog then
		local ok, llog = pcall(require, "klua.log")

		if ok and llog then
			log.klog = llog:new(log.logger_name)
		end
	end
end

function log.log(level_string, fmt, ...)
	local func_info = debug.getinfo(3, "n")
	local func_name = func_info.name or "-"
	local time = love and love.timer.getTime() or os.clock()
	local user_str = string.format(fmt or "", ...)
	local o = string.format("+[%.4f] %s.%s %s() - %s\n", time, log.logger_name, level_string, func_name, user_str)

	print(o)
end

function log.error(fmt, ...)
	log.get_klog()

	if log.klog then
		log.klog.error(fmt, ...)
	else
		log.log("ERROR   ", fmt, ...)
	end
end

function log.warning(fmt, ...)
	log.get_klog()

	if log.klog then
		log.klog.warning(fmt, ...)
	else
		log.log("WARNING ", fmt, ...)
	end
end

function log.info(fmt, ...)
	log.get_klog()

	if log.klog then
		log.klog.info(fmt, ...)
	else
		log.log("INFO    ", fmt, ...)
	end
end

function log.debug(fmt, ...)
	log.get_klog()

	if log.klog then
		log.klog.debug(fmt, ...)
	else
		log.log("DEBUG   ", fmt, ...)
	end
end

function log.paranoid(fmt, ...)
	log.get_klog()

	if log.klog then
		log.klog.paranoid(fmt, ...)
	else
		log.log("PARANOID", fmt, ...)
	end
end

local function jni_get_method(name, signature)
	local jenv = C.SDL_AndroidGetJNIEnv()

	if jenv == nil or jenv[0] == nil then
		log.error("error in SDL_AndroidGetJNIEnv() for method:%s %s", name, signature)

		return nil
	end

	local jact = C.SDL_AndroidGetActivity()

	if jact == nil then
		log.error("error in SDL_AndroidGetActivity() for method:%s %s", name, signature)

		return nil
	end

	local jclass = jenv[0].GetObjectClass(jenv, jact)

	if jclass == nil or jenv[0].ExceptionCheck(jenv) == 1 then
		log.error("error in GetObjectClass() for method:%s %s", name, signature)
		jenv[0].ExceptionClear(jenv)
		jenv[0].DeleteLocalRef(jenv, jact)

		return nil
	end

	local jm = jenv[0].GetMethodID(jenv, jclass, name, signature)

	if jm == nil or jenv[0].ExceptionCheck(jenv) == 1 then
		log.error("error in GetMethodID for method:%s %s", name, signature)
		jenv[0].ExceptionClear(jenv)
		jenv[0].DeleteLocalRef(jenv, jact)
		jenv[0].DeleteLocalRef(jenv, jclass)

		return nil
	end

	return jenv, jact, jclass, jm
end

local function jni_delete_refs(jenv, ...)
	if jenv ~= nil and jenv[0] ~= nil then
		if jenv[0].ExceptionCheck(jenv) == 1 then
			log.debug("cleaning up pending exceptions")
			jenv[0].ExceptionClear(jenv)
		end

		for _, ref in pairs({
			...
		}) do
			if ref ~= nil then
				jenv[0].DeleteLocalRef(jenv, ref)
			end
		end
	end
end

local jnia = {}

jnia.jni_get_method = jni_get_method
jnia.jni_delete_refs = jni_delete_refs

function jnia.get_system_property(key)
	local result, jp2
	local jenv, jact, jclass, jm = jni_get_method("getSystemProperty", "(Ljava/lang/String;)Ljava/lang/String;")

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, key or "")

		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, jp2)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_loggerhead_arch()
	return jnia.get_system_property("LOGGERHEAD_ARCH")
end

function jnia.get_loggerhead_id()
	return jnia.get_system_property("LOGGERHEAD_ID")
end

function jnia.get_loggerhead_time()
	return jnia.get_system_property("LOGGERHEAD_TIME")
end

function jnia.get_request_status(rid)
	local result = -1
	local jenv, jact, jclass, jm = jni_get_method("getRequestStatus", "(I)I")

	if jm ~= nil then
		result = jenv[0].CallIntMethod(jenv, jact, jm, ffi.cast("int", rid))
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_request_error_message(rid)
	local result
	local jenv, jact, jclass, jm = jni_get_method("getRequestErrorMessage", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, ffi.cast("int", rid))

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.delete_request(rid)
	local jenv, jact, jclass, jm = jni_get_method("deleteRequest", "(I)V")

	if jm ~= nil then
		jenv[0].CallVoidMethod(jenv, jact, jm, ffi.cast("int", rid))
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.set_service_param(key, value)
	local jenv, jact, jclass, jm = jni_get_method("setServiceParam", "(Ljava/lang/String;Ljava/lang/String;)V")
	local jp1, jp2

	if jm ~= nil then
		jp1 = jenv[0].NewStringUTF(jenv, key)
		jp2 = jenv[0].NewStringUTF(jenv, value)

		jenv[0].CallVoidMethod(jenv, jact, jm, jp1, jp2)
	end

	jni_delete_refs(jenv, jp1, jp2, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.init_service(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("initService", "(I)Z")

	if jm then
		result = jenv[0].CallBooleanMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_service_status(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getServiceStatus", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.do_signin(srvid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("doServiceSignIn", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.do_signout(srvid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("doServiceSignOut", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.create_request_do_signin(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestDoSignIn", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.unlock_achievement(srvid, ach_id)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("unlockAchievement", "(ILjava/lang/String;)V")
	local jstr

	if jm then
		jstr = jenv[0].NewStringUTF(jenv, ach_id)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jstr)
	end

	jni_delete_refs(jenv, jstr, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.show_achievements(srvid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("showAchievements", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.show_leaderboard(srvid, board_id)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("showLeaderboard", "(ILjava/lang/String;)V")
	local jstr

	if jm then
		jstr = jenv[0].NewStringUTF(jenv, board_id)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jstr)
	end

	jni_delete_refs(jenv, jstr, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.submit_score(srvid, board_id, score)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("submitScore", "(ILjava/lang/String;I)V")
	local jstr

	if jm then
		jstr = jenv[0].NewStringUTF(jenv, board_id)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jstr, ffi.cast("int", score))
	end

	jni_delete_refs(jenv, jstr, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.get_cached_slot(srvid, idx)
	local result
	local csrvid = ffi.cast("int", srvid)
	local idx_c = ffi.cast("jint", idx - 1)
	local jenv, jact, jclass, jm = jni_get_method("getCachedSlot", "(II)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid, idx_c)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_sync_slots(srvid, progress)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local progress_len = ffi.cast("jsize", #progress)
	local progress_c = ffi.new("jint[?]", #progress, progress)
	local jenv, jact, jclass, jm = jni_get_method("createRequestSyncSlots", "(I[I)I")
	local jp2

	if jm then
		jp2 = jenv[0].NewIntArray(jenv, progress_len)

		jenv[0].SetIntArrayRegion(jenv, jp2, 0, progress_len, progress_c)

		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_push_slot(srvid, idx, name, progress, data, overwrite)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local idx_c = ffi.cast("jint", idx - 1)
	local progress_c = ffi.cast("jint", progress)
	local jenv, jact, jclass, jm = jni_get_method("createRequestPushSlot", "(IILjava/lang/String;ILjava/lang/String;Z)I")
	local name_j, data_j

	if jm then
		name_j = jenv[0].NewStringUTF(jenv, name)
		data_j = jenv[0].NewStringUTF(jenv, data)
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, idx_c, name_j, progress_c, data_j, overwrite)
	end

	jni_delete_refs(jenv, name_j, data_j, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_delete_slot(srvid, idx)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local idx_c = ffi.cast("jint", idx - 1)
	local jenv, jact, jclass, jm = jni_get_method("createRequestDeleteSlot", "(II)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, idx_c)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_cloud_identity(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getCloudIdentity", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_formatted_currency(amount_micros, currency_code)
	local result = "?"
	local camount = ffi.cast("double", amount_micros)
	local jenv, jact, jclass, jm = jni_get_method("getFormattedCurrency", "(DLjava/lang/String;)Ljava/lang/String;")
	local jp3

	if jm then
		jp3 = jenv[0].NewStringUTF(jenv, currency_code or "USD")

		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, camount, jp3)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jp3, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_cached_products(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getCachedProducts", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_cached_purchases(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getCachedPurchases", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_cached_purchase_history(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getCachedPurchaseHistory", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.query_purchases(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("queryPurchases", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_query_purchases(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestQueryPurchases", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_query_purchase_history(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestQueryPurchaseHistory", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_sync_products(srvid, products_string)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestSyncProducts", "(ILjava/lang/String;)I")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, products_string)
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_purchase_product(srvid, pid, consume)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestPurchaseProduct", "(ILjava/lang/String;)I")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, pid)
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_consume_product(srvid, token)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestConsumeProduct", "(ILjava/lang/String;)I")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, token)
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_acknowledge_product(srvid, token)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestAcknowledgeProduct", "(ILjava/lang/String;)I")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, token)
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_check_drm(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestCheckDRM", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_drm_status(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getDRMStatus", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.has_video_ad(srvid, style)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("hasVideoAd", "(ILjava/lang/String;)Z")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, style)
		result = jenv[0].CallBooleanMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result == 1
end

function jnia.cache_video_ad(srvid, style)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("cacheVideoAd", "(ILjava/lang/String;)V")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, style)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.create_request_show_video_ad(srvid, style)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestShowVideoAd", "(ILjava/lang/String;)I")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, style)
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.launch_mediation_test(srvid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("launchMediationTest", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.log_analytics_event(srvid, name, key, value)
	key = key or ""
	value = value or ""

	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("logAnalyticsEvent", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")
	local jp2, jp3, jp4

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, name)
		jp3 = jenv[0].NewStringUTF(jenv, key)
		jp4 = jenv[0].NewStringUTF(jenv, value)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jp2, jp3, jp4)
	end

	jni_delete_refs(jenv, jp2, jp3, jp4, jclass, jact)
	log.paranoid("jnia call ok")
end

function jnia.log_analytics_event_multiparam(srvid, name, params)
	if not params or #params == 0 then
		return
	end

	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("logAnalyticsEventMultiparam", "(ILjava/lang/String;Ljava/lang/String;)V")
	local jp2, jp3

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, name)

		local params_in_string = ""

		for _, k in ipairs(params) do
			local key = k[1]
			local value = k[2]

			params_in_string = params_in_string .. ";;" .. key .. "==" .. value
		end

		params_in_string = params_in_string:sub(3)

		log.info(params_in_string)

		jp3 = jenv[0].NewStringUTF(jenv, params_in_string)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jp2, jp3)
	end

	jni_delete_refs(jenv, jp2, jp3, jclass, jact)
	log.paranoid("jnia call ok")
end

function jnia.get_messaging_token(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getMessagingToken", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)
			result = result ~= "" and result or nil

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_messaging_ids(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getMessagingIds", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)
			result = result ~= "" and result or nil

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_messaging_should_request_permission(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getMessagingShouldRequestPermission", "(I)Z")

	if jm then
		result = jenv[0].CallBooleanMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result == 1
end

function jnia.get_messaging_should_show_rationale(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getMessagingShouldShowRationale", "(I)Z")

	if jm then
		result = jenv[0].CallBooleanMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result == 1
end

function jnia.get_messaging_permission_granted(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getMessagingPermissionGranted", "(I)Z")

	if jm then
		result = jenv[0].CallBooleanMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result == 1
end

function jnia.create_request_messaging_ask_permission(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestMessagingAskPermission", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_deep_link(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getDeepLink", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)
			result = result ~= "" and result or nil

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_deep_link_epoch(srvid)
	local result = 0
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getDeepLinkEpoch", "(I)I")

	if jm ~= nil then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_dynamic_link(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getDynamicLink", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)
			result = result ~= "" and result or nil

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_remote_config_string(srvid, key)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getRemoteConfigString", "(ILjava/lang/String;)Ljava/lang/String;")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, key)

		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid, jp2)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)
			result = result ~= "" and result or nil

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_remote_config_keys(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getRemoteConfigKeys", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)
			result = result ~= "" and result or nil

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_sync_remote_config(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestSyncRemoteConfig", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.crashlytics_crash_test()
	local jenv, jact, jclass, jm = jni_get_method("crashTest", "()V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.crashlytics_log_and_crash(msg)
	local jenv, jact, jclass, jm = jni_get_method("crashWithLog", "(Ljava/lang/String;)V")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, msg)

		jenv[0].CallVoidMethod(jenv, jact, jm, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.crashlytics_set_collection(value)
	local jenv, jact, jclass, jm = jni_get_method("setCrashCollection", "(Z)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, value)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.launch_market()
	local jenv, jact, jclass, jm = jni_get_method("launchMarket", "()V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.show_game_assistant(srvid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("showGameAssistant", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.hide_game_assistant(srvid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("hideGameAssistant", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.create_request_https(srvid, method, url, headers, body)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestHttps", "(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)I")
	local jp2, jp3, jp4, jp5

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, method)
		jp3 = jenv[0].NewStringUTF(jenv, url)
		jp4 = jenv[0].NewStringUTF(jenv, headers)
		jp5 = jenv[0].NewStringUTF(jenv, body)
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, jp2, jp3, jp4, jp5)
	end

	jni_delete_refs(jenv, jp2, jp3, jp4, jp5, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_https_response_code(srvid, rid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local crid = ffi.cast("int", rid)
	local jenv, jact, jclass, jm = jni_get_method("getHttpsResponseCode", "(II)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid, crid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_https_response_headers(srvid, rid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local crid = ffi.cast("int", rid)
	local jenv, jact, jclass, jm = jni_get_method("getHttpsResponseHeaders", "(II)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid, crid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_https_response_data(srvid, rid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local crid = ffi.cast("int", rid)
	local jenv, jact, jclass, jm = jni_get_method("getHttpsResponseData", "(II)[B")

	if jm then
		local cb = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid, crid)

		if not cb then
			log.paranoid("error getting https byte array for rid %s", rid)
		else
			local cbsize = jenv[0].GetArrayLength(jenv, cb)
			local cba = jenv[0].GetByteArrayElements(jenv, cb, nil)

			result = ffi.string(cba, cbsize)

			jenv[0].ReleaseByteArrayElements(jenv, cb, cba, 2)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.delete_https_response(srvid, rid)
	local csrvid = ffi.cast("int", srvid)
	local crid = ffi.cast("int", rid)
	local jenv, jact, jclass, jm = jni_get_method("deleteHttpsResponse", "(II)V")

	if jm ~= nil then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, crid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.enforce_license(srvid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("enforceLicense", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.create_request_check_license(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestCheckLicense", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_license_status(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getLicenseStatus", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.get_consent_status(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getConsentStatus", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_sync_consent_status(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestSyncConsentStatus", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_show_consent_form(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestShowConsentForm", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_show_consent_options(srvid)
	local result = -1
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestShowConsentOptions", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.reset_consent_status(srvid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("resetConsentStatus", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.add_consent_test_device(srvid, deviceid)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("addConsentTestDevice", "(ILjava/lang/String;)V")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, deviceid)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.add_consent_test_geography(srvid, location)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("addConsentTestGeography", "(ILjava/lang/String;)V")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, location)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.has_more_games(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("hasMoreGames", "(I)Z")

	if jm then
		result = jenv[0].CallBooleanMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result == 1
end

function jnia.show_more_games(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("showMoreGames", "(I)V")

	if jm then
		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.open_channel_url(srvid, url)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("openChannelUrl", "(ILjava/lang/String;)V")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, url)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")
end

function jnia.get_channel_url(srvid, id)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("getChannelUrl", "(ILjava/lang/String;)Ljava/lang/String;")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, id)

		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid, jp2)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.check_quit_game_status(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("checkQuitGameStatus", "(I)Ljava/lang/String;")

	if jm then
		local jo = jenv[0].CallObjectMethod(jenv, jact, jm, csrvid)

		if jo ~= nil then
			local js = jenv[0].GetStringUTFChars(jenv, jo, nil)

			result = ffi.string(js)

			jenv[0].ReleaseStringUTFChars(jenv, jo, js)
			jenv[0].DeleteLocalRef(jenv, jo)
		end
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.create_request_quit_game(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("createRequestQuitGame", "(I)I")

	if jm then
		result = jenv[0].CallIntMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result
end

function jnia.should_hide_quit_prompt(srvid)
	local result
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("shouldHideQuitPrompt", "(I)Z")

	if jm then
		result = jenv[0].CallBooleanMethod(jenv, jact, jm, csrvid)
	end

	jni_delete_refs(jenv, jact, jclass)
	log.paranoid("jnia call ok")

	return result == 1
end

function jnia.debug_set_quit_game_status(srvid, msg)
	local csrvid = ffi.cast("int", srvid)
	local jenv, jact, jclass, jm = jni_get_method("debugSetQuitGameStatus", "(ILjava/lang/String;)V")
	local jp2

	if jm then
		jp2 = jenv[0].NewStringUTF(jenv, msg)

		jenv[0].CallVoidMethod(jenv, jact, jm, csrvid, jp2)
	end

	jni_delete_refs(jenv, jp2, jact, jclass)
	log.paranoid("jnia call ok")
end

return jnia
