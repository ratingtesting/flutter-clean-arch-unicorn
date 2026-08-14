import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/domain/use_cases/login_use_case.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/auth_repository_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/state/auth_state.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/providers.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;

  @override
  AuthState build() {
    _loginUseCase = LoginUseCase(
      ref.watch(authRepositoryProvider),
      ref.watch(userLocalRepositoryProvider),
    );
    return const AuthState.initial();
  }

  Future<void> loginUser(String username, String password) async {
    state = const AuthState.loading();
    final result = await _loginUseCase(username: username, password: password);
    state = result.fold(
      AuthState.failure,
      (_) => const AuthState.success(),
    );
  }
}
