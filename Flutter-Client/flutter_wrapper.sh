#!/bin/bash

# Flutter CLI Wrapper Script
# Ensures Flutter is available before executing commands
# Automatically installs Flutter locally if not found

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="$SCRIPT_DIR/install_flutter.sh"
FLUTTER_DIR="$SCRIPT_DIR/.flutter"
FLUTTER_BIN_DIR="$FLUTTER_DIR/sdk/bin"
FLUTTER_BIN="$FLUTTER_BIN_DIR/flutter"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[FLUTTER WRAPPER]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[FLUTTER WRAPPER]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[FLUTTER WRAPPER]${NC} $1"
}

log_error() {
    echo -e "${RED}[FLUTTER WRAPPER]${NC} $1"
}

# Check if Flutter is available in PATH
check_system_flutter() {
    if command -v flutter &> /dev/null; then
        log_info "Using system Flutter installation"
        exec flutter "$@"
    fi
    return 1
}

# Check if local Flutter installation exists
check_local_flutter() {
    if [ -x "$FLUTTER_BIN" ]; then
        log_info "Using local Flutter installation at $FLUTTER_BIN"
        export PATH="$FLUTTER_BIN_DIR:$PATH"
        exec "$FLUTTER_BIN" "$@"
    fi
    return 1
}

# Install Flutter locally
install_flutter_local() {
    log_warning "Flutter not found. Installing locally..."

    if [ ! -x "$INSTALL_SCRIPT" ]; then
        log_error "Installation script not found at $INSTALL_SCRIPT"
        exit 1
    fi

    # Run installation script
    if ! "$INSTALL_SCRIPT"; then
        log_error "Failed to install Flutter locally"
        exit 1
    fi

    # Check again after installation
    if [ -x "$FLUTTER_BIN" ]; then
        log_success "Flutter installed successfully"
        export PATH="$FLUTTER_BIN_DIR:$PATH"
        exec "$FLUTTER_BIN" "$@"
    else
        log_error "Flutter installation failed"
        exit 1
    fi
}

# Main wrapper logic
main() {
    log_info "Checking Flutter availability..."

    # Try system Flutter first
    check_system_flutter "$@" && return

    # Try local Flutter
    check_local_flutter "$@" && return

    # Install and try again
    install_flutter_local "$@"
}

# Run main function with all arguments
main "$@"