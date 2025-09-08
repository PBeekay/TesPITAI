import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Abonelik Planları',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mevcut abonelik bilgisi
                if (authProvider.user != null) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mevcut Aboneliğiniz',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                _getSubscriptionIcon(
                                  authProvider.user!.subscription.tier,
                                ),
                                color: _getSubscriptionColor(
                                  authProvider.user!.subscription.tier,
                                ),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authProvider.user!.subscription.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      authProvider
                                          .user!
                                          .subscription
                                          .description,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildUsageInfo(authProvider.user!),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Abonelik planları
                const Text(
                  'Abonelik Planları',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ...Subscription.availableSubscriptions.map((subscription) {
                  final isCurrentPlan =
                      authProvider.user?.subscription.tier == subscription.tier;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildSubscriptionCard(subscription, isCurrentPlan),
                  );
                }),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsageInfo(user) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Günlük Kelime Kullanımı:'),
              Text(
                '${user.dailyWordUsage}${user.subscription.wordLimit == -1 ? '' : '/${user.subscription.wordLimit}'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Günlük Dosya Yükleme:'),
              Text(
                '${user.dailyFileUsage}${user.subscription.fileUploadLimit == -1 ? '' : '/${user.subscription.fileUploadLimit}'}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (user.subscription.hasImageUpload) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Text('Resim Yükleme Aktif'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(Subscription subscription, bool isCurrentPlan) {
    return Card(
      elevation: isCurrentPlan ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentPlan
            ? BorderSide(
                color: _getSubscriptionColor(subscription.tier),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getSubscriptionIcon(subscription.tier),
                  color: _getSubscriptionColor(subscription.tier),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subscription.description,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentPlan)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getSubscriptionColor(subscription.tier),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Aktif',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              subscription.price == 0
                  ? 'Ücretsiz'
                  : '₺${subscription.price.toStringAsFixed(2)}/ay',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _getSubscriptionColor(subscription.tier),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureList(subscription),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCurrentPlan
                    ? null
                    : () => _updateSubscription(subscription),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCurrentPlan
                      ? Colors.grey
                      : _getSubscriptionColor(subscription.tier),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  isCurrentPlan ? 'Mevcut Plan' : 'Planı Seç',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(Subscription subscription) {
    return Column(
      children: [
        _buildFeatureItem(
          'Günlük Kelime Limiti',
          subscription.wordLimit == -1
              ? 'Sınırsız'
              : '${subscription.wordLimit} kelime',
        ),
        _buildFeatureItem(
          'Günlük Dosya Yükleme',
          subscription.fileUploadLimit == -1
              ? 'Sınırsız'
              : '${subscription.fileUploadLimit} dosya',
        ),
        _buildFeatureItem(
          'Resim Yükleme',
          subscription.hasImageUpload ? 'Aktif' : 'Pasif',
          subscription.hasImageUpload,
        ),
        if (subscription.isUnlimited)
          _buildFeatureItem('Tüm Özellikler', 'Sınırsız erişim', true),
      ],
    );
  }

  Widget _buildFeatureItem(String title, String value, [bool? isActive]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isActive == false ? Icons.close : Icons.check,
            color: isActive == false ? Colors.red : Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14))),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive == false ? Colors.red : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSubscriptionIcon(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return Icons.star_outline;
      case SubscriptionTier.pro:
        return Icons.star;
      case SubscriptionTier.unlimited:
        return Icons.diamond;
    }
  }

  Color _getSubscriptionColor(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return Colors.blue;
      case SubscriptionTier.pro:
        return Colors.purple;
      case SubscriptionTier.unlimited:
        return Colors.orange;
    }
  }

  Future<void> _updateSubscription(Subscription subscription) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.updateSubscription(
        authProvider.user!.username,
        subscription.tier.toString().split('.').last,
      );

      if (response['success'] == true) {
        // Update user subscription locally
        final updatedUser = authProvider.user!.copyWith(
          subscription: subscription,
        );
        authProvider.updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${subscription.name} planına başarıyla geçtiniz!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Abonelik güncellenemedi'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
