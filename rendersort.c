// rendersort.c
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <stdint.h>

typedef struct {
	int32_t z;
	float sort_y;
	int32_t draw_order;
	float pos_x;
	uint32_t lua_index;
} RenderFrameFFI;

// ==================== 比较函数 ====================
// 返回 true 表示 f1 < f2
static bool compare_frames_ffi(const RenderFrameFFI* f1, const RenderFrameFFI* f2) {
	if (f1->z != f2->z) return f1->z < f2->z;
	if (f1->sort_y != f2->sort_y) return f2->sort_y < f1->sort_y;
	if (f1->draw_order != f2->draw_order) return f1->draw_order < f2->draw_order;
	return f1->pos_x < f2->pos_x;
}

// ==================== qsort 比较函数 ====================
// 用于 malloc 失败回退（不稳定）
static int compare_frames_ffi_qsort(const void* a, const void* b) {
	const RenderFrameFFI* f1 = a;
	const RenderFrameFFI* f2 = b;
	if (f1->z != f2->z) return (f1->z < f2->z) ? -1 : 1;
	if (f1->sort_y != f2->sort_y) return (f1->sort_y > f2->sort_y) ? -1 : 1;
	if (f1->draw_order != f2->draw_order) return (f1->draw_order < f2->draw_order) ? -1 : 1;
	if (f1->pos_x != f2->pos_x) return (f1->pos_x < f2->pos_x) ? -1 : 1;
	return 0;
}

// ==================== 二分插入排序 ====================
// 仅用于 TimSort 内小数组排序
static void binary_insertion_sort(RenderFrameFFI* arr, uint32_t left, uint32_t right) {
	for (uint32_t i = left + 1; i <= right; i++) {
		RenderFrameFFI key = arr[i];
		uint32_t lo = left, hi = i;
		while (lo < hi) {
			uint32_t mid = (lo + hi) >> 1;
			if (compare_frames_ffi(&key, &arr[mid])) hi = mid;
			else lo = mid + 1;
		}
		uint32_t n = i - lo;
		if (n > 0)
			memmove(&arr[lo + 1], &arr[lo], n * sizeof(RenderFrameFFI));
		arr[lo] = key;
	}
}

// ==================== TimSort 配套函数 ====================
#define MIN_MERGE 32
#define MAX_STACK_SIZE 64

typedef struct {
	uint32_t start;
	uint32_t length;
} Run;

// 计算 min_run 长度
static uint32_t min_run_length(uint32_t n) {
	uint32_t r = 0;
	while (n >= MIN_MERGE) {
		r |= (n & 1);
		n >>= 1;
	}
	return n + r;
}

// 统计 run（升序或降序），并自动反转降序 run
static uint32_t count_run(RenderFrameFFI* arr, uint32_t start, uint32_t end) {
	if (start + 1 >= end) return 1;
	uint32_t run_end = start + 1;

	if (compare_frames_ffi(&arr[run_end], &arr[start])) {
		while (run_end < end && compare_frames_ffi(&arr[run_end], &arr[run_end - 1])) run_end++;
		// 反转降序 run
		uint32_t i = start, j = run_end - 1;
		while (i < j) {
			RenderFrameFFI tmp = arr[i];
			arr[i++] = arr[j];
			arr[j--] = tmp;
		}
	} else {
		while (run_end < end && !compare_frames_ffi(&arr[run_end], &arr[run_end - 1])) run_end++;
	}

	return run_end - start;
}

// merge_run：归并两个 run（左段或右段较小用 temp）
static void merge_run(RenderFrameFFI* arr, uint32_t start, uint32_t mid, uint32_t end, RenderFrameFFI* temp, uint32_t temp_size) {
	uint32_t left_len = mid - start;
	uint32_t right_len = end - mid;
	if (left_len == 0 || right_len == 0) return;

	if (left_len <= right_len) {
		memcpy(temp, &arr[start], left_len * sizeof(RenderFrameFFI));
		uint32_t i = 0, j = mid, k = start;
		while (i < left_len && j < end) {
			if (compare_frames_ffi(&temp[i], &arr[j])) arr[k++] = temp[i++];
			else arr[k++] = arr[j++];
		}
		while (i < left_len) arr[k++] = temp[i++];
	} else {
		memcpy(temp, &arr[mid], right_len * sizeof(RenderFrameFFI));
		uint32_t i = mid;
		uint32_t j = right_len;
		uint32_t k = end;
		while (i > start && j > 0) {
			if (compare_frames_ffi(&arr[i - 1], &temp[j - 1])) arr[--k] = temp[--j];
			else arr[--k] = arr[--i];
		}
		while (j > 0) arr[--k] = temp[--j];
	}
}

// ==================== TimSort 主函数 ====================
static void timsort_ffi(RenderFrameFFI* arr, uint32_t len) {
	if (len <= 1) return;
	if (len <= MIN_MERGE) {
		binary_insertion_sort(arr, 0, len - 1);
		return;
	}

	uint32_t min_run = min_run_length(len);
	uint32_t temp_size = len / 2;
	RenderFrameFFI* temp = malloc(temp_size * sizeof(RenderFrameFFI));
	if (!temp) {
		// malloc失败时回退到 qsort（不稳定）
		qsort(arr, len, sizeof(RenderFrameFFI), compare_frames_ffi_qsort);
		return;
	}

	Run runs[MAX_STACK_SIZE];
	uint32_t stack_size = 0;
	uint32_t i = 0;

	while (i < len) {
		uint32_t run_len = count_run(arr, i, len);
		if (run_len < min_run) {
			uint32_t remaining = len - i;
			uint32_t extend = (remaining < min_run) ? remaining : min_run;
			binary_insertion_sort(arr, i, i + extend - 1);
			run_len = extend;
		}

		runs[stack_size++] = (Run){i, run_len};

		for (;;) {
			if (stack_size <= 1) break;
			uint32_t n = stack_size - 1;

			if (n >= 2 && runs[n-2].length <= runs[n-1].length + runs[n].length) {
				if (runs[n-2].length < runs[n].length) {
					uint32_t a = runs[n-2].start;
					uint32_t b = runs[n-1].start;
					uint32_t c = b + runs[n-1].length;
					merge_run(arr, a, b, c, temp, temp_size);
					runs[n-2].length += runs[n-1].length;
					runs[n-1] = runs[n];
					stack_size--;
					continue;
				} else {
					uint32_t a = runs[n-1].start;
					uint32_t b = runs[n].start;
					uint32_t c = b + runs[n].length;
					merge_run(arr, a, b, c, temp, temp_size);
					runs[n-1].length += runs[n].length;
					stack_size--;
					continue;
				}
			}

			if (runs[n-1].length <= runs[n].length) {
				uint32_t a = runs[n-1].start;
				uint32_t b = runs[n].start;
				uint32_t c = b + runs[n].length;
				merge_run(arr, a, b, c, temp, temp_size);
				runs[n-1].length += runs[n].length;
				stack_size--;
				continue;
			}

			break;
		}

		i += run_len;
	}

	while (stack_size > 1) {
		uint32_t n = stack_size - 1;
		uint32_t a = runs[n-1].start;
		uint32_t b = runs[n].start;
		uint32_t c = b + runs[n].length;
		merge_run(arr, a, b, c, temp, temp_size);
		runs[n-1].length += runs[n].length;
		stack_size--;
	}

	free(temp);
}

// ==================== 外部接口 ====================
void sort_ffi(RenderFrameFFI* frames, uint32_t len) {
	timsort_ffi(frames, len);
}
