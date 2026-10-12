class DetectionModel {
  final int id;
  final int userId;
  final String modality;
  final String inputSummary;
  final double confidence;
  final String verdict;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  DetectionModel({
    required this.id,
    required this.userId,
    required this.modality,
    required this.inputSummary,
    required this.confidence,
    required this.verdict,
    required this.metadata,
    required this.createdAt,
  });

  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    return DetectionModel(
      id: json['id'],
      userId: json['user_id'],
      modality: json['modality'],
      inputSummary: json['input_summary'],
      confidence: (json['confidence'] as num).toDouble(),
      verdict: json['verdict'],
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'modality': modality,
      'input_summary': inputSummary,
      'confidence': confidence,
      'verdict': verdict,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Display formatting utilities
  double get confidencePercentage => confidence * 100;
  
  String get displayVerdict => verdict.toUpperCase();
  
  bool get isAi => verdict.toLowerCase() == 'ai';
}
