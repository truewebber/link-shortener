import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/utils/notification_utils.dart';

class UrlService {
  factory UrlService() => _instance;
  UrlService._internal();
  
  static final UrlService _instance = UrlService._internal();
  
  final _config = AppConfig.fromWindow();
  final _client = http.Client();
  final _authService = AuthService();

  Future<ShortUrl> createShortUrl({
    required String originalUrl,
    String? customAlias,
    DateTime? expiresAt,
    BuildContext? context,
  }) async {
    _checkUserAuthorized(context: context);

    try {
      final headers = await _authService.getAuthHeaders(context: context);
      
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
        throw Exception('non 200 status code: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating short URL: $e');
      }
      
      NotificationUtils.showError(context, 'Failed to create short URL');

      rethrow;
    }
  }
  
  Future<List<ShortUrl>> getUserUrls({BuildContext? context}) async {
    _checkUserAuthorized(context: context);
    
    try {
      final headers = await _authService.getAuthHeaders(context: context);
      
      final response = await _client.get(
        Uri.parse('${_config.apiBaseUrl}/api/urls'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((item) => ShortUrl.fromJson(item)).toList();
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('non 200 status code: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user URLs: $e');
      }

      NotificationUtils.showError(context, 'Error getting list of URLs');
      
      rethrow;
    }
  }

  Future<ShortUrl> getUrlDetails(String shortId, {BuildContext? context}) async {
    _checkUserAuthorized(context: context);

    try {
      final headers = await _authService.getAuthHeaders(context: context);
      
      final response = await _client.get(
        Uri.parse('${_config.apiBaseUrl}/api/urls/$shortId'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ShortUrl.fromJson(data);
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('non 200 status code: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting URL details: $e');
      }

      NotificationUtils.showError(context, 'Error getting URL details');

      rethrow;
    }
  }

  Future<bool> deleteUrl(String shortId, {BuildContext? context}) async {
    _checkUserAuthorized(context: context);
    
    try {
      final headers = await _authService.getAuthHeaders(context: context);
      
      final response = await _client.delete(
        Uri.parse('${_config.apiBaseUrl}/api/urls/$shortId'),
        headers: headers,
      );
      
      if (response.statusCode == 204 || response.statusCode == 200) {
        NotificationUtils.showSuccess(context, 'Ссылка успешно удалена');

        return true;
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('non 200 status code: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting URL: $e');
      }

      NotificationUtils.showError(context, 'Error deleting URL');
      
      rethrow;
    }
  }

  Future<ShortUrl> updateUrl({
    required String shortId,
    String? customAlias,
    DateTime? expiresAt,
    BuildContext? context,
  }) async {
    _checkUserAuthorized(context: context);
    
    try {
      final headers = await _authService.getAuthHeaders(context: context);
      
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
        NotificationUtils.showSuccess(context, 'URL was updated');
        
        final data = jsonDecode(response.body);
        return ShortUrl.fromJson(data);
      } else {
        final errorMsg = _parseErrorMessage(response);
        throw Exception('non 200 status code: $errorMsg');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating URL: $e');
      }
      
      NotificationUtils.showError(context, 'Error updating URL');
      
      rethrow;
    }
  }
  
  String _parseErrorMessage(http.Response response) => response.body;

  void _checkUserAuthorized({BuildContext? context}) {
    if (_authService.isAuthenticated) {
      return;
    }

    NotificationUtils.showWarning(context, 'To list your short URL you have to be logged in');

    throw Exception('User is not authenticated');
  }

  void dispose() {
    _client.close();
  }
}
