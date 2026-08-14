import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/datasource/user_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/domain/repositories/user_cache_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/domain/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/dummy_data.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ktestUser);
  });

  group('UserRepository contract', () {
    late UserDataSource datasource;
    late UserRepository repository;

    setUp(() {
      datasource = MockUserDataSource();
      repository = _FakeRepository(datasource);
    });

    test('fetchUser returns Right(user)', () async {
      when(
        () => datasource.fetchUser(),
      ).thenAnswer((_) async => Right(ktestUser));
      final result = await repository.fetchUser();
      expect(result.isRight(), isTrue);
    });

    test('saveUser returns true', () async {
      when(
        () => datasource.saveUser(user: any(named: 'user')),
      ).thenAnswer((_) async => true);
      expect(await repository.saveUser(user: ktestUser), isTrue);
    });

    test('deleteUser returns true', () async {
      when(() => datasource.deleteUser()).thenAnswer((_) async => true);
      expect(await repository.deleteUser(), isTrue);
    });

    test('hasUser returns false when empty', () async {
      when(() => datasource.hasUser()).thenAnswer((_) async => false);
      expect(await repository.hasUser(), isFalse);
    });
  });
}

class MockUserDataSource extends Mock implements UserDataSource {}

class _FakeRepository extends UserRepository {
  _FakeRepository(this._datasource);
  final UserDataSource _datasource;

  @override
  Future<bool> deleteUser() => _datasource.deleteUser();

  @override
  Future<Either<AppException, User>> fetchUser() => _datasource.fetchUser();

  @override
  Future<bool> hasUser() => _datasource.hasUser();

  @override
  Future<bool> saveUser({required User user}) =>
      _datasource.saveUser(user: user);
}
