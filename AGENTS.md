# GrabTube Development Guidelines

## Commands
Flutter: `flutter pub get`, `flutter analyze`, `flutter test test/unit/domain/entities/download_test.dart`, `./tools/run_tests.sh`
Python: `uv sync`, `uv run pylint app/`, `uv run python3 app/main.py`
Angular: `npm install`, `npm run start`, `npm run build`, `npm test`, `npm run lint`

## Code Style
Dart/Flutter: very_good_analysis lint rules, single quotes, const constructors, package imports `import 'package:grabtube/...'`, Clean Architecture (lib/core/, lib/data/, lib/domain/, lib/presentation/), BLoC pattern, @JsonSerializable() models, get_it + injectable DI, brand colors #E74C3C/#2C3E50/#FFFFFF
Python: uv package manager, PEP 8, async/await with aiohttp, type hints required, multiprocessing for downloads
General: Web-Client is read-only submodule, new features in Flutter-Client, run tests before commits, camelCase variables, PascalCase classes