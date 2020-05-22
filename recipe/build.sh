#!/bin/bash

declare -a _EXTRA_OPTS=()
if [[ ${target_platform} == osx-64 ]]; then
  _EXTRA_OPTS+=(--without-openssl)
else
  _EXTRA_OPTS+=(--with-openssl)
fi

autoreconf -vfi
mkdir build-${HOST} || true
pushd build-${HOST}
  ${SRC_DIR}/configure --prefix=${PREFIX}  \
                       --with-zlib  \
                       --with-bz2lib  \
                       --with-iconv  \
                       --with-lz4  \
                       --with-lzma  \
                       --without-lzo2  \
                       --with-zstd  \
                       --without-cng  \
                       --without-nettle  \
                       --with-xml2  \
                       "${_EXTRA_OPTS[@]}" \
                       --without-expat > config.log 2>&1 | tee
  make -j${CPU_COUNT} ${VERBOSE_AT}
  make install
popd
