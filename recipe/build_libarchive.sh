#!/bin/bash
set -euxo pipefail

mkdir build-${HOST} && pushd build-${HOST}
${SRC_DIR}/configure --prefix=${PREFIX}  \
                     --with-zlib         \
                     --with-bz2lib       \
                     ${USE_ICONV}        \
                     --with-lz4          \
                     --with-lzma         \
                     --with-lzo2         \
                     --with-zstd         \
                     --without-cng       \
                     --with-openssl      \
                     --without-nettle    \
                     --with-xml2         \
                     --without-expat

make -j${CPU_COUNT} ${VERBOSE_AT}
make install

# see https://github.com/conda-forge/libarchive-feedstock/issues/69
if [[ $target_platform =~ linux.* ]]; then
    # backwards compatibility with artifacts <= version=3.5.2,build=2
    MAJOR_VERSION=$(echo $PKG_VERSION | cut -d. -f1)
    MINOR_VERSION=$(echo $PKG_VERSION | cut -d. -f2)
    MINOR_PATCH_VERSION=$(echo $PKG_VERSION | cut -d. -f2-)
    # Check upstream CMakeLists.txt for details
    if [[ $MAJOR_VERSION == 3 ]]; then
        SONAME_BASE=13
    else
        echo "MAJOR_VERSION $MAJOR_VERSION not recognized. Update build.sh to specify its SONAME_BASE"
        exit 1
    fi
    SONAME_VERSION=$(( $SONAME_BASE + $MINOR_VERSION ))
    ln -s "$PREFIX/lib/libarchive.so.$SONAME_VERSION" "$PREFIX/lib/libarchive.so.$SONAME_BASE.$MINOR_PATCH_VERSION"
fi
