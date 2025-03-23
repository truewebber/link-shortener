import 'package:link_shortener/models/auth/oauth_provider.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        avatarUrl: json['avatar_url'] as String?,
        provider: _providerFromString(json['provider'] as String),
      );

  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final OAuthProvider provider;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'provider': provider.name,
      };

  static OAuthProvider _providerFromString(String value) {
    switch (value.toLowerCase()) {
      case 'google':
        return OAuthProvider.google;
      case 'apple':
        return OAuthProvider.apple;
      case 'github':
        return OAuthProvider.github;
      default:
        throw ArgumentError('Unknown provider: $value');
    }
  }
}
