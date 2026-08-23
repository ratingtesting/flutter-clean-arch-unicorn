// tool/boundary_rules.dart
//
// Architecture boundary rules — SINGLE SOURCE OF TRUTH.
//
// This file is the canonical definition of the template's allowed/forbidden
// dependencies. It is consumed by `tool/check_boundaries.dart` (the enforcer)
// and referenced by `ARCHITECTURE.md` / `AGENTS.md` / `llms.txt`. The rules
// are intentionally minimal: they protect against the most damaging forms of
// architectural decay without becoming a burden on legitimate code.
//
// How a rule is checked:
//   checkImport(fromRelPath, internalTarget: ..., externalPackage: ...)
// returns a list of BoundaryViolation. A `fatal: true` violation makes the
// checker exit with code 1 (CI fails). `fatal: false` is a warning only.
//
// Paths are relative to `lib/`, forward slashes, e.g.
//   fromRelPath:  services/user_cache_service/presentation/providers/current_user_provider.dart
//   internalTarget: features/authentication/presentation/providers/auth_providers.dart

/// A single detected boundary violation.
class BoundaryViolation {
  const BoundaryViolation(this.ruleId, this.message, this.fatal, this.fixHint);

  final String ruleId;
  final String message;
  final bool fatal;

  /// Short instruction telling the developer HOW to fix the violation
  /// (printed by the checker as a `Fix:` line — a hint, not an essay).
  final String fixHint;

  @override
  String toString() => '[$ruleId] $message';
}

/// Infrastructure packages covered by the Repository Law (rule R-INFRA).
///
/// Direct imports are forbidden inside domain/ and presentation/ screens &
/// widgets. When your project adds another infrastructure package (e.g.
/// `graphql`, `realm`, `objectbox`), add it to this set so the boundary
/// checker protects it too.
const Set<String> _infrastructurePackages = {'dio', 'drift', 'sqflite'};

/// Returns all boundary violations for one import statement.
///
/// [fromRelPath] is the importing file's path relative to `lib/`.
/// Provide exactly one of [internalTarget] (a path under `lib/`, used for
/// `package:flutter_clean_arch_unicorn/...` and resolved relative imports) or
/// [externalPackage] (e.g. `dio`, `drift`, `sqflite` for external packages).
List<BoundaryViolation> checkImport(
  String fromRelPath, {
  String? internalTarget,
  String? externalPackage,
}) {
  final violations = <BoundaryViolation>[];

  final from = fromRelPath.replaceAll('\\', '/');
  final target = internalTarget?.replaceAll('\\', '/');

  final fromTop = _segment(from, 0);
  final targetTop = target == null ? null : _segment(target, 0);

  // ---------------------------------------------------------------------------
  // R-CORE-1 — core must not depend on features or services.
  // core holds app-wide infrastructure (database). It must stay leaf-level.
  // ---------------------------------------------------------------------------
  if (fromTop == 'core' &&
      (targetTop == 'features' || targetTop == 'services')) {
    violations.add(
      const BoundaryViolation(
        'R-CORE-1',
        'core/ must not depend on features/ or services/ '
            '(core is leaf infrastructure).',
        true,
        'Move the feature/service-dependent code into the feature that uses '
            'it, or invert the dependency: define a contract in core/ or '
            'shared/ and implement it in features/services.',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // R-SHARED-1 — shared must not depend on features.
  // shared holds only generic primitives; feature-specific code belongs in the
  // feature. (shared -> services is allowed: services are cross-cutting infra.)
  // ---------------------------------------------------------------------------
  if (fromTop == 'shared' && targetTop == 'features') {
    violations.add(
      const BoundaryViolation(
        'R-SHARED-1',
        'shared/ must not depend on features/ '
            '(shared is generic; feature code stays in the feature).',
        true,
        'Move the model/widget into the feature that owns it, or generalise '
            'it and keep it in shared/ without feature imports.',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // R-SERVICES-1 — services must not depend on features (any layer).
  // Services are contracts/infrastructure consumed BY features, never the
  // reverse. A service reaching into a feature (presentation OR domain OR data)
  // inverts the dependency direction and couples infra to product code.
  // ---------------------------------------------------------------------------
  if (fromTop == 'services' && targetTop == 'features') {
    violations.add(
      const BoundaryViolation(
        'R-SERVICES-1',
        'services/ must not depend on features/ (any layer). '
            'Move shared types to shared/, or invert the dependency via a contract.',
        true,
        'Move the shared type to shared/ and import it from both sides, or '
            'define a contract in services/ that the feature implements.',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // R-FEATURE-1 — a feature must not import the INTERNALS of another feature.
  // Allowed: Feature A -> Core, -> Shared, -> Services (via contracts), and a
  // feature's PUBLIC barrel `features/<b>/<b>.dart`. Everything else inside
  // another feature (data/, domain/, presentation/, providers) is forbidden.
  // ---------------------------------------------------------------------------
  final fromFeat = _featureOf(from);
  final toFeat = target == null ? null : _featureOf(target);
  if (fromFeat != null && toFeat != null && fromFeat != toFeat) {
    final barrel = 'features/$toFeat/$toFeat.dart';
    if (target != barrel) {
      violations.add(
        BoundaryViolation(
          'R-FEATURE-1',
          'feature "$fromFeat" must not import internals of feature "$toFeat" '
              '($target). Depend on the public barrel or a contract instead.',
          true,
          'Import the public barrel features/$toFeat/$toFeat.dart, or move '
              'the shared type/contract to shared/ (or a service contract).',
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // R-LAYER-DOMAIN — domain must not depend on data or presentation.
  // domain is the business core; it must not know about implementations or UI.
  // Applies everywhere (features and services).
  // ---------------------------------------------------------------------------
  final fromLayer = _layerOf(from);
  final toLayer = target == null ? null : _layerOf(target);
  if (fromLayer == 'domain' &&
      (toLayer == 'data' || toLayer == 'presentation')) {
    violations.add(
      const BoundaryViolation(
        'R-LAYER-DOMAIN',
        'domain/ must not depend on data/ or presentation/ '
            '(domain is the business core).',
        true,
        'Declare an abstract contract in domain/ and depend on that; the '
            'implementation lives in data/ and is wired in presentation/providers/.',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // R-LAYER-DATA — data must not depend on presentation.
  // data implements domain interfaces; it must never reach into UI.
  // ---------------------------------------------------------------------------
  if (fromLayer == 'data' && toLayer == 'presentation') {
    violations.add(
      const BoundaryViolation(
        'R-LAYER-DATA',
        'data/ must not depend on presentation/ '
            '(data implements domain, never the UI).',
        true,
        'Return a domain model/Either from the repository and let the '
            'presentation layer map it to UI state.',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // R-INFRA — Repository Law.
  // Direct imports of infrastructure packages (dio / drift / sqflite) are only
  // allowed inside data layers, core/database, or services/security. Anywhere
  // else (presentation, domain, shared/presentation, etc.) bypasses the
  // Repository abstraction and is forbidden.
  // ---------------------------------------------------------------------------
  if (externalPackage != null &&
      _infrastructurePackages.contains(externalPackage)) {
    // Repository Law: infrastructure is only touched by infrastructure layers.
    // Forbidden inside business/UI layers: domain/, and presentation/ screens &
    // widgets (UI must never bypass the repository). The
    // `presentation/providers/` wiring layer is the ONE allowed place that
    // assembles infrastructure (Dio/Drift) into Riverpod providers — this
    // matches the repo's existing auth_repository_providers.dart pattern.
    final inProviderWiring = from.contains('/presentation/providers/');
    final forbiddenLayer =
        fromLayer == 'domain' ||
        (fromLayer == 'presentation' && !inProviderWiring);
    if (forbiddenLayer) {
      violations.add(
        BoundaryViolation(
          'R-INFRA',
          'direct import of package:$externalPackage is forbidden inside '
              'domain/ and presentation/ layers '
              '(Repository Law: never bypass the repository).',
          true,
          'Go through the repository: inject a use case/repository via a '
              'Riverpod provider (wiring lives in presentation/providers/), '
              'or move the code to data/ if it is infrastructure by nature.',
        ),
      );
    }
  }

  return violations;
}

/// First path segment (e.g. `core`, `features`, `shared`, `services`, `routes`).
String _segment(String path, int index) {
  final parts = path.split('/');
  return index < parts.length ? parts[index] : '';
}

/// Feature name if [path] is inside `features/<name>/`, else null.
String? _featureOf(String path) {
  final parts = path.split('/');
  if (parts.isNotEmpty && parts[0] == 'features' && parts.length > 1) {
    return parts[1];
  }
  return null;
}

/// Architectural layer if [path] contains `/data/`, `/domain/`, or
/// `/presentation/`, else null.
String? _layerOf(String path) {
  if (path.contains('/domain/')) return 'domain';
  if (path.contains('/data/')) return 'data';
  if (path.contains('/presentation/')) return 'presentation';
  return null;
}
