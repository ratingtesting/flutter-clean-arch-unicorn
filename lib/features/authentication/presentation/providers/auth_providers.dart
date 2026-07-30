import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/state/auth_notifier.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authStateNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
