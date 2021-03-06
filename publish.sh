flutter clean
flutter build appbundle --release
cd android
bundle exec fastlane deploy
cd ..
flutter build ios --release --no-codesign
cd ios
bundle exec fastlane release
cd ..
flutter build macos --release --no-codesign
cd macos
bundle exec fastlane release
