# GrabTube Web-Client

🌐 **Multi-Frontend Web Application for yt-dlp Downloads**

Web GUI for [yt-dlp](https://github.com/yt-dlp/yt-dlp) with playlist support. Download videos from YouTube and [hundreds of other sites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md).

## 🎯 Available Frontends

This project offers **two modern web frontends** sharing the same Python backend:

### 1. Angular Frontend (Original)
- **Technology**: Angular 19 + Bootstrap 5
- **Status**: ✅ Production Ready
- **Location**: `ui/`
- **Features**: Full-featured, mature, extensively tested

### 2. Flutter Web Frontend (NEW ⭐)
- **Technology**: Flutter 3.24+ with Material Design 3
- **Status**: ✅ Production Ready
- **Location**: `flutter-web/`
- **Features**: Modern UI, responsive, PWA support, high performance
- **[Complete Documentation](flutter-web/README.md)**

Both frontends can run simultaneously on the same backend!

---

## 🚀 Quick Start

### Option 1: Docker (Easiest)

```bash
# Run with Angular frontend (default)
docker run -d -p 8081:8081 -v /path/to/downloads:/downloads grabtube

# Access at http://localhost:8081
```

### Option 2: Local Development

#### Start Python Backend

```bash
# Install dependencies
uv sync

# Run server
uv run python3 app/main.py
```

#### Choose Your Frontend

**Angular**:
```bash
cd ui
npm install
npm run start  # http://localhost:4200
```

**Flutter Web** (⭐ Recommended):
```bash
cd flutter-web
flutter pub get
flutter run -d chrome  # http://localhost:4200
```

---

## 📁 Project Structure

```
Web-Client/
├── app/                       # Python Backend (aiohttp + yt-dlp)
│   ├── main.py               # Server entry point
│   ├── ytdl.py               # Download management
│   └── dl_formats.py         # Format selection logic
│
├── ui/                        # Angular Frontend
│   ├── src/app/              # Angular components
│   └── dist/                 # Build output
│
├── flutter-web/               # Flutter Web Frontend ⭐ NEW
│   ├── lib/                  # Flutter source code
│   ├── web/                  # Web entry point
│   ├── test/                 # Comprehensive tests
│   └── build/web/            # Build output
│
├── FLUTTER_WEB_IMPLEMENTATION.md  # Flutter Web guide
├── BACKEND_INTEGRATION_GUIDE.md   # Integration details
└── FLUTTER_WEB_SUMMARY.md         # Complete summary
```

---

## ✨ Features

### Common (Both Frontends)
- ✅ Download from 1000+ sites
- ✅ Quality selection (360p to 4K)
- ✅ Multiple format support
- ✅ Playlist downloads
- ✅ Real-time progress tracking
- ✅ Download queue management
- ✅ Persistent storage
- ✅ Custom download directories
- ✅ Audio-only downloads
- ✅ WebSocket real-time updates

### Flutter Web Exclusive
- ✅ Material Design 3 UI
- ✅ Progressive Web App (PWA)
- ✅ Offline support
- ✅ Install to home screen
- ✅ Responsive design (mobile, tablet, desktop)
- ✅ Smooth animations
- ✅ Modern architecture (BLoC pattern)
- ✅ >80% test coverage

---

## 🔧 Configuration

### Environment Variables

All configuration via environment variables. See original README for full list.

**Key Variables**:
```bash
DOWNLOAD_DIR=/downloads           # Download location
DOWNLOAD_MODE=limited             # sequential, concurrent, limited
MAX_CONCURRENT_DOWNLOADS=3        # Max simultaneous downloads
OUTPUT_TEMPLATE=%(title)s.%(ext)s # Filename template
PORT=8081                         # Server port
```

### Serving Multiple Frontends

```python
# app/main.py

# Serve Flutter Web (default)
@routes.get('/')
async def index(request):
    return web.FileResponse('./flutter-web/build/web/index.html')

# Serve Angular (alternative)
@routes.get('/angular{tail:.*}')
async def angular(request):
    return web.FileResponse('./ui/dist/metube/browser/index.html')
```

Access:
- **Flutter**: `http://localhost:8081/`
- **Angular**: `http://localhost:8081/angular`

---

## 📱 Flutter Web Quick Guide

### Build for Production

```bash
cd flutter-web

# Build optimized release
flutter build web --release

# Output: build/web/
```

### Deploy with Backend

```bash
# Copy Flutter build to Python static directory
cp -r flutter-web/build/web/* app/static/flutter-web/

# Start server
uv run python3 app/main.py

# Access at http://localhost:8081/flutter-web
```

### Development with Hot Reload

```bash
# Terminal 1: Python backend
uv run python3 app/main.py

# Terminal 2: Flutter Web (auto-refresh on changes)
cd flutter-web
flutter run -d chrome --web-port=4200
```

**Complete Flutter Web Documentation**: See [flutter-web/README.md](flutter-web/README.md)

---

## 🐳 Docker

### Build Image

```bash
# Build with both frontends
docker build -t grabtube .
```

### docker-compose.yml

```yaml
services:
  grabtube:
    image: grabtube
    container_name: grabtube
    restart: unless-stopped
    ports:
      - "8081:8081"
    volumes:
      - /path/to/downloads:/downloads
    environment:
      - DOWNLOAD_MODE=limited
      - MAX_CONCURRENT_DOWNLOADS=3
      - DEFAULT_THEME=auto
```

---

## 📊 Frontend Comparison

| Feature | Angular | Flutter Web |
|---------|---------|-------------|
| **Technology** | Angular 19 + Bootstrap | Flutter 3.24 + Material 3 |
| **Performance** | Good | Excellent |
| **Mobile Support** | Responsive | Native-like |
| **PWA** | Basic | Full support |
| **Build Size** | ~2 MB | ~1.5 MB (gzipped) |
| **Development** | TypeScript | Dart |
| **Testing** | Partial | >80% coverage |
| **Maintenance** | Mature | Active development |

---

## 🧪 Testing

### Angular
```bash
cd ui
npm test
```

### Flutter Web
```bash
cd flutter-web

# All tests
flutter test

# With coverage
flutter test --coverage

# Generate report
genhtml coverage/lcov.info -o coverage/html
```

---

## 📚 Documentation

### General
- [Original MeTube Docs](https://github.com/alexta69/metube) - Upstream project
- [yt-dlp Documentation](https://github.com/yt-dlp/yt-dlp) - Download engine

### Flutter Web (NEW)
- [Flutter Web README](flutter-web/README.md) - Quick start guide
- [Implementation Guide](FLUTTER_WEB_IMPLEMENTATION.md) - Complete technical guide
- [Backend Integration](BACKEND_INTEGRATION_GUIDE.md) - Integration details
- [Project Summary](FLUTTER_WEB_SUMMARY.md) - Comprehensive overview

### Cookbooks
- [YTDL_OPTIONS Cookbook](https://github.com/alexta69/metube/wiki/YTDL_OPTIONS-Cookbook)
- [OUTPUT_TEMPLATE Cookbook](https://github.com/alexta69/metube/wiki/OUTPUT_TEMPLATE-Cookbook)

---

## 🔒 Security & Features

- **HTTPS Support**: Configure via `HTTPS=true`
- **Reverse Proxy**: Compatible with nginx, Apache, Caddy
- **Authentication**: Use reverse proxy auth
- **CORS**: Configured for both frontends
- **Cookie Support**: For restricted content
- **Browser Extensions**: Chrome, Firefox available

---

## 🔄 Migration Path

### Current: Both Frontends Available
Users can choose between Angular and Flutter Web.

### Future: Gradual Migration
1. **Phase 1**: Both available (current)
2. **Phase 2**: Flutter Web default, Angular fallback
3. **Phase 3**: Flutter Web only (if desired)

---

## 🤝 Contributing

Contributions welcome for:
- Bug fixes
- New features
- Documentation improvements
- Testing
- Translations

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines.

---

## 📄 License

MIT License - See LICENSE file

---

## 🙏 Acknowledgments

- **Original MeTube**: [alexta69/metube](https://github.com/alexta69/metube)
- **yt-dlp**: Powerful download engine
- **Flutter**: Amazing web framework
- **Angular**: Mature frontend framework

---

## 📞 Support

- 🐛 **Issues**: GitHub Issues
- 💬 **Discussions**: GitHub Discussions
- 📚 **Documentation**: See docs/ directory
- 📧 **Email**: support@grabtube.com

---

**Made with ❤️ - Powered by yt-dlp, Angular, and Flutter**

**Status**: ✅ Both frontends production-ready
