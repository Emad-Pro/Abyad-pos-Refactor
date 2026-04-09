# Run Instructions for Abyad POS Flutter App

The following changes have been made to make the project compatible with:
- Flutter 3.29.0
- Dart 3.7.0
- Android SDK 35.0.0
- Java (JDK) 21.0.3
- macOS 15.3.2

## Updated Files:

1. **android/build.gradle**
   - Updated Gradle plugin version to 8.2.0
   - Updated Google Services to 4.4.0
   - Added Kotlin Gradle plugin 1.9.23

2. **android/app/build.gradle**
   - Updated Java compatibility to Java 17
   - Added Kotlin JVM target to 17
   - Set compileSdk to 34
   - Set explicit minSdk to 21
   - Set explicit targetSdk to 34

3. **pubspec.yaml**
   - Updated SDK constraint to '>=3.0.0 <4.0.0'
   - Added version numbers to all dependencies
   - Updated several package versions for compatibility with Flutter 3.29.0

## How to Run the App:

1. Open the project in your IDE (Android Studio or VS Code)
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app on a simulator or device

## Troubleshooting:

If you encounter any issues:

1. Make sure Flutter and Dart are updated to the versions mentioned above
2. Verify that Android SDK and JDK are correctly installed and configured
3. Run `flutter doctor` to check for any setup issues
4. Clean the project with `flutter clean` and then run `flutter pub get` again