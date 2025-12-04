# GrabTube API Reference

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Endpoints](#endpoints)
4. [WebSocket Events](#websocket-events)
5. [Error Handling](#error-handling)
6. [Rate Limiting](#rate-limiting)
7. [SDKs and Libraries](#sdks-and-libraries)

## Overview

GrabTube provides a RESTful API for managing video downloads and a WebSocket API for real-time progress updates. The API is designed to be simple, intuitive, and comprehensive.

### Base URL

```
Production: https://api.grabtube.io/v1
Development: http://localhost:8081/api/v1
```

### Authentication

GrabTube uses API key authentication for production environments:

```http
Authorization: Bearer YOUR_API_KEY
```

For development, no authentication is required.

### Content Type

All requests should use JSON content type:

```http
Content-Type: application/json
```

## Endpoints

### Videos

#### Get Video Info

Retrieve information about a video without downloading.

```http
GET /videos/info
```

**Parameters:**
- `url` (string, required): Video URL
- `format` (string, optional): Preferred format for info retrieval

**Example Request:**
```http
GET /videos/info?url=https://www.youtube.com/watch?v=dQw4w9WgXcQ
```

**Response:**
```json
{
  "id": "dQw4w9WgXcQ",
  "title": "Never Gonna Give You Up",
  "description": "Official music video",
  "duration": 212,
  "uploader": "RickAstleyVEVO",
  "view_count": 1400000000,
  "like_count": 11000000,
  "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
  "formats": [
    {
      "format_id": "137",
      "ext": "mp4",
      "resolution": "1920x1080",
      "fps": 30,
      "filesize": 50000000,
      "vcodec": "h264",
      "acodec": "none"
    }
  ],
  "extractor": "youtube",
  "extractor_key": "Youtube",
  "webpage_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "webpage_url_basename": "watch",
  "requested_formats": [],
  "format": "137 - 1920x1080 (1080p)+140 - audio only (medium)"
}
```

### Downloads

#### Add Download

Queue a new download.

```http
POST /downloads
```

**Parameters:**
- `url` (string, required): Video or playlist URL
- `quality` (string, optional): Video quality (e.g., "1080p", "720p", "best")
- `format` (string, optional): Output format (e.g., "mp4", "mp3", "avi")
- `folder` (string, optional): Custom download folder
- `auto_start` (boolean, optional): Start download immediately (default: true)
- `metadata` (object, optional): Custom metadata
  - `title` (string): Custom title
  - `artist` (string): Artist name (for audio)
  - `album` (string): Album name (for audio)
  - `year` (string): Release year

**Example Request:**
```http
POST /downloads
Content-Type: application/json

{
  "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "quality": "1080p",
  "format": "mp4",
  "folder": "/downloads/music-videos",
  "auto_start": true,
  "metadata": {
    "title": "Never Gonna Give You Up - Official Video",
    "artist": "Rick Astley",
    "year": "1987"
  }
}
```

**Response:**
```json
{
  "id": "download_1234567890",
  "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
  "title": "Never Gonna Give You Up",
  "status": "pending",
  "progress": 0.0,
  "speed": 0,
  "eta": null,
  "file_size": 50000000,
  "downloaded_size": 0,
  "quality": "1080p",
  "format": "mp4",
  "folder": "/downloads/music-videos",
  "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
  "timestamp": "2024-12-04T12:00:00Z",
  "error": null
}
```

#### Get Queue

Retrieve current download queue.

```http
GET /downloads/queue
```

**Response:**
```json
{
  "queue": [
    {
      "id": "download_1234567890",
      "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "title": "Never Gonna Give You Up",
      "status": "downloading",
      "progress": 65.5,
      "speed": 1048576,
      "eta": 45,
      "file_size": 50000000,
      "downloaded_size": 32768000,
      "quality": "1080p",
      "format": "mp4",
      "folder": "/downloads/music-videos",
      "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
      "timestamp": "2024-12-04T12:00:00Z",
      "error": null
    }
  ],
  "total": 1
}
```

#### Get Completed

Retrieve completed downloads.

```http
GET /downloads/completed
```

**Parameters:**
- `limit` (integer, optional): Maximum number of results (default: 50)
- `offset` (integer, optional): Pagination offset (default: 0)
- `search` (string, optional): Filter by search term

**Response:**
```json
{
  "downloads": [
    {
      "id": "download_1234567889",
      "url": "https://www.youtube.com/watch?v=example",
      "title": "Example Video",
      "status": "completed",
      "progress": 100.0,
      "file_size": 25000000,
      "downloaded_size": 25000000,
      "quality": "720p",
      "format": "mp4",
      "folder": "/downloads",
      "file_path": "/downloads/Example Video.mp4",
      "thumbnail": "https://i.ytimg.com/vi/example/maxresdefault.jpg",
      "timestamp": "2024-12-04T11:30:00Z",
      "completed_at": "2024-12-04T11:35:00Z",
      "error": null
    }
  ],
  "total": 1,
  "limit": 50,
  "offset": 0
}
```

#### Delete Download

Remove a download from queue or completed list.

```http
DELETE /downloads/{id}
```

**Parameters:**
- `id` (string, required): Download ID

**Response:**
```json
{
  "success": true,
  "message": "Download deleted successfully"
}
```

#### Start Download

Start a pending download.

```http
POST /downloads/{id}/start
```

**Parameters:**
- `id` (string, required): Download ID

**Response:**
```json
{
  "success": true,
  "message": "Download started"
}
```

#### Pause Download

Pause an active download.

```http
POST /downloads/{id}/pause
```

**Parameters:**
- `id` (string, required): Download ID

**Response:**
```json
{
  "success": true,
  "message": "Download paused"
}
```

#### Cancel Download

Cancel an active or pending download.

```http
POST /downloads/{id}/cancel
```

**Parameters:**
- `id` (string, required): Download ID

**Response:**
```json
{
  "success": true,
  "message": "Download canceled"
}
```

#### Retry Download

Retry a failed download.

```http
POST /downloads/{id}/retry
```

**Parameters:**
- `id` (string, required): Download ID

**Response:**
```json
{
  "success": true,
  "message": "Download retry initiated"
}
```

### Playlists

#### Get Playlist Info

Retrieve information about a playlist.

```http
GET /playlists/info
```

**Parameters:**
- `url` (string, required): Playlist URL

**Example Request:**
```http
GET /playlists/info?url=https://www.youtube.com/playlist?list=PL1234567890
```

**Response:**
```json
{
  "id": "PL1234567890",
  "title": "My Awesome Playlist",
  "description": "A collection of awesome videos",
  "uploader": "Channel Name",
  "uploader_id": "channel123",
  "uploader_url": "https://www.youtube.com/channel/channel123",
  "webpage_url": "https://www.youtube.com/playlist?list=PL1234567890",
  "webpage_url_basename": "playlist",
  "extractor": "youtube:tab",
  "extractor_key": "YoutubeTab",
  "playlist_count": 25,
  "playlist": [
    {
      "id": "video1",
      "title": "Video 1",
      "url": "https://www.youtube.com/watch?v=video1",
      "duration": 180,
      "uploader": "Channel Name",
      "uploader_id": "channel123",
      "thumbnail": "https://i.ytimg.com/vi/video1/default.jpg"
    }
  ]
}
```

#### Download Playlist

Download entire playlist or selected videos.

```http
POST /playlists/download
```

**Parameters:**
- `url` (string, required): Playlist URL
- `quality` (string, optional): Video quality
- `format` (string, optional): Output format
- `folder` (string, optional): Download folder
- `video_ids` (array, optional): Specific video IDs to download (default: all)
- `start_index` (integer, optional): Start from specific video (default: 0)
- `end_index` (integer, optional): End at specific video (default: last)
- `auto_start` (boolean, optional): Start downloads immediately

**Example Request:**
```http
POST /playlists/download
Content-Type: application/json

{
  "url": "https://www.youtube.com/playlist?list=PL1234567890",
  "quality": "720p",
  "format": "mp4",
  "video_ids": ["video1", "video2", "video3"],
  "auto_start": true
}
```

**Response:**
```json
{
  "success": true,
  "playlist_id": "PL1234567890",
  "downloads_added": 3,
  "download_ids": [
    "download_1234567890",
    "download_1234567891",
    "download_1234567892"
  ],
  "message": "3 downloads added to queue"
}
```

### Search

#### Search Videos

Search for videos on supported platforms.

```http
GET /search
```

**Parameters:**
- `query` (string, required): Search query
- `source` (string, optional): Platform to search (youtube, vimeo, etc.)
- `limit` (integer, optional): Maximum results (default: 20)
- `duration` (string, optional): Filter by duration (short, medium, long)
- `date` (string, optional): Filter by date (today, week, month, year)
- `type` (string, optional): Content type (video, playlist, channel)

**Example Request:**
```http
GET /search?query=rick+astley&source=youtube&limit=10&type=video
```

**Response:**
```json
{
  "results": [
    {
      "id": "dQw4w9WgXcQ",
      "title": "Never Gonna Give You Up",
      "description": "Official music video",
      "duration": 212,
      "uploader": "RickAstleyVEVO",
      "view_count": 1400000000,
      "upload_date": "20091025",
      "url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
      "thumbnail": "https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
      "source": "youtube",
      "type": "video"
    }
  ],
  "total": 156,
  "limit": 10,
  "offset": 0
}
```

### Settings

#### Get Settings

Retrieve current server settings.

```http
GET /settings
```

**Response:**
```json
{
  "download_dir": "/downloads",
  "download_mode": "limited",
  "max_concurrent_downloads": 3,
  "default_quality": "best",
  "default_format": "mp4",
  "audio_quality": "192",
  "video_quality": "1080p",
  "subtitle_lang": "en",
  "embed_subs": true,
  "embed_metadata": true,
  "restrict_filenames": true,
  "output_template": "%(title)s.%(ext)s",
  "rate_limit": null,
  "proxy": null
}
```

#### Update Settings

Update server configuration.

```http
PUT /settings
```

**Parameters:**
- `download_dir` (string, optional): Default download directory
- `download_mode` (string, optional): sequential, concurrent, or limited
- `max_concurrent_downloads` (integer, optional): Maximum simultaneous downloads
- `default_quality` (string, optional): Default video quality
- `default_format` (string, optional): Default output format
- `rate_limit` (string, optional): Download rate limit (e.g., "1M", "500K")
- `proxy` (object, optional): Proxy configuration
  - `url` (string): Proxy URL
  - `username` (string): Proxy username
  - `password` (string): Proxy password

**Example Request:**
```http
PUT /settings
Content-Type: application/json

{
  "download_mode": "limited",
  "max_concurrent_downloads": 5,
  "default_quality": "720p",
  "rate_limit": "2M"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Settings updated successfully",
  "settings": {
    "download_mode": "limited",
    "max_concurrent_downloads": 5,
    "default_quality": "720p",
    "rate_limit": "2M"
  }
}
```

### System

#### Get Status

Get server status and statistics.

```http
GET /status
```

**Response:**
```json
{
  "status": "running",
  "version": "1.0.0",
  "uptime": 86400,
  "downloads": {
    "active": 2,
    "completed": 156,
    "failed": 3,
    "total": 161
  },
  "system": {
    "cpu_usage": 45.2,
    "memory_usage": 67.8,
    "disk_usage": 78.5,
    "network_speed": {
      "download": 2097152,
      "upload": 1048576
    }
  },
  "supported_extractors": [
    "youtube",
    "vimeo",
    "tiktok",
    "instagram",
    "facebook"
  ]
}
```

#### Get Health

Health check endpoint.

```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-12-04T12:00:00Z",
  "version": "1.0.0",
  "uptime": 86400
}
```

## WebSocket Events

GrabTube uses WebSocket for real-time updates on download progress and system events.

### Connection

Connect to WebSocket:

```
ws://localhost:8081/socket.io
wss://api.grabtube.io/socket.io (production)
```

### Events

#### Client to Server

##### `join_room`
Join a room for specific updates.

```json
{
  "event": "join_room",
  "data": {
    "room": "downloads"
  }
}
```

##### `leave_room`
Leave a room.

```json
{
  "event": "leave_room",
  "data": {
    "room": "downloads"
  }
}
```

#### Server to Client

##### `download_added`
New download added to queue.

```json
{
  "event": "download_added",
  "data": {
    "id": "download_1234567890",
    "url": "https://www.youtube.com/watch?v=example",
    "title": "Example Video",
    "status": "pending",
    "timestamp": "2024-12-04T12:00:00Z"
  }
}
```

##### `download_updated`
Download progress updated.

```json
{
  "event": "download_updated",
  "data": {
    "id": "download_1234567890",
    "status": "downloading",
    "progress": 65.5,
    "speed": 1048576,
    "eta": 45,
    "downloaded_size": 32768000,
    "timestamp": "2024-12-04T12:02:00Z"
  }
}
```

##### `download_completed`
Download completed successfully.

```json
{
  "event": "download_completed",
  "data": {
    "id": "download_1234567890",
    "status": "completed",
    "progress": 100.0,
    "file_path": "/downloads/Example Video.mp4",
    "completed_at": "2024-12-04T12:05:00Z"
  }
}
```

##### `download_failed`
Download failed with error.

```json
{
  "event": "download_failed",
  "data": {
    "id": "download_1234567890",
    "status": "error",
    "error": "Video not found",
    "failed_at": "2024-12-04T12:01:00Z"
  }
}
```

##### `download_canceled`
Download was canceled.

```json
{
  "event": "download_canceled",
  "data": {
    "id": "download_1234567890",
    "status": "canceled",
    "canceled_at": "2024-12-04T12:03:00Z"
  }
}
```

##### `queue_updated`
Download queue updated.

```json
{
  "event": "queue_updated",
  "data": {
    "active_downloads": 2,
    "pending_downloads": 5,
    "completed_downloads": 156,
    "failed_downloads": 3
  }
}
```

##### `system_status`
System status update.

```json
{
  "event": "system_status",
  "data": {
    "cpu_usage": 45.2,
    "memory_usage": 67.8,
    "disk_usage": 78.5,
    "network_speed": {
      "download": 2097152,
      "upload": 1048576
    },
    "timestamp": "2024-12-04T12:00:00Z"
  }
}
```

## Error Handling

### Error Response Format

All error responses follow this format:

```json
{
  "error": {
    "code": "INVALID_URL",
    "message": "The provided URL is not valid",
    "details": "URL must be a valid YouTube or supported platform URL",
    "timestamp": "2024-12-04T12:00:00Z",
    "request_id": "req_1234567890"
  }
}
```

### HTTP Status Codes

- `200 OK`: Successful request
- `201 Created`: Resource created successfully
- `400 Bad Request`: Invalid request parameters
- `401 Unauthorized`: Authentication required or invalid
- `403 Forbidden`: Access denied
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource already exists
- `422 Unprocessable Entity`: Valid request but cannot be processed
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error
- `502 Bad Gateway`: Backend service unavailable
- `503 Service Unavailable`: Service temporarily unavailable

### Common Error Codes

#### `INVALID_URL`
The provided URL is not valid or not supported.

#### `VIDEO_NOT_FOUND`
The video could not be found or has been removed.

#### `QUALITY_NOT_AVAILABLE`
The requested quality is not available for this video.

#### `FORMAT_NOT_SUPPORTED`
The requested format is not supported.

#### `DOWNLOAD_LIMIT_EXCEEDED`
Download queue is full or concurrent limit reached.

#### `RATE_LIMIT_EXCEEDED`
API rate limit exceeded.

#### `QUOTA_EXCEEDED`
Quota limit exceeded.

#### `SERVER_ERROR`
Internal server error occurred.

#### `SERVICE_UNAVAILABLE`
Service temporarily unavailable.

## Rate Limiting

### API Limits

- **Development**: No rate limiting
- **Production**: 1000 requests per hour per API key
- **Premium**: 10000 requests per hour per API key

### WebSocket Limits

- **Connections**: 10 concurrent connections per API key
- **Events**: 1000 events per hour per connection

### Rate Limit Headers

Rate limit information is included in response headers:

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1701696000
```

## SDKs and Libraries

### Python

```python
import grabtube

# Initialize client
client = grabtube.Client(api_key="YOUR_API_KEY")

# Get video info
video = client.get_video_info("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
print(f"Title: {video.title}")

# Start download
download = client.add_download(
    url="https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    quality="1080p",
    format="mp4"
)

# Monitor progress
for event in client.watch_download(download.id):
    print(f"Progress: {event.progress}%")
```

### JavaScript

```javascript
import { GrabTubeClient } from 'grabtube-js';

// Initialize client
const client = new GrabTubeClient('YOUR_API_KEY');

// Get video info
const video = await client.getVideoInfo('https://www.youtube.com/watch?v=dQw4w9WgXcQ');
console.log('Title:', video.title);

// Start download
const download = await client.addDownload({
  url: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
  quality: '1080p',
  format: 'mp4'
});

// Monitor progress
client.onDownloadUpdate((event) => {
  console.log(`Progress: ${event.progress}%`);
}, download.id);
```

### Go

```go
package main

import (
    "fmt"
    "github.com/grabtube/go-grabtube"
)

func main() {
    client := grabtube.NewClient("YOUR_API_KEY")
    
    // Get video info
    video, err := client.GetVideoInfo("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
    if err != nil {
        panic(err)
    }
    fmt.Printf("Title: %s\n", video.Title)
    
    // Start download
    download, err := client.AddDownload(&grabtube.DownloadOptions{
        URL:     "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        Quality:  "1080p",
        Format:   "mp4",
    })
    if err != nil {
        panic(err)
    }
    
    // Monitor progress
    client.WatchDownload(download.ID, func(event grabtube.DownloadEvent) {
        fmt.Printf("Progress: %.1f%%\n", event.Progress)
    })
}
```

### CLI

```bash
# Install CLI
npm install -g grabtube-cli

# Configure
grabtube config set api-key YOUR_API_KEY

# Get video info
grabtube info "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Download video
grabtube download "https://www.youtube.com/watch?v=dQw4w9WgXcQ" --quality 1080p --format mp4

# Download playlist
grabtube playlist "https://www.youtube.com/playlist?list=PL1234567890" --quality 720p

# Monitor downloads
grabtube watch

# Export to JSON
grabtube export --format json > downloads.json
```

---

## Changelog

### v1.0.0 (2024-12-04)
- Initial API release
- Core download endpoints
- WebSocket events
- Rate limiting
- Authentication
- SDKs for Python, JavaScript, and Go

---

For more information, visit our [GitHub repository](https://github.com/milosvasic/GrabTube) or [documentation website](https://grabtube.io/docs).