#!/bin/bash

# GrabTube Universal Build Script
# Builds all applications and modules in the correct order

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Build tracking
TOTAL_BUILDS=0
SUCCESSFUL_BUILDS=0
FAILED_BUILDS=0

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((SUCCESSFUL_BUILDS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED_BUILDS++))
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to track build attempts
start_build() {
    local name=$1
    ((TOTAL_BUILDS++))
    print_status "Starting build: $name"
}

# Function to handle build completion
end_build() {
    local name=$1
    local status=$2
    if [ $status -eq 0 ]; then
        print_success "$name build completed successfully"
    else
        print_error "$name build failed"
    fi
}

# Function to build Python backend
build_python_backend() {
    start_build "Python Backend (Web-Client)"

    if [ ! -d "Web-Client" ]; then
        print_error "Web-Client directory not found"
        return 1
    fi

    cd Web-Client

    # Check if uv is available
    if ! command -v uv &> /dev/null; then
        print_error "uv package manager not found"
        cd ..
        return 1
    fi

    # Install/sync dependencies
    print_status "Installing Python dependencies..."
    if ! uv sync --quiet; then
        print_error "Failed to install Python dependencies"
        cd ..
        return 1
    fi

    # Basic validation - check if main.py can be imported
    print_status "Validating Python backend..."
    if python3 -c "
import sys
sys.path.insert(0, '.')
try:
    import main
    print('Python backend validation: OK')
except ImportError as e:
    print(f'Import error: {e}')
    sys.exit(1)
" 2>/dev/null; then
        print_success "Python backend validation passed"
    else
        print_error "Python backend validation failed"
        cd ..
        return 1
    fi

    cd ..
    end_build "Python Backend (Web-Client)" 0
    return 0
}

# Function to build Angular frontend
build_angular_frontend() {
    start_build "Angular Frontend (Web-Client/ui)"

    if [ ! -d "Web-Client/ui" ]; then
        print_error "Web-Client/ui directory not found"
        return 1
    fi

    cd Web-Client/ui

    # Check if npm is available
    if ! command -v npm &> /dev/null; then
        print_error "npm not found"
        cd ../..
        return 1
    fi

    # Install dependencies
    print_status "Installing Node.js dependencies..."
    if ! npm install --silent; then
        print_error "Failed to install Node.js dependencies"
        cd ../..
        return 1
    fi

    # Build Angular application
    print_status "Building Angular application..."
    if ! npm run build --silent; then
        print_error "Angular build failed"
        cd ../..
        return 1
    fi

    # Check if build output exists
    if [ ! -d "dist/metube" ]; then
        print_error "Angular build output not found"
        cd ../..
        return 1
    fi

    cd ../..
    end_build "Angular Frontend (Web-Client/ui)" 0
    return 0
}

# Function to build Flutter mobile app
build_flutter_mobile() {
    start_build "Flutter Mobile App (Flutter-Client)"

    if [ ! -d "Flutter-Client" ]; then
        print_error "Flutter-Client directory not found"
        return 1
    fi

    cd Flutter-Client

    # Check if flutter is available
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter SDK not found"
        cd ..
        return 1
    fi

    # Get dependencies
    print_status "Getting Flutter dependencies..."
    if ! flutter pub get --suppress-analytics; then
        print_error "Failed to get Flutter dependencies"
        cd ..
        return 1
    fi

    # Run code generation
    print_status "Running code generation..."
    if ! flutter pub run build_runner build --delete-conflicting-outputs --suppress-analytics; then
        print_error "Code generation failed"
        cd ..
        return 1
    fi

    # Analyze code
    print_status "Analyzing code..."
    if ! flutter analyze --suppress-analytics; then
        print_error "Code analysis failed"
        cd ..
        return 1
    fi

    # Build debug APK
    print_status "Building debug APK..."
    if ! flutter build apk --debug --suppress-analytics; then
        print_error "Debug APK build failed"
        cd ..
        return 1
    fi

    # Build release APK
    print_status "Building release APK..."
    if ! flutter build apk --release --suppress-analytics; then
        print_error "Release APK build failed"
        cd ..
        return 1
    fi

    # Build web version
    print_status "Building web version..."
    if ! flutter build web --release --suppress-analytics; then
        print_error "Web build failed"
        cd ..
        return 1
    fi

    cd ..
    end_build "Flutter Mobile App (Flutter-Client)" 0
    return 0
}

# Function to build Flutter web app
build_flutter_web() {
    start_build "Flutter Web App (Flutter-Client/flutter-web)"

    if [ ! -d "Flutter-Client/flutter-web" ]; then
        print_error "Flutter-Client/flutter-web directory not found"
        return 1
    fi

    cd Flutter-Client/flutter-web

    # Check if flutter is available
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter SDK not found"
        cd ../..
        return 1
    fi

    # Get dependencies
    print_status "Getting Flutter dependencies..."
    if ! flutter pub get --suppress-analytics; then
        print_error "Failed to get Flutter dependencies"
        cd ../..
        return 1
    fi

    # Run code generation
    print_status "Running code generation..."
    if ! flutter pub run build_runner build --delete-conflicting-outputs --suppress-analytics; then
        print_error "Code generation failed"
        cd ../..
        return 1
    fi

    # Analyze code
    print_status "Analyzing code..."
    if ! flutter analyze --suppress-analytics; then
        print_error "Code analysis failed"
        cd ../..
        return 1
    fi

    # Build web version
    print_status "Building web version..."
    if ! flutter build web --release --suppress-analytics; then
        print_error "Web build failed"
        cd ../..
        return 1
    fi

    cd ../..
    end_build "Flutter Web App (Flutter-Client/flutter-web)" 0
    return 0
}

# Function to build Android native app
build_android_native() {
    start_build "Android Native App (Android-Client)"

    if [ ! -d "Android-Client" ]; then
        print_error "Android-Client directory not found"
        return 1
    fi

    cd Android-Client

    # Check if Java is available
    if ! command -v java &> /dev/null; then
        print_error "Java not found"
        cd ..
        return 1
    fi

    # Use gradlew wrapper
    if [ ! -f "gradlew" ]; then
        print_error "Gradle wrapper not found"
        cd ..
        return 1
    fi

    # Make gradlew executable
    chmod +x gradlew

    # Build debug variant
    print_status "Building Android debug variant..."
    if ! ./gradlew assembleDebug --no-daemon; then
        print_error "Android debug build failed"
        cd ..
        return 1
    fi

    # Build release variant
    print_status "Building Android release variant..."
    if ! ./gradlew assembleRelease --no-daemon; then
        print_error "Android release build failed"
        cd ..
        return 1
    fi

    # Run unit tests
    print_status "Running Android unit tests..."
    if ! ./gradlew testDebugUnitTest --no-daemon; then
        print_error "Android unit tests failed"
        cd ..
        return 1
    fi

    cd ..
    end_build "Android Native App (Android-Client)" 0
    return 0
}

# Function to generate build summary
generate_build_summary() {
    print_header "📊 Build Summary"
    echo "Total Builds Attempted: $TOTAL_BUILDS"
    echo "Successful Builds: $SUCCESSFUL_BUILDS"
    echo "Failed Builds: $FAILED_BUILDS"
    echo ""

    if [ $FAILED_BUILDS -eq 0 ]; then
        echo -e "${GREEN}🎉 All builds completed successfully!${NC}"
        echo -e "${GREEN}All GrabTube applications are ready for deployment.${NC}"
        return 0
    else
        echo -e "${RED}❌ Some builds failed. Check the output above for details.${NC}"
        return 1
    fi
}

# Main execution
print_header "🔨 GrabTube Universal Build System"
print_status "Starting comprehensive build process..."
echo "Date: $(date)"
echo "Host: $(hostname)"
echo "User: $(whoami)"
echo ""

# Run environment verification first
print_status "Running environment verification..."
if ! ./verify-environment.sh; then
    print_error "Environment verification failed. Please fix issues and try again."
    exit 1
fi

# Build all applications in order
print_header "🏗️  Building Applications"

# 1. Python Backend
if ! build_python_backend; then
    print_error "Python backend build failed, but continuing with other builds..."
fi

# 2. Angular Frontend
if ! build_angular_frontend; then
    print_error "Angular frontend build failed, but continuing with other builds..."
fi

# 3. Flutter Mobile App
if ! build_flutter_mobile; then
    print_error "Flutter mobile build failed, but continuing with other builds..."
fi

# 4. Flutter Web App
if ! build_flutter_web; then
    print_error "Flutter web build failed, but continuing with other builds..."
fi

# 5. Android Native App
if ! build_android_native; then
    print_error "Android native build failed, but continuing with other builds..."
fi

# Generate summary
echo ""
generate_build_summary

# Exit with appropriate code
if [ $FAILED_BUILDS -eq 0 ]; then
    print_status "All builds completed successfully!"
    print_status "You can now run: ./test-all.sh"
    exit 0
else
    print_error "Some builds failed. Check the output above for details."
    exit 1
fi