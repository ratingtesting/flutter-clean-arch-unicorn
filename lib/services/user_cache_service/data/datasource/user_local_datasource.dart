import 'package:flutter_clean_arch_unicorn/shared/data/local/shared_prefs_storage_service.dart';
import 'package:flutter_clean_arch_unicorn/services/security/secure_storage.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/user.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';

abstract class UserDataSource {
  Future<Either<AppException, User>> fetchUser();
  Future<bool> saveUser({required User user});
  Future<bool> deleteUser();
  Future<bool> hasUser();
}

class UserLocalDataSource implements UserDataSource {
  UserLocalDataSource(this._prefs, this._secureStorage);

  final SharedPrefsService _prefs;
  final SecureStorage _secureStorage;

  static const String _userKey = 'cached_user';

  @override
  Future<Either<AppException, User>> fetchUser() async {
    try {
      final userMap = await _prefs.getMap(_userKey);
      if (userMap != null) {
        // Restore token from secure storage
        final token = await _secureStorage.read(SecureStorageKeys.authToken);
        final user = User.fromJson(userMap).copyWith(token: token ?? '');
        return Right(user);
      }
      return Left(
        AppException(
          message: 'User not found',
          statusCode: 404,
          identifier: 'UserLocalDataSource.fetchUser',
        ),
      );
    } catch (e) {
      return Left(
        AppException(
          message: 'Failed to fetch cached user',
          statusCode: 500,
          identifier: '${e.toString()}\nUserLocalDataSource.fetchUser',
        ),
      );
    }
  }

  @override
  Future<bool> saveUser({required User user}) async {
    try {
      // Save non-sensitive user data to SharedPreferences
      final userJson = user.toJson();
      await _prefs.setMap(_userKey, userJson);

      // Save token separately to SecureStorage
      if (user.token.isNotEmpty) {
        await _secureStorage.write(SecureStorageKeys.authToken, user.token);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteUser() async {
    try {
      await _prefs.remove(_userKey);
      await _secureStorage.delete(SecureStorageKeys.authToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasUser() async {
    return _prefs.containsKey(_userKey);
  }
}
