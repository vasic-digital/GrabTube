#!/bin/bash
# Download the test video

echo "Downloading test video..."
/home/milosvasic/Projects/GrabTube/Web-Client/.venv/bin/yt-dlp \
    --format "best[height<=720]" \
    --output "/home/milosvasic/.grabtube/downloads/%(title)s.%(ext)s" \
    --no-playlist \
    "https://vkvideo.ru/video-212087550_456239213"

echo "Download complete"
ls -lah "/home/milosvasic/.grabtube/downloads/"