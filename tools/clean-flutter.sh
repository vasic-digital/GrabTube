#!/bin/bash
# =============================================================================
# GrabTube - Flutter Cleanup Script
# =============================================================================
# This script removes the local Flutter SDK installation and related files.
#
# Usage: ./tools/clean-flutter.sh [--force]
#   --force: Skip confirmation prompt
# =============================================================================

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="${PROJECT_ROOT}/tools"
FLUTTER_DIR="${TOOLS_DIR}/flutter-sdk"
FLUTTER_VERSION_FILE="${PROJECT_ROOT}/.flutter-version"
FLUTTER_ENV_FILE="${TOOLS_DIR}/flutter-env.sh"

# Check for --force flag
FORCE=false
if [[ "$1" == "--force" ]]; then
    FORCE=true
fi

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

# =============================================================================
# Cleanup Functions
# =============================================================================

confirm_cleanup() {
    if [[ "$FORCE" == true ]]; then
        return 0
    fi

    echo ""
    log_warning "This will remove the local Flutter SDK installation!"
    echo ""
    log_info "The following will be deleted:"
    [[ -d "$FLUTTER_DIR" ]] && echo "  - $FLUTTER_DIR"
    [[ -f "$FLUTTER_VERSION_FILE" ]] && echo "  - $FLUTTER_VERSION_FILE"
    [[ -f "$FLUTTER_ENV_FILE" ]] && echo "  - $FLUTTER_ENV_FILE"
    echo ""
    read -p "Are you sure you want to continue? (yes/N): " -r
    echo ""

    if [[ ! "$REPLY" =~ ^[Yy][Ee][Ss]$ ]]; then
        log_info "Cleanup cancelled."
        exit 0
    fi
}

remove_flutter_sdk() {
    if [[ -d "$FLUTTER_DIR" ]]; then
        log_info "Removing Flutter SDK directory..."
        rm -rf "$FLUTTER_DIR"
        log_success "Flutter SDK directory removed"
    else
        log_info "Flutter SDK directory not found (already clean)"
    fi
}

remove_version_file() {
    if [[ -f "$FLUTTER_VERSION_FILE" ]]; then
        log_info "Removing Flutter version file..."
        rm -f "$FLUTTER_VERSION_FILE"
        log_success "Flutter version file removed"
    else
        log_info "Flutter version file not found (already clean)"
    fi
}

remove_env_file() {
    if [[ -f "$FLUTTER_ENV_FILE" ]]; then
        log_info "Removing Flutter environment file..."
        rm -f "$FLUTTER_ENV_FILE"
        log_success "Flutter environment file removed"
    else
        log_info "Flutter environment file not found (already clean)"
    fi
}

remove_flutter_cache() {
    # Remove Flutter cache in Flutter-Client if it exists
    if [[ -d "${PROJECT_ROOT}/Flutter-Client/.dart_tool" ]]; then
        log_info "Removing Flutter cache in Flutter-Client..."
        rm -rf "${PROJECT_ROOT}/Flutter-Client/.dart_tool"
        log_success "Flutter cache removed"
    fi

    if [[ -d "${PROJECT_ROOT}/Flutter-Client/.flutter-plugins" ]]; then
        rm -f "${PROJECT_ROOT}/Flutter-Client/.flutter-plugins"
    fi

    if [[ -d "${PROJECT_ROOT}/Flutter-Client/.flutter-plugins-dependencies" ]]; then
        rm -f "${PROJECT_ROOT}/Flutter-Client/.flutter-plugins-dependencies"
    fi
}

# =============================================================================
# Main Cleanup Flow
# =============================================================================

main() {
    echo ""
    log_info "=========================================="
    log_info "GrabTube - Flutter Cleanup"
    log_info "=========================================="

    # Confirm cleanup
    confirm_cleanup

    # Remove Flutter SDK
    remove_flutter_sdk

    # Remove version file
    remove_version_file

    # Remove environment file
    remove_env_file

    # Remove Flutter cache
    remove_flutter_cache

    echo ""
    log_success "=========================================="
    log_success "Cleanup Complete!"
    log_success "=========================================="
    echo ""
    log_info "To reinstall Flutter, run:"
    echo -e "  ${GREEN}./tools/setup-flutter.sh${NC}"
    echo ""
}

# Run main function
main
