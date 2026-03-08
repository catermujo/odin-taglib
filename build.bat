@echo off

setlocal EnableDelayedExpansion

set TAGLIB_REV=f4117f873c2cdc7b61553ae27df34364340a37ea
set vendor_dir=taglib
set binaries_dir=build

if not exist %vendor_dir% (
    git clone --recurse-submodules --revision %TAGLIB_REV% https://github.com/taglib/taglib --depth=1 %vendor_dir% || exit /b 1
)

echo Configuring taglib (shared)...
cmake -S %vendor_dir% -B %vendor_dir%\%binaries_dir% -A x64 -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release || exit /b 1

echo Building taglib (shared)...
cmake --build %vendor_dir%\%binaries_dir% -j%NUMBER_OF_PROCESSORS% --config Release || exit /b 1

if not exist windows mkdir windows

set TAG_C_LIB=
if exist %vendor_dir%\%binaries_dir%\bindings\c\Release\tag_c.lib set TAG_C_LIB=%vendor_dir%\%binaries_dir%\bindings\c\Release\tag_c.lib
if not defined TAG_C_LIB if exist %vendor_dir%\%binaries_dir%\bindings\c\tag_c.lib set TAG_C_LIB=%vendor_dir%\%binaries_dir%\bindings\c\tag_c.lib
if not defined TAG_C_LIB (
    echo ERROR: Could not find tag_c import library
    exit /b 1
)
copy /y %TAG_C_LIB% windows\tag_c_shared.lib >nul || exit /b 1

set TAG_C_DLL=
if exist %vendor_dir%\%binaries_dir%\bindings\c\Release\tag_c.dll set TAG_C_DLL=%vendor_dir%\%binaries_dir%\bindings\c\Release\tag_c.dll
if not defined TAG_C_DLL if exist %vendor_dir%\%binaries_dir%\bindings\c\tag_c.dll set TAG_C_DLL=%vendor_dir%\%binaries_dir%\bindings\c\tag_c.dll
if defined TAG_C_DLL copy /y %TAG_C_DLL% windows\tag_c.dll >nul || exit /b 1

set TAG_LIB=
if exist %vendor_dir%\%binaries_dir%\taglib\Release\tag.lib set TAG_LIB=%vendor_dir%\%binaries_dir%\taglib\Release\tag.lib
if not defined TAG_LIB if exist %vendor_dir%\%binaries_dir%\taglib\tag.lib set TAG_LIB=%vendor_dir%\%binaries_dir%\taglib\tag.lib
if defined TAG_LIB copy /y %TAG_LIB% windows\tag_shared.lib >nul || exit /b 1

echo Build completed successfully!
