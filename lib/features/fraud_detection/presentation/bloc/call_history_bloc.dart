import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/detection.dart';
import '../../data/models/call_history_record.dart';
import '../../../../core/services/call_history_service.dart';

part 'call_history_event.dart';
part 'call_history_state.dart';

class CallHistoryBloc extends Bloc<CallHistoryEvent, CallHistoryState> {
  CallHistoryBloc() : super(CallHistoryInitial()) {
    on<LoadCallHistoryEvent>(_onLoadHistory);
    on<SaveCallRecordEvent>(_onSaveRecord);
    on<DeleteCallRecordEvent>(_onDeleteRecord);
    on<DeleteAllHistoryEvent>(_onDeleteAll);
  }

  Future<void> _onLoadHistory(
    LoadCallHistoryEvent event,
    Emitter<CallHistoryState> emit,
  ) async {
    emit(CallHistoryLoading());

    final result = await CallHistoryService.getCallHistory(
      page: event.page,
    );

    if (result is Map<String, dynamic>) {
      final items = (result['items'] as List?)
              ?.map((e) => CallHistoryRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
      final total = result['total'] as int? ?? items.length;
      final detections = items.map((r) => r.toDetection()).toList();

      emit(CallHistoryLoaded(
        detections: detections,
        totalCount: total,
        currentPage: event.page,
      ));
    } else {
      emit(CallHistoryFailure(result as String));
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
      emit(CallHistoryDeleted());
      // Reload history after deletion
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
      emit(CallHistoryDeleted());
      // Reload history after deletion
      add(const LoadCallHistoryEvent());
    } else {
      emit(CallHistoryFailure(error));
    }
  }
}
