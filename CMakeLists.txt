cmake_minimum_required(VERSION 3.28)

set(PROJECT_NAME_VAR "my_project")

find_program(LLVM_CLANG_PATH clang PATHS "/opt/homebrew/opt/llvm/bin" "/usr/bin" "/usr/local/bin" NO_DEFAULT_PATH)
find_program(LLVM_CLANGXX_PATH clang++ PATHS "/opt/homebrew/opt/llvm/bin" "/usr/bin" "/usr/local/bin" NO_DEFAULT_PATH)

if(LLVM_CLANG_PATH AND LLVM_CLANGXX_PATH)
  set(CMAKE_C_COMPILER "${LLVM_CLANG_PATH}")
  set(CMAKE_CXX_COMPILER "${LLVM_CLANGXX_PATH}")
endif()

project(${PROJECT_NAME_VAR})

set(CMAKE_BUILD_PARALLEL_LEVEL 4)

find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
   set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
   set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()

if(APPLE)
   add_link_options(-fuse-ld=lld)
elseif(UNIX)
   add_link_options(-fuse-ld=gold)
endif()

set(CPM_DOWNLOAD_VERSION 0.40.2)
set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")

if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
   file(DOWNLOAD 
       https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake
       ${CPM_DOWNLOAD_LOCATION}
   )
endif()
include(${CPM_DOWNLOAD_LOCATION})

CPMAddPackage(
   NAME fmt
   GITHUB_REPOSITORY fmtlib/fmt
   GIT_TAG master
)

CPMAddPackage(
   NAME spdlog
   GITHUB_REPOSITORY gabime/spdlog
   GIT_TAG v1.12.0
)

CPMAddPackage(
   NAME yaml-cpp
   GITHUB_REPOSITORY jbeder/yaml-cpp
   GIT_TAG master
)

CPMAddPackage(
   NAME llama.cpp
   GITHUB_REPOSITORY ggerganov/llama.cpp
   GIT_TAG master
)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(${PROJECT_NAME_VAR} src/main.cpp)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
   set_target_properties(${PROJECT_NAME_VAR} PROPERTIES OUTPUT_NAME "dev_${PROJECT_NAME_VAR}")
endif()

target_link_libraries(${PROJECT_NAME_VAR} PRIVATE 
   fmt::fmt
   spdlog::spdlog
   yaml-cpp
   llama
)
