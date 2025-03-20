import 'package:flutter_test/flutter_test.dart';
import 'package:link_shortener/services/api_service.dart';
import '../../lib/services/error_handler_service.dart';

void main() {
  late ErrorHandlerService errorHandler;
  
  setUp(() {
    errorHandler = ErrorHandlerService();
  });
  
  group('ErrorHandlerService', () {
    test('handles network errors correctly', () {
      final error = Exception('Network error');
      final result = errorHandler.handleError(error);
      
      expect(result.message, 'Network error: Network error');
      expect(result.type, ErrorType.network);
      expect(result.isUserFriendly, true);
    });
    
    test('handles API errors correctly', () {
      final error = ApiException('Invalid URL format');
      final result = errorHandler.handleError(error);
      
      expect(result.message, 'Invalid URL format');
      expect(result.type, ErrorType.api);
      expect(result.isUserFriendly, true);
    });
    
    test('handles validation errors correctly', () {
      final error = ValidationException('URL must start with http:// or https://');
      final result = errorHandler.handleError(error);
      
      expect(result.message, 'URL must start with http:// or https://');
      expect(result.type, ErrorType.validation);
      expect(result.isUserFriendly, true);
    });
    
    test('handles unknown errors correctly', () {
      final error = Exception('Unknown error');
      final result = errorHandler.handleError(error);
      
      expect(result.message, 'An unexpected error occurred. Please try again later.');
      expect(result.type, ErrorType.unknown);
      expect(result.isUserFriendly, true);
    });
    
    test('handles null errors correctly', () {
      final result = errorHandler.handleError(null);
      
      expect(result.message, 'An unexpected error occurred. Please try again later.');
      expect(result.type, ErrorType.unknown);
      expect(result.isUserFriendly, true);
    });
    
    test('handles empty error messages correctly', () {
      final error = Exception('');
      final result = errorHandler.handleError(error);
      
      expect(result.message, 'An unexpected error occurred. Please try again later.');
      expect(result.type, ErrorType.unknown);
      expect(result.isUserFriendly, true);
    });
    
    test('handles error stack traces correctly', () {
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;
      final result = errorHandler.handleError(error, stackTrace);
      
      expect(result.message, 'Test error');
      expect(result.type, ErrorType.unknown);
      expect(result.isUserFriendly, true);
      expect(result.stackTrace, stackTrace);
    });
    
    test('handles custom error types correctly', () {
      final error = CustomException('Custom error message');
      final result = errorHandler.handleError(error);
      
      expect(result.message, 'Custom error message');
      expect(result.type, ErrorType.unknown);
      expect(result.isUserFriendly, true);
    });
    
    test('handles multiple error types correctly', () {
      final errors = [
        Exception('Network error'),
        ApiException('Invalid URL format'),
        ValidationException('Invalid input'),
        Exception('Unknown error'),
      ];
      
      for (final error in errors) {
        final result = errorHandler.handleError(error);
        expect(result.isUserFriendly, true);
      }
    });
  });
}

class CustomException implements Exception {
  final String message;
  CustomException(this.message);
  
  @override
  String toString() => message;
}
