import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:link_shortener/services/api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../test_helper.dart';
import '../test_helper.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late ApiService apiService;
  late MockClient mockClient;
  late TestAppConfig testConfig;
  
  setUp(() {
    mockClient = MockClient();
    testConfig = TestAppConfig();
    apiService = ApiService(testConfig, client: mockClient);
  });
  
  group('ApiService', () {
    test('shortens URL successfully', () async {
      const longUrl = 'https://example.com/very/long/url';
      const shortUrl = 'https://short.url/abc123';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"short_url": "$shortUrl"}',
        201,
      ));
      
      final result = await apiService.shortenUrl(longUrl);
      
      expect(result, shortUrl);
      verify(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(1);
    });
    
    test('handles API errors gracefully', () async {
      const longUrl = 'https://example.com/very/long/url';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"message": "Invalid URL format"}',
        400,
      ));
      
      expect(
        () => apiService.shortenUrl(longUrl),
        throwsA(isA<ApiException>()),
      );
    });
    
    test('handles network errors gracefully', () async {
      const longUrl = 'https://example.com/very/long/url';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenThrow(http.ClientException('Network error'));
      
      expect(
        () => apiService.shortenUrl(longUrl),
        throwsA(isA<ApiException>()),
      );
    });
    
    test('handles rate limiting', () async {
      const longUrl = 'https://example.com/very/long/url';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"message": "Rate limit exceeded"}',
        429,
      ));
      
      expect(
        () => apiService.shortenUrl(longUrl),
        throwsA(isA<ApiException>()),
      );
    });
    
    test('handles server errors gracefully', () async {
      const longUrl = 'https://example.com/very/long/url';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"message": "Internal server error"}',
        500,
      ));
      
      expect(
        () => apiService.shortenUrl(longUrl),
        throwsA(isA<ApiException>()),
      );
    });
    
    test('handles invalid response format', () async {
      const longUrl = 'https://example.com/very/long/url';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        'Invalid JSON',
        200,
      ));
      
      expect(
        () => apiService.shortenUrl(longUrl),
        throwsA(isA<ApiException>()),
      );
    });
    
    test('handles empty response', () async {
      const longUrl = 'https://example.com/very/long/url';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response('', 200));
      
      expect(
        () => apiService.shortenUrl(longUrl),
        throwsA(isA<ApiException>()),
      );
    });
    
    test('handles multiple requests', () async {
      const longUrl = 'https://example.com/very/long/url';
      const shortUrl = 'https://short.url/abc123';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"short_url": "$shortUrl"}',
        201,
      ));
      
      final results = await Future.wait([
        apiService.shortenUrl(longUrl),
        apiService.shortenUrl(longUrl),
        apiService.shortenUrl(longUrl),
      ]);
      
      expect(results.every((result) => result == shortUrl), true);
      verify(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(3);
    });
    
    test('handles concurrent requests', () async {
      const longUrl = 'https://example.com/very/long/url';
      const shortUrl = 'https://short.url/abc123';
      
      when(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        '{"short_url": "$shortUrl"}',
        201,
      ));
      
      final futures = List.generate(
        5,
        (_) => apiService.shortenUrl(longUrl),
      );
      
      final results = await Future.wait(futures);
      expect(results.every((result) => result == shortUrl), true);
      verify(mockClient.post(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).called(5);
    });
    
    test('checkHealth returns true when API is healthy', () async {
      when(mockClient.get(
        argThat(isA<Uri>()),
      )).thenAnswer((_) async => http.Response('', 200));
      
      final result = await apiService.checkHealth();
      expect(result, true);
    });
    
    test('checkHealth returns false when API is unhealthy', () async {
      when(mockClient.get(
        argThat(isA<Uri>()),
      )).thenAnswer((_) async => http.Response('', 500));
      
      final result = await apiService.checkHealth();
      expect(result, false);
    });
    
    test('getUrlInfo returns URL information on success', () async {
      const urlHash = 'abc123';
      final urlInfo = {
        'original_url': 'https://example.com',
        'short_url': 'https://short.url/abc123',
        'created_at': '2024-03-17T12:00:00Z',
        'expires_at': '2024-06-17T12:00:00Z',
      };
      
      when(mockClient.get(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode(urlInfo),
        200,
      ));
      
      final result = await apiService.getUrlInfo(urlHash);
      expect(result, urlInfo);
    });
    
    test('getUrlInfo throws ApiException on failure', () async {
      const urlHash = 'abc123';
      const errorMessage = 'URL not found';
      
      when(mockClient.get(
        argThat(isA<Uri>()),
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        jsonEncode({'message': errorMessage}),
        404,
      ));
      
      expect(
        () => apiService.getUrlInfo(urlHash),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
