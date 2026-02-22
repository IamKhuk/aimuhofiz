import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sip_ua/sip_ua.dart';

import '../../../../core/models/sip_call_event.dart' as sip_models;
import '../../../../core/services/sip_service.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class SipRegistrationEvent extends Equatable {
  const SipRegistrationEvent();

  @override
  List<Object?> get props => [];
}

/// Request SIP registration with the server.
class RegisterEvent extends SipRegistrationEvent {
  const RegisterEvent();
}

/// Request SIP unregistration from the server.
class UnregisterEvent extends SipRegistrationEvent {
  const UnregisterEvent();
}

/// Internal event: registration state changed (from SipService stream).
class RegistrationChangedEvent extends SipRegistrationEvent {
  final sip_models.SipRegistrationEvent registrationEvent;

  const RegistrationChangedEvent(this.registrationEvent);

  @override
  List<Object?> get props => [registrationEvent];
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class SipRegistrationState extends Equatable {
  const SipRegistrationState();

  @override
  List<Object?> get props => [];
}

/// Not registered with the SIP server.
class SipUnregistered extends SipRegistrationState {
  const SipUnregistered();
}

/// Registration in progress.
class SipRegistering extends SipRegistrationState {
  const SipRegistering();
}

/// Successfully registered with the SIP server.
class SipRegistered extends SipRegistrationState {
  const SipRegistered();
}

/// Registration failed.
class SipRegistrationFailed extends SipRegistrationState {
  final String? reason;

  const SipRegistrationFailed({this.reason});

  @override
  List<Object?> get props => [reason];
}

// ---------------------------------------------------------------------------
// BLoC
// ---------------------------------------------------------------------------

class SipRegistrationBloc
    extends Bloc<SipRegistrationEvent, SipRegistrationState> {
  final SipService _sipService;

  StreamSubscription<sip_models.SipRegistrationEvent>?
      _registrationSubscription;

  SipRegistrationBloc({required SipService sipService})
      : _sipService = sipService,
        super(const SipUnregistered()) {
    on<RegisterEvent>(_onRegister);
    on<UnregisterEvent>(_onUnregister);
    on<RegistrationChangedEvent>(_onRegistrationChanged);

    // Listen to SIP registration events from the service.
    _registrationSubscription = _sipService.registrationStream.listen(
      (event) => add(RegistrationChangedEvent(event)),
    );
  }

  void _onRegister(
    RegisterEvent event,
    Emitter<SipRegistrationState> emit,
  ) {
    emit(const SipRegistering());
    _sipService.register();
  }

  void _onUnregister(
    UnregisterEvent event,
    Emitter<SipRegistrationState> emit,
  ) {
    _sipService.unregister();
    emit(const SipUnregistered());
  }

  void _onRegistrationChanged(
    RegistrationChangedEvent event,
    Emitter<SipRegistrationState> emit,
  ) {
    final regEvent = event.registrationEvent;
    final regStateEnum = regEvent.state.state;

    debugPrint('SipRegistrationBloc: state=$regStateEnum');

    switch (regStateEnum) {
      case RegistrationStateEnum.REGISTERED:
        emit(const SipRegistered());
        break;

      case RegistrationStateEnum.REGISTRATION_FAILED:
        final cause = regEvent.state.cause?.toString();
        emit(SipRegistrationFailed(reason: cause));
        break;

      case RegistrationStateEnum.UNREGISTERED:
        emit(const SipUnregistered());
        break;

      case RegistrationStateEnum.NONE:
      case null:
        // No meaningful state change
        break;
    }
  }

  @override
  Future<void> close() {
    _registrationSubscription?.cancel();
    return super.close();
  }
}
