class ShortUrl {
  const ShortUrl({
    required this.originalUrl,
    required this.shortId,
    required this.shortUrl,
    required this.createdAt,
    this.customAlias,
    this.expiresAt,
    this.clickCount = 0,
    this.userId,
  });

  factory ShortUrl.fromJson(Map<String, dynamic> json) => ShortUrl(
      originalUrl: json['originalUrl'] as String,
      shortId: json['shortId'] as String,
      shortUrl: json['shortUrl'] as String,
      customAlias: json['customAlias'] as String?,
      expiresAt: json['expiresAt'] != null 
        ? DateTime.parse(json['expiresAt'] as String) 
        : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      clickCount: json['clickCount'] as int? ?? 0,
      userId: json['userId'] as String?,
    );

  final String originalUrl;
  
  final String shortId;
  
  final String? customAlias;
  
  final String shortUrl;
  
  final DateTime? expiresAt;
  
  final DateTime createdAt;
  
  final int clickCount;
  
  final String? userId;

  Map<String, dynamic> toJson() => {
      'originalUrl': originalUrl,
      'shortId': shortId,
      'shortUrl': shortUrl,
      if (customAlias != null) 'customAlias': customAlias,
      if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'clickCount': clickCount,
      if (userId != null) 'userId': userId,
    };

  ShortUrl copyWith({
    String? originalUrl,
    String? shortId,
    String? customAlias,
    String? shortUrl,
    DateTime? expiresAt,
    DateTime? createdAt,
    int? clickCount,
    String? userId,
  }) => ShortUrl(
      originalUrl: originalUrl ?? this.originalUrl,
      shortId: shortId ?? this.shortId,
      customAlias: customAlias ?? this.customAlias,
      shortUrl: shortUrl ?? this.shortUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      clickCount: clickCount ?? this.clickCount,
      userId: userId ?? this.userId,
    );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is ShortUrl &&
      other.originalUrl == originalUrl &&
      other.shortId == shortId &&
      other.customAlias == customAlias &&
      other.shortUrl == shortUrl &&
      other.expiresAt == expiresAt &&
      other.createdAt == createdAt &&
      other.clickCount == clickCount &&
      other.userId == userId;
  }

  @override
  int get hashCode => Object.hash(
      originalUrl,
      shortId,
      customAlias,
      shortUrl,
      expiresAt,
      createdAt,
      clickCount,
      userId,
    );

  @override
  String toString() => 'ShortUrl(shortId: $shortId, originalUrl: $originalUrl)';
  
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }
}
