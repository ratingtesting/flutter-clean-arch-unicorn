import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../services/user_cache_service/presentation/providers/current_user_provider.dart';

/// Auth guard: `/dashboard` requires a logged-in user. If none, redirect to
/// `/login`. We read live auth state (authStateNotifierProvider, combined with
/// persisted user) via isAuthenticatedProvider — no direct UI/repo import.
FutureOr<String?> appRouterRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  final container = ProviderScope.containerOf(context);
  final loggedIn = await container.read(isAuthenticatedProvider.future);
  final isLoggingIn = state.matchedLocation == '/login';

  if (!loggedIn && !isLoggingIn && state.matchedLocation == '/dashboard') {
    return '/login';
  }
  return null;
}

/// Route table: splash (initial) -> login -> dashboard.
final List<RouteBase> appRouterRoutes = [
  GoRoute(
    path: '/',
    builder: (BuildContext context, GoRouterState state) =>
        const SplashScreen(),
  ),
  GoRoute(
    path: '/login',
    builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
  ),
  GoRoute(
    path: '/dashboard',
    builder: (BuildContext context, GoRouterState state) =>
        const DashboardScreen(),
  ),
];

/// GoRouter configuration replacing the previous auto_route setup.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: appRouterRedirect,
  routes: appRouterRoutes,
);
