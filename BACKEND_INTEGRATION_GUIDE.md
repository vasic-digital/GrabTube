# Backend Integration Guide - Flutter Web + Python

This guide explains how to integrate the Flutter Web client with the existing Python backend.

## 📋 Overview

The Flutter Web client uses the **same Python backend** as the Angular client:
- **HTTP API**: REST endpoints for CRUD operations
- **WebSocket**: Real-time download progress updates via Socket.IO
- **Static Files**: Python serves both Angular and Flutter builds

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│         Browser (User)                   │
├─────────────────┬───────────────────────┤
│  Angular Client │  Flutter Web Client    │
│  (Port 8081)    │  (Port 8081/flutter-web)│
└─────────┬───────┴───────┬───────────────┘
          │               │
          │   HTTP + WebSocket
          │               │
     ┌────┴───────────────┴────┐
     │   Python Backend         │
     │   (aiohttp + Socket.IO)  │
     │   Port 8081              │
     └──────────┬───────────────┘
                │
          ┌─────┴─────┐
          │  yt-dlp   │
          └───────────┘
```

## 🔌 Python Backend Modifications

### Option 1: Serve Both Clients (Recommended)

Edit `app/main.py` to serve both Angular and Flutter:

```python
from aiohttp import web
import aiohttp_cors

# ... existing imports ...

def create_app():
    app = web.Application()

    # Setup CORS for Flutter Web
    cors = aiohttp_cors.setup(app, defaults={
        "*": aiohttp_cors.ResourceOptions(
            allow_credentials=True,
            expose_headers="*",
            allow_headers="*",
            allow_methods="*"
        )
    })

    # API routes (existing)
    routes = web.RouteTableDef()

    # ... existing API routes ...

    # Serve Flutter Web (new)
    app.router.add_static(
        '/flutter-web',
        path='./flutter-web/build/web',
        name='flutter_web'
    )

    # Serve Angular (existing)
    app.router.add_static(
        '/angular',
        path='./ui/dist/metube/browser',
        name='angular'
    )

    # Default route - choose which client to serve
    @routes.get('/')
    async def index(request):
        # Option A: Serve Flutter by default
        return web.FileResponse('./flutter-web/build/web/index.html')

        # Option B: Serve Angular by default
        # return web.FileResponse('./ui/dist/metube/browser/index.html')

        # Option C: Redirect to client selection page
        # return web.Response(text='''
        #     <html>
        #     <body>
        #         <h1>Choose Client</h1>
        #         <a href="/angular">Angular Client</a><br>
        #         <a href="/flutter-web">Flutter Web Client</a>
        #     </body>
        #     </html>
        # ''', content_type='text/html')

    # Apply CORS to all routes
    for route in list(app.router.routes()):
        cors.add(route)

    app.add_routes(routes)
    return app

if __name__ == '__main__':
    app = create_app()
    web.run_app(app, host='0.0.0.0', port=8081)
```

### Option 2: Separate Ports

Run Flutter Web on a different port:

```python
# app/flutter_server.py (NEW FILE)
from aiohttp import web
import aiohttp_cors

async def create_flutter_app():
    app = web.Application()

    # Setup CORS
    cors = aiohttp_cors.setup(app, defaults={
        "*": aiohttp_cors.ResourceOptions(
            allow_credentials=True,
            expose_headers="*",
            allow_headers="*"
        )
    })

    # Serve Flutter Web
    app.router.add_static(
        '/',
        path='./flutter-web/build/web',
        name='flutter_web'
    )

    @app.route.get('/{tail:.*}')
    async def catch_all(request):
        return web.FileResponse('./flutter-web/build/web/index.html')

    return app

if __name__ == '__main__':
    app = create_flutter_app()
    web.run_app(app, host='0.0.0.0', port=4200)
```

Then run both servers:

```bash
# Terminal 1 - Main backend
uv run python3 app/main.py  # Port 8081

# Terminal 2 - Flutter Web
uv run python3 app/flutter_server.py  # Port 4200
```

## 🔐 CORS Configuration

For Flutter Web to communicate with the Python backend:

```python
# app/main.py

import aiohttp_cors

def create_app():
    app = web.Application()

    # Configure CORS
    cors = aiohttp_cors.setup(app, defaults={
        # Allow all origins (development)
        "*": aiohttp_cors.ResourceOptions(
            allow_credentials=True,
            expose_headers="*",
            allow_headers="*",
            allow_methods=["GET", "POST", "OPTIONS"]
        ),

        # Or specific origins (production)
        "https://your-domain.com": aiohttp_cors.ResourceOptions(
            allow_credentials=True,
            expose_headers="*",
            allow_headers="*",
        ),
    })

    # Apply CORS to routes
    for route in list(app.router.routes()):
        cors.add(route)
```

## 📡 API Endpoints

Flutter Web uses these existing endpoints:

### HTTP Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/add` | Add download |
| GET | `/queue` | Get active downloads |
| GET | `/done` | Get completed downloads |
| GET | `/pending` | Get pending downloads |
| POST | `/delete` | Delete downloads |
| POST | `/start` | Start pending downloads |
| POST | `/clear` | Clear completed |
| GET | `/info` | Get video info |

### WebSocket Events

| Event | Direction | Description |
|-------|-----------|-------------|
| `connect` | Client → Server | Initial connection |
| `added` | Server → Client | Download added |
| `updated` | Server → Client | Progress update |
| `completed` | Server → Client | Download completed |
| `canceled` | Server → Client | Download canceled |
| `cleared` | Server → Client | Queue cleared |

## 🛠️ Development Setup

### 1. Build Flutter Web

```bash
cd Web-Client/flutter-web

# Development build
flutter build web

# Production build
flutter build web --release
```

### 2. Configure Python to Serve Flutter

```bash
# Option A: Copy build files
cp -r flutter-web/build/web/* app/static/flutter-web/

# Option B: Symlink (development)
ln -s $(pwd)/flutter-web/build/web app/static/flutter-web
```

### 3. Start Backend

```bash
cd Web-Client
uv run python3 app/main.py
```

### 4. Access Clients

- **Angular**: http://localhost:8081/angular
- **Flutter**: http://localhost:8081/flutter-web
- **Default**: http://localhost:8081/ (depends on configuration)

## 🔄 Live Reload Development

For live Flutter development:

```bash
# Terminal 1: Python Backend
cd Web-Client
uv run python3 app/main.py

# Terminal 2: Flutter Web (dev server)
cd Web-Client/flutter-web
flutter run -d chrome --web-port=4200
```

Flutter will proxy API requests to `localhost:8081`.

Configure in Flutter:

```dart
// lib/core/constants/app_constants.dart
static const String defaultServerUrl =
    kDebugMode
        ? 'http://localhost:8081'  // Dev: Python backend
        : '';  // Prod: Same origin
```

## 📝 Environment Configuration

### Development

```dart
// Flutter automatically detects
import 'package:flutter/foundation.dart';

final apiUrl = kDebugMode
    ? 'http://localhost:8081'
    : window.location.origin;
```

### Production

```dart
// Use same origin as frontend
final apiUrl = window.location.origin;
```

Or use environment variables:

```bash
# Build with custom API URL
flutter build web --dart-define=API_URL=https://api.example.com
```

```dart
// In code
const apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:8081',
);
```

## 🚀 Production Deployment

### Step 1: Build Flutter

```bash
cd Web-Client/flutter-web
flutter build web --release --web-renderer html
```

### Step 2: Deploy to Python Backend

```bash
# Create static directory
mkdir -p app/static/flutter-web

# Copy build
cp -r build/web/* app/static/flutter-web/
```

### Step 3: Configure Python

```python
# app/main.py
app.router.add_static(
    '/flutter-web',
    path='./static/flutter-web',
    name='flutter_web'
)

@routes.get('/')
async def index(request):
    return web.FileResponse('./static/flutter-web/index.html')
```

### Step 4: Deploy

```bash
# Docker
docker build -t grabtube .
docker run -p 8081:8081 grabtube

# Or direct
uv run python3 app/main.py
```

## 🐳 Docker Configuration

Update `Dockerfile`:

```dockerfile
FROM python:3.13-slim

WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy Python backend
COPY app/ ./app/

# Copy Flutter Web build
COPY flutter-web/build/web ./app/static/flutter-web/

# Optional: Copy Angular build
COPY ui/dist/metube/browser ./app/static/angular/

EXPOSE 8081

CMD ["python", "app/main.py"]
```

Build and run:

```bash
# Build image
docker build -t grabtube-web .

# Run container
docker run -d \
  -p 8081:8081 \
  -v /path/to/downloads:/downloads \
  grabtube-web
```

## 🧪 Testing Integration

### Test API Connectivity

```dart
// test/integration/api_test.dart
void main() {
  test('can connect to backend', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8081'));
    final response = await dio.get('/health');
    expect(response.statusCode, 200);
  });
}
```

### Test WebSocket

```dart
test('can connect to WebSocket', () async {
  final socket = io.io('http://localhost:8081', <String, dynamic>{
    'transports': ['websocket'],
  });

  final completer = Completer<bool>();

  socket.on('connect', (_) => completer.complete(true));
  socket.connect();

  final connected = await completer.future.timeout(
    Duration(seconds: 5),
  );

  expect(connected, true);
  socket.close();
});
```

## 🐛 Troubleshooting

### Issue: CORS Errors

**Solution**:

```python
# Ensure CORS is configured for all routes
cors = aiohttp_cors.setup(app, defaults={
    "*": aiohttp_cors.ResourceOptions(
        allow_credentials=True,
        expose_headers="*",
        allow_headers="*",
        allow_methods="*"
    )
})
```

### Issue: 404 on Refresh

**Solution**: Configure catch-all route

```python
@routes.get('/flutter-web/{tail:.*}')
async def flutter_catch_all(request):
    return web.FileResponse('./static/flutter-web/index.html')
```

### Issue: WebSocket Won't Connect

**Check**:
1. Backend WebSocket server is running
2. Port is correct
3. Firewall allows WebSocket connections
4. CORS allows WebSocket upgrade

**Solution**:

```python
# Ensure Socket.IO is configured
import socketio

sio = socketio.AsyncServer(
    async_mode='aiohttp',
    cors_allowed_origins='*'  # Or specific origin
)
```

### Issue: Static Files Not Found

**Check**:
1. Build directory exists: `flutter-web/build/web`
2. Files copied to correct location
3. Python path configuration is correct

**Solution**:

```bash
# Verify build
ls -la flutter-web/build/web

# Verify Python can access
ls -la app/static/flutter-web
```

## 📊 Performance Monitoring

Add logging to track both clients:

```python
import logging

@routes.get('/flutter-web{tail:.*}')
async def serve_flutter(request):
    logging.info(f'Flutter Web: {request.path}')
    return web.FileResponse('./static/flutter-web/index.html')

@routes.get('/angular{tail:.*}')
async def serve_angular(request):
    logging.info(f'Angular: {request.path}')
    return web.FileResponse('./static/angular/index.html')
```

## 🔄 Migration Strategy

### Phase 1: Parallel Deployment

Both clients available:
- Angular: `/angular`
- Flutter: `/flutter-web`

### Phase 2: Beta Testing

Default to Flutter, Angular as fallback:
- Flutter: `/`
- Angular: `/angular` (legacy)

### Phase 3: Full Migration

Flutter only:
- Flutter: `/`
- Angular: Deprecated

## 📚 Additional Resources

- [aiohttp Documentation](https://docs.aiohttp.org)
- [aiohttp-cors](https://github.com/aio-libs/aiohttp-cors)
- [Socket.IO Python](https://python-socketio.readthedocs.io)
- [Flutter Web Deployment](https://flutter.dev/docs/deployment/web)

---

**Last Updated**: October 18, 2024
**Status**: ✅ Production Ready
