library;

import 'package:flutter/foundation.dart';

/// Analytics tracking abstraction.
///
/// Wraps Firebase Analytics / Amplitude / PostHog behind a single interface.
/// Every growth experiment starts with structured event tracking.

abstract class AnalyticsTracker {
  Future<void> initialize();
  Future<void> track(String eventName, {Map<String, dynamic>? properties});
  Future<void> trackScreen(String screenName, {String? screenClass});
  Future<void> setUserIdentifier(String id);
  Future<void> setUserProperty(String name, String value);
  Future<void> reset();
}

/// No-op for testing.
class NoopAnalyticsTracker extends AnalyticsTracker {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> track(String eventName,
      {Map<String, dynamic>? properties}) async {}

  @override
  Future<void> trackScreen(String screenName, {String? screenClass}) async {}

  @override
  Future<void> setUserIdentifier(String id) async {}

  @override
  Future<void> setUserProperty(String name, String value) async {}

  @override
  Future<void> reset() async {}
}

/// Production implementation using Firebase Analytics.
/// This class is only used when Firebase is configured.
/// See firebase_analytics_tracker.dart for the actual implementation.
class FirebaseAnalyticsTracker extends AnalyticsTracker {
  FirebaseAnalyticsTracker();

  @override
  Future<void> initialize() async {}

  @override
  Future<void> track(String eventName,
      {Map<String, dynamic>? properties}) async {
    debugPrint('[Analytics] track: $eventName, properties: $properties');
  }

  @override
  Future<void> trackScreen(String screenName, {String? screenClass}) async {
    debugPrint('[Analytics] trackScreen: $screenName, class: $screenClass');
  }

  @override
  Future<void> setUserIdentifier(String id) async {
    debugPrint('[Analytics] setUserId: $id');
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    debugPrint('[Analytics] setUserProperty: $name = $value');
  }

  @override
  Future<void> reset() async {
    debugPrint('[Analytics] reset');
  }
}
