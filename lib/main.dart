import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_clean_arch_unicorn/core/database/database_provider.dart';
import 'package:flutter_clean_arch_unicorn/main/app.dart';
import 'package:flutter_clean_arch_unicorn/main/app_env.dart';
import 'package:flutter_clean_arch_unicorn/main/observers.dart'
    as main_observers;
import 'package:flutter_clean_arch_unicorn/services/feature_flags.dart';
import 'package:flutter_clean_arch_unicorn/services/observability/error_reporter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => mainCommon(AppEnvironment.DEV);

Future<void> mainCommon(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error reporting (no-op by default, replace with Crashlytics in prod)
  final errorReporter = NoopCrashReportingService();
  await errorReporter.initialize();

  // Initialize feature flags (static by default, replace with RemoteConfig in prod)
  final featureFlags = StaticFeatureFlags({});
  await featureFlags.initialize();

  EnvInfo.initialize(environment);

  // Open the local Drift database (on-disk). Override `appDatabaseProvider`
  // with `openTestDatabase()` in widget/integration tests.
  final appDatabase = await openAppDatabase();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(appDatabase)],
      observers: [main_observers.Observers()],
      child: const MyApp(),
    ),
  );
}
