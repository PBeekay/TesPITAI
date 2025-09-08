import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/analysis_provider.dart';

class FeedbackWidget extends StatefulWidget {
  final int analysisId;
  final bool aiDetected;

  const FeedbackWidget({
    super.key,
    required this.analysisId,
    required this.aiDetected,
  });

  @override
  State<FeedbackWidget> createState() => _FeedbackWidgetState();
}

class _FeedbackWidgetState extends State<FeedbackWidget> {
  bool _showFeedbackForm = false;
  String? _selectedActualResult;
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.feedback, color: Color(0xFF667eea)),
                SizedBox(width: 8),
                Text(
                  'Analiz Doğruluğu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu analiz doğru mu? Geri bildiriminiz sistemin öğrenmesine yardımcı olur.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            if (!_showFeedbackForm) ...[
              // Geri bildirim butonları
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleFeedback(true),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Doğru'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleFeedback(false),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Yanlış'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // Geri bildirim formu
              const Text(
                'Gerçek sonuç nedir?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),

              // Radio butonları
              RadioGroup<String>(
                groupValue: _selectedActualResult,
                onChanged: (value) {
                  setState(() {
                    _selectedActualResult = value;
                  });
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('🤖 AI tarafından yazılmış'),
                      value: 'ai',
                      activeColor: const Color(0xFF667eea),
                    ),
                    RadioListTile<String>(
                      title: const Text('👤 İnsan tarafından yazılmış'),
                      value: 'human',
                      activeColor: const Color(0xFF667eea),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notlar alanı
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ek notlarınız (isteğe bağlı)',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF667eea), width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Form butonları
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : _cancelFeedback,
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667eea),
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Gönder'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleFeedback(bool isCorrect) {
    if (isCorrect) {
      // Doğru tespit - direkt gönder
      _submitFeedback(isCorrect: true);
    } else {
      // Yanlış tespit - form göster
      setState(() {
        _showFeedbackForm = true;
      });
    }
  }

  void _cancelFeedback() {
    setState(() {
      _showFeedbackForm = false;
      _selectedActualResult = null;
      _notesController.clear();
    });
  }

  Future<void> _submitFeedback({bool? isCorrect}) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final analysisProvider = Provider.of<AnalysisProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final success = await analysisProvider.sendFeedback(
        userId: authProvider.user!.username,
        isCorrect:
            isCorrect ??
            (_selectedActualResult != null &&
                ((_selectedActualResult == 'ai' && widget.aiDetected) ||
                    (_selectedActualResult == 'human' && !widget.aiDetected))),
        actualResult: _selectedActualResult,
        feedbackNotes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Geri bildiriminiz kaydedildi! Teşekkürler.'),
            backgroundColor: Colors.green,
          ),
        );

        setState(() {
          _showFeedbackForm = false;
          _selectedActualResult = null;
          _notesController.clear();
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Geri bildirim gönderilemedi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
