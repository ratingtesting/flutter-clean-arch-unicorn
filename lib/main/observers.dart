import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_clean_arch_unicorn/main/app_env.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod observer that logs provider changes.
///
/// Active only outside production builds so sensitive provider state
/// (auth/user objects) never leaks into release logs.
base class Observers extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (kReleaseMode || EnvInfo.isProduction) return;
    log('''
      "provider": "\u0024${context.provider.name ?? context.provider.runtimeType}",
      "newValue": "$newValue"
    ''');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    if (kReleaseMode || EnvInfo.isProduction) return;
    log('''
      "provider": "\u0024${context.provider.name ?? context.provider.runtimeType}",
      "newValue": "disposed"
    ''');
    super.didDisposeProvider(context);
  }
}
