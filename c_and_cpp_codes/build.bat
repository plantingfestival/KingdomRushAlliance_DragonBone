@echo off
setlocal enabledelayedexpansion

:: ============================================================
::  Build Script: Windows DLL + Android SO
:: ============================================================

set "PROJECT_DIR=%~dp0"
cd /d "%PROJECT_DIR%"

set "OUT_DIR=%PROJECT_DIR%..\dll_and_so_files"

:: ------------------------------------------------------------
::  Toolchain paths (MODIFY THESE!)
:: ------------------------------------------------------------
set "CMAKE_BIN=cmake"
set "NINJA_BIN=D:\Portable\cmake-4.3.1-windows-x86_64\bin\ninja.exe"
set "ANDROID_NDK=E:\AppData\Android\Sdk\ndk\android-ndk-r29"

set "BUILD_WIN=%PROJECT_DIR%build-win"
set "BUILD_ANDROID=%PROJECT_DIR%build-android"

set "WIN_RESULT=FAIL"
set "ANDROID_RESULT=FAIL"

:: ------------------------------------------------------------
::  Interactive selection: Release or Debug
:: ------------------------------------------------------------
echo.
echo Select build type:
echo [1] Release
echo [2] Debug
echo.
choice /c 12 /n /m "Enter your choice (1 or 2): "

if errorlevel 2 (
    set "BUILD_TYPE=Debug"
) else (
    set "BUILD_TYPE=Release"
)

echo Build type: %BUILD_TYPE%

:: ============================================================
::  Stage 1: Build Windows DLLs
:: ============================================================
echo.
echo ============================================================
echo  [1/2] Building Windows DLLs (%BUILD_TYPE%)
echo ============================================================

if exist "%BUILD_WIN%" (
    echo [CLEAN] Removing old build-win...
    rmdir /s /q "%BUILD_WIN%"
)

mkdir "%BUILD_WIN%"
cd "%BUILD_WIN%"

echo [CONFIG] Configuring Windows build...
%CMAKE_BIN% .. -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=%BUILD_TYPE%

if errorlevel 1 (
    echo [ERROR] Windows CMake configuration failed!
    cd ..
    goto :build_android
)

echo [BUILD] Building Windows DLLs...
%CMAKE_BIN% --build . -j %NUMBER_OF_PROCESSORS%

if errorlevel 1 (
    echo [ERROR] Windows build failed!
) else (
    echo [OK] Windows DLLs generated successfully.
    set "WIN_RESULT=OK"
)

cd ..

:: ============================================================
::  Stage 2: Build Android SOs
:: ============================================================
:build_android
echo.
echo ============================================================
echo  [2/2] Building Android .so files (%BUILD_TYPE%)
echo ============================================================

if exist "%BUILD_ANDROID%" (
    echo [CLEAN] Removing old build-android...
    rmdir /s /q "%BUILD_ANDROID%"
)

mkdir "%BUILD_ANDROID%"
cd "%BUILD_ANDROID%"

echo [CONFIG] Configuring Android build...
%CMAKE_BIN% .. ^
    -G "Ninja" ^
    -DCMAKE_MAKE_PROGRAM="%NINJA_BIN%" ^
    -DCMAKE_TOOLCHAIN_FILE="%ANDROID_NDK%/build/cmake/android.toolchain.cmake" ^
    -DANDROID_ABI=arm64-v8a ^
    -DCMAKE_BUILD_TYPE=%BUILD_TYPE%

if errorlevel 1 (
    echo [ERROR] Android CMake configuration failed!
    cd ..
    goto :summary
)

echo [BUILD] Building Android SOs...
%CMAKE_BIN% --build . --target debugC myExtension render_worker search_worker

if errorlevel 1 (
    echo [ERROR] Android build failed!
) else (
    echo [OK] Android .so files generated successfully.
    set "ANDROID_RESULT=OK"
)

cd ..

:: ============================================================
::  Summary
:: ============================================================
:summary
echo.
echo ============================================================
echo  BUILD SUMMARY
echo ============================================================
echo Windows:  !WIN_RESULT!
echo Android:  !ANDROID_RESULT!
echo.
echo Output directory: %OUT_DIR%
echo.

if "!WIN_RESULT!"=="OK" (
    echo Windows DLLs:
    dir /b "%OUT_DIR%\*.dll" 2>nul
    echo.
)
if "!ANDROID_RESULT!"=="OK" (
    echo Android SOs:
    dir /b "%OUT_DIR%\*.so" 2>nul
    echo.
)

pause
exit /b 0

endlocal