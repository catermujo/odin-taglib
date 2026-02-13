#!/usr/bin/env bash

set -e

[ -d freetype ] || git clone --recurse-submodules --revision 23b6cd27ff19b70cbf98e058cd2cf0647d5284ff https://github.com/freetype/freetype --depth=1

echo "Building freetype.."
cd freetype
./autogen.sh
./configure --enable-shared=no --enable-year2038 --without-png --without-harfbuzz --without-bzip2 --without-brotli --without-gzip --with-zlib=no #--with-png=yes --with-harfbuzz=yes --with-librsvg=yes --with-brotli=yes # --with-bzip2=no

if [ $(uname -s) = 'Darwin' ]; then
    CPU=$(sysctl -n hw.ncpu)
    LIB_EXT=darwin
else
    CPU=$(nproc)
    LIB_EXT=linux
fi
# cmake -S . -B build \
#     -DFT_REQUIRE_ZLIB=TRUE \
#     -DFT_REQUIRE_PNG=TRUE \
#     -DFT_REQUIRE_HARFBUZZ=TRUE \
#     -DFT_REQUIRE_BROTLI=FALSE \
#     -DCMAKE_BUILD_TYPE=Release
# -DFT_DISABLE_ZLIB=TRUE \
# -DFT_DISABLE_PNG=TRUE \
# -DFT_DISABLE_HARFBUZZ=TRUE \

# -DFT_DISABLE_BZIP2=FALSE \

make -j$CPU

cp objs/.libs/libfreetype.a ../freetype.$LIB_EXT.a
