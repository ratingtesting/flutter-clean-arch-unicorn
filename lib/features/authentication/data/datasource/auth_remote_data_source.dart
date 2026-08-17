import 'package:flutter_clean_arch_unicorn/services/security/secure_storage.dart';
import 'package:flutter_clean_arch_unicorn/shared/data/remote/remote.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/user.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';

abstract class LoginUserDataSource {
  Future<Either<AppException, User>> loginUser({required User user});
}

class LoginUserRemoteDataSource implements LoginUserDataSource {
  LoginUserRemoteDataSource(this.networkService, this.secureStorage);

  final NetworkService networkService;
  final SecureStorage secureStorage;

  @override
  Future<Either<AppException, User>> loginUser({required User user}) async {
    try {
      final eitherType = await networkService.post(
        '/auth/login',
        data: user.toLoginJson(),
      );
      return eitherType.fold(
        (exception) {
          return Left(exception);
        },
        (response) async {
          final user = User.fromJson(response.data);
          // Persist the token so it survives app restarts (encrypted storage).
          if (user.token.isNotEmpty) {
            await secureStorage.write(SecureStorageKeys.authToken, user.token);
          }
          // update the token for subsequent requests
          networkService.updateHeader({'Authorization': user.token});

          return Right(user);
        },
      );
    } catch (e) {
      return Left(
        AppException(
          message: 'Unknown error occurred',
          statusCode: 1,
          identifier: '${e.toString()}\nLoginUserRemoteDataSource.loginUser',
        ),
      );
    }
  }
}
