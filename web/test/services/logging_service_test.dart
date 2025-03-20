import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/logging_service.dart';

@GenerateMocks([LoggingService])
void main() {
  late LoggingService loggingService;
  late MockLoggingService mockLoggingService;
  
  setUp(() {
    loggingService = LoggingService();
    mockLoggingService = MockLoggingService();
  });
  
  group('LoggingService', () {
    test('logs debug messages', () {
      const message = 'Debug message';
      
      loggingService.debug(message);
      
      verify(mockLoggingService.debug(message)).called(1);
    });
    
    test('logs info messages', () {
      const message = 'Info message';
      
      loggingService.info(message);
      
      verify(mockLoggingService.info(message)).called(1);
    });
    
    test('logs warning messages', () {
      const message = 'Warning message';
      
      loggingService.warning(message);
      
      verify(mockLoggingService.warning(message)).called(1);
    });
    
    test('logs error messages', () {
      const message = 'Error message';
      
      loggingService.error(message);
      
      verify(mockLoggingService.error(message)).called(1);
    });
    
    test('logs messages with stack traces', () {
      const message = 'Error with stack trace';
      final stackTrace = StackTrace.current;
      
      loggingService.error(message, stackTrace);
      
      verify(mockLoggingService.error(message, stackTrace)).called(1);
    });
    
    test('handles null messages', () {
      loggingService.debug(null);
      loggingService.info(null);
      loggingService.warning(null);
      loggingService.error(null);
      
      verifyNever(mockLoggingService.debug(any));
      verifyNever(mockLoggingService.info(any));
      verifyNever(mockLoggingService.warning(any));
      verifyNever(mockLoggingService.error(any));
    });
    
    test('handles empty messages', () {
      loggingService.debug('');
      loggingService.info('');
      loggingService.warning('');
      loggingService.error('');
      
      verifyNever(mockLoggingService.debug(any));
      verifyNever(mockLoggingService.info(any));
      verifyNever(mockLoggingService.warning(any));
      verifyNever(mockLoggingService.error(any));
    });
    
    test('logs messages with different log levels', () {
      const messages = [
        ('Debug message', LogLevel.debug),
        ('Info message', LogLevel.info),
        ('Warning message', LogLevel.warning),
        ('Error message', LogLevel.error),
      ];
      
      for (final (message, level) in messages) {
        switch (level) {
          case LogLevel.debug:
            loggingService.debug(message);
            verify(mockLoggingService.debug(message)).called(1);
            break;
          case LogLevel.info:
            loggingService.info(message);
            verify(mockLoggingService.info(message)).called(1);
            break;
          case LogLevel.warning:
            loggingService.warning(message);
            verify(mockLoggingService.warning(message)).called(1);
            break;
          case LogLevel.error:
            loggingService.error(message);
            verify(mockLoggingService.error(message)).called(1);
            break;
        }
      }
    });
    
    test('logs multiple messages in sequence', () {
      const messages = [
        'Debug message',
        'Info message',
        'Warning message',
        'Error message',
      ];
      
      loggingService.debug(messages[0]);
      loggingService.info(messages[1]);
      loggingService.warning(messages[2]);
      loggingService.error(messages[3]);
      
      verifyInOrder([
        mockLoggingService.debug(messages[0]),
        mockLoggingService.info(messages[1]),
        mockLoggingService.warning(messages[2]),
        mockLoggingService.error(messages[3]),
      ]);
    });
    
    test('handles special characters in messages', () {
      const message = 'Special chars: !@#$%^&*()_+{}[]|\\:;"\'<>,.?/~`';
      
      loggingService.debug(message);
      loggingService.info(message);
      loggingService.warning(message);
      loggingService.error(message);
      
      verify(mockLoggingService.debug(message)).called(1);
      verify(mockLoggingService.info(message)).called(1);
      verify(mockLoggingService.warning(message)).called(1);
      verify(mockLoggingService.error(message)).called(1);
    });
  });
}
