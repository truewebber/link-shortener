import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/network_service.dart';
import '../test_helper.dart';

@GenerateMocks([http.Client])
void main() {
  late NetworkService networkService;
  late MockClient mockClient;
  late TestAppConfig testConfig;
  
  setUp(() {
    mockClient = MockClient();
    testConfig = TestAppConfig();
    networkService = NetworkService(testConfig);
  });
  
  group('NetworkService', () {
    test('checks network connectivity successfully', () async {
      when(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health')))
          .thenAnswer((_) async => http.Response('', 200));
      
      final result = await networkService.checkConnectivity();
      expect(result, true);
    });
    
    test('handles network connectivity failure', () async {
      when(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health')))
          .thenThrow(http.ClientException('Network error'));
      
      final result = await networkService.checkConnectivity();
      expect(result, false);
    });
    
    test('handles server error response', () async {
      when(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health')))
          .thenAnswer((_) async => http.Response('', 500));
      
      final result = await networkService.checkConnectivity();
      expect(result, false);
    });
    
    test('handles timeout', () async {
      when(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health')))
          .thenAnswer((_) => Future.delayed(
                const Duration(seconds: 6),
                () => http.Response('', 200),
              ));
      
      final result = await networkService.checkConnectivity();
      expect(result, false);
    });
    
    test('handles invalid URL', () async {
      when(mockClient.get(Uri.parse('invalid-url')))
          .thenThrow(http.ClientException('Invalid URL'));
      
      final result = await networkService.checkConnectivity();
      expect(result, false);
    });
    
    test('handles null response', () async {
      when(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health')))
          .thenAnswer((_) async => null);
      
      final result = await networkService.checkConnectivity();
      expect(result, false);
    });
    
    test('handles empty response', () async {
      when(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health')))
          .thenAnswer((_) async => http.Response('', 200));
      
      final result = await networkService.checkConnectivity();
      expect(result, true);
    });
    
    test('handles multiple requests', () async {
      when(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health')))
          .thenAnswer((_) async => http.Response('', 200));
      
      final results = await Future.wait([
        networkService.checkConnectivity(),
        networkService.checkConnectivity(),
        networkService.checkConnectivity(),
      ]);
      
      expect(results.every((result) => result == true), true);
      verify(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health'))).called(3);
    });
    
    test('handles concurrent requests', () async {
      when(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health')))
          .thenAnswer((_) async => http.Response('', 200));
      
      final futures = List.generate(
        5,
        (_) => networkService.checkConnectivity(),
      );
      
      final results = await Future.wait(futures);
      expect(results.every((result) => result == true), true);
      verify(mockClient.get(Uri.parse('${testConfig.apiBaseUrl}/health'))).called(5);
    });
  });
}
