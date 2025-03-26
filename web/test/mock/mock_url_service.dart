import 'package:flutter/material.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/models/ttl.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:mockito/mockito.dart';

class MockUrlService extends Mock implements UrlService {
  @override
  Future<String> shortenRestrictedUrl(String url) async => 'https://short.url/abc123';

  @override
  Future<String> createShortUrl({
    BuildContext? context,
    required String url,
    required TTL ttl,
  }) async => 'https://short.url/abc123';

  @override
  Future<List<ShortUrl>> getUserUrls({BuildContext? context}) async => [
      ShortUrl(
        originalUrl: 'https://example.com',
        shortId: 'abc123',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime.now(),
      )
    ];

  @override
  Future<ShortUrl> getUrlDetails(String shortId,
      {BuildContext? context}) async => ShortUrl(
      originalUrl: 'https://example.com',
      shortId: shortId,
      shortUrl: 'https://short.url/$shortId',
      createdAt: DateTime.now(),
    );

  @override
  Future<bool> deleteUrl(String shortId, {BuildContext? context}) async => true;
}
