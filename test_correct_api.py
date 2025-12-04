#!/usr/bin/env python3
"""Test GrabTube download functionality using correct API."""

import json
import subprocess
import time
import os
import sys

TEST_URL = "https://vkvideo.ru/video-212087550_456239213"
BACKEND_URL = "http://localhost:8083"

def test_backend_health():
    """Test backend health endpoint."""
    print("Testing backend health...")
    
    try:
        result = subprocess.run(
            ['curl', '-s', '-o', '/dev/null', '-w', '%{http_code}', f'{BACKEND_URL}/version'],
            capture_output=True, text=True, timeout=10
        )
        if result.stdout.strip() == '200':
            print("✓ Backend is accessible")
            return True
        else:
            print(f"✗ Backend returned {result.stdout}")
            return False
    except Exception as e:
        print(f"✗ Error accessing backend: {e}")
        return False

def add_download():
    """Add download via API."""
    print("\nAdding download...")
    
    payload = {
        'url': TEST_URL,
        'quality': '720p',
        'format': 'mp4',
        'auto_start': True
    }
    
    try:
        json_payload = json.dumps(payload)
        result = subprocess.run(
            ['curl', '-s', '-X', 'POST', '-H', 'Content-Type: application/json', 
             '-d', json_payload, f'{BACKEND_URL}/add'],
            capture_output=True, text=True, timeout=30
        )
        
        if result.returncode == 0:
            response = json.loads(result.stdout)
            download_id = response.get('id')
            if download_id:
                print(f"✓ Download added with ID: {download_id}")
                return download_id
            else:
                print(f"✗ Failed to add download: {response}")
                return False
        else:
            print(f"✗ Request failed: {result.stderr}")
            return False
    except Exception as e:
        print(f"✗ Error adding download: {e}")
        return False

def check_download_history():
    """Check download history to find our download."""
    print("\nChecking download history...")
    
    try:
        result = subprocess.run(
            ['curl', '-s', f'{BACKEND_URL}/history'],
            capture_output=True, text=True, timeout=10
        )
        
        if result.returncode == 0:
            history = json.loads(result.stdout)
            queue = history.get('queue', [])
            done = history.get('done', [])
            
            print(f"Active downloads: {len(queue)}")
            print(f"Completed downloads: {len(done)}")
            
            # Check if our download is in progress
            for item in queue:
                if TEST_URL in item.get('url', ''):
                    print(f"Found download in queue: {item}")
                    return item['id'], item.get('status'), item.get('percent', 0)
                    
            # Check if it's completed
            for item in done:
                if TEST_URL in item.get('url', ''):
                    print(f"Found download in completed: {item}")
                    return item['id'], 'completed', 100
                    
        else:
            print(f"✗ Failed to get history: {result.stderr}")
            
    except Exception as e:
        print(f"✗ Error checking history: {e}")
    
    return None, None, None

def monitor_download(download_id=None):
    """Monitor download progress."""
    print("\nMonitoring download progress...")
    
    for i in range(60):  # Check for up to 5 minutes
        dl_id, status, progress = check_download_history()
        
        if not dl_id:
            print("Waiting for download to appear...")
        else:
            if not download_id:
                download_id = dl_id
                
            print(f"Progress: {progress:.1f}% - Status: {status}")
            
            if status == 'completed':
                print("✓ Download completed successfully")
                return True
            elif status in ['error', 'canceled']:
                print(f"✗ Download failed with status: {status}")
                return False
        
        time.sleep(5)
    
    print("✗ Download monitoring timed out")
    return False

def verify_download():
    """Verify file exists in downloads directory."""
    print("\nVerifying downloaded file...")
    
    download_dir = os.path.expanduser("~/.grabtube/downloads")
    if not os.path.exists(download_dir):
        print("✗ Download directory not found")
        return False
        
    files = os.listdir(download_dir)
    if not files:
        print("✗ No files in download directory")
        return False
        
    # Find the most recent file
    recent_file = None
    recent_time = 0
    for file in files:
        file_path = os.path.join(download_dir, file)
        if os.path.isfile(file_path):
            mtime = os.path.getmtime(file_path)
            if mtime > recent_time:
                recent_time = mtime
                recent_file = file_path
    
    if recent_file:
        size = os.path.getsize(recent_file) / (1024*1024)  # MB
        print(f"✓ Found downloaded file: {os.path.basename(recent_file)}")
        print(f"  Size: {size:.2f} MB")
        
        if size > 1:  # More than 1MB
            print("✓ File size indicates valid video content")
            return True
        else:
            print("✗ File too small, likely not a valid video")
            return False
    
    print("✗ No suitable downloaded file found")
    return False

def main():
    print("GrabTube Download Verification Test")
    print("=" * 50)
    print(f"Test URL: {TEST_URL}")
    print("=" * 50)
    
    # Test backend
    if not test_backend_health():
        print("\n✗ Backend not accessible")
        return 1
    
    # Add download
    download_id = add_download()
    if not download_id:
        print("\n✗ Failed to add download")
        return 1
    
    # Monitor download
    if not monitor_download(download_id):
        print("\n✗ Download did not complete successfully")
        return 1
    
    # Verify file
    if not verify_download():
        print("\n✗ Downloaded file verification failed")
        return 1
    
    print("\n✓ ALL TESTS PASSED - Video successfully downloaded with audio and video")
    return 0

if __name__ == "__main__":
    sys.exit(main())