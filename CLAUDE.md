<div align="center">

<img src="Assets/Logo.jpeg" alt="GrabTube Logo" width="250"/>

# CLAUDE.md

**Project guidance for Claude Code**

</div>

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GrabTube is a multi-platform tube services downloader - a GUI for yt-dlp with playlist support. The project consists of:
- **Web-Client**: Python (aiohttp) backend + Angular 19 frontend - production ready
- **Flutter-Client**: Cross-platform client (Android, iOS, Windows, macOS, Linux) - production ready with >80% test coverage
- **Android-Client**, **Desktop-Client**, **iOS-Client**: Placeholder directories (superseded by Flutter-Client)

The Web-Client is a fork/variant of MeTube. Both clients communicate with the same Python backend to download videos from YouTube and 1000+ sites supported by yt-dlp.

## Web-Client Submodule (READ-ONLY)

**IMPORTANT**: The Web-Client directory is a **READ-ONLY** git submodule that tracks the upstream MeTube project:

- **Upstream Repository**: `git@github.com:alexta69/metube.git`
- **Purpose**: Reference implementation for Angular frontend
- **Configuration**:
  - Git is configured to ignore all changes in Web-Client (`ignore = all`)
  - Push URL is blocked to prevent accidental upstream pushes
  - Only `git fetch` and `git pull` operations are allowed

### Working with Web-Client

**DO**:
- Read code from Web-Client for reference
- Update submodule to latest upstream: `cd Web-Client && git fetch && git pull origin master`
- Use as inspiration for Flutter Web client features

**DO NOT**:
- Modify files in Web-Client directory
- Commit changes to Web-Client
- Push to Web-Client upstream

**Important**: All GrabTube-specific branding and features should be implemented in the Flutter-Client (including flutter-web) instead of modifying Web-Client.

## Architecture

### Backend (Python)
The backend is an **aiohttp** async web server with **Socket.IO** for real-time communication:

- `app/main.py`: Main server entry point
  - Configures and runs the aiohttp web server
  - Handles HTTP endpoints (`/add`, `/delete`, `/start`, `/history`)
  - Manages Socket.IO events for real-time updates
  - Serves the Angular UI as static files
  - Uses environment variables for configuration (see Config class)

- `app/ytdl.py`: Download queue management
  - `DownloadQueue`: Manages download, pending, and completed queues with persistent storage (shelve)
  - `Download`: Handles individual downloads using multiprocessing
  - `PersistentQueue`: Stores queue state on disk for persistence across restarts
  - Supports three download modes: `sequential`, `concurrent`, and `limited` (default, with semaphore)
  - Each download runs in a separate process to isolate yt-dlp execution

- `app/dl_formats.py`: Format and quality string generation for yt-dlp
  - Converts user-friendly format/quality selections into yt-dlp format strings
  - Handles special cases like iOS-compatible formats, audio extraction, thumbnails
  - Configures postprocessors (FFmpeg operations) based on format selection

### Frontend Options

#### Angular Client (Web-Client/ui/)
- Built with Angular 19, Bootstrap 5, Font Awesome icons
- Uses Socket.IO client (`ngx-socket-io`) for real-time updates from backend
- Main component: `ui/src/app/app.component.ts` - handles UI state and user interactions
- Services:
  - `downloads.service.ts`: Manages download operations via HTTP and Socket.IO
  - `speed.service.ts`: Calculates and formats download speeds
- Theme support: `theme.ts` manages light/dark/auto theme switching

#### Flutter Client (Flutter-Client/)
- Cross-platform support: Android, iOS, Windows, macOS, Linux
- **Clean Architecture** with BLoC pattern for state management
- Directory structure:
  - `lib/core/`: Constants, DI setup, network layer (API client, WebSocket)
  - `lib/data/`: Models with JSON serialization, repository implementations
  - `lib/domain/`: Business entities, repository interfaces, use cases
  - `lib/presentation/`: BLoC state management, pages, widgets
- Tech stack: flutter_bloc, dio, socket_io_client, hive (local storage)
- **Comprehensive testing**: >80% coverage with unit, widget, integration, and E2E tests (Patrol)
- Build with: `flutter pub run build_runner build --delete-conflicting-outputs` (for code generation)

### Communication Flow
1. User submits download via Angular/Flutter UI
2. HTTP POST to `/add` endpoint with URL, quality, format, folder, etc.
3. Backend extracts video info using yt-dlp, creates Download object
4. Download added to queue, Socket.IO emits 'added' event to UI
5. Download executes in separate process, status updates sent via Socket.IO
6. UI receives real-time updates ('updated', 'completed', 'canceled', 'cleared')

## Quick Reference

### Most Common Commands

```bash
# Start backend server
cd Web-Client && uv run python3 app/main.py

# Start Angular dev server
cd Web-Client/ui && npm run start

# Run Flutter app (current platform)
cd Flutter-Client && flutter run

# Run Flutter tests
cd Flutter-Client && ./tools/run_tests.sh

# Flutter code generation (after model/DI changes)
cd Flutter-Client && flutter pub run build_runner build --delete-conflicting-outputs
```

## Development Commands

### Python Backend (Web-Client/)

**Prerequisites**: Python 3.13+, uv package manager

```bash
cd Web-Client

# Install dependencies
uv sync

# Install dev dependencies (includes pylint)
uv sync --dev

# Run backend server
uv run python3 app/main.py  # Starts on http://0.0.0.0:8081

# Run linter
uv run pylint app/

# Run single file
uv run python3 app/ytdl.py
```

### Angular Client (Web-Client/ui/)

**Prerequisites**: Node.js (LTS)

```bash
cd Web-Client/ui

# Install dependencies
npm install

# Development server with hot reload
npm run start        # Serves on http://localhost:4200

# Build for production
npm run build        # Output to ui/dist/metube/browser
node_modules/.bin/ng build  # Alternative

# Run tests
npm test

# Lint
npm run lint

# End-to-end tests
npm run e2e
```

### Flutter Client (Flutter-Client/)

**Prerequisites**: Flutter SDK 3.24+, Dart SDK 3.5+

```bash
cd Flutter-Client

# Install dependencies
flutter pub get

# Run code generation (REQUIRED after modifying models, repositories, or DI)
flutter pub run build_runner build --delete-conflicting-outputs

# For development with auto-rebuild on changes
flutter pub run build_runner watch --delete-conflicting-outputs

# Run on current device/platform
flutter run

# Run on specific platform
flutter run -d chrome              # Web
flutter run -d macos              # macOS
flutter run -d windows            # Windows
flutter run -d <device-id>        # Specific device (use: flutter devices)

# Build for production
flutter build apk --release        # Android APK
flutter build appbundle --release  # Android App Bundle
flutter build ios --release        # iOS
flutter build linux --release      # Linux
flutter build windows --release    # Windows
flutter build macos --release      # macOS
flutter build web --release        # Web

# Run all tests with coverage
./tools/run_tests.sh

# Run specific test suites
flutter test test/unit             # Unit tests
flutter test test/widget           # Widget tests
flutter test test/integration      # Integration tests
flutter test test/e2e              # E2E tests

# Run single test file
flutter test test/unit/path/to/test_file.dart

# Run tests with coverage
flutter test --coverage

# Run AI-powered test validation
python3 tools/ai_test_validator.py

# Code analysis
flutter analyze

# Fix auto-fixable lint issues
dart fix --apply
```

### Docker (Web-Client/)

```bash
cd Web-Client

# Build Docker image
docker build -t grabtube .

# Run container (basic)
docker run -d -p 8081:8081 -v /path/to/downloads:/downloads grabtube

# Run with custom configuration
docker run -d \
  -p 8081:8081 \
  -v /path/to/downloads:/downloads \
  -e DOWNLOAD_MODE=limited \
  -e MAX_CONCURRENT_DOWNLOADS=5 \
  -e OUTPUT_TEMPLATE="%(title)s.%(ext)s" \
  --name grabtube \
  grabtube

# View logs
docker logs -f grabtube

# Stop container
docker stop grabtube

# Remove container
docker rm grabtube

# Access shell for debugging
docker exec -ti grabtube sh

# Test yt-dlp directly in container
docker exec -ti grabtube sh -c "cd /downloads && yt-dlp --help"
```

## Configuration

The application is configured via environment variables (see `app/main.py` Config class). Key variables:

- `DOWNLOAD_DIR`: Where downloads are saved (default: `/downloads` in Docker)
- `DOWNLOAD_MODE`: `sequential`, `concurrent`, or `limited` (default: `limited`)
- `MAX_CONCURRENT_DOWNLOADS`: Max simultaneous downloads when mode is `limited` (default: 3)
- `YTDL_OPTIONS`: JSON string of yt-dlp options
- `YTDL_OPTIONS_FILE`: Path to JSON file with yt-dlp options (auto-reloads on change)
- `OUTPUT_TEMPLATE`: Filename template (default: `%(title)s.%(ext)s`)
- `PORT`: Server port (default: 8081)
- `LOGLEVEL`: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL` (default: `INFO`)

## Important Implementation Details

### Download Process Isolation
Each download runs in a **separate process** (multiprocessing.Process) to:
- Isolate yt-dlp execution from the main server
- Allow safe cancellation via process.kill()
- Prevent one download from blocking others
- Enable status updates via multiprocessing.Queue

### Queue Persistence
The application uses Python's `shelve` module to persist queue state:
- `queue`: Active downloads
- `done`: Completed downloads
- `pending`: Downloads not yet started (auto_start=False)

Files are stored in `STATE_DIR` (default: `/downloads/.metube`)

### File Watching
If `YTDL_OPTIONS_FILE` is set, the server watches for file changes using `watchfiles` and reloads options automatically, notifying clients via Socket.IO.

### Angular Build Output
The Angular app builds to `ui/dist/metube/browser/` and is served as static files by the backend. The backend expects this path and will raise an error if not found.

## Testing

### Flutter Testing Infrastructure

The Flutter client has a comprehensive testing infrastructure with **>80% coverage**:

**Test Types**:
1. **Unit Tests** (`test/unit/`) - Business logic, models, repositories, use cases
2. **Widget Tests** (`test/widget/`) - UI components in isolation
3. **Integration Tests** (`test/integration/`) - Feature flows, multi-component interactions
4. **E2E Tests** (`test/e2e/`) - Complete user journeys (uses Patrol framework)

**Test Runner**: `tools/run_tests.sh`
- Runs all test suites sequentially
- Generates coverage report (`coverage/lcov.info`)
- Creates HTML coverage report (if `lcov` installed)
- Runs AI-powered test validation
- Exits with error code on test failures

**AI Test Validator**: `tools/ai_test_validator.py`
- Analyzes test results and coverage
- Detects flaky tests
- Suggests missing test cases
- Provides quality recommendations
- Generates `test_validation_report.json`

**Running Tests**:
```bash
cd Flutter-Client

# All tests with full pipeline
./tools/run_tests.sh

# Individual test types
flutter test test/unit             # Fast, no dependencies
flutter test test/widget           # UI component tests
flutter test test/integration      # Feature tests
flutter test test/e2e              # Full app flows

# Single test file
flutter test test/unit/data/models/download_model_test.dart

# With coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
```

### Backend Testing

When testing yt-dlp functionality directly:
```bash
# In local environment
cd Web-Client
uv run yt-dlp --help
uv run yt-dlp <video-url> --list-formats

# In Docker container
docker exec -ti <container_name> sh
cd /downloads
yt-dlp --help
yt-dlp <video-url> --list-formats
```

## Project Structure

```
GrabTube/
├── Web-Client/               # Python backend + Angular frontend (git submodule)
│   ├── app/                  # Python backend code
│   │   ├── main.py          # aiohttp server, Socket.IO, API endpoints
│   │   ├── ytdl.py          # Download queue, multiprocessing
│   │   └── dl_formats.py    # yt-dlp format string generation
│   ├── ui/                   # Angular 19 frontend
│   │   ├── src/app/         # Components, services
│   │   └── package.json     # npm dependencies
│   ├── Dockerfile           # Multi-stage build (Node + Python)
│   ├── pyproject.toml       # Python dependencies (uv)
│   └── uv.lock              # Locked dependencies
├── Flutter-Client/          # Cross-platform Flutter client
│   ├── lib/                 # Dart/Flutter source code
│   │   ├── core/            # DI, network, constants
│   │   │   ├── di/          # Dependency injection (get_it + injectable)
│   │   │   ├── network/     # API client, WebSocket, interceptors
│   │   │   └── constants/   # App-wide constants
│   │   ├── data/            # Data layer
│   │   │   ├── models/      # JSON models (*.g.dart generated)
│   │   │   └── repositories/ # Repository implementations
│   │   ├── domain/          # Business logic layer
│   │   │   ├── entities/    # Plain Dart objects (no JSON)
│   │   │   ├── repositories/ # Repository interfaces
│   │   │   └── usecases/    # Business logic use cases
│   │   └── presentation/    # UI layer
│   │       ├── blocs/       # BLoC state management
│   │       ├── pages/       # Full screen pages
│   │       └── widgets/     # Reusable UI components
│   ├── test/                # Test suites
│   │   ├── unit/           # Business logic tests
│   │   ├── widget/         # UI component tests
│   │   ├── integration/    # Feature flow tests
│   │   └── e2e/            # End-to-end tests (Patrol)
│   ├── tools/              # Development tools
│   │   ├── run_tests.sh    # Comprehensive test runner
│   │   └── ai_test_validator.py  # AI-powered test analysis
│   ├── assets/             # Images, animations, fonts
│   │   ├── animations/     # Lottie JSON files
│   │   └── images/         # Logo and assets
│   ├── pubspec.yaml        # Flutter dependencies
│   └── docs/               # Documentation
│       ├── ARCHITECTURE.md  # Clean architecture guide
│       ├── API.md          # Backend API reference
│       └── USER_GUIDE.md   # User manual
├── Assets/                  # Shared project assets
│   └── Logo.jpeg           # GrabTube logo
├── Android-Client/          # Placeholder (superseded by Flutter-Client)
├── Desktop-Client/          # Placeholder (superseded by Flutter-Client)
├── iOS-Client/              # Placeholder (superseded by Flutter-Client)
├── Upstreams/              # Git submodules (upstream dependencies)
├── CLAUDE.md               # This file - guidance for Claude Code
└── README.md               # Project overview
```

### File Naming Conventions

**Flutter/Dart**:
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/functions: `camelCase`
- Constants: `camelCase` or `SCREAMING_SNAKE_CASE`
- Generated files: `*.g.dart`, `*.config.dart`
- BLoC files: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- Test files: `*_test.dart` (mirrors source file name)

**Python**:
- Files: `snake_case.py`
- Classes: `PascalCase`
- Functions/variables: `snake_case`
- Constants: `SCREAMING_SNAKE_CASE`

**Angular/TypeScript**:
- Files: `kebab-case.ts`
- Components: `kebab-case.component.ts`
- Services: `kebab-case.service.ts`
- Classes: `PascalCase`
- Variables/functions: `camelCase`

## API Endpoints Reference

### HTTP Endpoints (Backend)
- `POST /add` - Add download (params: url, quality, format, folder, auto_start)
- `GET /queue` - Get active downloads
- `GET /done` - Get completed downloads
- `GET /pending` - Get pending downloads (auto_start=False)
- `POST /delete` - Delete download by ID
- `POST /start` - Start pending download by ID
- `POST /clear` - Clear completed downloads
- `GET /history` - Get download history
- `GET /info` - Get video info without downloading

### WebSocket Events (Socket.IO)
- `connect` - Client connects to server
- `added` - Download added to queue (server → client)
- `updated` - Download progress update (server → client)
- `completed` - Download finished (server → client)
- `canceled` - Download canceled (server → client)
- `cleared` - Queue cleared (server → client)

## Branding and Animations

### Logo and Brand Colors
GrabTube uses a consistent brand identity across all clients:

**Logo**: `Assets/Logo.jpeg` - Red rounded rectangle with white download arrow
- **Primary Red**: `#E74C3C` - Main brand color (background)
- **Dark Charcoal**: `#2C3E50` - Arrow outline, dark theme background
- **White**: `#FFFFFF` - Arrow fill, light theme background
- **Light Gray**: `#ECF0F1` - Dark theme text

### Lottie Animations

The project includes two custom Lottie animations matching the logo design:

#### Splash Animation (`splash_logo.json`)
Located: `Flutter-Client/assets/animations/splash_logo.json`
- Animation sequence:
  1. Red rounded rectangle fades in and scales up (0-30 frames)
  2. White arrow with dark outline drops down from top (40-70 frames)
  3. Arrow settles with subtle bounce effect (70-100 frames)
  4. Final frame shows complete logo matching `Logo.jpeg`
- Duration: 2.5 seconds (150 frames @ 60fps)
- Used for: App splash screens on all platforms

#### Progress Indicator (`progress_arrow.json`)
Located: `Flutter-Client/assets/animations/progress_arrow.json`
- Features:
  - Gray arrow outline (background)
  - White arrow fill (mid-layer)
  - Red fill that animates from bottom to top (0-100 frames)
  - Progress controlled by animation frame (0% = frame 0, 100% = frame 100)
- Used for: Download progress visualization in Flutter client

### Progress Indicator Widgets (Flutter)

Three custom widgets in `lib/presentation/widgets/grabtube_progress_indicator.dart`:

1. **`GrabTubeProgressIndicator`**: Animated arrow icon that fills with progress
   - Parameters: `progress` (0.0-1.0), `size`, `showPercentage`, `textColor`
   - Uses Lottie animation for smooth visual feedback

2. **`GrabTubeLinearProgress`**: Horizontal progress bar with brand colors
   - Parameters: `progress`, `height`, `showPercentage`, `label`
   - Includes animated gradient fill and percentage text

3. **`GrabTubeCircularProgress`**: Circular progress with arrow icon in center
   - Parameters: `progress`, `size`, `strokeWidth`, `showPercentage`
   - Combines CircularProgressIndicator with animated arrow

**Usage Example**:
```dart
GrabTubeProgressIndicator(
  progress: 0.65, // 65% complete
  size: 48,
  showPercentage: true,
)
```

All progress indicators are fully tested with unit tests (`test/widget/grabtube_progress_indicator_test.dart`) and integration tests (`test/integration/progress_indicator_integration_test.dart`).

## Important Notes

- **Backend serves both frontends**: Angular build is in `ui/dist/metube/browser/`, served as static files
- **Download isolation**: Each download runs in separate Python process (multiprocessing) to isolate yt-dlp
- **Queue persistence**: Uses Python `shelve` module, stored in `STATE_DIR` (default: `/downloads/.metube`)
- **File watching**: If `YTDL_OPTIONS_FILE` is set, backend watches for changes using `watchfiles`
- **Flutter code generation**: Run `flutter pub run build_runner build` after modifying models, repositories, or DI
- **Flutter testing**: Comprehensive test suite with >80% coverage; use `./tools/run_tests.sh` before commits

## Troubleshooting

### Backend Issues

**Error: "Address already in use" when starting backend**
```bash
# Find process using port 8081
lsof -i :8081
# Kill the process
kill -9 <PID>
```

**Error: "yt-dlp not found" or download fails**
```bash
cd Web-Client
uv sync  # Re-install dependencies
uv run yt-dlp --version  # Verify installation
```

### Flutter Issues

**Error: "Missing generated files" or import errors**
```bash
cd Flutter-Client
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error: "Build failed" after Flutter upgrade**
```bash
cd Flutter-Client
flutter clean
flutter pub upgrade
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

**Error: iOS build fails with CocoaPods**
```bash
cd Flutter-Client/ios
rm -rf Pods Podfile.lock
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

**Tests failing with "Cannot find package"**
```bash
cd Flutter-Client
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
./tools/run_tests.sh
```

### Angular Issues

**Error: "Module not found" or build errors**
```bash
cd Web-Client/ui
rm -rf node_modules package-lock.json
npm install
npm run build
```

**Error: Angular dev server won't start**
```bash
cd Web-Client/ui
# Clear Angular cache
rm -rf .angular
npm run start
```

## Code Generation Requirements (Flutter)

You **MUST** run code generation after modifying:
- **Data models** (`lib/data/models/*.dart`) - Requires JSON serialization code
- **Repositories** (`lib/data/repositories/*.dart`) - Injectable annotation
- **Use cases** (`lib/domain/usecases/*.dart`) - Injectable annotation
- **BLoCs** (`lib/presentation/blocs/**/*.dart`) - Injectable annotation
- **Dependency injection** (`lib/core/di/injection.dart`) - DI configuration

**When to run**:
```bash
# After creating/modifying models, repos, use cases, or BLoCs
flutter pub run build_runner build --delete-conflicting-outputs

# During active development (auto-rebuilds on changes)
flutter pub run build_runner watch --delete-conflicting-outputs
```

**Common generated files**:
- `*.g.dart` - JSON serialization (json_serializable)
- `*.config.dart` - Dependency injection (injectable/get_it)
- `injection.config.dart` - DI container configuration
