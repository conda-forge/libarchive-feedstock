#!/bin/bash

# Needed for the tests.
export CFLAGS="-std=c99 ${CFLAGS}"

if [[ ${HOST} =~ .*darwin.* ]]; then
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib"
elif [[ ${HOST} =~ .*linux.* ]]; then
  export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"
  export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
fi

# Prevent libtool overlinking icu into libarchive.so
# -Wl,as-needed is not fixing this, maybe due to:
# https://sigquit.wordpress.com/2011/02/16/why-asneeded-doesnt-work-as-expected-for-your-libraries-on-your-autotools-project/
# rm ${PREFIX}/lib/libxml2.la

autoreconf -vfi
./configure --prefix=${PREFIX}  \
            --with-zlib         \
            --with-bz2lib       \
            --with-iconv        \
            --with-lz4          \
            --with-lzma         \
            --with-lzo2         \
            --without-cng       \
            --with-openssl      \
            --without-nettle    \
            --with-xml2         \
            --without-expat
make -j${CPU_COUNT} ${VERBOSE_AT}
make install
