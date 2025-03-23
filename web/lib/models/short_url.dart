/// Represents a shortened URL in the system
class ShortUrl {
  /// Creates a new short URL object
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

  /// Creates a short URL from a JSON object
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

  /// The original long URL that was shortened
  final String originalUrl;
  
  /// The shortened ID/path (the part after the domain)
  final String shortId;
  
  /// Optional custom alias for the URL
  final String? customAlias;
  
  /// The complete short URL (with domain)
  final String shortUrl;
  
  /// When the URL will expire (null means never)
  final DateTime? expiresAt;
  
  /// When the URL was created
  final DateTime createdAt;
  
  /// Number of times the URL has been accessed
  final int clickCount;
  
  /// The ID of the user who created this URL (if any)
  final String? userId;

  /// Converts this object to a JSON map
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

  /// Copy constructor to create a new ShortUrl with modified properties
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
  
  /// Checks if the URL has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
  
  /// Calculates time until expiration
  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiresAt!)) return Duration.zero;
    return expiresAt!.difference(now);
  }
}
