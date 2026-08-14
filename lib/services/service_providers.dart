/// Riverpod providers for all observability and security services.
///
/// This file wires the abstract interfaces to concrete implementations.
/// Switch implementations by changing one provider — zero changes in consuming code.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/logger.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/error_reporter.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/analytics.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/performance.dart';
import 'package:flutter_clean_arch_unicorn/services/feature_flags.dart';
import 'package:flutter_clean_arch_unicorn/services/security/secure_storage.dart';

/// Logger provider — use this everywhere instead of print().
final loggerProvider = Provider<AppLogger>((ref) {
  return ConsoleLogger();
});

/// Error reporter provider — no-op by default, replace with Crashlytics in prod.
final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  return NoopCrashReportingService();
});

/// Analytics tracker provider — no-op by default, replace with Firebase Analytics in prod.
final analyticsProvider = Provider<AnalyticsTracker>((ref) {
  return NoopAnalyticsTracker();
});

/// Feature flags provider — static flags by default, replace with RemoteConfig in prod.
final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  return StaticFeatureFlags({});
});

/// Secure storage provider — encrypted token storage.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorageImpl();
});

/// Performance monitoring provider — Noop by default, replace with Firebase
/// Performance / custom tracer in prod (see docs/adr/performance-monitoring.md).
final performanceMonitorProvider = Provider<PerformanceMonitor>((ref) {
  return NoopPerformanceMonitor();
});
