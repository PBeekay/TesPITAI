import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class AnalysisResultWidget extends StatelessWidget {
  final AnalysisResult result;

  const AnalysisResultWidget({super.key, required this.result});

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
            // Başlık
            Row(
              children: [
                Icon(
                  Icons.psychology,
                  color: result.aiDetected ? Colors.red : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Tespit Sonucu',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sonuç kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: result.aiDetected
                    ? Colors.red.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: result.aiDetected
                      ? Colors.red.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    result.aiDetected ? Icons.smart_toy : Icons.person,
                    color: result.aiDetected ? Colors.red : Colors.green,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          result.aiDetected
                              ? 'AI TARAFINDAN YAZILMIŞ'
                              : 'İNSAN TARAFINDAN YAZILMIŞ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: result.aiDetected
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Güven skoru: %${result.confidenceScore.toInt()}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Olasılık göstergesi
            Row(
              children: [
                const Text(
                  'AI Olasılığı:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: LinearProgressIndicator(
                    value: result.aiProbability / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      result.aiProbability > 50 ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '%${result.aiProbability.toInt()}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Detaylı analiz
            const Text(
              'Detaylı Analiz:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                result.analysis,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
