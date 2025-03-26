import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Simple test class for URL shortening functionality
class UrlShortenerService {
  // Add a delay to simulate network latency
  Future<String> shortenUrl(String url) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return 'https://short.url/${url.hashCode.toRadixString(16).substring(0, 6)}';
  }
}

// A simplified URL shortener form widget for testing
class TestUrlShortenerForm extends StatefulWidget {
  const TestUrlShortenerForm({
    super.key,
    required this.service,
    required this.onComplete,
  });
  final UrlShortenerService service;
  final Function(String) onComplete;

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
  Widget build(BuildContext context) => Column(
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _shortenUrl,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Shorten URL'),
          ),
        ] else ...[
          const Text('Your shortened URL is:'),
          SelectableText(_shortUrl!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _shortUrl = null;
                _urlController.clear();
              });
            },
            child: const Text('Shorten Another URL'),
          ),
        ],
      ],
    );

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}

// A test home screen component
class TestHomeScreen extends StatelessWidget {

  const TestHomeScreen({super.key, required this.urlService});
  final UrlShortenerService urlService;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('URL Shortener'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TestUrlShortenerForm(
            service: urlService,
            onComplete: (url) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL shortened successfully!')),
              );
            },
          ),
        ),
      ),
    );
}

void main() {
  group('HomeScreen', () {
    late UrlShortenerService urlService;

    setUp(() {
      // Use a real implementation instead of a mock for simplicity
      urlService = UrlShortenerService();
    });

    testWidgets('shows URL form and handles shortening process',
        (tester) async {
      // Act - render the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<UrlShortenerService>.value(
            value: urlService,
            child: TestHomeScreen(urlService: urlService),
          ),
        ),
      );

      // Assert - form is shown initially
      expect(find.text('URL Shortener'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Shorten URL'), findsOneWidget);

      // Act - enter URL and tap button
      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.tap(find.text('Shorten URL'));

      // Need to pump once to start processing (CircularProgressIndicator will appear)
      await tester.pump();

      // Verify loading state shows the progress indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Pump until all animations and futures are complete
      await tester.pumpAndSettle();

      // Assert - result is shown
      expect(find.text('Your shortened URL is:'), findsOneWidget);
      // We don't need to check the exact URL since we're using the real implementation
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('Shorten Another URL'), findsOneWidget);
    });

    testWidgets('allows creating another URL after shortening',
        (tester) async {
      // Act - render, enter URL, and get result
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<UrlShortenerService>.value(
            value: urlService,
            child: TestHomeScreen(urlService: urlService),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'https://example.com');
      await tester.tap(find.text('Shorten URL'));
      await tester.pumpAndSettle(); // Wait for result

      // Act - tap "Shorten Another URL"
      await tester.tap(find.text('Shorten Another URL'));
      await tester.pump();

      // Assert - form is shown again
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Shorten URL'), findsOneWidget);
      expect(find.text('Your shortened URL is:'), findsNothing);
    });
  });
}
