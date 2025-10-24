#!/bin/bash

# GrabTube Android Emulator Management Script
# Manages Android Virtual Devices (AVDs) for testing

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEFAULT_API_LEVEL=33
DEFAULT_DEVICE="pixel_6"
DEFAULT_EMULATOR_NAME="grabtube_test_emulator"
HEADLESS_MODE=true

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to check Android SDK
check_android_sdk() {
    if [ -z "$ANDROID_HOME" ]; then
        print_error "ANDROID_HOME environment variable not set"
        return 1
    fi

    if [ ! -d "$ANDROID_HOME" ]; then
        print_error "Android SDK not found at $ANDROID_HOME"
        return 1
    fi

    print_success "Android SDK found at $ANDROID_HOME"
    return 0
}

# Function to check emulator tools
check_emulator_tools() {
    if ! command -v emulator &> /dev/null; then
        print_error "Android emulator command not found"
        print_status "Make sure Android SDK tools are installed and in PATH"
        return 1
    fi

    if ! command -v adb &> /dev/null; then
        print_error "ADB command not found"
        print_status "Make sure Android SDK platform-tools are installed and in PATH"
        return 1
    fi

    print_success "Emulator tools available"
    return 0
}

# Function to list available AVDs
list_avds() {
    print_header "Available Android Virtual Devices"

    if ! emulator -list-avds > /dev/null 2>&1; then
        print_warning "No AVDs found or emulator not properly configured"
        return 1
    fi

    local avds
    avds=$(emulator -list-avds)

    if [ -z "$avds" ]; then
        print_warning "No Android Virtual Devices found"
        echo "Run: $0 create"
        return 1
    fi

    echo "$avds"
    return 0
}

# Function to create AVD
create_avd() {
    local api_level=${1:-$DEFAULT_API_LEVEL}
    local device=${2:-$DEFAULT_DEVICE}
    local name=${3:-$DEFAULT_EMULATOR_NAME}

    print_header "Creating Android Virtual Device"
    print_status "Name: $name"
    print_status "Device: $device"
    print_status "API Level: $api_level"

    # Check if AVD already exists
    if emulator -list-avds | grep -q "^$name$"; then
        print_warning "AVD '$name' already exists"
        return 0
    fi

    # Create AVD
    print_status "Creating AVD..."
    if ! echo "no" | avdmanager create avd -n "$name" -k "system-images;android-$api_level;google_apis;x86_64" -d "$device" --force; then
        print_error "Failed to create AVD"
        print_status "Make sure system image is installed:"
        print_status "sdkmanager \"system-images;android-$api_level;google_apis;x86_64\""
        return 1
    fi

    print_success "AVD '$name' created successfully"
    return 0
}

# Function to start emulator
start_emulator() {
    local name=${1:-$DEFAULT_EMULATOR_NAME}
    local headless=${2:-$HEADLESS_MODE}

    print_header "Starting Android Emulator"
    print_status "AVD: $name"
    print_status "Headless: $headless"

    # Check if AVD exists
    if ! emulator -list-avds | grep -q "^$name$"; then
        print_error "AVD '$name' not found"
        print_status "Available AVDs:"
        list_avds
        return 1
    fi

    # Check if emulator is already running
    if adb devices | grep -q "emulator"; then
        print_warning "Emulator already running"
        return 0
    fi

    # Start emulator
    print_status "Starting emulator (this may take a few minutes)..."

    local cmd="emulator -avd $name"
    if [ "$headless" = true ]; then
        cmd="$cmd -no-window -no-audio -no-boot-anim"
    fi

    # Start emulator in background
    $cmd > /dev/null 2>&1 &
    local emulator_pid=$!

    # Wait for emulator to boot
    print_status "Waiting for emulator to boot..."
    local max_attempts=60
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if adb devices | grep -q "device$"; then
            print_success "Emulator booted successfully"
            print_status "Emulator PID: $emulator_pid"
            return 0
        fi

        sleep 5
        ((attempt++))
        print_status "Waiting... ($attempt/$max_attempts)"
    done

    print_error "Emulator failed to boot within timeout"
    kill_emulator
    return 1
}

# Function to stop emulator
stop_emulator() {
    print_header "Stopping Android Emulator"

    # Find and kill emulator processes
    local emulator_pids
    emulator_pids=$(pgrep -f "emulator")

    if [ -z "$emulator_pids" ]; then
        print_warning "No emulator processes found"
        return 0
    fi

    print_status "Stopping emulator processes: $emulator_pids"
    kill $emulator_pids 2>/dev/null || true

    # Wait for processes to die
    sleep 2

    # Force kill if still running
    if pgrep -f "emulator" > /dev/null; then
        print_warning "Force killing emulator processes..."
        pkill -9 -f "emulator" 2>/dev/null || true
    fi

    print_success "Emulator stopped"
    return 0
}

# Function to check emulator status
check_emulator_status() {
    print_header "Emulator Status"

    # Check for running emulator processes
    if pgrep -f "emulator" > /dev/null; then
        print_success "Emulator process is running"
    else
        print_warning "No emulator process found"
    fi

    # Check ADB devices
    local devices
    devices=$(adb devices 2>/dev/null | grep -v "List of devices")

    if echo "$devices" | grep -q "device$"; then
        print_success "Emulator device connected via ADB"
        echo "$devices"
    else
        print_warning "No emulator device connected via ADB"
    fi

    return 0
}

# Function to run tests on emulator
run_tests_on_emulator() {
    print_header "Running Tests on Emulator"

    # Check if emulator is running
    if ! adb devices | grep -q "device$"; then
        print_error "No emulator device available"
        print_status "Start emulator first: $0 start"
        return 1
    fi

    print_success "Emulator is ready for testing"
    print_status "Connected devices:"
    adb devices

    # Note: Actual test execution would be handled by the test scripts
    print_status "Use ./test-all.sh to run the full test suite"
    return 0
}

# Function to clean up AVD
cleanup_avd() {
    local name=${1:-$DEFAULT_EMULATOR_NAME}

    print_header "Cleaning Up AVD"
    print_status "AVD: $name"

    # Stop emulator first
    stop_emulator

    # Delete AVD
    if emulator -list-avds | grep -q "^$name$"; then
        print_status "Deleting AVD '$name'..."
        if avdmanager delete avd -n "$name"; then
            print_success "AVD '$name' deleted"
        else
            print_error "Failed to delete AVD '$name'"
            return 1
        fi
    else
        print_warning "AVD '$name' not found"
    fi

    return 0
}

# Function to show usage
show_usage() {
    cat << EOF
GrabTube Android Emulator Management Script

USAGE:
    $0 <command> [options]

COMMANDS:
    list                    List available Android Virtual Devices
    create [api] [device] [name]    Create a new AVD
                            api: Android API level (default: $DEFAULT_API_LEVEL)
                            device: Device type (default: $DEFAULT_DEVICE)
                            name: AVD name (default: $DEFAULT_EMULATOR_NAME)
    start [name] [headless]         Start emulator
                            name: AVD name (default: $DEFAULT_EMULATOR_NAME)
                            headless: Run without UI (default: $HEADLESS_MODE)
    stop                    Stop running emulator
    status                  Show emulator status
    test                    Check if emulator is ready for testing
    cleanup [name]          Delete AVD and stop emulator
                            name: AVD name (default: $DEFAULT_EMULATOR_NAME)
    help                    Show this help message

EXAMPLES:
    $0 list
    $0 create 33 pixel_6 my_emulator
    $0 start
    $0 status
    $0 test
    $0 stop
    $0 cleanup

ENVIRONMENT:
    ANDROID_HOME must be set to Android SDK location
    Android SDK tools must be in PATH

EOF
}

# Main execution
main() {
    local command=$1

    case $command in
        list)
            check_android_sdk && check_emulator_tools && list_avds
            ;;
        create)
            check_android_sdk && check_emulator_tools && create_avd "$2" "$3" "$4"
            ;;
        start)
            check_android_sdk && check_emulator_tools && start_emulator "$2" "$3"
            ;;
        stop)
            stop_emulator
            ;;
        status)
            check_emulator_status
            ;;
        test)
            check_android_sdk && check_emulator_tools && run_tests_on_emulator
            ;;
        cleanup)
            cleanup_avd "$2"
            ;;
        help|--help|-h)
            show_usage
            ;;
        *)
            print_error "Unknown command: $command"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"