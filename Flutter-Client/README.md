# GrabTube Flutter Client

<div align="center">

![GrabTube Logo](assets/images/logo.png)

**A cutting-edge, multi-platform tube services downloader**

[![CI/CD](https://github.com/yourusername/grabtube/workflows/CI%2FCD%20Pipeline/badge.svg)](https://github.com/yourusername/grabtube/actions)
[![codecov](https://codecov.io/gh/yourusername/grabtube/branch/main/graph/badge.svg)](https://codecov.io/gh/yourusername/grabtube)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

[Features](#features) • [Installation](#installation) • [Architecture](#architecture) • [Testing](#testing) • [Contributing](#contributing)

</div>

## 🌟 Features

### Core Functionality
- **📥 Multi-Platform Downloads**: Android, iOS, Windows, macOS, and Linux support
- **🎬 Video Quality Selection**: Download in any quality from 360p to 4K
- **📊 Real-Time Progress**: Live download progress with WebSocket updates
- **📁 Queue Management**: Manage download queue with pause/resume capabilities
- **🎨 Modern UI/UX**: Material Design 3 with light/dark theme support
- **⚡ High Performance**: Native performance on all platforms

### Advanced Features
- **🔔 Push Notifications**: Get notified when downloads complete
- **📱 Background Downloads**: Continue downloading even when app is minimized
- **🌐 Multi-Server Support**: Connect to multiple backend servers
- **💾 Persistent Storage**: Download history and queue persistence
- **🔄 Auto-Retry**: Automatic retry on failed downloads
- **📊 Download Statistics**: Track download speed, ETA, and file size

### Platform-Specific Features
#### Android
- Material You dynamic theming
- Picture-in-picture support
- Share integration
- Deep link support

#### iOS
- Native iOS design patterns
- Share sheet integration
- Widget support
- Handoff support

#### Desktop (Windows/macOS/Linux)
- System tray integration
- Keyboard shortcuts
- Native menu bar
- File system integration

## 📦 Installation

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Dart SDK 3.5.0 or higher
- For Android: Android Studio with SDK 24+
- For iOS: Xcode 15+ (macOS only)
- For Desktop: Platform-specific build tools

### Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/grabtube-flutter.git
cd grabtube-flutter

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Platform-Specific Setup

#### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

#### iOS
```bash
# Install CocoaPods dependencies
cd ios && pod install && cd ..

# Build iOS app
flutter build ios --release
```

#### Desktop

**Linux:**
```bash
# Install dependencies
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

# Build
flutter build linux --release
```

**Windows:**
```bash
# Build (requires Visual Studio 2019+)
flutter build windows --release
```

**macOS:**
```bash
# Build
flutter build macos --release
```

## 🏗️ Architecture

### Clean Architecture with BLoC Pattern

```
lib/
├── core/
│   ├── constants/      # App-wide constants
│   ├── di/            # Dependency injection setup
│   ├── network/       # API client and WebSocket
│   └── utils/         # Utility functions
├── data/
│   ├── models/        # Data models with JSON serialization
│   └── repositories/  # Repository implementations
├── domain/
│   ├── entities/      # Business entities
│   ├── repositories/  # Repository interfaces
│   └── usecases/      # Business logic use cases
└── presentation/
    ├── blocs/         # BLoC state management
    ├── pages/         # Screen widgets
    └── widgets/       # Reusable UI components
```

### Key Design Patterns
- **Clean Architecture**: Separation of concerns with clear boundaries
- **BLoC Pattern**: Reactive state management
- **Dependency Injection**: Using get_it and injectable
- **Repository Pattern**: Abstract data sources
- **SOLID Principles**: Throughout the codebase

### Tech Stack
- **Framework**: Flutter 3.24+
- **State Management**: flutter_bloc
- **Dependency Injection**: get_it + injectable
- **Networking**: dio + retrofit
- **Real-Time**: socket_io_client
- **Local Storage**: hive + shared_preferences
- **Testing**: mocktail + patrol

## 🧪 Testing

### Comprehensive Test Coverage

We maintain **>80% code coverage** with a multi-layered testing approach:

#### Test Types
1. **Unit Tests** - Business logic and data models
2. **Widget Tests** - UI components
3. **Integration Tests** - Feature flows
4. **E2E Tests** - Complete user journeys (Patrol)

### Running Tests

```bash
# Run all tests with coverage
./tools/run_tests.sh

# Run specific test suites
flutter test test/unit          # Unit tests only
flutter test test/widget        # Widget tests only
flutter test test/integration   # Integration tests only

# Run E2E tests
patrol test
```

### AI-Powered Test Validation

We use an AI-powered test validation system to ensure quality:

```bash
# Run AI test validation
python3 tools/ai_test_validator.py

# Generates:
# - Test execution reports
# - Coverage analysis
# - Flaky test detection
# - Test case suggestions
# - Comprehensive recommendations
```

### Coverage Reports

```bash
# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 📱 Platform-Specific Documentation

### Android
- [Android Build Configuration](docs/android/BUILD.md)
- [Android Permissions](docs/android/PERMISSIONS.md)
- [Android Release Process](docs/android/RELEASE.md)

### iOS
- [iOS Build Configuration](docs/ios/BUILD.md)
- [iOS Capabilities](docs/ios/CAPABILITIES.md)
- [iOS Release Process](docs/ios/RELEASE.md)

### Desktop
- [Windows Build Guide](docs/desktop/WINDOWS.md)
- [macOS Build Guide](docs/desktop/MACOS.md)
- [Linux Build Guide](docs/desktop/LINUX.md)

## 🚀 Deployment

### CI/CD Pipeline

Automated builds and tests run on every commit:
- ✅ Lint and analyze code
- ✅ Run all test suites
- ✅ Generate coverage reports
- ✅ Build for all platforms
- ✅ Create release artifacts

See [.github/workflows/ci.yml](.github/workflows/ci.yml) for details.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Run `./tools/run_tests.sh` to verify
5. Submit a pull request

### Code Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Run `flutter analyze` before committing
- Maintain >80% test coverage
- Write meaningful commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Backend powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- Icons by [Font Awesome](https://fontawesome.com/)
- Inspired by [MeTube](https://github.com/alexta69/metube)

## 📞 Support

- 📧 Email: support@grabtube.com
- 💬 Discord: [Join our community](https://discord.gg/grabtube)
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/grabtube/issues)
- 📚 Wiki: [Documentation](https://github.com/yourusername/grabtube/wiki)

---

<div align="center">
Made with ❤️ by the GrabTube Team
</div>
