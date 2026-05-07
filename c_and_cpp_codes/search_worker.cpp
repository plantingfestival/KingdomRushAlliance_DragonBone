// search_worker.cpp
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
#include "debugC.h"

class SearchWorker {
private:
	void threadFunc() {
		Point tmp_points[2];
		std::vector<std::tuple<EntityPos, const EntityInfo*, double>> tmp_positions;

		while (true) {
			Task* task;

			{
				std::unique_lock<std::mutex> lock(mtx);
				cv.wait(lock, [&]() {
					// 等待任务 或 停止请求
					return stopRequested.load(std::memory_order_acquire) || !taskBuf.empty();
				});

				// 立即停止：只要收到 stop 请求，就退出
				if (stopRequested.load(std::memory_order_acquire)) [[unlikely]] {
					return;
				}

				// 否则处理队列中的第一个任务
				task = &taskBuf.front();
			}

			try {
				// 执行搜索任务
				EntityInfo* entities = static_cast<EntityInfo*>(task->data[0].data);
				uint32_t entities_len = task->data[0].len;
				SearchOrder* orders = static_cast<SearchOrder*>(task->data[1].data);
				uint32_t orders_len = task->data[1].len;
				SearchResult* results = static_cast<SearchResult*>(task->data[2].data);
				GridsOfTargets* grids = static_cast<GridsOfTargets*>(task->data[3].data);
				PathDB* pathdb = static_cast<PathDB*>(task->data[4].data);
	
				grids->reset();
				grids->reserve_entity_count(entities_len);
				for (int i = 0; i < entities_len; ++i) {
					grids->insert(&entities[i]);
				}
				for (int i = 0; i < orders_len; ++i) {
					SearchOrder& order = orders[i];
					if (order.type == 1) {
						utils::find_enemies(&order, pathdb, grids, tmp_points, &tmp_positions, &results[i]);
					} else if (order.type == 2) {
						utils::find_soldiers(&order, pathdb, grids, tmp_points, &tmp_positions, &results[i]);
					} else if (order.type == -1) {
						utils::find_towers_in_range(&order, grids, tmp_points, &tmp_positions, &results[i]);
					} else if (order.type == 3) {
						utils::find_targets_in_range(&order, pathdb, grids, tmp_points, &tmp_positions, &results[i]);
					} else if (order.type == 0) {
						utils::find_entities_in_range(&order, grids, tmp_points, &tmp_positions, &results[i]);
					}
				}
			} catch (const std::exception& e) {
				record_error((std::string("Fatal error in search worker. Execution stopped.\n") + e.what()).c_str());
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
	SearchWorker()
	  : stopRequested(false),
		thr(&SearchWorker::threadFunc, this)
	{}

	~SearchWorker() {
		requestStop();
		if (thr.joinable()) {
			thr.join();
		}

		for (auto &t : taskBuf) {
			delete[] t.data;
		}
	}

	// 检查是否可以提交索敌任务
	bool canSubmitTaskFindTargets() {
		std::lock_guard<std::mutex> lock(mtx);
		for (auto &old : taskBuf) {
			if (old.type == 1) {
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
	SearchWorker* create_search_worker() {
		return new SearchWorker();
	}

	bool search_worker_can_submit_task_find_targets(SearchWorker* w) {
		return w->canSubmitTaskFindTargets();
	}

	void search_worker_submit_task_find_targets(SearchWorker* w, EntityInfo* entities, uint32_t entities_len, SearchOrder* orders, uint32_t orders_len, 
		SearchResult* results, GridsOfTargets* grids, PathDB* pathdb) {
		DataArray* arr = new DataArray[5];
		arr[0].data = static_cast<void*>(entities);
		arr[0].len = entities_len;
		arr[1].data = static_cast<void*>(orders);
		arr[1].len = orders_len;
		arr[2].data = static_cast<void*>(results);
		arr[2].len = orders_len;
		arr[3].data = static_cast<void*>(grids);
		arr[3].len = 1;
		arr[4].data = static_cast<void*>(pathdb);
		arr[4].len = 1;

		Task t{ arr, 5, 1 };
		w->enqueueTask(t);
	}

	bool search_worker_pop_completed(SearchWorker* w, CompletedTask* out) {
		return w->popCompleted(*out);
	}

	void search_worker_destroy(SearchWorker* w) {
		delete w;
	}

	void search_results_init(SearchResult* results, uint32_t results_len) {
		for (uint32_t i = 0; i < results_len; ++i) {
			results[i].entityPosions = new EntityPos[16];
			results[i].len = 16;
			results[i].number = 0;
		}
	}

	void search_results_clear(SearchResult* results, uint32_t results_len) {
		for (uint32_t i = 0; i < results_len; ++i) {
			delete[] results[i].entityPosions;
			results[i].entityPosions = nullptr;
			results[i].len = 0;
		}
	}

}
