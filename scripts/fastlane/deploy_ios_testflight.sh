#!/bin/bash

# Deploy iOS to TestFlight
# Usage: ./scripts/deploy_ios_testflight.sh [development|staging|production]

set -e

FLAVOR=${1:-development}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Deploying iOS $FLAVOR to TestFlight..."

# Load environment variables if .env file exists
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
fi

# Navigate to iOS directory
cd "$PROJECT_ROOT/ios"

# Run the appropriate Fastlane lane
case $FLAVOR in
    development)
        echo "📱 Building and uploading Development build to TestFlight..."
        fastlane development
        ;;
    staging)
        echo "📱 Building and uploading Staging build to TestFlight..."
        fastlane staging
        ;;
    production)
        echo "📱 Building and uploading Production build to App Store..."
        fastlane release
        ;;
    *)
        echo "❌ Invalid flavor: $FLAVOR"
        echo "Usage: $0 [development|staging|production]"
        exit 1
        ;;
esac

echo "✅ iOS deployment completed successfully!"