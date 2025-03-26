/// Mock implementation of the URL shortener service
/// This can be used in both VM and browser environments
class MockUrlService {
  final Map<String, String> _shortenedUrls = {};
  final Duration delay;
  final bool simulateErrors;

  /// Create a new mock URL service
  /// - [delay]: Artificial delay to simulate network latency
  /// - [simulateErrors]: When true, will simulate errors for specific inputs
  MockUrlService({
    this.delay = const Duration(milliseconds: 300),
    this.simulateErrors = false,
  });

  /// Simulates shortening a URL
  ///
  /// Returns a shortened URL in the format "https://short.url/{hash}"
  /// If [simulateErrors] is true, will throw an error for empty URLs or ones
  /// containing "error" or "invalid"
  Future<String> shortenUrl(String url) async {
    // Simulate network delay
    await Future.delayed(delay);

    // Validate URL (very basic validation for testing)
    if (url.isEmpty) {
      throw Exception('URL cannot be empty');
    }

    // Simulate specific error cases when enabled
    if (simulateErrors && (url.contains('error') || url.contains('invalid'))) {
      throw Exception('Invalid URL format');
    }

    // Check if we've already shortened this URL
    if (_shortenedUrls.containsKey(url)) {
      return _shortenedUrls[url]!;
    }

    // Generate a shortened URL (use consistent hash for testing)
    final hash = url.hashCode.toRadixString(16).substring(0, 6);
    final shortUrl = 'https://short.url/$hash';

    // Store for future reference
    _shortenedUrls[url] = shortUrl;

    return shortUrl;
  }

  /// Get all shortened URLs
  Map<String, String> get shortenedUrls => Map.unmodifiable(_shortenedUrls);

  /// Clear all shortened URLs
  void reset() {
    _shortenedUrls.clear();
  }
}
