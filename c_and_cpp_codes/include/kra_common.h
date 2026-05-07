// kra_common.h
#ifndef KRA_COMMON_H
#define KRA_COMMON_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#include <lua.h>

typedef struct {
	void* data;
	uint32_t len;
} DataArray;

typedef struct {
	DataArray* data;
	uint32_t len;
	int8_t type;
} Task;

typedef struct {
	int8_t type;
} CompletedTask;

typedef struct {
	// 填充数组时写入原始顺序
	uint16_t render_index;
	uint16_t z;
	float    sort_y;
	int32_t  draw_order;
	float    pos_x;
} RenderFrameFFI;

typedef struct {
	const char* template_name;
	// speed_x和speed_y都为0，代表无motion
	double speed_x;
	double speed_y;
	// pos_x为负无穷大时，代表无pos
	double pos_x;
	double pos_y;
	uint32_t id;
	// vis_flags为-1时，代表无vis
	int32_t vis_flags;
	int32_t vis_bans;
	// 生命最大值。hp_max为-1时，代表无health
	int32_t hp_max;
	// 生命值。hp为-1时，代表无health；为0时，代表死亡；大于0时，代表存活
	int32_t hp;
	uint16_t ni;
	// pi为-1时，代表无nav_path
	int8_t pi;
	int8_t spi;
	int8_t dir;
	// entity_type为-1时，代表无tower_holder的防御塔；为-2时，代表有tower_holder的实体；为1时，代表敌方单位；为2时，代表友方单位；为0时，代表其他实体
	int8_t entity_type;
	// is_blocked为true时，代表无法行动；为false时，代表能正常行动
	bool is_blocked;
	bool pending_removal;
	bool forced_waypoint;
} EntityInfo;

typedef struct {
	const char** allowed_templates;
	const char** excluded_templates;
	uint32_t allowed_templates_len;
	uint32_t excluded_templates_len;
	double origin_x;
	double origin_y;
	double min_range;
	double max_range;
	double prediction_time;
	double crowd_range;
	int32_t flags;
	int32_t bans;
	int32_t min_override_flags;
	uint32_t min_targets;
	uint32_t max_towers;
	// type为-1，代表搜索防御塔；1代表搜索敌方单位；2代表搜索友方单位；3代表搜索所有单位；0代表搜索所有实体
	int8_t type;
	// search_type为1，代表搜索最近的；2代表搜索最远的；3代表随机搜索；4代表搜索生命值最多的；5代表搜索生命值最少的；6代表搜索最接近终点的；7代表搜索最远离终点的；
	// 8代表搜索最密集的；9代表搜索最大生命值最多的；10代表搜索最大生命值最少的；32代表自定义
	int8_t search_type;
	bool including_blocked;
	bool including_holder;
} SearchOrder;

typedef struct {
	double x;
	double y;
} Point;

typedef struct {
	lua_Integer from;
	lua_Integer to;
	lua_Integer flags;
} InvalidRange;

typedef struct {
	double x;
	double y;
	uint32_t id;
} EntityPos;

typedef struct {
	EntityPos* entityPosions;
	uint32_t len;
	uint32_t number;
} SearchResult;

#ifdef __cplusplus
}
#endif

#endif