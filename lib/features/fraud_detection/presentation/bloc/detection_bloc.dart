import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/detection.dart';
import '../../domain/usecases/detect_fraud.dart';
import '../../domain/usecases/get_recent_detections.dart';
import '../../../../core/services/sound_alert_service.dart';
import '../../../../core/usecases/usecase.dart';
part 'detection_event.dart';
part 'detection_state.dart';

class DetectionBloc extends Bloc<DetectionEvent, DetectionState> {
  final DetectFraud detectFraud;
  final GetRecentDetections getRecentDetections;
  final SoundAlertService _soundService = SoundAlertService();

  DetectionBloc({
    required this.detectFraud,
    required this.getRecentDetections,
  }) : super(DetectionInitial()) {
    on<DetectCallEvent>(_onDetectCall);
    on<LoadDetectionsHistoryEvent>(_onLoadDetectionsHistory);
  }

  Future<void> _onDetectCall(
    DetectCallEvent event,
    Emitter<DetectionState> emit,
  ) async {
    emit(DetectionLoading());
    final result = await detectFraud(DetectFraudParams(number: event.number));
    result.fold(
      (failure) => emit(const DetectionFailure(message: 'Detection failed')),
      (detection) {
        emit(DetectionSuccess(detection: detection));
        // Play sound alert based on threat score
        // Only play if score indicates a threat (>= 30)
        if (detection.score >= 30) {
          _soundService.playThreatAlert(detection.score);
        }
      },
    );
  }

  Future<void> _onLoadDetectionsHistory(
    LoadDetectionsHistoryEvent event,
    Emitter<DetectionState> emit,
  ) async {
    emit(DetectionsHistoryLoading());
    final result = await getRecentDetections(NoParams());
    result.fold(
      (failure) => emit(const DetectionsHistoryFailure(
        message: 'Failed to load detection history',
      )),
      (detections) => emit(DetectionsHistoryLoaded(detections: detections)),
    );
  }
}
