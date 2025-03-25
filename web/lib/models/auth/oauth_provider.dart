import 'package:flutter/material.dart';

enum OAuthProvider {
  unknown,
  google,
  apple,
  github,
}

extension OAuthProviderExtension on OAuthProvider {
  String get name {
    switch (this) {
      case OAuthProvider.google:
        return 'Google';
      case OAuthProvider.apple:
        return 'Apple';
      case OAuthProvider.github:
        return 'GitHub';
      case OAuthProvider.unknown:
        throw UnimplementedError();
    }
  }
  
  IconData get icon {
    switch (this) {
      case OAuthProvider.google:
        return Icons.g_mobiledata;
      case OAuthProvider.apple:
        return Icons.apple;
      case OAuthProvider.github:
        return Icons.code;
      default:
        return Icons.account_circle;
    }
  }


  
  String get backgroundColor {
    switch (this) {
      case OAuthProvider.google:
        return '#FFFFFF';
      case OAuthProvider.apple:
        return '#000000';
      case OAuthProvider.github:
        return '#24292E';
      case OAuthProvider.unknown:
        throw UnimplementedError();
    }
  }
  
  String get textColor {
    switch (this) {
      case OAuthProvider.google:
        return '#757575';
      case OAuthProvider.apple:
        return '#FFFFFF';
      case OAuthProvider.github:
        return '#FFFFFF';
      case OAuthProvider.unknown:
        throw UnimplementedError();
    }
  }
}
