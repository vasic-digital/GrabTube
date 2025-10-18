#!/bin/bash

# GrabTube Test Runner Script
# Runs all tests with coverage and generates reports

set -e

echo "🧪 GrabTube Test Suite Runner"
echo "=============================="

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Change to project directory
cd "$(dirname "$0")/.."

# Clean previous coverage data
echo -e "\n${YELLOW}Cleaning previous test data...${NC}"
rm -rf coverage/
rm -f test_validation_report.json

# Run tests with coverage
echo -e "\n${YELLOW}Running unit tests with coverage...${NC}"
flutter test test/unit --coverage || {
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
}

echo -e "\n${GREEN}✅ Unit tests passed${NC}"

# Run widget tests
echo -e "\n${YELLOW}Running widget tests...${NC}"
flutter test test/widget || {
    echo -e "${RED}❌ Widget tests failed${NC}"
    exit 1
}

echo -e "\n${GREEN}✅ Widget tests passed${NC}"

# Run integration tests
echo -e "\n${YELLOW}Running integration tests...${NC}"
flutter test test/integration || {
    echo -e "${RED}❌ Integration tests failed${NC}"
    exit 1
}

echo -e "\n${GREEN}✅ Integration tests passed${NC}"

# Generate coverage report
echo -e "\n${YELLOW}Generating coverage report...${NC}"
if command -v lcov &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo -e "${GREEN}✅ Coverage report generated at coverage/html/index.html${NC}"
else
    echo -e "${YELLOW}⚠️  lcov not installed, skipping HTML report generation${NC}"
fi

# Run AI-powered test validation
echo -e "\n${YELLOW}Running AI test validation...${NC}"
if command -v python3 &> /dev/null; then
    python3 tools/ai_test_validator.py || {
        echo -e "${RED}❌ AI validation detected issues${NC}"
        exit 1
    }
else
    echo -e "${YELLOW}⚠️  Python 3 not installed, skipping AI validation${NC}"
fi

echo -e "\n${GREEN}=============================="
echo -e "✅ All tests passed successfully!${NC}"
echo -e "${GREEN}==============================${NC}\n"
