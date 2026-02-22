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
  final int durationSeconds;
  final String callDirection; // 'incoming', 'outgoing', 'missed'
  final String callType; // 'voip'
  final String? contactName;
  final bool wasAnswered;

  const Detection({
    this.id,
    required this.number,
    required this.score,
    required this.reason,
    required this.timestamp,
    this.reported = false,
    this.audioFilePath,
    this.serverAnalysisJson,
    this.durationSeconds = 0,
    this.callDirection = 'outgoing',
    this.callType = 'voip',
    this.contactName,
    this.wasAnswered = true,
  });

  @override
  List<Object?> get props => [
        id, number, score, reason, timestamp, reported,
        audioFilePath, serverAnalysisJson, durationSeconds,
        callDirection, callType, contactName, wasAnswered,
      ];
}
