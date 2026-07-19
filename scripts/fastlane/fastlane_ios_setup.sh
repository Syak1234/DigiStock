#!/bin/bash

# iOS Fastlane Setup Script for Flutter Projects
# This script sets up Fastlane specifically for iOS with App Store Connect API Key authentication
# Usage: ./fastlane_ios_setup.sh

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
    print_color $GREEN "   iOS Fastlane Setup for Flutter         "
    print_color $GREEN "   (App Store Connect API Key Auth)       "
    print_color $GREEN "==========================================="
    echo ""

    # Check if we're in a Flutter project
    if [ ! -f "pubspec.yaml" ]; then
        print_color $RED "Error: pubspec.yaml not found. Please run this script from your Flutter project root directory."
        exit 1
    fi

    # Check if iOS directory exists
    if [ ! -d "ios" ]; then
        print_color $RED "Error: iOS directory not found. Make sure your Flutter project has iOS support."
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
    print_color $YELLOW "\n=== App Configuration ==="

    prompt_with_default "Enter iOS bundle identifier (e.g., com.company.app)" "" "APP_IDENTIFIER"

    # Apple Developer Configuration
    print_color $YELLOW "\n=== Apple Developer Configuration ==="
    prompt_with_default "Enter your Apple ID (email)" "" "APPLE_ID"
    prompt_with_default "Enter your Developer Team ID" "" "TEAM_ID"
    prompt_with_default "Enter your App Store Connect Team ID (usually same as Team ID)" "$TEAM_ID" "ITC_TEAM_ID"

    # App Store Connect API Key Configuration
    print_color $YELLOW "\n=== App Store Connect API Key ==="
    print_color $YELLOW "Get these from: App Store Connect > Users and Access > Integrations > App Store Connect API"
    echo ""
    prompt_with_default "Enter API Key ID" "" "API_KEY_ID"
    prompt_with_default "Enter API Issuer ID" "" "API_ISSUER_ID"
    prompt_with_default "Enter path to .p8 key file (relative to project root, e.g., AuthKey_XXXXX.p8)" "" "API_KEY_FILEPATH"

    # Verify .p8 file exists
    if [ ! -f "$API_KEY_FILEPATH" ]; then
        print_color $YELLOW "⚠ Warning: .p8 file not found at '$API_KEY_FILEPATH'"
        print_color $YELLOW "  Make sure to place the file there before running Fastlane"
    else
        print_color $GREEN "✓ API Key file found"
    fi

    # Firebase Configuration (Optional)
    print_color $YELLOW "\n=== Firebase Configuration (Optional) ==="
    if prompt_yes_no "Setup Firebase App Distribution" "n"; then
        USE_FIREBASE=true
        prompt_with_default "Enter Firebase App ID" "" "FIREBASE_APP_ID"
    else
        USE_FIREBASE=false
        FIREBASE_APP_ID=""
    fi

    # Match Configuration (Optional)
    print_color $YELLOW "\n=== Match Configuration (Optional) ==="
    if prompt_yes_no "Setup Match for certificate management" "n"; then
        USE_MATCH=true
        prompt_with_default "Enter Git repository URL for certificates" "" "MATCH_GIT_URL"
    else
        USE_MATCH=false
        MATCH_GIT_URL=""
    fi

    # Create directory structure
    print_color $YELLOW "\n=== Creating Directory Structure ==="

    mkdir -p ios/fastlane
    mkdir -p ios/build/ios

    print_color $GREEN "✓ Directory structure created"

    # Generate ios/fastlane/.env
    print_color $YELLOW "\n=== Generating ios/fastlane/.env ==="

    # Calculate relative path from ios/fastlane/ to project root
    API_KEY_RELATIVE_PATH="../../${API_KEY_FILEPATH}"

    cat > ios/fastlane/.env << EOF
# iOS Environment Variables for Fastlane
# Generated by fastlane_ios_setup.sh

# Apple Developer
APPLE_ID=${APPLE_ID}
TEAM_ID=${TEAM_ID}
ITC_TEAM_ID=${ITC_TEAM_ID}
APP_IDENTIFIER=${APP_IDENTIFIER}

# App Store Connect API Key (Required for TestFlight/App Store upload)
# Get these from: App Store Connect > Users and Access > Integrations > App Store Connect API
APP_STORE_CONNECT_API_KEY_ID=${API_KEY_ID}
APP_STORE_CONNECT_API_KEY_ISSUER_ID=${API_ISSUER_ID}
# Path relative to ios/fastlane/ directory
APP_STORE_CONNECT_API_KEY_FILEPATH=${API_KEY_RELATIVE_PATH}

# Firebase Configuration (Optional)
EOF

    if [ "$USE_FIREBASE" = true ]; then
        cat >> ios/fastlane/.env << EOF
FIREBASE_APP_ID=${FIREBASE_APP_ID}
# FIREBASE_CLI_TOKEN=your-firebase-cli-token-here
EOF
    else
        cat >> ios/fastlane/.env << EOF
# FIREBASE_APP_ID=your-firebase-app-id
# FIREBASE_CLI_TOKEN=your-firebase-cli-token-here
EOF
    fi

    cat >> ios/fastlane/.env << EOF

# Match Configuration (Optional - for certificate management)
EOF

    if [ "$USE_MATCH" = true ]; then
        cat >> ios/fastlane/.env << EOF
MATCH_GIT_URL=${MATCH_GIT_URL}
# MATCH_PASSWORD=your-match-password
# MATCH_KEYCHAIN_NAME=fastlane_tmp_keychain
# MATCH_KEYCHAIN_PASSWORD=temporary_password
EOF
    else
        cat >> ios/fastlane/.env << EOF
# MATCH_GIT_URL=https://github.com/your-org/certificates
# MATCH_PASSWORD=your-match-password
# MATCH_KEYCHAIN_NAME=fastlane_tmp_keychain
# MATCH_KEYCHAIN_PASSWORD=temporary_password
EOF
    fi

    cat >> ios/fastlane/.env << EOF

# Optional
# SLACK_URL=your-slack-webhook-url
CI=false
EOF

    print_color $GREEN "✓ ios/fastlane/.env generated"

    # Generate iOS Fastfile
    print_color $YELLOW "\n=== Generating iOS Fastfile ==="

    cat > ios/fastlane/Fastfile << 'EOF'
# iOS Fastlane Configuration
# Generated by fastlane_ios_setup.sh
# All configuration is loaded from .env file in ios/fastlane/

default_platform(:ios)

# Resolve the key filepath to absolute path after Fastlane auto-loads .env
# Note: Fastlane automatically loads ios/fastlane/.env
def resolve_key_filepath
  filepath = ENV['APP_STORE_CONNECT_API_KEY_FILEPATH']
  return nil unless filepath

  # If already absolute, return as is
  return filepath if filepath.start_with?('/')

  # Resolve relative path from ios/fastlane/ directory
  File.expand_path(filepath, __dir__)
end

platform :ios do
  before_all do
    setup_ci if ENV['CI'] == 'true'

    # Resolve the key filepath to absolute path
    resolved_path = resolve_key_filepath
    ENV['APP_STORE_CONNECT_API_KEY_FILEPATH'] = resolved_path if resolved_path

    # Debug: Print configuration
    UI.important("=== Fastlane Config ===")
    UI.important("APP_IDENTIFIER: #{ENV['APP_IDENTIFIER'] || 'NOT SET'}")
    UI.important("TEAM_ID: #{ENV['TEAM_ID'] || 'NOT SET'}")
    UI.important("KEY_ID: #{ENV['APP_STORE_CONNECT_API_KEY_ID'] || 'NOT SET'}")
    UI.important("ISSUER_ID: #{ENV['APP_STORE_CONNECT_API_KEY_ISSUER_ID'] || 'NOT SET'}")
    UI.important("KEY_FILEPATH: #{ENV['APP_STORE_CONNECT_API_KEY_FILEPATH'] || 'NOT SET'}")
    if ENV['APP_STORE_CONNECT_API_KEY_FILEPATH']
      UI.important("Key file exists: #{File.exist?(ENV['APP_STORE_CONNECT_API_KEY_FILEPATH'])}")
    end
    UI.important("=======================")
  end

  # Helper method to get API key using app_store_connect_api_key action
  def get_api_key
    key_id = ENV["APP_STORE_CONNECT_API_KEY_ID"]
    issuer_id = ENV["APP_STORE_CONNECT_API_KEY_ISSUER_ID"]
    key_filepath = ENV["APP_STORE_CONNECT_API_KEY_FILEPATH"]

    UI.user_error!("APP_STORE_CONNECT_API_KEY_ID is not set in .env") unless key_id
    UI.user_error!("APP_STORE_CONNECT_API_KEY_ISSUER_ID is not set in .env") unless issuer_id
    UI.user_error!("APP_STORE_CONNECT_API_KEY_FILEPATH is not set in .env") unless key_filepath
    UI.user_error!("API key file not found at: #{key_filepath}") unless File.exist?(key_filepath)

    app_store_connect_api_key(
      key_id: key_id,
      issuer_id: issuer_id,
      key_filepath: key_filepath,
      duration: 1200,
      in_house: false
    )
  end

  desc "Deploy Development to TestFlight"
  lane :development do
    api_key = get_api_key

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "development",
      export_method: "app-store",
      output_directory: "./build/ios",
      output_name: "App_development.ipa",
      clean: true
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      api_key: api_key,
      app_identifier: ENV["APP_IDENTIFIER"],
      team_id: ENV["TEAM_ID"],
      distribute_external: false,
      changelog: "Development build from Fastlane"
    )
  end

  desc "Deploy Staging to TestFlight"
  lane :staging do
    api_key = get_api_key

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "staging",
      export_method: "app-store",
      output_directory: "./build/ios",
      output_name: "App_staging.ipa",
      clean: true
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      api_key: api_key,
      app_identifier: ENV["APP_IDENTIFIER"],
      team_id: ENV["TEAM_ID"],
      distribute_external: true,
      groups: ["Beta Testers"],
      changelog: "Staging build from Fastlane"
    )
  end

  desc "Deploy Production to TestFlight"
  lane :production do
    api_key = get_api_key

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "production",
      export_method: "app-store",
      output_directory: "./build/ios",
      output_name: "App_production.ipa",
      clean: true
    )

    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      api_key: api_key,
      app_identifier: ENV["APP_IDENTIFIER"],
      team_id: ENV["TEAM_ID"],
      distribute_external: true,
      groups: ["Beta Testers"],
      changelog: "Production build from Fastlane"
    )
  end

  desc "Deploy Production to App Store"
  lane :release do
    api_key = get_api_key

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: "production",
      export_method: "app-store",
      output_directory: "./build/ios",
      output_name: "App_release.ipa",
      clean: true
    )

    upload_to_app_store(
      api_key: api_key,
      app_identifier: ENV["APP_IDENTIFIER"],
      skip_screenshots: true,
      skip_metadata: true,
      precheck_include_in_app_purchases: false
    )
  end

  desc "Build IPA only (no upload)"
  lane :build do |options|
    scheme = options[:scheme] || "production"
    export_method = options[:export_method] || "ad-hoc"

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: scheme,
      export_method: export_method,
      output_directory: "./build/ios",
      output_name: "App_#{scheme}.ipa",
      clean: true
    )
  end

  desc "Distribute to Firebase App Distribution"
  lane :firebase do |options|
    scheme = options[:scheme] || "development"
    app_id = ENV["FIREBASE_APP_ID"]

    UI.user_error!("FIREBASE_APP_ID is not set in .env") unless app_id

    build_app(
      workspace: "Runner.xcworkspace",
      scheme: scheme,
      export_method: "ad-hoc",
      output_directory: "./build/ios",
      output_name: "App_#{scheme}.ipa",
      clean: true
    )

    firebase_app_distribution(
      app: app_id,
      ipa_path: "./build/ios/App_#{scheme}.ipa",
      release_notes: options[:release_notes] || "New build from Fastlane",
      groups: options[:groups] || "testers",
      firebase_cli_token: ENV["FIREBASE_CLI_TOKEN"]
    )
  end

  desc "Sync certificates and profiles using Match"
  lane :sync_certificates do |options|
    match_type = options[:type] || "appstore"

    match(
      type: match_type,
      app_identifier: ENV["APP_IDENTIFIER"],
      readonly: options[:readonly] != false
    )
  end

  desc "Setup CI environment"
  lane :setup_ci_env do
    if is_ci
      create_keychain(
        name: ENV["MATCH_KEYCHAIN_NAME"] || "fastlane_tmp_keychain",
        password: ENV["MATCH_KEYCHAIN_PASSWORD"] || "",
        default_keychain: true,
        unlock: true,
        timeout: 3600,
        lock_when_sleeps: false
      )
    end
  end

  desc "Increment build number"
  lane :bump_build do
    increment_build_number(
      xcodeproj: "Runner.xcodeproj"
    )
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

    print_color $GREEN "✓ iOS Fastfile generated"

    # Generate iOS Appfile
    print_color $YELLOW "\n=== Generating iOS Appfile ==="

    cat > ios/fastlane/Appfile << 'EOF'
# iOS Appfile
# Generated by fastlane_ios_setup.sh
# For more information about the Appfile, see:
# https://docs.fastlane.tools/advanced/#appfile

# App Bundle ID (from .env or default)
app_identifier(ENV["APP_IDENTIFIER"] || "com.example.app")

# Apple Developer Portal username (from .env or default)
apple_id(ENV["APPLE_ID"] || "")

# App Store Connect Team ID (from .env or default)
itc_team_id(ENV["ITC_TEAM_ID"] || "")

# Apple Developer Portal Team ID (from .env or default)
team_id(ENV["TEAM_ID"] || "")
EOF

    print_color $GREEN "✓ iOS Appfile generated"

    # Generate Matchfile if using Match
    if [ "$USE_MATCH" = true ]; then
        print_color $YELLOW "\n=== Generating Matchfile ==="

        cat > ios/fastlane/Matchfile << 'EOF'
# Matchfile for code signing certificates management
# Generated by fastlane_ios_setup.sh
# For more information about Match, visit https://docs.fastlane.tools/actions/match/

# Git URL for storing certificates and profiles (from .env)
git_url(ENV["MATCH_GIT_URL"] || "")

# Storage mode: git, google_cloud, s3
storage_mode("git")

# Type of certificates/profiles to sync (can be overridden when running match)
# Options: development, adhoc, appstore, enterprise
type("appstore")

# App Bundle ID (from .env)
app_identifier(ENV["APP_IDENTIFIER"] || "")

# Your Apple Developer Portal username (from .env)
username(ENV["APPLE_ID"] || "")

# Apple Developer Portal Team ID (from .env)
team_id(ENV["TEAM_ID"] || "")

# Git branch to use for certificates
git_branch("main")

# Keychain settings for CI
keychain_name(ENV["MATCH_KEYCHAIN_NAME"] || "fastlane_tmp_keychain") if ENV['CI']
keychain_password(ENV["MATCH_KEYCHAIN_PASSWORD"] || "") if ENV['CI']

# Clone branch directly (faster)
clone_branch_directly(true)

# Verbose mode for debugging
verbose(true)
EOF

        print_color $GREEN "✓ Matchfile generated"
    fi

    # Generate deployment script
    print_color $YELLOW "\n=== Generating Deployment Script ==="

    cat > scripts/deploy_ios_testflight.sh << 'EOF'
#!/bin/bash

# iOS TestFlight Deployment Script
# Generated by fastlane_ios_setup.sh
# Usage: ./deploy_ios_testflight.sh [development|staging|production]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ENVIRONMENT=${1:-development}

echo -e "${GREEN}🚀 iOS TestFlight Deployment Script${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo ""

# Navigate to iOS directory
cd "$PROJECT_ROOT/ios"

case "$ENVIRONMENT" in
    development|dev)
        echo -e "${YELLOW}📱 Deploying Development to TestFlight...${NC}"
        fastlane development
        ;;
    staging|stg)
        echo -e "${YELLOW}📱 Deploying Staging to TestFlight...${NC}"
        fastlane staging
        ;;
    production|prod)
        echo -e "${YELLOW}📱 Deploying Production to TestFlight...${NC}"
        fastlane production
        ;;
    release)
        echo -e "${YELLOW}📱 Deploying to App Store...${NC}"
        fastlane release
        ;;
    *)
        echo -e "${RED}❌ Invalid environment: $ENVIRONMENT${NC}"
        echo "Usage: $0 [development|staging|production|release]"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ iOS deployment completed successfully!${NC}"
EOF

    chmod +x scripts/deploy_ios_testflight.sh
    print_color $GREEN "✓ Deployment script generated"

    # Update .gitignore
    if [ -f ".gitignore" ]; then
        print_color $YELLOW "\n=== Updating .gitignore ==="

        # Check if iOS Fastlane entries already exist
        if ! grep -q "ios/fastlane/.env" .gitignore 2>/dev/null; then
            echo "" >> .gitignore
            echo "# iOS Fastlane" >> .gitignore
            echo "ios/fastlane/.env" >> .gitignore
            echo "ios/fastlane/report.xml" >> .gitignore
            echo "ios/fastlane/Preview.html" >> .gitignore
            echo "ios/fastlane/screenshots" >> .gitignore
            echo "ios/fastlane/test_output" >> .gitignore
            echo "ios/build/" >> .gitignore
            echo "*.ipa" >> .gitignore
            echo "*.dSYM.zip" >> .gitignore
            echo "*.p8" >> .gitignore

            print_color $GREEN "✓ .gitignore updated"
        else
            print_color $YELLOW "⚠ .gitignore already contains iOS Fastlane entries"
        fi
    fi

    # Final instructions
    print_color $GREEN "\n==========================================="
    print_color $GREEN "   iOS Fastlane Setup Complete! 🎉"
    print_color $GREEN "==========================================="
    echo ""
    print_color $YELLOW "Generated Files:"
    echo "  • ios/fastlane/.env      - Environment configuration"
    echo "  • ios/fastlane/Fastfile  - Fastlane lanes"
    echo "  • ios/fastlane/Appfile   - App configuration"
    if [ "$USE_MATCH" = true ]; then
        echo "  • ios/fastlane/Matchfile - Certificate management"
    fi
    echo "  • scripts/deploy_ios_testflight.sh - Deployment script"
    echo ""

    print_color $YELLOW "Next Steps:"
    echo ""
    echo "1. Make sure your .p8 API key file is at: ${API_KEY_FILEPATH}"
    echo ""
    echo "2. Verify your configuration:"
    echo "   cd ios && fastlane lanes"
    echo ""
    echo "3. Deploy your app:"
    echo "   cd ios && fastlane development    # Deploy dev to TestFlight"
    echo "   cd ios && fastlane staging        # Deploy staging to TestFlight"
    echo "   cd ios && fastlane production     # Deploy prod to TestFlight"
    echo "   cd ios && fastlane release        # Deploy to App Store"
    echo ""
    echo "   Or use the script:"
    echo "   ./scripts/deploy_ios_testflight.sh development"
    echo ""

    print_color $YELLOW "Important Notes:"
    echo "  • The .env file is in ios/fastlane/.env (auto-loaded by Fastlane)"
    echo "  • The .p8 key file should NOT be committed to git"
    echo "  • Update ios/fastlane/.env with any changes to your credentials"
    echo ""

    print_color $GREEN "Happy deploying! 🚀"
}

# Run the main function
main "$@"
