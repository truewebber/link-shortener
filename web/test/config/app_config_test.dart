import 'package:flutter_test/flutter_test.dart';
import '../../lib/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('creates development config correctly', () {
      final config = AppConfig.development();
      
      expect(config.apiBaseUrl, 'http://localhost:8080');
      expect(config.environment, 'development');
      expect(config.isDevelopment, true);
      expect(config.isProduction, false);
    });
    
    test('creates production config correctly', () {
      final config = AppConfig.production();
      
      expect(config.apiBaseUrl, 'https://api.short.url');
      expect(config.environment, 'production');
      expect(config.isDevelopment, false);
      expect(config.isProduction, true);
    });
    
    test('creates custom config correctly', () {
      const apiUrl = 'https://custom-api.example.com';
      const env = 'staging';
      
      final config = AppConfig(
        apiBaseUrl: apiUrl,
        environment: env,
      );
      
      expect(config.apiBaseUrl, apiUrl);
      expect(config.environment, env);
      expect(config.isDevelopment, false);
      expect(config.isProduction, false);
    });
    
    test('handles empty API URL', () {
      expect(
        () => AppConfig(
          apiBaseUrl: '',
          environment: 'development',
        ),
        throwsAssertionError,
      );
    });
    
    test('handles invalid environment', () {
      expect(
        () => AppConfig(
          apiBaseUrl: 'http://localhost:8080',
          environment: 'invalid',
        ),
        throwsAssertionError,
      );
    });
    
    test('handles null values', () {
      expect(
        () => AppConfig(
          apiBaseUrl: null,
          environment: 'development',
        ),
        throwsAssertionError,
      );
      
      expect(
        () => AppConfig(
          apiBaseUrl: 'http://localhost:8080',
          environment: null,
        ),
        throwsAssertionError,
      );
    });
    
    test('validates API URL format', () {
      final invalidUrls = [
        'not-a-url',
        'ftp://example.com',
        'http://',
        'https://',
        'http://example',
        'https://example',
      ];
      
      for (final url in invalidUrls) {
        expect(
          () => AppConfig(
            apiBaseUrl: url,
            environment: 'development',
          ),
          throwsAssertionError,
        );
      }
    });
    
    test('validates environment values', () {
      final validEnvironments = ['development', 'production', 'staging', 'testing'];
      
      for (final env in validEnvironments) {
        final config = AppConfig(
          apiBaseUrl: 'http://localhost:8080',
          environment: env,
        );
        expect(config.environment, env);
      }
    });
  });
}
