#!/bin/bash

# GrabTube Universal Test Script
# Runs all test suites across all applications with comprehensive reporting

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test tracking
TOTAL_TEST_SUITES=0
PASSED_TEST_SUITES=0
FAILED_TEST_SUITES=0
TOTAL_COVERAGE=0
COVERAGE_COUNT=0

# Results storage
TEST_RESULTS_FILE="COMPREHENSIVE_TEST_RESULTS.md"
COVERAGE_DIR="coverage_reports"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASSED_TEST_SUITES++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((FAILED_TEST_SUITES++))
}

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Function to track test suite
start_test_suite() {
    local name=$1
    ((TOTAL_TEST_SUITES++))
    print_status "Starting test suite: $name"
}

# Function to handle test completion
end_test_suite() {
    local name=$1
    local status=$2
    local coverage=${3:-0}

    if [ $status -eq 0 ]; then
        print_success "$name tests passed"
        if [ "$coverage" != "0" ]; then
            echo -e "${GREEN}  📊 Coverage: ${coverage}%${NC}"
            TOTAL_COVERAGE=$((TOTAL_COVERAGE + coverage))
            ((COVERAGE_COUNT++))
        fi
    else
        print_error "$name tests failed"
    fi
}

# Function to run Python backend tests
test_python_backend() {
    start_test_suite "Python Backend (Web-Client)"

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
    print_status "Ensuring Python dependencies..."
    if ! uv sync --quiet; then
        print_error "Failed to sync Python dependencies"
        cd ..
        return 1
    fi

    # Run pylint
    print_status "Running pylint code analysis..."
    if uv run pylint app/ --output-format=colorized --reports=no > pylint_report.txt 2>&1; then
        print_success "Pylint analysis passed"
    else
        print_warning "Pylint analysis found issues (check pylint_report.txt)"
    fi

    # Run basic Python tests (if any exist)
    if [ -d "tests" ] || find . -name "*test*.py" -type f | grep -q .; then
        print_status "Running Python unit tests..."
        if uv run python -m pytest --tb=short --quiet; then
            print_success "Python unit tests passed"
        else
            print_error "Python unit tests failed"
            cd ..
            return 1
        fi
    else
        print_warning "No Python unit tests found"
    fi

    cd ..
    end_test_suite "Python Backend (Web-Client)" 0
    return 0
}

# Function to run Angular frontend tests
test_angular_frontend() {
    start_test_suite "Angular Frontend (Web-Client/ui)"

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
    print_status "Ensuring Node.js dependencies..."
    if ! npm install --silent; then
        print_error "Failed to install Node.js dependencies"
        cd ../..
        return 1
    fi

    # Run linting
    print_status "Running ESLint..."
    if npm run lint --silent 2>/dev/null; then
        print_success "ESLint passed"
    else
        print_warning "ESLint found issues"
    fi

    # Run Angular tests
    print_status "Running Angular unit tests..."
    if npm test -- --watch=false --browsers=ChromeHeadless 2>/dev/null; then
        print_success "Angular unit tests passed"
    else
        print_error "Angular unit tests failed"
        cd ../..
        return 1
    fi

    cd ../..
    end_test_suite "Angular Frontend (Web-Client/ui)" 0
    return 0
}

# Function to run Flutter tests
test_flutter() {
    start_test_suite "Flutter Tests (Flutter-Client)"

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
    print_status "Ensuring Flutter dependencies..."
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
    print_status "Running code analysis..."
    if ! flutter analyze --suppress-analytics; then
        print_error "Code analysis failed"
        cd ..
        return 1
    fi

    # Run unit tests with coverage
    print_status "Running unit tests with coverage..."
    if flutter test test/unit --coverage --suppress-analytics; then
        print_success "Unit tests passed"

        # Calculate coverage
        if [ -f "coverage/lcov.info" ] && command -v lcov &> /dev/null; then
            local coverage
            coverage=$(lcov --summary coverage/lcov.info 2>/dev/null | grep -oP "lines\.*:\s*\K\d+\.\d+" || echo "0")
            if [ "$coverage" != "0" ]; then
                end_test_suite "Flutter Unit Tests" 0 "$coverage"
            else
                end_test_suite "Flutter Unit Tests" 0
            fi
        else
            end_test_suite "Flutter Unit Tests" 0
        fi
    else
        print_error "Unit tests failed"
        cd ..
        return 1
    fi

    # Run widget tests
    print_status "Running widget tests..."
    if flutter test test/widget --suppress-analytics; then
        print_success "Widget tests passed"
    else
        print_error "Widget tests failed"
        cd ..
        return 1
    fi

    # Run integration tests
    print_status "Running integration tests..."
    if flutter test test/integration --suppress-analytics; then
        print_success "Integration tests passed"
    else
        print_error "Integration tests failed"
        cd ..
        return 1
    fi

    # Run E2E tests with Patrol (if available)
    if grep -q "patrol" pubspec.yaml && command -v patrol &> /dev/null; then
        print_status "Running E2E tests with Patrol..."
        if patrol test --suppress-analytics; then
            print_success "E2E tests passed"
        else
            print_error "E2E tests failed"
            cd ..
            return 1
        fi
    else
        print_warning "Patrol not available, skipping E2E tests"
    fi

    # Run AI-powered test validation
    if [ -f "tools/ai_test_validator.py" ] && command -v python3 &> /dev/null; then
        print_status "Running AI-powered test validation..."
        if python3 tools/ai_test_validator.py --quiet; then
            print_success "AI test validation passed"
        else
            print_warning "AI test validation found issues"
        fi
    fi

    cd ..
    end_test_suite "Flutter Tests (Flutter-Client)" 0
    return 0
}

# Function to run Android native tests
test_android_native() {
    start_test_suite "Android Native Tests (Android-Client)"

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

    # Run unit tests
    print_status "Running Android unit tests..."
    if ./gradlew testDebugUnitTest --no-daemon; then
        print_success "Android unit tests passed"
    else
        print_error "Android unit tests failed"
        cd ..
        return 1
    fi

    # Run linting
    print_status "Running Android linting..."
    if ./gradlew lintDebug --no-daemon; then
        print_success "Android linting passed"
    else
        print_warning "Android linting found issues"
    fi

    # Check for emulator and run instrumented tests if available
    if [ -n "$ANDROID_HOME" ] && [ -f "$ANDROID_HOME/emulator/emulator" ] && command -v emulator &> /dev/null; then
        print_status "Checking for Android emulator..."

        # List available AVDs
        local avds
        avds=$(emulator -list-avds 2>/dev/null || echo "")

        if [ -n "$avds" ]; then
            print_status "Found Android Virtual Devices, running instrumented tests..."
            # Note: This would require a running emulator, which is complex to set up
            # For now, we'll skip instrumented tests in automated builds
            print_warning "Skipping instrumented tests (requires running emulator)"
        else
            print_warning "No Android Virtual Devices found, skipping instrumented tests"
        fi
    else
        print_warning "Android emulator not available, skipping instrumented tests"
    fi

    cd ..
    end_test_suite "Android Native Tests (Android-Client)" 0
    return 0
}

# Function to run Python integration tests
test_python_integration() {
    start_test_suite "Python Integration Tests (Flutter-Client)"

    if [ ! -d "Flutter-Client" ]; then
        print_error "Flutter-Client directory not found"
        return 1
    fi

    cd Flutter-Client

    # Run Python integration test script
    if [ -f "tools/run_python_integration_tests.sh" ]; then
        print_status "Running Python integration tests..."
        if bash tools/run_python_integration_tests.sh; then
            print_success "Python integration tests passed"
        else
            print_error "Python integration tests failed"
            cd ..
            return 1
        fi
    else
        print_warning "Python integration test script not found"
    fi

    cd ..
    end_test_suite "Python Integration Tests (Flutter-Client)" 0
    return 0
}

# Function to generate coverage reports
generate_coverage_reports() {
    print_header "📊 Generating Coverage Reports"

    mkdir -p "$COVERAGE_DIR"

    # Flutter coverage
    if [ -d "Flutter-Client/coverage" ]; then
        print_status "Processing Flutter coverage..."
        cp -r Flutter-Client/coverage/* "$COVERAGE_DIR/" 2>/dev/null || true

        if command -v lcov &> /dev/null && [ -f "Flutter-Client/coverage/lcov.info" ]; then
            genhtml Flutter-Client/coverage/lcov.info -o "$COVERAGE_DIR/flutter_html" --quiet
            print_success "Flutter HTML coverage report generated: $COVERAGE_DIR/flutter_html/index.html"
        fi
    fi

    # Calculate average coverage
    if [ $COVERAGE_COUNT -gt 0 ]; then
        local avg_coverage
        avg_coverage=$((TOTAL_COVERAGE / COVERAGE_COUNT))
        print_success "Average test coverage: ${avg_coverage}%"
    fi
}

# Function to generate comprehensive test report
generate_test_report() {
    print_header "📄 Generating Comprehensive Test Report"

    cat > "$TEST_RESULTS_FILE" << EOF
# GrabTube Comprehensive Test Results

## Executive Summary

**Date**: $(date)  
**Environment**: $(hostname)  
**Total Test Suites**: $TOTAL_TEST_SUITES  
**Passed**: $PASSED_TEST_SUITES  
**Failed**: $FAILED_TEST_SUITES  

EOF

    if [ $COVERAGE_COUNT -gt 0 ]; then
        local avg_coverage
        avg_coverage=$((TOTAL_COVERAGE / COVERAGE_COUNT))
        echo "**Average Coverage**: ${avg_coverage}%  " >> "$TEST_RESULTS_FILE"
    fi

    cat >> "$TEST_RESULTS_FILE" << EOF

## Environment Details

- **Host**: $(hostname)
- **User**: $(whoami)
- **OS**: $(uname -a)
- **Shell**: $SHELL

## Build Results Matrix

| Application | Tests | Status | Coverage |
|-------------|-------|--------|----------|
EOF

    # Add test results to table
    echo "| Python Backend | Unit, Lint | $([ $PASSED_TEST_SUITES -ge 1 ] && echo "✅" || echo "❌") | N/A |" >> "$TEST_RESULTS_FILE"
    echo "| Angular Frontend | Unit, Lint | $([ $PASSED_TEST_SUITES -ge 2 ] && echo "✅" || echo "❌") | N/A |" >> "$TEST_RESULTS_FILE"
    echo "| Flutter Mobile | Unit, Widget, Integration, E2E | $([ $PASSED_TEST_SUITES -ge 3 ] && echo "✅" || echo "❌") | $([ $COVERAGE_COUNT -gt 0 ] && echo "$((TOTAL_COVERAGE / COVERAGE_COUNT))%" || echo "N/A") |" >> "$TEST_RESULTS_FILE"
    echo "| Android Native | Unit, Lint | $([ $PASSED_TEST_SUITES -ge 4 ] && echo "✅" || echo "❌") | N/A |" >> "$TEST_RESULTS_FILE"
    echo "| Python Integration | Integration | $([ $PASSED_TEST_SUITES -ge 5 ] && echo "✅" || echo "❌") | N/A |" >> "$TEST_RESULTS_FILE"

    cat >> "$TEST_RESULTS_FILE" << EOF

## Test Results Details

### Python Backend Tests
- **Location**: Web-Client/
- **Tools**: uv, pylint, pytest
- **Status**: $([ $PASSED_TEST_SUITES -ge 1 ] && echo "✅ PASSED" || echo "❌ FAILED")

### Angular Frontend Tests
- **Location**: Web-Client/ui/
- **Tools**: npm, Karma, Jasmine, ESLint
- **Status**: $([ $PASSED_TEST_SUITES -ge 2 ] && echo "✅ PASSED" || echo "❌ FAILED")

### Flutter Tests
- **Location**: Flutter-Client/
- **Tools**: Flutter test, Patrol (E2E), AI Validator
- **Status**: $([ $PASSED_TEST_SUITES -ge 3 ] && echo "✅ PASSED" || echo "❌ FAILED")
- **Coverage**: $([ $COVERAGE_COUNT -gt 0 ] && echo "$((TOTAL_COVERAGE / COVERAGE_COUNT))%" || echo "Not calculated")

### Android Native Tests
- **Location**: Android-Client/
- **Tools**: Gradle, JUnit, Espresso
- **Status**: $([ $PASSED_TEST_SUITES -ge 4 ] && echo "✅ PASSED" || echo "❌ FAILED")

### Python Integration Tests
- **Location**: Flutter-Client/tools/
- **Tools**: Flutter test, Python service
- **Status**: $([ $PASSED_TEST_SUITES -ge 5 ] && echo "✅ PASSED" || echo "❌ FAILED")

## Issues and Resolutions

EOF

    if [ $FAILED_TEST_SUITES -gt 0 ]; then
        echo "### Test Failures" >> "$TEST_RESULTS_FILE"
        echo "- Some test suites failed during execution" >> "$TEST_RESULTS_FILE"
        echo "- Check the console output above for specific error details" >> "$TEST_RESULTS_FILE"
        echo "- Review test logs and fix failing tests before deployment" >> "$TEST_RESULTS_FILE"
        echo "" >> "$TEST_RESULTS_FILE"
    fi

    cat >> "$TEST_RESULTS_FILE" << EOF
## Recommendations

1. **Continuous Integration**: Run this test suite on every code change
2. **Coverage Monitoring**: Maintain test coverage above 80%
3. **Performance Testing**: Add performance benchmarks for critical paths
4. **Security Testing**: Implement security-focused test suites
5. **Cross-platform Testing**: Expand testing across different device configurations

## Coverage Reports

Coverage reports are available in the \`$COVERAGE_DIR/\` directory:
- Flutter HTML Report: \`$COVERAGE_DIR/flutter_html/index.html\`
- Raw LCOV Data: \`$COVERAGE_DIR/lcov.info\`

## Next Steps

1. Review any failed tests and fix issues
2. Address code quality issues identified by linters
3. Improve test coverage for uncovered code paths
4. Run performance tests for production readiness
5. Execute manual testing scenarios

---
*Generated by GrabTube Universal Test Script on $(date)*
EOF

    print_success "Comprehensive test report generated: $TEST_RESULTS_FILE"
}

# Main execution
print_header "🧪 GrabTube Universal Test System"
print_status "Starting comprehensive test execution..."
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

# Run all test suites
print_header "🧪 Running Test Suites"

# 1. Python Backend Tests
if ! test_python_backend; then
    print_error "Python backend tests failed, but continuing with other tests..."
fi

# 2. Angular Frontend Tests
if ! test_angular_frontend; then
    print_error "Angular frontend tests failed, but continuing with other tests..."
fi

# 3. Flutter Tests
if ! test_flutter; then
    print_error "Flutter tests failed, but continuing with other tests..."
fi

# 4. Android Native Tests
if ! test_android_native; then
    print_error "Android native tests failed, but continuing with other tests..."
fi

# 5. Python Integration Tests
if ! test_python_integration; then
    print_error "Python integration tests failed, but continuing with other tests..."
fi

# Generate coverage reports
generate_coverage_reports

# Generate comprehensive test report
generate_test_report

# Final summary
print_header "📊 Test Execution Summary"
echo "Total Test Suites: $TOTAL_TEST_SUITES"
echo "Passed: $PASSED_TEST_SUITES"
echo "Failed: $FAILED_TEST_SUITES"

if [ $COVERAGE_COUNT -gt 0 ]; then
    local avg_coverage
    avg_coverage=$((TOTAL_COVERAGE / COVERAGE_COUNT))
    echo "Average Coverage: ${avg_coverage}%"
fi

echo ""
if [ $FAILED_TEST_SUITES -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed successfully!${NC}"
    echo -e "${GREEN}GrabTube is ready for deployment.${NC}"
    echo -e "${GREEN}📄 Check $TEST_RESULTS_FILE for detailed results${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Check the output above for details.${NC}"
    echo -e "${YELLOW}📄 Review $TEST_RESULTS_FILE for comprehensive analysis${NC}"
    exit 1
fi