#!/bin/bash
# setup.sh - Master setup script for GrabTube project
# This script sets up all components: Flutter client, Python backend, and dependencies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_section() {
    echo ""
    echo -e "${CYAN}${BOLD}═══ $1 ═══${NC}"
    echo ""
}

# Check if component should be set up
should_setup_backend() {
    [ "$SETUP_ALL" = "true" ] || [ "$SETUP_BACKEND" = "true" ]
}

should_setup_flutter() {
    [ "$SETUP_ALL" = "true" ] || [ "$SETUP_FLUTTER" = "true" ]
}

should_setup_flutter_web() {
    [ "$SETUP_ALL" = "true" ] || [ "$SETUP_FLUTTER" = "true" ] || [ "$SETUP_FLUTTER_WEB" = "true" ]
}

# Setup Web-Client (Python backend)
setup_backend() {
    log_section "Setting up Python Backend (Web-Client)"

    cd "$PROJECT_ROOT/Web-Client"

    # Setup Python virtual environment
    if [ -f "tools/setup-python.sh" ]; then
        log_info "Running Python setup..."
        bash tools/setup-python.sh "$@"
    else
        log_error "Python setup script not found"
        exit 1
    fi

    # Setup ffmpeg
    if [ -f "tools/setup-ffmpeg.sh" ]; then
        log_info "Running ffmpeg setup..."
        bash tools/setup-ffmpeg.sh
    else
        log_warning "ffmpeg setup script not found, skipping"
    fi

    # Create placeholder UI directory if needed
    if [ ! -d "ui/dist/metube/browser" ]; then
        log_info "Creating placeholder UI directory..."
        mkdir -p ui/dist/metube/browser
        touch ui/dist/metube/browser/index.html
        log_success "Placeholder UI created"
    fi

    log_success "Backend setup complete"
}

# Setup Flutter-Client
setup_flutter() {
    log_section "Setting up Flutter Client"

    cd "$PROJECT_ROOT/Flutter-Client"

    # Check if Flutter is already set up
    if [ -f "../tools/flutter-sdk/bin/flutter" ]; then
        log_success "Flutter SDK already installed"
    else
        # Run Flutter setup if available
        if [ -f "../tools/setup-flutter.sh" ]; then
            log_info "Running Flutter SDK setup..."
            cd "$PROJECT_ROOT"
            bash tools/setup-flutter.sh
            cd "$PROJECT_ROOT/Flutter-Client"
        else
            log_warning "Flutter setup script not found"
            log_info "Please ensure Flutter SDK is installed: https://flutter.dev/docs/get-started/install"
        fi
    fi

    # Get dependencies
    log_info "Getting Flutter dependencies..."
    ../tools/flutter pub get

    # Run code generation
    log_info "Running code generation..."
    ../tools/flutter pub run build_runner build --delete-conflicting-outputs

    # Enable web platform if requested
    if should_setup_flutter_web; then
        log_info "Enabling web platform..."
        ../tools/flutter create . --platforms=web
        log_success "Web platform enabled"
    fi

    log_success "Flutter setup complete"
}

# Create run scripts
create_run_scripts() {
    log_section "Creating convenience scripts"

    # Backend run script
    cat > "$PROJECT_ROOT/run-backend.sh" << 'EOF'
#!/bin/bash
# run-backend.sh - Start GrabTube backend server
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/Web-Client"

# Source ffmpeg environment
if [ -f "tools/ffmpeg-env.sh" ]; then
    source tools/ffmpeg-env.sh
fi

# Activate virtual environment and run
if [ -f ".venv/bin/activate" ]; then
    source .venv/bin/activate
    python app/main.py
else
    echo "Error: Virtual environment not found. Run ./setup.sh --backend first"
    exit 1
fi
EOF
    chmod +x "$PROJECT_ROOT/run-backend.sh"
    log_success "Created run-backend.sh"

    # Flutter run script
    cat > "$PROJECT_ROOT/run-flutter-web.sh" << 'EOF'
#!/bin/bash
# run-flutter-web.sh - Start Flutter web client
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/Flutter-Client"

if [ -f "../tools/flutter" ]; then
    ../tools/flutter run -d chrome --web-port=8080
else
    echo "Error: Flutter not set up. Run ./setup.sh --flutter first"
    exit 1
fi
EOF
    chmod +x "$PROJECT_ROOT/run-flutter-web.sh"
    log_success "Created run-flutter-web.sh"

    # Combined run script
    cat > "$PROJECT_ROOT/run-all.sh" << 'EOF'
#!/bin/bash
# run-all.sh - Start both backend and Flutter web client
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Starting GrabTube..."
echo ""
echo "Starting backend server..."
"$SCRIPT_DIR/run-backend.sh" &
BACKEND_PID=$!

echo "Waiting for backend to start..."
sleep 3

echo "Starting Flutter web client..."
"$SCRIPT_DIR/run-flutter-web.sh" &
FLUTTER_PID=$!

echo ""
echo "╔════════════════════════════════════════╗"
echo "║   GrabTube is running!                 ║"
echo "╠════════════════════════════════════════╣"
echo "║   Backend:  http://localhost:8081      ║"
echo "║   Flutter:  http://localhost:8080      ║"
echo "╚════════════════════════════════════════╝"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for both processes
wait $BACKEND_PID $FLUTTER_PID
EOF
    chmod +x "$PROJECT_ROOT/run-all.sh"
    log_success "Created run-all.sh"
}

# Update .gitignore
update_gitignore() {
    log_section "Updating .gitignore"

    GITIGNORE="$PROJECT_ROOT/.gitignore"

    # Backup existing .gitignore
    if [ -f "$GITIGNORE" ]; then
        cp "$GITIGNORE" "$GITIGNORE.backup"
    fi

    # Add local dependencies section
    cat >> "$GITIGNORE" << 'EOF'

# ═══════════════════════════════════════════════════
# Local Dependencies (automatically downloaded)
# ═══════════════════════════════════════════════════

# Python virtual environment
Web-Client/.venv/
Web-Client/requirements.txt
Web-Client/activate-venv.sh

# ffmpeg binaries (automatically downloaded)
Web-Client/tools/ffmpeg/
Web-Client/tools/ffmpeg-wrapper.sh
Web-Client/tools/ffprobe-wrapper.sh
Web-Client/tools/ffmpeg-env.sh

# Flutter SDK (automatically downloaded)
tools/flutter-sdk/
tools/.flutter-version

# Placeholder UI
Web-Client/ui/dist/

# Runtime data
Web-Client/.metube/
*.pyc
__pycache__/

# Run scripts
run-backend.sh
run-flutter-web.sh
run-all.sh

EOF

    log_success ".gitignore updated"
}

# Print usage
usage() {
    cat << EOF
GrabTube Setup Script

Usage: $0 [OPTIONS]

Options:
    --all            Setup everything (backend + flutter)
    --backend        Setup Python backend only
    --flutter        Setup Flutter client only
    --flutter-web    Enable Flutter web platform
    --dev            Install development dependencies
    --help           Show this help message

Examples:
    $0 --all                   # Complete setup
    $0 --backend --dev         # Backend with dev dependencies
    $0 --flutter --flutter-web # Flutter with web support

After setup, use:
    ./run-backend.sh           # Start backend server
    ./run-flutter-web.sh       # Start Flutter web client
    ./run-all.sh               # Start both servers

EOF
}

# Main setup process
main() {
    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║                                        ║"
    echo "║         GrabTube Setup                 ║"
    echo "║    Automated Dependency Management     ║"
    echo "║                                        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""

    # Parse arguments
    SETUP_ALL="false"
    SETUP_BACKEND="false"
    SETUP_FLUTTER="false"
    SETUP_FLUTTER_WEB="false"
    DEV_MODE=""

    if [ $# -eq 0 ]; then
        SETUP_ALL="true"
    fi

    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                SETUP_ALL="true"
                ;;
            --backend)
                SETUP_BACKEND="true"
                ;;
            --flutter)
                SETUP_FLUTTER="true"
                ;;
            --flutter-web)
                SETUP_FLUTTER_WEB="true"
                ;;
            --dev)
                DEV_MODE="--dev"
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done

    # Perform setup
    if should_setup_backend; then
        setup_backend $DEV_MODE
    fi

    if should_setup_flutter || should_setup_flutter_web; then
        setup_flutter
    fi

    create_run_scripts
    update_gitignore

    echo ""
    echo "╔════════════════════════════════════════╗"
    echo "║                                        ║"
    echo "║   Setup Complete! ✓                    ║"
    echo "║                                        ║"
    echo "╚════════════════════════════════════════╝"
    echo ""
    log_info "All dependencies are now locally installed"
    log_info "No system-wide installation required!"
    echo ""
    log_info "Quick start:"
    echo "  1. Start backend:       ./run-backend.sh"
    echo "  2. Start Flutter web:   ./run-flutter-web.sh"
    echo "  3. Or start both:       ./run-all.sh"
    echo ""
    log_info "Backend will be available at: http://localhost:8081"
    log_info "Flutter web will be available at: http://localhost:8080"
    echo ""
}

# Run main function
main "$@"
