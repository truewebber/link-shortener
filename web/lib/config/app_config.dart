import 'dart:js' as js;

class AppConfig {
  final String apiBaseUrl;
  final String environment;

  AppConfig._({
    required this.apiBaseUrl,
    required this.environment,
  });

  factory AppConfig.fromWindow() {
    final config = js.context['APP_CONFIG'];
    if (config == null) {
      throw Exception('APP_CONFIG is not defined in window object');
    }

    return AppConfig._(
      apiBaseUrl: config['apiBaseUrl'] as String? ?? '/api',
      environment: config['environment'] as String? ?? 'production',
    );
  }

  bool get isProduction => environment == 'production';
  bool get isStaging => environment == 'staging';
  bool get isDevelopment => environment == 'development';
} 