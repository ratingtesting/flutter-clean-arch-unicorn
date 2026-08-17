#!/usr/bin/env dart
// @dart=3.2
// ignore_for_file: avoid_print

// tool/check_boundaries.dart
//
// Architecture boundary enforcer for the Flutter Clean Arch Unicorn template.
//
// Scans every Dart file under the target root (default: `lib/`) and reports
// forbidden cross-module / cross-layer dependencies using the rules declared
// in `tool/boundary_rules.dart` (the single source of truth).
//
// Run:
//   dart run tool/check_boundaries.dart            # scan lib/
//   dart run tool/check_boundaries.dart <dir>      # scan an isolated fixture
//
// Exit code 0 = no fatal violations; 1 = at least one fatal violation.
// A non-fatal (warning) violation is printed but does NOT fail the run.
//
// The rule logic lives in `boundary_rules.dart` so it can be unit-tested
// directly without launching a subprocess.

import 'dart:io';

import 'package:flutter_clean_arch_unicorn/tool/boundary_rules.dart';

/// Package prefix that all first-party imports share.
const _pkgPrefix = "package:flutter_clean_arch_unicorn/";

/// Entry point. Accepts an optional scan root (defaults to `lib`).
void main(List<String> args) {
  final root = args.isNotEmpty ? args[0] : 'lib';
  final rootDir = Directory(root);
  if (!rootDir.existsSync()) {
    stderr.writeln('No directory found at "$root".');
    exit(0);
  }

  final violations = <BoundaryViolation>[];
  final scanned = _scan(rootDir, violations);

  if (violations.isEmpty) {
    print('✅ Boundary check passed: '
        'no architectural violations in $scanned file(s).');
    exit(0);
  }

  final fatal =
      violations.where((v) => v.fatal).toList(growable: false);
  final warnings =
      violations.where((v) => !v.fatal).toList(growable: false);

  for (final v in warnings) {
    stderr.writeln('⚠️  WARNING: $v');
  }
  if (fatal.isNotEmpty) {
    stderr.writeln(
        '❌ Boundary violations found (${fatal.length} fatal, '
        '${warnings.length} warning):');
    for (final v in fatal) {
      stderr.writeln('  - $v');
    }
    exit(1);
  }

  // Only warnings: still a pass.
  print('✅ Boundary check passed (warnings only) in $scanned file(s).');
  exit(0);
}

/// Recursively scan [root]; collect violations. Returns file count scanned.
int _scan(Directory root, List<BoundaryViolation> out) {
  var count = 0;
  for (final entity
      in root.listSync(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart')) continue;
    if (entity.path.endsWith('.freezed.dart') ||
        entity.path.endsWith('.g.dart')) {
      continue;
    }

    count++;
    final rel = _libRelative(root.path, entity.path);
    _checkFile(rel, entity.readAsLinesSync(), out);
  }
  return count;
}

/// Convert an absolute file path to a lib-relative path (forward slashes),
/// computed against [rootPath], then normalised to the `lib/` convention.
String _libRelative(String rootPath, String filePath) {
  final root = rootPath.replaceAll('\\', '/').replaceAll(r'\', '/');
  final file = filePath.replaceAll('\\', '/');
  final rel = file.startsWith(root)
      ? file.substring(root.length).replaceAll(RegExp(r'^/'), '')
      : file;
  // Treat the scan root as the source of truth: the path segments after the
  // root are the lib-relative coordinates the rules operate on.
  return rel;
}

/// Parse one file's imports and accumulate violations.
void _checkFile(
  String relPath,
  List<String> lines,
  List<BoundaryViolation> out,
) {
  // Directory of the importing file (for resolving relative imports),
  // split into segments and stripped of the leading root marker.
  final fromDirSegments =
      relPath.split('/')..removeLast();

  for (final line in lines) {
    if (!line.trim().startsWith("import ")) continue;

    // package: first-party import
    if (line.contains(_pkgPrefix)) {
      final target = line
          .substring(line.indexOf(_pkgPrefix) + _pkgPrefix.length);
      final cut = RegExp(r"[';]").firstMatch(target)?.start ?? target.length;
      final internal = target.substring(0, cut);
      out.addAll(checkImport(relPath, internalTarget: internal));
      continue;
    }

    // external package import (e.g. dio / drift) — for Repository Law
    final ext = RegExp(
      r"import 'package:([a-z0-9_]+)/",
    ).firstMatch(line);
    if (ext != null) {
      out.addAll(checkImport(relPath, externalPackage: ext.group(1)));
      continue;
    }

    // relative import: ../features/... or ./data/...
    final rel = RegExp(r"import '(\.\.?/[^']*)'").firstMatch(line);
    if (rel != null) {
      final resolved = _resolveRelative(fromDirSegments, rel.group(1)!);
      if (resolved != null) {
        out.addAll(checkImport(relPath, internalTarget: resolved));
      }
    }
  }
}

/// Resolve a relative import path (may contain ../) against the importing
/// file's directory segments. Returns a lib-relative target, or null if it
/// escapes the known tree (treated as benign).
String? _resolveRelative(List<String> fromDir, String relative) {
  final segs = [...fromDir];
  final parts = relative.split('/');
  for (final p in parts) {
    if (p == '..') {
      if (segs.isEmpty) return null;
      segs.removeLast();
    } else if (p == '.') {
      // no-op
    } else {
      segs.add(p);
    }
  }
  return segs.join('/');
}
