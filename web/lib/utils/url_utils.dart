import 'package:flutter/foundation.dart';

/// Utility class for URL-related operations
class UrlUtils {
  /// Validates if the provided string is a valid URL with http or https scheme
  /// This validation properly handles URL fragments (parts after the # character)
  static bool isValidUrl(String url) {
    if (url.isEmpty) {
      return false;
    }

    try {
      // Special handling for URLs with fragments
      if (url.contains('#')) {
        // Split the URL at the fragment
        final parts = url.split('#');
        final urlWithoutFragment = parts[0];
        
        // Check if the base URL is valid
        final baseUri = Uri.parse(urlWithoutFragment);
        final isValid = baseUri.isAbsolute && 
                     (baseUri.scheme == 'http' || baseUri.scheme == 'https') && 
                     baseUri.host.isNotEmpty;

        return isValid;
      }
      
      // Regular URL validation for URLs without fragments
      final uri = Uri.parse(url);
      return uri.isAbsolute && 
             (uri.scheme == 'http' || uri.scheme == 'https') && 
             uri.host.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating URL: $e');
      }
      return false;
    }
  }

  /// Returns a validation error message if the URL is invalid, otherwise null
  static String? getValidationErrorMessage(String url) {
    if (url.isEmpty) {
      return 'Please enter a URL';
    }

    if (!isValidUrl(url)) {
      return 'Please enter a valid URL starting with http:// or https://';
    }

    return null;
  }
}
