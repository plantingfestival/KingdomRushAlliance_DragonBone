// kra_common.hpp
#pragma once
#include <cmath>
#include <cstdint>
#include <vector>
#include <unordered_map>
#include <tuple>
#include <utility>
#include <random>
#include <limits>
#include <algorithm>
#include <stdexcept>
#include <lua.hpp>
#include "kra_common.h"
#include "debugC.h"

struct PathDB;
struct GridsOfTargets;

namespace search_type {
	inline constexpr int8_t nearest = 1;
	inline constexpr int8_t farthest = 2;
	inline constexpr int8_t random = 3;
	inline constexpr int8_t max_health = 4;
	inline constexpr int8_t min_health = 5;
	inline constexpr int8_t close_to_exit = 6;      // 最接近终点
	inline constexpr int8_t far_from_exit = 7;      // 最远离终点
	inline constexpr int8_t find_max_crowd = 8;     // 最密集
	inline constexpr int8_t max_initial_health = 9; // 最大生命值最多
	inline constexpr int8_t min_initial_health = 10;// 最大生命值最少
	inline constexpr int8_t custom = 32;            // 自定义
}

namespace math {
	inline thread_local std::mt19937 gen(std::random_device{}());

	// 返回 [0, 1) 之间的均匀浮点数
	inline double random() {
		static thread_local std::uniform_real_distribution<double> dist0_1(0.0, 1.0);
		return dist0_1(gen);
	}

	// 返回 [1, n] 之间的整数（n > 1）
	inline uint64_t random(uint64_t n) {
		if (n <= 1) [[unlikely]] return n;
		std::uniform_int_distribution<uint64_t> dist1_n(1, n);
		return dist1_n(gen);
	}

	// 返回 [m, n] 之间的整数
	inline int64_t random(int64_t m, int64_t n) {
		if (m > n) [[unlikely]] std::swap(m, n);
		std::uniform_int_distribution<int64_t> dist_m_n(m, n);
		return dist_m_n(gen);
	}
}

namespace vector {
	inline double len(double x, double y) {
		return std::sqrt(x * x + y * y);
	}

	inline double dist(double x1, double y1, double x2, double y2) {
		return len(x1 - x2, y1 - y2);
	}

	inline double len2(double x, double y) {
		return x * x + y * y;
	}

	inline double dist2(double x1, double y1, double x2, double y2) {
		return len2(x1 - x2, y1 - y2);
	}
}

namespace utils {
    // 先声明函数
	inline bool is_inside_ellipse(const Point& p, const Point& center, double radius, double aspect = 0.7);
    inline double clamp(double min, double max, double v);
	inline void find_enemies_in_range(GridsOfTargets* grids, PathDB* pathdb, Point* tmp_points, 
		double origin_x, double origin_y, double min_range, double max_range, int32_t flags, int32_t bans, 
		const char** allowed_templates, uint32_t allowed_templates_len, const char** excluded_templates, uint32_t excluded_templates_len, 
		std::vector<EntityInfo*>& out);
	inline void find_enemy_crowd(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, SearchResult* result);
	inline void find_enemies(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, 
		std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result);
	inline void find_soldiers_in_range(GridsOfTargets* grids, PathDB* pathdb, Point* tmp_points, 
		double origin_x, double origin_y, double min_range, double max_range, int32_t flags, int32_t bans, 
		const char** allowed_templates, uint32_t allowed_templates_len, const char** excluded_templates, uint32_t excluded_templates_len, 
		std::vector<EntityInfo*>& out);
	inline void find_soldier_crowd(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, SearchResult* result);
	inline void find_soldiers(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, 
		std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result);
	inline void find_towers_in_range(const SearchOrder* order, GridsOfTargets* grids, Point* tmp_points, 
		std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result);
	inline void find_targets_in_range(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, 
									std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result);
	inline void find_entities_in_range(const SearchOrder* order, GridsOfTargets* grids, Point* tmp_points, 
									std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result);
}

struct PathDB {
	std::vector<std::vector<Point>**>* paths = nullptr;
	std::unordered_map<lua_Integer, lua_Integer>* path_connections = nullptr;
	std::vector<lua_Integer>* path_start_node = nullptr;
	std::vector<lua_Integer>* path_end_node = nullptr;
	std::vector<lua_Integer>* visible_path_start_node = nullptr;
	std::vector<lua_Integer>* visible_path_end_node = nullptr;
	std::vector<bool>* active_paths = nullptr;
	std::vector<std::vector<InvalidRange>*>* invalid_ranges = nullptr;
	std::unordered_map<lua_Integer, lua_Integer>* defend_point_node = nullptr;

	inline std::vector<Point>* path(lua_Integer pi, lua_Integer spi = 0) {
		if (pi >= 0 && (size_t)pi < paths->size()) {
			auto arr = (*paths)[pi];
			if (spi >= 0 && spi < 3) {
				return arr[spi];
			}
		}
		return nullptr;
	}

	inline bool is_path_active(lua_Integer pi) {
		if (pi >= 0 && (size_t)pi < active_paths->size()) {
			return (*active_paths)[pi];
		}
		return false;
	}

	inline lua_Integer get_visible_start_node(lua_Integer pi) {
		if (pi >= 0 && (size_t)pi < visible_path_start_node->size()) {
			return (*visible_path_start_node)[pi];
		}
		return -1;
	}

	inline lua_Integer get_visible_end_node(lua_Integer pi) {
		if (pi >= 0 && (size_t)pi < visible_path_end_node->size()) {
			return (*visible_path_end_node)[pi];
		}
		return -1;
	}

	inline bool is_node_valid(lua_Integer pi, lua_Integer ni, lua_Integer flags = 4294967295) {
		std::vector<Point>* subpath = path(pi, 0);
		if (subpath) {
			if (ni >= 0 && (size_t)ni < subpath->size() && is_path_active(pi) && ni >= get_visible_start_node(pi) && ni <= get_visible_end_node(pi)) {
				std::vector<InvalidRange>* ranges = (*invalid_ranges)[pi];
				for (auto& range : *ranges) {
					if (ni >= range.from && ni <= range.to && (flags & (~range.flags)) == 0) {
						return false;
					}
				}
				return true;
			}
			return false;
		}
		throw std::runtime_error("PathDB::is_node_valid encountered an error: path(" + std::to_string(pi) + ", 0) is nullptr.");
	}

	inline Point node_pos(lua_Integer pi, lua_Integer spi, lua_Integer ni) {
		std::vector<Point>* subpath = path(pi, spi);
		if (subpath) {
			double last = static_cast<double>(subpath->size() - 1);
			ni = static_cast<lua_Integer>(utils::clamp(0, last, ni));
			return (*subpath)[ni];
		}
		throw std::runtime_error("PathDB::node_pos encountered an error: path(" + std::to_string(pi) + ", " + std::to_string(spi) + ") is nullptr.");
	}

	inline std::pair<lua_Integer, lua_Integer> nodes_to_goal(lua_Integer pi, lua_Integer spi, lua_Integer ni) const {
		lua_Integer cpi = pi;
		lua_Integer count = -ni;
		while (true) {
			count += path_end_node->at(cpi);
			auto it = path_connections->find(cpi);
			if (it == path_connections->end()) {
				break;
			}
			cpi = it->second;
		}
		return {count, cpi};
	}

	lua_Integer predict_enemy_node_advance(const EntityInfo& e, double flight_time = 0.0, double custom_delay = 0.1) {
		if (flight_time == 0.0) [[unlikely]]
			return 0;
		std::vector<Point>* p = path(e.pi, e.spi);
		if (!p || p->empty()) [[unlikely]]
			return 0;
		flight_time += custom_delay;
		double speed = vector::len(e.speed_x, e.speed_y);
		double fDist = flight_time * speed - 3;
		double x = e.pos_x;
		double y = e.pos_y;
		double dist = 0.0;
		lua_Integer ni = e.ni;
		if (e.dir >= 0) {
			lua_Integer endIndex = p->size() - 1;
			lua_Integer node_offset = endIndex - ni;
			lua_Integer step = 1;
			for (lua_Integer i = ni; i <= endIndex; i += step) {
				const Point& nodePos = node_pos(e.pi, e.spi, i);
				dist += vector::dist(x, y, nodePos.x, nodePos.y);
				if (fDist < dist) {
					node_offset = i - ni;
					break;
				}
				x = nodePos.x;
				y = nodePos.y;
			}
			return node_offset;
		} else {
			lua_Integer node_offset = -ni;
			lua_Integer step = -1;
			for (lua_Integer i = ni; i >= 0; i += step) {
				const Point& nodePos = node_pos(e.pi, e.spi, i);
				dist += vector::dist(x, y, nodePos.x, nodePos.y);
				if (fDist < dist) {
					node_offset = i - ni;
					break;
				}
				x = nodePos.x;
				y = nodePos.y;
			}
			return node_offset;
		}
	}
};

struct GridsOfTargets {
	double x, y, w, h;
	lua_Integer min_ix, max_ix, min_iy, max_iy, step;
	std::unordered_map<lua_Integer, std::unordered_map<lua_Integer, std::vector<EntityInfo*>>> grid;
	std::vector<EntityInfo*> tmp_entities;

	GridsOfTargets(double x = 0.0, double y = 0.0, double w = 0.0, double h = 0.0, 
	lua_Integer min_ix = 0, lua_Integer max_ix = 0, lua_Integer min_iy = 0, lua_Integer max_iy = 0, lua_Integer step = 128) : 
	x(x), y(y), w(w), h(h),
	min_ix(min_ix),
	max_ix(max_ix),
	min_iy(min_iy),
	max_iy(max_iy),
	step(step) {
		tmp_entities.reserve(512);
	}

	void reserve_entity_count(size_t entity_count) {
		tmp_entities.reserve(entity_count);
	}

	void reset() {
		// 遍历所有层级并清空每个 vector
		for (auto& [ix, row] : grid) {
			for (auto& [iy, cell] : row) {
				cell.clear();
			}
		}
	}

	bool insert(EntityInfo* v) {
		// pos_x 为负无穷大时表示无位置，无法插入网格
		if (v->pos_x == -std::numeric_limits<double>::infinity()) [[unlikely]] {
			// 可根据需要记录日志或忽略
			return false;
		}
		double x = v->pos_x;
		double y = v->pos_y;
		lua_Integer ix = static_cast<lua_Integer>(std::ceil((x - this->x) / step));
		lua_Integer iy = static_cast<lua_Integer>(std::ceil((y - this->y) / step));
		auto& row = grid[ix];
		auto& cell = row[iy];
		cell.push_back(v);
		min_ix = std::min(min_ix, ix);
		max_ix = std::max(max_ix, ix);
		min_iy = std::min(min_iy, iy);
		max_iy = std::max(max_iy, iy);
		return true;
	}

	void filter(double x, double y, double range) {
		tmp_entities.clear();
		// 计算需要遍历的网格索引范围
		lua_Integer ix0 = static_cast<lua_Integer>(std::ceil((x - range - this->x) / this->step));
		lua_Integer ix1 = static_cast<lua_Integer>(std::ceil((x + range - this->x) / this->step));
		lua_Integer iy0 = static_cast<lua_Integer>(std::ceil((y - range - this->y) / this->step));
		lua_Integer iy1 = static_cast<lua_Integer>(std::ceil((y + range - this->y) / this->step));
		// 限制在有效索引范围内
		ix0 = std::max(ix0, this->min_ix);
		ix1 = std::min(ix1, this->max_ix);
		iy0 = std::max(iy0, this->min_iy);
		iy1 = std::min(iy1, this->max_iy);
		// 遍历网格
		for (lua_Integer ix = ix0; ix <= ix1; ++ix) {
			auto itX = this->grid.find(ix);
			if (itX == this->grid.end()) [[unlikely]] continue;
			const auto& row = itX->second;
			for (lua_Integer iy = iy0; iy <= iy1; ++iy) {
				auto itY = row.find(iy);
				if (itY == row.end()) [[unlikely]] continue;
				const auto& cell = itY->second;
				// 将单元格中所有实体加入结果
				tmp_entities.insert(tmp_entities.end(), cell.begin(), cell.end());
			}
		}
	}
};

namespace utils {
	inline constexpr double DUMMY_DATA_DOUBLE = -1.0;

	inline bool is_inside_ellipse(const Point& p, const Point& center, double radius, double aspect) {
		double dx = p.x - center.x;
		double dy = p.y - center.y;
		double aspect2 = aspect * aspect;
		double dx2 = dx * dx;
		double dy2 = dy * dy;
		double r2 = radius * radius;
		return (aspect2 * dx2 + dy2) <= (r2 * aspect2);
	}

	inline double clamp(double min, double max, double v) {
		if (v < min) return min;
		if (v > max) return max;
		return v;
	}

	inline void find_enemies_in_range(GridsOfTargets* grids, PathDB* pathdb, Point* tmp_points, 
		double origin_x, double origin_y, double min_range, double max_range, int32_t flags, int32_t bans, 
		const char** allowed_templates, uint32_t allowed_templates_len, const char** excluded_templates, uint32_t excluded_templates_len, 
		std::vector<EntityInfo*>& out) {
		grids->filter(origin_x, origin_y, max_range);
		std::vector<EntityInfo*>& entities = grids->tmp_entities;
		out.clear();
		if (entities.size() == 0) {
			return;
		}

		Point* origin = tmp_points;
		origin->x = origin_x;
		origin->y = origin_y;
		Point& e_pos = tmp_points[1];
		for (EntityInfo* e : entities) {
			if (e->pending_removal) [[unlikely]] continue;
			if (e->entity_type != 1) continue;
			lua_Integer pi = e->pi;
			if (pi == -1) continue;
			int32_t vis_flags = e->vis_flags;
			if (vis_flags == -1) continue;
			if (e->hp <= 0) continue;
			if ((vis_flags & bans) != 0) continue;
			if ((e->vis_bans & flags) != 0) continue;

			if (allowed_templates) {
				bool isContained = false;
				for (uint32_t i = 0; i < allowed_templates_len; ++i) {
					const char* template_name = allowed_templates[i];
					if (template_name == e->template_name) {
						isContained = true;
						break;
					}
				}
				if (!isContained) continue;
			}
			if (excluded_templates) {
				bool excluded = false;
				for (uint32_t i = 0; i < excluded_templates_len; ++i) {
					const char* template_name = excluded_templates[i];
					if (template_name == e->template_name) {
						excluded = true;
						break;
					}
				}
				if (excluded) continue;
			}

			e_pos.x = e->pos_x;
			e_pos.y = e->pos_y;
			lua_Integer e_ni = e->ni;
			// ———— 范围与节点有效性判断 ————
			if (is_inside_ellipse(e_pos, *origin, max_range) && 
				pathdb->is_node_valid(pi, e_ni) && 
				(min_range == 0.0 || !is_inside_ellipse(e_pos, *origin, min_range))) {
				out.push_back(e);
			}
		}
	}

	// 寻找敌人聚集（返回人数最多的聚集）
	inline void find_enemy_crowd(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, SearchResult* result) {
		// 获取原始范围内的所有敌人
		std::vector<EntityInfo*> enemies;
		find_enemies_in_range(grids, pathdb, tmp_points, order->origin_x, order->origin_y, order->min_range, order->max_range, order->flags, order->bans, 
			order->allowed_templates, order->allowed_templates_len, order->excluded_templates, order->excluded_templates_len, enemies);
		size_t enemy_count = enemies.size();
		if (enemy_count == 0) {
			result->number = 0;
			return;
		}
		if (enemy_count == 1 && order->min_targets <= 1) [[unlikely]] {
			EntityInfo* e = enemies[0];
			result->entityPosions[0] = EntityPos{ e->pos_x, e->pos_y, e->id };
			result->number = 1;
			return;
		}

		// 对每个敌人，计算其周围 crowd_range 内的聚集
		std::vector<EntityInfo*> crowd, max_crowd;
		crowd.reserve(enemy_count);
		EntityInfo* center_entity = nullptr;
		for (EntityInfo* center : enemies) {
			double center_x = center->pos_x;
			double center_y = center->pos_y;
			// 以中心位置查找半径 crowd_range 内的所有敌人
			find_enemies_in_range(grids, pathdb, tmp_points, 
				center_x, center_y, 0.0, order->crowd_range, 0, 0, 
				nullptr, 0, nullptr, 0, 
				crowd);
			size_t crowd_size = crowd.size();
			if (crowd_size >= static_cast<size_t>(order->min_targets) && crowd_size > max_crowd.size()) {
				max_crowd = std::move(crowd);
				crowd.clear();
				crowd.reserve(enemy_count);
				center_entity = center;
			}
		}
		uint32_t count = max_crowd.size();
		result->number = count;
		if (count == 0) {
			return;
		}
		if (count > 1 && max_crowd[0] != center_entity) {
			for (uint32_t idx = 1; idx < count; ++idx) {
				if (max_crowd[idx] == center_entity) {
					std::swap(max_crowd[0], max_crowd[idx]);
					break;
				}
			}
		}
		if (count > result->len) {
			delete[] result->entityPosions;
			result->entityPosions = new EntityPos[count];
			result->len = count;
		}

		double prediction_time = order->prediction_time;
		Point& e_pos = tmp_points[0];
		for (uint32_t idx = 0; idx < count; ++idx) {
			EntityInfo* e = max_crowd[idx];
			e_pos.x = e->pos_x;
			e_pos.y = e->pos_y;
			lua_Integer pi = e->pi;
			lua_Integer e_ni = e->ni;
			if (prediction_time != 0.0 && (e->speed_x != 0.0 || e->speed_y != 0.0)) {
				if (e->forced_waypoint) {
					e_pos.x = e->pos_x + prediction_time * e->speed_x;
					e_pos.y = e->pos_y + prediction_time * e->speed_y;
				} else {
					lua_Integer node_offset = pathdb->predict_enemy_node_advance(*e, prediction_time);
					e_ni = e_ni + node_offset;
					if (pathdb->is_node_valid(pi, e_ni)) {
						e_pos = pathdb->node_pos(pi, e->spi, e_ni);
					}
				}
			}
			result->entityPosions[idx] = EntityPos{ e_pos.x, e_pos.y, e->id };
		}
	}

	inline void find_enemies(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, 
		std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result) {
		// 搜索最密集的
		if (order->search_type == search_type::find_max_crowd) {
			find_enemy_crowd(order, pathdb, grids, tmp_points, result);
			return;
		}

		Point* origin = tmp_points;
		origin->x = order->origin_x;
		origin->y = order->origin_y;
		const int32_t flags = order->flags, bans = order->bans;
		const char **allowed_templates = order->allowed_templates,
					**excluded_templates = order->excluded_templates;
		const double min_range = order->min_range, max_range = order->max_range,
					prediction_time = order->prediction_time;

		double range = max_range;
		if (prediction_time != 0.0) {
			range += prediction_time * 150.0;
		}
		grids->filter(origin->x, origin->y, range);
		std::vector<EntityInfo*>& entities = grids->tmp_entities;
		uint32_t entity_count = entities.size();
		if (entity_count == 0) {
			result->number = 0;
			return;
		}
		tmp_positions->clear();
		tmp_positions->reserve(entity_count);
		Point& e_pos = tmp_points[1];
		int8_t search_type = order->search_type;

		for (uint32_t idx = 0; idx < entity_count; ++idx) {
			const EntityInfo& e = *entities[idx];

			// ———— 过滤条件（与 Lua 逻辑等效） ————
			if (e.pending_removal) [[unlikely]] continue;

			// 搜索类别过滤
			if (e.entity_type != 1) continue;
			lua_Integer pi = e.pi;
			if (pi == -1) continue;
			int32_t vis_flags = e.vis_flags;
			if (vis_flags == -1) continue;
			if (e.hp <= 0) continue;
			if ((vis_flags & bans) != 0) continue;
			if ((e.vis_bans & flags) != 0) continue;

			if (allowed_templates) {
				bool isContained = false;
				for (uint32_t i = 0; i < order->allowed_templates_len; ++i) {
					const char* template_name = allowed_templates[i];
					if (template_name == e.template_name) {
						isContained = true;
						break;
					}
				}
				if (!isContained) continue;
			}

			if (excluded_templates) {
				bool excluded = false;
				for (uint32_t i = 0; i < order->excluded_templates_len; ++i) {
					const char* template_name = excluded_templates[i];
					if (template_name == e.template_name) {
						excluded = true;
						break;
					}
				}
				if (excluded) continue;
			}

			// ———— 预测位置与节点处理 ————
			e_pos.x = e.pos_x;
			e_pos.y = e.pos_y;
			lua_Integer e_ni = e.ni;
			if (prediction_time != 0.0 && (e.speed_x != 0.0 || e.speed_y != 0.0)) {
				if (e.forced_waypoint) {
					e_pos.x = e.pos_x + prediction_time * e.speed_x;
					e_pos.y = e.pos_y + prediction_time * e.speed_y;
				} else {
					lua_Integer node_offset = pathdb->predict_enemy_node_advance(e, prediction_time);
					e_ni = e_ni + node_offset;
					e_pos = pathdb->node_pos(pi, e.spi, e_ni);
				}
			}

			// ———— 范围与节点有效性判断 ————
			if (is_inside_ellipse(e_pos, *origin, max_range) && 
				pathdb->is_node_valid(pi, e_ni) && 
				(min_range == 0.0 || (vis_flags & order->min_override_flags) != 0 || !is_inside_ellipse(e_pos, *origin, min_range))) {
				double data = DUMMY_DATA_DOUBLE;
				if (search_type == search_type::nearest || search_type == search_type::farthest || search_type == search_type::max_health || search_type == search_type::min_health || search_type == search_type::max_initial_health || search_type == search_type::min_initial_health) {
					data = vector::dist2(e_pos.x, e_pos.y, origin->x, origin->y);
				}
				else if (search_type == search_type::close_to_exit || search_type == search_type::far_from_exit) {
					data = static_cast<double>(pathdb->nodes_to_goal(pi, e.spi, e.ni).first);
				}
				tmp_positions->emplace_back(EntityPos{ e_pos.x, e_pos.y, e.id }, &e, data);
			}
		}

		const uint32_t count = tmp_positions->size();
		result->number = count;
		if (count == 0) {
			return;
		}
		if (count > result->len) {
			delete[] result->entityPosions;
			result->entityPosions = new EntityPos[count];
			result->len = count;
		}

		// ====================== 在 tmp_positions 上排序 ======================
		if (search_type != search_type::custom && count > 1) {
			// 最接近终点 或者 最近
			if (search_type == search_type::close_to_exit || search_type == search_type::nearest) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](const auto& a, const auto& b) {
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 生命值最多
			else if (search_type == search_type::max_health) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](const auto& a, const auto& b) {
						auto* ea = std::get<1>(a);
						auto* eb = std::get<1>(b);
						if (ea->hp != eb->hp) return ea->hp > eb->hp;
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 随机
			else if (search_type == search_type::random) {
				int64_t idx = math::random(0, static_cast<int64_t>(count) - 1);
				std::swap((*tmp_positions)[0], (*tmp_positions)[idx]);
			}
			// 最远离终点 或者 最远
			else if (search_type == search_type::far_from_exit || search_type == search_type::farthest) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](const auto& a, const auto& b) {
						return std::get<2>(a) > std::get<2>(b);
					});
			}
			// 生命值最少
			else if (search_type == search_type::min_health) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](const auto& a, const auto& b) {
						auto* ea = std::get<1>(a);
						auto* eb = std::get<1>(b);
						if (ea->hp != eb->hp) return ea->hp < eb->hp;
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 最大生命值最多
			else if (search_type == search_type::max_initial_health) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](const auto& a, const auto& b) {
						auto* ea = std::get<1>(a);
						auto* eb = std::get<1>(b);
						if (ea->hp_max != eb->hp_max) return ea->hp_max > eb->hp_max;
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 最大生命值最少
			else if (search_type == search_type::min_initial_health) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](const auto& a, const auto& b) {
						auto* ea = std::get<1>(a);
						auto* eb = std::get<1>(b);
						if (ea->hp_max != eb->hp_max) return ea->hp_max < eb->hp_max;
						return std::get<2>(a) < std::get<2>(b);
					});
			}
		}

		for (uint32_t i = 0; i < count; ++i) {
			result->entityPosions[i] = std::get<0>((*tmp_positions)[i]);
		}
	}

	inline void find_soldiers_in_range(GridsOfTargets* grids, PathDB* pathdb, Point* tmp_points, 
		double origin_x, double origin_y, double min_range, double max_range, int32_t flags, int32_t bans, 
		const char** allowed_templates, uint32_t allowed_templates_len, const char** excluded_templates, uint32_t excluded_templates_len, 
		std::vector<EntityInfo*>& out) {
		grids->filter(origin_x, origin_y, max_range);
		std::vector<EntityInfo*>& entities = grids->tmp_entities;
		out.clear();
		if (entities.size() == 0) {
			return;
		}

		Point* origin = tmp_points;
		origin->x = origin_x;
		origin->y = origin_y;
		Point& e_pos = tmp_points[1];
		for (EntityInfo* e : entities) {
			if (e->pending_removal) [[unlikely]] continue;
			if (e->entity_type != 2) continue;
			int32_t vis_flags = e->vis_flags;
			if (vis_flags == -1) continue;
			if (e->hp <= 0) continue;
			if ((vis_flags & bans) != 0) continue;
			if ((e->vis_bans & flags) != 0) continue;

			if (allowed_templates) {
				bool isContained = false;
				for (uint32_t i = 0; i < allowed_templates_len; ++i) {
					const char* template_name = allowed_templates[i];
					if (template_name == e->template_name) {
						isContained = true;
						break;
					}
				}
				if (!isContained) continue;
			}
			if (excluded_templates) {
				bool excluded = false;
				for (uint32_t i = 0; i < excluded_templates_len; ++i) {
					const char* template_name = excluded_templates[i];
					if (template_name == e->template_name) {
						excluded = true;
						break;
					}
				}
				if (excluded) continue;
			}

			e_pos.x = e->pos_x;
			e_pos.y = e->pos_y;
			// ———— 范围与节点有效性判断 ————
			if (is_inside_ellipse(e_pos, *origin, max_range) && 
				(min_range == 0.0 || !is_inside_ellipse(e_pos, *origin, min_range))) {
				out.push_back(e);
			}
		}
	}

	inline void find_soldier_crowd(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, SearchResult* result) {
		// 获取原始范围内的所有友军
		std::vector<EntityInfo*> soldiers;
		find_soldiers_in_range(grids, pathdb, tmp_points, order->origin_x, order->origin_y, order->min_range, order->max_range, order->flags, order->bans, 
			order->allowed_templates, order->allowed_templates_len, order->excluded_templates, order->excluded_templates_len, soldiers);
		size_t soldier_count = soldiers.size();
		if (soldier_count == 0) {
			result->number = 0;
			return;
		}
		if (soldier_count == 1 && order->min_targets <= 1) [[unlikely]] {
			EntityInfo* e = soldiers[0];
			result->entityPosions[0] = EntityPos{ e->pos_x, e->pos_y, e->id };
			result->number = 1;
			return;
		}

		// 对每个友军，计算其周围 crowd_range 内的聚集
		std::vector<EntityInfo*> crowd, max_crowd;
		crowd.reserve(soldier_count);
		EntityInfo* center_entity = nullptr;
		for (EntityInfo* center : soldiers) {
			double center_x = center->pos_x;
			double center_y = center->pos_y;
			// 以中心位置查找半径 crowd_range 内的所有友军
			find_soldiers_in_range(grids, pathdb, tmp_points, 
				center_x, center_y, 0.0, order->crowd_range, 0, 0, 
				nullptr, 0, nullptr, 0, 
				crowd);
			size_t crowd_size = crowd.size();
			if (crowd_size >= static_cast<size_t>(order->min_targets) && crowd_size > max_crowd.size()) {
				max_crowd = std::move(crowd);
				crowd.clear();
				crowd.reserve(soldier_count);
				center_entity = center;
			}
		}
		uint32_t count = max_crowd.size();
		result->number = count;
		if (count == 0) {
			return;
		}
		if (count > 1 && max_crowd[0] != center_entity) {
			for (uint32_t idx = 1; idx < count; ++idx) {
				if (max_crowd[idx] == center_entity) {
					std::swap(max_crowd[0], max_crowd[idx]);
					break;
				}
			}
		}
		if (count > result->len) {
			delete[] result->entityPosions;
			result->entityPosions = new EntityPos[count];
			result->len = count;
		}

		double x = center_entity->pos_x;
		double y = center_entity->pos_y;
		for (uint32_t idx = 0; idx < count; ++idx) {
			EntityInfo* e = max_crowd[idx];
			result->entityPosions[idx] = EntityPos{ e->pos_x, e->pos_y, e->id };
			x += e->pos_x;
			y += e->pos_y;
		}
		double total = static_cast<double>(count + 1);
		x /= total;
		y /= total;
		double prediction_time = order->prediction_time;
		Point& e_pos = tmp_points[0];
		e_pos.x = x;
		e_pos.y = y;
		if (prediction_time != 0.0 && (center_entity->speed_x != 0.0 || center_entity->speed_y != 0.0)) {
			lua_Integer pi = center_entity->pi;
			if (pi == -1 || center_entity->forced_waypoint) {
				e_pos.x = x + prediction_time * center_entity->speed_x;
				e_pos.y = y + prediction_time * center_entity->speed_y;
			} else {
				lua_Integer e_ni = center_entity->ni;
				lua_Integer node_offset = pathdb->predict_enemy_node_advance(*center_entity, prediction_time);
				e_ni = e_ni + node_offset;
				e_pos = pathdb->node_pos(pi, center_entity->spi, e_ni);
			}
		}
		result->entityPosions[0].x = e_pos.x;
		result->entityPosions[0].y = e_pos.y;
	}

	inline void find_soldiers(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, 
		std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result) {
		// 搜索最密集的
		if (order->search_type == search_type::find_max_crowd) {
			find_soldier_crowd(order, pathdb, grids, tmp_points, result);
			return;
		}

		Point* origin = tmp_points;
		origin->x = order->origin_x;
		origin->y = order->origin_y;
		const int32_t flags = order->flags, bans = order->bans;
		const char **allowed_templates = order->allowed_templates, **excluded_templates = order->excluded_templates;
		const double min_range = order->min_range, max_range = order->max_range, prediction_time = order->prediction_time;

		double range = max_range;
		if (prediction_time != 0.0) {
			range = range + prediction_time * 150.0;
		}
		grids->filter(origin->x, origin->y, range);
		std::vector<EntityInfo*>& entities = grids->tmp_entities;
		uint32_t entity_count = entities.size();
		if (entity_count == 0) {
			result->number = 0;
			return;
		}
		tmp_positions->clear();
		tmp_positions->reserve(entity_count);
		Point& e_pos = tmp_points[1];
		int8_t search_type = order->search_type;

		for (uint32_t idx = 0; idx < entity_count; ++idx) {
			const EntityInfo& e = *entities[idx];

			// ———— 过滤条件（与 Lua 逻辑等效） ————
			if (e.pending_removal) [[unlikely]] continue;

			// 搜索类别过滤
			if (e.entity_type != 2) continue;
			int32_t vis_flags = e.vis_flags;
			if (vis_flags == -1) continue;
			if (e.hp <= 0) continue;
			if ((vis_flags & bans) != 0) continue;
			if ((e.vis_bans & flags) != 0) continue;

			if (allowed_templates) {
				bool isContained = false;
				for (uint32_t i = 0; i < order->allowed_templates_len; ++i) {
					const char* template_name = allowed_templates[i];
					if (template_name == e.template_name) {
						isContained = true;
						break;
					}
				}
				if (!isContained) continue;
			}

			if (excluded_templates) {
				bool excluded = false;
				for (uint32_t i = 0; i < order->excluded_templates_len; ++i) {
					const char* template_name = excluded_templates[i];
					if (template_name == e.template_name) {
						excluded = true;
						break;
					}
				}
				if (excluded) continue;
			}

			// ———— 预测位置与节点处理 ————
			e_pos.x = e.pos_x;
			e_pos.y = e.pos_y;
			if (prediction_time != 0.0 && (e.speed_x != 0.0 || e.speed_y != 0.0)) {
				lua_Integer pi = e.pi;
				if (pi == -1 || e.forced_waypoint) {
					e_pos.x = e.pos_x + prediction_time * e.speed_x;
					e_pos.y = e.pos_y + prediction_time * e.speed_y;
				} else {
					lua_Integer e_ni = e.ni;
					lua_Integer node_offset = pathdb->predict_enemy_node_advance(e, prediction_time);
					e_ni = e_ni + node_offset;
					e_pos = pathdb->node_pos(pi, e.spi, e_ni);
				}
			}

			// ———— 范围与节点有效性判断 ————
			if (is_inside_ellipse(e_pos, *origin, max_range) && (min_range == 0.0 || !is_inside_ellipse(e_pos, *origin, min_range))) {
				double data = DUMMY_DATA_DOUBLE;
				if (search_type == search_type::nearest || search_type == search_type::farthest || search_type == search_type::max_health || search_type == search_type::min_health || search_type == search_type::max_initial_health || search_type == search_type::min_initial_health) {
					data = vector::dist2(e_pos.x, e_pos.y, origin->x, origin->y);
				}
				tmp_positions->emplace_back(EntityPos{ e_pos.x, e_pos.y, e.id }, &e, data);
			}
		}

		const uint32_t count = tmp_positions->size();
		result->number = count;
		if (count == 0) {
			return;
		}
		if (count > result->len) {
			delete[] result->entityPosions;
			result->entityPosions = new EntityPos[count];
			result->len = count;
		}

		// ====================== 在 tmp_positions 上排序 ======================
		if (search_type != search_type::custom && count > 1) {
			// 最近
			if (search_type == search_type::nearest) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](auto const &a, auto const &b) {
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 随机
			else if (search_type == search_type::random) {
				int64_t idx = math::random(0, static_cast<int64_t>(count) - 1);
				std::swap((*tmp_positions)[0], (*tmp_positions)[idx]);
			}
			// 生命值最多
			else if (search_type == search_type::max_health) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](auto const &a, auto const &b) {
						auto* ea = std::get<1>(a);
						auto* eb = std::get<1>(b);
						if (ea->hp != eb->hp) return ea->hp > eb->hp;
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 生命值最少
			else if (search_type == search_type::min_health) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](auto const &a, auto const &b) {
						auto* ea = std::get<1>(a);
						auto* eb = std::get<1>(b);
						if (ea->hp != eb->hp) return ea->hp < eb->hp;
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 最大生命值最多
			else if (search_type == search_type::max_initial_health) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](auto const &a, auto const &b) {
						auto* ea = std::get<1>(a);
						auto* eb = std::get<1>(b);
						if (ea->hp_max != eb->hp_max) return ea->hp_max > eb->hp_max;
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 最大生命值最少
			else if (search_type == search_type::min_initial_health) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](auto const &a, auto const &b) {
						auto* ea = std::get<1>(a);
						auto* eb = std::get<1>(b);
						if (ea->hp_max != eb->hp_max) return ea->hp_max < eb->hp_max;
						return std::get<2>(a) < std::get<2>(b);
					});
			}
			// 最远
			else if (search_type == search_type::farthest) {
				std::sort(tmp_positions->begin(), tmp_positions->end(),
					[](auto const &a, auto const &b) {
						return std::get<2>(a) > std::get<2>(b);
					});
			}
		}

		for (uint32_t i = 0; i < count; ++i) {
			result->entityPosions[i] = std::get<0>((*tmp_positions)[i]);
		}
	}

	inline void find_towers_in_range(const SearchOrder* order, GridsOfTargets* grids, Point* tmp_points, 
		std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result) {
		Point* origin = tmp_points;
		origin->x = order->origin_x;
		origin->y = order->origin_y;
		double max_range = order->max_range;
		double min_range = order->min_range;

		grids->filter(origin->x, origin->y, max_range);
		std::vector<EntityInfo*>& entities = grids->tmp_entities;
		uint32_t entity_count = entities.size();
		if (entity_count == 0) {
			result->number = 0;
			return;
		}
		tmp_positions->clear();
		tmp_positions->reserve(entity_count);
		Point& e_pos = tmp_points[1];

		for (EntityInfo* e : entities) {
			if (e->pending_removal) [[unlikely]] continue;
			if (e->entity_type != -1 && e->entity_type != -2) continue;
			if (!order->including_blocked && e->is_blocked) continue;
			if (!order->including_holder && e->vis_flags == -1) continue;

			if (order->allowed_templates) {
				bool isContained = false;
				for (uint32_t i = 0; i < order->allowed_templates_len; ++i) {
					if (order->allowed_templates[i] == e->template_name) {
						isContained = true;
						break;
					}
				}
				if (!isContained) continue;
			}
			if (order->excluded_templates) {
				bool excluded = false;
				for (uint32_t i = 0; i < order->excluded_templates_len; ++i) {
					if (order->excluded_templates[i] == e->template_name) {
						excluded = true;
						break;
					}
				}
				if (excluded) continue;
			}

			e_pos.x = e->pos_x;
			e_pos.y = e->pos_y;
			if (!utils::is_inside_ellipse(e_pos, *origin, max_range)) continue;
			if (min_range > 0 && utils::is_inside_ellipse(e_pos, *origin, min_range)) continue;
			tmp_positions->emplace_back(EntityPos{ e_pos.x, e_pos.y, e->id }, e, DUMMY_DATA_DOUBLE);
		}

		uint32_t count = tmp_positions->size();
		uint32_t max_towers = order->max_towers;
		if (max_towers > 0 && max_towers < count) {
			count = max_towers;
		}
		result->number = count;
		if (count == 0) return;

		if (count > result->len) {
			delete[] result->entityPosions;
			result->entityPosions = new EntityPos[count];
			result->len = count;
		}

		for (uint32_t i = 0; i < count; ++i) {
			result->entityPosions[i] = std::get<0>(tmp_positions->at(i));
		}
	}

	inline void find_targets_in_range(const SearchOrder* order, PathDB* pathdb, GridsOfTargets* grids, Point* tmp_points, 
									std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result) {
		Point* origin = tmp_points;
		origin->x = order->origin_x;
		origin->y = order->origin_y;
		double max_range = order->max_range;
		double min_range = order->min_range;
		int32_t flags = order->flags;
		int32_t bans = order->bans;

		grids->filter(origin->x, origin->y, max_range);
		std::vector<EntityInfo*>& entities = grids->tmp_entities;
		uint32_t entity_count = entities.size();
		if (entity_count == 0) {
			result->number = 0;
			return;
		}
		tmp_positions->clear();
		tmp_positions->reserve(entity_count);
		Point& e_pos = tmp_points[1];

		for (EntityInfo* e : entities) {
			if (e->pending_removal) [[unlikely]] continue;
			if (e->entity_type != 1 && e->entity_type != 2) continue;
			if (e->vis_flags == -1) continue;
			if (e->hp <= 0) continue;
			if ((e->vis_flags & bans) != 0) continue;
			if ((e->vis_bans & flags) != 0) continue;

			if (order->allowed_templates) {
				bool isContained = false;
				for (uint32_t i = 0; i < order->allowed_templates_len; ++i) {
					if (order->allowed_templates[i] == e->template_name) {
						isContained = true;
						break;
					}
				}
				if (!isContained) continue;
			}
			if (order->excluded_templates) {
				bool excluded = false;
				for (uint32_t i = 0; i < order->excluded_templates_len; ++i) {
					if (order->excluded_templates[i] == e->template_name) {
						excluded = true;
						break;
					}
				}
				if (excluded) continue;
			}

			e_pos.x = e->pos_x;
			e_pos.y = e->pos_y;
			if (!utils::is_inside_ellipse(e_pos, *origin, max_range)) continue;
			if (min_range > 0 && utils::is_inside_ellipse(e_pos, *origin, min_range)) continue;
			// 路径节点有效性检查（仅当有路径时）
			if (e->pi != -1 && !pathdb->is_node_valid(e->pi, e->ni)) continue;
			tmp_positions->emplace_back(EntityPos{ e_pos.x, e_pos.y, e->id }, e, DUMMY_DATA_DOUBLE);
		}

		uint32_t count = tmp_positions->size();
		result->number = count;
		if (count == 0) return;

		if (count > result->len) {
			delete[] result->entityPosions;
			result->entityPosions = new EntityPos[count];
			result->len = count;
		}

		for (uint32_t i = 0; i < count; ++i) {
			result->entityPosions[i] = std::get<0>(tmp_positions->at(i));
		}
	}

	inline void find_entities_in_range(const SearchOrder* order, GridsOfTargets* grids, Point* tmp_points, 
									std::vector<std::tuple<EntityPos, const EntityInfo*, double>>* tmp_positions, SearchResult* result) {
		Point* origin = tmp_points;
		origin->x = order->origin_x;
		origin->y = order->origin_y;
		double max_range = order->max_range;
		double min_range = order->min_range;
		int32_t flags = order->flags;
		int32_t bans = order->bans;

		grids->filter(origin->x, origin->y, max_range);
		std::vector<EntityInfo*>& entities = grids->tmp_entities;
		uint32_t entity_count = entities.size();
		if (entity_count == 0) {
			result->number = 0;
			return;
		}
		tmp_positions->clear();
		tmp_positions->reserve(entity_count);
		Point& e_pos = tmp_points[1];

		for (EntityInfo* e : entities) {
			if (e->pending_removal) [[unlikely]] continue;
			if (e->vis_flags != -1) [[unlikely]] {
				if ((e->vis_flags & bans) != 0) continue;
				if ((e->vis_bans & flags) != 0) continue;
			}

			if (order->allowed_templates) {
				bool isContained = false;
				for (uint32_t i = 0; i < order->allowed_templates_len; ++i) {
					if (order->allowed_templates[i] == e->template_name) {
						isContained = true;
						break;
					}
				}
				if (!isContained) continue;
			}
			if (order->excluded_templates) {
				bool excluded = false;
				for (uint32_t i = 0; i < order->excluded_templates_len; ++i) {
					if (order->excluded_templates[i] == e->template_name) {
						excluded = true;
						break;
					}
				}
				if (excluded) continue;
			}

			e_pos.x = e->pos_x;
			e_pos.y = e->pos_y;
			if (!utils::is_inside_ellipse(e_pos, *origin, max_range)) continue;
			if (min_range > 0 && utils::is_inside_ellipse(e_pos, *origin, min_range)) continue;
			tmp_positions->emplace_back(EntityPos{ e_pos.x, e_pos.y, e->id }, e, DUMMY_DATA_DOUBLE);
		}

		uint32_t count = tmp_positions->size();
		result->number = count;
		if (count == 0) return;

		if (count > result->len) {
			delete[] result->entityPosions;
			result->entityPosions = new EntityPos[count];
			result->len = count;
		}

		for (uint32_t i = 0; i < count; ++i) {
			result->entityPosions[i] = std::get<0>(tmp_positions->at(i));
		}
	}
}