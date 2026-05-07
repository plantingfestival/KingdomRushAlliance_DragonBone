// sso.cpp
#include <vector>
#include <unordered_map>
#include <stdexcept>
#include <cmath>
#include "lua.hpp"
#include "kra_common.hpp"

// 从 Lua table { x = number, y = number, ... }，创建 GridsOfTargets，返回 userdata
static int l_new_grids_of_targets(lua_State* L) {
	double x = 0.0, y = 0.0, w = 0.0, h = 0.0;
	lua_Integer min_ix = 0, max_ix = 0, min_iy = 0, max_iy = 0, step = 128;
	// 辅助宏：从表中读取 double 字段
#define GET_NUMBER_FIELD(field, target) \
	do { \
		lua_getfield(L, 1, field); \
		target = lua_tonumber(L, -1); \
		lua_pop(L, 1); \
	} while(0)

	// 辅助宏：从表中读取 integer 字段
#define GET_INTEGER_FIELD(field, target) \
	do { \
		lua_getfield(L, 1, field); \
		target = lua_tointeger(L, -1); \
		lua_pop(L, 1); \
	} while(0)

	GET_NUMBER_FIELD("x", x);
	GET_NUMBER_FIELD("y", y);
	GET_NUMBER_FIELD("w", w);
	GET_NUMBER_FIELD("h", h);
	GET_INTEGER_FIELD("min_ix", min_ix);
	GET_INTEGER_FIELD("max_ix", max_ix);
	GET_INTEGER_FIELD("min_iy", min_iy);
	GET_INTEGER_FIELD("max_iy", max_iy);
	GET_INTEGER_FIELD("step", step);

#undef GET_NUMBER_FIELD
#undef GET_INTEGER_FIELD

	GridsOfTargets* p = (GridsOfTargets*)lua_newuserdata(L, sizeof(GridsOfTargets));
	// 调用构造函数，初始化所有成员
	new (p) GridsOfTargets(x, y, w, h, min_ix, max_ix, min_iy, max_iy, step);
	luaL_getmetatable(L, "GridsOfTargets");
	lua_setmetatable(L, -2);
	return 1;
}

// __gc
static int l_grids_of_targets_gc(lua_State* L) {
	GridsOfTargets* p = (GridsOfTargets*)lua_touserdata(L, 1);
	// 调用析构函数
	p->~GridsOfTargets();
	return 0;
}

// 注册 module-level 函数
static const struct luaL_Reg sso_module_funcs[] = {
	{ "new_grids_of_targets", l_new_grids_of_targets },
	{ NULL, NULL }
};

extern "C" int luaopen_sso(lua_State* L) {
	// 创建一个元表，并命名为 "GridsOfTargets"，供后续使用
	luaL_newmetatable(L, "GridsOfTargets");
	// 设置 __gc 元方法
	lua_pushcfunction(L, l_grids_of_targets_gc);
	lua_setfield(L, -2, "__gc");
	// 弹出 metatable GridsOfTargets
	lua_pop(L, 1);
	// 1. 新建模块表
	lua_newtable(L);
	// 2. 注册 module function
	luaL_register(L, NULL, sso_module_funcs);
	return 1;
}
