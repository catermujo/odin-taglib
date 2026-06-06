@echo off

setlocal EnableDelayedExpansion

set "VENDOR_WINDOWS_ARCH=%VSCMD_ARG_TGT_ARCH%"
if not defined VENDOR_WINDOWS_ARCH set "VENDOR_WINDOWS_ARCH=%PROCESSOR_ARCHITECTURE%"
if /I "%VENDOR_WINDOWS_ARCH%"=="AMD64" set "VENDOR_WINDOWS_ARCH=x64"
if /I "%VENDOR_WINDOWS_ARCH%"=="ARM64" set "VENDOR_WINDOWS_ARCH=arm64"
if /I "%VENDOR_WINDOWS_ARCH%"=="X86" set "VENDOR_WINDOWS_ARCH=x64"

set TAGLIB_REV=f4117f873c2cdc7b61553ae27df34364340a37ea
set vendor_dir=taglib
set binaries_dir=build_static
set output_dir=windows_%VENDOR_WINDOWS_ARCH%

if not exist %vendor_dir% (
    git clone --recurse-submodules --revision %TAGLIB_REV% https://github.com/taglib/taglib --depth=1 %vendor_dir% || exit /b 1
)

echo Configuring taglib (static)...
cmake -S %vendor_dir% -B %vendor_dir%\%binaries_dir% -A %VENDOR_WINDOWS_ARCH% -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=Release || exit /b 1

echo Building taglib (static)...
cmake --build %vendor_dir%\%binaries_dir% -j%NUMBER_OF_PROCESSORS% --config Release || exit /b 1

if not exist %output_dir% mkdir %output_dir%

set TAG_C_STATIC_LIB=
if exist %vendor_dir%\%binaries_dir%\bindings\c\Release\tag_c.lib set TAG_C_STATIC_LIB=%vendor_dir%\%binaries_dir%\bindings\c\Release\tag_c.lib
if not defined TAG_C_STATIC_LIB if exist %vendor_dir%\%binaries_dir%\bindings\c\tag_c.lib set TAG_C_STATIC_LIB=%vendor_dir%\%binaries_dir%\bindings\c\tag_c.lib
if not defined TAG_C_STATIC_LIB (
    echo ERROR: Could not find static tag_c.lib
    exit /b 1
)
copy /y %TAG_C_STATIC_LIB% %output_dir%\tag_c.lib >nul || exit /b 1

set TAG_STATIC_LIB=
if exist %vendor_dir%\%binaries_dir%\taglib\Release\tag.lib set TAG_STATIC_LIB=%vendor_dir%\%binaries_dir%\taglib\Release\tag.lib
if not defined TAG_STATIC_LIB if exist %vendor_dir%\%binaries_dir%\taglib\tag.lib set TAG_STATIC_LIB=%vendor_dir%\%binaries_dir%\taglib\tag.lib
if defined TAG_STATIC_LIB copy /y %TAG_STATIC_LIB% %output_dir%\tag.lib >nul || exit /b 1

echo Build completed successfully!
