cmake_minimum_required(VERSION 3.20)

project(test-libarchive LANGUAGES C)

add_executable(test-libarchive test.c)

find_path(libarchive_INCLUDE_DIR NAMES archive.h)
find_library(libarchive_LIBRARY NAMES "${LIB_NAME}")
target_link_libraries(test-libarchive PRIVATE ${libarchive_LIBRARY})
target_include_directories(test-libarchive PRIVATE ${libarchive_INCLUDE_DIR})

enable_testing()
add_test(NAME test-libarchive COMMAND test-libarchive)
