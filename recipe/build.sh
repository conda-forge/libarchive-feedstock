#!/bin/bash

# Needed for the tests.
export CFLAGS="-std=c99 ${CFLAGS}"

if [[ ${HOST} =~ .*darwin.* ]]; then
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
fi

autoreconf -vfi
./configure --prefix=${PREFIX}  \
            --with-expat        \
            --without-nettle    \
            --without-lz4       \
            --without-lzmadec   \
            --without-xml2
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
