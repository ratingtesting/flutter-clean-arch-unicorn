import 'package:flutter_clean_arch_unicorn/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/domain/repositories/user_cache_repository.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/domain/models/user_model.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';

/// Logs a user in and caches the session on success.
///
/// Separating this from the UI notifier keeps the business rule testable in
/// isolation and reusable from any surface (widget, background task, CLI tool).
class LoginUseCase {
  const LoginUseCase(this._authRepository, this._userRepository);

  final AuthenticationRepository _authRepository;
  final UserRepository _userRepository;

  /// Returns the authenticated [User] or an [AppException] on failure.
  Future<Either<AppException, User>> call({
    required String username,
    required String password,
  }) async {
    final response = await _authRepository.loginUser(
      user: User(username: username, password: password),
    );

    return response.fold((failure) => Left<AppException, User>(failure), (
      user,
    ) async {
      final saved = await _userRepository.saveUser(user: user);
      return saved
          ? Right<AppException, User>(user)
          : Left<AppException, User>(CacheFailureException());
    });
  }
}
