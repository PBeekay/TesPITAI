import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api';

  // Giriş yapma
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Bağlantı hatası: $e'};
    }
  }

  // Metin analizi
  static Future<Map<String, dynamic>> analyzeText(
    String content,
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/check-text'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content, 'userId': userId}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Dosya analizi
  static Future<Map<String, dynamic>> analyzeFile(
    File file,
    String userId,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/check-homework'),
      );

      request.fields['userId'] = userId;
      request.files.add(
        await http.MultipartFile.fromPath('homework', file.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      return jsonDecode(responseBody);
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Resim analizi
  static Future<Map<String, dynamic>> analyzeImage(
    XFile imageFile,
    String userId,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/check-image'),
      );

      request.fields['userId'] = userId;
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      return jsonDecode(responseBody);
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Geri bildirim gönderme
  static Future<Map<String, dynamic>> sendFeedback({
    required int analysisId,
    required String userId,
    required bool isCorrect,
    String? actualResult,
    String? feedbackNotes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/feedback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'analysisId': analysisId,
          'userId': userId,
          'isCorrect': isCorrect,
          'actualResult': actualResult,
          'feedbackNotes': feedbackNotes,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // İstatistikleri getirme
  static Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/stats'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Abonelik planlarını getirme
  static Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription-plans'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Abonelik güncelleme
  static Future<Map<String, dynamic>> updateSubscription(
    String userId,
    String subscriptionTier,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/update-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'subscriptionTier': subscriptionTier,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }

  // Kullanım limitlerini kontrol etme
  static Future<Map<String, dynamic>> checkUsageLimits(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usage-limits/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'error': 'Bağlantı hatası: $e'};
    }
  }
}
