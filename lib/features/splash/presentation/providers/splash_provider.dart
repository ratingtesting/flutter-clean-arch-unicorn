import 'package:flutter_clean_arch_unicorn/services/user_cache_service/presentation/providers/user_cache_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userLoginCheckProvider = FutureProvider((ref) async {
  final repo = ref.watch(userLocalRepositoryProvider);
  return await repo.hasUser();
});
