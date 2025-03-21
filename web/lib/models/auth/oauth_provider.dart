enum OAuthProvider {
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
    }
  }
  
  String get iconPath {
    switch (this) {
      case OAuthProvider.google:
        return 'assets/icons/google.png';
      case OAuthProvider.apple:
        return 'assets/icons/apple.png';
      case OAuthProvider.github:
        return 'assets/icons/github.png';
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
    }
  }
}
