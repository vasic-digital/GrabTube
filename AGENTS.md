# GrabTube Development Guidelines

## Quick Start

This is a multi-platform YouTube/tube services downloader with:
- **Web-Client**: Python backend + Angular frontend (read-only submodule)
- **Flutter-Client**: Cross-platform client (primary development focus)
- Legacy clients: Android-Client, Desktop-Client, iOS-Client (deprecated)

## Essential Commands

### Root Level
```bash
# Build all applications
./build-all.sh

# Test all applications
./test-all.sh

# Verify environment
./verify-environment.sh
```

### Flutter Client (Primary Development)
```bash
cd Flutter-Client

# Dependencies and code generation
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Development
flutter run                    # Run on current platform
flutter analyze                # Code analysis
flutter test                   # Run tests

# Testing (use comprehensive test runner)
./tools/run_tests.sh           # All test suites with coverage
flutter test test/unit         # Unit tests only
flutter test test/widget        # Widget tests only
flutter test test/integration  # Integration tests only
patrol test                   # E2E tests

# Building
flutter build apk --release
flutter build ios --release
flutter build web --release
flutter build linux --release
flutter build windows --release
flutter build macos --release

# AI Test Validation
python3 tools/ai_test_validator.py
```

### Python Backend (Web-Client)
```bash
cd Web-Client

# Dependencies
uv sync                        # Install dependencies
uv sync --dev                 # Include dev dependencies

# Development
uv run python3 app/main.py    # Start server (port 8081)
uv run pylint app/           # Linting
uv run python -m pytest app/  # Run tests
```

### Angular Frontend (Web-Client/ui)
```bash
cd Web-Client/ui

# Dependencies
npm install

# Development
npm run start                # Dev server (port 4200)
npm run build                # Production build
npm test                     # Unit tests
npm run lint                 # ESLint
npm run e2e                  # End-to-end tests
```

### Docker
```bash
cd Web-Client
docker build -t grabtube .
docker run -d -p 8081:8081 -v /path/to/downloads:/downloads grabtube
```

## Project Structure

### Flutter Client Architecture (Clean Architecture + BLoC)
```
Flutter-Client/
├── lib/
│   ├── core/               # DI, network, constants, utils
│   ├── data/               # Models, repository implementations
│   ├── domain/             # Entities, repository interfaces, use cases
│   └── presentation/       # BLoCs, pages, widgets
├── test/
│   ├── unit/              # Business logic tests
│   ├── widget/            # UI component tests
│   ├── integration/       # Feature flow tests
│   └── e2e/              # Complete user journey tests
└── tools/                # Test scripts and utilities
```

### Web-Client (Backend + Frontend)
```
Web-Client/
├── app/                   # Python backend (aiohttp + Socket.IO)
│   ├── main.py           # Server entry point
│   ├── ytdl.py           # Download queue management
│   └── dl_formats.py     # yt-dlp format handling
├── ui/                   # Angular 19 frontend
│   ├── src/app/          # Components and services
│   └── dist/metube/      # Build output
└── pyproject.toml        # Python dependencies
```

## Code Conventions

### Flutter/Dart
- **Lint rules**: `very_good_analysis` with custom rules
- **Import style**: Always use package imports (`import 'package:grabtube/...'`)
- **Quotes**: Single quotes only
- **Constructors**: Use `const` where possible
- **State management**: BLoC pattern with flutter_bloc
- **DI**: get_it + injectable
- **JSON serialization**: json_annotation with build_runner generation
- **Models**: Use Equatable for value equality
- **Testing**: mocktail for mocking, Patrol for E2E
- **File organization**: Clean Architecture strictly enforced

### Python
- **Package manager**: uv (not pip)
- **Style**: PEP 8 with pylint enforcement
- **Async**: aiohttp for web server, async/await throughout
- **Type hints**: Required for all functions
- **Testing**: pytest for unit tests

### Angular
- **Framework**: Angular 19 with TypeScript
- **Style**: ESLint + TSLint configuration
- **Testing**: Karma + Jasmine for unit tests

## Testing Strategy

### Flutter (Comprehensive Coverage >80%)
1. **Unit Tests**: Test business logic, use cases, models
2. **Widget Tests**: Test individual UI components
3. **Integration Tests**: Test feature flows and interactions
4. **E2E Tests**: Test complete user journeys with Patrol
5. **AI Validation**: Automated test quality assessment

### Python Backend
- Pylint for code quality
- pytest for unit tests
- Integration tests with test servers

## Important Gotchas

1. **Web-Client is Read-Only**: Never modify directly - it's a submodule of upstream MeTube
2. **Code Generation Required**: After modifying models, repositories, or DI, run:
   `flutter pub run build_runner build --delete-conflicting-outputs`
3. **Flutter Wrapper**: Use `./flutter_wrapper.sh` instead of direct flutter commands in scripts
4. **Test Dependencies**: Python integration requires Python 3.13+ with uv
5. **Android Emulator**: Required for some integration tests (managed by `scripts/manage_emulator.sh`)
6. **Brand Colors**: Always use #E74C3C (red), #2C3E50 (dark), #FFFFFF (white)
7. **Progress Indicators**: Use custom GrabTubeProgressIndicator widgets with Lottie animations

## Environment Variables (Backend)
- `DOWNLOAD_DIR`: Where downloads are saved (default: `/downloads`)
- `DOWNLOAD_MODE`: `sequential`, `concurrent`, or `limited` (default)
- `MAX_CONCURRENT_DOWNLOADS`: Limit for limited mode (default: 3)
- `YTDL_OPTIONS`: JSON string of yt-dlp options
- `OUTPUT_TEMPLATE`: Filename template (default: `%(title)s.%(ext)s`)
- `PORT`: Server port (default: 8081)

## Key Dependencies

### Flutter
- flutter_bloc: State management
- dio: HTTP client
- socket_io_client: WebSocket for real-time updates
- hive: Local storage
- get_it + injectable: Dependency injection
- patrol: E2E testing

### Python
- aiohttp: Async web server
- python-socketio: WebSocket support
- yt-dlp: Video downloader backend
- uv: Package manager

### Angular
- Angular 19: Frontend framework
- ngx-socket-io: WebSocket client
- Bootstrap 5: UI framework

## Development Workflow

1. **Setup**: Run `./verify-environment.sh` to check prerequisites
2. **Development**: Primary work in Flutter-Client
3. **Testing**: Always run `./tools/run_tests.sh` before commits
4. **Building**: Use `./build-all.sh` for comprehensive builds
5. **Code Review**: Ensure >80% test coverage and no lint issues

## API Reference

### Backend Endpoints
- `POST /add`: Add download
- `GET /queue`: Get active downloads
- `GET /done`: Get completed downloads
- `POST /delete`: Delete download
- `GET /info`: Get video info

### WebSocket Events
- `added`: Download added to queue
- `updated`: Progress update
- `completed`: Download finished
- `canceled`: Download canceled
- `cleared`: Queue cleared

## Debugging Tips

1. **Flutter**: Use `flutter logs` for device logs
2. **Backend**: Check Docker logs with `docker logs <container>`
3. **WebSocket**: Monitor events in browser dev tools
4. **Test Failures**: Check AI validator output for specific issues
5. **Build Issues**: Verify environment with `./verify-environment.sh`

## Documentation

- `CLAUDE.md`: Detailed architecture and implementation
- `Flutter-Client/docs/`: API and architecture docs
- `FLUTTER_WEB_*.md`: Web implementation details
- `*_FEATURE.md`: Feature-specific documentation

## Deployment

- Docker: Multi-stage build (Node for Angular, Python for backend)
- Flutter: Platform-specific builds with proper signing
- CI/CD: GitHub Actions for automated testing and building

## Brand Assets

- Logo: `Assets/Logo.jpeg`
- Splash animation: `Flutter-Client/assets/animations/splash_logo.json`
- Progress animation: `Flutter-Client/assets/animations/progress_arrow.json`
- Always maintain consistent branding across platforms