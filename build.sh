#!/usr/bin/env bash

set -e

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

clone_at_revision taglib f4117f873c2cdc7b61553ae27df34364340a37ea https://github.com/taglib/taglib --recurse-submodules --depth=1

linux_arch_dir() {
    case "$(uname -m)" in
        x86_64 | amd64) echo "linux_x64" ;;
        aarch64 | arm64) echo "linux_arm64" ;;
        *) echo "linux_$(uname -m)" ;;
    esac
}

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
    ARCH_DIR=$(linux_arch_dir)
fi
make -C build -j$CPU

if [ $(uname -s) = 'Darwin' ]; then
    cp build/taglib/*.a ../libtag.$OS_EXT.a
    cp build/bindings/c/*.a ../libtag_c.$OS_EXT.a
    cp build/bindings/c/*.$LIB_EXT ../
else
    mkdir -p "../$ARCH_DIR"
    cp build/taglib/*.a "../$ARCH_DIR/libtag.$OS_EXT.a"
    cp build/bindings/c/*.a "../$ARCH_DIR/libtag_c.$OS_EXT.a"
    cp build/bindings/c/*.$LIB_EXT "../$ARCH_DIR"/
fi
