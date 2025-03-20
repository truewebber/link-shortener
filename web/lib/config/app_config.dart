/// Configuration for the application
class AppConfig {
  final String apiBaseUrl;
  final String environment;

  /// Default constructor for AppConfig
  AppConfig({
    required this.apiBaseUrl,
    required this.environment,
  });

  /// Factory constructor that creates default values for tests
  /// In a web environment, these values would be overridden
  /// by values from window.APP_CONFIG
  factory AppConfig.fromWindow() {
    // In tests, return default values
    // In web, this would normally use JS interop to get values from window
    return AppConfig(
      apiBaseUrl: '/api',
      environment: 'test',
    );
  }

  bool get isProduction => environment == 'production';
  bool get isStaging => environment == 'staging';
  bool get isDevelopment => environment == 'development';
}
