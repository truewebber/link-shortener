import 'dart:js_interop';
import 'package:flutter/foundation.dart';

/// Объявляем JS-интерфейс для объекта конфигурации.
/// Директива @anonymous позволяет создавать интерфейс для «обычного» JS-объекта.
@JS()
@anonymous
@staticInterop
class JSAppConfig {}

extension JSAppConfigExtension on JSAppConfig {
  external String? get apiBaseUrl;
  external String? get environment;
}

/// Объявляем внешнюю переменную, которая ссылается на window.APP_CONFIG
@JS('APP_CONFIG')
external JSAppConfig? get jsAppConfig;

/// Конфигурация приложения на стороне Dart
class AppConfig {
  /// Создаёт конфигурацию приложения с необходимыми параметрами.
  const AppConfig({
    required this.apiBaseUrl,
    required this.environment,
  });

  /// Фабричный конструктор, создающий конфигурацию из нескольких источников
  /// с приоритетом:
  /// 1. Значения времени выполнения (window.APP_CONFIG в вебе)
  /// 2. Compile-time значения (--dart-define)
  /// 3. Жёстко заданные значения по умолчанию
  factory AppConfig.fromWindow() => AppConfig(
        apiBaseUrl: getApiBaseUrl(),
        environment: getEnvironment(),
      );

  /// Базовый URL для API вызовов
  final String apiBaseUrl;

  /// Текущее окружение (development, production, staging и т.д.)
  final String environment;

  /// Проверка, что окружение production
  bool get isProduction => environment == 'production';

  /// Проверка, что окружение staging
  bool get isStaging => environment == 'staging';

  /// Проверка, что окружение development
  bool get isDevelopment => environment == 'development';
}

/// Получает API base URL с приоритетом:
/// 1. Значение из window.APP_CONFIG (runtime)
/// 2. Compile-time значение (--dart-define=API_BASE_URL=...)
/// 3. Значение по умолчанию
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
  return const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://short.twb.one',
  );
}

/// Получает имя окружения с приоритетом:
/// 1. Значение из window.APP_CONFIG (runtime)
/// 2. Compile-time значение (--dart-define=ENVIRONMENT=...)
/// 3. Значение по умолчанию
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
  return const String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
}
