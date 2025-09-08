import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';

class AnalysisProvider with ChangeNotifier {
  AnalysisResult? _currentAnalysis;
  bool _isLoading = false;
  String? _error;

  AnalysisResult? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Metin analizi
  Future<bool> analyzeText(String content, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.analyzeText(content, userId);

      if (response['success'] == true) {
        _currentAnalysis = AnalysisResult.fromJson(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Analiz başarısız';
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

  // Dosya analizi
  Future<bool> analyzeFile(String filePath, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final file = File(filePath);
      final response = await ApiService.analyzeFile(file, userId);

      if (response['success'] == true) {
        _currentAnalysis = AnalysisResult.fromJson(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Analiz başarısız';
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

  // Resim analizi
  Future<bool> analyzeImage(XFile imageFile, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.analyzeImage(imageFile, userId);

      if (response['success'] == true) {
        _currentAnalysis = AnalysisResult.fromJson(response);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['error'] ?? 'Analiz başarısız';
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

  // Geri bildirim gönderme
  Future<bool> sendFeedback({
    required String userId,
    required bool isCorrect,
    String? actualResult,
    String? feedbackNotes,
  }) async {
    if (_currentAnalysis?.analysisId == null) return false;

    try {
      final response = await ApiService.sendFeedback(
        analysisId: _currentAnalysis!.analysisId!,
        userId: userId,
        isCorrect: isCorrect,
        actualResult: actualResult,
        feedbackNotes: feedbackNotes,
      );

      return response['success'] == true;
    } catch (e) {
      _error = 'Geri bildirim gönderme hatası: $e';
      notifyListeners();
      return false;
    }
  }

  // Analizi temizleme
  void clearAnalysis() {
    _currentAnalysis = null;
    _error = null;
    notifyListeners();
  }

  // Hata temizleme
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
