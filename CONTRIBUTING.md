# Contributing to GrabTube

Thank you for your interest in contributing to GrabTube! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Commit Message Guidelines](#commit-message-guidelines)
- [Review Process](#review-process)

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to ensure a welcoming environment for all contributors.

## Getting Started

### Prerequisites

Before contributing, ensure you have the following installed:

- **Flutter SDK**: 3.24+ ([Installation Guide](https://flutter.dev/docs/get-started/install))
- **Dart SDK**: 3.5+ (included with Flutter)
- **Python**: 3.13+ ([Download](https://www.python.org/downloads/))
- **uv**: Python package manager (`pip install uv`)
- **Node.js**: LTS version ([Download](https://nodejs.org/))
- **Android Studio**: For Android development (optional)
- **Xcode**: For iOS/macOS development (macOS only, optional)
- **Git**: For version control

### First Steps

1. **Fork the repository** on GitHub
2. **Clone your fork**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/GrabTube.git
   cd GrabTube
   ```
3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/GrabTube.git
   ```
4. **Read the documentation**:
   - [START_HERE.md](START_HERE.md) - Quick overview
   - [IMPLEMENTATION_QUICK_START.md](IMPLEMENTATION_QUICK_START.md) - Development guide
   - [DETAILED_IMPLEMENTATION_PLAN.md](DETAILED_IMPLEMENTATION_PLAN.md) - Comprehensive roadmap

## Development Setup

### Flutter Client

```bash
cd Flutter-Client

# Install dependencies
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Run on your device
flutter run

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Web Client (Backend + Angular)

#### Backend (Python)
```bash
cd Web-Client

# Install dependencies
uv sync

# Run server
uv run python3 app/main.py
```

#### Frontend (Angular)
```bash
cd Web-Client/ui

# Install dependencies
npm install

# Run development server
npm run start

# Build for production
npm run build
```

### Android Native Client

```bash
cd Android-Client

# Build the project
./gradlew build

# Run tests
./gradlew test

# Run on device/emulator
./gradlew installDebug
```

## Project Structure

```
GrabTube/
├── Flutter-Client/     # Cross-platform Flutter client
│   ├── lib/
│   │   ├── core/       # DI, network, constants
│   │   ├── data/       # Models, repositories
│   │   ├── domain/     # Entities, use cases
│   │   └── presentation/ # BLoC, pages, widgets
│   └── test/           # Comprehensive test suite
├── Web-Client/         # Python backend + Angular frontend
│   ├── app/            # Python aiohttp server
│   └── ui/             # Angular 19 frontend
├── Android-Client/     # Native Kotlin Android app
└── docs/               # Project documentation
```

See [CLAUDE.md](CLAUDE.md) for detailed architecture information.

## How to Contribute

### Areas of Contribution

1. **Feature Implementation** (Priority: High)
   - See [DETAILED_IMPLEMENTATION_PLAN.md](DETAILED_IMPLEMENTATION_PLAN.md) Phase 1
   - Implement missing entities, repositories, use cases, BLoCs, pages
   - Follow the templates in [Flutter-Client/TEMPLATES.md](Flutter-Client/TEMPLATES.md)

2. **Testing** (Priority: High)
   - Add missing unit tests
   - Add missing widget tests
   - Improve test coverage (target: 100%)
   - See [DETAILED_IMPLEMENTATION_PLAN.md](DETAILED_IMPLEMENTATION_PLAN.md) Phase 2

3. **Documentation** (Priority: Medium)
   - Write Android client documentation
   - Improve API documentation
   - Create user guides
   - See [DETAILED_IMPLEMENTATION_PLAN.md](DETAILED_IMPLEMENTATION_PLAN.md) Phase 3

4. **Website Development** (Priority: Medium)
   - Build marketing website
   - Create documentation portal
   - See [DETAILED_IMPLEMENTATION_PLAN.md](DETAILED_IMPLEMENTATION_PLAN.md) Phase 4

5. **Video Tutorials** (Priority: Low)
   - Create user tutorial videos
   - Create developer course videos
   - See [DETAILED_IMPLEMENTATION_PLAN.md](DETAILED_IMPLEMENTATION_PLAN.md) Phase 5

### Choosing What to Work On

1. Check [PROGRESS_TRACKER.md](PROGRESS_TRACKER.md) for current status
2. Look for unchecked items in your area of expertise
3. Check GitHub Issues for open tasks
4. Run `./scripts/check_progress.sh` to see what's missing
5. Comment on the issue or create a new one to claim the task

## Coding Standards

### Dart/Flutter

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use **Clean Architecture** pattern (Domain → Data → Presentation)
- Use **BLoC** pattern for state management
- Use **Dependency Injection** with get_it + injectable
- Run `flutter analyze` before committing
- Run `dart format .` to format code

**Example Entity**:
```dart
import 'package:equatable/equatable.dart';

class Download extends Equatable {
  final String id;
  final String url;
  final DownloadStatus status;

  const Download({
    required this.id,
    required this.url,
    required this.status,
  });

  @override
  List<Object?> get props => [id, url, status];
}
```

### Python

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guide
- Use type hints (Python 3.10+ syntax)
- Run `uv run pylint app/` before committing
- Use async/await for asynchronous code
- Document all public functions with docstrings

**Example Function**:
```python
async def add_download(url: str, quality: str) -> Download:
    """
    Add a new download to the queue.

    Args:
        url: The URL to download from
        quality: The desired quality (e.g., '1080p', 'best')

    Returns:
        Download: The created download object

    Raises:
        ValueError: If URL is invalid
    """
    # Implementation
```

### TypeScript/Angular

- Follow [Angular Style Guide](https://angular.io/guide/styleguide)
- Use TypeScript strict mode
- Run `npm run lint` before committing
- Use RxJS for reactive programming
- Use OnPush change detection where possible

### Kotlin

- Follow [Kotlin Coding Conventions](https://kotlinlang.org/docs/coding-conventions.html)
- Use MVVM architecture pattern
- Use Kotlin Coroutines for async operations
- Run `./gradlew ktlintCheck` before committing

## Testing Requirements

**ALL code contributions MUST include tests.**

### Flutter Tests

1. **Unit Tests** (Required for all business logic)
   ```dart
   test('should return download when repository call succeeds', () async {
     // Arrange
     when(() => mockRepository.getDownload(any()))
         .thenAnswer((_) async => tDownload);

     // Act
     final result = await useCase(GetDownloadParams(id: '123'));

     // Assert
     expect(result, Right(tDownload));
   });
   ```

2. **Widget Tests** (Required for all widgets)
   ```dart
   testWidgets('should display download title', (tester) async {
     await tester.pumpWidget(MaterialApp(
       home: DownloadItem(download: tDownload),
     ));

     expect(find.text('Test Download'), findsOneWidget);
   });
   ```

3. **Integration Tests** (Required for critical flows)
   ```dart
   testWidgets('should complete download flow', (tester) async {
     // Test full user journey
   });
   ```

### Coverage Requirements

- **Minimum coverage**: 80%
- **Target coverage**: 100% (excluding generated files)
- **Run coverage**: `flutter test --coverage`
- **View coverage**: `genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html`

### Python Tests

- Use `pytest` for testing
- Minimum coverage: 80%
- Include unit and integration tests

### Test Before Submit

```bash
# Flutter
cd Flutter-Client
./tools/run_tests.sh

# Python
cd Web-Client
uv run pytest

# Angular
cd Web-Client/ui
npm test
```

## Documentation

### Code Documentation

- **Dart**: Use `///` doc comments for public APIs
- **Python**: Use docstrings for all public functions
- **TypeScript**: Use JSDoc comments
- **Kotlin**: Use KDoc comments

### Documentation Files

When adding features, update:
- README.md (if user-facing feature)
- API documentation (if adding new APIs)
- User guides (if changing UI/UX)
- CHANGELOG.md (always update with changes)

## Pull Request Process

### Before Creating a PR

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes**:
   - Follow coding standards
   - Add tests
   - Update documentation

3. **Run all tests**:
   ```bash
   ./tools/run_tests.sh  # Flutter
   flutter analyze       # Lint
   dart format .         # Format
   ```

4. **Commit your changes**:
   - Follow commit message guidelines (see below)
   - Make small, focused commits

5. **Update your branch** with latest upstream:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

### Creating the PR

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Open a Pull Request** on GitHub with:
   - **Title**: Clear, descriptive title (e.g., "feat: Add QR scanner functionality")
   - **Description**: What, why, how
   - **Related issues**: Link to related issues (#123)
   - **Screenshots**: If UI changes
   - **Testing**: How you tested the changes
   - **Checklist**: Verify all items completed

### PR Template

```markdown
## Description
Brief description of changes

## Related Issues
Closes #123

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Widget tests added/updated
- [ ] Integration tests added/updated
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests pass locally
- [ ] Coverage maintained/improved
```

## Commit Message Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes

### Examples

```bash
feat(qr-scanner): add QR code scanning functionality

Implement QR code scanner using mobile_scanner package.
Supports scanning from camera and image gallery.
Validates scanned URLs before adding to downloads.

Closes #45

---

fix(download): prevent duplicate downloads

Check for existing downloads before adding new ones.
Show error message if URL already exists in queue.

Fixes #78

---

docs(readme): update installation instructions

Add Flutter 3.24 requirement.
Add uv installation step for Python backend.

---

test(favorites): add unit tests for favorites repository

Add tests for add, remove, and get favorites.
Coverage increased from 85% to 92%.
```

## Review Process

### For Contributors

1. **Be responsive**: Address review comments promptly
2. **Be open**: Accept constructive criticism
3. **Be thorough**: Test edge cases
4. **Be patient**: Reviews may take time

### For Reviewers

1. **Be kind**: Provide constructive feedback
2. **Be specific**: Point out exact issues
3. **Be thorough**: Check code, tests, documentation
4. **Be timely**: Review within 2-3 business days

### Review Checklist

- [ ] Code follows project conventions
- [ ] Tests are comprehensive and passing
- [ ] Documentation is updated
- [ ] No unnecessary complexity
- [ ] Error handling is appropriate
- [ ] Performance is acceptable
- [ ] Security considerations addressed
- [ ] Accessibility considerations (if UI changes)

## Getting Help

### Resources

- **Documentation**: Check [docs/](docs/) directory
- **Implementation Guide**: See [IMPLEMENTATION_QUICK_START.md](IMPLEMENTATION_QUICK_START.md)
- **Templates**: Use [Flutter-Client/TEMPLATES.md](Flutter-Client/TEMPLATES.md)
- **Architecture**: Read [CLAUDE.md](CLAUDE.md)

### Communication

- **GitHub Issues**: For bugs, features, questions
- **Pull Requests**: For code review discussions
- **Discussions**: For general questions (if enabled)

### Common Questions

**Q: Which features should I work on?**
A: Check [PROGRESS_TRACKER.md](PROGRESS_TRACKER.md) for unchecked items. Phase 1 tasks are highest priority.

**Q: How do I run code generation?**
A: `flutter pub run build_runner build --delete-conflicting-outputs`

**Q: Tests are failing locally. What should I do?**
A: Run `flutter clean && flutter pub get`, then try again. Check [CLAUDE.md](CLAUDE.md) troubleshooting section.

**Q: Should I create an issue before starting work?**
A: Yes, especially for large features. Discuss your approach first.

**Q: Can I work on multiple features in one PR?**
A: No, keep PRs focused on a single feature or fix.

## License

By contributing to GrabTube, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing to GrabTube!** 🎉

Your efforts help make video downloading accessible and easy for everyone.
