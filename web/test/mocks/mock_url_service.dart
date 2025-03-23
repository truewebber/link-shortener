import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/services/url_service.dart';

/// Мок класс для UrlService, используемый в тестах
class MockUrlService implements UrlService {
  // Фабричный метод для получения экземпляра
  factory MockUrlService() => _instance;

  // Приватный конструктор
  MockUrlService._();

  // Единственный экземпляр для паттерна Singleton
  static final MockUrlService _instance = MockUrlService._();

  @override
  Future<ShortUrl> createShortUrl({
    required String originalUrl,
    String? customAlias,
    DateTime? expiresAt,
  }) async => ShortUrl(
      originalUrl: originalUrl,
      shortId: 'mock-short',
      shortUrl: 'https://short.mock/mock-short',
      createdAt: DateTime.now(),
      customAlias: customAlias,
      expiresAt: expiresAt,
      userId: 'mock-user-id',
    );

  @override
  Future<List<ShortUrl>> getUserUrls() async => [
      ShortUrl(
        originalUrl: 'https://example.com/long-url-1',
        shortId: 'mock-short-1',
        shortUrl: 'https://short.mock/mock-short-1',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 90)),
        userId: 'mock-user-id',
        clickCount: 5,
      ),
      ShortUrl(
        originalUrl: 'https://example.com/long-url-2',
        shortId: 'mock-short-2',
        shortUrl: 'https://short.mock/mock-short-2',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 30)),
        userId: 'mock-user-id',
        clickCount: 10,
      ),
    ];

  @override
  Future<ShortUrl> getUrlDetails(String shortId) async => ShortUrl(
      originalUrl: 'https://example.com/long-url-$shortId',
      shortId: shortId,
      shortUrl: 'https://short.mock/$shortId',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 90)),
      userId: 'mock-user-id',
      clickCount: 15,
    );

  @override
  Future<bool> deleteUrl(String shortId) async => true;

  @override
  Future<ShortUrl> updateUrl({
    required String shortId,
    String? customAlias,
    DateTime? expiresAt,
  }) async => ShortUrl(
      originalUrl: 'https://example.com/long-url-$shortId',
      shortId: customAlias ?? shortId,
      shortUrl: 'https://short.mock/${customAlias ?? shortId}',
      createdAt: DateTime.now(),
      customAlias: customAlias,
      expiresAt: expiresAt,
      userId: 'mock-user-id',
      clickCount: 15,
    );

  @override
  void dispose() {
    // В моке ничего не нужно закрывать
  }
} 