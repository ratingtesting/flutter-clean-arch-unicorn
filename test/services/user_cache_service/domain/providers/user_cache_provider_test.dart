// ignore_for_file: avoid_dynamic_calls
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/datasource/user_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/domain/repositories/user_cache_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/presentation/providers/user_cache_provider.dart'
    as ucp;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/dummy_data.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ktestUser);
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  group('User cache providers', () {
    test('userLocalRepositoryProvider resolves a UserRepository', () {
      final container = ProviderContainer();
      // Shared prefs + secure storage providers are real here; this just
      // verifies the wiring does not throw and yields the right type.
      expect(
        container.read(ucp.userLocalRepositoryProvider),
        isA<UserRepository>(),
      );
      addTearDown(container.dispose);
    });

    test('repository delegates through the datasource (override)', () async {
      final datasource = MockUserDataSource();
      when(
        () => datasource.fetchUser(),
      ).thenAnswer((_) async => Right(ktestUser));

      final container = ProviderContainer(
        overrides: [ucp.userDatasourceProvider.overrideWithValue(datasource)],
      );
      final repo = container.read(ucp.userLocalRepositoryProvider);
      final result = await repo.fetchUser();
      expect(result.isRight(), isTrue);
      addTearDown(container.dispose);
    });
  });
}

class MockUserDataSource extends Mock implements UserDataSource {}
