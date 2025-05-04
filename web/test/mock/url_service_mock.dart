import 'package:flutter/material.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/models/ttl.dart';
import 'package:link_shortener/services/url_service.dart';

/// Mock implementation of the URL shortener service
/// This can be used in both VM and browser environments
class MockUrlService implements UrlService {

  /// Create a new mock URL service
  /// - [delay]: Artificial delay to simulate network latency
  /// - [simulateErrors]: When true, will simulate errors for specific inputs
  MockUrlService({
    this.delay = const Duration(milliseconds: 300),
    this.simulateErrors = false,
  });
  final Map<String, String> _shortenedUrls = {};
  final Duration delay;
  final bool simulateErrors;
  
  /// Tracks the last URL that was shortened
  String? lastShortenedUrl;

  /// Simulates shortening a URL
  ///
  /// Returns a shortened URL in the format "https://short.url/{hash}"
  /// If [simulateErrors] is true, will throw an error for empty URLs or ones
  /// containing "error" or "invalid"
  Future<String> shortenUrl(String url) async {
    // Track the last URL
    lastShortenedUrl = url;
    
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
  
  @override
  Future<String> shortenRestrictedUrl(String url) async {
    return shortenUrl(url);
  }
  
  @override
  Future<String> createShortUrl({
    required String url,
    BuildContext? context,
    required TTL ttl,
  }) async {
    return shortenUrl(url);
  }

  /// Get all shortened URLs
  Map<String, String> get shortenedUrls => Map.unmodifiable(_shortenedUrls);

  /// Clear all shortened URLs
  void reset() {
    _shortenedUrls.clear();
    lastShortenedUrl = null;
  }
  
  // Implement remaining required UrlService methods as no-op
  @override
  Future<bool> deleteUrl(String shortId, {BuildContext? context}) async {
    return true;
  }
  
  @override
  Future<ShortUrl> getUrlDetails(String shortId, {BuildContext? context}) async {
    // Return a dummy ShortUrl for testing
    return ShortUrl(
      shortId: shortId,
      shortUrl: 'https://short.url/$shortId',
      originalUrl: 'https://example.com',
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 90)),
    );
  }
  
  @override
  Future<List<ShortUrl>> getUserUrls({BuildContext? context}) async {
    // Return empty list for testing
    return [];
  }
  
  @override
  Future<ShortUrl> updateUrl({
    required String shortId,
    String? customAlias,
    DateTime? expiresAt,
    BuildContext? context,
  }) async {
    // Return a dummy updated ShortUrl
    return ShortUrl(
      shortId: shortId,
      shortUrl: 'https://short.url/$shortId',
      originalUrl: 'https://example.com',
      createdAt: DateTime.now(),
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 90)),
    );
  }
  
  @override
  void dispose() {
    // No-op for testing
  }
}
