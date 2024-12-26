cmake_minimum_required(VERSION 3.25)

# Set policies before anything else
if(POLICY CMP0169)
    cmake_policy(SET CMP0169 NEW)  # Use FetchContent_MakeAvailable instead of FetchContent_Populate
endif()

# Enable ccache if available (before project() command)
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
endif()

project(my_project)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Download CPM.cmake
set(CPM_DOWNLOAD_VERSION 0.38.6)
set(CPM_DOWNLOAD_LOCATION "${CMAKE_BINARY_DIR}/cmake/CPM_${CPM_DOWNLOAD_VERSION}.cmake")

if(NOT (EXISTS ${CPM_DOWNLOAD_LOCATION}))
    message(STATUS "Downloading CPM.cmake...")
    file(DOWNLOAD 
        https://github.com/cpm-cmake/CPM.cmake/releases/download/v${CPM_DOWNLOAD_VERSION}/CPM.cmake
        ${CPM_DOWNLOAD_LOCATION}
    )
endif()
include(${CPM_DOWNLOAD_LOCATION})

# Add dependencies from GitHub - THIS IS THE ONLY PLACE TO UPDATE
CPMAddPackage(
    NAME fmt
    GITHUB_REPOSITORY fmtlib/fmt
    GIT_TAG master
)

CPMAddPackage(
    NAME spdlog
    GITHUB_REPOSITORY gabime/spdlog
    GIT_TAG v1.x
)

CPMAddPackage(
    NAME yaml-cpp
    GITHUB_REPOSITORY jbeder/yaml-cpp
    GIT_TAG master
)

# Create executable first
add_executable(${PROJECT_NAME} src/main.cpp)

get_property(KNOWN_TARGETS DIRECTORY . PROPERTY BUILDSYSTEM_TARGETS)
foreach(TARGET ${KNOWN_TARGETS})
    # Don't try to link the project to itself
    if(TARGET ${TARGET} AND NOT ${TARGET} STREQUAL ${PROJECT_NAME})
        # Check if it's a library before linking
        get_target_property(TARGET_TYPE ${TARGET} TYPE)
        if(TARGET_TYPE MATCHES "LIBRARY|INTERFACE_LIBRARY|OBJECT_LIBRARY")
            target_link_libraries(${PROJECT_NAME} PRIVATE ${TARGET})
        endif()
    endif()
endforeach()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    # Fast builds for development
    if(MSVC)
        target_compile_options(${PROJECT_NAME} PRIVATE /W4 /Od /Zi)
    else()
        target_compile_options(${PROJECT_NAME} PRIVATE 
            -Wall -Wextra -Wpedantic
            -O0        # No optimization
            -g         # Debug info
            -fno-omit-frame-pointer  # Better debugging
        )
    endif()
else()
    # Full optimization for release builds
    if(MSVC)
        target_compile_options(${PROJECT_NAME} PRIVATE 
            /W4 /O2 /GL    # Max optimization with whole program optimization
            /Gy            # Function-level linking
            /Gw            # Whole program global data optimization
            /guard:cf      # Control Flow Guard
            /Qpar          # Auto-parallelizer
        )
        target_link_options(${PROJECT_NAME} PRIVATE 
            /LTCG         # Link-time code generation
            /OPT:REF      # Eliminate unreferenced data
            /OPT:ICF      # Identical COMDAT folding
        )
    elseif(APPLE)
        target_compile_options(${PROJECT_NAME} PRIVATE 
            -Wall -Wextra -Wpedantic
            -O3                      # Max optimization
            -flto                    # Link-time optimization
            -march=native            # Optimize for current CPU
            -ffunction-sections      # Place each function in its own section
            -fdata-sections          # Place each data item in its own section
            -fno-exceptions          # Disable exceptions for better performance
            -fno-rtti               # Disable RTTI for better performance
            -ffast-math             # Aggressive math optimizations
        )
        target_link_options(${PROJECT_NAME} PRIVATE
            -flto                    # Link-time optimization
            -dead_strip              # macOS equivalent of --gc-sections
        )
    else()
        target_compile_options(${PROJECT_NAME} PRIVATE 
            -Wall -Wextra -Wpedantic
            -O3                      # Max optimization
            -flto                    # Link-time optimization
            -march=native            # Optimize for current CPU
            -ffunction-sections      # Place each function in its own section
            -fdata-sections          # Place each data item in its own section
            -fno-exceptions          # Disable exceptions for better performance
            -fno-rtti               # Disable RTTI for better performance
            -ffast-math             # Aggressive math optimizations
        )
        target_link_options(${PROJECT_NAME} PRIVATE
            -flto                    # Link-time optimization
            -Wl,--gc-sections       # Remove unused code (Linux)
        )
    endif()
endif()
