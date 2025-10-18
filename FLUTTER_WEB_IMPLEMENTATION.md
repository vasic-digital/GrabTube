# Flutter Web Implementation Guide

## 📋 Overview

This document provides a complete guide for the Flutter Web implementation of GrabTube, including setup, development, testing, and deployment.

## 🎯 Implementation Status

✅ **COMPLETE** - Flutter Web client ready for production

### What's Included:

1. ✅ **Complete Flutter Web Application**
   - Material Design 3 UI
   - Responsive layout (mobile, tablet, desktop)
   - Real-time WebSocket integration
   - BLoC state management
   - Clean Architecture

2. ✅ **Backend Integration**
   - HTTP API client
   - WebSocket real-time updates
   - Shared Python backend with Angular

3. ✅ **Testing Infrastructure**
   - Unit tests
   - Widget tests
   - Integration tests
   - >80% coverage target

4. ✅ **Documentation**
   - Setup guides
   - API documentation
   - Deployment instructions
   - Developer guides

## 🏗️ Project Structure

```
Web-Client/
├── app/                    # Python backend (existing)
│   ├── main.py            # aiohttp server
│   ├── ytdl.py            # Download logic
│   └── static/
│       ├── angular/       # Angular build (optional)
│       └── flutter-web/   # Flutter build (new)
│
├── ui/                     # Angular frontend (existing)
│   └── ...
│
└── flutter-web/            # Flutter Web client (NEW)
    ├── lib/
    │   ├── core/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    ├── test/
    ├── web/
    ├── pubspec.yaml
    └── README.md
```

## 📦 Installation & Setup

### Prerequisites

```bash
# Check Flutter installation
flutter doctor

# Should show:
# ✓ Flutter (Channel stable, 3.24.0+)
# ✓ Chrome - develop for the web
```

### Step 1: Install Dependencies

```bash
cd Web-Client/flutter-web

# Get Flutter packages
flutter pub get

# Run code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### Step 2: Start Python Backend

```bash
cd ../

# Install Python dependencies (if not already done)
uv sync

# Run the backend server
uv run python3 app/main.py
```

Backend will start on `http://localhost:8081`

### Step 3: Run Flutter Web

```bash
cd flutter-web

# Development mode with hot reload
flutter run -d chrome --web-port=4200

# Or build for production
flutter build web --release
```

## 🚀 Development Workflow

### 1. Code Structure

Follow Clean Architecture principles:

```dart
// Domain Layer - Business Entities
class Download {
  final String id;
  final String title;
  final DownloadStatus status;
  final double progress;
}

// Data Layer - API Models
@JsonSerializable()
class DownloadModel {
  factory DownloadModel.fromJson(Map<String, dynamic> json);
  Download toEntity();
}

// Presentation Layer - BLoC
class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  // Handle events, emit states
}

// UI Layer - Widgets
class DownloadListItem extends StatelessWidget {
  // Build UI from state
}
```

### 2. Adding New Features

```bash
# 1. Create domain entity
lib/domain/entities/new_entity.dart

# 2. Create data model
lib/data/models/new_model.dart

# 3. Add API endpoint
lib/core/network/api_client.dart

# 4. Create repository
lib/data/repositories/new_repository_impl.dart

# 5. Create BLoC
lib/presentation/blocs/new_bloc/

# 6. Create UI
lib/presentation/pages/new_page.dart

# 7. Add tests
test/unit/new_entity_test.dart
test/widget/new_page_test.dart

# 8. Run code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Code Generation

The project uses code generation for:
- JSON serialization (`json_serializable`)
- Dependency injection (`injectable`)
- API clients (`retrofit`)

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on file changes)
flutter pub run build_runner watch
```

### 4. Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/domain/entities/download_test.dart

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 5. Debugging

```bash
# Launch with DevTools
flutter run -d chrome --web-port=4200

# DevTools will open at http://localhost:9100
```

## 🎨 UI Development

### Responsive Design

The app uses `responsive_framework` for adaptive layouts:

```dart
// Automatically adapts to screen size
ResponsiveWrapper.builder(
  child: MyApp(),
  breakpoints: [
    ResponsiveBreakpoint.resize(450, name: MOBILE),
    ResponsiveBreakpoint.resize(800, name: TABLET),
    ResponsiveBreakpoint.resize(1000, name: TABLET),
    ResponsiveBreakpoint.resize(1200, name: DESKTOP),
  ],
)
```

### Material Design 3

```dart
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
)
```

### Dark Mode

Automatically follows system preference:

```dart
MaterialApp(
  theme: lightTheme,
  darkTheme: darkTheme,
  themeMode: ThemeMode.system,
)
```

## 🔌 Backend Integration

### HTTP API

```dart
@RestApi()
abstract class ApiClient {
  @POST('/add')
  Future<Map<String, dynamic>> addDownload({
    @Field('url') required String url,
  });

  @GET('/queue')
  Future<List<DownloadModel>> getQueue();
}
```

### WebSocket

```dart
class SocketClient {
  void connect() {
    _socket = io.io(serverUrl, options);

    _socket.on('updated', (data) {
      final download = DownloadModel.fromJson(data);
      _downloadUpdated.add(download);
    });
  }
}
```

### Server URL Configuration

```dart
// Default: http://localhost:8081
// Change in lib/core/constants/app_constants.dart

// Or dynamically in Settings UI
final prefs = await SharedPreferences.getInstance();
await prefs.setString('server_url', 'http://your-server:8081');
```

## 📱 Progressive Web App

### Features

1. **Install Prompt** - Users can install to home screen
2. **Offline Support** - Service worker caching
3. **App Manifest** - Icons, colors, display mode
4. **Responsive** - Works on all devices

### Configuration

Edit `web/manifest.json`:

```json
{
  "name": "GrabTube",
  "short_name": "GrabTube",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#2196F3"
}
```

## 🚢 Deployment

### Build for Production

```bash
cd Web-Client/flutter-web

# Build with HTML renderer (better compatibility)
flutter build web --release --web-renderer html

# Or CanvasKit renderer (better performance on desktop)
flutter build web --release --web-renderer canvaskit

# Output in build/web/
```

### Deployment Options

#### Option 1: Python Backend Integration

```python
# app/main.py

# Serve Flutter Web
app.router.add_static('/flutter-web',
                     path='./flutter-web/build/web',
                     name='flutter-web')

# Default route to Flutter
@routes.get('/')
async def index(request):
    return web.FileResponse('./flutter-web/build/web/index.html')

# Angular on /angular route
@routes.get('/angular{tail:.*}')
async def angular_index(request):
    return web.FileResponse('./ui/dist/metube/browser/index.html')
```

Then:

```bash
# Build Flutter
cd flutter-web
flutter build web --release

# Copy to static directory (optional)
cp -r build/web/* app/static/flutter-web/

# Start Python server
cd ..
uv run python3 app/main.py

# Access at http://localhost:8081/
```

#### Option 2: Separate Hosting

Deploy `build/web/` to any static host:

**Firebase**:
```bash
firebase deploy
```

**Netlify**:
```bash
netlify deploy --prod --dir=build/web
```

**Docker**:
```dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
```

**GitHub Pages**:
```bash
# Push build/web/ to gh-pages branch
git subtree push --prefix flutter-web/build/web origin gh-pages
```

#### Option 3: CDN

Upload to CDN (CloudFlare, AWS CloudFront) for global distribution.

### Environment Variables

Create `.env` files for different environments:

```bash
# .env.development
SERVER_URL=http://localhost:8081

# .env.production
SERVER_URL=https://your-production-server.com
```

Load in code:

```dart
const serverUrl = String.fromEnvironment(
  'SERVER_URL',
  defaultValue: 'http://localhost:8081',
);
```

Build with environment:

```bash
flutter build web --dart-define=SERVER_URL=https://your-server.com
```

## 🔧 Configuration

### App Constants

Edit `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  static const String defaultServerUrl = 'http://localhost:8081';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const int maxConcurrentDownloads = 3;
  // ... other constants
}
```

### Analysis Options

Edit `analysis_options.yaml` for code quality rules.

## 📊 Performance Optimization

### 1. Build Size

```bash
# Analyze build size
flutter build web --release --analyze-size

# Output shows size breakdown
```

### 2. Code Splitting

Flutter automatically splits code. Lazy load routes:

```dart
return MaterialApp.router(
  routerConfig: router,
);
```

### 3. Image Optimization

```dart
// Use cached images
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => CircularProgressIndicator(),
)
```

### 4. Web-Specific Optimizations

```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Web-specific code
}
```

## 🧪 Testing Strategy

### Unit Tests

Test business logic:

```dart
test('should parse download status correctly', () {
  final model = DownloadModel(status: 'downloading');
  final entity = model.toEntity();
  expect(entity.status, DownloadStatus.downloading);
});
```

### Widget Tests

Test UI components:

```dart
testWidgets('displays download title', (tester) async {
  await tester.pumpWidget(DownloadCard(download: testDownload));
  expect(find.text('Test Video'), findsOneWidget);
});
```

### Integration Tests

Test complete flows:

```dart
testWidgets('can add and display download', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.tap(find.byIcon(Icons.add));
  await tester.enterText(find.byType(TextField), testUrl);
  await tester.tap(find.text('Add'));
  expect(find.text('Test Video'), findsOneWidget);
});
```

### Running Tests

```bash
# All tests
flutter test

# Specific suite
flutter test test/unit
flutter test test/widget
flutter test test/integration

# With coverage
flutter test --coverage

# Watch mode
flutter test --watch
```

## 🐛 Troubleshooting

### Common Issues

**1. CORS Errors**

Solution: Configure backend CORS headers

```python
import aiohttp_cors

cors = aiohttp_cors.setup(app, defaults={
    "*": aiohttp_cors.ResourceOptions(
        allow_credentials=True,
        expose_headers="*",
        allow_headers="*"
    )
})
```

**2. WebSocket Connection Failed**

- Check backend is running
- Verify port is correct
- Check firewall settings

**3. Build Fails**

```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
flutter build web
```

**4. Slow Initial Load**

- Use `--web-renderer html` for better initial load
- Enable code splitting
- Optimize images
- Use service worker for caching

## 📚 Additional Resources

### Documentation

- [Flutter Web Docs](https://flutter.dev/web)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Retrofit](https://pub.dev/packages/retrofit)
- [Injectable](https://pub.dev/packages/injectable)

### Tools

- **Flutter DevTools**: Debugging and profiling
- **Chrome DevTools**: Network, performance analysis
- **Lighthouse**: PWA audit

### Best Practices

1. **Performance**: Use `const` constructors
2. **State Management**: Follow BLoC pattern
3. **Testing**: Maintain >80% coverage
4. **Code Quality**: Run `flutter analyze`
5. **Accessibility**: Use semantic widgets

## 🎓 Learning Path

### For New Developers

1. **Flutter Basics** (1-2 weeks)
   - Widgets and layouts
   - State management basics
   - Navigation

2. **Architecture** (1 week)
   - Clean Architecture
   - BLoC pattern
   - Dependency injection

3. **Web-Specific** (3-5 days)
   - Responsive design
   - PWA features
   - Web debugging

4. **GrabTube Codebase** (1 week)
   - Read architecture docs
   - Explore code structure
   - Run and debug app

### Total Time: 4-6 weeks for full proficiency

## 🤝 Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

## 📞 Support

- 🐛 **Issues**: GitHub Issues
- 💬 **Discussions**: GitHub Discussions
- 📧 **Email**: dev@grabtube.com

---

**Last Updated**: October 18, 2024
**Status**: ✅ Production Ready
