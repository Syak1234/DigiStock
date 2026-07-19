#!/bin/bash

#===============================================================================
# Disable FlutterFire Crashlytics Symbol Upload for Simulator Builds
#===============================================================================
# This script modifies the FlutterFire upload-crashlytics-symbols build phase
# in an iOS Xcode project to skip execution when building for iPhone Simulator.
#
# Usage:
#   ./disable_crashlytics_simulator.sh [project_path]
#
# Arguments:
#   project_path: Optional path to Flutter project root (defaults to current dir)
#
# Features:
#   - Reusable across multiple Flutter projects
#   - Idempotent (safe to run multiple times)
#   - Creates timestamped backups before modification
#   - Validates environment and file structure
#   - Minimal dependencies (requires Python 3)
#===============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

#===============================================================================
# Helper Functions
#===============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ${NC}  $1"
}

#===============================================================================
# Validation Functions
#===============================================================================

validate_environment() {
    print_header "Step 1: Validating Environment"

    # Check if pubspec.yaml exists
    if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
        print_error "pubspec.yaml not found. Not a Flutter project?"
        print_info "Current directory: $PROJECT_ROOT"
        exit 1
    fi
    print_step "Flutter project detected"

    # Check if iOS directory exists
    if [ ! -d "$PROJECT_ROOT/ios" ]; then
        print_error "ios directory not found"
        exit 1
    fi
    print_step "iOS directory found"

    # Check if project.pbxproj exists
    PBXPROJ_PATH="$PROJECT_ROOT/ios/Runner.xcodeproj/project.pbxproj"
    if [ ! -f "$PBXPROJ_PATH" ]; then
        print_error "project.pbxproj not found at: $PBXPROJ_PATH"
        exit 1
    fi
    print_step "Xcode project file found"

    # Check if file is writable
    if [ ! -w "$PBXPROJ_PATH" ]; then
        print_error "project.pbxproj is not writable"
        print_info "Try: chmod u+w $PBXPROJ_PATH"
        exit 1
    fi
    print_step "File is writable"
}

#===============================================================================
# Check if Already Modified
#===============================================================================

check_if_already_modified() {
    print_header "Step 2: Checking Current State"

    # Check if the FlutterFire build phase exists
    if ! grep -q 'FlutterFire: "flutterfire upload-crashlytics-symbols"' "$PBXPROJ_PATH"; then
        print_warning "FlutterFire Crashlytics build phase not found in project"
        print_info "This script is only needed if you're using FlutterFire Crashlytics"
        exit 0
    fi
    print_step "FlutterFire Crashlytics build phase found"

    # Check if already modified
    if grep -q "Skip Crashlytics symbol upload for simulator" "$PBXPROJ_PATH"; then
        print_warning "Simulator skip already configured!"
        print_info "The project has already been modified. No changes needed."
        exit 0
    fi
    print_step "Modification not yet applied"
}

#===============================================================================
# Create Backup
#===============================================================================

create_backup() {
    print_header "Step 3: Creating Backup"

    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    BACKUP_PATH="${PBXPROJ_PATH}.backup-${TIMESTAMP}"

    cp "$PBXPROJ_PATH" "$BACKUP_PATH"

    if [ -f "$BACKUP_PATH" ]; then
        print_step "Backup created: $BACKUP_PATH"
        print_info "To restore: cp \"$BACKUP_PATH\" \"$PBXPROJ_PATH\""
    else
        print_error "Failed to create backup"
        exit 1
    fi
}

#===============================================================================
# Modify Crashlytics Build Phase
#===============================================================================

modify_crashlytics_build_phase() {
    print_header "Step 4: Modifying Build Phase"

    # Create a temporary file for the modification
    TEMP_FILE="${PBXPROJ_PATH}.tmp"

    # Use Python for more reliable text replacement
    # Python handles the escaping better than shell/perl
    python3 - "$PBXPROJ_PATH" "$TEMP_FILE" << 'PYTHON_SCRIPT'
import sys
import re

pbxproj_path = sys.argv[1]
temp_file = sys.argv[2]

# Read the file
with open(pbxproj_path, 'r') as f:
    content = f.read()

# The simulator check to insert (with proper escaping for the pbxproj format)
# Note: The file uses literal \n (backslash-n) not actual newlines
simulator_check = r'\\n\\n# Skip Crashlytics symbol upload for simulator builds\\nif [ \\"$PLATFORM_NAME\\" = \\"iphonesimulator\\" ]; then\\n  echo \\"Skipping Crashlytics symbol upload for simulator build\\"\\n  exit 0\\nfi\\n'

# Pattern: Find PATH="..." followed by \\n\\nif (literal backslash-n)
# Replace with PATH="..." + simulator_check + \\n\\nif
pattern = r'(PATH=\\"[^"]+\\")(\\n\\nif \[ -z)'
replacement = r'\1' + simulator_check + r'\2'

# Perform the substitution
modified_content = re.sub(pattern, replacement, content)

# Write to temp file
with open(temp_file, 'w') as f:
    f.write(modified_content)
PYTHON_SCRIPT

    # Check if modification was successful
    if [ ! -f "$TEMP_FILE" ]; then
        print_error "Failed to create temporary file"
        exit 1
    fi

    # Verify the modification was applied
    if ! grep -q "Skip Crashlytics symbol upload for simulator" "$TEMP_FILE"; then
        print_error "Modification was not applied correctly"
        print_info "The FlutterFire script structure may have changed"
        print_info "Please check the script manually or contact support"
        rm -f "$TEMP_FILE"
        exit 1
    fi

    # Replace original file with modified version
    mv "$TEMP_FILE" "$PBXPROJ_PATH"

    print_step "Build phase script modified successfully"
}

#===============================================================================
# Verify Modification
#===============================================================================

verify_modification() {
    print_header "Step 5: Verifying Changes"

    # Check that the modification is present
    if grep -q "Skip Crashlytics symbol upload for simulator" "$PBXPROJ_PATH"; then
        print_step "Simulator check successfully added to build phase"
    else
        print_error "Verification failed - modification not found"
        exit 1
    fi

    # Check that the file structure is still valid
    if grep -q 'shellScript = "' "$PBXPROJ_PATH"; then
        print_step "Xcode project file structure is valid"
    else
        print_error "Project file may be corrupted"
        print_info "Restore from backup: cp \"$BACKUP_PATH\" \"$PBXPROJ_PATH\""
        exit 1
    fi

    # Show the relevant section
    print_info "Modified section preview:"
    echo ""
    grep -A 2 "Skip Crashlytics symbol upload for simulator" "$PBXPROJ_PATH" | sed 's/\\n/\n/g' | head -6
    echo ""
}

#===============================================================================
# Print Summary
#===============================================================================

print_summary() {
    print_header "✓ Modification Complete!"

    echo -e "${GREEN}Successfully configured FlutterFire Crashlytics to skip simulator builds${NC}"
    echo ""
    echo "What was changed:"
    echo "  • Added simulator detection check to the upload-crashlytics-symbols build phase"
    echo "  • Simulator builds will now skip Crashlytics symbol upload"
    echo "  • Device builds will continue to upload symbols normally"
    echo ""
    echo "Expected behavior:"
    echo "  ${CYAN}Simulator builds:${NC} Will print \"Skipping Crashlytics symbol upload for simulator build\""
    echo "  ${CYAN}Device builds:${NC} Will upload symbols normally"
    echo ""
    echo "Testing:"
    echo "  1. Run simulator build: ${YELLOW}fvm flutter run${NC}"
    echo "     - Check build logs for skip message"
    echo ""
    echo "  2. Build for device: ${YELLOW}fvm flutter build ipa${NC}"
    echo "     - Verify symbols upload normally"
    echo ""
    echo "Backup location:"
    echo "  ${BACKUP_PATH}"
    echo ""
    echo "To restore original (if needed):"
    echo "  ${YELLOW}cp \"$BACKUP_PATH\" \"$PBXPROJ_PATH\"${NC}"
    echo ""
}

#===============================================================================
# Main Function
#===============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  FlutterFire Crashlytics - Disable Simulator Upload Script    ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"

    # Determine project root
    if [ -n "$1" ]; then
        PROJECT_ROOT="$1"
    else
        PROJECT_ROOT="$(pwd)"
    fi

    # Convert to absolute path
    PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
    print_info "Project root: $PROJECT_ROOT"

    # Execute steps
    validate_environment
    check_if_already_modified
    create_backup
    modify_crashlytics_build_phase
    verify_modification
    print_summary
}

#===============================================================================
# Script Entry Point
#===============================================================================

# Run main function with all arguments
main "$@"
