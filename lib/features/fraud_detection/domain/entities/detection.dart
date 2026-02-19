import 'package:equatable/equatable.dart';

class Detection extends Equatable {
  final int? id;
  final String number;
  final double score;
  final String reason;
  final DateTime timestamp;
  final bool reported;
  final String? audioFilePath;
  final String? serverAnalysisJson;

  const Detection({
    this.id,
    required this.number,
    required this.score,
    required this.reason,
    required this.timestamp,
    this.reported = false,
    this.audioFilePath,
    this.serverAnalysisJson,
  });

  @override
  List<Object?> get props => [id, number, score, reason, timestamp, reported, audioFilePath, serverAnalysisJson];
}
