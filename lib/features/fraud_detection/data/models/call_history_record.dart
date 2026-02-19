import '../../domain/entities/detection.dart';

class CallHistoryRecord {
  final String id;
  final double riskScore;
  final String riskLevel;
  final String warningMessage;
  final int keywordsFoundCount;
  final String language;
  final int durationSeconds;
  final String analysisType;
  final String? clientId;
  final DateTime createdAt;
  final String? audioUrl;
  final Map<String, dynamic>? serverAnalysis;

  const CallHistoryRecord({
    required this.id,
    required this.riskScore,
    required this.riskLevel,
    required this.warningMessage,
    required this.keywordsFoundCount,
    required this.language,
    required this.durationSeconds,
    required this.analysisType,
    this.clientId,
    required this.createdAt,
    this.audioUrl,
    this.serverAnalysis,
  });

  factory CallHistoryRecord.fromJson(Map<String, dynamic> json) {
    return CallHistoryRecord(
      id: json['id']?.toString() ?? '',
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] as String? ?? 'SAFE',
      warningMessage: json['warning_message'] as String? ?? '',
      keywordsFoundCount: json['keywords_found_count'] as int? ?? 0,
      language: json['language'] as String? ?? 'uz',
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      analysisType: json['analysis_type'] as String? ?? 'realtime',
      clientId: json['client_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      audioUrl: json['audio_url'] as String?,
      serverAnalysis: json['server_analysis'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Detection entity for UI compatibility
  Detection toDetection() {
    return Detection(
      number: clientId ?? 'Unknown',
      score: riskScore,
      reason: warningMessage,
      timestamp: createdAt,
      reported: false,
    );
  }
}
