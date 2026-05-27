#!/usr/bin/env bash

set -euo pipefail

TAGLIB_REV="f4117f873c2cdc7b61553ae27df34364340a37ea"

if [ $(uname -s) = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
else
    CPU=$(nproc)
fi

clone_at_revision() {
    local dir="$1"
    local revision="$2"
    local remote="$3"
    shift 3
    [ -d "$dir" ] && return
    git clone "$@" "$remote" "$dir"
    if ! git -C "$dir" checkout --detach "$revision"; then
        git -C "$dir" fetch origin "$revision"
        git -C "$dir" checkout --detach FETCH_HEAD
    fi
    if [ -f "$dir/.gitmodules" ]; then
        git -C "$dir" submodule update --init --recursive
    fi
}

clone_at_revision taglib "$TAGLIB_REV" https://github.com/taglib/taglib --recurse-submodules --depth=1

cd taglib
emcmake cmake -S . -B build_wasm \
    -DBUILD_SHARED_LIBS=OFF \
    -DWITH_ZLIB=OFF \
    -DCMAKE_BUILD_TYPE=Release

cmake --build build_wasm -j"$CPU" --config Release

cp build_wasm/taglib/*.a ../libtag.wasm.a
cp build_wasm/bindings/c/*.a ../libtag_c.wasm.a
