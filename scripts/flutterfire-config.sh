#!/bin/bash
# Script to generate Firebase configuration files for different environments/flavors

if [[ $# -eq 0 ]]; then
  echo "Error: No environment specified. Use 'development', 'staging', or 'production'."
  exit 1
fi

NEW_PACKAGE_NAME="$2"

case $1 in
  development)
    flutterfire config \
      --project=example-product-inventory-dev \
      --out=lib/firebase/firebase_options_dev.dart \
      --ios-bundle-id=com.example.productInventory \
      --ios-out=ios/flavors/dev/GoogleService-Info.plist \
      --android-package-name=com.example.productInventory.dev \
      --android-out=android/app/src/development/google-services.json
    ;;
  staging)
    flutterfire config \
      --project=example-product-inventory-stg \
      --out=lib/firebase/firebase_options_stg.dart \
      --ios-bundle-id=com.example.productInventory \
      --ios-out=ios/flavors/staging/GoogleService-Info.plist \
      --android-package-name=com.example.productInventory.stg \
      --android-out=android/app/src/staging/google-services.json
    ;;
  production)
    flutterfire config \
      --project=product-inventory-prod \
      --out=lib/firebase/firebase_options_prod.dart \
      --ios-bundle-id=com.example.productInventory \
      --ios-out=ios/flavors/production/GoogleService-Info.plist \
      --android-package-name=com.example.productInventory \
      --android-out=android/app/src/production/google-services.json
    ;;
  *)
    echo "Error: Invalid environment specified. Use 'development', 'staging', or 'production'."
    exit 1
    ;;
esac