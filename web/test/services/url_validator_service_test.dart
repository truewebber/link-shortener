import 'package:flutter_test/flutter_test.dart';
import '../../lib/services/url_validator_service.dart';

void main() {
  late UrlValidatorService validator;
  
  setUp(() {
    validator = UrlValidatorService();
  });
  
  group('UrlValidatorService', () {
    test('validates valid URLs', () {
      final validUrls = [
        'https://example.com',
        'http://example.com',
        'https://sub.example.com/path',
        'http://sub.example.com/path?param=value',
        'https://example.com:8080',
        'https://example.com/path#fragment',
      ];
      
      for (final url in validUrls) {
        expect(validator.isValidUrl(url), true, reason: 'URL should be valid: $url');
      }
    });
    
    test('rejects invalid URLs', () {
      final invalidUrls = [
        'example.com',
        'ftp://example.com',
        'invalid-url',
        'http:/example.com',
        'https//example.com',
        'http://',
        'https://',
        'http://example',
        'https://example',
        'http://example.',
        'https://example.',
      ];
      
      for (final url in invalidUrls) {
        expect(validator.isValidUrl(url), false, reason: 'URL should be invalid: $url');
      }
    });
    
    test('handles empty and null URLs', () {
      expect(validator.isValidUrl(''), false);
      expect(validator.isValidUrl(null), false);
    });
    
    test('validates URLs with special characters', () {
      final specialUrls = [
        'https://example.com/path with spaces',
        'https://example.com/path%20with%20spaces',
        'https://example.com/path-with-dashes',
        'https://example.com/path_with_underscores',
        'https://example.com/path.with.dots',
      ];
      
      for (final url in specialUrls) {
        expect(validator.isValidUrl(url), true, reason: 'URL should be valid: $url');
      }
    });
    
    test('validates URLs with query parameters', () {
      final queryUrls = [
        'https://example.com?param=value',
        'https://example.com?param1=value1&param2=value2',
        'https://example.com?param=value with spaces',
        'https://example.com?param=value%20with%20spaces',
      ];
      
      for (final url in queryUrls) {
        expect(validator.isValidUrl(url), true, reason: 'URL should be valid: $url');
      }
    });
    
    test('validates URLs with authentication', () {
      final authUrls = [
        'https://user:pass@example.com',
        'http://user:pass@example.com',
        'https://user:pass@example.com/path',
      ];
      
      for (final url in authUrls) {
        expect(validator.isValidUrl(url), true, reason: 'URL should be valid: $url');
      }
    });
    
    test('validates URLs with IP addresses', () {
      final ipUrls = [
        'https://192.168.1.1',
        'http://10.0.0.1',
        'https://172.16.0.1',
        'https://[2001:db8::1]',
        'https://[2001:db8::1]:8080',
      ];
      
      for (final url in ipUrls) {
        expect(validator.isValidUrl(url), true, reason: 'URL should be valid: $url');
      }
    });
  });
}
