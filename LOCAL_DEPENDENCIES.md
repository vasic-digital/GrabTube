# GrabTube Local Dependency Management

## Overview

GrabTube uses a **self-contained dependency management system** that automatically downloads and configures all required dependencies **locally within the project directory**. Users do not need to install anything on their system except for a base Python installation.

## Philosophy

- **Zero System Pollution**: No system-wide installations required
- **Automated Setup**: One command sets up everything
- **Isolated Dependencies**: Each project has its own dependencies
- **Version Controlled Scripts**: Setup scripts are version controlled
- **Git Ignored Binaries**: Downloaded binaries are excluded from git

## Architecture

```
GrabTube/
├── setup.sh                          # Master setup script
├── run-backend.sh                    # Start backend (auto-generated)
├── run-flutter-web.sh                # Start Flutter web (auto-generated)
├── run-all.sh                        # Start both (auto-generated)
│
├── Web-Client/                       # Python Backend
│   ├── .venv/                        # Python virtual environment (ignored)
│   ├── tools/
│   │   ├── setup-python.sh           # Python venv setup
│   │   ├── setup-ffmpeg.sh           # ffmpeg download & config
│   │   ├── configure-backend.sh      # Environment configuration
│   │   ├── ffmpeg/                   # Local ffmpeg binaries (ignored)
│   │   │   └── bin/
│   │   │       ├── ffmpeg            # ffmpeg executable
│   │   │       └── ffprobe           # ffprobe executable
│   │   ├── ffmpeg-env.sh             # ffmpeg environment (auto-gen)
│   │   ├── ffmpeg-wrapper.sh         # ffmpeg wrapper (auto-gen)
│   │   └── ffprobe-wrapper.sh        # ffprobe wrapper (auto-gen)
│   └── activate-venv.sh              # venv activation (auto-gen)
│
├── Flutter-Client/                   # Flutter Client
│   └── (uses tools/flutter-sdk)
│
└── tools/
    ├── flutter-sdk/                  # Local Flutter SDK (ignored)
    ├── setup-flutter.sh              # Flutter SDK setup
    └── flutter                       # Flutter wrapper
```

## Quick Start

### Complete Setup (Backend + Flutter)

```bash
cd GrabTube
./setup.sh --all
```

This single command:
1. Creates Python virtual environment
2. Installs all Python dependencies (aiohttp, yt-dlp, etc.)
3. Downloads and configures ffmpeg locally
4. Sets up Flutter SDK (if not present)
5. Installs Flutter dependencies
6. Runs code generation
7. Enables web platform
8. Creates convenience run scripts

**Time**: ~5-10 minutes (depending on internet speed)

### Backend Only

```bash
./setup.sh --backend
```

Installs:
- Python virtual environment
- Python dependencies
- ffmpeg binaries

### Flutter Only

```bash
./setup.sh --flutter --flutter-web
```

Installs:
- Flutter dependencies
- Runs code generation
- Enables web platform

## Running the Application

After setup, use the auto-generated convenience scripts:

### Start Backend

```bash
./run-backend.sh
```

- Activates Python venv
- Sources ffmpeg environment
- Starts server on http://localhost:8081

### Start Flutter Web

```bash
./run-flutter-web.sh
```

- Uses local Flutter SDK
- Starts on http://localhost:8080

### Start Both

```bash
./run-all.sh
```

- Starts backend in background
- Starts Flutter web
- Shows both URLs

## Local Dependencies

### Python Backend Dependencies

**Location**: `Web-Client/.venv/`

**Installed Packages**:
- `aiohttp` - Async HTTP server
- `python-socketio` - WebSocket support
- `yt-dlp` - Video downloader with curl-cffi support
- `mutagen` - Audio metadata
- `curl-cffi` - HTTP requests with TLS fingerprinting
- `watchfiles` - File watching

**Management**:
```bash
cd Web-Client

# Activate venv
source .venv/bin/activate

# Or use wrapper
source activate-venv.sh

# Install additional package
pip install package-name

# Update requirements
pip freeze > requirements.txt

# Deactivate
deactivate
```

### ffmpeg Binaries

**Location**: `Web-Client/tools/ffmpeg/`

**Included**:
- `ffmpeg` - Media converter
- `ffprobe` - Media analyzer

**Platform Support**:
- macOS (Intel & Apple Silicon)
- Linux (x86_64 & ARM64)
- Windows (x86_64)

**Sources**:
- macOS: https://evermeet.cx/ffmpeg/
- Linux: https://johnvansickle.com/ffmpeg/
- Windows: https://www.gyan.dev/ffmpeg/

**Auto-Detection**:
The backend automatically detects and uses local ffmpeg:
```python
# In app/main.py
def _configure_local_ffmpeg(self):
    local_ffmpeg = script_dir / 'tools' / 'ffmpeg' / 'bin' / 'ffmpeg'
    if local_ffmpeg.exists():
        os.environ['FFMPEG_LOCATION'] = str(local_ffmpeg.resolve())
```

### Flutter SDK

**Location**: `tools/flutter-sdk/`

**Version**: Configured via `.flutter-version` file

**Wrapper**: `tools/flutter` provides transparent access to local Flutter

**Usage**:
```bash
cd Flutter-Client

# All commands use local SDK
../tools/flutter run
../tools/flutter build
../tools/flutter pub get
```

## Setup Scripts Reference

### Master Setup: `setup.sh`

**Options**:
```bash
./setup.sh --all            # Complete setup
./setup.sh --backend        # Backend only
./setup.sh --flutter        # Flutter only
./setup.sh --flutter-web    # Enable web platform
./setup.sh --dev            # Include dev dependencies
./setup.sh --help           # Show help
```

**What It Does**:
1. Detects platform (macOS/Linux/Windows)
2. Finds compatible Python version (3.10+)
3. Creates virtual environment
4. Installs Python dependencies
5. Downloads platform-specific ffmpeg
6. Configures Flutter (if requested)
7. Creates run scripts
8. Updates .gitignore

### Python Setup: `Web-Client/tools/setup-python.sh`

**Options**:
```bash
cd Web-Client
tools/setup-python.sh        # Production dependencies
tools/setup-python.sh --dev  # Include dev dependencies
```

**Process**:
1. Finds Python 3.10+ installation
2. Creates `.venv` directory
3. Upgrades pip, setuptools, wheel
4. Installs dependencies from pyproject.toml
5. Verifies installation
6. Creates activation wrapper

**Checks**:
- Detects existing venv
- Validates dependencies
- Provides reinstall instructions

### ffmpeg Setup: `Web-Client/tools/setup-ffmpeg.sh`

**Usage**:
```bash
cd Web-Client
tools/setup-ffmpeg.sh
```

**Process**:
1. Detects OS and architecture
2. Downloads appropriate ffmpeg build
3. Extracts to `tools/ffmpeg/`
4. Creates wrapper scripts
5. Generates environment configuration
6. Verifies installation

**Output**:
- `tools/ffmpeg/bin/ffmpeg`
- `tools/ffmpeg/bin/ffprobe`
- `tools/ffmpeg-wrapper.sh`
- `tools/ffprobe-wrapper.sh`
- `tools/ffmpeg-env.sh`

### Flutter Setup: `tools/setup-flutter.sh`

Already documented in existing setup guides.

## Environment Configuration

### Backend Environment Variables

**Location**: `Web-Client/tools/configure-backend.sh`

**Variables**:
```bash
FFMPEG_LOCATION          # Path to local ffmpeg
DOWNLOAD_DIR             # Where downloads are saved
STATE_DIR                # Queue state directory
CUSTOM_DIRS              # Allow custom directories
DOWNLOAD_MODE            # Sequential/concurrent/limited
MAX_CONCURRENT_DOWNLOADS # Max parallel downloads
PORT                     # Server port (default: 8081)
LOGLEVEL                 # Logging level
```

**Usage**:
```bash
cd Web-Client
source tools/configure-backend.sh
python app/main.py
```

Or use the run script (does this automatically):
```bash
./run-backend.sh
```

### Flutter Environment

Flutter uses local SDK via wrapper script:
```bash
export FLUTTER_ROOT="$PROJECT_ROOT/tools/flutter-sdk"
export PATH="$FLUTTER_ROOT/bin:$PATH"
```

## Git Integration

### What's Ignored

All downloaded dependencies are ignored in `.gitignore`:

```gitignore
# Python virtual environment
Web-Client/.venv/
Web-Client/requirements.txt
Web-Client/activate-venv.sh

# ffmpeg binaries
Web-Client/tools/ffmpeg/
Web-Client/tools/ffmpeg-wrapper.sh
Web-Client/tools/ffprobe-wrapper.sh
Web-Client/tools/ffmpeg-env.sh

# Flutter SDK
tools/flutter-sdk/

# Generated run scripts
run-backend.sh
run-flutter-web.sh
run-all.sh
```

### What's Tracked

Setup scripts and configurations are version controlled:

```
Web-Client/tools/setup-python.sh    ✓ Tracked
Web-Client/tools/setup-ffmpeg.sh    ✓ Tracked
Web-Client/tools/configure-backend.sh ✓ Tracked
setup.sh                             ✓ Tracked
tools/setup-flutter.sh               ✓ Tracked
.gitignore                           ✓ Tracked
```

## Troubleshooting

### "Python 3.10+ not found"

**Solution**: Install Python 3.10 or higher:
```bash
# macOS
brew install python@3.13

# Linux (Ubuntu/Debian)
sudo apt-get install python3.13

# Linux (RHEL/CentOS)
sudo yum install python3.13
```

### "Virtual environment appears corrupted"

**Solution**: Remove and recreate:
```bash
cd Web-Client
rm -rf .venv
tools/setup-python.sh
```

### "ffmpeg not found"

**Solution**: Run ffmpeg setup:
```bash
cd Web-Client
tools/setup-ffmpeg.sh
```

**Verify**:
```bash
tools/ffmpeg/bin/ffmpeg -version
```

### "Flutter SDK not set up"

**Solution**: Run Flutter setup:
```bash
cd GrabTube
tools/setup-flutter.sh
```

**Or**: Complete setup:
```bash
./setup.sh --flutter
```

### Downloads Fail with "ERROR: ffmpeg not installed"

**Cause**: ffmpeg not properly configured

**Solution**:
```bash
cd Web-Client

# Setup ffmpeg
tools/setup-ffmpeg.sh

# Restart backend
../run-backend.sh
```

**Verify** ffmpeg detection in logs:
```
INFO:main:Using local ffmpeg: /path/to/Web-Client/tools/ffmpeg/bin/ffmpeg
```

## Advanced Usage

### Custom Python Version

```bash
cd Web-Client

# Create venv with specific Python
python3.13 -m venv .venv

# Install dependencies
source .venv/bin/activate
pip install aiohttp python-socketio yt-dlp mutagen curl-cffi watchfiles
```

### Manual ffmpeg Setup

```bash
cd Web-Client/tools

# Download ffmpeg manually
curl -L -o ffmpeg.zip [FFMPEG_URL]

# Extract to tools/ffmpeg/bin/
unzip ffmpeg.zip
mv ffmpeg ffmpeg/bin/
chmod +x ffmpeg/bin/ffmpeg
```

### Custom Backend Configuration

Create `Web-Client/.env` file:
```bash
DOWNLOAD_DIR=/custom/path/downloads
PORT=9000
MAX_CONCURRENT_DOWNLOADS=5
LOGLEVEL=DEBUG
```

Then source before running:
```bash
set -a
source .env
set +a
python app/main.py
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test GrabTube

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Dependencies
        run: ./setup.sh --backend --dev

      - name: Run Tests
        run: |
          cd Web-Client
          source .venv/bin/activate
          pytest
```

### Docker Integration

Local dependencies work seamlessly in Docker:

```dockerfile
FROM python:3.13-slim

WORKDIR /app
COPY Web-Client/ .

# Run setup
RUN tools/setup-python.sh
RUN tools/setup-ffmpeg.sh

# Start server
CMD ["sh", "-c", "source .venv/bin/activate && python app/main.py"]
```

## Benefits

### For Developers

✅ **No system pollution**: Dependencies stay in project
✅ **Consistent versions**: Everyone uses same binaries
✅ **Easy cleanup**: Delete folder to remove everything
✅ **Multiple projects**: Each project isolated
✅ **Portable**: Works on any machine with Python

### For Users

✅ **Simple setup**: One command to install
✅ **No prerequisites**: Just Python required
✅ **Automatic updates**: Scripts pull latest versions
✅ **Cross-platform**: Works on macOS, Linux, Windows

### For CI/CD

✅ **Fast**: Cached downloads speed up builds
✅ **Reproducible**: Same environment every time
✅ **Isolated**: No interference between jobs
✅ **Lightweight**: Only install what's needed

## Maintenance

### Updating Dependencies

**Python Packages**:
```bash
cd Web-Client
source .venv/bin/activate
pip install --upgrade [package-name]
pip freeze > requirements.txt
```

**ffmpeg**:
```bash
cd Web-Client
rm -rf tools/ffmpeg
tools/setup-ffmpeg.sh
```

**Flutter SDK**:
```bash
tools/flutter-sdk/bin/flutter upgrade
```

### Cleaning Up

**Remove all local dependencies**:
```bash
cd GrabTube

# Remove Python venv
rm -rf Web-Client/.venv

# Remove ffmpeg
rm -rf Web-Client/tools/ffmpeg

# Remove Flutter SDK
rm -rf tools/flutter-sdk

# Reinstall everything
./setup.sh --all
```

## Platform-Specific Notes

### macOS

- Requires **Xcode Command Line Tools**
- Apple Silicon uses native ARM64 binaries
- Intel Macs use x86_64 binaries
- No Homebrew required (optional for Python)

### Linux

- Requires **Python 3.10+** from package manager
- Uses static builds (no system dependencies)
- Works on all major distributions
- No sudo required after Python installation

### Windows

- Requires **Python 3.10+** from python.org
- Uses Git Bash or WSL for scripts
- PowerShell versions available in `tools/`
- Binaries from reliable Windows builds

## FAQ

**Q: Do I need to install yt-dlp system-wide?**
A: No, it's installed automatically in the Python venv.

**Q: Will this conflict with my system Python packages?**
A: No, everything is isolated in `.venv/`.

**Q: Can I use my existing ffmpeg installation?**
A: Yes, set `FFMPEG_LOCATION` environment variable.

**Q: How much disk space do local dependencies use?**
A: Approximately:
- Python venv: ~200MB
- ffmpeg: ~100-150MB
- Flutter SDK: ~1.5GB
- Total: ~1.8GB

**Q: Can I commit the dependencies to git?**
A: No, they're intentionally ignored. Commit setup scripts instead.

**Q: How do I update to a newer Python version?**
A: Remove `.venv/` and re-run `tools/setup-python.sh`.

## Resources

- **Python Virtual Environments**: https://docs.python.org/3/library/venv.html
- **yt-dlp Documentation**: https://github.com/yt-dlp/yt-dlp
- **ffmpeg Documentation**: https://ffmpeg.org/documentation.html
- **Flutter Setup**: https://flutter.dev/docs/get-started/install

---

**Last Updated**: 2025-11-11
**Maintainer**: GrabTube Development Team
**License**: See project LICENSE file
