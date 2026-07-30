.PHONY: setup check run-dev build-apk build-ios clean help

# Flutter Clean Arch Unicorn
# https://github.com/ratingtesting/flutter-clean-arch-unicorn

FLUTTER := flutter

## 🎯 Setup & Installation
setup: ## Install dependencies and setup project
	@echo "🔧 Setting up project..."
	$(FLUTTER) pub get
	@echo "✅ Setup complete. Run 'make run-dev' to start."

## 🔍 Code Quality
check: analyze test format ## Run all quality checks (analyze + test + format)

analyze: ## Run static analysis
	@echo "🔍 Analyzing code..."
	$(FLUTTER) analyze --fatal-infos --fatal-warnings
	@echo "✅ Analysis passed."

test: ## Run all tests
	@echo "🧪 Running tests..."
	$(FLUTTER) test
	@echo "✅ Tests passed."

format: ## Check code formatting
	@echo "🎨 Checking formatting..."
	$(FLUTTER) format --set-exit-if-changed .
	@echo "✅ Formatting OK."

## 🚀 Run
run-dev: ## Run app in development mode
	@echo "🚀 Starting DEV environment..."
	$(FLUTTER) run -t lib/main/main_dev.dart --dart-define=BASE_URL=https://api-dev.example.com

## 📦 Builds
build-apk: ## Build Android APK (debug)
	@echo "📦 Building Android APK..."
	$(FLUTTER) build apk --debug -t lib/main/main_dev.dart
	@echo "✅ APK built."

build-ios: ## Build iOS (release)
	@echo "📦 Building iOS..."
	$(FLUTTER) build ios --release -t lib/main/main_prod.dart
	@echo "✅ iOS build complete."

## 🧹 Cleanup
clean: ## Clean build artifacts
	@echo "🧹 Cleaning..."
	$(FLUTTER) clean
	$(FLUTTER) pub get
	@echo "✅ Clean complete."

## 📚 Help
help: ## Show this help message
	@echo "Flutter Clean Arch Unicorn - Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "GitHub: https://github.com/ratingtesting/flutter-clean-arch-unicorn"
	@echo ""
	@echo "Example: make setup && make run-dev"