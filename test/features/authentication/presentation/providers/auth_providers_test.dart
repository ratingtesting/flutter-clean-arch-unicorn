import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/auth_repository_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/domain/repositories/auth_repository.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/auth_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/state/auth_notifier.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/state/auth_state.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/presentation/providers/user_cache_provider.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/either.dart';
import 'package:flutter_clean_arch_unicorn/shared/domain/models/user.dart';
import 'package:flutter_clean_arch_unicorn/shared/exceptions/http_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/dummy_data.dart';

void main() {
  late AuthenticationRepository authRepository;
  late UserRepository userRepository;
  late ProviderContainer container;
  late AuthNotifier notifier;
  final List<AuthState> history = [];

  setUpAll(() => registerFallbackValue(ktestUser));

  setUp(() {
    authRepository = MockAuthRepository();
    userRepository = MockUserRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        userLocalRepositoryProvider.overrideWithValue(userRepository),
      ],
    );
    notifier = container.read(authStateNotifierProvider.notifier);
    history.clear();
    container.listen<AuthState>(
      authStateNotifierProvider,
      (_, next) => history.add(next),
    );
  });

  test('emits [] when no methods are called', () {
    expect(history, <AuthState>[]);
  });

  group('Authentication test\n', () {
    test(
      'emits [AuthState.loading, AuthState.success] when login and cache is success',
      () async {
        when(
          () => authRepository.loginUser(user: any(named: 'user')),
        ).thenAnswer(
          (invocation) async => Right<AppException, User>(ktestUser),
        );
        when(
          () => userRepository.saveUser(user: any(named: 'user')),
        ).thenAnswer((invocation) async => true);

        await notifier.loginUser('', '');

        expect(history, [const AuthState.loading(), const AuthState.success()]);
      },
    );

    test(
      'emits [AuthState.loading, AuthState.failure] when login is success but cache is fail',
      () async {
        when(
          () => authRepository.loginUser(user: any(named: 'user')),
        ).thenAnswer(
          (invocation) async => Right<AppException, User>(ktestUser),
        );
        when(
          () => userRepository.saveUser(user: any(named: 'user')),
        ).thenAnswer((invocation) async => false);

        await notifier.loginUser('', '');

        expect(history, [
          const AuthState.loading(),
          AuthState.failure(CacheFailureException()),
        ]);
      },
    );

    test(
      'when the login fails then the saveUser method is not called',
      () async {
        when(
          () => authRepository.loginUser(user: any(named: 'user')),
        ).thenAnswer(
          (invocation) async => Left<AppException, User>(ktestAppException),
        );

        await notifier.loginUser('', '');

        verifyNever(() => userRepository.saveUser(user: ktestUser));
      },
    );

    test(
      'emits [AuthState.loading, AuthState.failure] when login is fail',
      () async {
        when(
          () => authRepository.loginUser(user: any(named: 'user')),
        ).thenAnswer(
          (invocation) async => Left<AppException, User>(ktestAppException),
        );

        await notifier.loginUser('', '');

        expect(history, [
          const AuthState.loading(),
          AuthState.failure(ktestAppException),
        ]);
      },
    );
  });
}

class MockAuthRepository extends Mock implements AuthenticationRepository {}

class MockUserRepository extends Mock implements UserRepository {}
