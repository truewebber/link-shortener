import 'package:flutter_test/flutter_test.dart';

// Import your actual model classes here
// import 'package:link_shortener/models/short_url.dart';

// Mock ShortUrl class for testing
class ShortUrl {
  final String id;
  final String originalUrl;
  final String shortCode;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int clickCount;

  ShortUrl({
    required this.id,
    required this.originalUrl,
    required this.shortCode,
    required this.createdAt,
    this.expiresAt,
    this.clickCount = 0,
  });

  ShortUrl copyWith({
    String? id,
    String? originalUrl,
    String? shortCode,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? clickCount,
  }) {
    return ShortUrl(
      id: id ?? this.id,
      originalUrl: originalUrl ?? this.originalUrl,
      shortCode: shortCode ?? this.shortCode,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      clickCount: clickCount ?? this.clickCount,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalUrl': originalUrl,
      'shortCode': shortCode,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'clickCount': clickCount,
    };
  }

  factory ShortUrl.fromJson(Map<String, dynamic> json) {
    return ShortUrl(
      id: json['id'],
      originalUrl: json['originalUrl'],
      shortCode: json['shortCode'],
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      clickCount: json['clickCount'] ?? 0,
    );
  }
}

void main() {
  group('ShortUrl Model', () {
    test('creates a valid ShortUrl object', () {
      final now = DateTime.now();
      final shortUrl = ShortUrl(
        id: '123',
        originalUrl: 'https://example.com',
        shortCode: 'abc123',
        createdAt: now,
      );

      expect(shortUrl.id, equals('123'));
      expect(shortUrl.originalUrl, equals('https://example.com'));
      expect(shortUrl.shortCode, equals('abc123'));
      expect(shortUrl.createdAt, equals(now));
      expect(shortUrl.expiresAt, isNull);
      expect(shortUrl.clickCount, equals(0));
      expect(shortUrl.isExpired, isFalse);
    });

    test('correctly detects expired URLs', () {
      final now = DateTime.now();
      final pastDate = now.subtract(const Duration(days: 1));
      final futureDate = now.add(const Duration(days: 1));

      final expiredUrl = ShortUrl(
        id: '123',
        originalUrl: 'https://example.com',
        shortCode: 'abc123',
        createdAt: now,
        expiresAt: pastDate,
      );

      final validUrl = ShortUrl(
        id: '456',
        originalUrl: 'https://example.org',
        shortCode: 'def456',
        createdAt: now,
        expiresAt: futureDate,
      );

      expect(expiredUrl.isExpired, isTrue);
      expect(validUrl.isExpired, isFalse);
    });

    test('serializes to JSON correctly', () {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 7));

      final shortUrl = ShortUrl(
        id: '123',
        originalUrl: 'https://example.com',
        shortCode: 'abc123',
        createdAt: now,
        expiresAt: expiresAt,
        clickCount: 42,
      );

      final json = shortUrl.toJson();

      expect(json['id'], equals('123'));
      expect(json['originalUrl'], equals('https://example.com'));
      expect(json['shortCode'], equals('abc123'));
      expect(json['createdAt'], equals(now.toIso8601String()));
      expect(json['expiresAt'], equals(expiresAt.toIso8601String()));
      expect(json['clickCount'], equals(42));
    });

    test('deserializes from JSON correctly', () {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 7));

      final json = {
        'id': '123',
        'originalUrl': 'https://example.com',
        'shortCode': 'abc123',
        'createdAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'clickCount': 42,
      };

      final shortUrl = ShortUrl.fromJson(json);

      expect(shortUrl.id, equals('123'));
      expect(shortUrl.originalUrl, equals('https://example.com'));
      expect(shortUrl.shortCode, equals('abc123'));
      expect(
          shortUrl.createdAt.toIso8601String(), equals(now.toIso8601String()));
      expect(shortUrl.expiresAt?.toIso8601String(),
          equals(expiresAt.toIso8601String()));
      expect(shortUrl.clickCount, equals(42));
    });

    test('copyWith creates a new instance with updated values', () {
      final now = DateTime.now();
      final original = ShortUrl(
        id: '123',
        originalUrl: 'https://example.com',
        shortCode: 'abc123',
        createdAt: now,
      );

      final updated = original.copyWith(
        shortCode: 'xyz789',
        clickCount: 10,
      );

      // Verify updated fields
      expect(updated.shortCode, equals('xyz789'));
      expect(updated.clickCount, equals(10));

      // Verify unchanged fields
      expect(updated.id, equals(original.id));
      expect(updated.originalUrl, equals(original.originalUrl));
      expect(updated.createdAt, equals(original.createdAt));
      expect(updated.expiresAt, equals(original.expiresAt));

      // Verify they are different instances
      expect(identical(original, updated), isFalse);
    });
  });
}
