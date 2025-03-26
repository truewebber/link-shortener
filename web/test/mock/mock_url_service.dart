import 'package:mockito/mockito.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/models/ttl.dart';
import 'package:flutter/material.dart';

class MockUrlService extends Mock implements UrlService {
  @override
  Future<String> shortenRestrictedUrl(String url) async {
    return 'https://short.url/abc123';
  }

  @override
  Future<String> createShortUrl({
    BuildContext? context,
    required String url,
    required TTL ttl,
  }) async {
    return 'https://short.url/abc123';
  }

  @override
  Future<List<ShortUrl>> getUserUrls({BuildContext? context}) async {
    return [
      ShortUrl(
        originalUrl: 'https://example.com',
        shortId: 'abc123',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime.now(),
        clickCount: 0,
      )
    ];
  }

  @override
  Future<ShortUrl> getUrlDetails(String shortId,
      {BuildContext? context}) async {
    return ShortUrl(
      originalUrl: 'https://example.com',
      shortId: shortId,
      shortUrl: 'https://short.url/$shortId',
      createdAt: DateTime.now(),
      clickCount: 0,
    );
  }

  @override
  Future<bool> deleteUrl(String shortId, {BuildContext? context}) async {
    return true;
  }
}
