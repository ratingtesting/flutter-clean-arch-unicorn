import 'dart:async';

import 'package:flutter_clean_arch_unicorn/shared/data/local/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService implements StorageService {
  SharedPreferences? sharedPreferences;

  final Completer<SharedPreferences> initCompleter =
      Completer<SharedPreferences>();

  @override
  void init() {
    initCompleter.complete(SharedPreferences.getInstance());
  }

  @override
  bool get hasInitialized => sharedPreferences != null;

  @override
  Future<Object?> get(String key) async {
    sharedPreferences = await initCompleter.future;
    return sharedPreferences!.get(key);
  }

  @override
  Future<void> clear() async {
    sharedPreferences = await initCompleter.future;
    await sharedPreferences!.clear();
  }

  @override
  Future<bool> has(String key) async {
    sharedPreferences = await initCompleter.future;
    return sharedPreferences?.containsKey(key) ?? false;
  }

  @override
  Future<bool> remove(String key) async {
    sharedPreferences = await initCompleter.future;
    return await sharedPreferences!.remove(key);
  }

  @override
  Future<bool> set(String key, data) async {
    sharedPreferences = await initCompleter.future;
    return await sharedPreferences!.setString(key, data.toString());
  }

  /// Get a Map value from SharedPreferences
  Future<Map<String, dynamic>?> getMap(String key) async {
    sharedPreferences = await initCompleter.future;
    final value = sharedPreferences!.getString(key);
    if (value == null) return null;
    return Map<String, dynamic>.from(value as Map);
  }

  /// Set a Map value to SharedPreferences
  Future<bool> setMap(String key, Map<String, dynamic> value) async {
    sharedPreferences = await initCompleter.future;
    return await sharedPreferences!.setString(key, value.toString());
  }

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    sharedPreferences = await initCompleter.future;
    return sharedPreferences?.containsKey(key) ?? false;
  }
}
