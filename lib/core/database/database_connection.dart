import 'dart:io';

import 'package:drift/native.dart';

import 'database.dart';

/// Opens an on-disk [AppDatabase] at [path].
///
/// Uses Drift's bundled `sqlite3` (v3.x) — no extra Flutter-specific native
/// package is needed. On mobile, the `sqlite3` package resolves the platform
/// library automatically.
AppDatabase connectOnDisk(String path) {
  return AppDatabase(NativeDatabase(File(path)));
}

/// Opens an in-memory [AppDatabase] — used by tests so nothing touches disk.
///
/// Each call returns a fresh, isolated database.
AppDatabase openTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}
