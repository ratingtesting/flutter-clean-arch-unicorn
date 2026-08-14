import 'package:flutter/material.dart';
import 'package:flutter_clean_arch_unicorn/core/database/database_connection.dart';
import 'package:flutter_clean_arch_unicorn/core/database/database_provider.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/data/repositories/auth_repository_fake.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/providers/auth_repository_providers.dart';
import 'package:flutter_clean_arch_unicorn/features/authentication/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginScreen widget test', () {
    testWidgets('renders username, password fields and Login button', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              AuthRepositoryFake(shouldSucceed: true),
            ),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('shows loading indicator while logging in', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              AuthRepositoryFake(shouldSucceed: true),
            ),
            appDatabaseProvider.overrideWithValue(openTestDatabase()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump(); // first frame: loading state active

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error snackbar on login failure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(
              AuthRepositoryFake(
                shouldSucceed: false,
                failureMessage: 'Invalid credentials',
              ),
            ),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });
}
