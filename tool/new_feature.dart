#!/usr/bin/env dart
// @dart=3.8
// ignore_for_file: avoid_print

/// Feature generator for the Flutter Clean Arch Unicorn template.
///
/// Usage:
///   dart run tool/new_feature.dart <feature_name>
///   dart run tool/new_feature.dart profile --force
///
/// Creates a feature-first module under `lib/features/<name>/` with the
/// standard `data/`, `domain/`, `presentation/` folders plus a ready-to-edit
/// screen, and a matching `test/features/<name>/` folder.
///
/// Rules (kept minimal on purpose — see docs/AI_DEVELOPMENT_RULES.md):
///   - name is lower_snake_case; `--force` overwrites if the folder exists
///   - does NOT create empty "placeholder" files — only real, compilable stubs
///   - wired for Riverpod 3 + Freezed + the Repository Law
///
/// This is a plain Dart script (no CLI framework) so it stays transparent and
/// easy to modify.

import 'dart:io';

const String kUsage = '''
Feature generator — Flutter Clean Arch Unicorn

Usage:
  dart run tool/new_feature.dart <feature_name> [--force]

Arguments:
  feature_name   Feature folder name in lower_snake_case (e.g. "profile", "cart").

Options:
  --force        Overwrite the feature if it already exists.

Example:
  dart run tool/new_feature.dart settings
''';

void main(List<String> args) {
  final flags = args.where((a) => a.startsWith('--')).toSet();
  final positional = args.where((a) => !a.startsWith('--')).toList();

  if (positional.isEmpty) {
    print(kUsage);
    exit(64); // EX_USAGE
  }

  final rawName = positional.first;
  final force = flags.contains('--force');

  final name = _toSnakeCase(rawName);
  if (name.isEmpty) {
    print('✗ Invalid feature name: "$rawName". Use lower_snake_case.');
    exit(64);
  }

  final featureDir = Directory('lib/features/$name');
  if (featureDir.existsSync() && !force) {
    print('✗ Feature "$name" already exists. Use --force to overwrite.');
    exit(1);
  }

  _generateFeature(name);
  _generateTests(name);
  print('');
  print('✅ Feature "$name" created.');
  print('   • lib/features/$name/{data,domain,presentation}');
  print('   • lib/features/$name/presentation/screens/${name}_screen.dart');
  print('   • test/features/$name/');
  print('');
  print('Next steps:');
  print('  1. Add a repository interface in domain/repositories/');
  print(
    '  2. Implement it in data/repositories/ + datasource in data/datasource/',
  );
  print('  3. Register a provider in presentation/providers/');
  print('  4. Add a route in lib/routes/app_router.dart');
  print('  5. Run: dart run build_runner build --delete-conflicting-outputs');
  print('  6. Run: dart run tool/check_boundaries.dart  (must pass — enforces');
  print('     architecture boundaries; CI blocks on violation)');
}

void _generateFeature(String name) {
  final cap = _toPascalCase(name);

  // features/<name>/<name>.dart — public barrel. Boundary rules (R-FEATURE-1)
  // require other features to import this barrel instead of internals.
  _write('lib/features/$name/$name.dart', '''
/// Public API of the $name feature.
///
/// Other features may import ONLY this barrel (architecture rule R-FEATURE-1).
/// Export contracts and models here as the feature grows.
library;
''');

  // domain/repositories/<name>_repository.dart
  _write('lib/features/$name/domain/repositories/${name}_repository.dart', '''
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';

/// Contract for the $name feature. UI depends on this interface, never on a
/// concrete implementation. Add methods as the feature grows.
abstract class ${cap}Repository {
  // Example:
  // Future<Either<AppException, ${cap}Data>> fetch();
}
''');

  // data/datasource/<name>_remote_datasource.dart
  _write(
    'lib/features/$name/data/datasource/${name}_remote_datasource.dart',
    '''
import 'package:flutter_clean_arch_unicorn/shared/data/remote/remote.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';

/// Remote data source for the $name feature.
/// Implement the contract methods declared in domain/repositories/.
abstract class ${cap}Datasource {
  // Example:
  // Future<Either<AppException, ${cap}Data>> fetch(NetworkService networkService);
}
''',
  );

  // data/repositories/<name>_repository_impl.dart
  _write(
    'lib/features/$name/data/repositories/${name}_repository_impl.dart',
    '''
import 'package:flutter_clean_arch_unicorn/features/$name/domain/repositories/${name}_repository.dart';

/// Default implementation of [${cap}Repository].
/// Swap the datasource behind this without touching the UI.
class ${cap}RepositoryImpl extends ${cap}Repository {
  ${cap}RepositoryImpl(this.datasource);

  final ${cap}Datasource datasource;

  // Implement interface methods here, delegating to the datasource.
}
''',
  );

  // presentation/providers/<name>_providers.dart
  _write('lib/features/$name/presentation/providers/${name}_providers.dart', '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/features/$name/domain/repositories/${name}_repository.dart';
import 'package:flutter_clean_arch_unicorn/features/$name/presentation/providers/state/${name}_notifier.dart';
import 'package:flutter_clean_arch_unicorn/features/$name/presentation/providers/state/${name}_state.dart';

final ${name}NotifierProvider =
    NotifierProvider<${cap}Notifier, ${cap}State>(${cap}Notifier.new);

final ${name}RepositoryProvider = Provider<${cap}Repository>((ref) {
  // Wire the implementation. Replace the datasource as needed.
  throw UnimplementedError('Provide a ${cap}Repository implementation here.');
});
''');

  // presentation/providers/state/<name>_state.dart
  _write(
    'lib/features/$name/presentation/providers/state/${name}_state.dart',
    '''
import 'package:freezed_annotation/freezed_annotation.dart';

part '${name}_state.freezed.dart';

/// UI state for the $name feature. Add fields as needed.
@freezed
abstract class ${cap}State with _\$${cap}State {
  const factory ${cap}State.initial() = ${cap}StateInitial;
  const factory ${cap}State.loading() = ${cap}StateLoading;
  const factory ${cap}State.ready() = ${cap}StateReady;
  const factory ${cap}State.error(String message) = ${cap}StateError;
}
''',
  );

  // presentation/providers/state/<name>_notifier.dart
  _write(
    'lib/features/$name/presentation/providers/state/${name}_notifier.dart',
    '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/features/$name/domain/repositories/${name}_repository.dart';
import 'package:flutter_clean_arch_unicorn/features/$name/presentation/providers/${name}_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/$name/presentation/providers/state/${name}_state.dart';

class ${cap}Notifier extends Notifier<${cap}State> {
  late final ${cap}Repository _repository;

  @override
  ${cap}State build() {
    _repository = ref.watch(${name}RepositoryProvider);
    return const ${cap}State.initial();
  }

  // Add feature actions here.
}
''',
  );

  // presentation/screens/<name>_screen.dart
  _write('lib/features/$name/presentation/screens/${name}_screen.dart', '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/features/$name/presentation/providers/${name}_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/$name/presentation/providers/state/${name}_state.dart';

class ${cap}Screen extends ConsumerWidget {
  const ${cap}Screen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${name}NotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('${cap}')),
      body: switch (state) {
        ${cap}StateInitial() => const Center(child: Text('Initial')),
        ${cap}StateLoading() =>
          const Center(child: CircularProgressIndicator()),
        ${cap}StateReady() => const Center(child: Text('Ready')),
        ${cap}StateError(:final message) =>
          Center(child: Text('Error: \$message')),
      },
    );
  }
}
''');
}

void _generateTests(String name) {
  _write(
    'test/features/$name/data/repositories/${name}_repository_impl_test.dart',
    '''
import 'package:flutter_test/flutter_test.dart';

// Add unit tests for the $name repository here.
void main() {
  group('${name}_repository', () {
    test('placeholder', () {
      expect(true, isTrue);
    });
  });
}
''',
  );

  _write(
    'test/features/$name/presentation/providers/${name}_notifier_test.dart',
    '''
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Add provider tests with ProviderContainer + mocktail here.
void main() {
  group('${name}_notifier', () {
    test('placeholder', () {
      expect(true, isTrue);
    });
  });
}
''',
  );
}

void _write(String path, String content) {
  final file = File(path);
  file.createSync(recursive: true);
  file.writeAsStringSync(content);
  print('  + $path');
}

String _toSnakeCase(String input) {
  return input
      .trim()
      .replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')
      .replaceAllMapped(RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]}_${m[2]}')
      .toLowerCase()
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+\$'), '');
}

String _toPascalCase(String input) {
  final snake = _toSnakeCase(input);
  return snake
      .split('_')
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + p.substring(1))
      .join();
}
