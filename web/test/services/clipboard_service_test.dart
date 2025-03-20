import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/clipboard_service.dart';

@GenerateMocks([Clipboard])
void main() {
  late ClipboardService clipboardService;
  late MockClipboard mockClipboard;
  
  setUp(() {
    mockClipboard = MockClipboard();
    clipboardService = ClipboardService();
  });
  
  group('ClipboardService', () {
    test('copies text to clipboard successfully', () async {
      const text = 'https://short.url/abc123';
      
      when(mockClipboard.setData(any))
          .thenAnswer((_) async => true);
      
      final result = await clipboardService.copyToClipboard(text);
      
      expect(result, true);
      verify(mockClipboard.setData(ClipboardData(text: text))).called(1);
    });
    
    test('handles clipboard errors gracefully', () async {
      const text = 'https://short.url/abc123';
      
      when(mockClipboard.setData(any))
          .thenThrow(PlatformException(
            code: 'CLIPBOARD_ERROR',
            message: 'Failed to copy to clipboard',
          ));
      
      final result = await clipboardService.copyToClipboard(text);
      
      expect(result, false);
      verify(mockClipboard.setData(ClipboardData(text: text))).called(1);
    });
    
    test('handles empty text', () async {
      const text = '';
      
      when(mockClipboard.setData(any))
          .thenAnswer((_) async => true);
      
      final result = await clipboardService.copyToClipboard(text);
      
      expect(result, true);
      verify(mockClipboard.setData(ClipboardData(text: text))).called(1);
    });
    
    test('handles null text', () async {
      when(mockClipboard.setData(any))
          .thenAnswer((_) async => true);
      
      final result = await clipboardService.copyToClipboard(null);
      
      expect(result, false);
      verifyNever(mockClipboard.setData(any));
    });
    
    test('handles long text', () async {
      const text = 'https://short.url/' + 'a' * 1000;
      
      when(mockClipboard.setData(any))
          .thenAnswer((_) async => true);
      
      final result = await clipboardService.copyToClipboard(text);
      
      expect(result, true);
      verify(mockClipboard.setData(ClipboardData(text: text))).called(1);
    });
    
    test('handles special characters in text', () async {
      const text = 'https://short.url/abc123!@#$%^&*()';
      
      when(mockClipboard.setData(any))
          .thenAnswer((_) async => true);
      
      final result = await clipboardService.copyToClipboard(text);
      
      expect(result, true);
      verify(mockClipboard.setData(ClipboardData(text: text))).called(1);
    });
  });
}
