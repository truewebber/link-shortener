import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/short_url.dart';

void main() {
  group('ShortUrl', () {
    test('creates correctly with required parameters', () {
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
      );

      expect(shortUrl.shortId, equals('abc123'));
      expect(shortUrl.originalUrl, equals('https://example.com'));
      expect(shortUrl.shortUrl, equals('https://short.url/abc123'));
      expect(shortUrl.createdAt, equals(DateTime(2023)));
      expect(shortUrl.clickCount, equals(0)); // Default value
      expect(shortUrl.customAlias, isNull);
      expect(shortUrl.expiresAt, isNull);
      expect(shortUrl.userId, isNull);
    });

    test('creates with all parameters', () {
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
        customAlias: 'my-custom-url',
        expiresAt: DateTime(2023, 4),
        clickCount: 42,
        userId: 'user123',
      );

      expect(shortUrl.shortId, equals('abc123'));
      expect(shortUrl.originalUrl, equals('https://example.com'));
      expect(shortUrl.shortUrl, equals('https://short.url/abc123'));
      expect(shortUrl.createdAt, equals(DateTime(2023)));
      expect(shortUrl.clickCount, equals(42));
      expect(shortUrl.customAlias, equals('my-custom-url'));
      expect(shortUrl.expiresAt, equals(DateTime(2023, 4)));
      expect(shortUrl.userId, equals('user123'));
    });

    test('converts from JSON correctly', () {
      final json = {
        'shortId': 'abc123',
        'originalUrl': 'https://example.com',
        'shortUrl': 'https://short.url/abc123',
        'createdAt': '2023-01-01T00:00:00.000Z',
        'customAlias': 'my-custom-url',
        'expiresAt': '2023-04-01T00:00:00.000Z',
        'clickCount': 42,
        'userId': 'user123',
      };

      final shortUrl = ShortUrl.fromJson(json);

      expect(shortUrl.shortId, equals('abc123'));
      expect(shortUrl.originalUrl, equals('https://example.com'));
      expect(shortUrl.shortUrl, equals('https://short.url/abc123'));
      expect(shortUrl.createdAt,
          equals(DateTime.parse('2023-01-01T00:00:00.000Z')));
      expect(shortUrl.clickCount, equals(42));
      expect(shortUrl.customAlias, equals('my-custom-url'));
      expect(shortUrl.expiresAt,
          equals(DateTime.parse('2023-04-01T00:00:00.000Z')));
      expect(shortUrl.userId, equals('user123'));
    });

    test('converts to JSON correctly', () {
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
        customAlias: 'my-custom-url',
        expiresAt: DateTime(2023, 4),
        clickCount: 42,
        userId: 'user123',
      );

      final json = shortUrl.toJson();

      expect(json['shortId'], equals('abc123'));
      expect(json['originalUrl'], equals('https://example.com'));
      expect(json['shortUrl'], equals('https://short.url/abc123'));
      expect(json['createdAt'], equals('2023-01-01T00:00:00.000'));
      expect(json['clickCount'], equals(42));
      expect(json['customAlias'], equals('my-custom-url'));
      expect(json['expiresAt'], equals('2023-04-01T00:00:00.000'));
      expect(json['userId'], equals('user123'));
    });

    test('copyWith works correctly', () {
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
      );

      final updatedUrl = shortUrl.copyWith(
        clickCount: 10,
        expiresAt: DateTime(2023, 6),
      );

      // Changed properties
      expect(updatedUrl.clickCount, equals(10));
      expect(updatedUrl.expiresAt, equals(DateTime(2023, 6)));

      // Unchanged properties
      expect(updatedUrl.shortId, equals('abc123'));
      expect(updatedUrl.originalUrl, equals('https://example.com'));
      expect(updatedUrl.shortUrl, equals('https://short.url/abc123'));
      expect(updatedUrl.createdAt, equals(DateTime(2023)));
    });

    test('isExpired returns true for expired URL', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
        expiresAt: pastDate,
      );

      expect(shortUrl.isExpired, isTrue);
    });

    test('isExpired returns false for non-expired URL', () {
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
        expiresAt: futureDate,
      );

      expect(shortUrl.isExpired, isFalse);
    });

    test('isExpired returns false for URL with no expiration', () {
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
      );

      expect(shortUrl.isExpired, isFalse);
    });

    test('timeUntilExpiration returns correct duration', () {
      final futureDate = DateTime.now().add(const Duration(days: 30));
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
        expiresAt: futureDate,
      );

      final duration = shortUrl.timeUntilExpiration;
      expect(duration, isNotNull);
      expect(duration!.inDays,
          closeTo(30, 1)); // Allow small difference due to test execution time
    });

    test('timeUntilExpiration returns null for URL with no expiration', () {
      final shortUrl = ShortUrl(
        shortId: 'abc123',
        originalUrl: 'https://example.com',
        shortUrl: 'https://short.url/abc123',
        createdAt: DateTime(2023),
      );

      expect(shortUrl.timeUntilExpiration, isNull);
    });
  });
}
