import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/url_service.dart';

import 'mock_auth_service.dart';
import 'mock_url_service.dart';

/// Фабрика для предоставления сервисов в тестах
class TestServiceFactory {
  /// Фабричный метод для получения экземпляра
  factory TestServiceFactory() => _instance;

  /// Приватный конструктор
  TestServiceFactory._();
  
  /// Единственный экземпляр
  static final TestServiceFactory _instance = TestServiceFactory._();
  
  /// Текущие моки
  MockAuthService? _mockAuthService;
  MockUrlService? _mockUrlService;
  
  /// Предоставляет мок для AuthService
  AuthService provideAuthService() {
    _mockAuthService ??= MockAuthService();
    return _mockAuthService!;
  }
  
  /// Предоставляет мок для UrlService
  UrlService provideUrlService() {
    _mockUrlService ??= MockUrlService();
    return _mockUrlService!;
  }
  
  /// Сбрасывает все моки, чтобы они были созданы заново
  void reset() {
    _mockAuthService = null;
    _mockUrlService = null;
    
    // Сбрасываем состояние реальных сервисов
    AuthService.resetForTesting();
  }
}

/// Глобальный экземпляр фабрики сервисов для тестов
final testServiceFactory = TestServiceFactory(); 