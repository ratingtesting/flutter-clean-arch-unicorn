import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/providers.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/domain/models/user_model.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/auth_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/state/auth_state.dart';

class CurrentUserNotifier extends Notifier<User?> {
  @override
  User? build() {
    ref.watch(userLocalRepositoryProvider);
    return null;
  }
}

final currentUserProvider = NotifierProvider<CurrentUserNotifier, User?>(
  CurrentUserNotifier.new,
);

/// Live-first auth check for route guards.
/// Combines runtime auth state (authStateNotifierProvider) with persisted
/// user presence (SecureStorage) so a refreshed app still passes the guard.
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authStateNotifierProvider);
  if (authState is Success) return true;
  return ref.watch(userLocalRepositoryProvider).hasUser();
});
