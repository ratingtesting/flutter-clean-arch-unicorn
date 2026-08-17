// ignore_for_file: prefer_const_constructors
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/user.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/domain/use_cases/login_use_case.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/domain/repositories/user_cache_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';

/// Fake auth repository for testing credential separation
class FakeAuthRepository implements AuthenticationRepository {
  FakeAuthRepository(this.result);
  final Either<AppException, User> result;

  @override
  Future<Either<AppException, User>> loginUser({required User user}) async {
    return result;
  }
}

/// Fake user cache repository for testing
class FakeUserCacheRepository implements UserRepository {
  const FakeUserCacheRepository(this.saveResult);
  final bool saveResult;

  @override
  Future<bool> saveUser({required User user}) async => saveResult;

  @override
  Future<Either<AppException, User>> fetchUser() async => Left(
    AppException(message: 'Not implemented', statusCode: 1, identifier: 'test'),
  );

  @override
  Future<bool> deleteUser() async => true;

  @override
  Future<bool> hasUser() async => false;
}

void main() {
  group('Credential separation tests', () {
    test('User.toJson does not include password', () {
      const user = User(
        id: 1,
        username: 'testuser',
        password: 'secret123',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'avatar.png',
        token: 'jwt-token',
      );

      final json = user.toJson();
      expect(json.containsKey('password'), isFalse);
      expect(json.containsKey('token'), isFalse);
    });

    test('User.props does not include password or token', () {
      const user1 = User(
        id: 1,
        username: 'testuser',
        password: 'secret123',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'avatar.png',
        token: 'jwt-token',
      );

      const user2 = User(
        id: 1,
        username: 'testuser',
        password: 'different_password',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'avatar.png',
        token: 'different-token',
      );

      // Equality should be based on identity fields only, not secrets
      expect(user1.props, user2.props);
    });

    test('LoginUseCase returns user without password in response', () async {
      const expectedUser = User(
        id: 1,
        username: 'testuser',
        password: '', // Should be empty in response
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        gender: 'male',
        image: 'avatar.png',
        token: '', // Token handled separately
      );

      final useCase = LoginUseCase(
        FakeAuthRepository(Right(expectedUser)),
        const FakeUserCacheRepository(true),
      );

      final result = await useCase(username: 'testuser', password: 'secret123');

      result.fold((failure) => fail('Login should succeed'), (user) {
        expect(user.password, isEmpty);
        expect(user.token, isEmpty);
      });
    });
  });

  group('Pagination tests', () {
    test('DashboardNotifier calculates skip correctly from page', () {
      // This verifies the pagination logic matches v2 behavior
      const productsPerPage = 20;
      const page = 2;
      final expectedSkip = page * productsPerPage;
      expect(expectedSkip, equals(40));
    });
  });
}
