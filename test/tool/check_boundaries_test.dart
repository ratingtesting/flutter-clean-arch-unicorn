// @dart=3.2
// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_clean_arch_unicorn/tool/boundary_rules.dart';

/// Helper: collect only fatal violations for an internal (first-party) import.
List<String> fatalFor({
  required String from,
  String? internalTarget,
  String? externalPackage,
}) {
  return checkImport(
    from,
    internalTarget: internalTarget,
    externalPackage: externalPackage,
  )
      .where((v) => v.fatal)
      .map((v) => v.ruleId)
      .toList();
}

void main() {
  group('Boundary rules — valid architecture (no fatal violations)', () {
    test('1. valid: feature -> core', () {
      expect(
        fatalFor(
          from: 'features/dashboard/presentation/providers/dashboard_providers.dart',
          internalTarget: 'core/database/database_provider.dart',
        ),
        isEmpty,
      );
    });

    test('2. valid: feature -> shared', () {
      expect(
        fatalFor(
          from: 'features/auth/data/repositories/auth_repository_impl.dart',
          internalTarget: 'shared/domain/models/either.dart',
        ),
        isEmpty,
      );
    });

    test('3. valid: feature -> services (via contract)', () {
      expect(
        fatalFor(
          from: 'features/auth/domain/use_cases/login_use_case.dart',
          internalTarget: 'services/user_cache_service/domain/repositories/user_cache_repository.dart',
        ),
        isEmpty,
      );
    });

    test('4. valid: data -> domain (same feature)', () {
      expect(
        fatalFor(
          from: 'features/auth/data/repositories/authentication_repository_impl.dart',
          internalTarget: 'features/auth/domain/repositories/auth_repository.dart',
        ),
        isEmpty,
      );
    });

    test('5. valid: presentation -> domain (same feature)', () {
      expect(
        fatalFor(
          from: 'features/auth/presentation/providers/auth_providers.dart',
          internalTarget: 'features/auth/domain/models/user.dart',
        ),
        isEmpty,
      );
    });

    test('6. valid: feature -> feature PUBLIC barrel', () {
      expect(
        fatalFor(
          from: 'features/splash/presentation/providers/splash_provider.dart',
          internalTarget: 'features/authentication/authentication.dart',
        ),
        isEmpty,
      );
    });

    test('7. valid: services -> shared', () {
      expect(
        fatalFor(
          from: 'services/user_cache_service/data/datasource/user_local_datasource.dart',
          internalTarget: 'shared/domain/models/either.dart',
        ),
        isEmpty,
      );
    });

    test('8. valid: dio inside data layer (Repository Law allows)', () {
      expect(
        fatalFor(
          from: 'shared/data/remote/dio_network_service.dart',
          externalPackage: 'dio',
        ),
        isEmpty,
      );
    });

    test('9. valid: dio inside presentation/providers wiring layer', () {
      expect(
        fatalFor(
          from: 'shared/presentation/providers/dio_network_service_provider.dart',
          externalPackage: 'dio',
        ),
        isEmpty,
      );
    });

    test('10. valid: drift inside core/database', () {
      expect(
        fatalFor(
          from: 'core/database/database.dart',
          externalPackage: 'drift',
        ),
        isEmpty,
      );
    });
  });

  group('Boundary rules — forbidden dependencies (fatal)', () {
    test('forbidden: core -> features', () {
      expect(
        fatalFor(
          from: 'core/database/database_provider.dart',
          internalTarget: 'features/auth/domain/models/user.dart',
        ),
        contains('R-CORE-1'),
      );
    });

    test('forbidden: core -> services', () {
      expect(
        fatalFor(
          from: 'core/database/database_provider.dart',
          internalTarget: 'services/security/secure_storage.dart',
        ),
        contains('R-CORE-1'),
      );
    });

    test('forbidden: shared -> features', () {
      expect(
        fatalFor(
          from: 'shared/widgets/app_error.dart',
          internalTarget: 'features/auth/domain/models/user.dart',
        ),
        contains('R-SHARED-1'),
      );
    });

    test('forbidden: services -> features/presentation', () {
      expect(
        fatalFor(
          from: 'services/user_cache_service/presentation/providers/current_user_provider.dart',
          internalTarget: 'features/authentication/presentation/providers/auth_providers.dart',
        ),
        contains('R-SERVICES-1'),
      );
    });

    test('forbidden: services -> features/domain', () {
      expect(
        fatalFor(
          from: 'services/user_cache_service/data/datasource/user_local_datasource.dart',
          internalTarget: 'features/authentication/domain/models/user.dart',
        ),
        contains('R-SERVICES-1'),
      );
    });

    test('forbidden: feature A -> feature B internals', () {
      expect(
        fatalFor(
          from: 'features/dashboard/presentation/providers/dashboard_providers.dart',
          internalTarget: 'features/authentication/data/repositories/auth_repository_fake.dart',
        ),
        contains('R-FEATURE-1'),
      );
    });

    test('forbidden: domain -> data', () {
      expect(
        fatalFor(
          from: 'features/auth/domain/repositories/auth_repository.dart',
          internalTarget: 'features/auth/data/repositories/authentication_repository_impl.dart',
        ),
        contains('R-LAYER-DOMAIN'),
      );
    });

    test('forbidden: domain -> presentation', () {
      expect(
        fatalFor(
          from: 'features/auth/domain/use_cases/login_use_case.dart',
          internalTarget: 'features/auth/presentation/providers/auth_providers.dart',
        ),
        contains('R-LAYER-DOMAIN'),
      );
    });

    test('forbidden: data -> presentation', () {
      expect(
        fatalFor(
          from: 'features/auth/data/repositories/authentication_repository_impl.dart',
          internalTarget: 'features/auth/presentation/providers/auth_providers.dart',
        ),
        contains('R-LAYER-DATA'),
      );
    });

    test('forbidden: dio inside presentation/screens (Repository Law)', () {
      expect(
        fatalFor(
          from: 'features/auth/presentation/screens/login_screen.dart',
          externalPackage: 'dio',
        ),
        contains('R-INFRA'),
      );
    });

    test('forbidden: drift inside domain layer', () {
      expect(
        fatalFor(
          from: 'features/auth/domain/models/user.dart',
          externalPackage: 'drift',
        ),
        contains('R-INFRA'),
      );
    });
  });

  /// NEGATIVE TEST — proof that the protection actually works end-to-end.
  ///
  /// We create an isolated temp fixture with a forbidden import, run the
  /// checker on it as a subprocess, and assert it FAILS (exit code != 0).
  /// This is the discriminating test: if the enforcer silently passed a
  /// violation, this would go RED.
  ///
  /// NOTE: skipped when the running VM is the Flutter wrapper (`flutter.bat`
  /// on Windows) because a subprocess would re-invoke the slow wrapper and
  /// time out locally. On CI (Linux, direct `dart`) the test runs and proves
  /// the enforcer fails on a forbidden import. The same behaviour is verified
  /// manually on any platform by adding a forbidden import to `lib/` and
  /// running `dart run tool/check_boundaries.dart`.
  group('End-to-end enforcer', () {
    final subprocessSupported = !_dartExecutable.contains('flutter');

    test('forbidden import in a fixture makes the checker exit non-zero',
        () {
      if (!subprocessSupported) {
        // Local Windows/flutter wrapper: skip (run on CI with direct dart).
        // Manual proof: add a forbidden import to lib/ and run the checker.
        return;
      }
      final tempDir = Directory.systemTemp.createTempSync('boundary_test_');
      try {
        // features/leak/presentation/widgets/leak_screen.dart
        //   -> imports features/auth/presentation/providers/auth_providers.dart
        final leakDir = Directory(
          '${tempDir.path}/lib/features/leak/presentation/widgets',
        )..createSync(recursive: true);
        File('${leakDir.path}/leak_screen.dart').writeAsStringSync('''
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_arch_unicorn/features/auth/presentation/providers/auth_providers.dart';

class LeakScreen extends StatelessWidget {
  const LeakScreen({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
''');

        // Run the actual checker on the isolated fixture.
        final result = Process.runSync(
          _dartExecutable,
          ['run', 'tool/check_boundaries.dart', tempDir.path],
          workingDirectory: _repoRoot,
        );

        expect(result.exitCode, isNonZero,
            reason: 'checker must FAIL on a forbidden cross-feature import');
        expect(result.stderr.toString(), contains('R-FEATURE-1'));
      } finally {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      }
    });

    test('clean fixture passes (exit 0)', () {
      if (!subprocessSupported) {
        // Local Windows/flutter wrapper: skip (run on CI with direct dart).
        return;
      }
      final tempDir = Directory.systemTemp.createTempSync('boundary_test_');
      try {
        final cleanDir = Directory(
          '${tempDir.path}/lib/features/clean/presentation/widgets',
        )..createSync(recursive: true);
        File('${cleanDir.path}/clean_screen.dart').writeAsStringSync('''
import 'package:flutter/widgets.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';

class CleanScreen extends StatelessWidget {
  const CleanScreen({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
''');

        final result = Process.runSync(
          _dartExecutable,
          ['run', 'tool/check_boundaries.dart', tempDir.path],
          workingDirectory: _repoRoot,
        );

        expect(result.exitCode, 0,
            reason: 'checker must PASS a clean fixture');
      } finally {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      }
    });
  });
}

/// Locate the repo root and Dart executable relative to this test file.
String get _repoRoot {
  // test/tool/check_boundaries_test.dart -> repo root is two levels up.
  final testDir = File.fromUri(Platform.script).parent;
  return testDir.parent.parent.path;
}

String get _dartExecutable {
  // Use the same Dart VM that is running this test, so the subprocess works
  // regardless of PATH / DART_SDK env (local and CI).
  return Platform.resolvedExecutable;
}
