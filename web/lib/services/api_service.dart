import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Exception thrown when API requests fail
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException(this.message, {this.statusCode});
  
  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status code: $statusCode)' : ''}';
}

/// Service for interacting with the Link Shortener API
class ApiService {
  final String baseUrl;
  final Duration timeout;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    this.timeout = const Duration(seconds: 10),
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Disposes the HTTP client when the service is no longer needed
  void dispose() {
    _client.close();
  }

  /// Shortens a URL
  /// 
  /// Returns the shortened URL as a string
  /// Throws [ApiException] if the request fails
  Future<String> shortenUrl(String url) async {
    try {
      if (kDebugMode) {
        print('Shortening URL: $url');
        print('API endpoint: $baseUrl/api/restricted_urls');
      }
      
      final response = await _client.post(
        Uri.parse('$baseUrl/api/restricted_urls'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url}),
      ).timeout(timeout);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Successfully shortened URL: ${data['short_url']}');
        }
        return data['short_url'] as String;
      } else {
        String errorMessage = 'Failed to shorten URL';
        
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // If we can't parse the error message, use the default one
          if (kDebugMode) {
            print('Could not parse error response: $e');
          }
        }
        
        if (kDebugMode) {
          print('API error: $errorMessage (${response.statusCode})');
        }
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    } on http.ClientException catch (e) {
      final message = 'Network error: ${e.message}';
      if (kDebugMode) {
        print(message);
      }
      throw ApiException(message);
    } on FormatException catch (e) {
      final message = 'Invalid response format from server: ${e.message}';
      if (kDebugMode) {
        print(message);
      }
      throw ApiException(message);
    } on Exception catch (e) {
      final message = 'Error: ${e.toString()}';
      if (kDebugMode) {
        print(message);
      }
      throw ApiException(message);
    }
  }

  /// Checks if the API is healthy
  /// 
  /// Returns true if the API is healthy, false otherwise
  Future<bool> checkHealth() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/health'))
          .timeout(timeout);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Health check failed: $e');
      }
      return false;
    }
  }
  
  /// Gets information about a shortened URL
  /// 
  /// Returns a map containing information about the URL
  /// Throws [ApiException] if the request fails
  Future<Map<String, dynamic>> getUrlInfo(String urlHash) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/urls/$urlHash'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        String errorMessage = 'Failed to get URL information';
        
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
          // If we can't parse the error message, use the default one
        }
        
        throw ApiException(errorMessage, statusCode: response.statusCode);
      }
    } on http.ClientException catch (e) {
      throw ApiException('Network error: ${e.message}');
    } on FormatException catch (_) {
      throw ApiException('Invalid response format from server');
    } on Exception catch (e) {
      throw ApiException('Error: ${e.toString()}');
    }
  }
} 