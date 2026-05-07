// render_worker.cpp
#include <thread>
#include <mutex>
#include <condition_variable>
#include <vector>
#include <algorithm>
#include <cassert>
#include <atomic>
#include <math.h>
#include "lua.hpp"
#include "kra_common.hpp"
#include "hwy/base.h"
#include "debugC.h"

extern void sort_frames(RenderFrameFFI* frames, uint16_t len, std::vector<hwy::uint128_t>& keys, std::vector<RenderFrameFFI>& tmp);

class RenderWorker {
private:
	void threadFunc() {
		std::vector<hwy::uint128_t> keys;
		std::vector<RenderFrameFFI> tmp;
		while (true) {
			Task* task;

			{
				std::unique_lock<std::mutex> lock(mtx);
				cv.wait(lock, [&]() {
					// 等待任务 或 停止请求
					return stopRequested.load(std::memory_order_acquire) || !taskBuf.empty();
				});

				// 立即停止：只要收到 stop 请求，就退出
				if (stopRequested.load(std::memory_order_acquire)) {
					return;
				}

				// 否则处理队列中的第一个任务
				task = &taskBuf.front();
			}

			try {
				// 执行排序任务
				RenderFrameFFI* frames = static_cast<RenderFrameFFI*>(task->data[0].data);
				sort_frames(frames, task->data[0].len, keys, tmp);
			} catch (const std::exception& e) {
				record_error((std::string("Fatal error in render worker. Execution stopped.\n") + e.what()).c_str());
				delete[] task->data;
				return;
			}

			// 任务完成，记录结果
			{
				CompletedTask ct{ task->type };
				delete[] task->data;
				// task = 0;
				std::lock_guard<std::mutex> lock(mtx);
				taskBuf.erase(taskBuf.begin());
				completedBuf.push_back(ct);
			}
		}
	}

	std::vector<Task> taskBuf;
	std::vector<CompletedTask> completedBuf;

	std::mutex mtx;
	std::condition_variable cv;
	std::atomic<bool> stopRequested;
	std::thread thr;

public:
	RenderWorker()
	  : stopRequested(false),
		thr(&RenderWorker::threadFunc, this)
	{}

	~RenderWorker() {
		requestStop();
		if (thr.joinable()) {
			thr.join();
		}

		for (auto &t : taskBuf) {
			delete[] t.data;
		}
	}

	// 检查是否可以提交帧排序任务
	bool canSubmitTaskRenderSort() {
		std::lock_guard<std::mutex> lock(mtx);
		for (auto &old : taskBuf) {
			if (old.type == 0) {
				return false;
			}
		}
		return true;
	}

	void enqueueTask(const Task &t) {
		std::lock_guard<std::mutex> lock(mtx);
		taskBuf.push_back(t);
		cv.notify_one();
	}

	// 弹出已经完成的任务
	bool popCompleted(CompletedTask &out) {
		std::lock_guard<std::mutex> lock(mtx);
		if (completedBuf.empty()) {
			return false;
		}
		out = std::move(completedBuf.front());
		completedBuf.erase(completedBuf.begin());
		return true;
	}

	// 请求停止 — 立即停止
	void requestStop() {
		stopRequested.store(true, std::memory_order_release);
		cv.notify_one();
	}

};

// C 接口
extern "C" {
	RenderWorker* create_render_worker() {
		return new RenderWorker();
	}

	bool render_worker_can_submit_task_render_sort(RenderWorker* w) {
		return w->canSubmitTaskRenderSort();
	}

	void render_worker_submit_task_render_sort(RenderWorker* w, RenderFrameFFI* frames, uint32_t len) {
		DataArray* arr = new DataArray[1];
		arr[0].data = static_cast<void*>(frames);
		arr[0].len = len;
		Task t{ arr, 1, 0 };
		w->enqueueTask(t);
	}

	bool render_worker_pop_completed(RenderWorker* w, CompletedTask* out) {
		return w->popCompleted(*out);
	}

	void render_worker_destroy(RenderWorker* w) {
		delete w;
	}
}
