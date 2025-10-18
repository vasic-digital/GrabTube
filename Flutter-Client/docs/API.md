# GrabTube API Documentation

## Overview

This document describes the communication between the GrabTube Flutter client and the Python backend server.

## Base URL

```
Default: http://localhost:8081
Configurable via app settings
```

## Authentication

Currently, no authentication is required. Future versions will implement:
- API key authentication
- OAuth 2.0 support
- JWT tokens

## HTTP Endpoints

### 1. Add Download

**Endpoint**: `POST /add`

**Description**: Add a new download to the queue

**Request Body**:
```json
{
  "url": "https://youtube.com/watch?v=dQw4w9WgXcQ",
  "quality": "1080",
  "format": "mp4",
  "folder": "Downloads",
  "auto_start": true
}
```

**Request Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| url | string | Yes | Video URL to download |
| quality | string | No | Quality (best, 2160, 1440, 1080, 720, 480, 360, worst) |
| format | string | No | Format (any, mp4, webm, mkv, mp3, m4a, etc.) |
| folder | string | No | Subfolder for download |
| auto_start | boolean | No | Start download immediately (default: true) |

**Response**:
```json
{
  "status": "success",
  "download": {
    "id": "abc123",
    "url": "https://youtube.com/watch?v=dQw4w9WgXcQ",
    "title": "Rick Astley - Never Gonna Give You Up",
    "status": "downloading",
    "thumbnail": "https://...",
    "progress": 0.0,
    "quality": "1080",
    "format": "mp4"
  }
}
```

**Error Response**:
```json
{
  "status": "error",
  "error": "Invalid URL"
}
```

---

### 2. Get Queue

**Endpoint**: `GET /queue`

**Description**: Get all active downloads in the queue

**Response**:
```json
[
  {
    "id": "abc123",
    "url": "https://...",
    "title": "Video Title",
    "status": "downloading",
    "progress": 0.45,
    "speed": "2.5 MB/s",
    "eta": "2 minutes",
    "total_bytes": 104857600,
    "downloaded_bytes": 47185920,
    "thumbnail": "https://..."
  }
]
```

---

### 3. Get Completed Downloads

**Endpoint**: `GET /done`

**Description**: Get all completed downloads

**Response**:
```json
[
  {
    "id": "def456",
    "url": "https://...",
    "title": "Completed Video",
    "status": "finished",
    "progress": 1.0,
    "total_bytes": 104857600,
    "thumbnail": "https://..."
  }
]
```

---

### 4. Get Pending Downloads

**Endpoint**: `GET /pending`

**Description**: Get downloads that are pending (auto_start=false)

**Response**:
```json
[
  {
    "id": "ghi789",
    "url": "https://...",
    "title": "Pending Video",
    "status": "pending",
    "quality": "720",
    "format": "mp4"
  }
]
```

---

### 5. Delete Downloads

**Endpoint**: `POST /delete`

**Description**: Delete downloads from queue or completed list

**Request Body**:
```json
{
  "ids": ["abc123", "def456"],
  "where": "queue"
}
```

**Request Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ids | array | Yes | Array of download IDs to delete |
| where | string | No | Location: "queue", "done", or "pending" (default: "queue") |

**Response**:
```json
{
  "status": "success",
  "deleted_count": 2
}
```

---

### 6. Start Downloads

**Endpoint**: `POST /start`

**Description**: Start pending downloads

**Request Body**:
```json
{
  "ids": ["ghi789"]
}
```

**Response**:
```json
{
  "status": "success",
  "started_count": 1
}
```

---

### 7. Clear Completed

**Endpoint**: `POST /clear`

**Description**: Clear all completed downloads from the list

**Response**:
```json
{
  "status": "success",
  "cleared_count": 5
}
```

---

### 8. Get Video Info

**Endpoint**: `GET /info`

**Description**: Get video information without downloading

**Query Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| url | string | Yes | Video URL to get info for |

**Example**: `GET /info?url=https://youtube.com/watch?v=dQw4w9WgXcQ`

**Response**:
```json
{
  "id": "dQw4w9WgXcQ",
  "title": "Rick Astley - Never Gonna Give You Up",
  "url": "https://youtube.com/watch?v=dQw4w9WgXcQ",
  "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
  "duration": 213,
  "uploader": "Rick Astley",
  "description": "...",
  "view_count": 1234567890,
  "upload_date": "2009-10-25",
  "formats": [
    {
      "format_id": "22",
      "ext": "mp4",
      "quality": "720",
      "width": 1280,
      "height": 720,
      "filesize": 50000000
    }
  ]
}
```

---

### 9. Health Check

**Endpoint**: `GET /health`

**Description**: Check server health status

**Response**:
```json
{
  "status": "ok",
  "version": "1.0.0",
  "ytdl_version": "2024.10.07"
}
```

---

## WebSocket Events

The client connects to the server via Socket.IO for real-time updates.

### Connection

```javascript
const socket = io('http://localhost:8081', {
  transports: ['websocket'],
  reconnection: true
});
```

### Events from Server

#### 1. `added`
Emitted when a new download is added

**Payload**:
```json
{
  "id": "abc123",
  "url": "https://...",
  "title": "New Video",
  "status": "downloading",
  "progress": 0.0
}
```

---

#### 2. `updated`
Emitted when download progress updates

**Payload**:
```json
{
  "id": "abc123",
  "status": "downloading",
  "progress": 0.45,
  "speed": "2.5 MB/s",
  "eta": "2 minutes",
  "downloaded_bytes": 47185920
}
```

**Update Frequency**: Every 1 second during active download

---

#### 3. `completed`
Emitted when download completes successfully

**Payload**:
```json
{
  "id": "abc123",
  "status": "finished",
  "progress": 1.0,
  "total_bytes": 104857600
}
```

---

#### 4. `canceled`
Emitted when download is canceled

**Payload**:
```json
{
  "id": "abc123",
  "status": "canceled"
}
```

---

#### 5. `error`
Emitted when download encounters an error

**Payload**:
```json
{
  "id": "abc123",
  "status": "error",
  "error": "Video unavailable"
}
```

---

#### 6. `cleared`
Emitted when completed downloads are cleared

**Payload**:
```json
{
  "status": "cleared"
}
```

---

## Download Status Values

| Status | Description |
|--------|-------------|
| `pending` | Waiting to start (auto_start=false) |
| `downloading` | Currently downloading |
| `finished` | Download completed successfully |
| `error` | Download failed with error |
| `canceled` | Download was canceled by user |

## Error Codes

| Code | Message | Description |
|------|---------|-------------|
| 400 | Bad Request | Invalid parameters |
| 404 | Not Found | Download not found |
| 500 | Internal Server Error | Server error |
| 503 | Service Unavailable | yt-dlp error |

## Rate Limiting

Current implementation has no rate limiting. Future versions will implement:
- Max 100 requests per minute per IP
- Max 10 concurrent downloads per client

## Flutter Client Implementation

### HTTP Client (Retrofit)

```dart
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) = _ApiClient;

  @POST('/add')
  Future<Map<String, dynamic>> addDownload({
    @Field('url') required String url,
    @Field('quality') String? quality,
    @Field('format') String? format,
  });

  @GET('/queue')
  Future<List<DownloadModel>> getQueue();
}
```

### WebSocket Client

```dart
class SocketClient {
  late io.Socket _socket;

  void connect(String serverUrl) {
    _socket = io.io(serverUrl, options);

    _socket.on('updated', (data) {
      final download = DownloadModel.fromJson(data);
      _onDownloadUpdated(download);
    });
  }
}
```

### Usage Example

```dart
// Add download
final download = await apiClient.addDownload(
  url: 'https://youtube.com/watch?v=...',
  quality: '1080',
  format: 'mp4',
);

// Listen to updates
socketClient.downloadUpdates.listen((download) {
  print('Progress: ${download.progress * 100}%');
});

// Get queue
final queue = await apiClient.getQueue();
```

## Best Practices

1. **Always check server health before operations**
2. **Handle WebSocket reconnection gracefully**
3. **Validate URLs on client side before sending**
4. **Show user-friendly error messages**
5. **Implement retry logic for failed requests**
6. **Cache download history locally**
7. **Debounce rapid API calls**

## Testing

### Mock Server Responses

```dart
// Mock API client
class MockApiClient extends Mock implements ApiClient {}

// Test
test('should add download successfully', () async {
  when(() => mockApiClient.addDownload(url: any(named: 'url')))
      .thenAnswer((_) async => {'status': 'success'});

  final result = await repository.addDownload(url: testUrl);
  expect(result.status, DownloadStatus.downloading);
});
```

## Changelog

### v1.0.0 (2024-10-18)
- Initial API implementation
- HTTP endpoints for CRUD operations
- WebSocket real-time updates
- Video info extraction

### Future Versions
- v1.1.0: Authentication support
- v1.2.0: Playlist support
- v1.3.0: Multi-server management
- v2.0.0: GraphQL API option

## Support

For API issues or questions:
- GitHub Issues: https://github.com/yourusername/grabtube/issues
- Email: api@grabtube.com
- Documentation: https://docs.grabtube.com
