# GrabTube Flutter Web - Quick Start Guide

This guide will get you up and running with the Flutter Web client in **under 10 minutes**.

## 🎯 Prerequisites

Before you begin, ensure you have:

- ✅ **Flutter SDK** 3.24.0 or higher ([Install Flutter](https://flutter.dev/docs/get-started/install))
- ✅ **Python** 3.13+ with `uv` package manager
- ✅ **Chrome** browser (for development)

Check your installation:

```bash
flutter --version    # Should be 3.24.0+
python3 --version    # Should be 3.13+
uv --version         # Should be installed
```

## 🚀 Quick Start (3 Steps)

### Step 1: Start the Python Backend

```bash
# From Web-Client directory
cd Web-Client

# Install Python dependencies (if not already done)
uv sync

# Start the backend server
uv run python3 app/main.py
```

You should see:
```
======== Running on http://0.0.0.0:8081 ========
```

**Leave this terminal running** ✅

### Step 2: Run Flutter Web (Development Mode)

Open a **new terminal**:

```bash
# Navigate to Flutter Web directory
cd Web-Client/flutter-web

# Install dependencies
flutter pub get

# Run in Chrome with hot reload
flutter run -d chrome --web-port=4200
```

You should see:
```
🌍 Flutter Web is running on http://localhost:4200
```

**Your browser will automatically open!** 🎉

### Step 3: Test the Application

1. **Add a Download**:
   - Enter a YouTube URL (e.g., `https://youtube.com/watch?v=dQw4w9WgXcQ`)
   - Select quality and format
   - Click "Add"

2. **Navigate Tabs**:
   - **Queue**: Active downloads
   - **Completed**: Finished downloads
   - **Pending**: Queued downloads

3. **Test Responsiveness**:
   - Resize your browser window
   - UI should adapt smoothly

## 📦 Production Build (For Deployment)

### Option A: Using Build Script (Recommended)

```bash
cd Web-Client/flutter-web

# Make script executable (first time only)
chmod +x build.sh

# Build and deploy
./build.sh
```

The script will:
1. ✅ Clean previous build
2. ✅ Get dependencies
3. ✅ Build optimized release
4. ✅ Optionally deploy to Python backend

### Option B: Manual Build

```bash
cd Web-Client/flutter-web

# Build for production
flutter build web --release

# Output will be in: build/web/
```

### Deploy to Python Backend

```bash
# Copy build to Python static directory
cd Web-Client/flutter-web
cp -r build/web/* ../app/static/flutter-web/

# Restart Python server
cd ..
uv run python3 app/main.py
```

Access at: **http://localhost:8081/flutter-web**

## 🐳 Docker Deployment

### Build Docker Image

```bash
cd Web-Client

# Build with both frontends
docker build -f Dockerfile.flutter -t grabtube-dual .
```

### Run Container

```bash
docker run -d \
  --name grabtube \
  -p 8081:8081 \
  -v /path/to/downloads:/downloads \
  grabtube-dual
```

Access:
- **Flutter Web**: http://localhost:8081/flutter-web
- **Angular**: http://localhost:8081/angular

## 🧪 Testing

### Run All Tests

```bash
cd Web-Client/flutter-web

# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate HTML coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
# or
xdg-open coverage/html/index.html  # Linux
```

### Run Specific Test Suite

```bash
# Unit tests only
flutter test test/unit

# Widget tests only
flutter test test/widget

# Integration tests only
flutter test test/integration
```

## 🎨 Development Tips

### Hot Reload

While `flutter run` is active:
- Press `r` to hot reload
- Press `R` to hot restart
- Press `h` for help
- Press `q` to quit

### DevTools

```bash
# Flutter DevTools will automatically open
# Or manually open at: http://localhost:9100
```

### Code Generation

If you modify models or add dependency injection:

```bash
# One-time generation
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-generate on changes)
flutter pub run build_runner watch
```

### Debugging

```bash
# Run with verbose logging
flutter run -d chrome --web-port=4200 -v

# Run with DevTools open
flutter run -d chrome --web-port=4200 --start-paused
```

## 📁 Project Structure

```
flutter-web/
├── lib/
│   ├── core/              # Infrastructure
│   ├── data/              # Data layer
│   ├── domain/            # Business logic
│   └── presentation/      # UI
├── test/
│   ├── unit/             # Unit tests
│   ├── widget/           # Widget tests
│   └── integration/      # Integration tests
├── web/
│   ├── index.html        # Entry point
│   └── manifest.json     # PWA config
└── pubspec.yaml          # Dependencies
```

## 🔧 Configuration

### Change API URL

Edit `lib/core/constants/app_constants.dart`:

```dart
static const String defaultServerUrl = 'http://your-server:8081';
```

### Change Theme

The app automatically follows system theme. To force a theme:

Edit `lib/presentation/app.dart`:

```dart
MaterialApp(
  themeMode: ThemeMode.light,  // or ThemeMode.dark
  // ...
)
```

## 🐛 Troubleshooting

### "Flutter not found"

```bash
# Install Flutter
# macOS/Linux
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Verify
flutter doctor
```

### "Chrome not found"

```bash
# Install Google Chrome
# Then enable web support
flutter config --enable-web
```

### CORS Errors

Add to Python backend (`app/main.py`):

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

### Build Fails

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web
```

### Port Already in Use

```bash
# Use different port
flutter run -d chrome --web-port=4300
```

## 📚 Next Steps

### Learn More

- **Architecture**: Read [FLUTTER_WEB_IMPLEMENTATION.md](FLUTTER_WEB_IMPLEMENTATION.md)
- **API Integration**: Read [BACKEND_INTEGRATION_GUIDE.md](BACKEND_INTEGRATION_GUIDE.md)
- **Complete Guide**: Read [FLUTTER_WEB_SUMMARY.md](FLUTTER_WEB_SUMMARY.md)

### Customize

1. **Add Features**: Explore `lib/presentation/pages/`
2. **Modify UI**: Edit widgets in `lib/presentation/widgets/`
3. **Add Tests**: Create tests in `test/`

### Deploy

1. **Static Hosting**: Deploy `build/web/` to Netlify, Vercel, etc.
2. **Python Backend**: Copy build to `app/static/flutter-web/`
3. **Docker**: Use `Dockerfile.flutter`
4. **Kubernetes**: See deployment docs

## ✅ Verification Checklist

After completing the quick start, verify:

- [ ] Python backend running on port 8081
- [ ] Flutter Web accessible at http://localhost:4200
- [ ] Can add a download URL
- [ ] Can switch between tabs
- [ ] Can change quality/format
- [ ] UI is responsive
- [ ] No console errors

## 🎉 Success!

You now have a fully functional Flutter Web client running!

**What's Working**:
- ✅ Modern Material Design 3 UI
- ✅ Responsive layout
- ✅ Real-time connection to backend
- ✅ Download management
- ✅ Progressive Web App features

**Next Actions**:
1. Try adding actual downloads
2. Explore the codebase
3. Run tests
4. Read the full documentation
5. Start contributing!

## 📞 Need Help?

- 🐛 **Issues**: GitHub Issues
- 📚 **Docs**: See documentation files
- 💬 **Community**: GitHub Discussions
- 📧 **Email**: dev@grabtube.com

---

**Time to Complete**: ~5-10 minutes ⏱️
**Difficulty**: Easy 🟢
**Status**: Production Ready ✅
