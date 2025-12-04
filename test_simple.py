#!/usr/bin/env python3
"""Test with a simpler YouTube video."""

import json
import subprocess
import time

BACKEND_URL = "http://localhost:8083"
# Using a simple YouTube video for testing
TEST_URL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"  # Rick Roll - short and reliable

def test_simple_video():
    print(f"Testing with simple YouTube video: {TEST_URL}")
    
    # Add download
    payload = {
        'url': TEST_URL,
        'quality': '720p',
        'format': 'mp4',
        'auto_start': True
    }
    
    json_payload = json.dumps(payload)
    result = subprocess.run(
        ['curl', '-s', '-X', 'POST', '-H', 'Content-Type: application/json', 
         '-d', json_payload, f'{BACKEND_URL}/add'],
        capture_output=True, text=True, timeout=30
    )
    
    print(f"Add response: {result.stdout}")
    
    # Check history
    time.sleep(2)
    result = subprocess.run(
        ['curl', '-s', f'{BACKEND_URL}/history'],
        capture_output=True, text=True, timeout=10
    )
    
    if result.returncode == 0:
        history = json.loads(result.stdout)
        print("\nDownload history:")
        for item in history.get('queue', []):
            print(f"  {item.get('url')}: {item.get('status', 'unknown')}")

if __name__ == "__main__":
    test_simple_video()