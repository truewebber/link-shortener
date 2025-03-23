import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/config/app_config.dart';

void main() {
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
    
    test('fromWindow provides default configuration', () {
      final config = AppConfig.fromWindow();
      
      // Verify default values are used
      expect(config.apiBaseUrl, 'https://short.twb.one');
      expect(config.environment, 'development');
    });
    
    test('provides environment helpers', () {
      const devConfig = AppConfig(
        apiBaseUrl: '/api',
        environment: 'development',
      );
      
      expect(devConfig.isDevelopment, true);
      expect(devConfig.isProduction, false);
      expect(devConfig.isStaging, false);
      
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
