import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/providers.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/user.dart';

/// Tracks whether the persisted user cache is currently "wired" into the
/// provider graph. It depends only on the `user_cache_service` boundary
/// (`userLocalRepositoryProvider`) and the shared `User` model — never on any
/// feature's `presentation/` layer (architecture boundary R-SERVICES-1).
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

/// The auth-guard check that combines live auth state with the persisted user
/// lives in `lib/routes/auth_guard_providers.dart` (the composition root),
/// not here, so this service stays decoupled from feature presentation.
