import 'package:link_shortener/config/app_config.dart';

/// Mock implementation of AppConfig for testing
/// This avoids the need for the dart:js_interop library
class MockAppConfig implements AppConfig {
  @override
  final String apiBaseUrl;
  
  @override
  final String environment;

  MockAppConfig({
    this.apiBaseUrl = 'http://test-api.example.com',
    this.environment = 'test',
  });

  @override
  bool get isProduction => environment == 'production';
  
  @override
  bool get isStaging => environment == 'staging';
  
  @override
  bool get isDevelopment => environment == 'development';
}
