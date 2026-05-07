// pathDB.cpp
#include <vector>
#include <unordered_map>
#include <stdexcept>
#include <cmath>
#include "lua.hpp"
#include "kra_common.hpp"

// 辅助函数 — 从 Lua stack 上的 userdata 获取内部 std::vector<Point>*
static std::vector<Point>* getVectorPoint_ptr(lua_State* L, int index) {
	std::vector<Point>* ptr = (std::vector<Point>*)lua_touserdata(L, index);
	return ptr;
}

static std::vector<std::vector<Point>**>* getPaths_ptr(lua_State* L, int index) {
	auto ptr = (std::vector<std::vector<Point>**>*)lua_touserdata(L, index);
	return ptr;
}

// 从 Lua table { { x = number, y = number }, ... }，创建 vector<Point>，返回 light userdata
static int l_new_vector_point(lua_State* L) {
	size_t ln = lua_objlen(L, 1);
	std::vector<Point>* vec = new std::vector<Point>();
	vec->reserve(ln);
	for (size_t i = 1; i <= ln; ++i) {
		lua_rawgeti(L, 1, i);
		lua_getfield(L, -1, "x");
		lua_getfield(L, -2, "y");
		double x = lua_tonumber(L, -2);
		double y = lua_tonumber(L, -1);
		vec->push_back(Point{x, y});
		lua_pop(L, 3);
	}
	lua_pushlightuserdata(L, vec);
	return 1;
}

// 接受三个 std::vector<Point>*，返回 std::vector<Point>**（数组）作为 light userdata
static int l_new_path(lua_State* L) {
	std::vector<Point>** arr = new std::vector<Point>*[3];
	std::vector<Point>* v1 = (std::vector<Point>*)lua_touserdata(L, 1);
	std::vector<Point>* v2 = (std::vector<Point>*)lua_touserdata(L, 2);
	std::vector<Point>* v3 = (std::vector<Point>*)lua_touserdata(L, 3);
	arr[0] = v1;
	arr[1] = v2;
	arr[2] = v3;
	lua_pushlightuserdata(L, arr);
	return 1;
}

// 创建一个 std::vector<std::vector<Point>**>*
static int l_new_paths(lua_State* L) {
	auto p = new std::vector<std::vector<Point>**>();
	lua_pushlightuserdata(L, p);
	return 1;
}

// 从 Lua table { number, ... }，创建 vector<lua_Integer>，返回 light userdata
inline static int l_new_path_start_node(lua_State* L) {
	size_t ln = lua_objlen(L, 1);
	auto ptr = new std::vector<lua_Integer>();
	ptr->reserve(ln);
	for (size_t i = 1; i <= ln; ++i) {
		lua_rawgeti(L, 1, i);
		lua_Integer ni = lua_tointeger(L, -1) - 1;
		ptr->push_back(ni);
		lua_pop(L, 1);
	}
	lua_pushlightuserdata(L, ptr);
	return 1;
}

static int l_new_path_end_node(lua_State* L) {
	return l_new_path_start_node(L);
}

static int l_new_visible_path_start_node(lua_State* L) {
	return l_new_path_start_node(L);
}

static int l_new_visible_path_end_node(lua_State* L) {
	return l_new_path_start_node(L);
}

// 从 Lua table { boolean, ... }，创建 vector<bool>，返回 light userdata
static int l_new_active_paths(lua_State* L) {
	size_t ln = lua_objlen(L, 1);
	auto ptr = new std::vector<bool>();
	ptr->reserve(ln);
	for (size_t i = 1; i <= ln; ++i) {
		lua_rawgeti(L, 1, i);
		bool isActive = lua_toboolean(L, -1);
		ptr->push_back(isActive);
		lua_pop(L, 1);
	}
	lua_pushlightuserdata(L, ptr);
	return 1;
}

// 从 Lua table { { from = number, to = number, flags = number }, ... }，创建 vector<InvalidRange>，返回 light userdata
static int l_new_invalid_ranges_of_path(lua_State* L) {
	size_t ln = lua_objlen(L, 1);
	auto ptr = new std::vector<InvalidRange>();
	ptr->reserve(ln);
	for (size_t i = 1; i <= ln; ++i) {
		lua_rawgeti(L, 1, i);
		lua_getfield(L, -1, "from");
		lua_getfield(L, -2, "to");
		lua_getfield(L, -3, "flags");
		lua_Integer from = lua_tointeger(L, -3) - 1;
		lua_Integer to = lua_tointeger(L, -2) - 1;
		lua_Integer flags = lua_tointeger(L, -1);
		ptr->push_back(InvalidRange{ from, to, flags });
		lua_pop(L, 4);
	}
	lua_pushlightuserdata(L, ptr);
	return 1;
}

// 创建一个 std::vector<std::vector<InvalidRange>*>*
static int l_new_invalid_ranges(lua_State* L) {
	auto ptr = new std::vector<std::vector<InvalidRange>*>();
	lua_pushlightuserdata(L, ptr);
	return 1;
}

inline static int l_new_defend_point_node(lua_State* L) {
	std::unordered_map<lua_Integer, lua_Integer>* ptr = new std::unordered_map<lua_Integer, lua_Integer>();
	lua_pushnil(L);
	while (lua_next(L, 1) != 0) {
		// key 在 -2，value 在 -1
		lua_Integer k = lua_tointeger(L, -2) - 1;
		lua_Integer v = lua_tointeger(L, -1) - 1;
		(*ptr)[k] = v;
		lua_pop(L, 1); // 弹出 value，保留 key 用于下一次 lua_next
	}
	lua_pushlightuserdata(L, ptr);
	return 1;
}

static int l_new_path_connections(lua_State* L) {
	return l_new_defend_point_node(L);
}

static int l_new_path_db(lua_State* L) {
	PathDB* p = (PathDB*)lua_newuserdata(L, sizeof(PathDB));
	// 调用构造函数，初始化所有成员
	new (p) PathDB();
	luaL_getmetatable(L, "PathDB");
	lua_setmetatable(L, -2);
	return 1;
}

// __gc
static int l_path_db_gc(lua_State* L) {
	PathDB* p = (PathDB*)lua_touserdata(L, 1);
	auto paths = p->paths;
	if (paths) {
		for (auto arr : *paths) {
			for (size_t i = 0; i < 3; ++i) {
				std::vector<Point>* vp = arr[i];
				delete vp;
			}
			delete[] arr;
		}
		delete paths;
		p->paths = nullptr;
	}

	auto path_connections = p->path_connections;
	if (path_connections) {
		delete path_connections;
		p->path_connections = nullptr;
	}
	auto path_start_node = p->path_start_node;
	if (path_start_node) {
		delete path_start_node;
		p->path_start_node = nullptr;
	}
	auto path_end_node = p->path_end_node;
	if (path_end_node) {
		delete path_end_node;
		p->path_end_node = nullptr;
	}
	auto visible_path_start_node = p->visible_path_start_node;
	if (visible_path_start_node) {
		delete visible_path_start_node;
		p->visible_path_start_node = nullptr;
	}
	auto visible_path_end_node = p->visible_path_end_node;
	if (visible_path_end_node) {
		delete visible_path_end_node;
		p->visible_path_end_node = nullptr;
	}
	auto active_paths = p->active_paths;
	if (active_paths) {
		delete active_paths;
		p->active_paths = nullptr;
	}
	auto invalid_ranges = p->invalid_ranges;
	if (invalid_ranges) {
		for (auto inner_vec : *invalid_ranges) {
			delete inner_vec;   // 释放每个 vector<InvalidRange>*
		}
		delete invalid_ranges;
		p->invalid_ranges = nullptr;
	}
	auto defend_point_node = p->defend_point_node;
	if (defend_point_node) {
		delete defend_point_node;
		p->defend_point_node = nullptr;
	}

	return 0;
}

// 返回 vector 长度 (lua_Integer)
static int l_size_of_vector_point(lua_State* L) {
	std::vector<Point>* ptr = getVectorPoint_ptr(L, 1);
	lua_pushinteger(L, (lua_Integer)ptr->size());
	return 1;
}

static int l_size_of_paths(lua_State* L) {
	std::vector<std::vector<Point>**>* ptr = getPaths_ptr(L, 1);
	lua_pushinteger(L, (lua_Integer)ptr->size());
	return 1;
}

// 向 vector 末尾添加一个 Point(x, y)
static int l_vector_point_push(lua_State* L) {
	std::vector<Point>* ptr = getVectorPoint_ptr(L, 1);
	double x = lua_tonumber(L, 2);
	double y = lua_tonumber(L, 3);
	ptr->push_back(Point{x, y});
	return 0;
}

// 将一个 Lua 传入的 std::vector<Point>*数组 放入 vector
static int l_paths_push(lua_State* L) {
	std::vector<std::vector<Point>**>* ptr = getPaths_ptr(L, 1);
	std::vector<Point>** arr = (std::vector<Point>**)lua_touserdata(L, 2);
	ptr->push_back(arr);
	return 0;
}

static int l_invalid_ranges_of_path_push(lua_State* L) {
	auto ptr = (std::vector<InvalidRange>*)lua_touserdata(L, 1);
	lua_Integer from = lua_tointeger(L, 2) - 1;
	lua_Integer to = lua_tointeger(L, 3) - 1;
	lua_Integer flags = lua_tointeger(L, 4);
	ptr->push_back(InvalidRange{ from, to, flags });
	return 0;
}

static int l_invalid_ranges_push(lua_State* L) {
	auto ptr = (std::vector<std::vector<InvalidRange>*>*)lua_touserdata(L, 1);
	auto invalid_ranges_of_path = (std::vector<InvalidRange>*)lua_touserdata(L, 2);
	ptr->push_back(invalid_ranges_of_path);
	return 0;
}

static int l_add_invalid_range(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->invalid_ranges;
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	lua_Integer from = lua_tointeger(L, 3) - 1;
	lua_Integer to = lua_tointeger(L, 4) - 1;
	lua_Integer flags = lua_tointeger(L, 5);
	std::vector<InvalidRange>* invalid_ranges_of_path = (*ptr)[pi];
	invalid_ranges_of_path->push_back(InvalidRange{ from, to, flags });
	return 0;
}

// 在指定位置插入 Point(x, y)
static int l_vector_point_insert(lua_State* L) {
	std::vector<Point>* ptr = getVectorPoint_ptr(L, 1);
	lua_Integer pos = lua_tointeger(L, 2);
	if (pos >= 1) {
		lua_getfield(L, 3, "x");
		lua_getfield(L, 3, "y");
		double x = lua_tonumber(L, -2);
		double y = lua_tonumber(L, -1);
		lua_pop(L, 2);
		size_t idx = (size_t)(pos - 1);
		size_t sz = ptr->size();
		if (idx >= sz) {
			ptr->push_back(Point{x, y});
		} else {
			ptr->insert(ptr->begin() + idx, Point{x, y});
		}
		lua_pushboolean(L, 1);
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

static int l_paths_insert(lua_State* L) {
	std::vector<std::vector<Point>**>* ptr = getPaths_ptr(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	if (li >= 1) {
		std::vector<Point>** arr = (std::vector<Point>**)lua_touserdata(L, 3);
		size_t idx = (size_t)(li - 1);
		size_t sz = ptr->size();
		if (idx >= sz) {
			ptr->push_back(arr);
		} else {
			ptr->insert(ptr->begin() + idx, arr);
		}
		lua_pushboolean(L, 1);
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

// 修改指定位置 (1-based lua_Integer) 的 Point
static int l_vector_point_set(lua_State* L) {
	std::vector<Point>* ptr = getVectorPoint_ptr(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		lua_getfield(L, 3, "x");
		lua_getfield(L, 3, "y");
		double x = lua_tonumber(L, -2);
		double y = lua_tonumber(L, -1);
		lua_pop(L, 2);
		Point &p = (*ptr)[li - 1];
		p.x = x;
		p.y = y;
		lua_pushboolean(L, 1);
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

static int l_path_set(lua_State* L) {
	std::vector<Point>** arr = (std::vector<Point>**)lua_touserdata(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	if (li >= 1 && li <= 3) {
		std::vector<Point>* old = arr[li - 1];
		std::vector<Point>* v = (std::vector<Point>*)lua_touserdata(L, 3);
		if (old != v) {
			delete old;
			arr[li - 1] = v;
			lua_pushboolean(L, 1);
			return 1;
		}
	}
	lua_pushboolean(L, 0);
	return 1;
}

static int l_paths_set(lua_State* L) {
	std::vector<std::vector<Point>**>* ptr = getPaths_ptr(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		std::vector<Point>** old = (*ptr)[li - 1];
		std::vector<Point>** arr = (std::vector<Point>**)lua_touserdata(L, 3);
		if (old != arr) {
			for (size_t i = 0; i < 3; ++i) {
				delete old[i];
			}
			delete[] old;
			(*ptr)[li - 1] = arr;
			lua_pushboolean(L, 1);
			return 1;
		}
	}
	lua_pushboolean(L, 0);
	return 1;
}

inline static int l_path_start_node_set(lua_State* L) {
	std::vector<lua_Integer>* ptr = (std::vector<lua_Integer>*)lua_touserdata(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		(*ptr)[li - 1] = lua_tointeger(L, 3) - 1;
		lua_pushboolean(L, 1);
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

static int l_path_end_node_set(lua_State* L) {
	return l_path_start_node_set(L);
}

static int l_visible_path_start_node_set(lua_State* L) {
	return l_path_start_node_set(L);
}

static int l_visible_path_end_node_set(lua_State* L) {
	return l_path_start_node_set(L);
}

static int l_active_paths_set(lua_State* L) {
	std::vector<bool>* ptr = (std::vector<bool>*)lua_touserdata(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		(*ptr)[li - 1] = lua_toboolean(L, 3);
		lua_pushboolean(L, 1);
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

inline static int l_defend_point_node_set(lua_State* L) {
	std::unordered_map<lua_Integer, lua_Integer>* ptr = (std::unordered_map<lua_Integer, lua_Integer>*)lua_touserdata(L, 1);
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	(*ptr)[pi] = lua_tointeger(L, 3) - 1;
	return 0;
}

static int l_set_defend_point_node(lua_State* L) {
	std::unordered_map<lua_Integer, lua_Integer>* ptr = ((PathDB*)lua_touserdata(L, 1))->defend_point_node;
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	(*ptr)[pi] = lua_tointeger(L, 3) - 1;
	return 0;
}

static int l_path_connections_set(lua_State* L) {
	return l_defend_point_node_set(L);
}

static int l_set_path_connection(lua_State* L) {
	std::unordered_map<lua_Integer, lua_Integer>* ptr = ((PathDB*)lua_touserdata(L, 1))->path_connections;
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	(*ptr)[pi] = lua_tointeger(L, 3) - 1;
	return 0;
}

static int l_path_db_set_paths(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	auto new_paths = getPaths_ptr(L, 2);
	auto old_paths = ptr->paths;
	if (old_paths && old_paths != new_paths) [[unlikely]] {
		for (auto arr : *old_paths) {
			for (size_t i = 0; i < 3; ++i) {
				delete arr[i];
			}
			delete[] arr;
		}
		delete old_paths;
	}
	ptr->paths = new_paths;
	return 0;
}

static int l_path_db_set_path_start_node(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	auto new_val = (std::vector<lua_Integer>*)lua_touserdata(L, 2);
	auto old_val = ptr->path_start_node;
	if (old_val && old_val != new_val) [[unlikely]] {
		delete old_val;
	}
	ptr->path_start_node = new_val;
	return 0;
}

static int l_path_db_set_path_end_node(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	auto new_val = (std::vector<lua_Integer>*)lua_touserdata(L, 2);
	auto old_val = ptr->path_end_node;
	if (old_val && old_val != new_val) [[unlikely]] {
		delete old_val;
	}
	ptr->path_end_node = new_val;
	return 0;
}

static int l_path_db_set_visible_path_start_node(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	auto new_val = (std::vector<lua_Integer>*)lua_touserdata(L, 2);
	auto old_val = ptr->visible_path_start_node;
	if (old_val && old_val != new_val) [[unlikely]] {
		delete old_val;
	}
	ptr->visible_path_start_node = new_val;
	return 0;
}

static int l_path_db_set_visible_path_end_node(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	auto new_val = (std::vector<lua_Integer>*)lua_touserdata(L, 2);
	auto old_val = ptr->visible_path_end_node;
	if (old_val && old_val != new_val) [[unlikely]] {
		delete old_val;
	}
	ptr->visible_path_end_node = new_val;
	return 0;
}

static int l_path_db_set_active_paths(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	std::vector<bool>* new_active_paths = (std::vector<bool>*)lua_touserdata(L, 2);
	std::vector<bool>* old_active_paths = ptr->active_paths;
	if (old_active_paths && old_active_paths != new_active_paths) [[unlikely]] {
		delete old_active_paths;
	}
	ptr->active_paths = new_active_paths;
	return 0;
}

static int l_path_db_set_invalid_ranges(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	auto new_val = (std::vector<std::vector<InvalidRange>*>*)lua_touserdata(L, 2);
	auto old_val = ptr->invalid_ranges;
	if (old_val && old_val != new_val) [[unlikely]] {
		for (auto inner : *old_val) {
			delete inner;
		}
		delete old_val;
	}
	ptr->invalid_ranges = new_val;
	return 0;
}

static int l_path_db_set_defend_point_node(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	auto new_val = (std::unordered_map<lua_Integer, lua_Integer>*)lua_touserdata(L, 2);
	auto old_val = ptr->defend_point_node;
	if (old_val && old_val != new_val) [[unlikely]] {
		delete old_val;
	}
	ptr->defend_point_node = new_val;
	return 0;
}

static int l_path_db_set_path_connections(lua_State* L) {
	PathDB* ptr = (PathDB*)lua_touserdata(L, 1);
	auto new_val = (std::unordered_map<lua_Integer, lua_Integer>*)lua_touserdata(L, 2);
	auto old_val = ptr->path_connections;
	if (old_val && old_val != new_val) [[unlikely]] {
		delete old_val;
	}
	ptr->path_connections = new_val;
	return 0;
}

// 删除指定位置的 Point
static int l_vector_point_remove(lua_State* L) {
	std::vector<Point>* ptr = getVectorPoint_ptr(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		ptr->erase(ptr->begin() + (li - 1));
		lua_pushboolean(L, 1);
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

static int l_paths_remove(lua_State* L) {
	std::vector<std::vector<Point>**>* ptr = getPaths_ptr(L, 1);
	lua_Integer idx = lua_tointeger(L, 2) - 1;
	size_t sz = ptr->size();
	if (idx >= 0 && idx < sz) {
		std::vector<Point>** arr = (*ptr)[idx];
		for (size_t i = 0; i < 3; ++i) {
			std::vector<Point>* vp = arr[i];
			delete vp;
		}
		delete[] arr;
		ptr->erase(ptr->begin() + idx);
		lua_pushboolean(L, 1);
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

static int l_remove_invalid_range(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->invalid_ranges;
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	lua_Integer from = lua_tointeger(L, 3) - 1;
	lua_Integer to = lua_tointeger(L, 4) - 1;
	std::vector<InvalidRange>* invalid_ranges_of_path = (*ptr)[pi];
	size_t sz = invalid_ranges_of_path->size();
	bool isRemoved = false;
	for (int i = sz - 1; i >= 0; --i) {
		auto& invalid_range = (*invalid_ranges_of_path)[i];
		if (invalid_range.from == from && invalid_range.to == to) {
			invalid_ranges_of_path->erase(invalid_ranges_of_path->begin() + i);
			isRemoved = true;
			break;
		}
	}
	if (isRemoved) {
		lua_pushboolean(L, 1);
	} else {
		lua_pushboolean(L, 0);
	}
	return 1;
}

// 获取指定位置 (1-based lua_Integer) 的 Point，返回 { x = number, y = number }
static int l_vector_point_get(lua_State* L) {
	std::vector<Point>* ptr = getVectorPoint_ptr(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		Point &p = (*ptr)[li - 1];
		// 创建新的 Lua table
		lua_newtable(L);
		// 设置 field "x"
		lua_pushnumber(L, p.x);
		lua_setfield(L, -2, "x");
		// 设置 field "y"
		lua_pushnumber(L, p.y);
		lua_setfield(L, -2, "y");
		// 返回这张 table
		return 1;
	} else {
		// 超出范围 — 返回 nil
		lua_pushnil(L);
		return 1;
	}
}

static int l_path_get(lua_State* L) {
	std::vector<Point>** arr = (std::vector<Point>**)lua_touserdata(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	if (li >= 1 && li <= 3) {
		lua_pushlightuserdata(L, arr[li - 1]);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_paths_get(lua_State* L) {
	std::vector<std::vector<Point>**>* ptr = getPaths_ptr(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		std::vector<Point>** arr = (*ptr)[li - 1];
		lua_pushlightuserdata(L, arr);
	} else {
		// 超出范围 — 返回 nil
		lua_pushnil(L);
	}
	return 1;
}

inline static int l_path_start_node_get(lua_State* L) {
	auto ptr = (std::vector<lua_Integer>*)lua_touserdata(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		auto ni = (*ptr)[li - 1] + 1;
		lua_pushinteger(L, ni);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_end_node_get(lua_State* L) {
	return l_path_start_node_get(L);
}

static int l_visible_path_start_node_get(lua_State* L) {
	return l_path_start_node_get(L);
}

static int l_visible_path_end_node_get(lua_State* L) {
	return l_path_start_node_get(L);
}

static int l_active_paths_get(lua_State* L) {
	auto ptr = (std::vector<bool>*)lua_touserdata(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		auto isActive = (*ptr)[li - 1];
		lua_pushboolean(L, isActive);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_invalid_ranges_get(lua_State* L) {
	auto ptr = (std::vector<std::vector<InvalidRange>*>*)lua_touserdata(L, 1);
	lua_Integer li = lua_tointeger(L, 2);
	size_t sz = ptr->size();
	if (li >= 1 && li <= sz) {
		std::vector<InvalidRange>* invalid_ranges_of_path = (*ptr)[li - 1];
		lua_pushlightuserdata(L, invalid_ranges_of_path);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_defend_point_node_get(lua_State* L) {
	auto ptr = (std::unordered_map<lua_Integer, lua_Integer>*)lua_touserdata(L, 1);
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	lua_Integer ni = (*ptr)[pi] + 1;
	lua_pushinteger(L, ni);
	return 1;
}

static int l_get_defend_point_node(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->defend_point_node;
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	lua_Integer ni = (*ptr)[pi] + 1;
	lua_pushinteger(L, ni);
	return 1;
}

static int l_path_connections_get(lua_State* L) {
	auto ptr = (std::unordered_map<lua_Integer, lua_Integer>*)lua_touserdata(L, 1);
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	lua_Integer ci = (*ptr)[pi] + 1;
	lua_pushinteger(L, ci);
	return 1;
}

static int l_get_path_connection(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->path_connections;
	lua_Integer pi = lua_tointeger(L, 2) - 1;
	lua_Integer ci = (*ptr)[pi] + 1;
	lua_pushinteger(L, ci);
	return 1;
}

static int l_path_db_get_paths(lua_State* L) {
	auto paths = ((PathDB*)lua_touserdata(L, 1))->paths;
	if (paths) {
		lua_pushlightuserdata(L, paths);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_db_get_path_start_node(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->path_start_node;
	if (ptr) {
		lua_pushlightuserdata(L, ptr);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_db_get_path_end_node(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->path_end_node;
	if (ptr) {
		lua_pushlightuserdata(L, ptr);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_db_get_visible_path_start_node(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->visible_path_start_node;
	if (ptr) {
		lua_pushlightuserdata(L, ptr);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_db_get_visible_path_end_node(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->visible_path_end_node;
	if (ptr) {
		lua_pushlightuserdata(L, ptr);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_db_get_active_paths(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->active_paths;
	if (ptr) {
		lua_pushlightuserdata(L, ptr);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_db_get_invalid_ranges(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->invalid_ranges;
	if (ptr) {
		lua_pushlightuserdata(L, ptr);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_db_get_defend_point_node(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->defend_point_node;
	if (ptr) {
		lua_pushlightuserdata(L, ptr);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

static int l_path_db_get_path_connections(lua_State* L) {
	auto ptr = ((PathDB*)lua_touserdata(L, 1))->path_connections;
	if (ptr) {
		lua_pushlightuserdata(L, ptr);
	} else {
		lua_pushnil(L);
	}
	return 1;
}

// 注册 metatable
static const struct luaL_Reg PathDB_methods[] = {
	{ "path_db_set_paths", l_path_db_set_paths },
	{ "path_db_get_paths", l_path_db_get_paths },
	{ "path_db_set_path_start_node", l_path_db_set_path_start_node },
	{ "path_db_get_path_start_node", l_path_db_get_path_start_node },
	{ "path_db_set_path_end_node", l_path_db_set_path_end_node },
	{ "path_db_get_path_end_node", l_path_db_get_path_end_node },
	{ "path_db_set_visible_path_start_node", l_path_db_set_visible_path_start_node },
	{ "path_db_get_visible_path_start_node", l_path_db_get_visible_path_start_node },
	{ "path_db_set_visible_path_end_node", l_path_db_set_visible_path_end_node },
	{ "path_db_get_visible_path_end_node", l_path_db_get_visible_path_end_node },
	{ "path_db_set_active_paths", l_path_db_set_active_paths },
	{ "path_db_get_active_paths", l_path_db_get_active_paths },
	{ "add_invalid_range", l_add_invalid_range },
	{ "remove_invalid_range", l_remove_invalid_range },
	{ "path_db_set_invalid_ranges", l_path_db_set_invalid_ranges },
	{ "path_db_get_invalid_ranges", l_path_db_get_invalid_ranges },
	{ "set_defend_point_node", l_set_defend_point_node },
	{ "get_defend_point_node", l_get_defend_point_node },
	{ "path_db_set_defend_point_node", l_path_db_set_defend_point_node },
	{ "path_db_get_defend_point_node", l_path_db_get_defend_point_node },
	{ "set_path_connection", l_set_path_connection },
	{ "get_path_connection", l_get_path_connection },
	{ "path_db_set_path_connections", l_path_db_set_path_connections },
	{ "path_db_get_path_connections", l_path_db_get_path_connections },
	{ "__gc", l_path_db_gc },
	{ NULL, NULL }
};

// 注册 module-level 函数
static const struct luaL_Reg pathDB_module_funcs[] = {
	{ "new_vector_point", l_new_vector_point },
	{ "size_of_vector_point", l_size_of_vector_point },
	{ "vector_point_push",    l_vector_point_push },
	{ "vector_point_insert",  l_vector_point_insert },
	{ "vector_point_set",     l_vector_point_set },
	{ "vector_point_remove",  l_vector_point_remove },
	{ "vector_point_get",     l_vector_point_get },
	{ "new_path", l_new_path },
	{ "path_set", l_path_set },
	{ "path_get", l_path_get },
	{ "new_paths", l_new_paths },
	{ "size_of_paths", l_size_of_paths },
	{ "paths_push", l_paths_push },
	{ "paths_insert", l_paths_insert },
	{ "paths_set", l_paths_set },
	{ "paths_remove", l_paths_remove },
	{ "paths_get", l_paths_get },
	{ "path_db_set_paths", l_path_db_set_paths },
	{ "path_db_get_paths", l_path_db_get_paths },
	{ "new_path_start_node", l_new_path_start_node },
	{ "path_start_node_set", l_path_start_node_set },
	{ "path_start_node_get", l_path_start_node_get },
	{ "path_db_set_path_start_node", l_path_db_set_path_start_node },
	{ "path_db_get_path_start_node", l_path_db_get_path_start_node },
	{ "new_path_end_node", l_new_path_end_node },
	{ "path_end_node_set", l_path_end_node_set },
	{ "path_end_node_get", l_path_end_node_get },
	{ "path_db_set_path_end_node", l_path_db_set_path_end_node },
	{ "path_db_get_path_end_node", l_path_db_get_path_end_node },
	{ "new_visible_path_start_node", l_new_visible_path_start_node },
	{ "visible_path_start_node_set", l_visible_path_start_node_set },
	{ "visible_path_start_node_get", l_visible_path_start_node_get },
	{ "path_db_set_visible_path_start_node", l_path_db_set_visible_path_start_node },
	{ "path_db_get_visible_path_start_node", l_path_db_get_visible_path_start_node },
	{ "new_visible_path_end_node", l_new_visible_path_end_node },
	{ "visible_path_end_node_set", l_visible_path_end_node_set },
	{ "visible_path_end_node_get", l_visible_path_end_node_get },
	{ "path_db_set_visible_path_end_node", l_path_db_set_visible_path_end_node },
	{ "path_db_get_visible_path_end_node", l_path_db_get_visible_path_end_node },
	{ "new_active_paths", l_new_active_paths },
	{ "active_paths_set", l_active_paths_set },
	{ "active_paths_get", l_active_paths_get },
	{ "path_db_set_active_paths", l_path_db_set_active_paths },
	{ "path_db_get_active_paths", l_path_db_get_active_paths },
	{ "new_invalid_ranges_of_path", l_new_invalid_ranges_of_path },
	{ "new_invalid_ranges", l_new_invalid_ranges },
	{ "invalid_ranges_push", l_invalid_ranges_push },
	{ "invalid_ranges_of_path_push", l_invalid_ranges_of_path_push },
	{ "add_invalid_range", l_add_invalid_range },
	{ "remove_invalid_range", l_remove_invalid_range },
	{ "invalid_ranges_get", l_invalid_ranges_get },
	{ "path_db_set_invalid_ranges", l_path_db_set_invalid_ranges },
	{ "path_db_get_invalid_ranges", l_path_db_get_invalid_ranges },
	{ "new_defend_point_node", l_new_defend_point_node },
	{ "defend_point_node_set", l_defend_point_node_set },
	{ "defend_point_node_get", l_defend_point_node_get },
	{ "set_defend_point_node", l_set_defend_point_node },
	{ "get_defend_point_node", l_get_defend_point_node },
	{ "path_db_set_defend_point_node", l_path_db_set_defend_point_node },
	{ "path_db_get_defend_point_node", l_path_db_get_defend_point_node },
	{ "new_path_connections", l_new_path_connections },
	{ "path_connections_set", l_path_connections_set },
	{ "path_connections_get", l_path_connections_get },
	{ "set_path_connection", l_set_path_connection },
	{ "get_path_connection", l_get_path_connection },
	{ "path_db_set_path_connections", l_path_db_set_path_connections },
	{ "path_db_get_path_connections", l_path_db_get_path_connections },

	{ "new_path_db", l_new_path_db },
	{ NULL, NULL }
};

extern "C" int luaopen_pathDB(lua_State* L) {
	// 1. 新建模块表
	lua_newtable(L);
	// 2. 注册 module function
	luaL_register(L, NULL, pathDB_module_funcs);
	// 3. 注册 metatable
	luaL_newmetatable(L, "PathDB");
	luaL_register(L, NULL, PathDB_methods);
	// 设置 __index
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	// 弹出 metatable 本身
	lua_pop(L, 1);
	return 1;
}
