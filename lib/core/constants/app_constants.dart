class AppConstants {
  AppConstants._();

  static const String appName = 'FreeHub';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Personal Free Internet Resources Directory';

  // Database
  static const String dbName = 'freehub.db';
  static const int dbVersion = 1;

  // JSON Schema
  static const String jsonSchemaVersion = '1';
  static const String initialDataAsset = 'assets/data/initial_websites.json';

  // SharedPreferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefFirstLaunch = 'first_launch';
  static const String prefDbInitialized = 'db_initialized';

  // Website source types
  static const String sourceFmhy = 'FMHY';
  static const String sourceCustom = 'CUSTOM';

  // Website types
  static const String typeFree = 'Free';
  static const String typeFreemium = 'Freemium';
  static const String typeOpenSource = 'Open Source';

  // Export file name
  static const String exportFileName = 'freehub_backup';

  // Pagination
  static const int pageSize = 20;

  // Favicon fallback
  static const String faviconBaseUrl = 'https://www.google.com/s2/favicons?sz=64&domain=';
}
