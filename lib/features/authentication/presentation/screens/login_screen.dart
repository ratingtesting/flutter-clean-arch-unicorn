import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/auth_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/state/auth_state.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/widgets/auth_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController(text: 'kminchelle');
  final passwordController = TextEditingController(text: '0lelplR');

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authStateNotifierProvider);

    ref.listen(authStateNotifierProvider.select((value) => value), ((
      previous,
      next,
    ) {
      if (next is Failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.exception.message.toString())),
        );
      } else if (next is Success) {
        // ignore: use_build_context_synchronously
        context.go('/dashboard');
      }
    }));

    return Scaffold(
      appBar: AppBar(title: const Text('TDD with Riverpod')),
      body: SafeArea(
        child: Column(
          children: [
            AuthField(hintText: 'Username', controller: usernameController),
            AuthField(
              hintText: 'Password',
              obscureText: true,
              controller: passwordController,
            ),
            state.maybeMap(
              loading: (_) => const Center(child: CircularProgressIndicator()),
              orElse: () => ElevatedButton(
                onPressed: () {
                  ref
                      .read(authStateNotifierProvider.notifier)
                      .loginUser(
                        usernameController.text,
                        passwordController.text,
                      );
                },
                child: const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
