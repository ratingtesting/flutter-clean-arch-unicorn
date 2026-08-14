import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/datasource/user_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/repositories/user_repository_impl.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/domain/repositories/user_cache_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/dummy_data.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(ktestUser);
  });

  late UserDataSource datasource;
  late UserRepository repository;

  setUp(() {
    datasource = MockUserDataSource();
    repository = UserRepositoryImpl(datasource);
  });

  test('saveUser delegates to datasource', () async {
    when(() => datasource.saveUser(user: any(named: 'user')))
        .thenAnswer((_) async => true);
    expect(await repository.saveUser(user: ktestUser), isTrue);
  });

  test('fetchUser returns user from datasource', () async {
    when(() => datasource.fetchUser())
        .thenAnswer((_) async => Right(ktestUser));
    final result = await repository.fetchUser();
    expect(result.isRight(), isTrue);
  });

  test('deleteUser delegates to datasource', () async {
    when(() => datasource.deleteUser()).thenAnswer((_) async => true);
    expect(await repository.deleteUser(), isTrue);
  });

  test('hasUser delegates to datasource', () async {
    when(() => datasource.hasUser()).thenAnswer((_) async => false);
    expect(await repository.hasUser(), isFalse);
  });
}

class MockUserDataSource extends Mock implements UserDataSource {}
