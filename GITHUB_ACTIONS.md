# GitHub Actions & API Setup

This document describes the GitHub Actions workflows and API setup for the Guess the Heritage project.

## Overview

The project includes several GitHub Actions workflows that handle:
- **Building Android APKs** (debug and release)
- **Processing data via APIs** (Wikimedia Commons integration)
- **Continuous Integration** (testing and validation)
- **Icon generation** (Flutter launcher icons)

## Workflows

### 1. `flutter-android.yml` - Main Android Build
**Trigger:** Push to main, manual dispatch  
**Purpose:** Builds both debug and release APKs

Key features:
- Uses Java 17 (compatible with Flutter requirements)
- Flutter 3.24.3 for consistency
- Dependency caching for faster builds
- Generates launcher icons (optional)
- Uploads APK artifacts

```bash
# Manually trigger with:
gh workflow run flutter-android.yml
```

### 2. `data-processing.yml` - API Data Processing
**Trigger:** Manual dispatch  
**Purpose:** Processes heritage data using Wikimedia Commons APIs

Features:
- Choice of scripts: `fill_commons_metadata`, `fill_commons_images`, or both
- Configurable overwrite option
- Installs all required Python dependencies
- Validates input/output files
- Auto-commits results

```bash
# Manually trigger with script choice:
gh workflow run data-processing.yml -f script_choice=both -f overwrite=true
```

### 3. `ci.yml` - Continuous Integration
**Trigger:** Push/PR to main  
**Purpose:** Comprehensive testing and validation

Includes:
- Flutter tests and code analysis
- Python script validation
- Dependency checks
- Code formatting verification

### 4. `fill-images.yml` - Legacy Image Filling
**Trigger:** Manual dispatch  
**Purpose:** Fills Commons images using the tool script

Enhanced with:
- Better dependency management
- Input/output validation
- Error handling

### 5. `generate-icons.yml` - Icon Generation
**Trigger:** Manual dispatch, changes to icons/pubspec  
**Purpose:** Generates Flutter launcher icons

### 6. Android Workflows
- `android-recreate.yml` - Recreates Android project structure
- `migrate-android-v2.yml` - Migrates to Android v2 embedding

## API Scripts

### `scripts/fill_commons_metadata.py`
Searches Wikimedia Commons for heritage images and adds metadata.

```bash
python scripts/fill_commons_metadata.py \
    --in assets/data/questions.json \
    --out assets/data/questions.filled.json \
    --strategy answer \
    --field century \
    --limit 50
```

### `tool/fill_commons_images.py`
Fills images using Wikidata and Commons integration.

```bash
# Set environment variable to overwrite existing images
export OVERWRITE_ALL=true
python tool/fill_commons_images.py
```

## Configuration

### Environment Variables
- `OVERWRITE_ALL` - Set to `true` to overwrite existing image URLs in the data

### Dependencies
All Python dependencies are listed in `scripts/requirements.txt`:
```
requests>=2.31.0
tqdm>=4.66.0
```

### Java & Flutter Versions
- **Java:** 17 (Temurin distribution)
- **Flutter:** 3.24.3 (stable channel)

## Validation

Run the validation script to check everything is working:

```bash
python scripts/validate.py
```

This checks:
- ✅ questions.json exists and is valid
- ✅ Python scripts compile correctly
- ✅ Required dependencies are available
- ✅ Script help functions work

## Troubleshooting

### Common Issues

1. **Java Version Mismatch**
   - Solution: Workflows now use Java 17 consistently

2. **Missing Python Dependencies**
   - Solution: All workflows install `requests` and `tqdm`
   - Check: `pip install -r scripts/requirements.txt`

3. **Flutter Build Failures**
   - Solution: Updated to Flutter 3.24.3 for consistency
   - Check: `flutter doctor -v`

4. **Permission Errors**
   - Solution: Workflows have appropriate `contents: write` permissions

### Manual Testing

Test individual components:

```bash
# Test Flutter build
flutter pub get
flutter analyze
flutter build apk --debug

# Test Python scripts
python scripts/validate.py
python -m py_compile scripts/fill_commons_metadata.py
python -m py_compile tool/fill_commons_images.py

# Test with sample data
python scripts/fill_commons_metadata.py --help
```

## Performance Improvements

The workflows include several optimizations:
- **Dependency Caching:** Flutter and Python dependencies are cached
- **Concurrent Builds:** Multiple jobs run in parallel where possible
- **Conditional Steps:** Optional steps (like icon generation) can be skipped
- **Timeout Limits:** Prevents hanging builds

## Security

- Uses GitHub's built-in `GITHUB_TOKEN` for repository access
- No external secrets required for basic operations
- Python scripts use appropriate User-Agent headers for API calls

## Monitoring

Check workflow status:
```bash
# List recent workflow runs
gh run list

# View specific run details
gh run view <run-id>

# Download artifacts
gh run download <run-id>
```