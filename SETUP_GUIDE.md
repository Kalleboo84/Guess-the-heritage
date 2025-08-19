# Setup Guide for Java 21 + Gradle 8.5 + Flutter

This guide helps you configure your Guess the Heritage project for Java 21 and Gradle 8.5.

## Current Configuration Status

✅ **Gradle Version**: 8.5 (correctly configured)  
✅ **Flutter Version**: 3.35.1 (compatible)  
⚠️ **Java Version**: 21 (needs configuration updates)  
❌ **Android SDK**: Missing command-line tools  

## Issues Fixed

### 1. Java Version Compatibility
**Problem**: Your `android/app/build.gradle` was configured for Java 8, but you're using Java 21.

**Solution Applied**:
```gradle
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_17  // Updated from VERSION_1_8
    targetCompatibility = JavaVersion.VERSION_17  // Updated from VERSION_1_8
}
```

**Why Java 17?**: Flutter currently supports Java 17 as the maximum version. Java 21 is too new and may cause compatibility issues.

### 2. Gradle Properties
**Problem**: Missing Java home configuration for Gradle.

**Solution Applied**:
```properties
org.gradle.java.home=C:\\Program Files\\Android\\Android Studio\\jbr
org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
```

### 3. Android SDK Setup
**Problem**: Missing Android command-line tools and licenses.

**Solution**: Run the setup script and follow the steps below.

## Setup Steps

### Step 1: Run Android SDK Setup
```cmd
# Run the setup script
setup_android_sdk.bat
```

### Step 2: Restart Terminal
After running the setup script, close and reopen your PowerShell/Command Prompt.

### Step 3: Accept Android Licenses
```bash
flutter doctor --android-licenses
```
Accept all licenses when prompted (type 'y' for each).

### Step 4: Verify Setup
```bash
flutter doctor
```

You should see:
- ✅ Flutter
- ✅ Android Studio  
- ✅ Android SDK
- ✅ Connected devices

## Build Commands

### Quick Build (Recommended)
```powershell
# Use the PowerShell script
.\build_apk.ps1
```

### Manual Build
```bash
# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Or build split APKs
flutter build apk --split-per-abi --release
```

## Troubleshooting

### If you get Java version errors:
1. Make sure Android Studio is using Java 17 (not 21)
2. Check that `org.gradle.java.home` points to the correct JDK
3. Try using the Android Studio bundled JDK

### If you get Android SDK errors:
1. Run `setup_android_sdk.bat`
2. Restart terminal
3. Run `flutter doctor --android-licenses`
4. Accept all licenses

### If build fails with ProGuard errors:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

## Version Compatibility Matrix

| Component | Version | Status |
|-----------|---------|--------|
| Flutter | 3.35.1 | ✅ Compatible |
| Gradle | 8.5 | ✅ Compatible |
| Java | 17 (max) | ⚠️ Use Java 17, not 21 |
| Android SDK | Latest | ✅ Compatible |

## Notes

- **Java 21**: Too new for Flutter. Use Java 17 instead.
- **Gradle 8.5**: Fully compatible with Flutter 3.35.1
- **Android Studio**: Provides bundled JDK 17 that works perfectly
- **Split APKs**: Recommended for Play Store distribution

## Next Steps

1. Run `setup_android_sdk.bat`
2. Restart terminal
3. Run `flutter doctor --android-licenses`
4. Test build with `.\build_apk.ps1`

Your project should now build successfully with the optimized configuration!
