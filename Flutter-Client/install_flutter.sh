#!/bin/bash

# GrabTube Flutter CLI Installer
# Downloads and installs Flutter CLI locally in the project
# This script ensures Flutter is available for development without requiring system-wide installation

set -e

# Configuration
FLUTTER_VERSION="3.24.0"
FLUTTER_CHANNEL="stable"
FLUTTER_ARCH="linux-x64"
FLUTTER_DIR=".flutter"
FLUTTER_SDK_DIR="$FLUTTER_DIR/sdk"
FLUTTER_BIN_DIR="$FLUTTER_SDK_DIR/bin"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is already available
check_flutter() {
    if command -v flutter &> /dev/null; then
        FLUTTER_PATH=$(command -v flutter)
        log_info "Flutter found at: $FLUTTER_PATH"
        return 0
    fi
    return 1
}

# Check if local Flutter installation exists
check_local_flutter() {
    if [ -f "$FLUTTER_BIN_DIR/flutter" ]; then
        log_info "Local Flutter installation found at: $FLUTTER_BIN_DIR"
        return 0
    fi
    return 1
}

# Download Flutter SDK
download_flutter() {
    local flutter_url="https://storage.googleapis.com/flutter_infra_release/releases/$FLUTTER_CHANNEL/linux/flutter_linux_$FLUTTER_VERSION-$FLUTTER_CHANNEL.tar.xz"

    log_info "Downloading Flutter $FLUTTER_VERSION from $flutter_url"

    # Create directory if it doesn't exist
    mkdir -p "$FLUTTER_DIR"

    # Download Flutter SDK
    if command -v curl &> /dev/null; then
        curl -L "$flutter_url" -o "$FLUTTER_DIR/flutter.tar.xz"
    elif command -v wget &> /dev/null; then
        wget "$flutter_url" -O "$FLUTTER_DIR/flutter.tar.xz"
    else
        log_error "Neither curl nor wget found. Please install one of them."
        exit 1
    fi

    log_info "Extracting Flutter SDK..."
    tar -xf "$FLUTTER_DIR/flutter.tar.xz" -C "$FLUTTER_DIR"
    mv "$FLUTTER_DIR/flutter" "$FLUTTER_SDK_DIR"

    # Clean up
    rm "$FLUTTER_DIR/flutter.tar.xz"

    log_success "Flutter SDK extracted to $FLUTTER_SDK_DIR"
}

# Setup Flutter
setup_flutter() {
    log_info "Setting up Flutter..."

    # Add Flutter to PATH for this session
    export PATH="$FLUTTER_BIN_DIR:$PATH"

    # Pre-download Flutter dependencies
    log_info "Pre-downloading Flutter dependencies..."
    "$FLUTTER_BIN_DIR/flutter" --version
    "$FLUTTER_BIN_DIR/flutter" config --no-analytics
    "$FLUTTER_BIN_DIR/flutter" precache

    log_success "Flutter setup complete"
}

# Verify Flutter installation
verify_flutter() {
    log_info "Verifying Flutter installation..."

    if ! "$FLUTTER_BIN_DIR/flutter" --version; then
        log_error "Flutter verification failed"
        exit 1
    fi

    if ! "$FLUTTER_BIN_DIR/flutter" doctor; then
        log_warning "Flutter doctor check failed, but continuing..."
    fi

    log_success "Flutter verification complete"
}

# Main installation function
install_flutter() {
    log_info "Installing Flutter CLI locally..."

    if check_local_flutter; then
        log_info "Local Flutter installation already exists"
        setup_flutter
        return
    fi

    download_flutter
    setup_flutter
    verify_flutter

    log_success "Flutter CLI installed successfully!"
    log_info "Flutter binary location: $FLUTTER_BIN_DIR/flutter"
    log_info "Add the following to your shell profile to make Flutter available globally:"
    log_info "  export PATH=\"$PWD/$FLUTTER_BIN_DIR:\$PATH\""
}

# Main script
main() {
    log_info "GrabTube Flutter CLI Installer"
    log_info "=============================="

    # Check if system Flutter is available
    if check_flutter; then
        log_info "Using system Flutter installation"
        exit 0
    fi

    # Check/install local Flutter
    if check_local_flutter; then
        log_info "Using existing local Flutter installation"
        setup_flutter
        exit 0
    fi

    # Install Flutter locally
    install_flutter
}

# Run main function
main "$@"