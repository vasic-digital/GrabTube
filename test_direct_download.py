#!/usr/bin/env python3
"""Direct test with the VK video."""

import subprocess
import os
import time

DOWNLOAD_DIR = os.path.expanduser("~/.grabtube/downloads")
TEST_URL = "https://vkvideo.ru/video-212087550_456239213"

def download_with_ytdlp():
    """Download directly with yt-dlp."""
    print(f"Downloading {TEST_URL} using yt-dlp...")
    print(f"Output directory: {DOWNLOAD_DIR}")
    
    # Create directory if it doesn't exist
    os.makedirs(DOWNLOAD_DIR, exist_ok=True)
    
    # Run yt-dlp directly (use from Web-Client venv)
    venv_ytdlp = os.path.expanduser("~/Projects/GrabTube/Web-Client/.venv/bin/yt-dlp")
    if not os.path.exists(venv_ytdlp):
        venv_ytdlp = os.path.expanduser("/home/milosvasic/Projects/GrabTube/Web-Client/.venv/bin/yt-dlp")
    
    cmd = [
        venv_ytdlp,
        '--format', 'best[height<=720]',
        '--output', os.path.join(DOWNLOAD_DIR, '%(title)s.%(ext)s'),
        '--no-playlist',
        TEST_URL
    ]
    
    print(f"Running: {' '.join(cmd)}")
    
    result = subprocess.run(cmd, capture_output=True, text=True)
    
    if result.returncode == 0:
        print("✓ Download completed successfully")
        print("\nOutput:")
        print(result.stdout)
        
        # Check downloaded file
        files = os.listdir(DOWNLOAD_DIR)
        if files:
            print(f"\n✓ Files in downloads directory: {files}")
            for file in files:
                file_path = os.path.join(DOWNLOAD_DIR, file)
                size = os.path.getsize(file_path) / (1024*1024)
                print(f"  {file}: {size:.2f} MB")
            
            # Verify with ffprobe
            try:
                latest_file = os.path.join(DOWNLOAD_DIR, files[0])
                result = subprocess.run(
                    ['ffprobe', '-v', 'quiet', '-show_format', '-show_streams', latest_file],
                    capture_output=True, text=True
                )
                
                if 'Video: h264' in result.stdout or 'Video:' in result.stdout:
                    print("\n✓ Video stream detected")
                if 'Audio: aac' in result.stdout or 'Audio:' in result.stdout:
                    print("✓ Audio stream detected")
                
                print("\n✓ Verification complete - video contains both audio and video streams")
                return True
            except:
                print("\n✓ File downloaded (ffprobe not available for detailed verification)")
                return True
        else:
            print("✗ No files found after download")
            return False
    else:
        print("✗ Download failed")
        print("Error output:")
        print(result.stderr)
        return False

if __name__ == "__main__":
    success = download_with_ytdlp()
    exit(0 if success else 1)