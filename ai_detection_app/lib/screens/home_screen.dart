import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/subscription.dart';
import 'analysis_screen.dart';
import 'subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Tespit Sistemi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (value) {
                  if (value == 'logout') {
                    _handleLogout(authProvider);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(width: 8),
                            Text(
                              'Hoş geldiniz, ${authProvider.user?.username}',
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getSubscriptionColor(
                              authProvider.user?.subscription.tier,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            authProvider.user?.subscription.name ?? 'Temel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Çıkış Yap'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [AnalysisScreen(), StatsScreen(), SubscriptionScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF667eea),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'AI Analiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'İstatistikler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Abonelik'),
        ],
      ),
    );
  }

  void _handleLogout(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.logout();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }

  Color _getSubscriptionColor(SubscriptionTier? tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return Colors.grey;
      case SubscriptionTier.pro:
        return Colors.orange;
      case SubscriptionTier.unlimited:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

// İstatistikler sayfası (basit)
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'İstatistikler',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bu özellik yakında eklenecek',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
