import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/config/app_config.dart';

void main() {
  late AppConfig config;

  setUp(() {
    config = const AppConfig(
      apiBaseUrl: 'https://api.test.example.com',
      environment: 'test',
    );
  });

  group('AppConfig', () {
    test('creates configuration correctly', () {
      const apiUrl = 'https://api.example.com';
      const env = 'production';
      
      const config = AppConfig(
        apiBaseUrl: apiUrl,
        environment: env,
      );
      
      expect(config.apiBaseUrl, apiUrl);
      expect(config.environment, env);
    });
    
    test('provides environment helpers', () {
      expect(config.isDevelopment, false);
      expect(config.isProduction, false);
      expect(config.isStaging, false);
      
      const prodConfig = AppConfig(
        apiBaseUrl: '/api',
        environment: 'production',
      );
      
      expect(prodConfig.isDevelopment, false);
      expect(prodConfig.isProduction, true);
      expect(prodConfig.isStaging, false);
      
      const stagingConfig = AppConfig(
        apiBaseUrl: '/api',
        environment: 'staging',
      );
      
      expect(stagingConfig.isDevelopment, false);
      expect(stagingConfig.isProduction, false);
      expect(stagingConfig.isStaging, true);
    });
  });
}
