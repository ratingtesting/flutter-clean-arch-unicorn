import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_clean_arch_unicorn/services/security/secure_storage.dart';

void main() {
  group('SecureStorageFake', () {
    late SecureStorageFake storage;

    setUp(() {
      storage = SecureStorageFake();
    });

    test('write and read', () async {
      await storage.write('key1', 'value1');
      final result = await storage.read('key1');
      expect(result, equals('value1'));
    });

    test('read returns null for missing key', () async {
      final result = await storage.read('missing');
      expect(result, isNull);
    });

    test('delete removes key', () async {
      await storage.write('key1', 'value1');
      await storage.delete('key1');
      final result = await storage.read('key1');
      expect(result, isNull);
    });

    test('containsKey returns true for existing key', () async {
      await storage.write('key1', 'value1');
      expect(await storage.containsKey('key1'), isTrue);
    });

    test('containsKey returns false for missing key', () async {
      expect(await storage.containsKey('missing'), isFalse);
    });

    test('write overwrites existing value', () async {
      await storage.write('key1', 'value1');
      await storage.write('key1', 'value2');
      final result = await storage.read('key1');
      expect(result, equals('value2'));
    });

    test('SecureStorageKeys constants are defined', () {
      expect(SecureStorageKeys.authToken, isNotEmpty);
      expect(SecureStorageKeys.refreshToken, isNotEmpty);
      expect(SecureStorageKeys.userId, isNotEmpty);
      expect(SecureStorageKeys.privateKey, isNotEmpty);
    });
  });
}
