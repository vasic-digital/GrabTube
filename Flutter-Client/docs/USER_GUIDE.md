# GrabTube User Guide

Welcome to GrabTube! This guide will help you get started with downloading videos across all platforms.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Adding Downloads](#adding-downloads)
3. [Managing Downloads](#managing-downloads)
4. [Settings](#settings)
5. [Tips & Tricks](#tips--tricks)
6. [Troubleshooting](#troubleshooting)

## Getting Started

### First Launch

When you first launch GrabTube, you'll see three tabs:
- **Queue**: Active downloads
- **Completed**: Finished downloads
- **Pending**: Downloads waiting to start

### Connecting to Server

1. Tap the **Settings** icon (⚙️) in the top right
2. Enter your server URL (e.g., `http://localhost:8081`)
3. Tap **Save**
4. The connection status indicator will turn green when connected

## Adding Downloads

### Quick Download

1. Tap the **+ Add Download** button (floating action button)
2. Paste the video URL
3. Tap **Add**

That's it! The download will start automatically.

### Advanced Options

For more control:

1. Tap **+ Add Download**
2. Paste the video URL
3. **Select Quality**:
   - `best`: Highest available quality
   - `2160`: 4K (if available)
   - `1080`: Full HD
   - `720`: HD
   - `480`: SD
   - `360`: Mobile quality
   - `worst`: Lowest quality (fastest download)

4. **Select Format**:
   - `any`: Best available format
   - `mp4`: MP4 video
   - `webm`: WebM video
   - `mkv`: MKV container
   - `mp3`: Audio only (MP3)
   - `m4a`: Audio only (M4A)

5. **Toggle Auto-Start**:
   - ON: Download starts immediately
   - OFF: Download added to pending queue

6. Tap **Add**

### Supported Sites

GrabTube supports hundreds of sites including:
- YouTube
- Vimeo
- Dailymotion
- Facebook
- Instagram
- Twitter
- TikTok
- And many more!

## Managing Downloads

### Queue Tab

View and manage active downloads:

**Download Card** shows:
- Video thumbnail
- Title
- Quality badge
- Status (Downloading/Completed/Error)
- Progress bar with percentage
- Download speed and ETA

**Actions**:
- Tap **⋮** menu for options:
  - **Delete**: Remove from queue

### Completed Tab

View all successfully downloaded videos:

**Actions**:
- Tap **⋮** menu:
  - **Delete**: Remove from history

- **Clear All**: Remove all completed downloads from list

### Pending Tab

View downloads waiting to start:

**Actions**:
- Tap **⋮** menu:
  - **Start**: Begin download
  - **Delete**: Remove from pending

## Statistics

At the top of the screen, you'll see:

📊 **Active**: Number of currently downloading videos
⏳ **Pending**: Downloads waiting to start
✅ **Completed**: Total completed downloads

## Settings

Access settings by tapping the **⚙️** icon:

### Server Configuration
- **Server URL**: Backend server address
- **Connection Status**: Green = connected, Red = disconnected

### Download Preferences
- **Default Quality**: Auto-select quality for new downloads
- **Default Format**: Auto-select format for new downloads
- **Auto-Start**: Automatically start new downloads
- **Download Path**: Where files are saved

### Notifications
- **Enable Notifications**: Get notified when downloads complete
- **Sound**: Play sound on completion
- **Vibrate**: Vibrate on completion (mobile only)

### Appearance
- **Theme**: Light, Dark, or System default
- **Language**: Select app language

### Advanced
- **Max Concurrent Downloads**: Number of simultaneous downloads
- **Download History Limit**: Number of completed items to keep

## Tips & Tricks

### Faster Downloads

1. **Use Lower Quality**: 720p downloads faster than 1080p
2. **Limit Concurrent Downloads**: Set to 1-2 for faster individual speeds
3. **Use Wi-Fi**: Faster than mobile data

### Save Space

1. **Download Audio Only**: Use MP3/M4A format
2. **Lower Quality**: 480p uses less space than 1080p
3. **Clear Completed**: Regularly clear completed downloads

### Batch Downloads

1. Add multiple videos with Auto-Start OFF
2. Review all pending downloads
3. Start all at once from Pending tab

### Retry Failed Downloads

If a download fails:
1. Find it in the Queue tab (Error status)
2. Note the error message
3. Tap **Delete**
4. Add the URL again with different quality/format

## Platform-Specific Features

### Android

**Sharing**:
1. Open YouTube app
2. Tap **Share** on any video
3. Select **GrabTube**
4. Download starts automatically

**Widgets**:
- Add home screen widget to see download progress

**Notifications**:
- Download progress in notification shade
- Tap to open app

### iOS

**Share Extension**:
1. Open YouTube app (or Safari)
2. Tap **Share** button
3. Select **GrabTube**
4. Download added to queue

**Widgets**:
- Add widget to see recent downloads

### Desktop (Windows/macOS/Linux)

**System Tray**:
- App runs in system tray
- Click icon to open/minimize
- Right-click for quick actions

**Keyboard Shortcuts**:
- `Ctrl/Cmd + N`: New download
- `Ctrl/Cmd + R`: Refresh
- `Ctrl/Cmd + ,`: Settings
- `Ctrl/Cmd + Q`: Quit

**Drag & Drop**:
- Drag video URL from browser to app window

## Troubleshooting

### Cannot Connect to Server

**Problem**: Red connection indicator

**Solutions**:
1. Check server URL is correct
2. Ensure backend server is running
3. Check firewall settings
4. Try http:// instead of https://

### Download Fails

**Problem**: Download shows "Error" status

**Solutions**:
1. Check internet connection
2. Verify video is still available
3. Try different quality/format
4. Check server logs for details

### Slow Download Speed

**Problem**: Download speed is slow

**Solutions**:
1. Reduce concurrent downloads
2. Switch to Wi-Fi connection
3. Try lower quality
4. Check server bandwidth

### Video Not Playing

**Problem**: Downloaded video won't play

**Solutions**:
1. Ensure you have a compatible video player
2. Try different format (MP4 is most compatible)
3. Re-download with different settings

### App Crashes

**Problem**: App crashes or freezes

**Solutions**:
1. Update to latest version
2. Clear app cache
3. Restart app
4. Reinstall if problem persists

## FAQs

**Q: Is GrabTube free?**
A: Yes, completely free and open-source!

**Q: How many videos can I download at once?**
A: Default is 3, configurable in settings.

**Q: Where are my downloaded videos?**
A: Location depends on platform:
- **Android**: Downloads/GrabTube/
- **iOS**: App Documents/
- **Desktop**: ~/Downloads/GrabTube/

**Q: Can I download playlists?**
A: Coming in version 1.2.0!

**Q: What's the maximum video length?**
A: No limit, depends on storage space.

**Q: Can I download private/unlisted videos?**
A: Only if you have access to the URL.

**Q: Does it work offline?**
A: No, internet connection required.

**Q: Can I schedule downloads?**
A: Not yet, planned for v1.3.0.

## Privacy & Safety

- **No Data Collection**: We don't collect any personal data
- **Local Storage**: All data stored on your device
- **Open Source**: Code is publicly auditable
- **Secure**: HTTPS support for server connections

## Legal Notice

**Important**: Ensure you have the right to download content. Respect copyright laws and terms of service of video platforms.

## Getting Help

### In-App Help
- Tap **?** icon for contextual help
- Long-press any button for tooltip

### Community Support
- **Discord**: https://discord.gg/grabtube
- **Reddit**: r/GrabTube
- **GitHub Discussions**: github.com/grabtube/discussions

### Bug Reports
- **GitHub Issues**: github.com/grabtube/issues
- **Email**: support@grabtube.com

## What's Next?

After mastering the basics:
1. Explore **Advanced Settings**
2. Try different quality/format combinations
3. Set up multiple server connections
4. Join our community for tips

Happy downloading! 🎉
