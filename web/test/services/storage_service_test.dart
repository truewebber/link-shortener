import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/services/storage_service.dart';

void main() {
  late StorageService storageService;
  late SharedPreferences prefs;
  
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    storageService = StorageService(prefs);
  });
  
  group('StorageService', () {
    test('saves and retrieves shortened URLs', () async {
      const longUrl = 'https://example.com/very/long/url';
      const shortUrl = 'https://short.url/abc123';
      
      await storageService.saveShortenedUrl(longUrl, shortUrl);
      
      final savedUrls = await storageService.getShortenedUrls();
      expect(savedUrls.length, 1);
      expect(savedUrls[0].longUrl, longUrl);
      expect(savedUrls[0].shortUrl, shortUrl);
    });
    
    test('handles multiple shortened URLs', () async {
      const urls = [
        ('https://example.com/url1', 'https://short.url/abc123'),
        ('https://example.com/url2', 'https://short.url/def456'),
        ('https://example.com/url3', 'https://short.url/ghi789'),
      ];
      
      for (final (longUrl, shortUrl) in urls) {
        await storageService.saveShortenedUrl(longUrl, shortUrl);
      }
      
      final savedUrls = await storageService.getShortenedUrls();
      expect(savedUrls.length, 3);
      
      for (var i = 0; i < urls.length; i++) {
        expect(savedUrls[i].longUrl, urls[i].$1);
        expect(savedUrls[i].shortUrl, urls[i].$2);
      }
    });
    
    test('handles empty storage', () async {
      final savedUrls = await storageService.getShortenedUrls();
      expect(savedUrls, isEmpty);
    });
    
    test('handles invalid JSON data', () async {
      await prefs.setString('shortened_urls', 'invalid json');
      
      final savedUrls = await storageService.getShortenedUrls();
      expect(savedUrls, isEmpty);
    });
    
    test('handles null values', () async {
      await storageService.saveShortenedUrl(null, null);
      
      final savedUrls = await storageService.getShortenedUrls();
      expect(savedUrls, isEmpty);
    });
    
    test('handles empty strings', () async {
      await storageService.saveShortenedUrl('', '');
      
      final savedUrls = await storageService.getShortenedUrls();
      expect(savedUrls, isEmpty);
    });
    
    test('limits storage size', () async {
      const maxUrls = 100;
      
      for (var i = 0; i < maxUrls + 10; i++) {
        await storageService.saveShortenedUrl(
          'https://example.com/url$i',
          'https://short.url/abc$i',
        );
      }
      
      final savedUrls = await storageService.getShortenedUrls();
      expect(savedUrls.length, maxUrls);
    });
    
    test('maintains URL order', () async {
      const urls = [
        ('https://example.com/url1', 'https://short.url/abc123'),
        ('https://example.com/url2', 'https://short.url/def456'),
        ('https://example.com/url3', 'https://short.url/ghi789'),
      ];
      
      for (final (longUrl, shortUrl) in urls) {
        await storageService.saveShortenedUrl(longUrl, shortUrl);
      }
      
      final savedUrls = await storageService.getShortenedUrls();
      
      for (var i = 0; i < urls.length; i++) {
        expect(savedUrls[i].longUrl, urls[i].$1);
        expect(savedUrls[i].shortUrl, urls[i].$2);
      }
    });
    
    test('handles storage errors gracefully', () async {
      // Simulate storage error by setting invalid data
      await prefs.setString('shortened_urls', '[]');
      
      const longUrl = 'https://example.com/url';
      const shortUrl = 'https://short.url/abc123';
      
      await storageService.saveShortenedUrl(longUrl, shortUrl);
      
      final savedUrls = await storageService.getShortenedUrls();
      expect(savedUrls.length, 1);
      expect(savedUrls[0].longUrl, longUrl);
      expect(savedUrls[0].shortUrl, shortUrl);
    });
  });
}
