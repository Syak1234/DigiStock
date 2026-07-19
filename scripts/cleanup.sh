flutter clean
rm -rf Pods pubspec.lock
rm -rf ~/Library/Caches/
flutter pub cache clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cd ios
pod deintegrate
pod cache clean --all
rm -rf ~/Library/Developer/Xcode/DerivedData/
rm -rf Pods Podfile.lock
pod repo update
pod install
dart pub global activate flutterfire_cli
cd ..
