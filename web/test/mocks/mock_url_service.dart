import 'package:flutter/src/widgets/framework.dart';
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
  void dispose() {
    // В моке ничего не нужно закрывать
  }

  @override
  Future<ShortUrl> createShortUrl({required String originalUrl, String? customAlias, DateTime? expiresAt, BuildContext? context}) {
    // TODO: implement createShortUrl
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteUrl(String shortId, {BuildContext? context}) {
    // TODO: implement deleteUrl
    throw UnimplementedError();
  }

  @override
  Future<ShortUrl> getUrlDetails(String shortId, {BuildContext? context}) {
    // TODO: implement getUrlDetails
    throw UnimplementedError();
  }

  @override
  Future<List<ShortUrl>> getUserUrls({BuildContext? context}) {
    // TODO: implement getUserUrls
    throw UnimplementedError();
  }

  @override
  Future<ShortUrl> updateUrl({required String shortId, String? customAlias, DateTime? expiresAt, BuildContext? context}) {
    // TODO: implement updateUrl
    throw UnimplementedError();
  }
}
