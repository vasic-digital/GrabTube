#!/bin/bash

# GrabTube Flutter Web Build Script
# Builds the Flutter Web client and optionally deploys to Python backend

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   GrabTube Flutter Web Build Script   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo -e "${YELLOW}   Please install Flutter: https://flutter.dev/docs/get-started/install${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Flutter found: $(flutter --version | head -n 1)"

# Clean previous build
echo -e "\n${BLUE}Cleaning previous build...${NC}"
flutter clean

# Get dependencies
echo -e "\n${BLUE}Getting dependencies...${NC}"
flutter pub get

# Run code generation (if needed)
if grep -q "build_runner" pubspec.yaml; then
    echo -e "\n${BLUE}Running code generation...${NC}"
    flutter pub run build_runner build --delete-conflicting-outputs
fi

# Build for production
echo -e "\n${BLUE}Building Flutter Web (release mode)...${NC}"

# Choose renderer based on argument
RENDERER="html"  # Default to html for better compatibility
if [ "$1" == "canvaskit" ]; then
    RENDERER="canvaskit"
    echo -e "${YELLOW}Using CanvasKit renderer (better for desktop)${NC}"
else
    echo -e "${YELLOW}Using HTML renderer (better compatibility)${NC}"
fi

flutter build web --release --web-renderer $RENDERER

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ Build successful!${NC}"
    echo -e "${GREEN}   Output: build/web/${NC}"
else
    echo -e "\n${RED}❌ Build failed${NC}"
    exit 1
fi

# Analyze build size
echo -e "\n${BLUE}Build Size:${NC}"
du -sh build/web

# Optional: Deploy to Python backend
read -p $'\nDeploy to Python backend? (y/N): ' DEPLOY

if [ "$DEPLOY" == "y" ] || [ "$DEPLOY" == "Y" ]; then
    BACKEND_DIR="../app/static/flutter-web"

    echo -e "\n${BLUE}Deploying to Python backend...${NC}"

    # Create directory if it doesn't exist
    mkdir -p $BACKEND_DIR

    # Copy build files
    echo -e "${BLUE}Copying files to ${BACKEND_DIR}${NC}"
    cp -r build/web/* $BACKEND_DIR/

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Deployment successful!${NC}"
        echo -e "${GREEN}   Location: ${BACKEND_DIR}${NC}"
        echo -e "\n${YELLOW}Next steps:${NC}"
        echo -e "1. Ensure Python backend is configured (see app/serve_flutter.py)"
        echo -e "2. Start Python server: cd .. && uv run python3 app/main.py"
        echo -e "3. Access at: http://localhost:8081/flutter-web"
    else
        echo -e "${RED}❌ Deployment failed${NC}"
        exit 1
    fi
fi

# Summary
echo -e "\n${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║             Build Complete!            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Build output:${NC} build/web/"
echo -e "${GREEN}Renderer:${NC} $RENDERER"
echo ""
echo -e "${YELLOW}Development:${NC}"
echo -e "  flutter run -d chrome --web-port=4200"
echo ""
echo -e "${YELLOW}Testing:${NC}"
echo -e "  flutter test"
echo -e "  flutter test --coverage"
echo ""
echo -e "${YELLOW}Serve locally:${NC}"
echo -e "  cd build/web && python3 -m http.server 8080"
echo ""
