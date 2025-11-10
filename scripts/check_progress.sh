#!/bin/bash

# GrabTube - Progress Checker Script
# Analyzes the codebase and shows completion status

set -e

echo "📊 GrabTube Implementation Progress Report"
echo "==========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
total_items=0
completed_items=0

# Get project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

echo -e "${BLUE}Phase 1: Core Feature Implementation${NC}"
echo "======================================"
echo ""

# Check entities
echo "📦 Domain Entities:"
entities=(
  "Flutter-Client/lib/domain/entities/qr_scan_result.dart"
  "Flutter-Client/lib/domain/entities/search_result.dart"
  "Flutter-Client/lib/domain/entities/search_parameters.dart"
  "Flutter-Client/lib/domain/entities/schedule.dart"
  "Flutter-Client/lib/domain/entities/scheduled_download.dart"
  "Flutter-Client/lib/domain/entities/jdownloader_instance.dart"
  "Flutter-Client/lib/domain/entities/speed_data_point.dart"
)

entity_count=0
for entity in "${entities[@]}"; do
  total_items=$((total_items + 1))
  if [ -f "$entity" ] && [ -s "$entity" ]; then
    echo -e "  ${GREEN}✅${NC} $(basename "$entity")"
    entity_count=$((entity_count + 1))
    completed_items=$((completed_items + 1))
  else
    echo -e "  ${RED}❌${NC} $(basename "$entity")"
  fi
done
echo -e "  Status: ${entity_count}/7 completed\n"

# Check repository interfaces
echo "🔌 Repository Interfaces:"
repos=(
  "Flutter-Client/lib/domain/repositories/qr_scanner_repository.dart"
  "Flutter-Client/lib/domain/repositories/search_repository.dart"
  "Flutter-Client/lib/domain/repositories/favorites_repository.dart"
  "Flutter-Client/lib/domain/repositories/schedule_repository.dart"
  "Flutter-Client/lib/domain/repositories/jdownloader_repository.dart"
)

repo_count=0
for repo in "${repos[@]}"; do
  total_items=$((total_items + 1))
  if [ -f "$repo" ] && [ -s "$repo" ]; then
    echo -e "  ${GREEN}✅${NC} $(basename "$repo")"
    repo_count=$((repo_count + 1))
    completed_items=$((completed_items + 1))
  else
    echo -e "  ${RED}❌${NC} $(basename "$repo")"
  fi
done
echo -e "  Status: ${repo_count}/5 completed\n"

# Check use cases
echo "⚙️  Use Cases:"
if [ -d "Flutter-Client/lib/domain/usecases" ]; then
  usecase_count=$(find Flutter-Client/lib/domain/usecases -name "*_usecase.dart" -type f 2>/dev/null | wc -l | tr -d ' ')
  total_items=$((total_items + 25))
  completed_items=$((completed_items + usecase_count))
  echo -e "  ${YELLOW}📝${NC} Found: ${usecase_count}/25 use cases"

  if [ "$usecase_count" -eq 0 ]; then
    echo -e "  ${RED}❌${NC} No use cases implemented yet"
  elif [ "$usecase_count" -lt 25 ]; then
    echo -e "  ${YELLOW}⚠️${NC}  Partially implemented"
  else
    echo -e "  ${GREEN}✅${NC} All use cases implemented"
  fi
else
  total_items=$((total_items + 25))
  echo -e "  ${RED}❌${NC} Use cases directory doesn't exist"
fi
echo ""

# Check BLoCs
echo "🎯 BLoC State Management:"
blocs=(
  "Flutter-Client/lib/presentation/blocs/qr_scanner"
  "Flutter-Client/lib/presentation/blocs/search"
  "Flutter-Client/lib/presentation/blocs/favorites"
  "Flutter-Client/lib/presentation/blocs/schedule"
  "Flutter-Client/lib/presentation/blocs/jdownloader"
)

bloc_count=0
for bloc_dir in "${blocs[@]}"; do
  total_items=$((total_items + 1))
  if [ -d "$bloc_dir" ] && [ -f "$bloc_dir/$(basename "$bloc_dir")_bloc.dart" ]; then
    echo -e "  ${GREEN}✅${NC} $(basename "$bloc_dir")"
    bloc_count=$((bloc_count + 1))
    completed_items=$((completed_items + 1))
  else
    echo -e "  ${RED}❌${NC} $(basename "$bloc_dir")"
  fi
done
echo -e "  Status: ${bloc_count}/5 completed\n"

# Check pages
echo "📱 Presentation Pages:"
pages=(
  "Flutter-Client/lib/presentation/pages/qr_scanner_page.dart"
  "Flutter-Client/lib/presentation/pages/search_page.dart"
  "Flutter-Client/lib/presentation/pages/favorites_page.dart"
  "Flutter-Client/lib/presentation/pages/schedule_page.dart"
  "Flutter-Client/lib/presentation/pages/jdownloader_page.dart"
  "Flutter-Client/lib/presentation/pages/settings_page.dart"
)

page_count=0
for page in "${pages[@]}"; do
  total_items=$((total_items + 1))
  if [ -f "$page" ] && [ -s "$page" ]; then
    echo -e "  ${GREEN}✅${NC} $(basename "$page")"
    page_count=$((page_count + 1))
    completed_items=$((completed_items + 1))
  else
    echo -e "  ${RED}❌${NC} $(basename "$page")"
  fi
done
echo -e "  Status: ${page_count}/6 completed\n"

echo ""
echo -e "${BLUE}Phase 2: Testing & Quality Assurance${NC}"
echo "====================================="
echo ""

# Check test coverage
if [ -f "Flutter-Client/coverage/lcov.info" ]; then
  echo -e "  ${GREEN}✅${NC} Coverage report exists"
  echo -e "  ${YELLOW}📝${NC} Run: genhtml Flutter-Client/coverage/lcov.info -o Flutter-Client/coverage/html"
else
  echo -e "  ${RED}❌${NC} No coverage report found"
  echo -e "  ${YELLOW}📝${NC} Run: cd Flutter-Client && flutter test --coverage"
fi
echo ""

echo ""
echo -e "${BLUE}Phase 3: Documentation${NC}"
echo "======================"
echo ""

# Check Android documentation
echo "📚 Android-Client Documentation:"
android_docs=(
  "Android-Client/README.md"
  "Android-Client/docs/ARCHITECTURE.md"
  "Android-Client/docs/API.md"
  "Android-Client/docs/USER_GUIDE.md"
  "Android-Client/docs/DEVELOPMENT.md"
)

android_doc_count=0
for doc in "${android_docs[@]}"; do
  total_items=$((total_items + 1))
  if [ -f "$doc" ] && [ -s "$doc" ]; then
    echo -e "  ${GREEN}✅${NC} $(basename "$doc")"
    android_doc_count=$((android_doc_count + 1))
    completed_items=$((completed_items + 1))
  else
    echo -e "  ${RED}❌${NC} $(basename "$doc")"
  fi
done
echo -e "  Status: ${android_doc_count}/5 completed\n"

echo ""
echo -e "${BLUE}Phase 4: Website Development${NC}"
echo "============================"
echo ""

# Check website
if [ -f "Website/package.json" ]; then
  echo -e "  ${GREEN}✅${NC} Website initialized"
  total_items=$((total_items + 1))
  completed_items=$((completed_items + 1))

  if [ -d "Website/app" ] || [ -d "Website/pages" ]; then
    echo -e "  ${GREEN}✅${NC} Website pages exist"
  else
    echo -e "  ${YELLOW}⚠️${NC}  Website pages not yet created"
  fi
else
  echo -e "  ${RED}❌${NC} Website not initialized"
  total_items=$((total_items + 1))
fi
echo ""

echo ""
echo -e "${BLUE}Phase 5: Video Course Production${NC}"
echo "================================="
echo ""

# Check video directories
if [ -d "videos" ]; then
  user_videos=$(find videos/user_tutorials -name "*.mp4" -type f 2>/dev/null | wc -l | tr -d ' ')
  dev_videos=$(find videos/developer_courses -name "*.mp4" -type f 2>/dev/null | wc -l | tr -d ' ')
  adv_videos=$(find videos/advanced_topics -name "*.mp4" -type f 2>/dev/null | wc -l | tr -d ' ')
  total_videos=$((user_videos + dev_videos + adv_videos))

  total_items=$((total_items + 25))
  completed_items=$((completed_items + total_videos))

  echo "🎥 Video Tutorials:"
  echo -e "  ${YELLOW}📝${NC} User Tutorials: ${user_videos}/10"
  echo -e "  ${YELLOW}📝${NC} Developer Courses: ${dev_videos}/10"
  echo -e "  ${YELLOW}📝${NC} Advanced Topics: ${adv_videos}/5"
  echo -e "  Status: ${total_videos}/25 videos completed"
else
  total_items=$((total_items + 25))
  echo -e "  ${RED}❌${NC} Video directories not created"
fi
echo ""

echo ""
echo -e "${GREEN}==========================================="
echo "📊 Overall Progress Summary"
echo "===========================================${NC}"
echo ""

# Calculate percentage
if [ $total_items -gt 0 ]; then
  percentage=$((completed_items * 100 / total_items))
else
  percentage=0
fi

echo -e "Total Items: ${BLUE}${total_items}${NC}"
echo -e "Completed:   ${GREEN}${completed_items}${NC}"
echo -e "Remaining:   ${RED}$((total_items - completed_items))${NC}"
echo ""

# Progress bar
bar_length=50
filled=$((percentage * bar_length / 100))
empty=$((bar_length - filled))

printf "Progress: ["
for ((i=0; i<filled; i++)); do printf "${GREEN}█${NC}"; done
for ((i=0; i<empty; i++)); do printf "░"; done
printf "] ${percentage}%%\n"

echo ""

if [ $percentage -lt 25 ]; then
  echo -e "${RED}Status: Just getting started! 🚀${NC}"
elif [ $percentage -lt 50 ]; then
  echo -e "${YELLOW}Status: Good progress! Keep going! 💪${NC}"
elif [ $percentage -lt 75 ]; then
  echo -e "${YELLOW}Status: Halfway there! 🎯${NC}"
elif [ $percentage -lt 100 ]; then
  echo -e "${GREEN}Status: Almost complete! 🏁${NC}"
else
  echo -e "${GREEN}Status: 100% COMPLETE! 🎉🎊${NC}"
fi

echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Review DETAILED_IMPLEMENTATION_PLAN.md for specific tasks"
echo "2. Choose your focus area (implementation, docs, website, or videos)"
echo "3. Follow the phase-by-phase plan"
echo "4. Run this script regularly to track progress"
echo ""
