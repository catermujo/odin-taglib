#!/usr/bin/env bash

set -euo pipefail

TAGLIB_REV="f4117f873c2cdc7b61553ae27df34364340a37ea"
[ -d taglib ] || git clone --recurse-submodules --revision "$TAGLIB_REV" https://github.com/taglib/taglib --depth=1

echo "Building taglib (static).."
cd taglib
cmake -S . -B build_static \
    -DBUILD_SHARED_LIBS=OFF \
    -DCMAKE_BUILD_TYPE=Release

if [ $(uname -s) = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
    OS_EXT=darwin
else
    CPU=$(nproc)
    OS_EXT=linux
fi
cmake --build build_static -j"$CPU" --config Release

cp build_static/taglib/*.a ../libtag."$OS_EXT".a
cp build_static/bindings/c/*.a ../libtag_c."$OS_EXT".a
