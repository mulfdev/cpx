#!/bin/bash
set -e

# Get build type from argument, default to Debug
BUILD_TYPE=${1:-Debug}

# Platform-specific ccache and ninja installation
if ! command -v ccache &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ccache ninja
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y ccache ninja-build
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy ccache ninja
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y ccache ninja-build
    else
        echo "Please install ccache and ninja manually for your system"
    fi
fi

# Configure ccache
ccache --max-size=50G
ccache --set-config=sloppiness=file_macro,time_macros,locale

# Create build directory
mkdir -p build && cd build

# Configure and build with Ninja if available
if command -v ninja &> /dev/null; then
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
    cmake --build .
else
    cmake .. -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
    cmake --build .
fi

# Show ccache statistics after build
echo "ccache statistics:"
ccache -s

echo "Build completed in ${BUILD_TYPE} mode"
