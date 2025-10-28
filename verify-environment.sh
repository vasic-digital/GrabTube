#!/bin/bash

# GrabTube Environment Verification Script
# Verifies all required dependencies and tools for building and testing all applications



# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Results tracking
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED_CHECKS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED_CHECKS++))
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to check command availability
check_command() {
    local cmd=$1
    local description=$2
    ((TOTAL_CHECKS++))

    if command -v "$cmd" &> /dev/null; then
        print_success "$description: Available"
        return 0
    else
        print_error "$description: Not found"
        return 1
    fi
}

# Function to check version
check_version() {
    local cmd=$1
    local version_cmd=$2
    local min_version=$3
    local description=$4
    ((TOTAL_CHECKS++))

    if command -v "$cmd" &> /dev/null; then
        local version
        version=$($version_cmd 2>&1 | head -n1)
        print_success "$description: $version"
        return 0
    else
        print_error "$description: Not found"
        return 1
    fi
}

# Function to check Flutter
check_flutter() {
    ((TOTAL_CHECKS++))
    if command -v flutter &> /dev/null; then
        local version
        version=$(flutter --version | head -n1)
        print_success "Flutter: $version"

        # Check Flutter doctor
        print_status "Running flutter doctor..."
        if flutter doctor --suppress-analytics > /dev/null 2>&1; then
            print_success "Flutter doctor: Passed"
        else
            print_warning "Flutter doctor: Issues detected (check manually)"
        fi
        return 0
    else
        print_error "Flutter: Not found"
        return 1
    fi
}

# Function to check Android SDK
check_android_sdk() {
    ((TOTAL_CHECKS++))
    if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME" ]; then
        print_success "Android SDK: $ANDROID_HOME"

        # Check for required Android tools
        if [ -f "$ANDROID_HOME/platform-tools/adb" ]; then
            print_success "Android Debug Bridge (ADB): Available"
        else
            print_warning "Android Debug Bridge (ADB): Not found"
        fi

        # Check for emulator
        if [ -f "$ANDROID_HOME/emulator/emulator" ]; then
            print_success "Android Emulator: Available"
        else
            print_warning "Android Emulator: Not found"
        fi

        return 0
    else
        print_error "Android SDK: Not found (ANDROID_HOME not set)"
        return 1
    fi
}

# Function to check Android emulator
check_android_emulator() {
    ((TOTAL_CHECKS++))
    if command -v emulator &> /dev/null; then
        print_success "Android Emulator CLI: Available"

        # Check for existing AVDs
        if [ -n "$ANDROID_HOME" ] && [ -d "$ANDROID_HOME/avd" ]; then
            local avd_count
            avd_count=$(find "$ANDROID_HOME/avd" -name "*.avd" 2>/dev/null | wc -l)
            if [ "$avd_count" -gt 0 ]; then
                print_success "Android Virtual Devices: $avd_count found"
            else
                print_warning "Android Virtual Devices: None found (will create if needed)"
            fi
        fi
        return 0
    else
        print_error "Android Emulator CLI: Not found"
        return 1
    fi
}

# Function to check Python with uv
check_python_uv() {
    ((TOTAL_CHECKS++))
    if command -v python3 &> /dev/null; then
        local version
        version=$(python3 --version)
        print_success "Python 3: $version"

        # Check uv package manager
        if command -v uv &> /dev/null; then
            local uv_version
            uv_version=$(uv --version)
            print_success "uv package manager: $uv_version"
        else
            print_warning "uv package manager: Not found (install with: pip install uv)"
        fi
        return 0
    else
        print_error "Python 3: Not found"
        return 1
    fi
}

# Function to check Node.js and npm
check_nodejs() {
    ((TOTAL_CHECKS++))
    if command -v node &> /dev/null; then
        local version
        version=$(node --version)
        print_success "Node.js: $version"

        if command -v npm &> /dev/null; then
            local npm_version
            npm_version=$(npm --version)
            print_success "npm: $npm_version"
        else
            print_error "npm: Not found"
            return 1
        fi
        return 0
    else
        print_error "Node.js: Not found"
        return 1
    fi
}

# Function to check Java
check_java() {
    ((TOTAL_CHECKS++))
    if command -v java &> /dev/null; then
        local version
        version=$(java -version 2>&1 | head -n1)
        print_success "Java: $version"

        # Check Java version (need 17+)
        local java_version
        java_version=$(java -version 2>&1 | grep -oP 'version "\K[^"]*' | cut -d. -f1)
        if [ "$java_version" -ge 17 ]; then
            print_success "Java version: Compatible (17+)"
        else
            print_warning "Java version: $java_version (recommended: 17+)"
        fi
        return 0
    else
        print_error "Java: Not found"
        return 1
    fi
}

# Function to check system tools
check_system_tools() {
    local tools=("git" "curl" "wget" "unzip" "tar" "grep" "find" "which")
    local missing_tools=()

    for tool in "${tools[@]}"; do
        ((TOTAL_CHECKS++))
        if command -v "$tool" &> /dev/null; then
            print_success "$tool: Available"
        else
            print_error "$tool: Not found"
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        print_warning "Missing system tools: ${missing_tools[*]}"
        return 1
    fi
    return 0
}

# Function to check coverage tools
check_coverage_tools() {
    ((TOTAL_CHECKS++))
    if command -v lcov &> /dev/null; then
        print_success "lcov: Available"
        return 0
    else
        print_warning "lcov: Not found (install with: apt-get install lcov)"
        return 1
    fi
}

# Function to check Docker (optional for Web-Client)
check_docker() {
    ((TOTAL_CHECKS++))
    if command -v docker &> /dev/null; then
        local version
        version=$(docker --version)
        print_success "Docker: $version"
        return 0
    else
        print_warning "Docker: Not found (optional for Web-Client builds)"
        return 1
    fi
}

# Function to check Flutter dependencies
check_flutter_dependencies() {
    if command -v flutter &> /dev/null; then
        print_status "Checking Flutter dependencies..."

        # Check Flutter-Client
        if [ -f "Flutter-Client/pubspec.yaml" ]; then
            cd Flutter-Client
            if flutter pub get --suppress-analytics > /dev/null 2>&1; then
                print_success "Flutter-Client dependencies: OK"
            else
                print_error "Flutter-Client dependencies: Failed"
            fi
            cd ..
        fi

        # Check Flutter-Web
        if [ -f "Flutter-Client/flutter-web/pubspec.yaml" ]; then
            cd Flutter-Client/flutter-web
            if flutter pub get --suppress-analytics > /dev/null 2>&1; then
                print_success "Flutter-Web dependencies: OK"
            else
                print_error "Flutter-Web dependencies: Failed"
            fi
            cd ../..
        fi
    fi
}

# Function to check Python dependencies
check_python_dependencies() {
    if command -v uv &> /dev/null && [ -f "Web-Client/pyproject.toml" ]; then
        print_status "Checking Python dependencies..."
        cd Web-Client
        if uv sync --quiet > /dev/null 2>&1; then
            print_success "Python dependencies: OK"
        else
            print_error "Python dependencies: Failed"
        fi
        cd ..
    fi
}

# Function to check Node.js dependencies
check_nodejs_dependencies() {
    if command -v npm &> /dev/null && [ -f "Web-Client/ui/package.json" ]; then
        print_status "Checking Node.js dependencies..."
        cd Web-Client/ui
        if npm install --silent > /dev/null 2>&1; then
            print_success "Node.js dependencies: OK"
        else
            print_error "Node.js dependencies: Failed"
        fi
        cd ../..
    fi
}

# Function to check Gradle
check_gradle() {
    ((TOTAL_CHECKS++))
    if command -v gradle &> /dev/null; then
        local version
        version=$(gradle --version | grep "Gradle" | head -n1)
        print_success "Gradle: $version"
        return 0
    else
        print_warning "Gradle: Not found (using gradlew wrapper)"
        return 1
    fi
}

# Main execution
print_header "🧪 GrabTube Environment Verification"
print_status "Starting comprehensive environment check..."
echo "Date: $(date)"
echo "Host: $(hostname)"
echo "User: $(whoami)"
echo "OS: $(uname -a)"
echo ""

# Core Development Tools
print_header "🔧 Core Development Tools"
check_flutter
check_java
check_python_uv
check_nodejs
check_android_sdk
check_gradle

# System Tools
print_header "🖥️  System Tools"
check_system_tools
check_coverage_tools
check_docker

# Android Specific
print_header "🤖 Android Development"
check_android_emulator

# Project Dependencies
print_header "📦 Project Dependencies"
check_flutter_dependencies
check_python_dependencies
check_nodejs_dependencies

# Summary
print_header "📊 Verification Summary"
echo "Total Checks: $TOTAL_CHECKS"
echo "Passed: $PASSED_CHECKS"
echo "Failed: $FAILED_CHECKS"

if [ $FAILED_CHECKS -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All checks passed! Environment is ready for GrabTube development.${NC}"
    echo -e "${GREEN}You can now run: ./build-all.sh and ./test-all.sh${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Some checks failed. Please install missing dependencies.${NC}"
    echo -e "${YELLOW}Run this script again after fixing issues.${NC}"
    exit 1
fi