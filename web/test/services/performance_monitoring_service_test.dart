import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/performance_monitoring_service.dart';

@GenerateMocks([PerformanceMonitoringService])
void main() {
  late PerformanceMonitoringService performanceService;
  late MockPerformanceMonitoringService mockPerformanceService;
  
  setUp(() {
    performanceService = PerformanceMonitoringService();
    mockPerformanceService = MockPerformanceMonitoringService();
  });
  
  group('PerformanceMonitoringService', () {
    test('tracks API response time', () async {
      const endpoint = '/api/restricted_urls';
      const duration = 150.0;
      
      await performanceService.trackApiResponseTime(endpoint, duration);
      
      verify(mockPerformanceService.trackApiResponseTime(
        endpoint,
        duration,
      )).called(1);
    });
    
    test('tracks page load time', () async {
      const pageName = 'home';
      const duration = 200.0;
      
      await performanceService.trackPageLoadTime(pageName, duration);
      
      verify(mockPerformanceService.trackPageLoadTime(
        pageName,
        duration,
      )).called(1);
    });
    
    test('tracks user interaction time', () async {
      const action = 'button_click';
      const duration = 50.0;
      
      await performanceService.trackUserInteractionTime(action, duration);
      
      verify(mockPerformanceService.trackUserInteractionTime(
        action,
        duration,
      )).called(1);
    });
    
    test('tracks memory usage', () async {
      const usage = 1024.0; // MB
      
      await performanceService.trackMemoryUsage(usage);
      
      verify(mockPerformanceService.trackMemoryUsage(usage)).called(1);
    });
    
    test('tracks frame rate', () async {
      const fps = 60.0;
      
      await performanceService.trackFrameRate(fps);
      
      verify(mockPerformanceService.trackFrameRate(fps)).called(1);
    });
    
    test('handles negative durations', () async {
      const endpoint = '/api/restricted_urls';
      const duration = -150.0;
      
      await performanceService.trackApiResponseTime(endpoint, duration);
      
      verifyNever(mockPerformanceService.trackApiResponseTime(
        endpoint,
        duration,
      ));
    });
    
    test('handles zero durations', () async {
      const endpoint = '/api/restricted_urls';
      const duration = 0.0;
      
      await performanceService.trackApiResponseTime(endpoint, duration);
      
      verifyNever(mockPerformanceService.trackApiResponseTime(
        endpoint,
        duration,
      ));
    });
    
    test('handles null values', () async {
      await performanceService.trackApiResponseTime(null, 150.0);
      await performanceService.trackPageLoadTime(null, 200.0);
      await performanceService.trackUserInteractionTime(null, 50.0);
      await performanceService.trackMemoryUsage(null);
      await performanceService.trackFrameRate(null);
      
      verifyNever(mockPerformanceService.trackApiResponseTime(any, any));
      verifyNever(mockPerformanceService.trackPageLoadTime(any, any));
      verifyNever(mockPerformanceService.trackUserInteractionTime(any, any));
      verifyNever(mockPerformanceService.trackMemoryUsage(any));
      verifyNever(mockPerformanceService.trackFrameRate(any));
    });
    
    test('tracks multiple metrics in sequence', () async {
      const metrics = [
        ('/api/restricted_urls', 150.0),
        ('home', 200.0),
        ('button_click', 50.0),
      ];
      
      await performanceService.trackApiResponseTime(metrics[0].$1, metrics[0].$2);
      await performanceService.trackPageLoadTime(metrics[1].$1, metrics[1].$2);
      await performanceService.trackUserInteractionTime(metrics[2].$1, metrics[2].$2);
      
      verifyInOrder([
        mockPerformanceService.trackApiResponseTime(metrics[0].$1, metrics[0].$2),
        mockPerformanceService.trackPageLoadTime(metrics[1].$1, metrics[1].$2),
        mockPerformanceService.trackUserInteractionTime(metrics[2].$1, metrics[2].$2),
      ]);
    });
    
    test('tracks performance thresholds', () async {
      const endpoint = '/api/restricted_urls';
      const slowDuration = 1000.0;
      const fastDuration = 100.0;
      
      await performanceService.trackApiResponseTime(endpoint, slowDuration);
      await performanceService.trackApiResponseTime(endpoint, fastDuration);
      
      verify(mockPerformanceService.trackApiResponseTime(
        endpoint,
        slowDuration,
      )).called(1);
      verify(mockPerformanceService.trackApiResponseTime(
        endpoint,
        fastDuration,
      )).called(1);
    });
  });
}
