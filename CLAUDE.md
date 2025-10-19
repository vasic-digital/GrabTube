# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GrabTube is a multi-platform tube services downloader - a GUI for yt-dlp with playlist support. The project consists of:
- **Web-Client**: Python (aiohttp) backend + Angular 19 frontend - production ready
- **Flutter-Client**: Cross-platform client (Android, iOS, Windows, macOS, Linux) - production ready with >80% test coverage
- **Android-Client**, **Desktop-Client**, **iOS-Client**: Placeholder directories (superseded by Flutter-Client)

The Web-Client is a fork/variant of MeTube. Both clients communicate with the same Python backend to download videos from YouTube and 1000+ sites supported by yt-dlp.

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

## Development Commands

### Python Backend (Web-Client/)

**Prerequisites**: Python 3.13, uv package manager

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

# Run code generation (for JSON serialization, DI, etc.)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on current device/platform
flutter run

# Run on specific platform
flutter run -d chrome              # Web
flutter run -d macos              # macOS
flutter run -d windows            # Windows

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
patrol test                        # E2E tests

# Run AI-powered test validation
python3 tools/ai_test_validator.py

# Code analysis
flutter analyze
```

### Docker (Web-Client/)

```bash
cd Web-Client

# Build Docker image
docker build -t grabtube .

# Run container
docker run -d -p 8081:8081 -v /path/to/downloads:/downloads grabtube

# Run with custom options
docker run -d \
  -p 8081:8081 \
  -v /path/to/downloads:/downloads \
  -e DOWNLOAD_MODE=limited \
  -e MAX_CONCURRENT_DOWNLOADS=5 \
  grabtube
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

## Testing Considerations

When testing yt-dlp functionality, you can exec into a running Docker container:
```bash
docker exec -ti <container_name> sh
cd /downloads
yt-dlp --help
```

This allows testing yt-dlp directly with the same environment as the application.

## Project Structure

```
GrabTube/
├── Web-Client/               # Python backend + Angular frontend
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
│   │   ├── data/            # Models, repositories
│   │   ├── domain/          # Entities, use cases
│   │   └── presentation/    # BLoC, pages, widgets
│   ├── test/                # Unit, widget, integration tests
│   ├── tools/               # Testing scripts, AI validator
│   ├── pubspec.yaml         # Flutter dependencies
│   └── docs/                # Architecture, API, user guides
├── Android-Client/          # Placeholder (use Flutter-Client instead)
├── Desktop-Client/          # Placeholder (use Flutter-Client instead)
├── iOS-Client/              # Placeholder (use Flutter-Client instead)
├── Upstreams/               # Git submodules (upstream dependencies)
└── CLAUDE.md               # This file
```

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

## Important Notes

- **Backend serves both frontends**: Angular build is in `ui/dist/metube/browser/`, served as static files
- **Download isolation**: Each download runs in separate Python process (multiprocessing) to isolate yt-dlp
- **Queue persistence**: Uses Python `shelve` module, stored in `STATE_DIR` (default: `/downloads/.metube`)
- **File watching**: If `YTDL_OPTIONS_FILE` is set, backend watches for changes using `watchfiles`
- **Flutter code generation**: Run `flutter pub run build_runner build` after modifying models, repositories, or DI
- **Flutter testing**: Comprehensive test suite with >80% coverage; use `./tools/run_tests.sh` before commits
