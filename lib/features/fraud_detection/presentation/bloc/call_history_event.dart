part of 'call_history_bloc.dart';

abstract class CallHistoryEvent extends Equatable {
  const CallHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCallHistoryEvent extends CallHistoryEvent {
  final int page;
  const LoadCallHistoryEvent({this.page = 1});

  @override
  List<Object?> get props => [page];
}

class SaveCallRecordEvent extends CallHistoryEvent {
  final double riskScore;
  final String riskLevel;
  final String warningMessage;
  final int keywordsFoundCount;
  final String language;
  final int durationSeconds;
  final String analysisType;
  final String? clientId;

  const SaveCallRecordEvent({
    required this.riskScore,
    required this.riskLevel,
    required this.warningMessage,
    required this.keywordsFoundCount,
    this.language = 'uz',
    this.durationSeconds = 0,
    this.analysisType = 'realtime',
    this.clientId,
  });

  @override
  List<Object?> get props => [
        riskScore,
        riskLevel,
        warningMessage,
        keywordsFoundCount,
        language,
        durationSeconds,
        analysisType,
        clientId,
      ];
}

class DeleteCallRecordEvent extends CallHistoryEvent {
  final String recordId;
  const DeleteCallRecordEvent(this.recordId);

  @override
  List<Object?> get props => [recordId];
}

class DeleteAllHistoryEvent extends CallHistoryEvent {
  const DeleteAllHistoryEvent();
}
