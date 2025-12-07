import '../../domain/entities/detection.dart';

/// Detailed threat information including transcription, analysis, and metadata
class ThreatDetailsModel {
  final Detection detection;
  final String transcription;
  final String languageDetected;
  final double riskScore;
  final String riskLevel; // "safe", "suspicious", "danger"
  final double confidence;
  final List<KeywordMatch> keywordMatches;
  final VoiceFeatures voiceFeatures;
  final String warningMessage;
  final bool shouldWarnUser;
  
  // New fields for enhanced UI
  final String? callerName;
  final Duration? callDuration;
  final String? location;
  final String? carrier;
  final String callType; // "Incoming" or "Outgoing"
  final int reportedCount;
  final List<String> flaggedReasons;
  final AIAnalysis? aiAnalysis;
  final List<TimelineEvent>? timelineEvents;

  const ThreatDetailsModel({
    required this.detection,
    required this.transcription,
    required this.languageDetected,
    required this.riskScore,
    required this.riskLevel,
    required this.confidence,
    required this.keywordMatches,
    required this.voiceFeatures,
    required this.warningMessage,
    required this.shouldWarnUser,
    this.callerName,
    this.callDuration,
    this.location,
    this.carrier,
    this.callType = 'Incoming',
    this.reportedCount = 0,
    this.flaggedReasons = const [],
    this.aiAnalysis,
    this.timelineEvents,
  });

  /// Creates ThreatDetailsModel from Detection and additional data
  factory ThreatDetailsModel.fromDetection(
    Detection detection, {
    String? transcription,
    String? languageDetected,
    double? riskScore,
    String? riskLevel,
    double? confidence,
    List<KeywordMatch>? keywordMatches,
    VoiceFeatures? voiceFeatures,
    String? warningMessage,
    bool? shouldWarnUser,
    String? callerName,
    Duration? callDuration,
    String? location,
    String? carrier,
    String? callType,
    int? reportedCount,
    List<String>? flaggedReasons,
    AIAnalysis? aiAnalysis,
    List<TimelineEvent>? timelineEvents,
  }) {
    return ThreatDetailsModel(
      detection: detection,
      transcription: transcription ?? detection.reason,
      languageDetected: languageDetected ?? 'Unknown',
      riskScore: riskScore ?? detection.score,
      riskLevel: riskLevel ?? _getRiskLevelFromScore(detection.score),
      confidence: confidence ?? 0.0,
      keywordMatches: keywordMatches ?? [],
      voiceFeatures: voiceFeatures ?? const VoiceFeatures(),
      warningMessage: warningMessage ?? detection.reason,
      shouldWarnUser: shouldWarnUser ?? detection.score >= 30,
      callerName: callerName,
      callDuration: callDuration,
      location: location,
      carrier: carrier,
      callType: callType ?? 'Incoming',
      reportedCount: reportedCount ?? 0,
      flaggedReasons: flaggedReasons ?? [],
      aiAnalysis: aiAnalysis,
      timelineEvents: timelineEvents,
    );
  }

  /// Creates ThreatDetailsModel from JSON
  factory ThreatDetailsModel.fromJson(Map<String, dynamic> json, Detection detection) {
    return ThreatDetailsModel(
      detection: detection,
      transcription: json['transcription'] ?? '',
      languageDetected: json['language_detected'] ?? 'Unknown',
      riskScore: json['risk_score']?.toDouble() ?? detection.score,
      riskLevel: json['risk_level'] ?? _getRiskLevelFromScore(detection.score),
      confidence: json['confidence']?.toDouble() ?? 0.0,
      keywordMatches: (json['keyword_matches'] as List<dynamic>?)
              ?.map((e) => KeywordMatch.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      voiceFeatures: json['voice_features'] != null
          ? VoiceFeatures.fromJson(json['voice_features'] as Map<String, dynamic>)
          : const VoiceFeatures(),
      warningMessage: json['warning_message'] ?? detection.reason,
      shouldWarnUser: json['should_warn_user'] ?? false,
      callerName: json['caller_name'],
      callDuration: json['call_duration_seconds'] != null
          ? Duration(seconds: json['call_duration_seconds'] as int)
          : null,
      location: json['location'],
      carrier: json['carrier'],
      callType: json['call_type'] ?? 'Incoming',
      reportedCount: json['reported_count'] ?? 0,
      flaggedReasons: (json['flagged_reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      aiAnalysis: json['ai_analysis'] != null
          ? AIAnalysis.fromJson(json['ai_analysis'] as Map<String, dynamic>)
          : null,
      timelineEvents: (json['timeline_events'] as List<dynamic>?)
              ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  static String _getRiskLevelFromScore(double score) {
    if (score <= 30) return 'safe';
    if (score <= 70) return 'suspicious';
    return 'danger';
  }
}

class KeywordMatch {
  final String keyword;
  final String category;
  final double weight;

  const KeywordMatch({
    required this.keyword,
    required this.category,
    required this.weight,
  });

  factory KeywordMatch.fromJson(Map<String, dynamic> json) {
    return KeywordMatch(
      keyword: json['keyword'] ?? '',
      category: json['category'] ?? '',
      weight: json['weight']?.toDouble() ?? 0.0,
    );
  }

  String get categoryLabel {
    switch (category) {
      case 'threat_intimidation':
        return 'Threat & Intimidation';
      case 'bank_information_request':
        return 'Bank Information Request';
      case 'urgent_action_required':
        return 'Urgent Action Required';
      case 'suspicious_link':
        return 'Suspicious Link';
      default:
        return category.replaceAll('_', ' ').split(' ').map((word) {
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }
}

class VoiceFeatures {
  final double speakingRate;
  final double pitchMean;
  final double stressLevel;

  const VoiceFeatures({
    this.speakingRate = 0.0,
    this.pitchMean = 0.0,
    this.stressLevel = 0.0,
  });

  factory VoiceFeatures.fromJson(Map<String, dynamic> json) {
    return VoiceFeatures(
      speakingRate: json['speaking_rate']?.toDouble() ?? 0.0,
      pitchMean: json['pitch_mean']?.toDouble() ?? 0.0,
      stressLevel: json['stress_level']?.toDouble() ?? 0.0,
    );
  }
}

class AIAnalysis {
  final VoiceAnalysis voiceAnalysis;
  final ContentAnalysis contentAnalysis;
  final BehavioralPatterns behavioralPatterns;

  const AIAnalysis({
    required this.voiceAnalysis,
    required this.contentAnalysis,
    required this.behavioralPatterns,
  });

  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    return AIAnalysis(
      voiceAnalysis: VoiceAnalysis.fromJson(json['voice_analysis'] ?? {}),
      contentAnalysis: ContentAnalysis.fromJson(json['content_analysis'] ?? {}),
      behavioralPatterns: BehavioralPatterns.fromJson(json['behavioral_patterns'] ?? {}),
    );
  }
}

class VoiceAnalysis {
  final double confidence;
  final List<String> findings;

  const VoiceAnalysis({
    required this.confidence,
    required this.findings,
  });

  factory VoiceAnalysis.fromJson(Map<String, dynamic> json) {
    return VoiceAnalysis(
      confidence: json['confidence']?.toDouble() ?? 0.0,
      findings: (json['findings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class ContentAnalysis {
  final double confidence;
  final List<String> findings;

  const ContentAnalysis({
    required this.confidence,
    required this.findings,
  });

  factory ContentAnalysis.fromJson(Map<String, dynamic> json) {
    return ContentAnalysis(
      confidence: json['confidence']?.toDouble() ?? 0.0,
      findings: (json['findings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class BehavioralPatterns {
  final double confidence;
  final List<String> patterns;

  const BehavioralPatterns({
    required this.confidence,
    required this.patterns,
  });

  factory BehavioralPatterns.fromJson(Map<String, dynamic> json) {
    return BehavioralPatterns(
      confidence: json['confidence']?.toDouble() ?? 0.0,
      patterns: (json['patterns'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class TimelineEvent {
  final String event;
  final Duration timestamp;
  final EventType type;

  const TimelineEvent({
    required this.event,
    required this.timestamp,
    required this.type,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      event: json['event'] ?? '',
      timestamp: Duration(seconds: json['timestamp_seconds'] ?? 0),
      type: _parseEventType(json['type'] ?? 'info'),
    );
  }

  static EventType _parseEventType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
      case 'safe':
        return EventType.success;
      case 'warning':
      case 'suspicious':
        return EventType.warning;
      case 'error':
      case 'fraud':
      case 'danger':
        return EventType.danger;
      default:
        return EventType.info;
    }
  }

  String get formattedTime {
    final minutes = timestamp.inMinutes;
    final seconds = timestamp.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

enum EventType {
  success,
  warning,
  danger,
  info,
}

