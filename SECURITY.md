# Security Policy

## Supported Versions

Only the latest tagged release receives security updates.

| Version | Supported          |
| ------- | ------------------ |
| v1.7.x  | ✅ Yes (latest)    |
| < v1.7  | ❌ No              |

## Reporting a Vulnerability

**DO NOT** open a public issue for security vulnerabilities.

Report privately to: **security@your-org.example** (replace with actual contact)

Include:
- Description of the vulnerability
- Steps to reproduce
- Impact assessment
- Suggested fix (if any)

We aim to acknowledge within 48 hours and provide a fix timeline within 7 days.

## Security Model of This Template

### Threat Model (STRIDE)

| Threat | Mitigation in Template |
|--------|------------------------|
| **S**poofing | SecureStorage for tokens, auth interceptor injects token |
| **T**ampering | Network Security Config (cleartext blocked), signed builds |
| **R**epudiation | Structured audit logs (AppLogger), immutable events |
| **I**nformation Disclosure | Secrets in `--dart-define` / CI Secrets, SecureStorage for tokens |
| **D**enial of Service | Retry interceptor with exponential backoff (rate limiting is a backend responsibility) |
| **E**levation of Privilege | Authorization boundaries belong to your backend; the template only guards routes client-side |

### Secrets Management

```
❌ NEVER commit:
  - .env files
  - API keys, tokens, passwords
  - Keystore / provisioning profiles
  - firebase google-services.json / GoogleService-Info.plist

✅ ALWAYS use:
  - GitHub Secrets (CI)
  - --dart-define=KEY=value (build-time)
  - flutter_secure_storage (runtime, encrypted)
  - Fastlane match (code signing)
```

### Network Security

- **Cleartext disabled** — `cleartextTrafficPermitted=false` in Android manifest
- **Certificate Pinning** — *optional, not bundled*: add `CertificatePinningInterceptor` + Network Security Config when your backend requires it
- **CSP**: Content-Security-Policy headers on API responses (backend responsibility)

### Token Storage

- **Access/Refresh tokens** → `flutter_secure_storage` (iOS Keychain `first_unlock_this_device`, Android EncryptedSharedPreferences AES-256)
- **User PII** → same encrypted storage
- **Non-sensitive cache** → SharedPreferences (theme, locale, feature flags)

### Dependency Security

- `flutter pub outdated` — weekly check
- Use caret (`^`) ranges for normal deps, but avoid unconstrained `any`; pin critical security-sensitive packages to a known-good version when needed
- Audit transitive deps before upgrading

### Incident Response

1. **Detect** → Log anomaly / test failure alert
2. **Contain** → Feature Flag kill-switch (`featureFlags.isEnabled('payment_flow') = false`)
3. **Investigate** → Structured logs + stack traces
4. **Fix** → Hotfix branch → tag → deploy
5. **Post-mortem** → ADR with timeline, root cause, prevention

## Hardening Checklist for Your App

Before shipping to production, verify:

- [ ] Certificate pins configured for YOUR domains
- [ ] Network Security Config pins match
- [ ] `flutter_secure_storage` used for ALL tokens/secrets
- [ ] `--dart-define` for all API keys (no hardcoded)
- [ ] Crashlytics / Sentry DSN in CI secrets only
- [ ] Firebase `google-services.json` / `GoogleService-Info.plist` NOT in repo
- [ ] Keystore / provisioning profiles in Fastlane match / CI secrets
- [ ] `flutter build apk --release` / `flutter build ios --release` passes
- [ ] Play Integrity / App Attest enabled (if applicable)
- [ ] Penetration test passed (OWASP MASVS L1+)

## Security-Related Files in Template

```
lib/services/security/
  ├── secure_storage.dart          # Interface + encrypted impl + fake for tests
  └── (interceptors live in lib/services/network/)

lib/services/network/
  └── interceptors/                # Dio interceptors (retry, auth, logging)

.github/workflows/main.yml         # CI: pub get, build_runner, format, analyze, secret scan, boundary, test+coverage, coverage gate, apk build
```

## License

MIT-0. No warranty. Use at your own risk. Security is a process, not a checkbox.