import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/analytics_service.dart';

@GenerateMocks([AnalyticsService])
void main() {
  late AnalyticsService analyticsService;
  late MockAnalyticsService mockAnalyticsService;
  
  setUp(() {
    analyticsService = AnalyticsService();
    mockAnalyticsService = MockAnalyticsService();
  });
  
  group('AnalyticsService', () {
    test('tracks URL shortening events', () async {
      const longUrl = 'https://example.com/very/long/url';
      const shortUrl = 'https://short.url/abc123';
      
      await analyticsService.trackUrlShortened(
        longUrl: longUrl,
        shortUrl: shortUrl,
        isAnonymous: true,
      );
      
      verify(mockAnalyticsService.trackUrlShortened(
        longUrl: longUrl,
        shortUrl: shortUrl,
        isAnonymous: true,
      )).called(1);
    });
    
    test('tracks URL copy events', () async {
      const shortUrl = 'https://short.url/abc123';
      
      await analyticsService.trackUrlCopied(shortUrl);
      
      verify(mockAnalyticsService.trackUrlCopied(shortUrl)).called(1);
    });
    
    test('tracks error events', () async {
      const errorMessage = 'Invalid URL format';
      const errorType = 'validation';
      
      await analyticsService.trackError(
        message: errorMessage,
        type: errorType,
      );
      
      verify(mockAnalyticsService.trackError(
        message: errorMessage,
        type: errorType,
      )).called(1);
    });
    
    test('tracks page views', () async {
      const pageName = 'home';
      
      await analyticsService.trackPageView(pageName);
      
      verify(mockAnalyticsService.trackPageView(pageName)).called(1);
    });
    
    test('tracks user interactions', () async {
      const action = 'button_click';
      const label = 'shorten_url';
      
      await analyticsService.trackUserAction(
        action: action,
        label: label,
      );
      
      verify(mockAnalyticsService.trackUserAction(
        action: action,
        label: label,
      )).called(1);
    });
    
    test('tracks performance metrics', () async {
      const metricName = 'api_response_time';
      const value = 150.0;
      
      await analyticsService.trackPerformance(
        metricName: metricName,
        value: value,
      );
      
      verify(mockAnalyticsService.trackPerformance(
        metricName: metricName,
        value: value,
      )).called(1);
    });
    
    test('handles null values gracefully', () async {
      await analyticsService.trackUrlShortened(
        longUrl: null,
        shortUrl: null,
        isAnonymous: true,
      );
      
      verify(mockAnalyticsService.trackUrlShortened(
        longUrl: null,
        shortUrl: null,
        isAnonymous: true,
      )).called(1);
    });
    
    test('handles empty values gracefully', () async {
      await analyticsService.trackUrlShortened(
        longUrl: '',
        shortUrl: '',
        isAnonymous: true,
      );
      
      verify(mockAnalyticsService.trackUrlShortened(
        longUrl: '',
        shortUrl: '',
        isAnonymous: true,
      )).called(1);
    });
    
    test('tracks multiple events in sequence', () async {
      const longUrl = 'https://example.com/very/long/url';
      const shortUrl = 'https://short.url/abc123';
      
      await analyticsService.trackUrlShortened(
        longUrl: longUrl,
        shortUrl: shortUrl,
        isAnonymous: true,
      );
      
      await analyticsService.trackUrlCopied(shortUrl);
      
      verifyInOrder([
        mockAnalyticsService.trackUrlShortened(
          longUrl: longUrl,
          shortUrl: shortUrl,
          isAnonymous: true,
        ),
        mockAnalyticsService.trackUrlCopied(shortUrl),
      ]);
    });
  });
}
