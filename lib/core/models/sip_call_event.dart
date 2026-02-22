import 'package:sip_ua/sip_ua.dart';

/// Represents a SIP call state change event.
class SipCallEvent {
  final Call call;
  final CallState callState;

  const SipCallEvent({required this.call, required this.callState});

  String get remoteNumber => call.remote_identity ?? '';
  String get remoteDisplayName => call.remote_display_name ?? '';
  String get direction => call.direction;
  CallStateEnum get state => callState.state;
}

/// Represents a SIP registration state change event.
class SipRegistrationEvent {
  final RegistrationState state;

  const SipRegistrationEvent({required this.state});

  bool get isRegistered =>
      state.state == RegistrationStateEnum.REGISTERED;

  bool get isFailed =>
      state.state == RegistrationStateEnum.REGISTRATION_FAILED;
}

/// Represents a SIP transport state change event.
class SipTransportEvent {
  final TransportState state;

  const SipTransportEvent({required this.state});

  bool get isConnected =>
      state.state == TransportStateEnum.CONNECTED;
}
