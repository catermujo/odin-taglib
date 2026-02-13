#!/usr/bin/env bash

set -e

[ -d taglib ] || git clone --recurse-submodules https://github.com/taglib/taglib --depth=1

echo "Building taglib.."
cd taglib
cmake -S . -B build \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_BUILD_TYPE=Release

if [ $(uname -s) = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
    OS_EXT=darwin
    LIB_EXT=dylib
else
    CPU=$(nproc)
    OS_EXT=linux
    LIB_EXT=so
fi
make -C build -j$CPU

cp build/taglib/*.a ../libtag.$OS_EXT.a
cp build/bindings/c/*.a ../libtag_c.$OS_EXT.a
cp build/bindings/c/*.$LIB_EXT ../
