import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/providers.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/models.dart';

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
