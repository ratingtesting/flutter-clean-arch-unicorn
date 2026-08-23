.PHONY: setup gen check boundary run-dev build-apk build-ios clean help

# Flutter Clean Arch Unicorn
# https://github.com/ratingtesting/flutter-clean-arch-unicorn

FLUTTER := flutter

## 🎯 Setup & Installation
setup: ## Install dependencies and setup project
	@echo "🔧 Setting up project..."
	$(FLUTTER) pub get
	@echo "✅ Setup complete. Run 'make run-dev' to start."

## ⚙️ Code Generation
gen: ## Generate freezed/drift code (REQUIRED before analyze/test)
	@echo "⚙️ Generating code (freezed, drift)..."
	dart run build_runner build --delete-conflicting-outputs
	@echo "✅ Generated. Now analyze/test see the full picture."

## 🔍 Code Quality
check: gen analyze test format boundary secrets ## Run all quality checks (gen + analyze + test + format + boundaries + secret scan)

secrets: ## Scan for accidentally committed secrets
	@echo "🔒 Scanning for secrets..."
	bash scripts/check_secrets.sh
	@echo "✅ No secrets found."

boundary: ## Run architecture boundary enforcer (fails on forbidden imports)
	@echo "🧱 Checking architecture boundaries..."
	$(FLUTTER) pub get >/dev/null 2>&1 || true
	dart run tool/check_boundaries.dart
	@echo "✅ Boundaries OK."

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