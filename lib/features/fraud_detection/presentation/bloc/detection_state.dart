part of 'detection_bloc.dart';

abstract class DetectionState extends Equatable {
  const DetectionState();
  
  @override
  List<Object> get props => [];
}

class DetectionInitial extends DetectionState {}

class DetectionLoading extends DetectionState {}

class DetectionSuccess extends DetectionState {
  final Detection detection;

  const DetectionSuccess({required this.detection});

  @override
  List<Object> get props => [detection];
}

class DetectionFailure extends DetectionState {
  final String message;

  const DetectionFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class DetectionsHistoryLoading extends DetectionState {}

class DetectionsHistoryLoaded extends DetectionState {
  final List<Detection> detections;

  const DetectionsHistoryLoaded({required this.detections});

  @override
  List<Object> get props => [detections];
}

class DetectionsHistoryFailure extends DetectionState {
  final String message;

  const DetectionsHistoryFailure({required this.message});

  @override
  List<Object> get props => [message];
}
