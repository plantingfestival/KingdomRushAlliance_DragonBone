// render_sort.cpp
#include <bit>
#include <cstdint>
#include <vector>
#include <cstring>

#include "hwy/base.h"
#include "hwy/contrib/sort/vqsort.h"
#include "kra_common.h"

using U128 = hwy::uint128_t;

// float -> uint32 (ascending)
inline uint32_t float_to_uint32_asc(float f) {
	uint32_t u = std::bit_cast<uint32_t>(f);
	return (u & 0x80000000u) ? ~u : (u ^ 0x80000000u);
}

// int32 -> uint32 (ascending signed)
inline uint32_t int32_to_uint32_asc(int32_t x) {
	return uint32_t(x) ^ 0x80000000u;
}

// 完整排序 key：
// z asc
// sort_y desc
// draw_order asc (signed)
// pos_x asc
// render_index asc (稳定 + 回表)
inline U128 make_key(const RenderFrameFFI& f) {
	const uint32_t draw = int32_to_uint32_asc(f.draw_order);

	const uint64_t hi =
		(uint64_t(f.z) << 48) |
		(uint64_t(~float_to_uint32_asc(f.sort_y)) << 16) |
		uint64_t(uint16_t(draw >> 16));

	const uint64_t lo =
		(uint64_t(uint16_t(draw)) << 48) |
		(uint64_t(float_to_uint32_asc(f.pos_x)) << 16) |
		uint64_t(f.render_index);

	return U128{lo, hi};
}

void sort_frames(RenderFrameFFI* frames, uint16_t len, std::vector<U128>& keys, std::vector<RenderFrameFFI>& tmp) {
	keys.reserve(len);
	tmp.reserve(len);
	keys.clear();
	tmp.clear();

	// 构造完整 key
	for (uint16_t i = 0; i < len; ++i) {
		keys.push_back(make_key(frames[i]));
	}

	// 一次 SIMD 排序
	hwy::VQSort(keys.data(), len, hwy::SortAscending());

	// 最终回表
	for (uint16_t i = 0; i < len; ++i) {
		const uint16_t idx = static_cast<uint16_t>(keys[i].lo & 0xFFFFu) - 1; // render_index 从 1 开始
		tmp.push_back(frames[idx]);
	}

	memcpy(frames, tmp.data(), len * sizeof(RenderFrameFFI));
}
