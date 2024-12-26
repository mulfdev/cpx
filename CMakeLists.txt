cmake_minimum_required(VERSION 3.30)


find_program(LLVM_CLANG_PATH 
   NAMES clang
   PATHS 
       "/opt/homebrew/opt/llvm/bin"  # macOS Homebrew (highest priority)
       "/usr/bin"                    # System default 
       "/usr/local/bin"              # Unix/Linux secondary paths
       "/usr/lib/llvm-*/bin"         # Linux LLVM installations
       "C:/Program Files/LLVM/bin"   # Windows fallback
   NO_DEFAULT_PATH  # Enforce strict priority order
)

find_program(LLVM_CLANGXX_PATH 
   NAMES clang++
   PATHS 
       "/opt/homebrew/opt/llvm/bin"
       "/usr/bin"
       "/usr/local/bin"
       "/usr/lib/llvm-*/bin"
       "C:/Program Files/LLVM/bin"
   NO_DEFAULT_PATH
)

if(LLVM_CLANG_PATH AND LLVM_CLANGXX_PATH)
   set(CMAKE_C_COMPILER "${LLVM_CLANG_PATH}" CACHE FILEPATH "C compiler" FORCE)
   set(CMAKE_CXX_COMPILER "${LLVM_CLANGXX_PATH}" CACHE FILEPATH "CXX compiler" FORCE)
endif()

# Force compiler selection before project
set(CMAKE_C_COMPILER_WORKS TRUE)
set(CMAKE_CXX_COMPILER_WORKS TRUE)

# Enable ccache if available
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()

project(my_project)

# Download CPM.cmake
set(CPM_DOWNLOAD_VERSION 0.40.2)
set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")

if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
    file(DOWNLOAD 
        https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake
        ${CPM_DOWNLOAD_LOCATION}
    )
endif()
include(${CPM_DOWNLOAD_LOCATION})

# Add dependencies
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

# Set C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Create executable
add_executable(my_project src/main.cpp)

# Link libraries
target_link_libraries(my_project PRIVATE 
    fmt::fmt
    spdlog::spdlog
    yaml-cpp
    llama
)
