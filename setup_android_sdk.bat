@echo off
echo ========================================
echo    Android SDK Setup Helper
echo ========================================
echo.

REM Check if ANDROID_HOME is set
if "%ANDROID_HOME%"=="" (
    echo Setting ANDROID_HOME environment variable...
    setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"
    echo ANDROID_HOME set to: C:\Users\%USERNAME%\AppData\Local\Android\Sdk
    echo.
    echo Please restart your terminal/PowerShell after this script completes.
    echo.
) else (
    echo ANDROID_HOME is already set to: %ANDROID_HOME%
    echo.
)

REM Check if Android Studio SDK path exists
if exist "C:\Program Files\Android\Android Studio\sdk" (
    echo Found Android Studio SDK at: C:\Program Files\Android\Android Studio\sdk
    setx ANDROID_HOME "C:\Program Files\Android\Android Studio\sdk"
    echo Updated ANDROID_HOME to use Android Studio SDK
    echo.
) else if exist "C:\Users\%USERNAME%\AppData\Local\Android\Sdk" (
    echo Found Android SDK at: C:\Users\%USERNAME%\AppData\Local\Android\Sdk
    echo.
) else (
    echo WARNING: Android SDK not found in common locations.
    echo Please install Android Studio or download the command-line tools.
    echo.
)

echo Next steps:
echo 1. Restart your terminal/PowerShell
echo 2. Run: flutter doctor --android-licenses
echo 3. Accept all licenses when prompted
echo 4. Run: flutter doctor
echo.

pause
