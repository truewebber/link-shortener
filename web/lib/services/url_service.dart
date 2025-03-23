import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/services/auth_service.dart';

/// Service for handling URL shortening operations
class UrlService {
  factory UrlService() => _instance;
  UrlService._internal();
  
  // Singleton instance
  static final UrlService _instance = UrlService._internal();
  
  final _config = AppConfig.fromWindow();
  final _client = http.Client();
  final _authService = AuthService();
  
  // Create a shortened URL
  Future<ShortUrl> createShortUrl({
    required String originalUrl,
    String? customAlias,
    DateTime? expiresAt,
  }) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final payload = {
        'originalUrl': originalUrl,
        if (customAlias != null && customAlias.isNotEmpty) 'customAlias': customAlias,
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      };
      
      final response = await _client.post(
        Uri.parse('${_config.apiBaseUrl}/api/urls'),
        headers: headers,
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShortUrl.fromJson(data);
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('Failed to create short URL: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating short URL: $e');
      }
      rethrow;
    }
  }
  
  // Get a list of URLs for the authenticated user
  Future<List<ShortUrl>> getUserUrls() async {
    if (!_authService.isAuthenticated) {
      throw Exception('User is not authenticated');
    }
    
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await _client.get(
        Uri.parse('${_config.apiBaseUrl}/api/urls'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => ShortUrl.fromJson(item)).toList();
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('Failed to get user URLs: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user URLs: $e');
      }
      rethrow;
    }
  }
  
  // Get details of a specific URL
  Future<ShortUrl> getUrlDetails(String shortId) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await _client.get(
        Uri.parse('${_config.apiBaseUrl}/api/urls/$shortId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShortUrl.fromJson(data);
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('Failed to get URL details: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting URL details: $e');
      }
      rethrow;
    }
  }
  
  // Delete a shortened URL
  Future<bool> deleteUrl(String shortId) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User is not authenticated');
    }
    
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await _client.delete(
        Uri.parse('${_config.apiBaseUrl}/api/urls/$shortId'),
        headers: headers,
      );
      
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('Failed to delete URL: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting URL: $e');
      }
      rethrow;
    }
  }
  
  // Update a shortened URL (for authenticated users)
  Future<ShortUrl> updateUrl({
    required String shortId,
    String? customAlias,
    DateTime? expiresAt,
  }) async {
    if (!_authService.isAuthenticated) {
      throw Exception('User is not authenticated');
    }
    
    try {
      final headers = await _authService.getAuthHeaders();
      
      final payload = {
        if (customAlias != null) 'customAlias': customAlias,
        if (expiresAt != null) 'expiresAt': expiresAt.toIso8601String(),
      };
      
      final response = await _client.patch(
        Uri.parse('${_config.apiBaseUrl}/api/urls/$shortId'),
        headers: headers,
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShortUrl.fromJson(data);
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('Failed to update URL: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating URL: $e');
      }
      rethrow;
    }
  }
  
  // Helper method to parse error messages from the API
  String _parseErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data.containsKey('message')) {
        return data['message'] as String;
      } else if (data.containsKey('error')) {
        return data['error'] as String;
      } else {
        return 'Error ${response.statusCode}';
      }
    } catch (e) {
      return 'Error ${response.statusCode}';
    }
  }
  
  // Dispose method to clean up resources
  void dispose() {
    _client.close();
  }
}
