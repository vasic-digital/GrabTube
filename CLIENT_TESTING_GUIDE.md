# GrabTube Client Testing Guide

This guide provides comprehensive instructions for testing all GrabTube clients with the provided video link.

## Test Video

**URL**: https://vkvideo.ru/video-212087550_456239213
- **Expected**: Valid YouTube video that should download with video and audio tracks
- **Verification**: Download completes successfully with both video and audio present

## Test Suite Overview

The test suite validates:
1. **Backend Connectivity** - All clients can connect to Python backend
2. **Download Initiation** - Clients can add downloads via API
3. **Progress Tracking** - Real-time download progress updates work
4. **Completion Handling** - Download completion is properly detected
5. **File Verification** - Downloaded files contain video and audio

## Running Tests

### Quick Start

```bash
# Run all tests for all clients
./run_all_tests.sh
```

### Individual Client Tests

#### 1. Python Backend Tests

First, ensure the backend is running:

```bash
cd Web-Client
uv run python3 app/main.py
```

Then run backend integration tests:

```bash
# Run Python integration tests
python3 test_download_integration.py
```

#### 2. Angular Web Client Tests

```bash
cd Web-Client/ui

# Install dependencies
npm install

# Run unit tests
npm test

# Run integration tests
npm run test:e2e
```

#### 3. Flutter Client Tests

```bash
cd Flutter-Client

# Install dependencies
flutter pub get

# Generate code
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run all tests
./tools/run_tests.sh

# Run specific test suites
flutter test test/unit/                    # Unit tests
flutter test test/widget/                   # Widget tests
flutter test test/integration/              # Integration tests
```

## Test Scenarios

### Scenario 1: Standard Download

**Steps:**
1. Add URL to download queue
2. Verify download starts
3. Monitor progress to 100%
4. Confirm file saved with expected format

**Expected Results:**
- Download appears in queue immediately
- Progress updates received in real-time
- File saved with both video and audio
- Status changes: queued → downloading → complete

### Scenario 2: Different Qualities

Test multiple quality options:
- 144p (lowest)
- 360p (medium)
- 720p (high)
- 1080p (full HD)
- best (auto-select best available)

### Scenario 3: Different Formats

Test multiple format options:
- MP4 (video + audio)
- WebM (video + audio)
- MP3 (audio only)

### Scenario 4: Error Handling

Test error scenarios:
- Invalid URL rejected
- Network interruptions handled
- Duplicate downloads managed
- Missing parameters rejected

## Verification Checklist

After download completes, verify:

### Video File Verification
- [ ] File exists in download directory
- [ ] File size > 0 bytes
- [ ] Video codec information present
- [ ] Audio codec information present
- [ ] Duration matches source
- [ ] Resolution matches requested quality

### API Response Verification
- [ ] 200/201 status on add request
- [ ] Download ID returned
- [ ] Progress updates via WebSocket
- [ ] Completion event received
- [ ] File metadata provided

### Client-Side Verification
- [ ] UI shows download in list
- [ ] Progress bar updates smoothly
- [ ] Status changes correctly
- [ ] Errors displayed gracefully
- [ ] Can cancel/pause/resume

## Troubleshooting

### Backend Not Running
```bash
# Check if backend is running
curl http://localhost:8081/queue

# Start backend
cd Web-Client
uv run python3 app/main.py
```

### Flutter Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build
flutter build apk --debug
```

### Angular Test Failures
```bash
# Clear node_modules
rm -rf node_modules package-lock.json
npm install
npm test
```

### Download Fails

**Check YouTube Link:**
- Verify video is not region-restricted
- Check if video requires authentication
- Ensure video is not private/deleted

**Check Backend Logs:**
```bash
cd Web-Client
tail -f ../logs/debug.log
```

**Check yt-dlp:**
```bash
cd Web-Client
yt-dlp --help
yt-dlp "https://www.youtube.com/watch?v=TEST_ID"
```

## Performance Benchmarks

Expected performance metrics:

| Metric               | Target              |
|---------------------|---------------------|
| Add Download Time   | < 2 seconds        |
| First Progress      | < 5 seconds        |
| Progress Updates    | < 1 second interval |
| 720p Download     | < 2 minutes        |
| 1080p Download     | < 5 minutes        |

## Continuous Integration

The tests can be integrated into CI/CD pipelines:

### GitHub Actions
```yaml
- name: Test Download Integration
  run: |
    cd Web-Client
    uv run python3 -m pytest test_download_integration.py -v
```

### Flutter CI
```yaml
- name: Flutter Tests
  run: |
    cd Flutter-Client
    flutter test --reporter json > test_report.json
    flutter test test/integration/
```

### Angular CI
```yaml
- name: Angular Tests
  run: |
    cd Web-Client/ui
    npm run test:ci
```

## Automated Testing Script

Use the provided `run_all_tests.sh` for comprehensive testing:

```bash
./run_all_tests.sh
```

This script will:
1. Check Python backend status
2. Run backend integration tests
3. Execute Angular tests
4. Run Flutter tests (unit, widget, integration)
5. Attempt to build APK
6. Generate test summary report

## Test Data

The test suite includes mock data for:
- Various YouTube URL formats
- Different video durations
- Multiple quality levels
- Various format options
- Error conditions

## Reporting

Test results are saved to:
- `test_results/` - Flutter test reports
- `coverage/` - Code coverage reports
- `logs/` - Test execution logs

For detailed test output, check individual test files:
- `/test/integration/web_client_integration_test.dart`
- `/test/integration/flutter_client_integration_test.dart`
- `/Web-Client/ui/src/app/app.component.integration.spec.ts`
- `/test_download_integration.py`

## Manual Testing

For manual verification:

1. Open Web Client at http://localhost:8081
2. Enter test URL: https://vkvideo.ru/video-212087550_456239213
3. Select quality: 720p, format: MP4
4. Click "Add Download"
5. Observe download progress
6. Verify file in downloads folder
7. Play video to confirm both audio and video work

## Security Considerations

When testing with provided URL:
- Verify it's not copyrighted/restricted content
- Ensure downloads are stored securely
- Clean up test downloads after verification
- Don't commit actual downloaded files to repo

## Next Steps

After running tests:
1. Review test results
2. Fix any failures
3. Update documentation
4. Add new test cases as needed
5. Optimize performance based on benchmarks