// debugC.cpp
#define DEBUG_C
#include "debugC.h"

#include <string>
#include <sstream>
#include <cstddef>
#include <vector>
#include <atomic>
#include <mutex>
#include <chrono>
#include <ctime>
#include <iomanip>
#include <lua.hpp>

#if defined(__ANDROID__)

#include <cstdint>
#include <unwind.h>
#include <dlfcn.h>
#include <cxxabi.h>
#include <cstdlib>

#else

#include <cpptrace/cpptrace.hpp>

#endif

namespace debug {
	// 错误信息
	static std::vector<std::string> errorMessages;
	// 保护 errorMessage 的互斥锁
	static std::mutex debugMutex;
	// log 信息
	static std::vector<std::string> logs;
	static std::vector<std::string> tmpLogs;
}

// Android backtrace
#if defined(__ANDROID__)

struct AndroidBacktraceState {
	void** current;
	void** end;
};

static _Unwind_Reason_Code android_unwind_cb(_Unwind_Context* ctx, void* arg) {
	auto* state = (AndroidBacktraceState*)arg;

	uintptr_t pc = _Unwind_GetIP(ctx);

	if (pc) pc -= 1;

	if (!pc) return _URC_NO_REASON;

	if (state->current == state->end)
		return _URC_END_OF_STACK;

	*state->current++ = (void*)pc;
	return _URC_NO_REASON;
}

static size_t capture_android_backtrace(void** buffer, size_t max) {
	AndroidBacktraceState state{buffer, buffer + max};
	_Unwind_Backtrace(android_unwind_cb, &state);
	return state.current - buffer;
}

#endif

// 生成堆栈字符串
static std::string capture_stack_trace() {
	std::ostringstream oss;

#if defined(__ANDROID__)

	void* buffer[64];
	size_t count = capture_android_backtrace(buffer, 64);

	oss << "Stack trace (most recent call first):\n";

	const size_t skip = 2;

	for (size_t i = skip; i < count; i++) {
		Dl_info info;
		uintptr_t addr = (uintptr_t)buffer[i];

		oss << "#" << (i - skip)
			<< " 0x" << std::hex << addr << std::dec;

		if (dladdr(buffer[i], &info) && info.dli_sname) {

			int status = 0;
			char* demangled = abi::__cxa_demangle(
				info.dli_sname, nullptr, nullptr, &status);

			const char* name =
				(demangled && status == 0) ? demangled : info.dli_sname;

			uintptr_t sym_addr = (uintptr_t)info.dli_saddr;

			oss << " in " << name;

			if (sym_addr) {
				oss << "+" << (addr - sym_addr);
			}

			if (info.dli_fname) {
				oss << " (" << info.dli_fname << ")";
			}

			if (demangled) std::free(demangled);

		} else {
			oss << " in ??";
		}

		oss << "\n";
	}

#else

	cpptrace::generate_trace().print(oss);

#endif

	return oss.str();
}

extern "C" {
	void log_c(const char* logMessage) {
		if (!logMessage) [[unlikely]] return;

		auto now = std::chrono::system_clock::now();
		std::time_t t = std::chrono::system_clock::to_time_t(now);
		auto us = std::chrono::duration_cast<std::chrono::microseconds>(now.time_since_epoch()).count() % 1000000LL;

		std::tm tm;
#if defined(_WIN32)
		localtime_s(&tm, &t);
#else
		localtime_r(&t, &tm);
#endif

		char buffer[256];
		int len = snprintf(
			buffer, sizeof(buffer),
			"[%04d-%02d-%02d %02d:%02d:%02d.%06lld] %s",
			tm.tm_year + 1900,
			tm.tm_mon + 1,
			tm.tm_mday,
			tm.tm_hour,
			tm.tm_min,
			tm.tm_sec,
			(long long)us,
			logMessage
		);
		
		if (len < (int)sizeof(buffer)) {
			// 没截断
			std::lock_guard<std::mutex> lock(debug::debugMutex);
			debug::logs.emplace_back(buffer);
		} else {
			// 被截断 → 重新分配
			std::string full;
			full.resize(len + 1);
			snprintf(
				full.data(), full.size(),
				"[%04d-%02d-%02d %02d:%02d:%02d.%06lld] %s",
				tm.tm_year + 1900,
				tm.tm_mon + 1,
				tm.tm_mday,
				tm.tm_hour,
				tm.tm_min,
				tm.tm_sec,
				(long long)us,
				logMessage
			);
			std::lock_guard<std::mutex> lock(debug::debugMutex);
			debug::logs.emplace_back(std::move(full));
		}
	}

	// ==================== Debug 记录，Release 不记录 ====================
	void debug_log_c(const char* logMessage) {
	#ifndef NDEBUG
		if (!logMessage) [[unlikely]] return;
		// 构造带前缀的消息
		std::string prefixed = "[DEBUG] ";
		prefixed += logMessage;
		log_c(prefixed.c_str());
	#else
		(void)logMessage;
	#endif
	}

	int l_flush_logs(lua_State* L) {
		// 清空 tmpLogs（复用 capacity，避免 realloc）
		debug::tmpLogs.clear();

		// 快速交换 logs -> tmpLogs（O(1)）
		{
			std::lock_guard<std::mutex> lock(debug::debugMutex);
			if (debug::logs.empty()) {
				lua_pushboolean(L, 0);
				return 1;
			}
			debug::logs.swap(debug::tmpLogs);
		}

		// 不持锁，安全调用 Lua
		for (const auto& msg : debug::tmpLogs) {
			lua_getglobal(L, "print");
			lua_pushlstring(L, msg.c_str(), msg.size());
			if (lua_pcall(L, 1, 0, 0) != 0) {
				lua_pop(L, 1); // 弹错误
			}
		}

		lua_pushboolean(L, 1);
		return 1;
	}

	// 记录错误
	void record_error(const char* errorMessage) {
		if (errorMessage) {
			// 错误信息加锁保护，保证线程安全
			std::lock_guard<std::mutex> lock(debug::debugMutex);
			// 拼接错误信息和堆栈
			std::string message = std::string(errorMessage) + "\n" + capture_stack_trace();
			debug::errorMessages.emplace_back(std::move(message));
		}
	}

	int l_push_error(lua_State* L) {
		debug::tmpLogs.clear();
		{
			std::lock_guard<std::mutex> lock(debug::debugMutex);
			if (debug::errorMessages.empty()) {
				lua_pushboolean(L, 0);
				return 1;
			}
			debug::errorMessages.swap(debug::tmpLogs);
		}
		for (const auto& msg : debug::tmpLogs) {
			lua_getglobal(L, "print");
			lua_pushlstring(L, msg.c_str(), msg.size());
			if (lua_pcall(L, 1, 0, 0) != 0) {
				lua_pop(L, 1); // 弹错误
			}
		}
		lua_pushboolean(L, 1);
		return 1;
	}

	// 注册 module-level 函数
	static const struct luaL_Reg debug_module_funcs[] = {
		{ "flush_logs", l_flush_logs },
		{ "push_error", l_push_error },
		{ NULL, NULL }
	};

	int luaopen_debugC(lua_State* L) {
		// 1. 新建模块表
		lua_newtable(L);
		// 2. 注册 module function
		luaL_register(L, NULL, debug_module_funcs);
		return 1;
	}
}

void log_c(const std::string& msg) {
	log_c(msg.c_str());
}

void debug_log_c(const std::string& msg) {
	debug_log_c(msg.c_str());
}