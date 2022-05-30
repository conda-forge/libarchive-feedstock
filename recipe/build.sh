#!/bin/bash

# Isolate the build.
mkdir -p build_c
cd build_c || exit 1

# Generate the build files.
echo "Generating the build files."

declare -a CMAKE_EXTRA_ARGS=()
if [[ ${target_platform} == osx-64 ]]; then
  CMAKE_EXTRA_ARGS+=(-DENABLE_OPENSSL=FALSE)
else
  CMAKE_EXTRA_ARGS+=(-DENABLE_OPENSSL=TRUE)
fi

cmake .. ${CMAKE_ARGS}                                   \
      -GNinja                                            \
      -DCMAKE_PREFIX_PATH=$PREFIX                        \
      -DCMAKE_INSTALL_PREFIX=$PREFIX             \
      -DCMAKE_BUILD_TYPE=Release                         \
      -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS:BOOL=FALSE \
      -DCMAKE_C_FLAGS_RELEASE="$CFLAGS"                  \
      -DENABLE_ZLIB=TRUE                                 \
      -DENABLE_BZIP2=TRUE                                \
      -DBZIP2_ROOT=$PREFIX/lib                           \
      -DENABLE_ICONV=TRUE                                \
      -DENABLE_LZ4=TRUE                                  \
      -DENABLE_LZMA=TRUE                                 \
      -DENABLE_LZO=FALSE                                 \
      -DENABLE_ZSTD=TRUE                                 \
      -DENABLE_CNG=FALSE                                 \
      -DENABLE_NETTLE=FALSE                              \
      -DENABLE_XML2=TRUE                                 \
      -DENABLE_EXPAT=FALSE                               \
      "${CMAKE_EXTRA_ARGS[@]}"

# Build.
echo "Building..."
ninja || exit 1 

# Perform tests.
if [[ ${target_platform} ~= "*linux-64*" || ${target_platform} ~= "*s390x*" || ${target_platform} ~= "*aarch64*" ]]; then
  echo "Testing..."
  ctest -VV --output-on-failure || exit 1
else
  echo "Skip testing on ""${target_platform}"
fi

# Installing
echo "Installing..."
ninja install || exit 1

# Error free exit!
echo "Error free exit!"
