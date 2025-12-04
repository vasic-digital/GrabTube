# GrabTube User Manual

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Getting Started](#getting-started)
4. [Basic Usage](#basic-usage)
5. [Advanced Features](#advanced-features)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)
8. [Support](#support)

## Introduction

GrabTube is a cutting-edge multi-platform tube services downloader that supports downloading videos from YouTube and 1000+ other sites. It features a modern, intuitive interface and powerful capabilities for both casual users and power users.

### Key Features

- **Multi-Platform Support**: Windows, macOS, Linux, Android, iOS
- **1000+ Supported Sites**: YouTube, Vimeo, TikTok, and more
- **Batch Downloads**: Download entire playlists and channels
- **Multiple Formats**: MP4, MP3, AVI, and custom formats
- **High Performance**: Multi-threaded downloads for maximum speed
- **Privacy Focused**: Open source, ad-free, and no tracking
- **Modern UI**: Clean, responsive interface with dark mode

## Installation

### System Requirements

- **Operating System**: Windows 10+, macOS 10.14+, Linux (Ubuntu 18.04+), Android 8.0+, iOS 13.0+
- **Memory**: 4GB RAM minimum, 8GB recommended
- **Storage**: 100MB free space for installation
- **Network**: Active internet connection

### Installation Steps

#### Windows
1. Download the latest installer from the [Releases page](https://github.com/milosvasic/GrabTube/releases)
2. Run `GrabTube-Setup.exe`
3. Follow the installation wizard
4. Launch GrabTube from Start Menu

#### macOS
1. Download the DMG file from the [Releases page](https://github.com/milosvasic/GrabTube/releases)
2. Open the downloaded DMG file
3. Drag GrabTube to Applications folder
4. Launch GrabTube from Applications

#### Linux
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install grabtube

# Or download AppImage
wget https://github.com/milosvasic/GrabTube/releases/latest/grabtube.AppImage
chmod +x grabtube.AppImage
./grabtube.AppImage
```

#### Android
1. Download APK from [Releases page](https://github.com/milosvasic/GrabTube/releases)
2. Enable "Install from unknown sources" in Settings
3. Install the APK
4. Launch GrabTube

#### iOS
1. Download from TestFlight (beta) or App Store (stable)
2. Follow the installation prompt
3. Launch GrabTube

## Getting Started

### First Launch

When you first launch GrabTube, you'll see:

1. **Welcome Screen**: Brief overview of features
2. **Settings Configuration**: Basic setup options
3. **Default Download Location**: Choose where to save downloads

### Basic Setup

1. **Download Location**: Set your preferred download folder
2. **Quality Settings**: Choose default video quality
3. **Format Preferences**: Select preferred output formats
4. **Network Settings**: Configure proxy if needed

## Basic Usage

### Downloading a Single Video

1. **Copy Video URL**: Copy the video URL from your browser
2. **Paste URL**: Paste it into GrabTube's URL input field
3. **Select Quality**: Choose video/audio quality
4. **Choose Format**: Select output format (MP4, MP3, etc.)
5. **Start Download**: Click the download button

### Example: YouTube Video Download
```
URL: https://www.youtube.com/watch?v=dQw4w9WgXcQ
Quality: 1080p
Format: MP4
```

### Monitoring Downloads

- **Active Downloads**: View in the Downloads tab
- **Progress Bar**: Shows download progress and speed
- **ETA**: Estimated time remaining
- **Pause/Resume**: Control active downloads
- **Cancel**: Stop downloads if needed

## Advanced Features

### Batch Downloads

#### Downloading Playlists
1. Copy the playlist URL
2. Select "Download Playlist" option
3. Configure quality and format settings
4. Choose which videos to download (all or select)
5. Start batch download

#### Custom Selection
- **Individual Videos**: Select specific videos from playlist
- **Date Range**: Download videos within date range
- **Duration Filter**: Filter by video length
- **Quality Range**: Set minimum/maximum quality

### Format Conversion

#### Audio Extraction
- Convert videos to MP3, AAC, or other audio formats
- Preserve metadata (title, artist, album)
- Choose audio quality (128kbps to 320kbps)

#### Video Formats
- MP4 (recommended for compatibility)
- AVI (higher quality, larger size)
- MKV (multiple audio tracks)
- Custom presets for specific devices

### Automation Features

#### Scheduled Downloads
- Set specific times for downloads
- Daily/weekly/monthly schedules
- Auto-start when connected to WiFi

#### Watch Folder
- Monitor specific folders for new URLs
- Automatically download from text files
- Email notifications for completed downloads

### Settings & Configuration

#### Network Settings
- **Proxy Support**: HTTP/HTTPS/SOCKS proxies
- **Bandwidth Limiting**: Control download speed
- **Concurrent Downloads**: Set maximum simultaneous downloads
- **Retry Settings**: Configure retry attempts and delays

#### Interface Settings
- **Theme**: Light, Dark, or Auto
- **Language**: Multiple language support
- **Notifications**: Desktop notifications for completed downloads
- **Integration**: Browser extensions and context menus

## Troubleshooting

### Common Issues

#### Download Fails
**Problem**: Download starts but fails midway
**Solutions**:
1. Check internet connection
2. Verify video URL is valid
3. Try different quality setting
4. Check available disk space
5. Update GrabTube to latest version

#### Slow Downloads
**Problem**: Downloads are unusually slow
**Solutions**:
1. Check internet speed
2. Pause other downloads
3. Try different quality setting
4. Configure bandwidth settings
5. Check proxy settings

#### Audio/Video Out of Sync
**Problem**: Audio and video are not synchronized
**Solutions**:
1. Try different output format
2. Lower quality setting
3. Update system codecs
4. Use post-processing option

#### Cannot Access Video
**Problem**: Video is restricted or private
**Solutions**:
1. Verify you have access to the video
2. Check if video requires login
3. Some platforms block external tools
4. Use browser cookies import feature

### Error Messages

#### "Video not found"
- Check URL spelling
- Video may have been removed
- Try a different video from same uploader

#### "Format not available"
- Video may not have requested format
- Try different quality or format
- Use auto-select option

#### "Network error"
- Check internet connection
- Try again later
- Check firewall settings

#### "Permission denied"
- Check download folder permissions
- Run as administrator (Windows)
- Choose different download location

## FAQ

### General Questions

**Q: Is GrabTube free to use?**
A: Yes, GrabTube is completely free and open source.

**Q: Is it legal to download videos?**
A: It depends on your location and how you use the downloaded content. Only download content you have the right to access and use.

**Q: Does GrabTube work with all video platforms?**
A: GrabTube supports 1000+ sites, but some platforms may restrict or block downloads. Check our supported sites list.

### Technical Questions

**Q: What video formats are supported?**
A: GrabTube supports MP4, AVI, MKV, MOV, and audio formats like MP3, AAC, FLAC.

**Q: Can I download 4K videos?**
A: Yes, if the source video is available in 4K and your platform supports it.

**Q: How many simultaneous downloads can I run?**
A: You can configure this in settings. Default is 3 simultaneous downloads.

### Platform-Specific

**Q: Does GrabTube work on M1 Macs?**
A: Yes, GrabTube has native support for Apple Silicon Macs.

**Q: Is there a browser extension?**
A: Yes, we offer extensions for Chrome, Firefox, and Edge.

## Support

### Getting Help

- **Documentation**: Read this manual and online docs
- **Community**: Join our [Discord server](https://discord.gg/grabtube)
- **Issues**: Report bugs on [GitHub Issues](https://github.com/milosvasic/GrabTube/issues)
- **Discussions**: Ask questions on [GitHub Discussions](https://github.com/milosvasic/GrabTube/discussions)

### Contributing

We welcome contributions! See our [Contributing Guide](https://github.com/milosvasic/GrabTube/blob/main/CONTRIBUTING.md) for details.

### Reporting Issues

When reporting issues, please include:
1. GrabTube version
2. Operating system
3. Video URL (if applicable)
4. Error message
5. Steps to reproduce

### Feedback

We value your feedback! Share your thoughts on:
- Feature requests
- User experience improvements
- Bug reports
- Documentation improvements

---

## Appendix

### Keyboard Shortcuts

- **Ctrl/Cmd + V**: Paste URL
- **Ctrl/Cmd + N**: New download
- **Ctrl/Cmd + P**: Pause/Resume
- **Ctrl/Cmd + S**: Settings
- **Ctrl/Cmd + Q**: Quit application

### Command Line Options

```
grabtube --url "https://example.com/video" --quality 1080 --format mp4
grabtube --playlist "https://example.com/playlist" --audio-only
grabtube --config /path/to/config.json
```

### Configuration File

Configuration is stored in:
- **Windows**: `%APPDATA%/GrabTube/config.json`
- **macOS**: `~/Library/Application Support/GrabTube/config.json`
- **Linux**: `~/.config/GrabTube/config.json`

### API Reference

For developers, see our [API Documentation](https://github.com/milosvasic/GrabTube/blob/main/docs/API.md) for integration details.

---

**Last Updated**: December 2024
**Version**: 1.0.0
**License**: MIT License