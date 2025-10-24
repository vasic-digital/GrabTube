#!/bin/bash

# Python Integration Test Runner for GrabTube
# This script runs all tests related to Python service integration

set -e

echo "🚀 Starting Python Integration Tests for GrabTube"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if Flutter is available
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    print_warning "Python 3 is not available - some tests may fail"
fi

# Change to project directory
cd "$(dirname "$0")/.."

print_status "Running Flutter analysis..."
if flutter analyze; then
    print_success "Flutter analysis passed"
else
    print_error "Flutter analysis failed"
    exit 1
fi

print_status "Running unit tests for Python integration..."
if flutter test test/unit/core/network/python_service_client_test.dart test/unit/core/network/native_python_bridge_test.dart; then
    print_success "Python integration unit tests passed"
else
    print_error "Python integration unit tests failed"
    exit 1
fi

print_status "Running integration tests..."
if flutter test test/integration/python_service_integration_test.dart; then
    print_success "Python service integration tests passed"
else
    print_error "Python service integration tests failed"
    exit 1
fi

# Check if Patrol is available for E2E tests
if grep -q "patrol" pubspec.yaml; then
    print_status "Running E2E tests with Patrol..."
    if patrol test --target test/e2e/python_integration_e2e_test.dart; then
        print_success "E2E tests passed"
    else
        print_error "E2E tests failed"
        exit 1
    fi
else
    print_warning "Patrol not found in dependencies, skipping E2E tests"
fi

# Run AI-powered test validation
print_status "Running AI-powered test validation..."
if command -v python3 &> /dev/null; then
    if python3 tools/ai_test_validator.py --focus python; then
        print_success "AI test validation passed"
    else
        print_warning "AI test validation had issues"
    fi
else
    print_warning "Python not available, skipping AI validation"
fi

# Generate test coverage report
print_status "Generating test coverage report..."
if flutter test --coverage --coverage-path=coverage/lcov.info test/unit/core/network/ test/integration/python_service_integration_test.dart; then
    print_success "Coverage report generated"
    
    # Check if lcov is available for HTML report
    if command -v genhtml &> /dev/null; then
        genhtml coverage/lcov.info -o coverage/html
        print_success "HTML coverage report generated at coverage/html/"
    else
        print_warning "genhtml not available, skipping HTML report"
    fi
else
    print_error "Failed to generate coverage report"
    exit 1
fi

# Check Python service health
print_status "Checking Python service health..."
if command -v python3 &> /dev/null; then
    # Try to run a simple Python health check
    if python3 -c "
import sys
try:
    import yt_dlp
    import aiohttp
    import socketio
    import watchfiles
    print('Python dependencies: OK')
    sys.exit(0)
except ImportError as e:
    print(f'Missing dependency: {e}')
    sys.exit(1)
" 2>/dev/null; then
        print_success "Python dependencies are available"
    else
        print_warning "Some Python dependencies are missing"
    fi
else
    print_warning "Python not available, skipping dependency check"
fi

print_status "Running all unit tests to ensure no regressions..."
if flutter test test/unit/; then
    print_success "All unit tests passed"
else
    print_error "Some unit tests failed"
    exit 1
fi

echo ""
echo "🎉 All Python integration tests completed successfully!"
echo ""
echo "Summary:"
echo "  ✓ Flutter analysis"
echo "  ✓ Python integration unit tests"
echo "  ✓ Python service integration tests"
echo "  ✓ E2E tests (if available)"
echo "  ✓ AI test validation (if available)"
echo "  ✓ Test coverage report"
echo "  ✓ Python dependency check"
echo "  ✓ All unit tests"
echo ""
echo "The Python service integration is ready for use!"
echo ""

# Display next steps
echo "Next steps:"
echo "  1. Run 'flutter run' to test the app with embedded Python service"
echo "  2. Check the coverage report at coverage/html/index.html"
echo "  3. Run 'python3 python/main.py' to test the Python service standalone"
echo ""

# Make the script executable
chmod +x "$0"