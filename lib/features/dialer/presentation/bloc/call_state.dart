part of 'call_bloc.dart';

abstract class CallBlocState extends Equatable {
  const CallBlocState();

  @override
  List<Object?> get props => [];
}

/// Initial idle state - no active call.
class CallIdleState extends CallBlocState {
  const CallIdleState();
}

/// Outgoing call is ringing.
class CallOutgoingState extends CallBlocState {
  final String number;

  const CallOutgoingState(this.number);

  @override
  List<Object?> get props => [number];
}

/// Incoming call is ringing.
class CallIncomingState extends CallBlocState {
  final String callerNumber;

  const CallIncomingState(this.callerNumber);

  @override
  List<Object?> get props => [callerNumber];
}

/// Call is connected and active.
class CallConnectedState extends CallBlocState {
  final String remoteNumber;
  final Duration duration;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isOnHold;
  final FraudResult? fraudResult;
  final ServerStreamResult? serverStreamResult;

  const CallConnectedState({
    required this.remoteNumber,
    this.duration = Duration.zero,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isOnHold = false,
    this.fraudResult,
    this.serverStreamResult,
  });

  CallConnectedState copyWith({
    String? remoteNumber,
    Duration? duration,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isOnHold,
    FraudResult? fraudResult,
    ServerStreamResult? serverStreamResult,
  }) {
    return CallConnectedState(
      remoteNumber: remoteNumber ?? this.remoteNumber,
      duration: duration ?? this.duration,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isOnHold: isOnHold ?? this.isOnHold,
      fraudResult: fraudResult ?? this.fraudResult,
      serverStreamResult: serverStreamResult ?? this.serverStreamResult,
    );
  }

  @override
  List<Object?> get props => [
        remoteNumber,
        duration,
        isMuted,
        isSpeakerOn,
        isOnHold,
        fraudResult,
        serverStreamResult,
      ];
}

/// Call has ended. Briefly shown before returning to idle.
class CallEndedState extends CallBlocState {
  final String? reason;

  const CallEndedState({this.reason});

  @override
  List<Object?> get props => [reason];
}
