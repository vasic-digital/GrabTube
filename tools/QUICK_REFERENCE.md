# Flutter Local SDK - Quick Reference

## 🚀 One-Time Setup

```bash
# Install Flutter (from project root)
./tools/setup-flutter.sh
```

**That's it!** Wait 3-5 minutes for download and setup.

---

## 💻 Daily Usage

### From Project Root

```bash
# Check Flutter version
./tools/flutter --version

# Run Flutter doctor
./tools/flutter doctor
```

### From Flutter-Client Directory

```bash
cd Flutter-Client

# Install dependencies
../tools/flutter pub get

# Generate code
../tools/flutter pub run build_runner build --delete-conflicting-outputs

# Analyze code
../tools/flutter analyze

# Run tests
../tools/flutter test

# Run app (web)
../tools/flutter run -d chrome

# Run app (desktop)
../tools/flutter run -d macos
```

---

## ✅ Verify Installation

```bash
./tools/verify-flutter.sh
```

---

## 🧹 Clean/Remove Flutter

```bash
./tools/clean-flutter.sh
```

---

## 🔄 Update/Change Version

```bash
# Remove current version
./tools/clean-flutter.sh --force

# Install new version
./tools/setup-flutter.sh 3.24.5
```

---

## 📍 Important Paths

- **Flutter SDK:** `tools/flutter-sdk/`
- **Flutter Binary:** `tools/flutter-sdk/bin/flutter`
- **Wrapper Script:** `tools/flutter`
- **Documentation:** `tools/FLUTTER_SETUP.md`

---

## 🆘 Quick Troubleshooting

**Problem:** "Flutter SDK not found"
```bash
./tools/setup-flutter.sh
```

**Problem:** "Permission denied"
```bash
chmod +x tools/setup-flutter.sh tools/flutter tools/verify-flutter.sh
```

**Problem:** Flutter doctor errors
```bash
./tools/flutter-sdk/bin/flutter doctor --android-licenses
```

---

## 📚 Full Documentation

See `tools/FLUTTER_SETUP.md` for complete documentation.

---

**Note:** This is a LOCAL Flutter installation. It doesn't affect your system-wide Flutter (if you have one).
