import 'package:flutter/foundation.dart';
import 'package:link_shortener/models/auth/oauth_provider.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.provider,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['id'] is int ? json['id'] as int : int.parse(json['id'].toString());
      return User(
        id: id,
        name: json['name']?.toString() ?? 'Unknown',
        email: json['email']?.toString() ?? 'no-email@example.com',
        avatarUrl: json['avatar_url']?.toString(),
        provider: _providerFromString(json['provider']?.toString() ?? 'google'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing User from JSON: $e');
        print('JSON data: $json');
      }

      return const User(
        id: -1,
        name: 'Unknown User',
        email: 'unknown@example.com',
        provider: OAuthProvider.unknown,
      );
    }
  }

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
