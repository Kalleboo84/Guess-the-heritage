# Guess the Heritage - APK Builder (PowerShell)
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Guess the Heritage - APK Builder" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter not found"
    }
    Write-Host "Flutter version:" -ForegroundColor Green
    Write-Host $flutterVersion
    Write-Host ""
} catch {
    Write-Host "ERROR: Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Java version
Write-Host "Checking Java configuration..." -ForegroundColor Yellow
flutter doctor -v | Select-String "Java version" | ForEach-Object {
    Write-Host "Found: $_" -ForegroundColor Green
}
Write-Host ""

# Get dependencies
Write-Host "Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to get dependencies" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "Choose build type:" -ForegroundColor Cyan
Write-Host "1. Release APK (single file)" -ForegroundColor White
Write-Host "2. Release APK (split by architecture - smaller files)" -ForegroundColor White
Write-Host "3. Debug APK (for testing)" -ForegroundColor White
Write-Host "4. Clean and build release APK" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-4)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Building release APK..." -ForegroundColor Yellow
        flutter build apk --release
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host ""
        Write-Host "APK built successfully!" -ForegroundColor Green
        Write-Host "Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    }
    "2" {
        Write-Host ""
        Write-Host "Building split APKs..." -ForegroundColor Yellow
        flutter build apk --split-per-abi --release
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host ""
        Write-Host "Split APKs built successfully!" -ForegroundColor Green
        Write-Host "Location: build\app\outputs\flutter-apk\" -ForegroundColor Cyan
        Write-Host "Files:" -ForegroundColor White
        Write-Host "  - app-arm64-v8a-release.apk (64-bit ARM)" -ForegroundColor Gray
        Write-Host "  - app-armeabi-v7a-release.apk (32-bit ARM)" -ForegroundColor Gray
        Write-Host "  - app-x86_64-release.apk (64-bit x86)" -ForegroundColor Gray
    }
    "3" {
        Write-Host ""
        Write-Host "Building debug APK..." -ForegroundColor Yellow
        flutter build apk --debug
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host ""
        Write-Host "Debug APK built successfully!" -ForegroundColor Green
        Write-Host "Location: build\app\outputs\flutter-apk\app-debug.apk" -ForegroundColor Cyan
    }
    "4" {
        Write-Host ""
        Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
        flutter clean
        Write-Host ""
        Write-Host "Getting dependencies..." -ForegroundColor Yellow
        flutter pub get
        Write-Host ""
        Write-Host "Building release APK..." -ForegroundColor Yellow
        flutter build apk --release
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit 1
        }
        Write-Host ""
        Write-Host "APK built successfully!" -ForegroundColor Green
        Write-Host "Location: build\app\outputs\flutter-apk\app-release.apk" -ForegroundColor Cyan
    }
    default {
        Write-Host "Invalid choice. Please run the script again." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit 1
    }
}

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
