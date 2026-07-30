@echo off
REM make.bat - Windows alternative to Makefile
REM Usage: make.bat [command]

setlocal enabledelayedexpansion

if "%1"=="" goto help
if "%1"=="setup" goto setup
if "%1"=="check" goto check
if "%1"=="test" goto test
if "%1"=="analyze" goto analyze
if "%1"=="format" goto format
if "%1"=="run-dev" goto run-dev
if "%1"=="build-apk" goto build-apk
if "%1"=="clean" goto clean
if "%1"=="help" goto help

echo Unknown command: %1
goto help

:setup
echo 🔧 Setting up project...
flutter pub get
echo ✅ Setup complete.
goto end

:check
call :analyze
call :test
call :format
goto end

:test
echo 🧪 Running tests...
flutter test
echo ✅ Tests passed.
goto end

:analyze
echo 🔍 Analyzing code...
flutter analyze --fatal-infos --fatal-warnings
echo ✅ Analysis passed.
goto end

:format
echo 🎨 Checking formatting...
flutter format --set-exit-if-changed .
echo ✅ Formatting OK.
goto end

:run-dev
echo 🚀 Starting DEV environment...
flutter run --flavor dev -t lib/main/main_dev.dart --dart-define=BASE_URL=https://api-dev.example.com
goto end

:build-apk
echo 📦 Building Android APK...
flutter build apk --debug --flavor dev -t lib/main/main_dev.dart
echo ✅ APK built: build\app\outputs\flutter-apk\app-debug.apk
goto end

:clean
echo 🧹 Cleaning...
flutter clean
flutter pub get
echo ✅ Clean complete.
goto end

:help
echo Flutter Template Riverpod 3 - Available commands:
echo.
echo   setup      - Install dependencies
echo   check      - Run analyze + test + format
echo   test       - Run all tests
echo   analyze    - Run static analysis
echo   format     - Check code formatting
echo   run-dev    - Run app in dev mode
echo   build-apk  - Build Android APK
echo   clean      - Clean build artifacts
echo   help       - Show this help
echo.
echo Example: make.bat setup ^&^& make.bat run-dev
goto end

:end
endlocal