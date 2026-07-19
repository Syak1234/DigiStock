#!/bin/bash

# Deploy Android to Play Store
# Usage: ./scripts/deploy_android_playstore.sh [development|staging|production]

set -e

FLAVOR=${1:-development}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 Deploying Android $FLAVOR to Play Store..."

# Load environment variables if .env file exists
if [ -f "$PROJECT_ROOT/.env" ]; then
    export $(cat "$PROJECT_ROOT/.env" | grep -v '^#' | xargs)
fi

# Navigate to Android directory
cd "$PROJECT_ROOT/android"

# Run the appropriate Fastlane lane
case $FLAVOR in
    development)
        echo "📱 Building and uploading Development build to Internal Testing..."
        fastlane internal_development
        ;;
    staging)
        echo "📱 Building and uploading Staging build to Alpha Testing..."
        fastlane alpha_staging
        ;;
    production)
        echo "📱 Building and uploading Production build to Play Store..."
        fastlane release
        ;;
    *)
        echo "❌ Invalid flavor: $FLAVOR"
        echo "Usage: $0 [development|staging|production]"
        exit 1
        ;;
esac

echo "✅ Android deployment completed successfully!"