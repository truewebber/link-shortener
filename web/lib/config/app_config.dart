import 'dart:js_interop';
import 'package:flutter/foundation.dart';

@JS()
@anonymous
@staticInterop
class JSAppConfig {}

extension JSAppConfigExtension on JSAppConfig {
  external String? get apiBaseUrl;
  external String? get googleCaptchaSiteKey;
  external String? get environment;
}

@JS('APP_CONFIG')
external JSAppConfig? get jsAppConfig;

class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.googleCaptchaSiteKey,
    required this.environment,
  });

  factory AppConfig.fromWindow() => AppConfig(
        apiBaseUrl: getApiBaseUrl(),
        googleCaptchaSiteKey: getGoogleCaptchaSiteKey(),
        environment: getEnvironment(),
      );

  final String apiBaseUrl;

  final String googleCaptchaSiteKey;

  final String environment;

  bool get isProduction => environment == 'production';

  bool get isStaging => environment == 'staging';

  bool get isDevelopment => environment == 'development';
}

String getApiBaseUrl() {
  if (kIsWeb) {
    final runtimeValue = jsAppConfig?.apiBaseUrl;
    if (runtimeValue != null) {
      if (kDebugMode) {
        print('Найдена конфигурация window.APP_CONFIG.apiBaseUrl: $runtimeValue');
      }
      return runtimeValue;
    }
  }

  return const String.fromEnvironment('API_BASE_URL');
}

String getGoogleCaptchaSiteKey() {
  if (kIsWeb) {
    final runtimeValue = jsAppConfig?.googleCaptchaSiteKey;
    if (runtimeValue != null) {
      if (kDebugMode) {
        print('Найдена конфигурация window.APP_CONFIG.googleCaptchaSiteKey: $runtimeValue');
      }
      return runtimeValue;
    }
  }

  return const String.fromEnvironment('GOOGLE_CAPTCHA_SITE_KEY');
}

String getEnvironment() {
  if (kIsWeb) {
    final runtimeValue = jsAppConfig?.environment;
    if (runtimeValue != null) {
      if (kDebugMode) {
        print('Найдена конфигурация window.APP_CONFIG.environment: $runtimeValue');
      }
      return runtimeValue;
    }
  }

  return const String.fromEnvironment('ENVIRONMENT');
}
