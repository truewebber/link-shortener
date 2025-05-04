import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/utils/url_utils.dart';

void main() {
  group('UrlUtils', () {
    group('isValidUrl', () {
      test('returns true for valid http URLs', () {
        expect(UrlUtils.isValidUrl('http://example.com'), isTrue);
      });

      test('returns true for valid https URLs', () {
        expect(UrlUtils.isValidUrl('https://example.com'), isTrue);
      });

      test('returns false for empty strings', () {
        expect(UrlUtils.isValidUrl(''), isFalse);
      });

      test('returns false for non-HTTP/HTTPS URLs', () {
        expect(UrlUtils.isValidUrl('ftp://example.com'), isFalse);
        expect(UrlUtils.isValidUrl('file:///path/to/file'), isFalse);
      });

      test('returns false for malformed URLs', () {
        expect(UrlUtils.isValidUrl('not-a-url'), isFalse);
        expect(UrlUtils.isValidUrl('http:example.com'), isFalse);
      });

      test('returns true for URLs with query parameters', () {
        expect(UrlUtils.isValidUrl('https://example.com/path?query=value'), isTrue);
      });

      // Test cases for URLs with fragments
      test('returns true for URLs with fragments', () {
        expect(UrlUtils.isValidUrl('https://example.com#section'), isTrue);
        expect(UrlUtils.isValidUrl('https://example.com/page#top'), isTrue);
        expect(UrlUtils.isValidUrl('https://truewebber.com/about?t=1#blah'), isTrue);
      });

      test('returns true for complex URLs with query params and fragments', () {
        expect(
          UrlUtils.isValidUrl('https://example.com/path?query=value&another=123#section'),
          isTrue,
        );
      });
    });

    group('getValidationErrorMessage', () {
      test('returns error message for empty URLs', () {
        expect(UrlUtils.getValidationErrorMessage(''), 'Please enter a URL');
      });

      test('returns error message for invalid URLs', () {
        expect(
          UrlUtils.getValidationErrorMessage('not-a-url'),
          'Please enter a valid URL starting with http:// or https://',
        );
      });

      test('returns null for valid URLs', () {
        expect(UrlUtils.getValidationErrorMessage('https://example.com'), isNull);
      });

      test('returns null for valid URLs with fragments', () {
        expect(
          UrlUtils.getValidationErrorMessage('https://truewebber.com/about?t=1#blah'),
          isNull,
        );
      });
    });
  });
}
