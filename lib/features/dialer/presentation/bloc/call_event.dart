part of 'call_bloc.dart';

abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

/// User initiates an outgoing call.
class InitiateCallEvent extends CallEvent {
  final String number;

  const InitiateCallEvent(this.number);

  @override
  List<Object?> get props => [number];
}

/// An incoming call is detected.
class IncomingCallEvent extends CallEvent {
  final String callerNumber;

  const IncomingCallEvent(this.callerNumber);

  @override
  List<Object?> get props => [callerNumber];
}

/// User answers an incoming call.
class AnswerCallEvent extends CallEvent {
  const AnswerCallEvent();
}

/// User rejects an incoming call.
class RejectCallEvent extends CallEvent {
  const RejectCallEvent();
}

/// User hangs up the active call.
class HangUpCallEvent extends CallEvent {
  const HangUpCallEvent();
}

/// User toggles mute on the active call.
class ToggleMuteEvent extends CallEvent {
  const ToggleMuteEvent();
}

/// User toggles speakerphone on the active call.
class ToggleSpeakerEvent extends CallEvent {
  const ToggleSpeakerEvent();
}

/// User toggles hold on the active call.
class ToggleHoldEvent extends CallEvent {
  const ToggleHoldEvent();
}

/// User sends a DTMF tone during the active call.
class SendDtmfEvent extends CallEvent {
  final String tone;

  const SendDtmfEvent(this.tone);

  @override
  List<Object?> get props => [tone];
}

/// Fraud detection result updated during an active call.
class FraudScoreUpdatedEvent extends CallEvent {
  final FraudResult result;

  const FraudScoreUpdatedEvent(this.result);

  @override
  List<Object?> get props => [result];
}

/// Internal event: SIP call state changed (from SipService stream).
class CallStateChangedEvent extends CallEvent {
  final SipCallEvent event;

  const CallStateChangedEvent(this.event);

  @override
  List<Object?> get props => [event];
}

/// Internal event: periodic timer tick for call duration tracking.
class CallTimerTickEvent extends CallEvent {
  const CallTimerTickEvent();
}
