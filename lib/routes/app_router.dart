import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../services/user_cache_service/providers.dart';

/// GoRouter configuration replacing the previous auto_route setup.
/// Routes: splash (initial) -> login -> dashboard.
///
/// Auth guard: `/dashboard` requires a logged-in user. If none, redirect to
/// `/login`. We read auth state from the user-cache repository (no UI import).
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    final container = ProviderScope.containerOf(context);
    final loggedIn = await container
        .read(userLocalRepositoryProvider)
        .hasUser();
    final isLoggingIn = state.matchedLocation == '/login';

    if (!loggedIn && !isLoggingIn && state.matchedLocation == '/dashboard') {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (BuildContext context, GoRouterState state) =>
          const DashboardScreen(),
    ),
  ],
);
