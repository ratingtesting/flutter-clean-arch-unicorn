import 'package:flutter/material.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/screens/login_screen.dart';
import 'package:flutter_clean_arch_unicorn/routes/app_router.dart';
import 'package:flutter_clean_arch_unicorn/services/user_cache_service/presentation/providers/current_user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppRouter auth guard', () {
    testWidgets('redirects /dashboard to /login when not authenticated', (
      tester,
    ) async {
      final router = GoRouter(
        initialLocation: '/dashboard',
        routes: appRouterRoutes,
        redirect: appRouterRedirect,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            isAuthenticatedProvider.overrideWithValue(AsyncValue.data(false)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      // GoRouter resolves the redirect asynchronously; pump a few frames.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // LoginScreen... no — LoginScreen AppBar title:
      expect(find.text('TDD with Riverpod'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });
  });
}
