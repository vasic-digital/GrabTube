#!/usr/bin/env python3

import subprocess
import sys
import os

def run_command(cmd):
    """Run a command and return success status"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✓ {cmd}")
            return True
        else:
            print(f"✗ {cmd}")
            print(f"  Error: {result.stderr}")
            return False
    except Exception as e:
        print(f"✗ {cmd}")
        print(f"  Exception: {e}")
        return False

def main():
    print("🚀 Installing Python dependencies for GrabTube...")
    print("=" * 50)
    
    # Check Python version
    python_version = sys.version_info
    if python_version.major < 3 or (python_version.major == 3 and python_version.minor < 8):
        print("✗ Python 3.8+ is required")
        sys.exit(1)
    
    print(f"✓ Python {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    # Install dependencies
    dependencies = [
        "yt-dlp",
        "aiohttp", 
        "python-socketio[asyncio_client]",
        "watchfiles"
    ]
    
    success = True
    for dep in dependencies:
        if not run_command(f"pip install {dep}"):
            success = False
    
    if success:
        print("\n🎉 All dependencies installed successfully!")
        print("\nYou can now run the embedded Python service:")
        print("  python3 main.py")
    else:
        print("\n❌ Some dependencies failed to install")
        print("Please install them manually:")
        print("  pip install yt-dlp aiohttp python-socketio[asyncio_client] watchfiles")
        sys.exit(1)

if __name__ == "__main__":
    main()