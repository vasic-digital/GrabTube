#!/usr/bin/env python3
"""Simple connectivity test for GrabTube backend."""

import sys
import socket

def check_backend(host="localhost", port=8083):
    """Check if backend is running."""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        result = sock.connect_ex((host, port))
        sock.close()
        return result == 0
    except:
        return False

if check_backend():
    print("✓ Backend is running on port 8083")
    sys.exit(0)
else:
    print("✗ Backend is not accessible on port 8083")
    sys.exit(1)