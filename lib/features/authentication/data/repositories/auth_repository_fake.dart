import 'package:flutter_clean_arch_unicorn/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/user.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';

/// In-memory fake of [AuthenticationRepository] for VibeCoders and tests.
///
/// Lets a developer run the app or widget tests without a backend:
///   - set [shouldSucceed] to simulate login outcomes;
///   - override [fakeUser] to control the returned entity;
///   - set [delay] to observe transient UI states (e.g. loading spinner).
/// Swap by changing one provider in `auth_providers.dart`.
class AuthRepositoryFake implements AuthenticationRepository {
  AuthRepositoryFake({
    this.shouldSucceed = true,
    this.fakeUser,
    this.failureMessage = 'Fake auth failure',
    this.delay = Duration.zero,
  });

  final bool shouldSucceed;
  final User? fakeUser;
  final String failureMessage;
  final Duration delay;

  @override
  Future<Either<AppException, User>> loginUser({required User user}) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    if (shouldSucceed) {
      return Right(fakeUser ?? user);
    }
    return Left(
      AppException(
        message: failureMessage,
        statusCode: 401,
        identifier: 'AuthRepositoryFake.loginUser',
      ),
    );
  }
}
