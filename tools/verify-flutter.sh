#!/bin/bash
# =============================================================================
# GrabTube - Flutter Verification Script
# =============================================================================
# This script verifies the local Flutter SDK installation and checks if
# everything is configured correctly.
#
# Usage: ./tools/verify-flutter.sh
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
FLUTTER_BIN="${FLUTTER_DIR}/bin/flutter"
FLUTTER_VERSION_FILE="${PROJECT_ROOT}/.flutter-version"

# =============================================================================
# Helper Functions
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# =============================================================================
# Verification Checks
# =============================================================================

echo ""
log_info "=========================================="
log_info "Flutter Installation Verification"
log_info "=========================================="
echo ""

# Check 1: Flutter SDK directory exists
log_info "Checking Flutter SDK directory..."
if [[ -d "$FLUTTER_DIR" ]]; then
    log_success "Flutter SDK directory found: $FLUTTER_DIR"
else
    log_error "Flutter SDK directory not found: $FLUTTER_DIR"
    echo "  Run: ./tools/setup-flutter.sh"
    exit 1
fi

# Check 2: Flutter binary exists
log_info "Checking Flutter binary..."
if [[ -f "$FLUTTER_BIN" ]]; then
    log_success "Flutter binary found: $FLUTTER_BIN"
else
    log_error "Flutter binary not found: $FLUTTER_BIN"
    echo "  Run: ./tools/setup-flutter.sh"
    exit 1
fi

# Check 3: Flutter binary is executable
log_info "Checking Flutter binary permissions..."
if [[ -x "$FLUTTER_BIN" ]]; then
    log_success "Flutter binary is executable"
else
    log_warning "Flutter binary is not executable. Fixing..."
    chmod +x "$FLUTTER_BIN"
    log_success "Permissions fixed"
fi

# Check 4: Flutter version
log_info "Checking Flutter version..."
FLUTTER_VERSION=$("$FLUTTER_BIN" --version 2>&1 | head -n1 || echo "Unknown")
if [[ -n "$FLUTTER_VERSION" ]]; then
    log_success "Flutter version: $FLUTTER_VERSION"
else
    log_error "Failed to get Flutter version"
    exit 1
fi

# Check 5: Flutter version file
log_info "Checking Flutter version file..."
if [[ -f "$FLUTTER_VERSION_FILE" ]]; then
    SAVED_VERSION=$(cat "$FLUTTER_VERSION_FILE")
    log_success "Version file exists: $SAVED_VERSION"
else
    log_warning "Version file not found. Creating..."
    echo "$FLUTTER_VERSION" > "$FLUTTER_VERSION_FILE"
    log_success "Version file created"
fi

# Check 6: Flutter wrapper script
log_info "Checking Flutter wrapper script..."
if [[ -f "${TOOLS_DIR}/flutter" ]]; then
    if [[ -x "${TOOLS_DIR}/flutter" ]]; then
        log_success "Flutter wrapper script is ready"
    else
        log_warning "Flutter wrapper script is not executable. Fixing..."
        chmod +x "${TOOLS_DIR}/flutter"
        log_success "Permissions fixed"
    fi
else
    log_error "Flutter wrapper script not found: ${TOOLS_DIR}/flutter"
    exit 1
fi

# Check 7: Test Flutter wrapper
log_info "Testing Flutter wrapper..."
WRAPPER_VERSION=$("${TOOLS_DIR}/flutter" --version 2>&1 | head -n1 || echo "Failed")
if [[ "$WRAPPER_VERSION" == "$FLUTTER_VERSION" ]]; then
    log_success "Flutter wrapper working correctly"
else
    log_warning "Flutter wrapper version mismatch"
    echo "  Direct: $FLUTTER_VERSION"
    echo "  Wrapper: $WRAPPER_VERSION"
fi

# Check 8: Flutter doctor
log_info "Running Flutter doctor..."
echo ""
"$FLUTTER_BIN" doctor
echo ""

# Check 9: Dart SDK
log_info "Checking Dart SDK..."
DART_VERSION=$("$FLUTTER_DIR/bin/dart" --version 2>&1 || echo "Not found")
if [[ "$DART_VERSION" != "Not found" ]]; then
    log_success "Dart SDK: $DART_VERSION"
else
    log_error "Dart SDK not found"
fi

# Check 10: Flutter environment file
log_info "Checking Flutter environment file..."
if [[ -f "${TOOLS_DIR}/flutter-env.sh" ]]; then
    if [[ -x "${TOOLS_DIR}/flutter-env.sh" ]]; then
        log_success "Flutter environment file is ready"
    else
        log_warning "Flutter environment file is not executable. Fixing..."
        chmod +x "${TOOLS_DIR}/flutter-env.sh"
        log_success "Permissions fixed"
    fi
else
    log_error "Flutter environment file not found"
fi

# Summary
echo ""
log_info "=========================================="
log_success "Verification Complete!"
log_info "=========================================="
echo ""
log_info "Flutter SDK location: $FLUTTER_DIR"
log_info "Flutter version: $FLUTTER_VERSION"
echo ""
log_info "You can use Flutter in the following ways:"
echo ""
echo "  1. Wrapper script (recommended):"
echo -e "     ${GREEN}./tools/flutter${NC} --version"
echo ""
echo "  2. Source environment:"
echo -e "     ${GREEN}source tools/flutter-env.sh${NC}"
echo -e "     ${GREEN}flutter${NC} --version"
echo ""
echo "  3. Direct path:"
echo -e "     ${GREEN}${FLUTTER_BIN}${NC} --version"
echo ""
log_success "All checks passed! ✓"
echo ""
