#!/bin/bash

# FIXME: This is a hack to make sure the environment is activated.
# The reason this is required is due to the conda-build issue
# mentioned below.
#
# https://github.com/conda/conda-build/issues/910
#
source activate "${CONDA_DEFAULT_ENV}"

# Needed for the tests.
export CFLAGS="-std=c99 ${CFLAGS}"

if [ "`uname`" == 'Darwin' ]
then
    export LIBRARY_SEARCH_VAR=DYLD_FALLBACK_LIBRARY_PATH
else
    export LIBRARY_SEARCH_VAR=LD_LIBRARY_PATH
fi


aclocal
autoconf
autoreconf -ivf
./configure --prefix=${PREFIX} \
            --with-expat \
            --without-nettle \
            --without-lz4 \
            --without-lzmadec \
            --without-xml2
make -j${NUM_CPUS}
#eval ${LIBRARY_SEARCH_VAR}="${PREFIX}/lib" make check
make install

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/toolchain_${CHANGE}.sh"
done
