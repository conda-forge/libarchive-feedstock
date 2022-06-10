#!/bin/bash
set -euxo pipefail

mkdir build-${HOST} && pushd build-${HOST}

if [[ $target_platform =~ linux.* ]]; then
    USE_ICONV=-DENABLE_ICONV=FALSE
else
    USE_ICONV=-DENABLE_ICONV=TRUE
fi

cmake .. ${CMAKE_ARGS}                                 \
    -DCMAKE_PREFIX_PATH=$PREFIX                        \
    -DCMAKE_INSTALL_PREFIX=$PREFIX                     \
    -DCMAKE_BUILD_TYPE=Release                         \
    -DCMAKE_C_FLAGS_RELEASE="$CFLAGS"                  \
    -DENABLE_ZLIB=TRUE                                 \
    -DENABLE_BZIP2=TRUE                                \
    -DBZIP2_ROOT=$PREFIX/lib                           \
    -DENABLE_LZ4=TRUE                                  \
    -DENABLE_LZMA=TRUE                                 \
    -DENABLE_LZO=TRUE                                  \
    -DENABLE_ZSTD=TRUE                                 \
    -DENABLE_CNG=FALSE                                 \
    -DENABLE_NETTLE=FALSE                              \
    -DENABLE_XML2=TRUE                                 \
    -DENABLE_EXPAT=FALSE                               \
    $USE_ICONV

make -j${CPU_COUNT}
make install


# backwards compatibility with artifacts <= version=3.5.2,build=2
MAJOR_VERSION=$(echo $PKG_VERSION | cut -d. -f1)
MINOR_VERSION=$(echo $PKG_VERSION | cut -d. -f2)
MINOR_PATCH_VERSION=$(echo $PKG_VERSION | cut -d. -f2-)
# Check upstream CMakeLists.txt for details
if [[ $MAJOR_VERSION == 3 ]];
    SONAME_BASE=13
else
    echo "MAJOR_VERSION $MAJOR_VERSION not recognized. Update build.sh to specify its SONAME_BASE"
    exit 1
fi
SONAME_VERSION=$(( $SONAME_BASE + $MINOR_VERSION ))
ln -s "$PREFIX/lib/libarchive.so.$SONAME_VERSION" "$PREFIX/lib/libarchive.so.$SONAME_BASE.$MINOR_PATCH_VERSION"