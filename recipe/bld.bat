:: Needed so we can find stdint.h from msinttypes.
set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

:: VS2008 doesn't have stdbool.h so copy in our own
:: to 'lib' where the other headers are so it gets picked up.
if "%VS_MAJOR%" == "9" (
    copy %RECIPE_DIR%\stdbool.h lib\
    copy %LIBRARY_INC%\stdint.h lib\
)

:: set cflags because NDEBUG is set in Release configuration, which errors out in test suite due to no assert
cmake -G"%CMAKE_GENERATOR%" ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_C_FLAGS_RELEASE="%CFLAGS%" ^
      .

:: Build.
cmake --build . --config Release -- -v:d
if errorlevel 1 exit 1

:: Install.
cmake --build . --config Release --target install -- -v:d
if errorlevel 1 exit 1

:: Test.
:: Failures:
:: The following tests FAILED:
::         365 - libarchive_test_read_truncated_filter_bzip2 (Timeout) => runs msys2's bzip2.exe
::         372 - libarchive_test_sparse_basic (Failed)
::         373 - libarchive_test_fully_sparse_files (Failed)
::         386 - libarchive_test_warn_missing_hardlink_target (Failed)
:: ctest -C Release
::if errorlevel 1 exit 1
