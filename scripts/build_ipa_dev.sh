flutter build ipa --target=lib/main_development.dart --flavor=development --dart-define-from-file=config/dev.json

xcrun altool --upload-app --type ios -f build/ios/ipa/*.ipa --apiKey 29GH885RN3 --apiIssuer 180baef9-3fff-4547-85a9-68bde71620d0