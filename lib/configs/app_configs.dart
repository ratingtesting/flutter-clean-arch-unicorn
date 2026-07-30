/// Central configuration for the app.
///
/// All environment-specific values are injected at build time via
/// `--dart-define=BASE_URL=...` so secrets/endpoints never live in source
/// control. One binary can target dev/staging/prod without code changes.
class AppConfigs {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}
