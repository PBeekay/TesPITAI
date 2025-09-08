class AnalysisResult {
  final int? analysisId;
  final String analysis;
  final double aiProbability;
  final bool aiDetected;
  final double confidenceScore;
  final Map<String, dynamic>? rawResult;

  AnalysisResult({
    this.analysisId,
    required this.analysis,
    required this.aiProbability,
    required this.aiDetected,
    required this.confidenceScore,
    this.rawResult,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      analysisId: json['analysisId'],
      analysis: json['analysis'] ?? '',
      aiProbability: (json['aiProbability'] ?? 0).toDouble(),
      aiDetected: json['aiDetected'] ?? false,
      confidenceScore: (json['confidenceScore'] ?? 0).toDouble(),
      rawResult: json['rawResult'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysisId': analysisId,
      'analysis': analysis,
      'aiProbability': aiProbability,
      'aiDetected': aiDetected,
      'confidenceScore': confidenceScore,
      'rawResult': rawResult,
    };
  }
}
