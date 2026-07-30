#!/bin/bash
# scripts/check_secrets.sh
# Pre-commit hook to prevent committing secrets

echo "🔒 Checking for secrets..."

# Patterns to search for
PATTERNS=(
    "sk-[a-zA-Z0-9]{48}"
    "API_KEY[=:]"
    "SECRET[=:]"
    "PASSWORD[=:]"
    "PRIVATE_KEY"
    "ghp_[a-zA-Z0-9]{36}"
    "github_pat_"
)

FOUND=0

for pattern in "${PATTERNS[@]}"; do
    # Search in all files except .git, build, and test mocks
    MATCHES=$(grep -r -E "$pattern" . --exclude-dir=.git --exclude-dir=build --exclude-dir=.dart_tool --include="*.dart" --include="*.yaml" --include="*.yml" --include="*.json" 2>/dev/null | grep -v "test\|mock\|dummy\|example\|Noop")
    
    if [ -n "$MATCHES" ]; then
        echo "❌ FOUND POTENTIAL SECRET: $pattern"
        echo "$MATCHES"
        FOUND=1
    fi
done

if [ $FOUND -eq 0 ]; then
    echo "✅ No secrets found. Safe to commit."
else
    echo "🚨 COMMIT BLOCKED: Remove secrets before committing!"
    exit 1
fi