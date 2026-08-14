import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_clean_arch_unicorn/services/feature_flags.dart';

void main() {
  group('StaticFeatureFlags', () {
    late StaticFeatureFlags flags;

    setUp(() {
      flags = StaticFeatureFlags({
        'new_checkout_flow': true,
        'dark_mode_enabled': false,
        'max_upload_size_mb': 50,
        'api_version': '2.1.0',
      });
    });

    test('isEnabled returns true for enabled flag', () {
      expect(flags.isEnabled('new_checkout_flow'), isTrue);
    });

    test('isEnabled returns false for disabled flag', () {
      expect(flags.isEnabled('dark_mode_enabled'), isFalse);
    });

    test('isEnabled returns defaultValue for missing flag', () {
      expect(flags.isEnabled('unknown_flag'), isFalse);
      expect(flags.isEnabled('unknown_flag', defaultValue: true), isTrue);
    });

    test('getString returns value for string flag', () {
      expect(flags.getString('api_version'), equals('2.1.0'));
    });

    test('getString returns defaultValue for missing flag', () {
      expect(flags.getString('unknown'), equals(''));
      expect(
        flags.getString('unknown', defaultValue: 'fallback'),
        equals('fallback'),
      );
    });

    test('getInt returns value for int flag', () {
      expect(flags.getInt('max_upload_size_mb'), equals(50));
    });

    test('getInt returns defaultValue for missing flag', () {
      expect(flags.getInt('unknown'), equals(0));
    });

    test('initialize completes without error', () async {
      await expectLater(flags.initialize(), completes);
    });
  });
}
