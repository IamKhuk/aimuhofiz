import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/detection.dart';
import '../../data/models/call_history_record.dart';
import '../../data/datasources/local_data_source.dart';
import '../../../../core/services/call_history_service.dart';
import '../../../../core/services/audio_analysis_service.dart';

part 'call_history_event.dart';
part 'call_history_state.dart';

class CallHistoryBloc extends Bloc<CallHistoryEvent, CallHistoryState> {
  final AppDatabase _localDb;

  CallHistoryBloc({required AppDatabase localDb})
      : _localDb = localDb,
        super(CallHistoryInitial()) {
    on<LoadCallHistoryEvent>(_onLoadHistory);
    on<LoadMoreCallHistoryEvent>(_onLoadMore);
    on<SaveCallRecordEvent>(_onSaveRecord);
    on<DeleteCallRecordEvent>(_onDeleteRecord);
    on<DeleteAllHistoryEvent>(_onDeleteAll);
    on<RequestAudioAnalysisEvent>(_onRequestAudioAnalysis);
  }

  static const int _pageSize = 20;

  Future<void> _onLoadHistory(
    LoadCallHistoryEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    emit(CallHistoryLoading());

    final result = await CallHistoryService.getCallHistory(
      page: event.page,
      pageSize: _pageSize,
    );

    if (result is Map<String, dynamic>) {
      final items = (result['items'] as List?)
              ?.map((e) => CallHistoryRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = result['total'] as int? ?? items.length;
      final detections = items.map((r) => r.toDetection()).toList();
      final hasMore = detections.length >= _pageSize && detections.length < total;

      emit(CallHistoryLoaded(
        detections: detections,
        totalCount: total,
        currentPage: event.page,
        hasMore: hasMore,
      ));
    } else {
      // API failed — fall back to local database so user still sees history
      debugPrint('API failed ($result), falling back to local DB');
      await _loadFromLocalDb(emit);
    }
  }

  Future<void> _onLoadMore(
    LoadMoreCallHistoryEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! CallHistoryLoaded || !currentState.hasMore) return;

    final nextPage = currentState.currentPage + 1;
    final result = await CallHistoryService.getCallHistory(
      page: nextPage,
      pageSize: _pageSize,
    );

    if (result is Map<String, dynamic>) {
      final items = (result['items'] as List?)
              ?.map((e) => CallHistoryRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = result['total'] as int? ?? items.length;
      final newDetections = items.map((r) => r.toDetection()).toList();
      final allDetections = [...currentState.detections, ...newDetections];
      final hasMore = newDetections.length >= _pageSize && allDetections.length < total;

      emit(CallHistoryLoaded(
        detections: allDetections,
        totalCount: total,
        currentPage: nextPage,
        hasMore: hasMore,
      ));
    } else {
      debugPrint('Load more failed: $result');
      // Keep current state — don't disrupt what user already sees
    }
  }

  Future<void> _loadFromLocalDb(Emitter<CallHistoryState> emit) async {
    try {
      final localData = await _localDb.getAllDetections();
      final detections = localData
          .map((d) => Detection(
                id: d.id,
                number: d.number,
                score: d.score,
                reason: d.reason,
                timestamp: d.timestamp,
                reported: d.reported,
                audioFilePath: d.audioFilePath,
                serverAnalysisJson: d.serverAnalysisJson,
                durationSeconds: d.durationSeconds,
                callDirection: d.callDirection,
                callType: d.callType,
                contactName: d.contactName,
                wasAnswered: d.wasAnswered,
              ))
          .toList();

      emit(CallHistoryLoaded(
        detections: detections,
        totalCount: detections.length,
        currentPage: 1,
      ));
    } catch (e) {
      debugPrint('Local DB fallback also failed: $e');
      emit(const CallHistoryFailure("Tarixni yuklab bo'lmadi"));
    }
  }

  Future<void> _onSaveRecord(
    SaveCallRecordEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    emit(CallHistorySaving());

    final error = await CallHistoryService.saveCallRecord(
      riskScore: event.riskScore,
      riskLevel: event.riskLevel,
      warningMessage: event.warningMessage,
      keywordsFoundCount: event.keywordsFoundCount,
      language: event.language,
      durationSeconds: event.durationSeconds,
      analysisType: event.analysisType,
      clientId: event.clientId,
    );

    if (error == null) {
      emit(CallHistorySaved());
    } else {
      emit(CallHistoryFailure(error));
    }
  }

  Future<void> _onDeleteRecord(
    DeleteCallRecordEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    emit(CallHistoryDeleting());

    final error = await CallHistoryService.deleteRecord(event.recordId);

    if (error == null) {
      // Also delete from local DB to keep them in sync
      final localId = int.tryParse(event.recordId);
      if (localId != null) {
        try {
          await _localDb.deleteDetection(localId);
        } catch (e) {
          debugPrint('Local DB delete failed (non-critical): $e');
        }
      }
      emit(CallHistoryDeleted());
      add(const LoadCallHistoryEvent());
    } else {
      emit(CallHistoryFailure(error));
    }
  }

  Future<void> _onDeleteAll(
    DeleteAllHistoryEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    emit(CallHistoryDeleting());

    final error = await CallHistoryService.deleteAllHistory();

    if (error == null) {
      // Also clear local DB to keep them in sync
      try {
        await _localDb.deleteAllDetections();
      } catch (e) {
        debugPrint('Local DB delete-all failed (non-critical): $e');
      }
      emit(CallHistoryDeleted());
      add(const LoadCallHistoryEvent());
    } else {
      emit(CallHistoryFailure(error));
    }
  }

  Future<void> _onRequestAudioAnalysis(
    RequestAudioAnalysisEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    emit(AudioAnalysisInProgress(event.detectionId));

    try {
      final result = await AudioAnalysisService.analyzeAudio(event.audioFilePath);

      if (result is ServerAnalysisResult) {
        final jsonString = result.toJsonString();
        await _localDb.updateServerAnalysis(event.detectionId, jsonString);
        emit(AudioAnalysisComplete(event.detectionId, jsonString));
      } else {
        emit(CallHistoryFailure(result.toString()));
      }
    } catch (e) {
      debugPrint('Audio analysis request failed: $e');
      emit(CallHistoryFailure("Server tahlilida xatolik: $e"));
    }
  }
}
