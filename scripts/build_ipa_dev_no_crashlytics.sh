#!/bin/bash

# Build IPA for development without Crashlytics symbols upload
# This script builds the IPA with Crashlytics disabled to avoid upload errors

flutter build ipa --target=lib/main_development.dart --flavor=development --no-tree-shake-icons
