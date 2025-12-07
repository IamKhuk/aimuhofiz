import '../../domain/entities/detection.dart';

class DetectionModel extends Detection {
  const DetectionModel({
    super.id,
    required super.number,
    required super.score,
    required super.reason,
    required super.timestamp,
    super.reported,
  });

  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    return DetectionModel(
      id: json['id'],
      number: json['number'],
      score: json['score'],
      reason: json['reason'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp_ms']),
      reported: json['reported'] ?? false,
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
    };
  }
}
