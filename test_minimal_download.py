#!/usr/bin/env python3
"""Minimal test for GrabTube download functionality."""

import json
import subprocess
import time
import os

TEST_URL = "https://vkvideo.ru/video-212087550_456239213"
BACKEND_URL = "http://localhost:8083"

def test_backend_api():
    """Test backend API with curl."""
    print("Testing backend API...")
    
    # Test GET /queue
    try:
        result = subprocess.run(
            ['curl', '-s', '-o', '/dev/null', '-w', '%{http_code}', f'{BACKEND_URL}/queue'],
            capture_output=True, text=True, timeout=10
        )
        if result.stdout.strip() == '200':
            print("✓ Backend /queue endpoint accessible")
        else:
            print(f"✗ Backend /queue returned {result.stdout}")
            return False
    except Exception as e:
        print(f"✗ Error accessing /queue: {e}")
        return False
    
    # Add download
    payload = {
        'url': TEST_URL,
        'quality': '720p',
        'format': 'mp4',
        'auto_start': True
    }
    
    try:
        import json
        json_payload = json.dumps(payload)
        result = subprocess.run(
            ['curl', '-s', '-X', 'POST', '-H', 'Content-Type: application/json', 
             '-d', json_payload, f'{BACKEND_URL}/add'],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode == 0:
            response = json.loads(result.stdout)
            download_id = response.get('id')
            print(f"✓ Download added with ID: {download_id}")
            return download_id
        else:
            print(f"✗ Failed to add download: {result.stderr}")
            return False
    except Exception as e:
        print(f"✗ Error adding download: {e}")
        return False

def monitor_download(download_id):
    """Monitor download progress."""
    print(f"\nMonitoring download {download_id}...")
    
    for i in range(60):  # Check for up to 5 minutes (60 * 5 seconds)
        try:
            result = subprocess.run(
                ['curl', '-s', f'{BACKEND_URL}/queue'],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0:
                queue = json.loads(result.stdout)
                
                # Find our download
                download = None
                for item in queue:
                    if item.get('id') == download_id:
                        download = item
                        break
                
                if download:
                    progress = download.get('percent', 0)
                    status = download.get('status', 'unknown')
                    print(f"Progress: {progress:.1f}% - Status: {status}")
                    
                    if status == 'complete':
                        print("✓ Download completed successfully")
                        filename = download.get('filename')
                        if filename:
                            print(f"Downloaded file: {filename}")
                        return True
                        
                    elif status in ['error', 'canceled']:
                        error = download.get('error', 'Unknown error')
                        print(f"✗ Download failed: {error}")
                        return False
        except Exception as e:
            print(f"✗ Error monitoring download: {e}")
        
        time.sleep(5)
    
    print("✗ Download timed out")
    return False

def main():
    print("GrabTube Download Test")
    print("=" * 40)
    print(f"URL: {TEST_URL}")
    print("=" * 40)
    
    # Test API
    download_id = test_backend_api()
    if not download_id:
        print("\n✗ API test failed")
        return 1
    
    # Monitor download
    if monitor_download(download_id):
        print("\n✓ Download test PASSED")
        return 0
    else:
        print("\n✗ Download test FAILED")
        return 1

if __name__ == "__main__":
    exit(main())