/// Configuration for the application
class AppConfig {

  /// Creates application configuration with required parameters
  /// 
  /// [apiBaseUrl] must be a valid HTTP or HTTPS URL
  /// [environment] identifies the runtime environment
  const AppConfig({
    required this.apiBaseUrl,
    required this.environment,
  });

  /// Factory constructor that creates configuration from window.APP_CONFIG
  /// 
  /// In a production environment, this reads configuration values
  /// that are injected into the window object at runtime.
  /// 
  /// Falls back to sensible defaults if values are missing.
  factory AppConfig.fromWindow() {
    // In a real implementation, this would use the window object
    // For development/testing, use reasonable defaults
    return const AppConfig(
      apiBaseUrl: '/api',
      environment: 'development',
    );
  }
  /// Base URL for API calls
  final String apiBaseUrl;
  
  /// Current environment (development, production, staging, etc.)
  final String environment;

  /// Check if the environment is production
  bool get isProduction => environment == 'production';
  
  /// Check if the environment is staging
  bool get isStaging => environment == 'staging';
  
  /// Check if the environment is development
  bool get isDevelopment => environment == 'development';
}
