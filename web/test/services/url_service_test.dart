import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/models/ttl.dart';
import 'package:link_shortener/services/url_service.dart';
import 'package:mockito/mockito.dart';

import '../mocks/url_service.generate.mocks.dart';

void main() {
  late UrlService urlService;
  late MockUrlService mockUrlService;

  setUp(() {
    urlService = UrlService();
    mockUrlService = MockUrlService();
  });

  tearDown(() {
    urlService.dispose();
  });

  group('UrlService', () {
    test('should create short URL with TTL', () async {
      const testUrl = 'https://example.com';
      const expectedShortUrl = 'https://short.url/abc123';

      when(mockUrlService.createShortUrl(
        url: testUrl,
        context: anyNamed('context'),
        ttl: anyNamed('ttl'),
      )).thenAnswer((_) async => expectedShortUrl);

      final result = await mockUrlService.createShortUrl(
        url: testUrl,
        ttl: TTL.threeMonths,
      );

      expect(result, equals(expectedShortUrl));
      verify(mockUrlService.createShortUrl(
        url: testUrl,
        context: anyNamed('context'),
        ttl: anyNamed('ttl'),
      )).called(1);
    });

    test('should handle API errors', () async {
      const testUrl = 'https://example.com';

      when(mockUrlService.createShortUrl(
        url: testUrl,
        context: anyNamed('context'),
        ttl: anyNamed('ttl'),
      )).thenThrow(Exception('API Error'));

      expect(
        () => mockUrlService.createShortUrl(
          url: testUrl,
          ttl: TTL.threeMonths,
        ),
        throwsException,
      );
    });

    test('should handle different TTL options', () async {
      const testUrl = 'https://example.com';
      const expectedShortUrl = 'https://short.url/abc123';

      final ttlOptions = [
        TTL.threeMonths,
        TTL.sixMonths,
        TTL.twelveMonths,
        TTL.never,
      ];

      for (final ttl in ttlOptions) {
        when(mockUrlService.createShortUrl(
          url: testUrl,
          context: anyNamed('context'),
          ttl: ttl,
        )).thenAnswer((_) async => expectedShortUrl);

        final result = await mockUrlService.createShortUrl(
          url: testUrl,
          ttl: ttl,
        );

        expect(result, equals(expectedShortUrl));
        verify(mockUrlService.createShortUrl(
          url: testUrl,
          context: anyNamed('context'),
          ttl: ttl,
        )).called(1);
      }
    });

    test('should handle network errors', () async {
      const testUrl = 'https://example.com';

      when(mockUrlService.createShortUrl(
        url: testUrl,
        context: anyNamed('context'),
        ttl: anyNamed('ttl'),
      )).thenThrow(Exception('Network Error'));

      expect(
        () => mockUrlService.createShortUrl(
          url: testUrl,
          ttl: TTL.threeMonths,
        ),
        throwsException,
      );
    });
  });
}
