import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

base class Observers extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    log('''{
      "provider": "\u0024${context.provider.name ?? context.provider.runtimeType}",
      "newValue": "$newValue"
    }''');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    log('''{
      "provider": "\u0024${context.provider.name ?? context.provider.runtimeType}",
      "newValue": "disposed"
    }''');
    super.didDisposeProvider(context);
  }
}
