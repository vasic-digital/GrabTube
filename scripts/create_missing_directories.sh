#!/bin/bash

# GrabTube - Create Missing Directories Script
# This script creates all missing directory structures for Phase 1+ implementation

set -e

echo "🚀 GrabTube - Creating Missing Directory Structure"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo -e "${BLUE}📁 Creating Flutter-Client directories...${NC}"

# Domain layer - Use Cases
mkdir -p Flutter-Client/lib/domain/usecases/download
mkdir -p Flutter-Client/lib/domain/usecases/qr_scanner
mkdir -p Flutter-Client/lib/domain/usecases/search
mkdir -p Flutter-Client/lib/domain/usecases/favorites
mkdir -p Flutter-Client/lib/domain/usecases/schedule
mkdir -p Flutter-Client/lib/domain/usecases/jdownloader

# Domain layer - Additional Repositories
mkdir -p Flutter-Client/lib/data/repositories

# Presentation layer - BLoCs
mkdir -p Flutter-Client/lib/presentation/blocs/qr_scanner
mkdir -p Flutter-Client/lib/presentation/blocs/search
mkdir -p Flutter-Client/lib/presentation/blocs/favorites
mkdir -p Flutter-Client/lib/presentation/blocs/schedule
mkdir -p Flutter-Client/lib/presentation/blocs/jdownloader

# Presentation layer - Pages (if not exists)
mkdir -p Flutter-Client/lib/presentation/pages

# Test directories
mkdir -p Flutter-Client/test/unit/core/network
mkdir -p Flutter-Client/test/unit/core/utils
mkdir -p Flutter-Client/test/unit/data/models
mkdir -p Flutter-Client/test/unit/data/repositories
mkdir -p Flutter-Client/test/unit/domain/entities
mkdir -p Flutter-Client/test/unit/domain/usecases/download
mkdir -p Flutter-Client/test/unit/domain/usecases/qr_scanner
mkdir -p Flutter-Client/test/unit/domain/usecases/search
mkdir -p Flutter-Client/test/unit/domain/usecases/favorites
mkdir -p Flutter-Client/test/unit/domain/usecases/schedule
mkdir -p Flutter-Client/test/unit/domain/usecases/jdownloader
mkdir -p Flutter-Client/test/unit/presentation/blocs/qr_scanner
mkdir -p Flutter-Client/test/unit/presentation/blocs/search
mkdir -p Flutter-Client/test/unit/presentation/blocs/favorites
mkdir -p Flutter-Client/test/unit/presentation/blocs/schedule
mkdir -p Flutter-Client/test/unit/presentation/blocs/jdownloader
mkdir -p Flutter-Client/test/widget
mkdir -p Flutter-Client/test/integration
mkdir -p Flutter-Client/test/performance
mkdir -p Flutter-Client/test/golden

echo -e "${GREEN}✅ Flutter-Client directories created${NC}"
echo ""

echo -e "${BLUE}📁 Creating Android-Client documentation directories...${NC}"

mkdir -p Android-Client/docs

echo -e "${GREEN}✅ Android-Client directories created${NC}"
echo ""

echo -e "${BLUE}📁 Creating Website directory structure...${NC}"

mkdir -p Website/public/css
mkdir -p Website/public/js
mkdir -p Website/public/assets/images
mkdir -p Website/public/assets/videos
mkdir -p Website/public/assets/downloads
mkdir -p Website/src
mkdir -p Website/content/docs/getting-started
mkdir -p Website/content/docs/user-guide
mkdir -p Website/content/docs/developer
mkdir -p Website/components/ui
mkdir -p Website/components/marketing
mkdir -p Website/components/docs

echo -e "${GREEN}✅ Website directories created${NC}"
echo ""

echo -e "${BLUE}📁 Creating video course directories...${NC}"

mkdir -p videos/user_tutorials
mkdir -p videos/developer_courses
mkdir -p videos/advanced_topics
mkdir -p videos/scripts
mkdir -p videos/raw_footage
mkdir -p videos/edited
mkdir -p videos/thumbnails

echo -e "${GREEN}✅ Video course directories created${NC}"
echo ""

echo -e "${BLUE}📝 Creating .gitkeep files to preserve empty directories...${NC}"

# Find empty directories and add .gitkeep
find . -type d -empty -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/build/*" -exec touch {}/.gitkeep \;

echo -e "${GREEN}✅ .gitkeep files created${NC}"
echo ""

echo -e "${BLUE}📊 Directory Structure Summary:${NC}"
echo ""
echo "Flutter-Client:"
echo "  - lib/domain/usecases/         (6 feature directories)"
echo "  - lib/presentation/blocs/      (5 feature directories)"
echo "  - test/                        (comprehensive test structure)"
echo ""
echo "Android-Client:"
echo "  - docs/                        (documentation directory)"
echo ""
echo "Website:"
echo "  - public/                      (static assets)"
echo "  - src/                         (source code)"
echo "  - content/docs/                (MDX documentation)"
echo "  - components/                  (React components)"
echo ""
echo "videos:"
echo "  - user_tutorials/              (end-user videos)"
echo "  - developer_courses/           (developer videos)"
echo "  - advanced_topics/             (advanced videos)"
echo "  - scripts/                     (video scripts)"
echo "  - raw_footage/                 (unedited recordings)"
echo "  - edited/                      (final videos)"
echo "  - thumbnails/                  (video thumbnails)"
echo ""

echo -e "${GREEN}=================================================="
echo "✅ All directories created successfully!"
echo "==================================================${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Review the directory structure"
echo "2. Commit the changes: git add . && git commit -m 'chore: create directory structure'"
echo "3. Start implementing Phase 1 according to DETAILED_IMPLEMENTATION_PLAN.md"
echo ""
