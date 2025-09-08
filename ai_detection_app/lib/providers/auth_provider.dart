import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/subscription.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Test kullanıcıları
  static const Map<String, Map<String, dynamic>> _testUsers = {
    'temel': {
      'username': 'temel',
      'password': '123',
      'name': 'Temel Kullanıcı',
      'subscription': SubscriptionTier.basic,
    },
    'premium': {
      'username': 'premium',
      'password': '123',
      'name': 'Premium Kullanıcı',
      'subscription': SubscriptionTier.pro,
    },
    'sınırsız': {
      'username': 'sınırsız',
      'password': '123',
      'name': 'Sınırsız Kullanıcı',
      'subscription': SubscriptionTier.unlimited,
    },
  };

  // Giriş yapma
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Test kullanıcıları için özel kontrol
      if (_testUsers.containsKey(username.toLowerCase())) {
        final testUser = _testUsers[username.toLowerCase()]!;
        if (testUser['password'] == password) {
          final subscription = Subscription.availableSubscriptions.firstWhere(
            (sub) => sub.tier == testUser['subscription'],
          );

          _user = User(
            username: testUser['username'],
            name: testUser['name'],
            role: 'user',
            subscription: subscription,
          );

          await _saveUserToStorage();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _error = 'Şifre hatalı';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      // Normal API çağrısı
      final response = await ApiService.login(username, password);

      if (response['success'] == true) {
        _user = User.fromJson(response['user']);
        await _saveUserToStorage();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Giriş başarısız';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Bağlantı hatası: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Çıkış yapma
  Future<void> logout() async {
    _user = null;
    await _removeUserFromStorage();
    notifyListeners();
  }

  // Kullanıcıyı storage'a kaydetme
  Future<void> _saveUserToStorage() async {
    if (_user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _user!.username);
      await prefs.setString('user_data', _user!.toJson().toString());
    }
  }

  // Kullanıcıyı storage'dan silme
  Future<void> _removeUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('user_data');
  }

  // Uygulama başlangıcında kullanıcıyı yükleme
  Future<void> loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');

    if (username != null) {
      // Kullanıcı bilgilerini basit şekilde saklayalım
      _user = User(
        username: username,
        name: username,
        role: 'user',
        subscription:
            Subscription.availableSubscriptions.first, // Default to basic
      );
      notifyListeners();
    }
  }

  // Kullanıcıyı güncelleme
  void updateUser(User user) {
    _user = user;
    _saveUserToStorage();
    notifyListeners();
  }

  // Hata temizleme
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
