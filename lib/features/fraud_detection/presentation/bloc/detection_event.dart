part of 'detection_bloc.dart';

abstract class DetectionEvent extends Equatable {
  const DetectionEvent();

  @override
  List<Object> get props => [];
}

class DetectCallEvent extends DetectionEvent {
  final String number;

  const DetectCallEvent(this.number);

  @override
  List<Object> get props => [number];
}

class LoadDetectionsHistoryEvent extends DetectionEvent {
  const LoadDetectionsHistoryEvent();
}
