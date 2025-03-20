import 'package:link_shortener/config/app_config.dart';

/// Mock implementation of AppConfig for testing
/// This avoids the need for the dart:js_interop library
class MockAppConfig implements AppConfig {

  MockAppConfig({
    this.apiBaseUrl = 'http://test-api.example.com',
    this.environment = 'test',
  });
  @override
  final String apiBaseUrl;
  
  @override
  final String environment;
  
  /// Flag to simulate API errors during testing
  bool simulateApiError = false;
  
  /// Flag to simulate network errors during testing
  bool simulateNetworkError = false;
  
  /// Flag to simulate rate limiting errors during testing
  bool simulateRateLimitError = false;

  @override
  bool get isProduction => environment == 'production';
  
  @override
  bool get isStaging => environment == 'staging';
  
  @override
  bool get isDevelopment => environment == 'development';
}
