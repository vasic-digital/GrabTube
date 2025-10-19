<div align="center">

<img src="Assets/Logo.jpeg" alt="GrabTube Logo" width="300"/>

# GrabTube - Universal Tube Services Downloader

**A cutting-edge, multi-platform video downloader with modern UI/UX**

![Platforms](https://img.shields.io/badge/platforms-Web%20%7C%20Android%20%7C%20iOS%20%7C%20Desktop-blue)
![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)
![Python](https://img.shields.io/badge/Python-3.13+-3776AB?logo=python)
![License](https://img.shields.io/badge/license-MIT-green)

[Features](#features) • [Clients](#clients) • [Getting Started](#getting-started) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---

## 🌟 Overview

GrabTube is a comprehensive video downloading solution featuring:
- **Web-based GUI** - Original Python/Angular application
- **Mobile Apps** - Native Android and iOS applications (Flutter)
- **Desktop Apps** - Windows, macOS, and Linux applications (Flutter)

All clients communicate with the powerful **yt-dlp** backend for downloading from hundreds of sites.

---

## 📱 Available Clients

### 🌐 Web Client (Production Ready)
- **Technology**: Python (aiohttp) + Angular 19
- **Status**: ✅ Complete
- **Features**: Full-featured web interface
- **Location**: `Web-Client/`
- [📖 Documentation](CLAUDE.md)

### 📱 Flutter Client (Production Ready) ⭐ NEW!
- **Technology**: Flutter 3.24+ (Dart)
- **Platforms**: Android, iOS, Windows, macOS, Linux
- **Status**: ✅ **Complete with comprehensive testing**
- **Location**: `Flutter-Client/`
- **Test Coverage**: >80% with AI validation
- [📖 Documentation](Flutter-Client/README.md)

---

## ✨ Features

### Universal Features (All Clients)
- ✅ Download from YouTube and 1000+ sites
- ✅ Quality selection (360p to 4K)
- ✅ Multiple format support (MP4, WebM, MP3, etc.)
- ✅ Real-time progress tracking
- ✅ Download queue management
- ✅ Persistent download history

### Flutter Client Exclusive
- ✅ **Native performance** on all platforms
- ✅ **Material Design 3** with adaptive theming
- ✅ **Background downloads** with notifications
- ✅ **Offline queue** management
- ✅ **>80% test coverage** with AI validation
- ✅ **CI/CD pipeline** for automated testing

---

## 🚀 Quick Start

### Prerequisites
- **Backend**: Python 3.13+, uv package manager
- **Web Client**: Node.js (LTS)
- **Flutter Client**: Flutter 3.24+, Dart 3.5+

### 1. Start the Backend

```bash
cd Web-Client

# Install dependencies
uv sync

# Run the server
uv run python3 app/main.py
```

Server will start on `http://localhost:8081`

### 2. Choose Your Client

#### Option A: Web Client

```bash
cd Web-Client/ui

# Install and build
npm install
npm run build

# Development server
npm run start  # http://localhost:4200
```

#### Option B: Flutter Client (Recommended ⭐)

```bash
cd Flutter-Client

# Install dependencies
flutter pub get

# Run on your platform
flutter run

# Or build for specific platform:
flutter build apk           # Android
flutter build ios           # iOS
flutter build linux         # Linux
flutter build windows       # Windows
flutter build macos         # macOS
```

---

## 📚 Documentation

### Flutter Client Documentation (Complete ✅)
- [📘 Main README](Flutter-Client/README.md) - Installation, features, quick start
- [🏗️ Architecture Guide](Flutter-Client/docs/ARCHITECTURE.md) - Clean architecture, BLoC pattern
- [🔌 API Documentation](Flutter-Client/docs/API.md) - Backend API reference
- [👤 User Guide](Flutter-Client/docs/USER_GUIDE.md) - Complete user manual
- [📊 Implementation Summary](IMPLEMENTATION_SUMMARY.md) - Project completion report

### Web Client Documentation
- [📘 Development Guide](CLAUDE.md) - Backend architecture and development guide

---

## 🧪 Testing

### Flutter Client Testing (>80% Coverage)

```bash
cd Flutter-Client

# Run all tests
./tools/run_tests.sh

# Individual test suites
flutter test test/unit              # Unit tests
flutter test test/widget            # Widget tests
flutter test test/integration       # Integration tests
patrol test                         # E2E tests

# AI-powered test validation
python3 tools/ai_test_validator.py
```

---

## 📊 Project Status

| Client | Status | Platforms | Tests | Docs |
|--------|--------|-----------|-------|------|
| **Web Client** | ✅ Production | Web | ⚠️ Partial | ✅ Complete |
| **Flutter Client** | ✅ Production | Android, iOS, Desktop | ✅ >80% | ✅ Complete |

---

## 📄 License

This project is licensed under the MIT License.

---

## 📞 Support

- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/grabtube/issues)
- 📚 **Documentation**: See Flutter-Client/docs/

---

<div align="center">

**Made with ❤️ by the GrabTube Team**

*Empowering users to download content from anywhere, on any platform*

</div>
