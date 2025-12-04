#!/usr/bin/env python3
"""Debug API responses."""

import subprocess
import json

BACKEND_URL = "http://localhost:8083"

def test_add():
    """Test add endpoint and show response."""
    payload = {
        'url': "https://vkvideo.ru/video-212087550_456239213",
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
    
    print(f"Status code: {result.returncode}")
    print(f"Response: {result.stdout}")
    if result.stderr:
        print(f"Stderr: {result.stderr}")
    
    if result.returncode == 0 and result.stdout:
        try:
            data = json.loads(result.stdout)
            print(f"Parsed JSON: {json.dumps(data, indent=2)}")
        except:
            print("Response is not valid JSON")

if __name__ == "__main__":
    test_add()