#!/bin/bash
# =============================================================================
# GrabTube - Local Flutter SDK Setup Script
# =============================================================================
# This script downloads and sets up a local Flutter SDK installation
# specifically for this project, without affecting the system-wide installation.
#
# Usage: ./tools/setup-flutter.sh [version]
#   version: Optional Flutter version (e.g., 3.24.5, stable, beta)
#            Defaults to 'stable'
#
# Example:
#   ./tools/setup-flutter.sh           # Install stable
#   ./tools/setup-flutter.sh 3.24.5    # Install specific version
#   ./tools/setup-flutter.sh beta      # Install beta channel
# =============================================================================

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory (parent of tools/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="${PROJECT_ROOT}/tools"
FLUTTER_DIR="${TOOLS_DIR}/flutter-sdk"
FLUTTER_VERSION_FILE="${PROJECT_ROOT}/.flutter-version"

# Default Flutter version
FLUTTER_VERSION="${1:-stable}"

# =============================================================================
# Helper Functions
# =============================================================================

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

# Detect OS and architecture
detect_platform() {
    OS="$(uname -s)"
    ARCH="$(uname -m)"

    # Determine channel
    if [[ "$FLUTTER_VERSION" == "stable" ]] || [[ "$FLUTTER_VERSION" == "beta" ]] || [[ "$FLUTTER_VERSION" == "dev" ]]; then
        CHANNEL="$FLUTTER_VERSION"
    else
        # For specific versions, use stable channel
        CHANNEL="stable"
    fi

    case "$OS" in
        Darwin*)
            PLATFORM="macos"
            RELEASES_JSON_URL="https://storage.googleapis.com/flutter_infra_release/releases/releases_macos.json"
            if [[ "$ARCH" == "arm64" ]]; then
                FLUTTER_ARCH="arm64"
            else
                FLUTTER_ARCH="x64"
            fi
            ARCHIVE_TYPE="zip"
            ;;
        Linux*)
            PLATFORM="linux"
            RELEASES_JSON_URL="https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json"
            FLUTTER_ARCH="x64"
            ARCHIVE_TYPE="tar.xz"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            PLATFORM="windows"
            RELEASES_JSON_URL="https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json"
            FLUTTER_ARCH="x64"
            ARCHIVE_TYPE="zip"
            ;;
        *)
            log_error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac

    log_info "Detected platform: $PLATFORM ($ARCH)"
    log_info "Using channel: $CHANNEL"
}

# Get Flutter download URL from releases JSON
get_download_url() {
    log_info "Fetching latest Flutter release information..."

    # Download releases JSON
    local releases_json=$(curl -sL "$RELEASES_JSON_URL")

    # Find the latest stable/beta/dev release with matching architecture
    local archive_path=$(echo "$releases_json" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for release in data['releases']:
    if release['channel'] == '$CHANNEL' and release.get('dart_sdk_arch') == '$FLUTTER_ARCH':
        print(release['archive'])
        break
else:
    # Fallback: find first release matching channel (any arch)
    for release in data['releases']:
        if release['channel'] == '$CHANNEL':
            print(release['archive'])
            break
" 2>/dev/null)

    if [[ -z "$archive_path" ]]; then
        log_error "Could not find Flutter release for channel: $CHANNEL, arch: $FLUTTER_ARCH"
        log_warning "Falling back to generic stable URL..."
        archive_path="${CHANNEL}/${PLATFORM}/flutter_${PLATFORM}_${CHANNEL}.zip"
    fi

    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/${archive_path}"
    log_info "Download URL: $FLUTTER_URL"
}

# Check if Flutter is already installed
check_existing_installation() {
    if [[ -d "$FLUTTER_DIR" ]]; then
        log_warning "Flutter SDK already exists at: $FLUTTER_DIR"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Keeping existing installation. Exiting."
            exit 0
        fi
        log_info "Removing existing installation..."
        rm -rf "$FLUTTER_DIR"
    fi
}

# Download Flutter SDK
download_flutter() {
    log_info "Downloading Flutter SDK ($FLUTTER_VERSION)..."
    log_info "URL: $FLUTTER_URL"

    # Create tools directory if it doesn't exist
    mkdir -p "$TOOLS_DIR"

    # Download Flutter
    cd "$TOOLS_DIR"

    if [[ "$ARCHIVE_TYPE" == "zip" ]]; then
        ARCHIVE_FILE="flutter.zip"
    else
        ARCHIVE_FILE="flutter.tar.xz"
    fi

    # Download with progress
    curl -L -o "$ARCHIVE_FILE" "$FLUTTER_URL" || {
        log_error "Failed to download Flutter from $FLUTTER_URL"
        exit 1
    }

    # Verify download (check if file is not empty or too small)
    FILE_SIZE=$(stat -f%z "$ARCHIVE_FILE" 2>/dev/null || stat -c%s "$ARCHIVE_FILE" 2>/dev/null || echo "0")
    if [[ "$FILE_SIZE" -lt 10000 ]]; then
        log_error "Downloaded file is too small ($FILE_SIZE bytes). Download may have failed."
        log_error "Please check your internet connection and try again."
        rm -f "$ARCHIVE_FILE"
        exit 1
    fi

    log_success "Flutter SDK downloaded successfully (${FILE_SIZE} bytes)"
}

# Extract Flutter SDK
extract_flutter() {
    log_info "Extracting Flutter SDK..."

    cd "$TOOLS_DIR"

    if [[ "$ARCHIVE_TYPE" == "zip" ]]; then
        unzip -q "$ARCHIVE_FILE" || {
            log_error "Failed to extract Flutter archive"
            log_info "Archive file: $ARCHIVE_FILE"
            log_info "File size: $(ls -lh "$ARCHIVE_FILE" | awk '{print $5}')"
            exit 1
        }
    else
        tar xf "$ARCHIVE_FILE" || {
            log_error "Failed to extract Flutter archive"
            log_info "Archive file: $ARCHIVE_FILE"
            log_info "File size: $(ls -lh "$ARCHIVE_FILE" | awk '{print $5}')"
            exit 1
        }
    fi

    # Rename flutter to flutter-sdk
    if [[ -d "flutter" ]]; then
        mv flutter flutter-sdk
    else
        log_error "Flutter directory not found after extraction"
        log_info "Contents of tools directory:"
        ls -la
        exit 1
    fi

    # Clean up archive
    rm "$ARCHIVE_FILE"

    log_success "Flutter SDK extracted to: $FLUTTER_DIR"
}

# Configure Flutter
configure_flutter() {
    log_info "Configuring Flutter SDK..."

    # Disable analytics
    "$FLUTTER_DIR/bin/flutter" config --no-analytics

    # Accept licenses non-interactively (if possible)
    log_info "Accepting Android licenses..."
    yes | "$FLUTTER_DIR/bin/flutter" doctor --android-licenses 2>/dev/null || true

    # Run flutter doctor to download dependencies
    log_info "Running flutter doctor (this may take a few minutes)..."
    "$FLUTTER_DIR/bin/flutter" doctor

    # Save Flutter version
    "$FLUTTER_DIR/bin/flutter" --version | head -n1 > "$FLUTTER_VERSION_FILE"

    log_success "Flutter configuration complete"
}

# Create environment setup file
create_env_file() {
    log_info "Creating environment setup file..."

    cat > "${TOOLS_DIR}/flutter-env.sh" << 'EOF'
#!/bin/bash
# =============================================================================
# Flutter Environment Setup
# =============================================================================
# Source this file to add local Flutter SDK to PATH
#
# Usage:
#   source tools/flutter-env.sh
#   flutter --version
# =============================================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUTTER_SDK_DIR="${SCRIPT_DIR}/flutter-sdk"

# Add Flutter to PATH (prepend to prioritize local installation)
if [[ -d "$FLUTTER_SDK_DIR" ]]; then
    export PATH="$FLUTTER_SDK_DIR/bin:$PATH"
    export FLUTTER_ROOT="$FLUTTER_SDK_DIR"
    echo "✓ Local Flutter SDK added to PATH"
    echo "  Location: $FLUTTER_SDK_DIR"
    echo "  Version: $(flutter --version 2>&1 | head -n1)"
else
    echo "✗ Flutter SDK not found at: $FLUTTER_SDK_DIR"
    echo "  Run: ./tools/setup-flutter.sh"
    return 1
fi
EOF

    chmod +x "${TOOLS_DIR}/flutter-env.sh"

    log_success "Created: ${TOOLS_DIR}/flutter-env.sh"
}

# Print usage instructions
print_usage() {
    log_success "=================================================================================="
    log_success "Flutter SDK Setup Complete!"
    log_success "=================================================================================="
    echo ""
    log_info "Installation location: $FLUTTER_DIR"
    log_info "Flutter version: $(cat "$FLUTTER_VERSION_FILE")"
    echo ""
    log_info "To use the local Flutter SDK:"
    echo ""
    echo "  Option 1: Use the wrapper script (recommended)"
    echo -e "    ${GREEN}./tools/flutter${NC} --version"
    echo -e "    ${GREEN}./tools/flutter${NC} doctor"
    echo -e "    ${GREEN}cd Flutter-Client && ../tools/flutter${NC} pub get"
    echo ""
    echo "  Option 2: Source the environment file"
    echo -e "    ${GREEN}source tools/flutter-env.sh${NC}"
    echo -e "    ${GREEN}flutter${NC} --version"
    echo ""
    echo "  Option 3: Use full path"
    echo -e "    ${GREEN}${FLUTTER_DIR}/bin/flutter${NC} --version"
    echo ""
    log_info "Next steps:"
    echo "  1. cd Flutter-Client"
    echo "  2. ../tools/flutter pub get"
    echo "  3. ../tools/flutter pub run build_runner build --delete-conflicting-outputs"
    echo "  4. ../tools/flutter analyze"
    echo "  5. ../tools/flutter test"
    echo "  6. ../tools/flutter run"
    echo ""
    log_success "=================================================================================="
}

# =============================================================================
# Main Installation Flow
# =============================================================================

main() {
    echo ""
    log_info "=================================================================================="
    log_info "GrabTube - Local Flutter SDK Setup"
    log_info "=================================================================================="
    echo ""

    # Detect platform
    detect_platform

    # Get download URL
    get_download_url

    # Check existing installation
    check_existing_installation

    # Download Flutter
    download_flutter

    # Extract Flutter
    extract_flutter

    # Configure Flutter
    configure_flutter

    # Create environment file
    create_env_file

    # Print usage instructions
    print_usage
}

# Run main function
main
