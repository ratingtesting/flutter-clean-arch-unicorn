import 'package:flutter_clean_arch_unicorn/services/user_cache_service/data/datasource/user_local_datasource.dart';
import 'package:flutter_clean_arch_unicorn/shared/data/local/shared_prefs_storage_service.dart';
import 'package:flutter_clean_arch_unicorn/services/security/secure_storage.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/user/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/data/user_map.dart';
import '../../../../fixtures/dummy_data.dart';

void main() {
  late SharedPrefsService storageService;
  late SecureStorage secureStorage;
  late UserDataSource userDataSource;

  setUpAll(() {
    storageService = MockSharedPrefsService();
    secureStorage = MockSecureStorage();
    userDataSource = UserLocalDataSource(storageService, secureStorage);
  });

  setUp(() {
    reset(storageService);
    reset(secureStorage);
  });

  test('Should return valid User model when user was found', () async {
    // arrange
    when(
      () => storageService.getMap(any()),
    ).thenAnswer((invocation) async => ktestUserMap);
    when(
      () => secureStorage.read(any()),
    ).thenAnswer((invocation) async => 'test_token');
    // act
    final data = await userDataSource.fetchUser();

    //assert
    expect(data.isRight(), true);
    final user = data.fold((l) => throw Exception('No user'), (r) => r);
    expect(user, isA<User>());
    expect(user.token, 'test_token');
  });
  test('Should return AppException when user was not found', () async {
    // arrange
    when(
      () => storageService.getMap(any()),
    ).thenAnswer((invocation) async => null);

    // act
    final data = await userDataSource.fetchUser();

    //assert
    expect(data.isLeft(), true);
  });
  test('Should return true when user is saved', () async {
    // arrange
    when(
      () => storageService.setMap(any(), any()),
    ).thenAnswer((invocation) async => true);
    when(() => secureStorage.write(any(), any())).thenAnswer((_) async {});

    // act
    final data = await userDataSource.saveUser(user: ktestUser);

    //assert
    expect(data, true);
  });
  test(
    'Should return false when user is not saved (exception thrown)',
    () async {
      // arrange
      when(
        () => storageService.setMap(any(), any()),
      ).thenThrow(Exception('Storage error'));

      // act
      final data = await userDataSource.saveUser(user: ktestUser);

      //assert
      expect(data, false);
    },
  );
  test('Should return true when user is deleted', () async {
    // arrange
    when(
      () => storageService.remove(any()),
    ).thenAnswer((invocation) async => true);
    when(() => secureStorage.delete(any())).thenAnswer((_) async {});

    // act
    final data = await userDataSource.deleteUser();

    //assert
    expect(data, true);
  });
  test(
    'Should return false when user is not deleted (exception thrown)',
    () async {
      // arrange
      when(
        () => storageService.remove(any()),
      ).thenThrow(Exception('Storage error'));

      // act
      final data = await userDataSource.deleteUser();

      //assert
      expect(data, false);
    },
  );
  test('Should check if user is saved', () async {
    // arrange
    when(
      () => storageService.containsKey(any()),
    ).thenAnswer((invocation) async => false);

    // act
    final data = await userDataSource.hasUser();

    //assert
    expect(data, false);

    when(
      () => storageService.containsKey(any()),
    ).thenAnswer((invocation) async => true);

    // act
    final data2 = await userDataSource.hasUser();

    //assert
    expect(data2, true);
  });
}

class MockSharedPrefsService extends Mock implements SharedPrefsService {}

class MockSecureStorage extends Mock implements SecureStorage {}
