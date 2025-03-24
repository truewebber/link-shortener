import 'package:link_shortener/models/auth/user.dart';

class UserSession {
  UserSession({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    this.user,
  });

  factory UserSession.fromJson(Map<String, dynamic> json) {
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
      json['access_token_expiry_ms'] as int,
    );

    final userObj = json.containsKey('user') && json['user'] != null
        ? User.fromJson(json['user'] as Map<String, dynamic>)
        : null;

    return UserSession(
      token: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: expiresAt,
      user: userObj,
    );
  }

  final String token;

  final String refreshToken;

  final DateTime expiresAt;
  
  final User? user;

  bool get isExpired => expiresAt.isBefore(DateTime.now());

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'access_token': token,
      'refresh_token': refreshToken,
      'access_token_expiry_ms': expiresAt.millisecondsSinceEpoch,
    };
    
    if (user != null) {
      data['user'] = user!.toJson();
    }
    
    return data;
  }

  @override
  String toString() => 'UserSession(token: ${token.substring(0, 10)}..., '
      'refreshToken: ${refreshToken.substring(0, 10)}..., '
      'expiresAt: $expiresAt, '
      'user: ${user != null ? "${user!.name} (${user!.email})" : "null"})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSession &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          refreshToken == other.refreshToken &&
          expiresAt == other.expiresAt &&
          user == other.user;

  @override
  int get hashCode => token.hashCode ^ refreshToken.hashCode ^ expiresAt.hashCode ^ (user?.hashCode ?? 0);
}
