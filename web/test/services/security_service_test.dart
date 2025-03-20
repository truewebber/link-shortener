import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/security_service.dart';

@GenerateMocks([SecurityService])
void main() {
  late SecurityService securityService;
  late MockSecurityService mockSecurityService;
  
  setUp(() {
    securityService = SecurityService();
    mockSecurityService = MockSecurityService();
  });
  
  group('SecurityService', () {
    test('validates URLs correctly', () {
      const validUrls = [
        'https://example.com',
        'http://example.com',
        'https://sub.example.com/path',
        'http://sub.example.com/path?param=value',
        'https://example.com:8080',
        'https://example.com/path#fragment',
      ];
      
      for (final url in validUrls) {
        expect(securityService.isValidUrl(url), true, reason: 'URL should be valid: $url');
      }
      
      const invalidUrls = [
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
        expect(securityService.isValidUrl(url), false, reason: 'URL should be invalid: $url');
      }
    });
    
    test('sanitizes URLs correctly', () {
      const urls = [
        ('https://example.com/path with spaces', 'https://example.com/path%20with%20spaces'),
        ('https://example.com/path-with-dashes', 'https://example.com/path-with-dashes'),
        ('https://example.com/path_with_underscores', 'https://example.com/path_with_underscores'),
        ('https://example.com/path.with.dots', 'https://example.com/path.with.dots'),
      ];
      
      for (final (input, expected) in urls) {
        expect(securityService.sanitizeUrl(input), expected);
      }
    });
    
    test('validates URL length', () {
      const maxLength = 2048;
      const validUrl = 'https://example.com';
      final longUrl = 'https://example.com/${'a' * maxLength}';
      
      expect(securityService.isValidUrlLength(validUrl), true);
      expect(securityService.isValidUrlLength(longUrl), false);
    });
    
    test('validates URL protocols', () {
      const validProtocols = ['http', 'https'];
      const invalidProtocols = ['ftp', 'sftp', 'file', 'data'];
      
      for (final protocol in validProtocols) {
        expect(
          securityService.isValidProtocol(protocol),
          true,
          reason: 'Protocol should be valid: $protocol',
        );
      }
      
      for (final protocol in invalidProtocols) {
        expect(
          securityService.isValidProtocol(protocol),
          false,
          reason: 'Protocol should be invalid: $protocol',
        );
      }
    });
    
    test('validates URL domains', () {
      const validDomains = [
        'example.com',
        'sub.example.com',
        'example.co.uk',
        'example.org',
        'example.net',
      ];
      
      const invalidDomains = [
        'example',
        'example.',
        '.example.com',
        'example..com',
        'example.com.',
      ];
      
      for (final domain in validDomains) {
        expect(
          securityService.isValidDomain(domain),
          true,
          reason: 'Domain should be valid: $domain',
        );
      }
      
      for (final domain in invalidDomains) {
        expect(
          securityService.isValidDomain(domain),
          false,
          reason: 'Domain should be invalid: $domain',
        );
      }
    });
    
    test('validates URL paths', () {
      const validPaths = [
        '/path',
        '/path/with/slashes',
        '/path-with-dashes',
        '/path_with_underscores',
        '/path.with.dots',
      ];
      
      const invalidPaths = [
        'path',
        '//path',
        '/path//with//slashes',
        '/path/../with/parent',
      ];
      
      for (final path in validPaths) {
        expect(
          securityService.isValidPath(path),
          true,
          reason: 'Path should be valid: $path',
        );
      }
      
      for (final path in invalidPaths) {
        expect(
          securityService.isValidPath(path),
          false,
          reason: 'Path should be invalid: $path',
        );
      }
    });
    
    test('validates URL query parameters', () {
      const validQueries = [
        'param=value',
        'param1=value1&param2=value2',
        'param=value with spaces',
        'param=value%20with%20spaces',
      ];
      
      const invalidQueries = [
        'param',
        'param=',
        '=value',
        'param=value&',
        '&param=value',
      ];
      
      for (final query in validQueries) {
        expect(
          securityService.isValidQuery(query),
          true,
          reason: 'Query should be valid: $query',
        );
      }
      
      for (final query in invalidQueries) {
        expect(
          securityService.isValidQuery(query),
          false,
          reason: 'Query should be invalid: $query',
        );
      }
    });
    
    test('validates URL fragments', () {
      const validFragments = [
        'fragment',
        'fragment-with-dashes',
        'fragment_with_underscores',
        'fragment.with.dots',
      ];
      
      const invalidFragments = [
        'fragment with spaces',
        'fragment#with#hashes',
        'fragment/with/slashes',
      ];
      
      for (final fragment in validFragments) {
        expect(
          securityService.isValidFragment(fragment),
          true,
          reason: 'Fragment should be valid: $fragment',
        );
      }
      
      for (final fragment in invalidFragments) {
        expect(
          securityService.isValidFragment(fragment),
          false,
          reason: 'Fragment should be invalid: $fragment',
        );
      }
    });
    
    test('handles null and empty values', () {
      expect(securityService.isValidUrl(null), false);
      expect(securityService.isValidUrl(''), false);
      expect(securityService.sanitizeUrl(null), '');
      expect(securityService.sanitizeUrl(''), '');
    });
  });
}
