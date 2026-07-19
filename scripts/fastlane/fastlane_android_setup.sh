#!/bin/bash

# Android Fastlane Setup Script for Flutter Projects
# This script sets up Fastlane specifically for Android
# Usage: ./fastlane_android_setup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_color() {
    color=$1
    shift
    echo -e "${color}$@${NC}"
}

# Function to prompt for input with default value
prompt_with_default() {
    local prompt=$1
    local default=$2
    local var_name=$3
    
    if [ -z "$default" ]; then
        read -p "$(echo -e ${BLUE}$prompt: ${NC})" value
    else
        read -p "$(echo -e ${BLUE}$prompt [$default]: ${NC})" value
        value=${value:-$default}
    fi
    
    eval "$var_name='$value'"
}

# Function to prompt for yes/no
prompt_yes_no() {
    local prompt=$1
    local default=$2
    
    if [ "$default" = "y" ]; then
        read -p "$(echo -e ${BLUE}$prompt [Y/n]: ${NC})" yn
        yn=${yn:-y}
    else
        read -p "$(echo -e ${BLUE}$prompt [y/N]: ${NC})" yn
        yn=${yn:-n}
    fi
    
    case $yn in
        [Yy]* ) return 0;;
        * ) return 1;;
    esac
}

# Main setup function
main() {
    print_color $GREEN "==========================================="
    print_color $GREEN "   Android Fastlane Setup for Flutter     "
    print_color $GREEN "==========================================="
    echo ""
    
    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_color $RED "Error: pubspec.yaml not found. Please run this script from your Flutter project root directory."
        exit 1
    fi
    
    # Check if Android directory exists
    if [ ! -d "android" ]; then
        print_color $RED "Error: Android directory not found. Make sure your Flutter project has Android support."
        exit 1
    fi
    
    # Check if Fastlane is installed
    if ! command -v fastlane &> /dev/null; then
        print_color $YELLOW "Fastlane is not installed. Would you like to install it?"
        if prompt_yes_no "Install Fastlane using gem" "y"; then
            print_color $YELLOW "Installing Fastlane..."
            sudo gem install fastlane -NV
        else
            print_color $RED "Fastlane is required. Please install it manually and run this script again."
            exit 1
        fi
    else
        print_color $GREEN "✓ Fastlane is already installed"
    fi
    
    # Get project information
    print_color $YELLOW "\n=== Project Information ==="
    
    # Try to extract app name from pubspec.yaml
    default_app_name=$(grep "^name:" pubspec.yaml | cut -d' ' -f2 | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
    prompt_with_default "Enter your app name" "$default_app_name" "APP_NAME"
    
    # Get Android specific configuration
    print_color $YELLOW "\n=== Android Configuration ==="
    prompt_with_default "Enter Android package name (e.g., com.company.app)" "" "ANDROID_PACKAGE"
    
    if prompt_yes_no "Do you use different flavors for different environments (dev, staging, prod)" "y"; then
        ANDROID_USES_FLAVORS=true
        # Ask about flavor names
        prompt_with_default "Enter Development flavor name" "development" "DEV_FLAVOR"
        prompt_with_default "Enter Staging flavor name" "staging" "STG_FLAVOR"
        prompt_with_default "Enter Production flavor name" "production" "PROD_FLAVOR"
        
        # Ask for separate package names if needed
        if prompt_yes_no "Do you use different package names for each environment" "n"; then
            prompt_with_default "Enter Development package name" "${ANDROID_PACKAGE}" "ANDROID_DEV_PACKAGE"
            prompt_with_default "Enter Staging package name" "${ANDROID_PACKAGE}" "ANDROID_STG_PACKAGE"
            prompt_with_default "Enter Production package name" "${ANDROID_PACKAGE}" "ANDROID_PROD_PACKAGE"
            SEPARATE_PACKAGES=true
        else
            ANDROID_DEV_PACKAGE="${ANDROID_PACKAGE}"
            ANDROID_STG_PACKAGE="${ANDROID_PACKAGE}"
            ANDROID_PROD_PACKAGE="${ANDROID_PACKAGE}"
            SEPARATE_PACKAGES=false
        fi
    else
        ANDROID_USES_FLAVORS=false
        SEPARATE_PACKAGES=false
    fi
    
    # Signing configuration
    print_color $YELLOW "\n=== Signing Configuration ==="
    
    if prompt_yes_no "Do you have a keystore file ready" "y"; then
        prompt_with_default "Enter keystore file path (absolute path)" "" "KEYSTORE_PATH"
        prompt_with_default "Enter keystore password" "" "KEYSTORE_PASSWORD"
        prompt_with_default "Enter key alias" "" "KEY_ALIAS"
        prompt_with_default "Enter key password" "" "KEY_PASSWORD"
        HAS_KEYSTORE=true
    else
        HAS_KEYSTORE=false
        print_color $YELLOW "Note: You'll need to configure keystore details in .env file later"
    fi
    
    # Google Play configuration
    print_color $YELLOW "\n=== Google Play Configuration ==="
    
    if prompt_yes_no "Setup Google Play Store deployment" "y"; then
        USE_PLAY_STORE=true
        prompt_with_default "Enter Play Store service account JSON path (leave empty to set later)" "" "PLAY_STORE_JSON"
        
        if prompt_yes_no "Use internal testing track" "y"; then
            USE_INTERNAL_TRACK=true
        else
            USE_INTERNAL_TRACK=false
        fi
        
        if prompt_yes_no "Use beta/open testing track" "y"; then
            USE_BETA_TRACK=true
        else
            USE_BETA_TRACK=false
        fi
        
        if prompt_yes_no "Use production track" "y"; then
            USE_PRODUCTION_TRACK=true
        else
            USE_PRODUCTION_TRACK=false
        fi
    else
        USE_PLAY_STORE=false
    fi
    
    # Distribution options
    print_color $YELLOW "\n=== Distribution Options ==="
    
    if prompt_yes_no "Setup Firebase App Distribution" "n"; then
        USE_FIREBASE=true
        if [ "$ANDROID_USES_FLAVORS" = true ]; then
            prompt_with_default "Enter Firebase App ID for Development" "" "FIREBASE_DEV_ID"
            prompt_with_default "Enter Firebase App ID for Staging" "" "FIREBASE_STG_ID"
            prompt_with_default "Enter Firebase App ID for Production" "" "FIREBASE_PROD_ID"
        else
            prompt_with_default "Enter Firebase App ID" "" "FIREBASE_APP_ID"
        fi
        prompt_with_default "Enter default tester groups (comma separated)" "testers" "FIREBASE_GROUPS"
    else
        USE_FIREBASE=false
    fi
    
    # Build options
    print_color $YELLOW "\n=== Build Options ==="
    
    if prompt_yes_no "Generate both APK and AAB builds" "y"; then
        BUILD_APK=true
        BUILD_AAB=true
    else
        if prompt_yes_no "Generate APK builds" "y"; then
            BUILD_APK=true
            BUILD_AAB=false
        else
            BUILD_APK=false
            BUILD_AAB=true
        fi
    fi
    
    # Create directory structure
    print_color $YELLOW "\n=== Creating Directory Structure ==="
    
    mkdir -p android/fastlane
    mkdir -p scripts
    
    print_color $GREEN "✓ Directory structure created"
    
    # Save Android configuration
    print_color $YELLOW "\n=== Saving Android Configuration ==="
    
    cat > .android_fastlane_config << EOF
# Android Fastlane Configuration
# Generated by fastlane_android_setup.sh
# This file stores Android-specific configuration for Fastlane

# Project Information
APP_NAME="${APP_NAME}"

# Android Package Configuration
ANDROID_PACKAGE="${ANDROID_PACKAGE}"
ANDROID_USES_FLAVORS=${ANDROID_USES_FLAVORS}
SEPARATE_PACKAGES=${SEPARATE_PACKAGES}
ANDROID_DEV_PACKAGE="${ANDROID_DEV_PACKAGE}"
ANDROID_STG_PACKAGE="${ANDROID_STG_PACKAGE}"
ANDROID_PROD_PACKAGE="${ANDROID_PROD_PACKAGE}"

# Flavor Names
DEV_FLAVOR="${DEV_FLAVOR}"
STG_FLAVOR="${STG_FLAVOR}"
PROD_FLAVOR="${PROD_FLAVOR}"

# Signing
HAS_KEYSTORE=${HAS_KEYSTORE}
KEYSTORE_PATH="${KEYSTORE_PATH}"
KEYSTORE_PASSWORD="${KEYSTORE_PASSWORD}"
KEY_ALIAS="${KEY_ALIAS}"
KEY_PASSWORD="${KEY_PASSWORD}"

# Google Play
USE_PLAY_STORE=${USE_PLAY_STORE}
PLAY_STORE_JSON="${PLAY_STORE_JSON}"
USE_INTERNAL_TRACK=${USE_INTERNAL_TRACK}
USE_BETA_TRACK=${USE_BETA_TRACK}
USE_PRODUCTION_TRACK=${USE_PRODUCTION_TRACK}

# Distribution
USE_FIREBASE=${USE_FIREBASE}
FIREBASE_DEV_ID="${FIREBASE_DEV_ID}"
FIREBASE_STG_ID="${FIREBASE_STG_ID}"
FIREBASE_PROD_ID="${FIREBASE_PROD_ID}"
FIREBASE_APP_ID="${FIREBASE_APP_ID}"
FIREBASE_GROUPS="${FIREBASE_GROUPS}"

# Build Options
BUILD_APK=${BUILD_APK}
BUILD_AAB=${BUILD_AAB}
EOF
    
    print_color $GREEN "✓ Configuration saved to .android_fastlane_config"
    
    # Generate Android Fastfile
    print_color $YELLOW "\n=== Generating Android Fastfile ==="
    
    cat > android/fastlane/Fastfile << 'EOF'
# Android Fastlane Configuration
# Generated by fastlane_android_setup.sh

default_platform(:android)

# Load configuration
def load_config
  config_file = "../.android_fastlane_config"
  config = {}
  if File.exist?(config_file)
    File.read(config_file).each_line do |line|
      next if line.strip.empty? || line.strip.start_with?('#')
      key, value = line.strip.split('=', 2)
      config[key] = value.gsub('"', '') if key && value
    end
  end
  config
end

# Helper function to get version code
def get_version_code
  gradle_file = "../app/build.gradle"
  if File.exist?(gradle_file)
    content = File.read(gradle_file)
    match = content.match(/versionCode\s+(\d+)/)
    return match[1].to_i if match
  end
  1
end


platform :android do
  config = load_config()
  
  before_all do
    # Setup CI environment if needed
    if ENV['CI']
      UI.message("Running in CI environment")
    end
  end
  
EOF
    
    if [ "$ANDROID_USES_FLAVORS" = true ]; then
        # Multi-flavor setup
        if [ "$USE_PLAY_STORE" = true ] && [ "$USE_INTERNAL_TRACK" = true ]; then
            cat >> android/fastlane/Fastfile << 'EOF'
  desc "Deploy Development build to Internal Testing"
  lane :internal_development do
    package_name = config['ANDROID_DEV_PACKAGE'] || config['ANDROID_PACKAGE'] || ENV['ANDROID_PACKAGE']
    dev_flavor = config['DEV_FLAVOR'] || 'development'
    
    
    gradle(
      task: "clean bundle#{dev_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/#{dev_flavor}Release/app-#{dev_flavor}-release.aab",
      package_name: package_name,
      json_key: ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON'],
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_apk: true
    )
    
    slack(
      message: "Successfully deployed #{config['APP_NAME']} Dev to Internal Testing! 🚀",
      slack_url: ENV["SLACK_URL"]
    ) if ENV["SLACK_URL"]
  end
  
EOF
        fi
        
        if [ "$USE_PLAY_STORE" = true ] && [ "$USE_BETA_TRACK" = true ]; then
            cat >> android/fastlane/Fastfile << 'EOF'
  desc "Deploy Staging build to Beta Testing"
  lane :beta_staging do
    package_name = config['ANDROID_STG_PACKAGE'] || config['ANDROID_PACKAGE'] || ENV['ANDROID_PACKAGE']
    stg_flavor = config['STG_FLAVOR'] || 'staging'
    
    
    gradle(
      task: "clean bundle#{stg_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    upload_to_play_store(
      track: "beta",
      aab: "../build/app/outputs/bundle/#{stg_flavor}Release/app-#{stg_flavor}-release.aab",
      package_name: package_name,
      json_key: ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON'],
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_apk: true
    )
    
    slack(
      message: "Successfully deployed #{config['APP_NAME']} Staging to Beta Testing! 🚀",
      slack_url: ENV["SLACK_URL"]
    ) if ENV["SLACK_URL"]
  end
  
EOF
        fi
        
        if [ "$USE_PLAY_STORE" = true ] && [ "$USE_PRODUCTION_TRACK" = true ]; then
            cat >> android/fastlane/Fastfile << 'EOF'
  desc "Deploy Production build to Play Store"
  lane :release do
    package_name = config['ANDROID_PROD_PACKAGE'] || config['ANDROID_PACKAGE'] || ENV['ANDROID_PACKAGE']
    prod_flavor = config['PROD_FLAVOR'] || 'production'
    
    
    gradle(
      task: "clean bundle#{prod_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    upload_to_play_store(
      track: "production",
      rollout: "0.1", # 10% rollout initially
      aab: "../build/app/outputs/bundle/#{prod_flavor}Release/app-#{prod_flavor}-release.aab",
      package_name: package_name,
      json_key: ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON'],
      skip_upload_metadata: false,
      skip_upload_images: false,
      skip_upload_screenshots: false,
      skip_upload_apk: true
    )
    
    slack(
      message: "Successfully deployed #{config['APP_NAME']} to Play Store! 🎉",
      slack_url: ENV["SLACK_URL"]
    ) if ENV["SLACK_URL"]
  end
  
  desc "Complete production rollout"
  lane :complete_rollout do
    package_name = config['ANDROID_PACKAGE'] || ENV['ANDROID_PACKAGE']
    
    upload_to_play_store(
      track: "production",
      rollout: "1.0", # 100% rollout
      package_name: package_name,
      json_key: ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON'],
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_apk: true,
      skip_upload_aab: true
    )
    
    UI.success("Production rollout completed to 100%!")
  end
  
EOF
        fi
        
        # Build lanes for flavors
        if [ "$BUILD_APK" = true ]; then
            cat >> android/fastlane/Fastfile << 'EOF'
  desc "Build Development APK"
  lane :build_apk_development do
    app_name = config['APP_NAME'] || 'App'
    dev_flavor = config['DEV_FLAVOR'] || 'development'
    
    gradle(
      task: "clean assemble#{dev_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    apk_path = "../build/app/outputs/apk/#{dev_flavor}/release/app-#{dev_flavor}-release.apk"
    output_path = "../build/#{app_name.gsub(' ', '_')}_dev.apk"
    
    sh("cp #{apk_path} #{output_path}")
    UI.success("APK saved to: build/#{File.basename(output_path)}")
  end
  
  desc "Build Staging APK"
  lane :build_apk_staging do
    app_name = config['APP_NAME'] || 'App'
    stg_flavor = config['STG_FLAVOR'] || 'staging'
    
    gradle(
      task: "clean assemble#{stg_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    apk_path = "../build/app/outputs/apk/#{stg_flavor}/release/app-#{stg_flavor}-release.apk"
    output_path = "../build/#{app_name.gsub(' ', '_')}_staging.apk"
    
    sh("cp #{apk_path} #{output_path}")
    UI.success("APK saved to: build/#{File.basename(output_path)}")
  end
  
  desc "Build Production APK"
  lane :build_apk_production do
    app_name = config['APP_NAME'] || 'App'
    prod_flavor = config['PROD_FLAVOR'] || 'production'
    
    gradle(
      task: "clean assemble#{prod_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    apk_path = "../build/app/outputs/apk/#{prod_flavor}/release/app-#{prod_flavor}-release.apk"
    output_path = "../build/#{app_name.gsub(' ', '_')}.apk"
    
    sh("cp #{apk_path} #{output_path}")
    UI.success("APK saved to: build/#{File.basename(output_path)}")
  end
  
EOF
        fi
        
        if [ "$BUILD_AAB" = true ]; then
            cat >> android/fastlane/Fastfile << 'EOF'
  desc "Build Development AAB"
  lane :build_aab_development do
    app_name = config['APP_NAME'] || 'App'
    dev_flavor = config['DEV_FLAVOR'] || 'development'
    
    gradle(
      task: "clean bundle#{dev_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    aab_path = "../build/app/outputs/bundle/#{dev_flavor}Release/app-#{dev_flavor}-release.aab"
    output_path = "../build/#{app_name.gsub(' ', '_')}_dev.aab"
    
    sh("cp #{aab_path} #{output_path}")
    UI.success("AAB saved to: build/#{File.basename(output_path)}")
  end
  
  desc "Build Staging AAB"
  lane :build_aab_staging do
    app_name = config['APP_NAME'] || 'App'
    stg_flavor = config['STG_FLAVOR'] || 'staging'
    
    gradle(
      task: "clean bundle#{stg_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    aab_path = "../build/app/outputs/bundle/#{stg_flavor}Release/app-#{stg_flavor}-release.aab"
    output_path = "../build/#{app_name.gsub(' ', '_')}_staging.aab"
    
    sh("cp #{aab_path} #{output_path}")
    UI.success("AAB saved to: build/#{File.basename(output_path)}")
  end
  
  desc "Build Production AAB"
  lane :build_aab_production do
    app_name = config['APP_NAME'] || 'App'
    prod_flavor = config['PROD_FLAVOR'] || 'production'
    
    gradle(
      task: "clean bundle#{prod_flavor.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    aab_path = "../build/app/outputs/bundle/#{prod_flavor}Release/app-#{prod_flavor}-release.aab"
    output_path = "../build/#{app_name.gsub(' ', '_')}.aab"
    
    sh("cp #{aab_path} #{output_path}")
    UI.success("AAB saved to: build/#{File.basename(output_path)}")
  end
  
EOF
        fi
    else
        # Single environment setup
        if [ "$USE_PLAY_STORE" = true ]; then
            if [ "$USE_INTERNAL_TRACK" = true ]; then
                cat >> android/fastlane/Fastfile << 'EOF'
  desc "Deploy to Internal Testing"
  lane :internal do
    package_name = config['ANDROID_PACKAGE'] || ENV['ANDROID_PACKAGE']
    
    
    gradle(
      task: "clean bundleRelease",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    upload_to_play_store(
      track: "internal",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      package_name: package_name,
      json_key: ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON'],
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_apk: true
    )
  end
  
EOF
            fi
            
            if [ "$USE_BETA_TRACK" = true ]; then
                cat >> android/fastlane/Fastfile << 'EOF'
  desc "Deploy to Beta Testing"
  lane :beta do
    package_name = config['ANDROID_PACKAGE'] || ENV['ANDROID_PACKAGE']
    
    
    gradle(
      task: "clean bundleRelease",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    upload_to_play_store(
      track: "beta",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      package_name: package_name,
      json_key: ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON'],
      skip_upload_metadata: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_apk: true
    )
  end
  
EOF
            fi
            
            if [ "$USE_PRODUCTION_TRACK" = true ]; then
                cat >> android/fastlane/Fastfile << 'EOF'
  desc "Deploy to Production"
  lane :release do
    package_name = config['ANDROID_PACKAGE'] || ENV['ANDROID_PACKAGE']
    
    
    gradle(
      task: "clean bundleRelease",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    upload_to_play_store(
      track: "production",
      rollout: "0.1",
      aab: "../build/app/outputs/bundle/release/app-release.aab",
      package_name: package_name,
      json_key: ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON'],
      skip_upload_metadata: false,
      skip_upload_images: false,
      skip_upload_screenshots: false,
      skip_upload_apk: true
    )
  end
  
EOF
            fi
        fi
        
        # Build lanes for single environment
        if [ "$BUILD_APK" = true ]; then
            cat >> android/fastlane/Fastfile << 'EOF'
  desc "Build APK"
  lane :build_apk do
    app_name = config['APP_NAME'] || 'App'
    
    gradle(
      task: "clean assembleRelease",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    apk_path = "../build/app/outputs/apk/release/app-release.apk"
    output_path = "../build/#{app_name.gsub(' ', '_')}.apk"
    
    sh("cp #{apk_path} #{output_path}")
    UI.success("APK saved to: build/#{File.basename(output_path)}")
  end
  
EOF
        fi
        
        if [ "$BUILD_AAB" = true ]; then
            cat >> android/fastlane/Fastfile << 'EOF'
  desc "Build AAB"
  lane :build_aab do
    app_name = config['APP_NAME'] || 'App'
    
    gradle(
      task: "clean bundleRelease",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    aab_path = "../build/app/outputs/bundle/release/app-release.aab"
    output_path = "../build/#{app_name.gsub(' ', '_')}.aab"
    
    sh("cp #{aab_path} #{output_path}")
    UI.success("AAB saved to: build/#{File.basename(output_path)}")
  end
  
EOF
        fi
    fi
    
    # Firebase distribution
    if [ "$USE_FIREBASE" = true ]; then
        cat >> android/fastlane/Fastfile << 'EOF'
  desc "Distribute to Firebase App Distribution"
  lane :firebase do |options|
    config = load_config()
    app_name = config['APP_NAME'] || 'App'
    
EOF
        if [ "$ANDROID_USES_FLAVORS" = true ]; then
            cat >> android/fastlane/Fastfile << 'EOF'
    flavor = options[:flavor] || "development"
    
    case flavor
    when "development"
      flavor_name = config['DEV_FLAVOR'] || 'development'
      app_id = ENV["FIREBASE_APP_ID_DEVELOPMENT"] || config['FIREBASE_DEV_ID']
    when "staging"
      flavor_name = config['STG_FLAVOR'] || 'staging'
      app_id = ENV["FIREBASE_APP_ID_STAGING"] || config['FIREBASE_STG_ID']
    else
      flavor_name = config['PROD_FLAVOR'] || 'production'
      app_id = ENV["FIREBASE_APP_ID_PRODUCTION"] || config['FIREBASE_PROD_ID']
    end
    
    gradle(
      task: "clean assemble#{flavor_name.capitalize}Release",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    firebase_app_distribution(
      app: app_id,
      apk_path: "../build/app/outputs/apk/#{flavor_name}/release/app-#{flavor_name}-release.apk",
      release_notes: options[:release_notes] || "New build from Fastlane",
      groups: options[:groups] || config['FIREBASE_GROUPS'] || "testers",
      firebase_cli_token: ENV["FIREBASE_CLI_TOKEN"]
    )
EOF
        else
            cat >> android/fastlane/Fastfile << 'EOF'
    app_id = ENV["FIREBASE_APP_ID"] || config['FIREBASE_APP_ID']
    
    gradle(
      task: "clean assembleRelease",
      project_dir: "../",
      print_command: false,
      properties: {
        "android.injected.signing.store.file" => ENV["KEYSTORE_PATH"] || config['KEYSTORE_PATH'],
        "android.injected.signing.store.password" => ENV["KEYSTORE_PASSWORD"] || config['KEYSTORE_PASSWORD'],
        "android.injected.signing.key.alias" => ENV["KEY_ALIAS"] || config['KEY_ALIAS'],
        "android.injected.signing.key.password" => ENV["KEY_PASSWORD"] || config['KEY_PASSWORD'],
      }
    )
    
    firebase_app_distribution(
      app: app_id,
      apk_path: "../build/app/outputs/apk/release/app-release.apk",
      release_notes: options[:release_notes] || "New build from Fastlane",
      groups: options[:groups] || config['FIREBASE_GROUPS'] || "testers",
      firebase_cli_token: ENV["FIREBASE_CLI_TOKEN"]
    )
EOF
        fi
        
        cat >> android/fastlane/Fastfile << 'EOF'
  end
  
EOF
    fi
    
    # Utility lanes
    cat >> android/fastlane/Fastfile << 'EOF'
  
  desc "Clean build directories"
  lane :clean do
    gradle(
      task: "clean",
      project_dir: "../"
    )
    
    sh("rm -rf ../build")
    UI.success("Build directories cleaned")
  end
  
  desc "Run tests"
  lane :test do
    gradle(
      task: "test",
      project_dir: "../"
    )
  end
  
  desc "Setup keystore"
  lane :setup_keystore do
    if !File.exist?("../app/keystore.jks")
      UI.important("Generating a new keystore...")
      sh("keytool -genkey -v -keystore ../app/keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release")
      UI.success("Keystore generated at app/keystore.jks")
      UI.important("Remember to update your .env file with keystore details")
    else
      UI.success("Keystore already exists")
    end
  end
  
  desc "Validate Play Store setup"
  lane :validate_play_store do
    config = load_config()
    json_key = ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON']
    package_name = config['ANDROID_PACKAGE'] || ENV['ANDROID_PACKAGE']
    
    if json_key && File.exist?(json_key)
      UI.success("Play Store JSON key found")
      
      # Try to validate access
      begin
        google_play_track_version_codes(
          track: "internal",
          json_key: json_key,
          package_name: package_name
        )
        UI.success("Successfully connected to Play Store!")
      rescue => e
        UI.error("Could not connect to Play Store: #{e.message}")
      end
    else
      UI.error("Play Store JSON key not found")
    end
  end
  
  error do |lane, exception|
    slack(
      message: "Error in lane #{lane}: #{exception.message}",
      success: false,
      slack_url: ENV["SLACK_URL"]
    ) if ENV["SLACK_URL"]
  end
end
EOF
    
    print_color $GREEN "✓ Android Fastfile generated"
    
    # Generate Android Appfile
    print_color $YELLOW "\n=== Generating Android Appfile ==="
    
    cat > android/fastlane/Appfile << 'EOF'
# Android Appfile
# Generated by fastlane_android_setup.sh

# Load configuration
config_file = "../.android_fastlane_config"
config = {}
if File.exist?(config_file)
  File.read(config_file).each_line do |line|
    next if line.strip.empty? || line.strip.start_with?('#')
    key, value = line.strip.split('=', 2)
    config[key] = value.gsub('"', '') if key && value
  end
end

json_key_file(ENV["PLAY_STORE_CONFIG_JSON"] || config['PLAY_STORE_JSON'] || "")
package_name(ENV["PACKAGE_NAME"] || config['ANDROID_PACKAGE'] || "com.example.app")

# Environment-specific package names
for_platform :android do
EOF
    
    if [ "$ANDROID_USES_FLAVORS" = true ]; then
        cat >> android/fastlane/Appfile << 'EOF'
  for_lane :internal_development do
    package_name config['ANDROID_DEV_PACKAGE'] || config['ANDROID_PACKAGE']
  end
  
  for_lane :beta_staging do
    package_name config['ANDROID_STG_PACKAGE'] || config['ANDROID_PACKAGE']
  end
  
  for_lane :release do
    package_name config['ANDROID_PROD_PACKAGE'] || config['ANDROID_PACKAGE']
  end
EOF
    fi
    
    cat >> android/fastlane/Appfile << 'EOF'
end
EOF
    
    print_color $GREEN "✓ Android Appfile generated"
    
    # Generate deployment script
    print_color $YELLOW "\n=== Generating Deployment Script ==="
    
    cat > scripts/deploy_android.sh << 'EOF'
#!/bin/bash

# Android Deployment Script
# Generated by fastlane_android_setup.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load configuration
if [ -f "$PROJECT_ROOT/.android_fastlane_config" ]; then
    source "$PROJECT_ROOT/.android_fastlane_config"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 Android Deployment Script${NC}"
echo ""

# Load environment variables if .env file exists
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
fi

EOF
    
    if [ "$ANDROID_USES_FLAVORS" = true ]; then
        cat >> scripts/deploy_android.sh << 'EOF'
# Check for flavor argument
FLAVOR=${1:-development}
ACTION=${2:-playstore}

# Navigate to Android directory
cd "$PROJECT_ROOT/android"

case "$ACTION" in
    playstore|internal|beta|release)
        case $FLAVOR in
            development)
                echo -e "${YELLOW}📱 Deploying Development to Internal Testing...${NC}"
                fastlane internal_development
                ;;
            staging)
                echo -e "${YELLOW}📱 Deploying Staging to Beta Testing...${NC}"
                fastlane beta_staging
                ;;
            production)
                echo -e "${YELLOW}📱 Deploying Production to Play Store...${NC}"
                fastlane release
                ;;
            *)
                echo -e "${RED}❌ Invalid flavor: $FLAVOR${NC}"
                echo "Usage: $0 [development|staging|production] [playstore|build-apk|build-aab|firebase]"
                exit 1
                ;;
        esac
        ;;
    build-apk)
        case $FLAVOR in
            development)
                echo -e "${YELLOW}🔨 Building Development APK...${NC}"
                fastlane build_apk_development
                ;;
            staging)
                echo -e "${YELLOW}🔨 Building Staging APK...${NC}"
                fastlane build_apk_staging
                ;;
            production)
                echo -e "${YELLOW}🔨 Building Production APK...${NC}"
                fastlane build_apk_production
                ;;
            *)
                echo -e "${RED}❌ Invalid flavor: $FLAVOR${NC}"
                echo "Usage: $0 [development|staging|production] [playstore|build-apk|build-aab|firebase]"
                exit 1
                ;;
        esac
        ;;
    build-aab)
        case $FLAVOR in
            development)
                echo -e "${YELLOW}🔨 Building Development AAB...${NC}"
                fastlane build_aab_development
                ;;
            staging)
                echo -e "${YELLOW}🔨 Building Staging AAB...${NC}"
                fastlane build_aab_staging
                ;;
            production)
                echo -e "${YELLOW}🔨 Building Production AAB...${NC}"
                fastlane build_aab_production
                ;;
            *)
                echo -e "${RED}❌ Invalid flavor: $FLAVOR${NC}"
                echo "Usage: $0 [development|staging|production] [playstore|build-apk|build-aab|firebase]"
                exit 1
                ;;
        esac
        ;;
EOF
        
        if [ "$USE_FIREBASE" = true ]; then
            cat >> scripts/deploy_android.sh << 'EOF'
    firebase)
        echo -e "${YELLOW}🔥 Distributing $FLAVOR to Firebase...${NC}"
        fastlane firebase flavor:$FLAVOR
        ;;
EOF
        fi
        
        cat >> scripts/deploy_android.sh << 'EOF'
    *)
        echo -e "${RED}❌ Invalid action: $ACTION${NC}"
        echo "Usage: $0 [development|staging|production] [playstore|build-apk|build-aab|firebase]"
        exit 1
        ;;
esac
EOF
    else
        cat >> scripts/deploy_android.sh << 'EOF'
ACTION=${1:-internal}

# Navigate to Android directory
cd "$PROJECT_ROOT/android"

case "$ACTION" in
    internal)
        echo -e "${YELLOW}📱 Deploying to Internal Testing...${NC}"
        fastlane internal
        ;;
    beta)
        echo -e "${YELLOW}📱 Deploying to Beta Testing...${NC}"
        fastlane beta
        ;;
    release|production)
        echo -e "${YELLOW}📱 Deploying to Production...${NC}"
        fastlane release
        ;;
    build-apk)
        echo -e "${YELLOW}🔨 Building APK...${NC}"
        fastlane build_apk
        ;;
    build-aab)
        echo -e "${YELLOW}🔨 Building AAB...${NC}"
        fastlane build_aab
        ;;
EOF
        
        if [ "$USE_FIREBASE" = true ]; then
            cat >> scripts/deploy_android.sh << 'EOF'
    firebase)
        echo -e "${YELLOW}🔥 Distributing to Firebase...${NC}"
        fastlane firebase
        ;;
EOF
        fi
        
        cat >> scripts/deploy_android.sh << 'EOF'
    *)
        echo -e "${RED}❌ Invalid action: $ACTION${NC}"
        echo "Usage: $0 [internal|beta|release|build-apk|build-aab|firebase]"
        exit 1
        ;;
esac
EOF
    fi
    
    cat >> scripts/deploy_android.sh << 'EOF'

echo -e "${GREEN}✅ Android deployment completed successfully!${NC}"
EOF
    
    chmod +x scripts/deploy_android.sh
    print_color $GREEN "✓ Deployment script generated"
    
    # Generate environment template
    print_color $YELLOW "\n=== Generating Environment Template ==="
    
    cat > .env.android.example << EOF
# Android Environment Variables
# Generated by fastlane_android_setup.sh
# Copy this file to .env and fill in your actual values

# Signing Configuration
KEYSTORE_PATH=${KEYSTORE_PATH}
KEYSTORE_PASSWORD=${KEYSTORE_PASSWORD}
KEY_ALIAS=${KEY_ALIAS}
KEY_PASSWORD=${KEY_PASSWORD}

# Google Play
PLAY_STORE_CONFIG_JSON=${PLAY_STORE_JSON}
PACKAGE_NAME=${ANDROID_PACKAGE}
EOF
    
    if [ "$USE_FIREBASE" = true ]; then
        cat >> .env.android.example << EOF

# Firebase Configuration
FIREBASE_CLI_TOKEN=your_firebase_cli_token
EOF
        if [ "$ANDROID_USES_FLAVORS" = true ]; then
            cat >> .env.android.example << EOF
FIREBASE_APP_ID_DEVELOPMENT=${FIREBASE_DEV_ID}
FIREBASE_APP_ID_STAGING=${FIREBASE_STG_ID}
FIREBASE_APP_ID_PRODUCTION=${FIREBASE_PROD_ID}
EOF
        else
            cat >> .env.android.example << EOF
FIREBASE_APP_ID=${FIREBASE_APP_ID}
EOF
        fi
    fi
    
    cat >> .env.android.example << EOF

# Optional
SLACK_URL=your_slack_webhook_url
CI=false
EOF
    
    print_color $GREEN "✓ Environment template generated"
    
    # Update .gitignore
    if [ -f ".gitignore" ]; then
        print_color $YELLOW "\n=== Updating .gitignore ==="
        
        if ! grep -q ".android_fastlane_config" .gitignore; then
            echo "" >> .gitignore
            echo "# Android Fastlane" >> .gitignore
            echo ".android_fastlane_config" >> .gitignore
            echo ".env" >> .gitignore
            echo ".env.android" >> .gitignore
            echo "android/fastlane/report.xml" >> .gitignore
            echo "android/fastlane/Preview.html" >> .gitignore
            echo "android/fastlane/test_output" >> .gitignore
            echo "*.apk" >> .gitignore
            echo "*.aab" >> .gitignore
            echo "android/app/keystore.jks" >> .gitignore
            echo "android/key.properties" >> .gitignore
            
            print_color $GREEN "✓ .gitignore updated"
        else
            print_color $YELLOW "⚠ .gitignore already contains Android Fastlane entries"
        fi
    fi
    
    # Final instructions
    print_color $GREEN "\n==========================================="
    print_color $GREEN "   Android Fastlane Setup Complete! 🎉"
    print_color $GREEN "==========================================="
    echo ""
    print_color $YELLOW "Next Steps:"
    echo ""
    echo "1. Copy the environment template and add your credentials:"
    echo "   cp .env.android.example .env"
    echo ""
    
    if [ "$HAS_KEYSTORE" = false ]; then
        echo "2. Generate or configure your keystore:"
        echo "   cd android && fastlane setup_keystore"
        echo ""
    fi
    
    if [ "$USE_PLAY_STORE" = true ]; then
        echo "3. Setup Google Play Store access:"
        echo "   - Create a service account in Google Cloud Console"
        echo "   - Grant access in Play Console"
        echo "   - Download JSON key and update PLAY_STORE_CONFIG_JSON in .env"
        echo "   - Validate: cd android && fastlane validate_play_store"
        echo ""
    fi
    
    echo "4. Test your setup:"
    echo "   cd android && fastlane lanes"
    echo ""
    
    echo "5. Deploy your app:"
    if [ "$ANDROID_USES_FLAVORS" = true ]; then
        echo "   ./scripts/deploy_android.sh development playstore"
        echo "   ./scripts/deploy_android.sh staging build-apk"
        echo "   ./scripts/deploy_android.sh production release"
    else
        echo "   ./scripts/deploy_android.sh internal"
        echo "   ./scripts/deploy_android.sh build-apk"
    fi
    echo ""
    
    print_color $YELLOW "Documentation:"
    echo "- Configuration saved in: .android_fastlane_config"
    echo "- Fastlane files in: android/fastlane/"
    echo "- Deployment script: scripts/deploy_android.sh"
    echo ""
    
    print_color $GREEN "Happy deploying! 🚀"
}

# Run the main function
main "$@"