import 'package:flutter_clean_arch_unicorn/routes/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

String routeLocation(RouteBase route) => route is GoRoute ? route.path : '';

void main() {
  group('AppRouter (GoRouter)', () {
    late GoRouter router;

    setUp(() {
      router = appRouter;
    });

    test('declares the three core routes', () {
      final locations = router.configuration.routes.map(routeLocation).toList();
      expect(locations, contains('/'));
      expect(locations, contains('/login'));
      expect(locations, contains('/dashboard'));
    });

    test('initial route is splash (/)', () {
      final first = router.configuration.routes.first;
      expect(routeLocation(first), '/');
    });

    test('route locations are unique', () {
      final locations = router.configuration.routes.map(routeLocation).toList();
      final unique = locations.where((l) => l.isNotEmpty).toSet();
      expect(unique.length, locations.where((l) => l.isNotEmpty).length);
    });

    test('core paths are absolute', () {
      for (final path in const ['/', '/login', '/dashboard']) {
        expect(path.startsWith('/'), isTrue);
      }
    });
  });
}
