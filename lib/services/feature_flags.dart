library;

import 'package:flutter/foundation.dart';

/// Feature flags abstraction.
///
/// Wraps Firebase Remote Config behind a single interface.
/// Roll out features without deploying new builds. A/B test everything.

abstract class FeatureFlags {
  Future<void> initialize();
  bool isEnabled(String flag, {bool defaultValue = false});
  String getString(String flag, {String defaultValue = ''});
  int getInt(String flag, {int defaultValue = 0});
  double getDouble(String flag, {double defaultValue = 0.0});
}

/// Static flags for testing / no Firebase.
class StaticFeatureFlags extends FeatureFlags {
  final Map<String, dynamic> _flags;

  StaticFeatureFlags(this._flags);

  @override
  Future<void> initialize() async {}

  @override
  bool isEnabled(String flag, {bool defaultValue = false}) =>
      _flags[flag] as bool? ?? defaultValue;

  @override
  String getString(String flag, {String defaultValue = ''}) =>
      _flags[flag] as String? ?? defaultValue;

  @override
  int getInt(String flag, {int defaultValue = 0}) =>
      _flags[flag] as int? ?? defaultValue;

  @override
  double getDouble(String flag, {double defaultValue = 0.0}) =>
      _flags[flag] as double? ?? defaultValue;
}

/// Production implementation using Firebase Remote Config.
/// This class is only used when Firebase is configured.
/// See firebase_feature_flags.dart for the actual implementation.
class RemoteConfigFeatureFlags extends FeatureFlags {
  RemoteConfigFeatureFlags();

  @override
  Future<void> initialize() async {}

  @override
  bool isEnabled(String flag, {bool defaultValue = false}) {
    debugPrint('[RemoteConfig] getBool: $flag');
    return defaultValue;
  }

  @override
  String getString(String flag, {String defaultValue = ''}) {
    debugPrint('[RemoteConfig] getString: $flag');
    return defaultValue;
  }

  @override
  int getInt(String flag, {int defaultValue = 0}) {
    debugPrint('[RemoteConfig] getInt: $flag');
    return defaultValue;
  }

  @override
  double getDouble(String flag, {double defaultValue = 0.0}) {
    debugPrint('[RemoteConfig] getDouble: $flag');
    return defaultValue;
  }
}
