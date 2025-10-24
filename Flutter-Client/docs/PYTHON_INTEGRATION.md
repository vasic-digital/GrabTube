# Python Service Integration

## Overview

This document describes the integration of the Python backend server directly into the Flutter-Client, eliminating the need for a separate server process. The integration allows the Flutter app to run the download functionality locally without external dependencies.

## Architecture

### Embedded Python Service

```
Flutter-Client/
├── python/                    # Embedded Python backend
│   ├── main.py               # Embedded server
│   ├── ytdl.py               # Download queue management
│   └── dl_formats.py         # Format handling
├── lib/core/network/
│   ├── python_service_client.dart  # Python service manager
│   └── native_python_bridge.dart   # Platform-specific bridge
└── test/
    ├── unit/core/network/    # Unit tests
    ├── integration/          # Integration tests
    └── e2e/                  # E2E tests
```

### Communication Flow

1. **Flutter App** starts the embedded Python service
2. **Python Service** runs locally on `127.0.0.1:8081`
3. **Flutter HTTP Client** communicates with local Python service
4. **Socket.IO** provides real-time updates
5. **Downloads** execute in separate Python processes

## Setup

### Prerequisites

- Python 3.8+ installed on the system
- Required Python packages:
  - `yt-dlp`
  - `aiohttp`
  - `python-socketio[asyncio_client]`
  - `watchfiles`

### Automatic Installation

The app can automatically install required Python packages:

```dart
final nativeBridge = NativePythonBridge();
final requirements = await nativeBridge.getPlatformRequirements();

if (!requirements['pythonAvailable']) {
  // Show Python installation guide
} else if (!requirements['packages']['yt-dlp']) {
  // Offer to install packages
  await nativeBridge.installPythonPackages();
}
```

### Manual Installation

```bash
# Install Python packages manually
pip install yt-dlp aiohttp python-socketio[asyncio_client] watchfiles
```

## Usage

### Starting the Python Service

```dart
final pythonService = PythonServiceClient();

// Start the service
final success = await pythonService.startService(port: 8081);

if (success) {
  print('Python service started successfully');
} else {
  print('Failed to start Python service');
}
```

### Service Status Monitoring

```dart
// Monitor service status
pythonService.statusStream.listen((isRunning) {
  if (isRunning) {
    print('Python service is running');
  } else {
    print('Python service stopped');
  }
});
```

### Platform-Specific Integration

```dart
final nativeBridge = NativePythonBridge();

// Get platform information
final platformInfo = nativeBridge.getPlatformInfo();

// Get download directory
final downloadDir = nativeBridge.getDownloadDirectory();

// Check write permissions
final canWrite = await nativeBridge.canWriteToDownloadDirectory();
```

## Testing

### Test Types

1. **Unit Tests**: Test individual components
   - `test/unit/core/network/python_service_client_test.dart`
   - `test/unit/core/network/native_python_bridge_test.dart`

2. **Integration Tests**: Test service integration
   - `test/integration/python_service_integration_test.dart`

3. **E2E Tests**: Full user workflow testing
   - `test/e2e/python_integration_e2e_test.dart`

### Running Tests

```bash
# Run all Python integration tests
./tools/run_python_integration_tests.sh

# Run specific test types
flutter test test/unit/core/network/
flutter test test/integration/python_service_integration_test.dart
patrol test --target test/e2e/python_integration_e2e_test.dart
```

### AI-Powered Test Validation

The project includes AI-powered test validation:

```bash
python3 tools/ai_test_validator.py --focus python
```

## Configuration

### Python Service Configuration

```python
# EmbeddedConfig in python/main.py
class EmbeddedConfig:
    DOWNLOAD_DIR = '~/Downloads/GrabTube'  # Download location
    PORT = 8081                            # Service port
    DOWNLOAD_MODE = 'limited'              # Concurrent downloads
    MAX_CONCURRENT_DOWNLOADS = 3           # Max simultaneous downloads
```

### Platform-Specific Settings

- **Android**: `/storage/emulated/0/Download/GrabTube`
- **iOS**: `Documents/GrabTube`
- **Windows**: `%USERPROFILE%\Downloads\GrabTube`
- **Linux/macOS**: `~/Downloads/GrabTube`

## Error Handling

### Common Issues

1. **Python Not Found**
   - Solution: Install Python 3.8+
   - Detection: `nativeBridge.isPythonAvailable()`

2. **Missing Dependencies**
   - Solution: Run `nativeBridge.installPythonPackages()`
   - Detection: `nativeBridge.getPlatformRequirements()`

3. **Port Already in Use**
   - Solution: Use different port in `startService(port: 8082)`

4. **Permission Denied**
   - Solution: Check download directory permissions
   - Detection: `nativeBridge.canWriteToDownloadDirectory()`

### Fallback Strategies

If Python service fails to start, the app can:

1. Show user-friendly error messages
2. Offer to install Python/packages
3. Fall back to remote server (if configured)
4. Provide manual download instructions

## Performance

### Resource Usage

- **Memory**: Python service uses ~50-100MB
- **CPU**: Minimal when idle, varies with downloads
- **Storage**: Downloads + state files (~10MB)

### Optimization

- Downloads run in separate processes
- Concurrent download limiting
- Persistent state management
- Automatic cleanup of completed downloads

## Security

### Local Execution

- Service runs on `127.0.0.1` (localhost only)
- No external network access required
- File operations in user's download directory

### Data Privacy

- Download URLs and metadata stored locally
- No data sent to external servers
- User controls all download locations

## Maintenance

### Updates

- Python packages updated via `pip install --upgrade`
- Service restarts automatically on app updates
- State preserved across restarts

### Logging

- Python service logs to console
- Flutter app logs service status
- Error reporting for debugging

## Migration from Remote Server

### Benefits

1. **No Network Dependency**: Works offline
2. **Better Performance**: Local communication
3. **Enhanced Privacy**: All data stays local
4. **Simplified Deployment**: No server setup

### Migration Steps

1. Update API client to use local endpoint
2. Start embedded Python service
3. Migrate download state (if needed)
4. Update configuration

## Troubleshooting

### Debug Mode

Enable verbose logging:

```dart
// In python/main.py
logging.basicConfig(level=logging.DEBUG)
```

### Common Solutions

1. **Service Won't Start**
   - Check Python installation
   - Verify port availability
   - Check file permissions

2. **Downloads Fail**
   - Verify internet connection
   - Check yt-dlp installation
   - Review download directory permissions

3. **Real-time Updates Not Working**
   - Verify Socket.IO connection
   - Check service status
   - Review network configuration

## Future Enhancements

1. **WebAssembly**: Python in browser for Flutter Web
2. **Mobile Optimization**: Reduced resource usage
3. **Plugin System**: Custom download handlers
4. **Cloud Sync**: Optional remote backup

## Support

For issues with Python integration:

1. Check the troubleshooting section
2. Review application logs
3. Verify Python installation
4. Test with sample URLs
5. Contact development team