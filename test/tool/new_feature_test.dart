import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// End-to-end test for the feature generator (`tool/new_feature.dart`).
///
/// Runs the generator against a temporary copy of the repo layout and asserts
/// the expected files are produced and are non-empty.
void main() {
  test(
    'new_feature.dart scaffolds a feature-first module',
    () async {
      // Run from the repo root so `lib/features` resolves.
      final root = _repoRoot();
      final result = await Process.run(
        'dart',
        ['run', 'tool/new_feature.dart', 'demo_widget', '--force'],
        workingDirectory: root,
        runInShell: true,
      );

      expect(
        result.exitCode,
        0,
        reason: 'generator failed:\n${result.stdout}\n${result.stderr}',
      );

      final base = p.join(root, 'lib', 'features', 'demo_widget');
      final expected = [
        p.join(base, 'domain', 'repositories', 'demo_widget_repository.dart'),
        p.join(
          base,
          'data',
          'datasource',
          'demo_widget_remote_datasource.dart',
        ),
        p.join(
          base,
          'data',
          'repositories',
          'demo_widget_repository_impl.dart',
        ),
        p.join(base, 'presentation', 'providers', 'demo_widget_providers.dart'),
        p.join(
          base,
          'presentation',
          'providers',
          'state',
          'demo_widget_state.dart',
        ),
        p.join(
          base,
          'presentation',
          'providers',
          'state',
          'demo_widget_notifier.dart',
        ),
        p.join(base, 'presentation', 'screens', 'demo_widget_screen.dart'),
        p.join(
          root,
          'test',
          'features',
          'demo_widget',
          'data',
          'repositories',
          'demo_widget_repository_impl_test.dart',
        ),
        p.join(
          root,
          'test',
          'features',
          'demo_widget',
          'presentation',
          'providers',
          'demo_widget_notifier_test.dart',
        ),
      ];

      for (final f in expected) {
        final file = File(f);
        expect(file.existsSync(), isTrue, reason: 'missing $f');
        expect(
          file.readAsStringSync().trim().isNotEmpty,
          isTrue,
          reason: 'empty $f',
        );
      }

      // Clean up generated artifacts so they don't pollute the repo.
      final libFeature = Directory(
        p.join(root, 'lib', 'features', 'demo_widget'),
      );
      if (libFeature.existsSync()) await libFeature.delete(recursive: true);
      final testFeature = Directory(
        p.join(root, 'test', 'features', 'demo_widget'),
      );
      if (testFeature.existsSync()) await testFeature.delete(recursive: true);
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

String _repoRoot() {
  // tool/ lives at <root>/tool, so if it exists here we are at the root.
  if (Directory('tool').existsSync()) return Directory.current.path;
  // Fallback: walk up from this test file.
  var dir = p.dirname(File(Platform.script.toFilePath()).path);
  while (!File(p.join(dir, 'pubspec.yaml')).existsSync()) {
    final parent = p.dirname(dir);
    if (parent == dir) break;
    dir = parent;
  }
  return dir;
}
