cmake_minimum_required(VERSION 3.20)
project(MyNativeLibs VERSION 1.0 LANGUAGES C CXX)

# 设置 C/C++ 标准（可根据需要调整）
set(CMAKE_C_STANDARD 23)
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_ANDROID_STL_TYPE c++_shared)

# 设置 Android API 级别为 21
set(CMAKE_SYSTEM_VERSION 21)

# 将动态库输出到父目录下的 /dll_and_so_files
# 动态库输出目录（Linux/Android .so 及 macOS .dylib）
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../dll_and_so_files")
# Windows 动态库 (.dll) 属于 RUNTIME 输出
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../dll_and_so_files")

# 声明 luajit（预编译 .so 或 .dll ）
add_library(luajit SHARED IMPORTED)

add_library(debugC SHARED debugC.cpp)
target_include_directories(debugC PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

# 指定 .so 或者 .dll 路径
if(WIN32)
	set_target_properties(luajit PROPERTIES
		IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../dll_and_so_files/lua51.dll"
		IMPORTED_IMPLIB   "${CMAKE_CURRENT_SOURCE_DIR}/../dll_and_so_files/lua51.dll"  # 直接使用 DLL 作为导入库
	)
	add_library(cpptrace SHARED IMPORTED)
	set_target_properties(cpptrace PROPERTIES
		IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../dll_and_so_files/libcpptrace.dll"
		IMPORTED_IMPLIB   "${CMAKE_CURRENT_SOURCE_DIR}/../dll_and_so_files/libcpptrace.dll"
	)
	target_include_directories(cpptrace INTERFACE
		${CMAKE_CURRENT_SOURCE_DIR}/cpptrace
	)
	target_link_libraries(debugC PUBLIC cpptrace)
elseif(ANDROID)
	set_target_properties(luajit PROPERTIES
		IMPORTED_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}/../dll_and_so_files/liblove.so"
	)
	find_library(log-lib log)
	target_link_libraries(debugC PUBLIC ${log-lib})
endif()

target_include_directories(luajit INTERFACE
	${CMAKE_CURRENT_SOURCE_DIR}/LuaJIT
)

target_link_libraries(debugC PUBLIC luajit)

if(WIN32)
	set_target_properties(debugC PROPERTIES
		PREFIX ""
		OUTPUT_NAME "debugC"
	)
else()
	set_target_properties(debugC PROPERTIES
		PREFIX "lib"
		OUTPUT_NAME "debugC"
	)
endif()

# ==============================================
# 构建 myExtension 动态库
# ==============================================
add_library(myExtension SHARED
	myExtension.c
	sso.cpp
	pathDB.cpp
)

target_include_directories(myExtension PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(myExtension PUBLIC debugC)

if(WIN32)
	# Windows 平台：移除 "lib" 前缀，并强制输出名称为 myExtension.dll
	set_target_properties(myExtension PROPERTIES
		PREFIX ""              # 将前缀设置为空，移除 "lib"
		OUTPUT_NAME "myExtension"
	)
else()
	# Android / Linux 平台：保留默认的 "lib" 前缀
	# 这意味着生成的库文件将是 libmyExtension.so
	set_target_properties(myExtension PROPERTIES
		PREFIX "lib"
		OUTPUT_NAME "myExtension"
	)
endif()

# ==============================================
# 构建 render_worker 动态库
# ==============================================
add_library(render_worker SHARED
	render_worker.cpp
	render_sort.cpp
)

target_include_directories(render_worker PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(render_worker PUBLIC debugC)

set(HWY_ENABLE_TESTS OFF CACHE BOOL "" FORCE)
set(HWY_ENABLE_EXAMPLES OFF CACHE BOOL "" FORCE)
set(HWY_ENABLE_CONTRIB_TESTS OFF CACHE BOOL "" FORCE)
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/highway" EXCLUDE_FROM_ALL)

# 链接 Highway 目标（这些目标已由 add_subdirectory 定义）
target_link_libraries(render_worker PUBLIC hwy_contrib hwy)

# 静态链接 Highway 时的必要宏
target_compile_definitions(render_worker PRIVATE HWY_STATIC_DEFINE)

if(WIN32)
	set_target_properties(render_worker PROPERTIES
		PREFIX ""
		OUTPUT_NAME "render_worker"
	)
else()
	set_target_properties(render_worker PROPERTIES
		PREFIX "lib"
		OUTPUT_NAME "render_worker"
	)
endif()

# ==============================================
# 构建 search_worker 动态库
# ==============================================
add_library(search_worker SHARED
	search_worker.cpp
)

target_include_directories(search_worker PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(search_worker PUBLIC debugC)

if(WIN32)
	set_target_properties(search_worker PROPERTIES
		PREFIX ""
		OUTPUT_NAME "search_worker"
	)
else()
	set_target_properties(search_worker PROPERTIES
		PREFIX "lib"
		OUTPUT_NAME "search_worker"
	)
endif()