# C++ Project Build System

A minimal, robust C++ build system using CMake, ccache, and ninja for optimal performance.

## Requirements

- CMake 3.30+
- C++20 compiler (Clang)
- ccache (installed automatically)
- ninja (installed automatically)
- lld linker (installed automatically)

## Project Structure

```
cpx/
├── CMakeLists.txt      # CMake configuration
├── Makefile           # Build automation
├── scripts/
│   └── build.sh       # Build script with auto-installation
└── src/
    └── main.cpp       # Source files
```

## Build Commands

```bash
# Debug build
make dev

# Release build
make release

# Clean build directory
make clean
```

## Features

- Automatic dependency installation via CPM
- Compiler cache with ccache
- Parallel builds
- Cross-platform support (macOS, Linux)
- Debug/Release configurations
- LLD/Gold linker integration
- Automatic tool installation (ccache, ninja, lld)

## Build Output

Debug builds output: `dev_my_project`
Release builds output: `my_project`

## Build Performance

- Parallel compilation (4 cores)
- ccache for faster rebuilds (50GB cache)
- Ninja generator when available

## Customization

Modify `CMakeLists.txt` for:
- Project name: Change `PROJECT_NAME_VAR`
- C++ standard: Adjust `CMAKE_CXX_STANDARD`
- Dependencies: Add/remove `CPMAddPackage` entries
