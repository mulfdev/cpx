#!/bin/bash
set -e

BUILD_TYPE=${1:-Debug}

if ! command -v ccache &> /dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install ccache ninja lld
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y ccache ninja-build lld
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy ccache ninja lld
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y ccache ninja-build lld
    else
        echo "Please install ccache, ninja, and lld manually"
        exit 1
    fi
fi

export ASAN_OPTIONS=alloc_dealloc_mismatch=0
ccache --max-size=50G
ccache --set-config=sloppiness=file_macro,time_macros,locale

mkdir -p build && cd build

if command -v ninja &> /dev/null; then
    cmake .. -GNinja -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
    cmake --build .
else
    cmake .. -DCMAKE_BUILD_TYPE=${BUILD_TYPE}
    cmake --build .
fi

echo "ccache statistics:"
ccache -s

echo "Build completed in ${BUILD_TYPE} mode"
