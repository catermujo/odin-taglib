#!/usr/bin/env bash

set -euo pipefail

TAGLIB_REV="f4117f873c2cdc7b61553ae27df34364340a37ea"

if [ $(uname -s) = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
else
    CPU=$(nproc)
fi

[ -d taglib ] || git clone --recurse-submodules --revision "$TAGLIB_REV" https://github.com/taglib/taglib --depth=1

cd taglib
emcmake cmake -S . -B build_wasm \
    -DBUILD_SHARED_LIBS=OFF \
    -DWITH_ZLIB=OFF \
    -DCMAKE_BUILD_TYPE=Release

cmake --build build_wasm -j"$CPU" --config Release

cp build_wasm/taglib/*.a ../libtag.wasm.a
cp build_wasm/bindings/c/*.a ../libtag_c.wasm.a
