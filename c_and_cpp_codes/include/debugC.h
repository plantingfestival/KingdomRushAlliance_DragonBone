// debugC.h
#pragma once

#ifdef _WIN32
	#ifdef DEBUG_C
		#define DEBUG_C_EXPORT __declspec(dllexport)
	#else
		#define DEBUG_C_EXPORT __declspec(dllimport)
	#endif
#else
	#define DEBUG_C_EXPORT
#endif

#ifdef __cplusplus
#include <lua.hpp>
#include <string>
DEBUG_C_EXPORT void log_c(const std::string& msg);
DEBUG_C_EXPORT void debug_log_c(const std::string& msg);
extern "C" {
#else
#include <lua.h>
#endif

DEBUG_C_EXPORT void log_c(const char* logMessage);
DEBUG_C_EXPORT void debug_log_c(const char* logMessage);
DEBUG_C_EXPORT void record_error(const char* errorMessage);
DEBUG_C_EXPORT int  luaopen_debugC(lua_State* L);

#ifdef __cplusplus
}
#endif