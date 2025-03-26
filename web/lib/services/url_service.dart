import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:link_shortener/config/app_config.dart';
import 'package:link_shortener/models/short_url.dart';
import 'package:link_shortener/models/ttl.dart';
import 'package:link_shortener/services/api_exception.dart';
import 'package:link_shortener/services/auth_service.dart';
import 'package:link_shortener/services/recaptcha_service.dart';
import 'package:link_shortener/utils/notification_utils.dart';

class UrlService {
  factory UrlService() => _instance;
  UrlService._internal();
  
  static final UrlService _instance = UrlService._internal();
  
  final _config = AppConfig.fromWindow();
  final _client = http.Client();
  final _authService = AuthService();
  final _recaptchaService = RecaptchaService();

  String get _baseUrl => _config.apiBaseUrl;

  Uri _buildUrl(String path) {
    final cleanBase = _baseUrl.endsWith('/') ? _baseUrl.substring(0, _baseUrl.length - 1) : _baseUrl;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;

    return Uri.parse('$cleanBase/$cleanPath');
  }

  Future<String> shortenRestrictedUrl(String url) async {
    final requestUrl = _buildUrl('/api/restricted_urls');

    if (kDebugMode) {
      print('Shorten restricted URL: $url');
      print('API endpoint: ${requestUrl.toString()}');
    }

    try {
      // Get reCAPTCHA token for anonymous users
      final recaptchaToken = await _recaptchaService.execute('create_unauthorized_short_url');

      final response = await _client.post(
        requestUrl,
        headers: {
          'Content-Type': 'application/json',
          'X-Recaptcha-Token': recaptchaToken,
        },
        body: jsonEncode({'url': url}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print('Successfully shortened URL: ${data['short_url']}');
        }
        return data['short_url'] as String;
      } else {
        var errorMessage = 'Failed to shorten URL';

        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          }
        } catch (e) {
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

  Future<String> createShortUrl({
    BuildContext? context,
    required String url,
    required TTL ttl,
  }) async {
    final requestUrl = _buildUrl('/api/urls');

    if (kDebugMode) {
      print('Shorten URL: $url, ttl: ');
      print('API endpoint: ${requestUrl.toString()}');
    }

    try {
      final headers = await _authService.getAuthHeaders(context: context);

      final payload = {
        'url': url,
        'ttl': _ttlRequestValue(ttl),
      };

      final response = await _client.post(
        requestUrl,
        headers: headers,
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['short_url'] as String;
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

  String _ttlRequestValue(TTL ttl) {
    switch (ttl) {
      case TTL.threeMonths:
        return '3months';
      case TTL.sixMonths:
        return '6months';
      case TTL.twelveMonths:
        return '12months';
      case TTL.never:
        return 'never';
    }
  }
  
  Future<List<ShortUrl>> getUserUrls({BuildContext? context}) async {
    final requestUrl = _buildUrl('/api/urls');

    if (kDebugMode) {
      print('API endpoint: ${requestUrl.toString()}');
    }

    try {
      final headers = await _authService.getAuthHeaders(context: context);
      
      final response = await _client.get(
        requestUrl,
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

  void dispose() {
    _client.close();
  }
}
