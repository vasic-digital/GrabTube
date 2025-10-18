# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GrabTube is a tube services downloader - a web-based GUI for yt-dlp with playlist support. The project consists of:
- **Web-Client**: The main application (Python backend + Angular frontend)
- **Android-Client**, **Desktop-Client**, **iOS-Client**: Placeholder directories for future client implementations

The Web-Client is a fork/variant of MeTube, providing a user-friendly interface to download videos from YouTube and dozens of other sites supported by yt-dlp.

## Architecture

### Backend (Python)
The backend is an **aiohttp** async web server with **Socket.IO** for real-time communication:

- `app/main.py`: Main server entry point
  - Configures and runs the aiohttp web server
  - Handles HTTP endpoints (`/add`, `/delete`, `/start`, `/history`)
  - Manages Socket.IO events for real-time updates
  - Serves the Angular UI as static files
  - Uses environment variables for configuration (see Config class)

- `app/ytdl.py`: Download queue management
  - `DownloadQueue`: Manages download, pending, and completed queues with persistent storage (shelve)
  - `Download`: Handles individual downloads using multiprocessing
  - `PersistentQueue`: Stores queue state on disk for persistence across restarts
  - Supports three download modes: `sequential`, `concurrent`, and `limited` (default, with semaphore)
  - Each download runs in a separate process to isolate yt-dlp execution

- `app/dl_formats.py`: Format and quality string generation for yt-dlp
  - Converts user-friendly format/quality selections into yt-dlp format strings
  - Handles special cases like iOS-compatible formats, audio extraction, thumbnails
  - Configures postprocessors (FFmpeg operations) based on format selection

### Frontend (Angular 19)
Located in `ui/` directory:

- Built with Angular 19, Bootstrap 5, Font Awesome icons
- Uses Socket.IO client (`ngx-socket-io`) for real-time updates from backend
- Main component: `ui/src/app/app.component.ts` - handles UI state and user interactions
- Services:
  - `downloads.service.ts`: Manages download operations via HTTP and Socket.IO
  - `speed.service.ts`: Calculates and formats download speeds
- Theme support: `theme.ts` manages light/dark/auto theme switching

### Communication Flow
1. User submits download via Angular UI
2. HTTP POST to `/add` endpoint with URL, quality, format, folder, etc.
3. Backend extracts video info using yt-dlp, creates Download object
4. Download added to queue, Socket.IO emits 'added' event to UI
5. Download executes in separate process, status updates sent via Socket.IO
6. UI receives real-time updates ('updated', 'completed', 'canceled', 'cleared')

## Development Commands

### Building and Running Locally

**Prerequisites**: Node.js (LTS), Python 3.13, and uv package manager

```bash
# Build the Angular UI
cd Web-Client/ui
npm install
node_modules/.bin/ng build

# Install Python dependencies and run
cd ..
uv sync
uv run python3 app/main.py
```

The server will start on `http://0.0.0.0:8081` by default.

### Angular Development

```bash
cd Web-Client/ui

# Development server with hot reload
npm run start        # Serves on http://localhost:4200

# Build for production
npm run build        # Output to ui/dist/metube/browser

# Run tests
npm test

# Lint
npm run lint

# End-to-end tests
npm run e2e
```

### Python Development

```bash
cd Web-Client

# Install dev dependencies
uv sync --dev

# Run linter
uv run pylint app/
```

### Docker

```bash
# Build Docker image
docker build -t grabtube .

# Run container
docker run -d -p 8081:8081 -v /path/to/downloads:/downloads grabtube
```

## Configuration

The application is configured via environment variables (see `app/main.py` Config class). Key variables:

- `DOWNLOAD_DIR`: Where downloads are saved (default: `/downloads` in Docker)
- `DOWNLOAD_MODE`: `sequential`, `concurrent`, or `limited` (default: `limited`)
- `MAX_CONCURRENT_DOWNLOADS`: Max simultaneous downloads when mode is `limited` (default: 3)
- `YTDL_OPTIONS`: JSON string of yt-dlp options
- `YTDL_OPTIONS_FILE`: Path to JSON file with yt-dlp options (auto-reloads on change)
- `OUTPUT_TEMPLATE`: Filename template (default: `%(title)s.%(ext)s`)
- `PORT`: Server port (default: 8081)
- `LOGLEVEL`: `DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL` (default: `INFO`)

## Important Implementation Details

### Download Process Isolation
Each download runs in a **separate process** (multiprocessing.Process) to:
- Isolate yt-dlp execution from the main server
- Allow safe cancellation via process.kill()
- Prevent one download from blocking others
- Enable status updates via multiprocessing.Queue

### Queue Persistence
The application uses Python's `shelve` module to persist queue state:
- `queue`: Active downloads
- `done`: Completed downloads
- `pending`: Downloads not yet started (auto_start=False)

Files are stored in `STATE_DIR` (default: `/downloads/.metube`)

### File Watching
If `YTDL_OPTIONS_FILE` is set, the server watches for file changes using `watchfiles` and reloads options automatically, notifying clients via Socket.IO.

### Angular Build Output
The Angular app builds to `ui/dist/metube/browser/` and is served as static files by the backend. The backend expects this path and will raise an error if not found.

## Testing Considerations

When testing yt-dlp functionality, you can exec into a running Docker container:
```bash
docker exec -ti <container_name> sh
cd /downloads
yt-dlp --help
```

This allows testing yt-dlp directly with the same environment as the application.

## Project Structure Notes

- The repository has placeholder directories for Android, Desktop, and iOS clients, but these are currently empty
- The active component is Web-Client, which is a complete standalone application
- Upstreams directory exists (likely for git submodules tracking upstream dependencies)
