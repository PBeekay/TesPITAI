enum SubscriptionTier { basic, pro, unlimited }

class Subscription {
  final SubscriptionTier tier;
  final String name;
  final String description;
  final double price;
  final int wordLimit;
  final int fileUploadLimit;
  final bool hasImageUpload;
  final bool isUnlimited;

  const Subscription({
    required this.tier,
    required this.name,
    required this.description,
    required this.price,
    required this.wordLimit,
    required this.fileUploadLimit,
    required this.hasImageUpload,
    required this.isUnlimited,
  });

  static const List<Subscription> availableSubscriptions = [
    Subscription(
      tier: SubscriptionTier.basic,
      name: 'Temel',
      description: 'Günlük temel kullanım için',
      price: 0.0,
      wordLimit: 1000,
      fileUploadLimit: 5,
      hasImageUpload: false,
      isUnlimited: false,
    ),
    Subscription(
      tier: SubscriptionTier.pro,
      name: 'Profesyonel',
      description: 'Gelişmiş özellikler ve daha fazla kullanım',
      price: 29.99,
      wordLimit: 10000,
      fileUploadLimit: 50,
      hasImageUpload: true,
      isUnlimited: false,
    ),
    Subscription(
      tier: SubscriptionTier.unlimited,
      name: 'Sınırsız',
      description: 'Tüm özellikler ve sınırsız kullanım',
      price: 99.99,
      wordLimit: -1, // -1 means unlimited
      fileUploadLimit: -1, // -1 means unlimited
      hasImageUpload: true,
      isUnlimited: true,
    ),
  ];

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.toString() == 'SubscriptionTier.${json['tier']}',
        orElse: () => SubscriptionTier.basic,
      ),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      wordLimit: json['wordLimit'] ?? 0,
      fileUploadLimit: json['fileUploadLimit'] ?? 0,
      hasImageUpload: json['hasImageUpload'] ?? false,
      isUnlimited: json['isUnlimited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tier': tier.toString().split('.').last,
      'name': name,
      'description': description,
      'price': price,
      'wordLimit': wordLimit,
      'fileUploadLimit': fileUploadLimit,
      'hasImageUpload': hasImageUpload,
      'isUnlimited': isUnlimited,
    };
  }
}
