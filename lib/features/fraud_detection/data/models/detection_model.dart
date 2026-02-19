import '../../domain/entities/detection.dart';

class DetectionModel extends Detection {
  const DetectionModel({
    super.id,
    required super.number,
    required super.score,
    required super.reason,
    required super.timestamp,
    super.reported,
    super.audioFilePath,
    super.serverAnalysisJson,
  });

  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    return DetectionModel(
      id: json['id'],
      number: json['number'],
      score: json['score'],
      reason: json['reason'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp_ms']),
      reported: json['reported'] ?? false,
      audioFilePath: json['audio_file_path'],
      serverAnalysisJson: json['server_analysis_json'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'score': score,
      'reason': reason,
      'timestamp_ms': timestamp.millisecondsSinceEpoch,
      'reported': reported,
      'audio_file_path': audioFilePath,
      'server_analysis_json': serverAnalysisJson,
    };
  }
}
