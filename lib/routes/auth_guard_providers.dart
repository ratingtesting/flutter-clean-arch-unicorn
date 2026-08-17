import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/authentication/presentation/providers/auth_providers.dart';
import '../features/authentication/presentation/providers/state/auth_state.dart';
import '../services/user_cache_service/providers.dart';

/// Live-first auth check for route guards.
///
/// Lives in `routes/` (the app's composition root / glue layer) because it is
/// the ONE place that legitimately combines a feature's runtime state
/// (`authStateNotifierProvider`) with a service's persisted state
/// (`userLocalRepositoryProvider`). Keeping it here means `services/` never
/// reaches into a feature's `presentation/` layer (architecture boundary
/// R-SERVICES-1) and features never reach into `services/` internals.
///
/// Returns `true` when the user is logged in (live session OR persisted user),
/// so a refreshed app still passes the guard.
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authState = ref.watch(authStateNotifierProvider);
  if (authState is Success) return true;
  return ref.watch(userLocalRepositoryProvider).hasUser();
});
