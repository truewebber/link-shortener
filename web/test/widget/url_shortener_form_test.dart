import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../mock/url_service_mock.dart';

// Import your actual widget classes here
// import 'package:link_shortener/widgets/url_shortener_form.dart';

// For testing purposes, we'll use the test version from home_screen_test.dart
// In a real implementation, you would import and test the actual widget

void main() {
  group('URL Shortener Form', () {
    late MockUrlService mockUrlService;

    setUp(() {
      mockUrlService = MockUrlService(
        delay:
            const Duration(milliseconds: 100), // Short delay for faster tests
      );
    });

    testWidgets('validates empty URL input', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestUrlShortenerForm(
              service: mockUrlService,
              onComplete: (url) {},
            ),
          ),
        ),
      );

      // Attempt to submit without entering a URL
      await tester.tap(find.text('Shorten URL'));
      await tester.pump();

      // Verify error message is displayed
      expect(find.text('Please enter a URL'), findsOneWidget);
    });

    testWidgets('shortens valid URL and shows result',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestUrlShortenerForm(
              service: mockUrlService,
              onComplete: (url) {},
            ),
          ),
        ),
      );

      // Enter valid URL
      const testUrl = 'https://example.com';
      await tester.enterText(find.byType(TextField), testUrl);

      // Submit the form
      await tester.tap(find.text('Shorten URL'));

      // Check for loading indicator
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the operation to complete
      await tester.pumpAndSettle();

      // Verify results are shown
      expect(find.text('Your shortened URL is:'), findsOneWidget);

      // The exact shortened URL will depend on the hash implementation
      // but we can verify a shortened URL exists
      expect(find.byType(SelectableText), findsOneWidget);

      // Verify the mock service was called correctly
      expect(mockUrlService.shortenedUrls.containsKey(testUrl), isTrue);
    });

    testWidgets('handles errors gracefully', (WidgetTester tester) async {
      // Create a service that simulates errors
      final errorService = MockUrlService(simulateErrors: true);

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TestUrlShortenerForm(
              service: errorService,
              onComplete: (url) {},
            ),
          ),
        ),
      );

      // Enter a URL that will trigger an error
      await tester.enterText(find.byType(TextField), 'http://invalid.com');

      // Submit the form
      await tester.tap(find.text('Shorten URL'));
      await tester.pump(); // Start the future

      // Wait for operation to complete
      await tester.pumpAndSettle();

      // Verify error is displayed
      expect(find.textContaining('An error occurred'), findsOneWidget);
    });
  });
}

// Copy of the test widget from home_screen_test.dart
// In a real implementation, you'd import the actual widget

class TestUrlShortenerForm extends StatefulWidget {
  final dynamic service;
  final Function(String) onComplete;

  const TestUrlShortenerForm({
    Key? key,
    required this.service,
    required this.onComplete,
  }) : super(key: key);

  @override
  _TestUrlShortenerFormState createState() => _TestUrlShortenerFormState();
}

class _TestUrlShortenerFormState extends State<TestUrlShortenerForm> {
  final _urlController = TextEditingController();
  String? _errorText;
  bool _isLoading = false;
  String? _shortUrl;

  Future<void> _shortenUrl() async {
    final url = _urlController.text;
    if (url.isEmpty) {
      setState(() {
        _errorText = 'Please enter a URL';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final shortUrl = await widget.service.shortenUrl(url);
      setState(() {
        _shortUrl = shortUrl;
        _isLoading = false;
      });
      widget.onComplete(shortUrl);
    } catch (e) {
      setState(() {
        _errorText = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_shortUrl == null) ...[
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Enter a URL',
              errorText: _errorText,
              hintText: 'https://example.com',
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _shortenUrl,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('Shorten URL'),
          ),
        ] else ...[
          Text('Your shortened URL is:'),
          SelectableText(_shortUrl!),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _shortUrl = null;
                _urlController.clear();
              });
            },
            child: Text('Shorten Another URL'),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
