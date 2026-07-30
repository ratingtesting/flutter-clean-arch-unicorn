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

  // Connection string is injected at build time via
  // `--dart-define=BASE_URL=...` so it is never hardcoded in source.
  static const _connectionStrings = {
    AppEnvironment.DEV: String.fromEnvironment('BASE_URL',
        defaultValue: 'https://api.example.com'),
    AppEnvironment.STAGING: String.fromEnvironment('BASE_URL',
        defaultValue: 'https://api.example.com'),
    AppEnvironment.PROD: String.fromEnvironment('BASE_URL',
        defaultValue: 'https://api.example.com'),
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
