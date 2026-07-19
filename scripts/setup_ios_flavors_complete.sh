#!/bin/bash

#===============================================================================
# iOS Flavor Configuration Complete Setup Script
#===============================================================================
# This script combines all iOS flavor setup functionality into a single file.
# It creates flavor configurations for development, staging, and production.
#
# Usage: ./scripts/setup_ios_flavors_complete.sh [--reset]
#   --reset: Clean up existing flavor configurations before adding new ones
#
# Prerequisites:
#   - Ruby installed
#   - xcodeproj gem (will be installed if missing)
#===============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FLAVORS=("development" "staging" "production")
BASE_CONFIGS=("Debug" "Release" "Profile")
BUNDLE_ID_BASE="com.example.productInventory"

# Parse arguments
RESET_MODE=false
for arg in "$@"; do
    case $arg in
        --reset)
            RESET_MODE=true
            shift
            ;;
    esac
done

#===============================================================================
# Helper Functions
#===============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
}

print_step() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

#===============================================================================
# Step 1: Prerequisites Check
#===============================================================================

check_prerequisites() {
    print_header "Step 1: Checking Prerequisites"

    # Set encoding
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    # Check Ruby
    if ! command -v ruby &> /dev/null; then
        print_error "Ruby is not installed. Please install Ruby first."
        exit 1
    fi
    print_step "Ruby found: $(ruby --version)"

    # Check/install xcodeproj gem
    if ! gem list xcodeproj -i > /dev/null 2>&1; then
        print_warning "xcodeproj gem not found. Installing..."
        sudo gem install xcodeproj
        print_step "xcodeproj gem installed"
    else
        print_step "xcodeproj gem found"
    fi

    # Navigate to iOS directory
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
    IOS_DIR="$PROJECT_ROOT/ios"

    if [ ! -d "$IOS_DIR" ]; then
        print_error "iOS directory not found at $IOS_DIR"
        exit 1
    fi

    cd "$IOS_DIR"
    print_step "Working directory: $IOS_DIR"

    # Check Xcode project exists
    if [ ! -d "Runner.xcodeproj" ]; then
        print_error "Runner.xcodeproj not found in ios directory"
        exit 1
    fi
    print_step "Xcode project found"
}

#===============================================================================
# Step 2: Create Flavor xcconfig Files
#===============================================================================

create_xcconfig_files() {
    print_header "Step 2: Creating Flavor xcconfig Files"

    FLUTTER_DIR="$IOS_DIR/Flutter"

    # Development.xcconfig
    cat > "$FLUTTER_DIR/Development.xcconfig" << 'EOF'
#include "Debug.xcconfig"

PRODUCT_BUNDLE_IDENTIFIER=$(BUNDLE_ID_BASE).dev
DISPLAY_NAME=Product Inventory Dev
FLUTTER_TARGET=lib/main_development.dart
EOF
    print_step "Created Development.xcconfig"

    # Staging.xcconfig
    cat > "$FLUTTER_DIR/Staging.xcconfig" << 'EOF'
#include "Release.xcconfig"

PRODUCT_BUNDLE_IDENTIFIER=$(BUNDLE_ID_BASE).stg
DISPLAY_NAME=Product Inventory Stg
FLUTTER_TARGET=lib/main_staging.dart
EOF
    print_step "Created Staging.xcconfig"

    # Production.xcconfig
    cat > "$FLUTTER_DIR/Production.xcconfig" << 'EOF'
#include "Release.xcconfig"

PRODUCT_BUNDLE_IDENTIFIER=$(BUNDLE_ID_BASE)
DISPLAY_NAME=Product Inventory
FLUTTER_TARGET=lib/main_production.dart
EOF
    print_step "Created Production.xcconfig"
}

#===============================================================================
# Step 3 & 4: Add Build Configurations to Xcode Project
#===============================================================================

add_build_configurations() {
    print_header "Step 3: Adding Build Configurations to Xcode Project"

    local reset_flag="$1"

    ruby << RUBY_SCRIPT
require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

flavors = ['development', 'staging', 'production']
base_configs = ['Debug', 'Release', 'Profile']
reset_mode = $reset_flag

puts "Loading Xcode project..."

# Get project configuration list
project_config_list = project.root_object.build_configuration_list

if reset_mode
  puts "Reset mode: Removing existing flavor configurations..."

  # Remove flavor configurations from project level
  configs_to_keep = project_config_list.build_configurations.select { |c| base_configs.include?(c.name) }
  project_config_list.build_configurations.clear
  configs_to_keep.each { |c| project_config_list.build_configurations << c }
  puts "  Kept base configurations: #{configs_to_keep.map(&:name).join(', ')}"

  # Remove flavor configurations from all targets
  project.targets.each do |target|
    target_configs_to_keep = target.build_configuration_list.build_configurations.select { |c| base_configs.include?(c.name) }
    target.build_configuration_list.build_configurations.clear
    target_configs_to_keep.each { |c| target.build_configuration_list.build_configurations << c }
    puts "  Reset target '#{target.name}': kept #{target_configs_to_keep.map(&:name).join(', ')}"
  end
end

puts ""
puts "Adding project-level configurations..."

# Add project-level configurations
flavors.each do |flavor_name|
  xcconfig_path = "Flutter/#{flavor_name.capitalize}.xcconfig"
  xcconfig_ref = project.files.find { |f| f.path == xcconfig_path }

  # Create xcconfig reference if it doesn't exist
  unless xcconfig_ref
    flutter_group = project.main_group.find_subpath('Flutter', true)
    xcconfig_ref = flutter_group.new_reference(xcconfig_path)
    puts "  Created reference for #{xcconfig_path}"
  end

  base_configs.each do |base_name|
    config_name = "#{base_name}-#{flavor_name}"

    # Skip if exists
    if project_config_list.build_configurations.any? { |c| c.name == config_name }
      puts "  #{config_name} already exists, skipping"
      next
    end

    # Find base configuration
    base_config = project_config_list.build_configurations.find { |c| c.name == base_name }

    if base_config
      new_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
      new_config.name = config_name
      new_config.build_settings = base_config.build_settings.dup
      new_config.build_settings['BUNDLE_ID_BASE'] = 'com.example.productInventory'
      new_config.base_configuration_reference = xcconfig_ref

      project_config_list.build_configurations << new_config
      puts "  Created #{config_name}"
    else
      puts "  WARNING: Base config #{base_name} not found!"
    end
  end
end

puts ""
puts "Adding target-level configurations..."

# Add target-level configurations
project.targets.each do |target|
  puts "  Target: #{target.name}"
  target_config_list = target.build_configuration_list

  flavors.each do |flavor_name|
    # Only Runner target should use the xcconfig file
    xcconfig_ref = nil
    if target.name == 'Runner'
      xcconfig_path = "Flutter/#{flavor_name.capitalize}.xcconfig"
      xcconfig_ref = project.files.find { |f| f.path == xcconfig_path }
    end

    base_configs.each do |base_name|
      config_name = "#{base_name}-#{flavor_name}"

      # Skip if exists
      if target_config_list.build_configurations.any? { |c| c.name == config_name }
        puts "    #{config_name} already exists, skipping"
        next
      end

      # Find base configuration
      base_config = target_config_list.build_configurations.find { |c| c.name == base_name }

      if base_config
        new_config = project.new(Xcodeproj::Project::Object::XCBuildConfiguration)
        new_config.name = config_name
        new_config.build_settings = base_config.build_settings.dup
        new_config.build_settings['SWIFT_VERSION'] = '5.0'
        new_config.build_settings['BUNDLE_ID_BASE'] = 'com.example.productInventory'
        new_config.base_configuration_reference = xcconfig_ref if xcconfig_ref

        target_config_list.build_configurations << new_config
        puts "    Created #{config_name}"
      else
        puts "    WARNING: Base config #{base_name} not found!"
      end
    end
  end
end

# Save project
puts ""
puts "Saving project..."
project.save
puts "Project saved successfully!"

puts ""
puts "Final configurations:"
project_config_list.build_configurations.map(&:name).sort.each do |name|
  puts "  - #{name}"
end
RUBY_SCRIPT

    print_step "Build configurations added"
}

#===============================================================================
# Step 5: Create Xcode Schemes
#===============================================================================

create_xcode_schemes() {
    print_header "Step 4: Creating Xcode Schemes"

    SCHEMES_DIR="$IOS_DIR/Runner.xcodeproj/xcshareddata/xcschemes"
    mkdir -p "$SCHEMES_DIR"

    # Read existing Runner.xcscheme as template
    if [ ! -f "$SCHEMES_DIR/Runner.xcscheme" ]; then
        print_warning "Runner.xcscheme not found, skipping scheme creation"
        return
    fi

    # Create development scheme
    cat > "$SCHEMES_DIR/development.xcscheme" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1510"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "97C146ED1CF9000F007C117D"
               BuildableName = "Runner.app"
               BlueprintName = "Runner"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug-development"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
      <Testables>
         <TestableReference
            skipped = "NO"
            parallelizable = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "331C8080294A63A400263BE5"
               BuildableName = "RunnerTests.xctest"
               BlueprintName = "RunnerTests"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug-development"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Profile-development"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug-development">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release-development"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF
    print_step "Created development.xcscheme"

    # Create staging scheme
    cat > "$SCHEMES_DIR/staging.xcscheme" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1510"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "97C146ED1CF9000F007C117D"
               BuildableName = "Runner.app"
               BlueprintName = "Runner"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug-staging"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
      <Testables>
         <TestableReference
            skipped = "NO"
            parallelizable = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "331C8080294A63A400263BE5"
               BuildableName = "RunnerTests.xctest"
               BlueprintName = "RunnerTests"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug-staging"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Profile-staging"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug-staging">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release-staging"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF
    print_step "Created staging.xcscheme"

    # Create production scheme
    cat > "$SCHEMES_DIR/production.xcscheme" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1510"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "97C146ED1CF9000F007C117D"
               BuildableName = "Runner.app"
               BlueprintName = "Runner"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug-production"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
      <Testables>
         <TestableReference
            skipped = "NO"
            parallelizable = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "331C8080294A63A400263BE5"
               BuildableName = "RunnerTests.xctest"
               BlueprintName = "RunnerTests"
               ReferencedContainer = "container:Runner.xcodeproj">
            </BuildableReference>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug-production"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Profile-production"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "97C146ED1CF9000F007C117D"
            BuildableName = "Runner.app"
            BlueprintName = "Runner"
            ReferencedContainer = "container:Runner.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug-production">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release-production"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
EOF
    print_step "Created production.xcscheme"
}

#===============================================================================
# Step 6: Update Podfile
#===============================================================================

update_podfile() {
    print_header "Step 5: Updating Podfile"

    PODFILE="$IOS_DIR/Podfile"

    if [ ! -f "$PODFILE" ]; then
        print_warning "Podfile not found, skipping Podfile update. (This is normal for a fresh Flutter project without native dependencies)"
        return
    fi

    # Backup Podfile
    cp "$PODFILE" "$PODFILE.backup"
    print_step "Created Podfile backup"

    # Check if flavor configurations already exist in Podfile
    if grep -q "Debug-development" "$PODFILE"; then
        print_warning "Flavor configurations already exist in Podfile, skipping"
        return
    fi

    # Replace the project configuration block
    cat > "$PODFILE" << 'EOF'
# Uncomment this line to define a global platform for your project
platform :ios, '15.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
  'Debug-development' => :debug,
  'Debug-staging' => :debug,
  'Debug-production' => :debug,
  'Release-development' => :release,
  'Release-staging' => :release,
  'Release-production' => :release,
  'Profile-development' => :release,
  'Profile-staging' => :release,
  'Profile-production' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}. Try deleting Generated.xcconfig, then run flutter pub get"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
EOF

    print_step "Updated Podfile with flavor configurations"
}

#===============================================================================
# Step 7: Run Pod Install
#===============================================================================

run_pod_install() {
    print_header "Step 6: Running Pod Install"

    cd "$IOS_DIR"

    print_info "Running pod install (this may take a while)..."
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    PODFILE="$IOS_DIR/Podfile"
    if [ ! -f "$PODFILE" ]; then
        print_warning "Podfile not found, skipping pod install."
        return
    fi

    pod install

    print_step "Pod install completed"
}

#===============================================================================
# Step 8: Verification
#===============================================================================

verify_setup() {
    print_header "Step 7: Verification"

    # Check xcconfig files
    echo ""
    echo "xcconfig files:"
    for flavor in "${FLAVORS[@]}"; do
        XCCONFIG="$IOS_DIR/Flutter/${flavor^}.xcconfig"
        if [ -f "$XCCONFIG" ]; then
            print_step "${flavor^}.xcconfig exists"
        else
            print_error "${flavor^}.xcconfig missing"
        fi
    done

    # Check schemes
    echo ""
    echo "Xcode schemes:"
    SCHEMES_DIR="$IOS_DIR/Runner.xcodeproj/xcshareddata/xcschemes"
    for flavor in "${FLAVORS[@]}"; do
        SCHEME="$SCHEMES_DIR/$flavor.xcscheme"
        if [ -f "$SCHEME" ]; then
            print_step "$flavor.xcscheme exists"
        else
            print_error "$flavor.xcscheme missing"
        fi
    done

    # Check Podfile
    echo ""
    echo "Podfile configuration:"
    if grep -q "Debug-development" "$IOS_DIR/Podfile"; then
        print_step "Flavor configurations present in Podfile"
    else
        print_error "Flavor configurations missing in Podfile"
    fi
}

#===============================================================================
# Print Next Steps
#===============================================================================

print_next_steps() {
    print_header "Setup Complete!"

    echo ""
    echo "Your iOS project is now configured for 3 flavors:"
    echo "  - development (com.example.productInventory.dev)"
    echo "  - staging (com.example.productInventory.stg)"
    echo "  - production (com.example.productInventory)"
    echo ""
    echo "Next steps:"
    echo ""
    echo "1. Run your app with a specific flavor:"
    echo "   ${YELLOW}fvm flutter run --flavor development -t lib/main_development.dart${NC}"
    echo "   ${YELLOW}fvm flutter run --flavor staging -t lib/main_staging.dart${NC}"
    echo "   ${YELLOW}fvm flutter run --flavor production -t lib/main_production.dart${NC}"
    echo ""
    echo "2. Build IPA for a specific flavor:"
    echo "   ${YELLOW}fvm flutter build ipa --flavor development -t lib/main_development.dart${NC}"
    echo ""
    echo "3. Or use existing scripts:"
    echo "   ${YELLOW}./scripts/run_development.sh${NC}"
    echo "   ${YELLOW}./scripts/build_ipa_dev.sh${NC}"
    echo ""
    echo "Note: If you encounter issues, try running with --reset flag:"
    echo "   ${YELLOW}./scripts/setup_ios_flavors_complete.sh --reset${NC}"
    echo ""
}

#===============================================================================
# Main Execution
#===============================================================================

main() {
    echo ""
    echo -e "${BLUE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     iOS Flavor Configuration - Complete Setup Script          ║${NC}"
    echo -e "${BLUE}╚═══════════════════════════════════════════════════════════════╝${NC}"

    if [ "$RESET_MODE" = true ]; then
        print_warning "Running in RESET mode - existing flavor configurations will be removed"
    fi

    check_prerequisites
    create_xcconfig_files
    add_build_configurations "$RESET_MODE"
    create_xcode_schemes
    update_podfile
    run_pod_install
    verify_setup
    print_next_steps
}

# Run main function
main
