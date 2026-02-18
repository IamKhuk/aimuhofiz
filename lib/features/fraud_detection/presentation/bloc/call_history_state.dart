part of 'call_history_bloc.dart';

abstract class CallHistoryState extends Equatable {
  const CallHistoryState();

  @override
  List<Object?> get props => [];
}

class CallHistoryInitial extends CallHistoryState {}

class CallHistoryLoading extends CallHistoryState {}

class CallHistoryLoaded extends CallHistoryState {
  final List<Detection> detections;
  final int totalCount;
  final int currentPage;
  final bool hasMore;

  const CallHistoryLoaded({
    required this.detections,
    required this.totalCount,
    required this.currentPage,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [detections, totalCount, currentPage, hasMore];
}

class CallHistoryFailure extends CallHistoryState {
  final String message;
  const CallHistoryFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class CallHistorySaving extends CallHistoryState {}

class CallHistorySaved extends CallHistoryState {}

class CallHistoryDeleting extends CallHistoryState {}

class CallHistoryDeleted extends CallHistoryState {}
