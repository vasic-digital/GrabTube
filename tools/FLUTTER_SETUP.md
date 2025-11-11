# GrabTube - Local Flutter SDK Setup

This directory contains scripts for setting up and managing a **local Flutter SDK installation** specifically for the GrabTube project.

## 📋 Overview

Instead of requiring a system-wide Flutter installation, GrabTube uses a **project-local Flutter SDK** with the following benefits:

- ✅ **Version Consistency**: Everyone uses the same Flutter version
- ✅ **No System Pollution**: Doesn't affect global Flutter installation
- ✅ **CI/CD Ready**: Easy to replicate in build pipelines
- ✅ **Easy Cleanup**: Remove with one command
- ✅ **Fully Automated**: One script to download, install, and configure
- ✅ **Not Versioned**: Excluded from Git (see `.gitignore`)

---

## 🚀 Quick Start

### 1. Install Local Flutter SDK

```bash
# From project root
./tools/setup-flutter.sh

# Or install specific version
./tools/setup-flutter.sh 3.24.5
```

**What it does:**
- Detects your OS and architecture (macOS M1/Intel, Linux, Windows)
- Downloads the appropriate Flutter SDK
- Extracts to `tools/flutter-sdk/` (gitignored)
- Configures Flutter (disables analytics, accepts licenses)
- Creates wrapper scripts for easy usage
- Runs `flutter doctor` to verify installation

**Time:** ~3-5 minutes (depending on internet speed)

### 2. Verify Installation

```bash
./tools/verify-flutter.sh
```

**What it checks:**
- ✓ Flutter SDK directory exists
- ✓ Flutter binary is executable
- ✓ Flutter version is correct
- ✓ Wrapper script works
- ✓ Dart SDK is available
- ✓ Runs `flutter doctor`

### 3. Use Flutter

**Option A: Wrapper Script (Recommended)**
```bash
# From project root
./tools/flutter --version
./tools/flutter doctor

# From Flutter-Client directory
cd Flutter-Client
../tools/flutter pub get
../tools/flutter run
```

**Option B: Source Environment File**
```bash
# Load Flutter into PATH
source tools/flutter-env.sh

# Now use flutter directly
flutter --version
flutter doctor
cd Flutter-Client && flutter pub get
```

**Option C: Direct Path**
```bash
# Use full path to Flutter binary
./tools/flutter-sdk/bin/flutter --version
```

---

## 📁 File Structure

```
tools/
├── setup-flutter.sh          # Main installation script
├── flutter                    # Flutter wrapper script (executable)
├── verify-flutter.sh          # Verification script
├── clean-flutter.sh           # Cleanup script
├── flutter-env.sh             # Generated: Environment setup
├── flutter-sdk/               # Generated: Flutter SDK (gitignored)
│   ├── bin/
│   │   ├── flutter            # Flutter CLI
│   │   └── dart               # Dart CLI
│   ├── packages/
│   └── ...
└── FLUTTER_SETUP.md           # This file
```

**Generated files** (not in Git):
- `flutter-sdk/` - The actual Flutter SDK installation
- `flutter-env.sh` - Shell script to add Flutter to PATH
- `../.flutter-version` - Tracks installed Flutter version

---

## 📜 Available Scripts

### `setup-flutter.sh`

**Purpose:** Downloads and installs local Flutter SDK

**Usage:**
```bash
./tools/setup-flutter.sh [version]
```

**Arguments:**
- `version` - Optional Flutter version (default: `stable`)
  - `stable` - Latest stable release
  - `beta` - Latest beta release
  - `3.24.5` - Specific version number

**Examples:**
```bash
# Install latest stable
./tools/setup-flutter.sh

# Install specific version
./tools/setup-flutter.sh 3.24.5

# Install beta channel
./tools/setup-flutter.sh beta
```

**What it does:**
1. Detects your operating system and architecture
2. Downloads appropriate Flutter SDK from Google's servers
3. Extracts to `tools/flutter-sdk/`
4. Runs `flutter config --no-analytics`
5. Accepts Android licenses (non-interactive)
6. Runs `flutter doctor` to download dependencies
7. Creates `flutter-env.sh` for PATH configuration
8. Saves Flutter version to `.flutter-version`

---

### `flutter` (Wrapper Script)

**Purpose:** Convenient wrapper to use local Flutter SDK

**Usage:**
```bash
./tools/flutter [flutter-arguments]
```

**Examples:**
```bash
# Check Flutter version
./tools/flutter --version

# Run Flutter doctor
./tools/flutter doctor

# Get dependencies (from Flutter-Client)
cd Flutter-Client
../tools/flutter pub get

# Run code generation
../tools/flutter pub run build_runner build

# Analyze code
../tools/flutter analyze

# Run tests
../tools/flutter test

# Run app
../tools/flutter run
```

**Advantages:**
- ✅ No need to modify PATH
- ✅ Works from any directory
- ✅ Checks if Flutter is installed
- ✅ Shows helpful error messages

---

### `verify-flutter.sh`

**Purpose:** Verifies local Flutter installation

**Usage:**
```bash
./tools/verify-flutter.sh
```

**What it checks:**
- Flutter SDK directory exists
- Flutter binary is executable
- Flutter version is correct
- Flutter wrapper script works
- Dart SDK is available
- Environment file is configured
- Runs full `flutter doctor` check

**Exit Codes:**
- `0` - All checks passed
- `1` - One or more checks failed

---

### `clean-flutter.sh`

**Purpose:** Removes local Flutter installation

**Usage:**
```bash
# With confirmation prompt
./tools/clean-flutter.sh

# Skip confirmation (CI/CD)
./tools/clean-flutter.sh --force
```

**What it removes:**
- `tools/flutter-sdk/` - Flutter SDK directory
- `tools/flutter-env.sh` - Environment file
- `.flutter-version` - Version tracking file
- `Flutter-Client/.dart_tool/` - Flutter cache
- `Flutter-Client/.flutter-plugins*` - Flutter plugins

**Safe to run:**
- Does NOT remove your source code
- Does NOT remove `tools/` scripts
- Does NOT affect system-wide Flutter

---

### `flutter-env.sh`

**Purpose:** Adds local Flutter to PATH (generated by setup script)

**Usage:**
```bash
# Load into current shell
source tools/flutter-env.sh

# Now use flutter directly
flutter --version
```

**What it does:**
- Adds `tools/flutter-sdk/bin` to PATH
- Sets `FLUTTER_ROOT` environment variable
- Shows confirmation message

**When to use:**
- When you prefer typing `flutter` instead of `./tools/flutter`
- In IDE terminals (add to shell profile)
- In CI/CD scripts

---

## 🔧 Common Workflows

### Initial Setup (First Time)

```bash
# 1. Install Flutter
./tools/setup-flutter.sh

# 2. Verify installation
./tools/verify-flutter.sh

# 3. Go to Flutter project
cd Flutter-Client

# 4. Install dependencies
../tools/flutter pub get

# 5. Generate code
../tools/flutter pub run build_runner build --delete-conflicting-outputs

# 6. Analyze code
../tools/flutter analyze

# 7. Run tests
../tools/flutter test

# 8. Run app
../tools/flutter run
```

---

### Daily Development

```bash
cd Flutter-Client

# Get latest dependencies
../tools/flutter pub get

# Run code generation after model changes
../tools/flutter pub run build_runner build --delete-conflicting-outputs

# Run app
../tools/flutter run

# Run tests
../tools/flutter test

# Analyze code
../tools/flutter analyze
```

---

### Switching Flutter Versions

```bash
# Remove current installation
./tools/clean-flutter.sh

# Install different version
./tools/setup-flutter.sh 3.24.5

# Verify new version
./tools/verify-flutter.sh
```

---

### CI/CD Integration

```yaml
# Example: GitHub Actions
name: Flutter CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      # Install local Flutter
      - name: Setup Flutter
        run: ./tools/setup-flutter.sh stable

      # Verify installation
      - name: Verify Flutter
        run: ./tools/verify-flutter.sh

      # Run tests
      - name: Run tests
        run: |
          cd Flutter-Client
          ../tools/flutter pub get
          ../tools/flutter test
```

---

### Using in IDE (VS Code)

**Option 1: Use wrapper script in tasks**

`.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Flutter: Pub Get",
      "type": "shell",
      "command": "../tools/flutter pub get",
      "problemMatcher": []
    },
    {
      "label": "Flutter: Run",
      "type": "shell",
      "command": "../tools/flutter run",
      "problemMatcher": []
    }
  ]
}
```

**Option 2: Add to shell profile**

Add to `~/.zshrc` or `~/.bashrc`:
```bash
# GrabTube local Flutter (only when in project directory)
if [[ -f "$PWD/tools/flutter-env.sh" ]]; then
  source "$PWD/tools/flutter-env.sh"
fi
```

---

## 🛠️ Troubleshooting

### Issue: "Flutter SDK not found"

**Solution:**
```bash
# Install Flutter
./tools/setup-flutter.sh

# Or verify it's installed
./tools/verify-flutter.sh
```

---

### Issue: "Permission denied"

**Solution:**
```bash
# Make scripts executable
chmod +x tools/setup-flutter.sh
chmod +x tools/flutter
chmod +x tools/verify-flutter.sh
chmod +x tools/clean-flutter.sh
```

---

### Issue: "Download failed"

**Possible causes:**
- Internet connection issue
- Invalid Flutter version specified
- Storage space issue

**Solution:**
```bash
# Try with stable channel
./tools/setup-flutter.sh stable

# Or check disk space
df -h
```

---

### Issue: "Flutter doctor shows errors"

**Common errors and fixes:**

**Android License Error:**
```bash
# Accept Android licenses
./tools/flutter-sdk/bin/flutter doctor --android-licenses
```

**Xcode Error (macOS):**
```bash
# Install Xcode from App Store
# Then accept license
sudo xcodebuild -license accept
```

**Android SDK not found:**
```bash
# Set ANDROID_HOME environment variable
export ANDROID_HOME=/path/to/android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

---

### Issue: "Flutter version mismatch"

**Solution:**
```bash
# Clean and reinstall
./tools/clean-flutter.sh --force
./tools/setup-flutter.sh 3.24.5  # Use specific version
```

---

## 📊 Comparison: Local vs System Installation

| Feature | Local (This Setup) | System-Wide |
|---------|-------------------|-------------|
| Version consistency | ✅ Guaranteed | ❌ Varies by dev |
| Project isolation | ✅ Yes | ❌ Shared |
| CI/CD friendly | ✅ Very easy | ⚠️ Complex |
| Disk space | ⚠️ ~2GB per project | ✅ ~2GB total |
| Setup time | ⚠️ 3-5 min | ⚠️ 5-10 min |
| Multiple versions | ✅ Easy | ⚠️ Complex |
| Team onboarding | ✅ One command | ❌ Manual setup |
| Cleanup | ✅ One command | ⚠️ System-wide |

---

## 🔐 Security

### What's Excluded from Git

The following are **automatically excluded** via `.gitignore`:

```gitignore
# Flutter SDK
tools/flutter-sdk/
tools/flutter-*.tar.xz
.flutter-version
flutter/
.flutter/
```

### What's Included in Git

The following **are versioned** and safe to commit:

- ✅ `tools/setup-flutter.sh` - Installation script
- ✅ `tools/flutter` - Wrapper script
- ✅ `tools/verify-flutter.sh` - Verification script
- ✅ `tools/clean-flutter.sh` - Cleanup script
- ✅ `tools/FLUTTER_SETUP.md` - This documentation

### Downloads are from Official Sources

All Flutter downloads come from:
- **Official Google servers**: `https://storage.googleapis.com/flutter_infra_release/`
- **Secure HTTPS only**
- **Checksums verified** by Flutter itself

---

## 📈 Performance

### Initial Setup
- **Download size**: ~300-500 MB (compressed)
- **Installed size**: ~1.5-2 GB
- **Setup time**: 3-5 minutes (depends on internet)

### After Setup
- **Flutter commands**: Same speed as system installation
- **No overhead**: Direct binary execution
- **Caching**: Uses same Flutter cache mechanisms

---

## 🎯 Best Practices

### DO ✅

- Use the wrapper script: `./tools/flutter`
- Run `verify-flutter.sh` after setup
- Clean before version switches
- Document required Flutter version in README
- Use same version across team
- Add to CI/CD for consistency

### DON'T ❌

- Don't commit `tools/flutter-sdk/` to Git
- Don't mix local and system Flutter
- Don't modify files in `flutter-sdk/` directly
- Don't share the downloaded SDK (download fresh)

---

## 📚 Additional Resources

### Flutter Official Documentation
- [Flutter Install](https://docs.flutter.dev/get-started/install)
- [Flutter Doctor](https://docs.flutter.dev/get-started/flutter-doctor)
- [Flutter CLI](https://docs.flutter.dev/reference/flutter-cli)

### GrabTube Documentation
- `../INTEGRATION_STATUS.md` - Current integration status
- `../Flutter-Client/NEXT_STEPS.md` - Next steps after Flutter setup
- `../SESSION_SUMMARY.md` - Recent implementation summary

---

## ❓ FAQ

**Q: Do I need to install Flutter system-wide?**
A: No! The local installation is completely independent.

**Q: Can I use both local and system Flutter?**
A: Yes, but avoid mixing them in the same project. Use one consistently.

**Q: How do I update Flutter?**
A: Run `./tools/clean-flutter.sh` then `./tools/setup-flutter.sh` with desired version.

**Q: What happens if I delete `tools/flutter-sdk/`?**
A: Nothing breaks. Just run `./tools/setup-flutter.sh` again.

**Q: Can multiple projects share the same local Flutter?**
A: No, each project gets its own copy. This ensures version consistency.

**Q: Is the download safe?**
A: Yes, downloads come from official Google Cloud Storage servers over HTTPS.

**Q: What if I already have Flutter installed?**
A: The local installation won't interfere. Use the wrapper script to use the local version.

**Q: Can I use this in Docker?**
A: Yes! Perfect for Docker. The scripts work in containers.

---

## 🆘 Getting Help

### For Flutter SDK Issues
1. Run `./tools/verify-flutter.sh`
2. Check `flutter doctor` output
3. See troubleshooting section above
4. Visit [Flutter Docs](https://docs.flutter.dev/)

### For GrabTube Project Issues
1. Check `INTEGRATION_STATUS.md`
2. Read `Flutter-Client/NEXT_STEPS.md`
3. Review `SESSION_SUMMARY.md`
4. Open GitHub issue

---

**Last Updated:** November 11, 2025
**Flutter Version Supported:** 3.24+ (stable channel recommended)
**Tested Platforms:** macOS (M1/Intel), Linux (x64), Windows (x64)
