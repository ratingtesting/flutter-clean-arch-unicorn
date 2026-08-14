import 'package:flutter/foundation.dart';

/// Contract for performance monitoring.
///
/// Template ships a [NoopPerformanceMonitor]. Swap for Firebase Performance
/// or a custom tracer when scaling — feature code stays vendor-independent.
abstract class PerformanceMonitor {
  /// Trace a synchronous/async block with a named span.
  T trace<T>(String name, T Function() block);

  /// Trace a future.
  Future<T> traceAsync<T>(String name, Future<T> Function() block);

  /// Report a custom metric (e.g. startup time in ms).
  void recordMetric(String name, double value, {String? unit});

  /// Startup time measurement helper.
  void recordStartupTime(Duration duration);
}

/// No-op implementation. Used by default (dev/test).
class NoopPerformanceMonitor implements PerformanceMonitor {
  @override
  T trace<T>(String name, T Function() block) => block();

  @override
  Future<T> traceAsync<T>(String name, Future<T> Function() block) => block();

  @override
  void recordMetric(String name, double value, {String? unit}) {
    if (kDebugMode) {
      debugPrint('[PerformanceMonitor] $name: $value${unit ?? ''}');
    }
  }

  @override
  void recordStartupTime(Duration duration) {
    recordMetric('startup_time', duration.inMilliseconds.toDouble(), unit: 'ms');
  }
}
