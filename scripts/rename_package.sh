#!/bin/bash

# Flutter Package Renaming Script
# This script automates the process of renaming package names across all platforms

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Current values (from template)
CURRENT_PACKAGE_NAME="product_inventory"
CURRENT_ANDROID_PACKAGE="com.example.product_inventory"
CURRENT_IOS_BUNDLE="com.example.newArch"

# Function to print colored messages
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect Flutter command (FVM or direct)
detect_flutter_command() {
    if [ -d ".fvm" ]; then
        print_info "FVM detected, using 'fvm flutter' commands"
        echo "fvm flutter"
    else
        print_info "No FVM detected, using 'flutter' commands"
        echo "flutter"
    fi
}

# Display usage
usage() {
    echo "Usage: $0 <app_display_name> <dart_package_name> <android_package_id> <ios_bundle_id>"
    echo ""
    echo "Example:"
    echo "  $0 \"My Awesome App\" \"my_awesome_app\" \"com.company.myawesomeapp\" \"com.company.myAwesomeApp\""
    echo ""
    echo "Arguments:"
    echo "  app_display_name    - The human-readable name of your app (e.g., 'My Awesome App')"
    echo "  dart_package_name   - The Dart package name, snake_case (e.g., 'my_awesome_app')"
    echo "  android_package_id  - Android package ID, reverse domain (e.g., 'com.company.myawesomeapp')"
    echo "  ios_bundle_id       - iOS bundle identifier, reverse domain (e.g., 'com.company.myAwesomeApp')"
    exit 1
}

# Validate inputs
if [ $# -ne 4 ]; then
    print_error "Error: Incorrect number of arguments"
    usage
fi

APP_DISPLAY_NAME="$1"
NEW_PACKAGE_NAME="$2"
NEW_ANDROID_PACKAGE="$3"
NEW_IOS_BUNDLE="$4"

# Validate package name format (lowercase with underscores)
if ! [[ "$NEW_PACKAGE_NAME" =~ ^[a-z][a-z0-9_]*$ ]]; then
    print_error "Invalid Dart package name. Must be lowercase with underscores only (e.g., 'my_app')"
    exit 1
fi

# Validate Android package format
if ! [[ "$NEW_ANDROID_PACKAGE" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    print_error "Invalid Android package ID. Must be reverse domain notation (e.g., 'com.company.app')"
    exit 1
fi

# Validate iOS bundle format
if ! [[ "$NEW_IOS_BUNDLE" =~ ^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)+$ ]]; then
    print_error "Invalid iOS bundle ID. Must be reverse domain notation (e.g., 'com.company.App')"
    exit 1
fi

# Summary
echo ""
print_info "═══════════════════════════════════════════════════════════"
print_info "Package Renaming Summary"
print_info "═══════════════════════════════════════════════════════════"
echo "App Display Name : $APP_DISPLAY_NAME"
echo "Dart Package     : $NEW_PACKAGE_NAME"
echo "Android Package  : $NEW_ANDROID_PACKAGE"
echo "iOS Bundle ID    : $NEW_IOS_BUNDLE"
print_info "═══════════════════════════════════════════════════════════"
echo ""

# Confirm with user
read -p "Proceed with renaming? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Aborted by user"
    exit 0
fi

print_info "Starting package rename process..."
echo ""

# ========================
# 1. Update pubspec.yaml
# ========================
print_info "[1/11] Updating pubspec.yaml..."
if [ -f "pubspec.yaml" ]; then
    sed -i.bak "s/^name: $CURRENT_PACKAGE_NAME$/name: $NEW_PACKAGE_NAME/" pubspec.yaml
    print_success "Updated pubspec.yaml"
else
    print_warning "pubspec.yaml not found"
fi

# ========================
# 2. Update Android files
# ========================
print_info "[2/11] Updating Android configuration..."

# Update build.gradle
if [ -f "android/app/build.gradle" ]; then
    sed -i.bak "s/namespace = \"$CURRENT_ANDROID_PACKAGE\"/namespace = \"$NEW_ANDROID_PACKAGE\"/" android/app/build.gradle
    sed -i.bak "s/applicationId = \"$CURRENT_ANDROID_PACKAGE\"/applicationId = \"$NEW_ANDROID_PACKAGE\"/" android/app/build.gradle
    print_success "Updated android/app/build.gradle"
fi

# Update AndroidManifest.xml
if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
    sed -i.bak "s/android:label=\"$CURRENT_PACKAGE_NAME\"/android:label=\"$APP_DISPLAY_NAME\"/" android/app/src/main/AndroidManifest.xml
    print_success "Updated AndroidManifest.xml"
fi

# Update MainActivity.kt and rename directory
ANDROID_OLD_DIR="android/app/src/main/kotlin/$(echo $CURRENT_ANDROID_PACKAGE | tr '.' '/')"
ANDROID_NEW_DIR="android/app/src/main/kotlin/$(echo $NEW_ANDROID_PACKAGE | tr '.' '/')"

if [ -f "$ANDROID_OLD_DIR/MainActivity.kt" ]; then
    # Update package declaration in MainActivity.kt
    sed -i.bak "s/package $CURRENT_ANDROID_PACKAGE/package $NEW_ANDROID_PACKAGE/" "$ANDROID_OLD_DIR/MainActivity.kt"

    # Create new directory structure
    mkdir -p "$ANDROID_NEW_DIR"

    # Move MainActivity.kt to new location
    mv "$ANDROID_OLD_DIR/MainActivity.kt" "$ANDROID_NEW_DIR/MainActivity.kt"

    # Remove old directory structure if empty
    rm -rf "android/app/src/main/kotlin/com/example/$CURRENT_PACKAGE_NAME" 2>/dev/null || true

    print_success "Updated and moved MainActivity.kt"
fi

# ========================
# 3. Update iOS files
# ========================
print_info "[3/11] Updating iOS configuration..."

# Update Info.plist
if [ -f "ios/Runner/Info.plist" ]; then
    sed -i.bak "s|<string>$CURRENT_PACKAGE_NAME</string>|<string>$NEW_PACKAGE_NAME</string>|" ios/Runner/Info.plist
    sed -i.bak "s|<string>New Arch</string>|<string>$APP_DISPLAY_NAME</string>|" ios/Runner/Info.plist
    print_success "Updated ios/Runner/Info.plist"
fi

# Update project.pbxproj
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    sed -i.bak "s/PRODUCT_BUNDLE_IDENTIFIER = $CURRENT_IOS_BUNDLE/PRODUCT_BUNDLE_IDENTIFIER = $NEW_IOS_BUNDLE/g" ios/Runner.xcodeproj/project.pbxproj
    print_success "Updated ios/Runner.xcodeproj/project.pbxproj"
fi

# ========================
# 4. Update macOS files
# ========================
print_info "[4/11] Updating macOS configuration..."

if [ -f "macos/Runner/Configs/AppInfo.xcconfig" ]; then
    sed -i.bak "s/PRODUCT_NAME = $CURRENT_PACKAGE_NAME/PRODUCT_NAME = $NEW_PACKAGE_NAME/" macos/Runner/Configs/AppInfo.xcconfig
    sed -i.bak "s/PRODUCT_BUNDLE_IDENTIFIER = $CURRENT_IOS_BUNDLE/PRODUCT_BUNDLE_IDENTIFIER = $NEW_IOS_BUNDLE/" macos/Runner/Configs/AppInfo.xcconfig
    sed -i.bak "s/Copyright © .* com.example./Copyright © $(date +%Y) ${NEW_IOS_BUNDLE%.*}./" macos/Runner/Configs/AppInfo.xcconfig
    print_success "Updated macos/Runner/Configs/AppInfo.xcconfig"
fi

if [ -f "macos/Runner.xcodeproj/project.pbxproj" ]; then
    sed -i.bak "s/PRODUCT_BUNDLE_IDENTIFIER = $CURRENT_IOS_BUNDLE/PRODUCT_BUNDLE_IDENTIFIER = $NEW_IOS_BUNDLE/g" macos/Runner.xcodeproj/project.pbxproj
    print_success "Updated macos/Runner.xcodeproj/project.pbxproj"
fi

# ========================
# 5. Update Linux files
# ========================
print_info "[5/11] Updating Linux configuration..."

if [ -f "linux/CMakeLists.txt" ]; then
    sed -i.bak "s/set(BINARY_NAME \"$CURRENT_PACKAGE_NAME\")/set(BINARY_NAME \"$NEW_PACKAGE_NAME\")/" linux/CMakeLists.txt
    sed -i.bak "s/set(APPLICATION_ID \"$CURRENT_ANDROID_PACKAGE\")/set(APPLICATION_ID \"$NEW_ANDROID_PACKAGE\")/" linux/CMakeLists.txt
    print_success "Updated linux/CMakeLists.txt"
fi

if [ -f "linux/runner/my_application.cc" ]; then
    sed -i.bak "s/application_id = \"$CURRENT_ANDROID_PACKAGE\"/application_id = \"$NEW_ANDROID_PACKAGE\"/" linux/runner/my_application.cc
    print_success "Updated linux/runner/my_application.cc"
fi

# ========================
# 6. Update Windows files
# ========================
print_info "[6/11] Updating Windows configuration..."

if [ -f "windows/CMakeLists.txt" ]; then
    sed -i.bak "s/project($CURRENT_PACKAGE_NAME LANGUAGES CXX)/project($NEW_PACKAGE_NAME LANGUAGES CXX)/" windows/CMakeLists.txt
    sed -i.bak "s/set(BINARY_NAME \"$CURRENT_PACKAGE_NAME\")/set(BINARY_NAME \"$NEW_PACKAGE_NAME\")/" windows/CMakeLists.txt
    print_success "Updated windows/CMakeLists.txt"
fi

if [ -f "windows/runner/Runner.rc" ]; then
    sed -i.bak "s/VALUE \"FileDescription\", \"$CURRENT_PACKAGE_NAME\"/VALUE \"FileDescription\", \"$APP_DISPLAY_NAME\"/" windows/runner/Runner.rc
    sed -i.bak "s/VALUE \"ProductName\", \"$CURRENT_PACKAGE_NAME\"/VALUE \"ProductName\", \"$APP_DISPLAY_NAME\"/" windows/runner/Runner.rc
    print_success "Updated windows/runner/Runner.rc"
fi

# ========================
# 7. Update Web files
# ========================
print_info "[7/11] Updating Web configuration..."

if [ -f "web/manifest.json" ]; then
    sed -i.bak "s/\"name\": \"$CURRENT_PACKAGE_NAME\"/\"name\": \"$APP_DISPLAY_NAME\"/" web/manifest.json
    sed -i.bak "s/\"short_name\": \"$CURRENT_PACKAGE_NAME\"/\"short_name\": \"$NEW_PACKAGE_NAME\"/" web/manifest.json
    print_success "Updated web/manifest.json"
fi

if [ -f "web/index.html" ]; then
    sed -i.bak "s/<meta name=\"apple-mobile-web-app-title\" content=\"$CURRENT_PACKAGE_NAME\">/<meta name=\"apple-mobile-web-app-title\" content=\"$APP_DISPLAY_NAME\">/" web/index.html
    sed -i.bak "s/<title>$CURRENT_PACKAGE_NAME<\/title>/<title>$APP_DISPLAY_NAME<\/title>/" web/index.html
    print_success "Updated web/index.html"
fi

# ========================
# 8. Update all Dart import statements
# ========================
print_info "[8/11] Updating Dart import statements..."

# Find all .dart files and update imports
find lib -name "*.dart" -type f -exec sed -i.bak "s/package:$CURRENT_PACKAGE_NAME\//package:$NEW_PACKAGE_NAME\//g" {} \;
find test -name "*.dart" -type f -exec sed -i.bak "s/package:$CURRENT_PACKAGE_NAME\//package:$NEW_PACKAGE_NAME\//g" {} \; 2>/dev/null || true

print_success "Updated all Dart import statements"

# ========================
# 9. Clean up backup files
# ========================
print_info "[9/11] Cleaning up backup files..."
find . -name "*.bak" -type f -delete
print_success "Removed all backup files"

# ========================
# 10. Detect Flutter command and clean
# ========================
print_info "[10/11] Running Flutter clean..."
FLUTTER_CMD=$(detect_flutter_command)
$FLUTTER_CMD clean
print_success "Flutter clean completed"

# ========================
# 11. Get dependencies
# ========================
print_info "[11/11] Getting Flutter dependencies..."
$FLUTTER_CMD pub get
print_success "Flutter pub get completed"

# ========================
# Final Summary
# ========================
echo ""
print_success "═══════════════════════════════════════════════════════════"
print_success "Package Renaming Completed Successfully!"
print_success "═══════════════════════════════════════════════════════════"
echo ""
echo "Summary of changes:"
echo "  ✓ Package name changed to: $NEW_PACKAGE_NAME"
echo "  ✓ Android package changed to: $NEW_ANDROID_PACKAGE"
echo "  ✓ iOS bundle changed to: $NEW_IOS_BUNDLE"
echo "  ✓ App display name changed to: $APP_DISPLAY_NAME"
echo "  ✓ All import statements updated"
echo "  ✓ Flutter dependencies refreshed"
echo ""
print_info "Next steps:"
echo "  1. Review the changes"
echo "  2. Test the app on all target platforms"
echo "  3. Update Firebase configuration if applicable"
echo "  4. Update any CI/CD configurations"
echo ""
print_success "Done!"
