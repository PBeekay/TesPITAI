import 'subscription.dart';

class User {
  final String username;
  final String name;
  final String role;
  final Subscription subscription;
  final int dailyWordUsage;
  final int dailyFileUsage;
  final DateTime lastUsageReset;

  User({
    required this.username,
    required this.name,
    required this.role,
    required this.subscription,
    this.dailyWordUsage = 0,
    this.dailyFileUsage = 0,
    DateTime? lastUsageReset,
  }) : lastUsageReset = lastUsageReset ?? DateTime.now();

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? 'user',
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : Subscription.availableSubscriptions.first,
      dailyWordUsage: json['dailyWordUsage'] ?? 0,
      dailyFileUsage: json['dailyFileUsage'] ?? 0,
      lastUsageReset: json['lastUsageReset'] != null
          ? DateTime.parse(json['lastUsageReset'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'role': role,
      'subscription': subscription.toJson(),
      'dailyWordUsage': dailyWordUsage,
      'dailyFileUsage': dailyFileUsage,
      'lastUsageReset': lastUsageReset.toIso8601String(),
    };
  }

  // Check if user can perform text analysis
  bool canAnalyzeText(int wordCount) {
    if (subscription.isUnlimited) return true;
    if (subscription.wordLimit == -1) return true;
    return dailyWordUsage + wordCount <= subscription.wordLimit;
  }

  // Check if user can upload files
  bool canUploadFile() {
    if (subscription.isUnlimited) return true;
    if (subscription.fileUploadLimit == -1) return true;
    return dailyFileUsage < subscription.fileUploadLimit;
  }

  // Check if user can upload images
  bool canUploadImage() {
    return subscription.hasImageUpload;
  }

  // Reset daily usage if it's a new day
  User resetDailyUsageIfNeeded() {
    final now = DateTime.now();
    if (now.difference(lastUsageReset).inDays >= 1) {
      return User(
        username: username,
        name: name,
        role: role,
        subscription: subscription,
        dailyWordUsage: 0,
        dailyFileUsage: 0,
        lastUsageReset: now,
      );
    }
    return this;
  }

  // Update usage after analysis
  User updateUsage({int? wordCount, bool? fileUploaded}) {
    return User(
      username: username,
      name: name,
      role: role,
      subscription: subscription,
      dailyWordUsage: dailyWordUsage + (wordCount ?? 0),
      dailyFileUsage: dailyFileUsage + (fileUploaded == true ? 1 : 0),
      lastUsageReset: lastUsageReset,
    );
  }

  // Copy with method for updating user
  User copyWith({
    String? username,
    String? name,
    String? role,
    Subscription? subscription,
    int? dailyWordUsage,
    int? dailyFileUsage,
    DateTime? lastUsageReset,
  }) {
    return User(
      username: username ?? this.username,
      name: name ?? this.name,
      role: role ?? this.role,
      subscription: subscription ?? this.subscription,
      dailyWordUsage: dailyWordUsage ?? this.dailyWordUsage,
      dailyFileUsage: dailyFileUsage ?? this.dailyFileUsage,
      lastUsageReset: lastUsageReset ?? this.lastUsageReset,
    );
  }
}
