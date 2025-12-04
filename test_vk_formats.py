#!/usr/bin/env python3
"""Test VK video with different formats."""

import json
import subprocess
import time

BACKEND_URL = "http://localhost:8083"
TEST_URL = "https://vkvideo.ru/video-212087550_456239213"

def test_vk_video():
    print(f"Testing VK video: {TEST_URL}")
    
    # Test different formats
    formats = [
        ('360p', 'mp4'),
        ('720p', 'mp4'), 
        ('1080p', 'mp4'),
        ('360p', 'webm'),
        ('best', 'mp4'),
    ]
    
    for quality, format in formats:
        print(f"\n\n--- Testing with {quality} {format} ---")
        
        # Add download
        payload = {
            'url': TEST_URL,
            'quality': quality,
            'format': format,
            'auto_start': True
        }
        
        json_payload = json.dumps(payload)
        result = subprocess.run(
            ['curl', '-s', '-X', 'POST', '-H', 'Content-Type: application/json', 
             '-d', json_payload, f'{BACKEND_URL}/add'],
            capture_output=True, text=True, timeout=30
        )
        
        if result.returncode == 0:
            response = json.loads(result.stdout)
            if response.get('status') == 'ok':
                print(f"✓ Download added with {quality} {format}")
                
                # Monitor for a short time
                for i in range(6):  # Check for 30 seconds
                    time.sleep(5)
                    result = subprocess.run(
                        ['curl', '-s', f'{BACKEND_URL}/history'],
                        capture_output=True, text=True, timeout=10
                    )
                    
                    if result.returncode == 0:
                        history = json.loads(result.stdout)
                        for item in history.get('queue', []):
                            if item.get('url') == TEST_URL:
                                status = item.get('status', 'unknown')
                                progress = item.get('percent', 0)
                                print(f"  Progress: {progress:.1f}% - Status: {status}")
                                break
                        
                        # Also check done queue
                        for item in history.get('done', []):
                            if item.get('url') == TEST_URL:
                                status = item.get('status', 'unknown')
                                filename = item.get('filename', 'N/A')
                                print(f"  ✓ Completed! File: {filename}")
                                break
                
                # Clean up download if still in queue
                result = subprocess.run(
                    ['curl', '-s', f'{BACKEND_URL}/history'],
                    capture_output=True, text=True, timeout=10
                )
                if result.returncode == 0:
                    history = json.loads(result.stdout)
                    for item in history.get('queue', []):
                        if item.get('url') == TEST_URL:
                            delete_payload = {'ids': [item.get('id')], 'where': 'queue'}
                            del_json = json.dumps(delete_payload)
                            subprocess.run(
                                ['curl', '-s', '-X', 'POST', '-H', 'Content-Type: application/json',
                                 '-d', del_json, f'{BACKEND_URL}/delete'],
                                capture_output=True, text=True, timeout=10
                            )
                            print(f"  Cleaned up pending download")
                            break

if __name__ == "__main__":
    test_vk_video()