# GrabTube Development Guidelines

## Build/Lint/Test Commands

### Flutter Client (Flutter-Client/)
```bash
# Install dependencies
flutter pub get

# Code generation (run after model/repository changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Analysis
flutter analyze

# Run single test
flutter test test/unit/domain/entities/download_test.dart

# Run test suites
flutter test test/unit          # Unit tests
flutter test test/widget        # Widget tests
flutter test test/integration   # Integration tests
patrol test                     # E2E tests

# Run all tests with coverage
./tools/run_tests.sh
```

### Python Backend (Web-Client/)
```bash
# Install dependencies
uv sync

# Lint
uv run pylint app/

# Run server
uv run python3 app/main.py
```

### Angular Frontend (Web-Client/ui/)
```bash
# Install dependencies
npm install

# Development
npm run start

# Build
npm run build

# Test
npm test

# Lint
npm run lint
```

## Code Style Guidelines

### Dart/Flutter
- Use `very_good_analysis` lint rules (see analysis_options.yaml)
- Prefer single quotes, const constructors, final locals
- Use package imports: `import 'package:grabtube/...'`
- Follow Clean Architecture: lib/core/, lib/data/, lib/domain/, lib/presentation/
- Use BLoC pattern for state management
- All models need JSON serialization with `@JsonSerializable()`
- Use `get_it` + `injectable` for dependency injection
- Brand colors: primary `#E74C3C`, dark `#2C3E50`, white `#FFFFFF`

### Python
- Use uv package manager
- Follow PEP 8 style
- Async/await with aiohttp
- Type hints required
- Use multiprocessing for download isolation

### General
- Web-Client is read-only submodule - do not modify
- All new features go in Flutter-Client
- Run tests before commits
- Use descriptive commit messages
- Follow existing naming conventions (camelCase for variables, PascalCase for classes)