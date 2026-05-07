/*
 * myExtension.c - Lua 5.1 ByteData module for LÖVE 0.10.2
 * Default: Little Endian
 * Cross-platform: Windows / Android
 */

#include <lua.h>
#include <lauxlib.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include "debugC.h"

#ifdef _WIN32
	#define MY_EXTENSION_EXPORT __declspec(dllexport)
#else
	#define MY_EXTENSION_EXPORT
#endif

typedef struct {
	uint8_t* buffer;
	uint32_t size;
} ByteData;

static inline void read_size_checked(lua_State* L, int idx, uint32_t *out_size) {
	lua_Integer s = luaL_checkinteger(L, idx);
	if (s < 0) luaL_error(L, "size must be non-negative");
	if ((uint64_t)s > UINT32_MAX) luaL_error(L, "size too large");
	*out_size = (uint32_t)s;
}

static inline void byte_check_range(lua_State* L, ByteData** udata, uint32_t offset, uint32_t len) {
	if (offset > (*udata)->size || (*udata)->size - offset < len)
		luaL_error(L, "offset out of range");
}
#define BYTE_CHECK_RANGE(offset, len) byte_check_range(L, udata, (offset), (len))

// ---------------- Constructor ----------------
static int l_newByteData(lua_State* L) {
	int arg = lua_type(L, 1);
	uint32_t size = 0;
	ByteData* b = NULL;

	if (arg == LUA_TNUMBER) {
		read_size_checked(L, 1, &size);
		b = (ByteData*)malloc(sizeof(ByteData) + (size_t)size);
		if (!b) return luaL_error(L, "Memory allocation failed for ByteData");
		b->buffer = (uint8_t*)(b + 1);
		if (size) memset(b->buffer, 0, size);
		b->size = size;
	}
	else if (arg == LUA_TSTRING) {
		size = (uint32_t)lua_objlen(L, 1);
		b = (ByteData*)malloc(sizeof(ByteData) + (size_t)size);
		if (!b) return luaL_error(L, "Memory allocation failed for ByteData");
		b->buffer = (uint8_t*)(b + 1);
		if (size) memcpy(b->buffer, lua_tostring(L, 1), size);
		b->size = size;
	}
	else {
		return luaL_error(L, "newByteData expects number or string");
	}

	ByteData** udata = (ByteData**)lua_newuserdata(L, sizeof(ByteData*));
	*udata = b;
	luaL_getmetatable(L, "ByteData");
	lua_setmetatable(L, -2);
	return 1;
}

// ---------------- GC ----------------
static int l_ByteData_gc(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	if (*udata) {
		free(*udata);
		*udata = NULL;
	}
	return 0;
}

// ---------------- Basic Methods ----------------
static int l_getSize(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	lua_pushinteger(L, (*udata)->size);
	return 1;
}

static int l_getString(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	lua_Integer off_i = luaL_optinteger(L, 2, 0);
	if (off_i < 0) return luaL_error(L, "offset must be non-negative");
	if ((uint64_t)off_i > UINT32_MAX) return luaL_error(L, "offset too large");
	uint32_t offset = (uint32_t)off_i;
	uint32_t len = (uint32_t)luaL_optinteger(L, 3, (lua_Integer)((*udata)->size - offset));
	if (offset + len > (*udata)->size) return luaL_error(L, "getString out of range");
	lua_pushlstring(L, (const char*)(*udata)->buffer + offset, len);
	return 1;
}

// ---------------- Int / UInt Read/Write ----------------
// Int8 / UInt8
static int l_getInt8(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 1);
	lua_pushinteger(L, (int8_t)(*udata)->buffer[offset]);
	return 1;
}
static int l_setInt8(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 1);
	(*udata)->buffer[offset] = (uint8_t)luaL_checkinteger(L, 3);
	return 0;
}

// UInt8
static int l_getUInt8(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 1);
	lua_pushinteger(L, (uint8_t)(*udata)->buffer[offset]);
	return 1;
}
static int l_setUInt8(lua_State* L) { return l_setInt8(L); }

// Int16 / UInt16
static int l_getInt16(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 2);
	uint16_t val;
	memcpy(&val, (*udata)->buffer + offset, 2);
	lua_pushinteger(L, (int16_t)val);
	return 1;
}

static int l_setInt16(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	int16_t val = (int16_t)luaL_checkinteger(L, 3);
	BYTE_CHECK_RANGE(offset, 2);
	memcpy((*udata)->buffer + offset, &val, 2);
	return 0;
}

// UInt16
static int l_getUInt16(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 2);
	uint16_t val;
	memcpy(&val, (*udata)->buffer + offset, 2);
	lua_pushinteger(L, (lua_Integer)val);
	return 1;
}

static int l_setUInt16(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	uint16_t val = (uint16_t)luaL_checkinteger(L, 3);
	BYTE_CHECK_RANGE(offset, 2);
	memcpy((*udata)->buffer + offset, &val, 2);
	return 0;
}

// Int32 / UInt32
static int l_getInt32(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 4);
	uint32_t val;
	memcpy(&val, (*udata)->buffer + offset, 4);
	lua_pushinteger(L, (int32_t)val);
	return 1;
}

static int l_setInt32(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	int32_t val = (int32_t)luaL_checkinteger(L, 3);
	BYTE_CHECK_RANGE(offset, 4);
	memcpy((*udata)->buffer + offset, &val, 4);
	return 0;
}

// UInt32
static int l_getUInt32(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 4);
	uint32_t val;
	memcpy(&val, (*udata)->buffer + offset, 4);
	lua_pushinteger(L, (lua_Integer)val);
	return 1;
}

static int l_setUInt32(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	uint32_t val = (uint32_t)luaL_checkinteger(L, 3);
	BYTE_CHECK_RANGE(offset, 4);
	memcpy((*udata)->buffer + offset, &val, 4);
	return 0;
}

// Float / Double
static int l_getFloat(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 4);
	float val;
	memcpy(&val, (*udata)->buffer + offset, 4);
	lua_pushnumber(L, (lua_Number)val);
	return 1;
}

static int l_setFloat(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	float val = (float)luaL_checknumber(L, 3);
	BYTE_CHECK_RANGE(offset, 4);
	memcpy((*udata)->buffer + offset, &val, 4);
	return 0;
}

static int l_getDouble(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	BYTE_CHECK_RANGE(offset, 8);
	double val;
	memcpy(&val, (*udata)->buffer + offset, 8);
	lua_pushnumber(L, (lua_Number)val);
	return 1;
}

static int l_setDouble(lua_State* L) {
	ByteData** udata = (ByteData**)luaL_checkudata(L, 1, "ByteData");
	uint32_t offset = (uint32_t)luaL_checkinteger(L, 2);
	double val = (double)luaL_checknumber(L, 3);
	BYTE_CHECK_RANGE(offset, 8);
	memcpy((*udata)->buffer + offset, &val, 8);
	return 0;
}

// ---------------- Metatable ----------------
static const struct luaL_Reg ByteData_methods[] = {
	{"getSize", l_getSize},
	{"getString", l_getString},
	{"getInt8", l_getInt8}, {"setInt8", l_setInt8},
	{"getUInt8", l_getUInt8}, {"setUInt8", l_setUInt8},
	{"getInt16", l_getInt16}, {"setInt16", l_setInt16},
	{"getUInt16", l_getUInt16}, {"setUInt16", l_setUInt16},
	{"getInt32", l_getInt32}, {"setInt32", l_setInt32},
	{"getUInt32", l_getUInt32}, {"setUInt32", l_setUInt32},
	{"getFloat", l_getFloat}, {"setFloat", l_setFloat},
	{"getDouble", l_getDouble}, {"setDouble", l_setDouble},
	{NULL, NULL}
};

// ---------------- rapidComputation Functions ----------------
void prs(double x, double y, double psx, double psy, double pr, double* rsx, double* rsy) {
	double cp = cos(pr);
	double sp = sin(pr);
	double sx = x * psx;
	double sy = y * psy;
	*rsx = sx * cp - sy * sp;
	*rsy = sx * sp + sy * cp;
}

static int l_prs(lua_State* L) {
	double x = luaL_checknumber(L, 1);
	double y = luaL_checknumber(L, 2);
	double psx = luaL_checknumber(L, 3);
	double psy = luaL_checknumber(L, 4);
	double pr = luaL_checknumber(L, 5);
	double rsx, rsy;
	prs(x, y, psx, psy, pr, &rsx, &rsy);
	lua_pushnumber(L, rsx);
	lua_pushnumber(L, rsy);
	return 2;
}

static int l_integerDivision(lua_State *L) {
	lua_Number a = lua_tonumber(L, 1);
	lua_Number b = lua_tonumber(L, 2);
	// 检查除数是否为0
	if (b == 0) {
		luaL_error(L, "division by zero");
		return 0; // luaL_error 不会返回，这里只是为了语法正确
	}
	lua_Integer result = (lua_Integer)(a / b);
	lua_pushinteger(L, result);
	return 1;
}

extern int luaopen_pathDB(lua_State* L);
extern int luaopen_sso(lua_State* L);

// ---------------- Entry ----------------
MY_EXTENSION_EXPORT int luaopen_myExtension(lua_State* L) {
	// 创建 ByteData 元表
	luaL_newmetatable(L, "ByteData");
	luaL_register(L, NULL, ByteData_methods);
	lua_pushcfunction(L, l_ByteData_gc);
	lua_setfield(L, -2, "__gc");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	lua_pop(L, 1);
	// 创建模块表 myExtension
	lua_newtable(L);
	// 嵌套 byteData
	lua_newtable(L);
	lua_pushcfunction(L, l_newByteData);
	lua_setfield(L, -2, "newByteData");
	lua_setfield(L, -2, "byteData");
	// 嵌套 rapidComputation
	lua_newtable(L);
	// 将 prs 函数添加到 rapidComputation 表
	lua_pushcfunction(L, l_prs);
	lua_setfield(L, -2, "prs");
	// 将 integerDivision 函数添加到 rapidComputation 表
	lua_pushcfunction(L, l_integerDivision);
	lua_setfield(L, -2, "integerDivision");
	// 将 rapidComputation 表设置为 myExtension 的字段
	lua_setfield(L, -2, "rapidComputation");
	// 调用 debugC.cpp 的 luaopen_debugC 函数
	luaopen_debugC(L);
	// 将 debug 表设置为 myExtension 的字段
	lua_setfield(L, -2, "debug");
	// 调用 pathDB.cpp 的 luaopen_pathDB 函数
	luaopen_pathDB(L);
	// 将 pathDB 表设置为 myExtension 的字段
	lua_setfield(L, -2, "pathDB");
	// 调用 sso.cpp 的 luaopen_sso 函数
	luaopen_sso(L);
	// 将 sso 表设置为 myExtension 的字段
	lua_setfield(L, -2, "sso");
	return 1;
}