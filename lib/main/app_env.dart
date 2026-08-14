// ignore_for_file: constant_identifier_names, use_setters_to_change_properties, avoid_classes_with_only_static_members
enum AppEnvironment { DEV, STAGING, PROD }

abstract class EnvInfo {
  static AppEnvironment _environment = AppEnvironment.DEV;

  static void initialize(AppEnvironment environment) {
    EnvInfo._environment = environment;
  }

  static String get appName => _environment._appTitle;
  static String get envName => _environment._envName;
  static String get connectionString => _environment._connectionString;
  static AppEnvironment get environment => _environment;
  static bool get isProduction => _environment == AppEnvironment.PROD;
}

extension _EnvProperties on AppEnvironment {
  static const _appTitles = {
    AppEnvironment.DEV: 'Q Flutter TDD Dev',
    AppEnvironment.STAGING: 'Q Flutter TDD Staging',
    AppEnvironment.PROD: 'Q Flutter TDD',
  };

  // Connection string is injected at build time per environment via distinct
  // `--dart-define` keys (BASE_URL_DEV / BASE_URL_STAGING / BASE_URL_PROD) so
  // each environment reads a real, separate backend URL. They are never
  // hardcoded in source. Defaults are placeholder endpoints so the template
  // still compiles out of the box; wire them to real backends per environment.
  static const _connectionStrings = {
    AppEnvironment.DEV: String.fromEnvironment(
      'BASE_URL_DEV',
      defaultValue: 'https://dev.api.example.com',
    ),
    AppEnvironment.STAGING: String.fromEnvironment(
      'BASE_URL_STAGING',
      defaultValue: 'https://staging.api.example.com',
    ),
    AppEnvironment.PROD: String.fromEnvironment(
      'BASE_URL_PROD',
      defaultValue: 'https://api.example.com',
    ),
  };

  static const _envs = {
    AppEnvironment.DEV: 'dev',
    AppEnvironment.STAGING: 'staging',
    AppEnvironment.PROD: 'prod',
  };

  String get _appTitle => _appTitles[this]!;
  String get _envName => _envs[this]!;
  String get _connectionString => _connectionStrings[this]!;
}
