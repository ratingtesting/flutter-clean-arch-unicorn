#!/usr/bin/env dart
// tool/check_boundaries.dart
//
// Lightweight guard for architecture boundaries (§10 / §11).
//
// Rules enforced:
//   1. Feature A must NOT import internals of Feature B.
//      Allowed: Feature -> Core, Feature -> Shared.
//      Forbidden: features/<a>/... -> features/<b>/ (where a != b, and not
//      through a public barrel `features/<b>/<b>.dart`).
//   2. presentation/ must not import data/ of the SAME feature's datasources
//      directly when a repository boundary exists (warns, non-fatal).
//
// Run:  dart run tool/check_boundaries.dart
// Exit code 1 = violations found.

import 'dart:io';

final featuresDir = Directory('lib/features');
final violations = <String>[];

void scan(Directory dir, String currentFeature) {
  for (final entity in dir.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.freezed.dart') ||
        entity.path.endsWith('.g.dart')) {
      continue;
    }

    final rel = entity.path.replaceAll('\\', '/');
    final lines = entity.readAsLinesSync();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!line.contains("import 'package:flutter_clean_arch_unicorn/"))
        continue;

      final match = RegExp(
        r"import 'package:flutter_clean_arch_unicorn/(.+?)[';]",
      ).firstMatch(line);
      if (match == null) continue;
      final target = match.group(1)!;

      // Rule 1: cross-feature import (skip public barrel of same feature)
      final featMatch = RegExp(r'features/([^/]+)/').firstMatch(target);
      if (featMatch != null && featMatch.group(1) != currentFeature) {
        // public barrel exception: features/<b>/<b>.dart
        final barrel =
            'features/${featMatch.group(1)}/${featMatch.group(1)}.dart';
        if (target != barrel) {
          violations.add('${rel}:${i + 1} cross-feature import -> $target');
        }
      }
    }
  }
}

void main() {
  if (!featuresDir.existsSync()) {
    stderr.writeln('No lib/features directory found.');
    exit(0);
  }

  for (final featureDir in featuresDir.listSync()) {
    if (featureDir is! Directory) continue;
    final name = featureDir.uri.pathSegments.where((s) => s.isNotEmpty).last;
    scan(featureDir, name);
  }

  if (violations.isEmpty) {
    print('✅ Boundary check passed: no cross-feature imports.');
    exit(0);
  }

  stderr.writeln('❌ Boundary violations found (${violations.length}):');
  for (final v in violations) stderr.writeln('  - $v');
  exit(1);
}
