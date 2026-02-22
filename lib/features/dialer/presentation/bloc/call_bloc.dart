import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sip_ua/sip_ua.dart';

import '../../../../core/models/sip_call_event.dart';
import '../../../../core/services/call_monitoring_service.dart';
import '../../../../core/services/fraud_detector.dart';
import '../../../../core/services/sip_service.dart';
import '../../../../core/services/websocket_streaming_service.dart';

part 'call_event.dart';
part 'call_state.dart';

class CallBloc extends Bloc<CallEvent, CallBlocState> {
  final SipService _sipService;

  StreamSubscription<SipCallEvent>? _callEventSubscription;
  Timer? _callTimer;
  String _lastDirection = 'OUTGOING';

  CallBloc({required SipService sipService})
      : _sipService = sipService,
        super(const CallIdleState()) {
    // Register event handlers
    on<InitiateCallEvent>(_onInitiateCall);
    on<IncomingCallEvent>(_onIncomingCall);
    on<AnswerCallEvent>(_onAnswerCall);
    on<RejectCallEvent>(_onRejectCall);
    on<HangUpCallEvent>(_onHangUp);
    on<ToggleMuteEvent>(_onToggleMute);
    on<ToggleSpeakerEvent>(_onToggleSpeaker);
    on<ToggleHoldEvent>(_onToggleHold);
    on<SendDtmfEvent>(_onSendDtmf);
    on<FraudScoreUpdatedEvent>(_onFraudScoreUpdated);
    on<ServerStreamResultEvent>(_onServerStreamResult);
    on<CallStateChangedEvent>(_onCallStateChanged);
    on<CallTimerTickEvent>(_onCallTimerTick);

    // Listen to SIP call events from the service
    _callEventSubscription = _sipService.callEventStream.listen(
      (event) => add(CallStateChangedEvent(event)),
    );
  }

  // ---------------------------------------------------------------------------
  // Event handlers
  // ---------------------------------------------------------------------------

  Future<void> _onInitiateCall(
    InitiateCallEvent event,
    Emitter<CallBlocState> emit,
  ) async {
    emit(CallOutgoingState(event.number));
    final success = await _sipService.makeCall(event.number);
    if (!success) {
      emit(const CallEndedState(reason: 'Call failed to connect'));
      await Future.delayed(const Duration(seconds: 2));
      emit(const CallIdleState());
    }
  }

  void _onIncomingCall(
    IncomingCallEvent event,
    Emitter<CallBlocState> emit,
  ) {
    emit(CallIncomingState(event.callerNumber));
  }

  void _onAnswerCall(
    AnswerCallEvent event,
    Emitter<CallBlocState> emit,
  ) {
    _sipService.answerCall();
  }

  void _onRejectCall(
    RejectCallEvent event,
    Emitter<CallBlocState> emit,
  ) {
    _sipService.rejectCall();
  }

  void _onHangUp(
    HangUpCallEvent event,
    Emitter<CallBlocState> emit,
  ) {
    _sipService.hangUp();
  }

  void _onToggleMute(
    ToggleMuteEvent event,
    Emitter<CallBlocState> emit,
  ) {
    _sipService.toggleMute();
  }

  void _onToggleSpeaker(
    ToggleSpeakerEvent event,
    Emitter<CallBlocState> emit,
  ) {
    // Speaker toggle is handled locally since SipService doesn't manage speaker.
    // The actual audio routing is handled by the platform.
    final currentState = state;
    if (currentState is CallConnectedState) {
      emit(currentState.copyWith(isSpeakerOn: !currentState.isSpeakerOn));
    }
  }

  void _onToggleHold(
    ToggleHoldEvent event,
    Emitter<CallBlocState> emit,
  ) {
    _sipService.toggleHold();
  }

  void _onSendDtmf(
    SendDtmfEvent event,
    Emitter<CallBlocState> emit,
  ) {
    _sipService.sendDTMF(event.tone);
  }

  void _onFraudScoreUpdated(
    FraudScoreUpdatedEvent event,
    Emitter<CallBlocState> emit,
  ) {
    final currentState = state;
    if (currentState is CallConnectedState) {
      emit(currentState.copyWith(fraudResult: event.result));
    }
  }

  void _onServerStreamResult(
    ServerStreamResultEvent event,
    Emitter<CallBlocState> emit,
  ) {
    final currentState = state;
    if (currentState is CallConnectedState) {
      emit(currentState.copyWith(
        serverStreamResult: event.result,
      ));
    }
  }

  Future<void> _onCallStateChanged(
    CallStateChangedEvent event,
    Emitter<CallBlocState> emit,
  ) async {
    final sipEvent = event.event;
    final callStateEnum = sipEvent.state;
    final remoteNumber = sipEvent.remoteNumber;
    final direction = sipEvent.direction;

    debugPrint(
      'CallBloc: SIP state=$callStateEnum direction=$direction remote=$remoteNumber',
    );

    switch (callStateEnum) {
      case CallStateEnum.CALL_INITIATION:
        _lastDirection = direction;
        if (direction == 'INCOMING') {
          emit(CallIncomingState(remoteNumber));
        } else {
          emit(CallOutgoingState(remoteNumber));
        }
        break;

      case CallStateEnum.CONNECTING:
      case CallStateEnum.PROGRESS:
        // Keep current outgoing/incoming state while connecting
        break;

      case CallStateEnum.ACCEPTED:
        // Call accepted but not yet confirmed; keep current state
        break;

      case CallStateEnum.CONFIRMED:
        _startCallTimer();
        final callDir = _lastDirection == 'INCOMING' ? 'incoming' : 'outgoing';
        _startFraudMonitoring(remoteNumber, direction: callDir);
        emit(CallConnectedState(remoteNumber: remoteNumber));
        break;

      case CallStateEnum.HOLD:
        final currentState = state;
        if (currentState is CallConnectedState) {
          emit(currentState.copyWith(isOnHold: true));
        }
        break;

      case CallStateEnum.UNHOLD:
        final currentState = state;
        if (currentState is CallConnectedState) {
          emit(currentState.copyWith(isOnHold: false));
        }
        break;

      case CallStateEnum.MUTED:
        final currentState = state;
        if (currentState is CallConnectedState) {
          emit(currentState.copyWith(isMuted: true));
        }
        break;

      case CallStateEnum.UNMUTED:
        final currentState = state;
        if (currentState is CallConnectedState) {
          emit(currentState.copyWith(isMuted: false));
        }
        break;

      case CallStateEnum.ENDED:
      case CallStateEnum.FAILED:
        _stopCallTimer();
        _stopFraudMonitoring();
        final cause = sipEvent.callState.cause?.toString();
        emit(CallEndedState(reason: cause));
        await Future.delayed(const Duration(seconds: 2));
        emit(const CallIdleState());
        break;

      case CallStateEnum.STREAM:
      case CallStateEnum.NONE:
      case CallStateEnum.REFER:
        // No state change needed for these
        break;
    }
  }

  void _onCallTimerTick(
    CallTimerTickEvent event,
    Emitter<CallBlocState> emit,
  ) {
    final currentState = state;
    if (currentState is CallConnectedState) {
      emit(currentState.copyWith(
        duration: currentState.duration + const Duration(seconds: 1),
      ));
    }
  }

  // ---------------------------------------------------------------------------
  // Fraud monitoring integration
  // ---------------------------------------------------------------------------

  void _startFraudMonitoring(String remoteNumber, {String direction = 'outgoing'}) {
    final monitoringService = CallMonitoringService();
    // Set callback so fraud results flow into CallBloc
    monitoringService.onFraudDetected = (FraudResult result) {
      add(FraudScoreUpdatedEvent(result));
    };
    // Set callback for server-side streaming results
    monitoringService.onServerStreamResult = (ServerStreamResult result) {
      add(ServerStreamResultEvent(result));
    };
    monitoringService.startMonitoringCall(remoteNumber, direction: direction);
  }

  void _stopFraudMonitoring() {
    CallMonitoringService().stopMonitoringCall();
  }

  // ---------------------------------------------------------------------------
  // Timer management
  // ---------------------------------------------------------------------------

  void _startCallTimer() {
    _stopCallTimer();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const CallTimerTickEvent());
    });
  }

  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() {
    _stopCallTimer();
    _callEventSubscription?.cancel();
    return super.close();
  }
}
