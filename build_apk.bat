@echo off
echo ========================================
echo    Guess the Heritage - APK Builder
echo ========================================
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo Flutter version:
flutter --version
echo.

REM Get dependencies
echo Getting dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo Choose build type:
echo 1. Release APK (single file)
echo 2. Release APK (split by architecture - smaller files)
echo 3. Debug APK (for testing)
echo 4. Clean and build release APK
echo.

set /p choice="Enter your choice (1-4): "

if "%choice%"=="1" (
    echo.
    echo Building release APK...
    flutter build apk --release
    if errorlevel 1 (
        echo ERROR: Build failed
        pause
        exit /b 1
    )
    echo.
    echo APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
)

if "%choice%"=="2" (
    echo.
    echo Building split APKs...
    flutter build apk --split-per-abi --release
    if errorlevel 1 (
        echo ERROR: Build failed
        pause
        exit /b 1
    )
    echo.
    echo Split APKs built successfully!
    echo Location: build\app\outputs\flutter-apk\
    echo Files:
    echo   - app-arm64-v8a-release.apk (64-bit ARM)
    echo   - app-armeabi-v7a-release.apk (32-bit ARM)
    echo   - app-x86_64-release.apk (64-bit x86)
)

if "%choice%"=="3" (
    echo.
    echo Building debug APK...
    flutter build apk --debug
    if errorlevel 1 (
        echo ERROR: Build failed
        pause
        exit /b 1
    )
    echo.
    echo Debug APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-debug.apk
)

if "%choice%"=="4" (
    echo.
    echo Cleaning previous builds...
    flutter clean
    echo.
    echo Getting dependencies...
    flutter pub get
    echo.
    echo Building release APK...
    flutter build apk --release
    if errorlevel 1 (
        echo ERROR: Build failed
        pause
        exit /b 1
    )
    echo.
    echo APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-release.apk
)

echo.
echo Build completed successfully!
echo.
pause

