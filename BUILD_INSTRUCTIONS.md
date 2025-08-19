# Build Instructions for Guess the Heritage

This document provides comprehensive instructions for building the APK locally for the Guess the Heritage Flutter app.

## Prerequisites

### 1. Flutter SDK
- Install Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install)
- Ensure Flutter is in your PATH
- Run `flutter doctor` to verify installation

### 2. Android Development Environment
- Install Android Studio or Android SDK
- Install Android SDK Build-Tools
- Set up Android SDK environment variables

### 3. Java Development Kit (JDK)
- Install JDK 8 or higher
- Set JAVA_HOME environment variable

## Quick Build Methods

### Method 1: Using Build Scripts (Recommended for Windows)

#### Option A: PowerShell Script
```powershell
# Run the PowerShell build script
.\build_apk.ps1
```

#### Option B: Batch Script
```cmd
# Run the batch build script
build_apk.bat
```

Both scripts will:
- Check Flutter installation
- Get dependencies
- Provide build options
- Build the APK
- Show the output location

### Method 2: Flutter CLI Commands

#### Basic Release Build
```bash
# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release
```

#### Split APKs (Recommended for Play Store)
```bash
# Build separate APKs for different architectures
flutter build apk --split-per-abi --release
```

#### Debug Build (for testing)
```bash
# Build debug APK
flutter build apk --debug
```

#### Clean Build
```bash
# Clean previous builds and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

### Method 3: IDE Integration

#### Android Studio
1. Open the project in Android Studio
2. Open Terminal in Android Studio
3. Run: `flutter build apk --release`

#### VS Code
1. Open the project in VS Code
2. Open Terminal (Ctrl+`)
3. Run: `flutter build apk --release`

## Build Output Locations

### Single APK
- **Location**: `build/app/outputs/flutter-apk/app-release.apk`
- **Size**: ~50-80 MB (includes all architectures)

### Split APKs
- **Location**: `build/app/outputs/flutter-apk/`
- **Files**:
  - `app-arm64-v8a-release.apk` (~25-35 MB) - 64-bit ARM devices
  - `app-armeabi-v7a-release.apk` (~20-30 MB) - 32-bit ARM devices  
  - `app-x86_64-release.apk` (~25-35 MB) - 64-bit x86 devices

## Build Configuration

### Optimizations Enabled
The project includes the following optimizations for release builds:

1. **Code Shrinking**: Removes unused code
2. **Resource Shrinking**: Removes unused resources
3. **ProGuard Rules**: Protects against obfuscation issues
4. **Split APKs**: Reduces download size per device

### Custom Build Configuration
The `android/app/build.gradle` file includes:
- ProGuard configuration for code obfuscation
- Split APK configuration for different architectures
- Optimized build settings for release builds

## Troubleshooting

### Common Issues

#### 1. Flutter not found
```bash
# Add Flutter to PATH or install Flutter
flutter doctor
```

#### 2. Dependencies not found
```bash
# Get dependencies
flutter pub get
```

#### 3. Build fails with ProGuard errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release
```

#### 4. Memory issues during build
```bash
# Increase Gradle memory in android/gradle.properties
org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError
```

#### 5. Signing issues
The current configuration uses debug signing. For production:
1. Create a keystore
2. Configure signing in `android/app/build.gradle`
3. Add keystore properties to `android/key.properties`

### Build Performance Tips

1. **Use SSD**: Store project on SSD for faster builds
2. **Increase Memory**: Set higher Gradle memory limits
3. **Parallel Builds**: Enable parallel execution in Gradle
4. **Incremental Builds**: Use `flutter build apk --release` without clean for faster rebuilds

## Testing the APK

### Install on Device
```bash
# Install directly to connected device
flutter install --release

# Or manually install APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Test on Emulator
```bash
# Start emulator first, then install
flutter install --release
```

## Distribution

### For Personal Use
- Use the single APK file
- Share via file sharing or direct installation

### For Play Store
- Use split APKs for smaller download sizes
- Sign with release keystore
- Follow Play Store guidelines

### For Internal Testing
- Use debug APK for faster builds
- Share via internal distribution channels

## Version Management

The app version is managed in:
- `pubspec.yaml`: `version: 1.0.0+5`
- `android/app/build.gradle`: Uses Flutter version from pubspec.yaml

To update version:
1. Update `version` in `pubspec.yaml`
2. Rebuild APK
3. Version code will auto-increment

## Support

For build issues:
1. Check Flutter installation: `flutter doctor`
2. Verify dependencies: `flutter pub get`
3. Clean and rebuild: `flutter clean && flutter build apk --release`
4. Check Android SDK setup
5. Review build logs for specific errors

