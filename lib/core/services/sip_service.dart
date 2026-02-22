import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sip_ua/sip_ua.dart';

import '../models/sip_config.dart';
import '../models/sip_call_event.dart';

/// Central SIP service that wraps SIPUAHelper.
/// Handles registration, call management, and broadcasts events.
class SipService implements SipUaHelperListener {
  static final SipService _instance = SipService._internal();
  factory SipService() => _instance;
  SipService._internal();

  final SIPUAHelper _helper = SIPUAHelper();

  final _callEventController = StreamController<SipCallEvent>.broadcast();
  final _registrationController =
      StreamController<SipRegistrationEvent>.broadcast();
  final _transportController =
      StreamController<SipTransportEvent>.broadcast();

  /// Stream of call state changes.
  Stream<SipCallEvent> get callEventStream => _callEventController.stream;

  /// Stream of registration state changes.
  Stream<SipRegistrationEvent> get registrationStream =>
      _registrationController.stream;

  /// Stream of transport state changes.
  Stream<SipTransportEvent> get transportStream =>
      _transportController.stream;

  Call? _activeCall;
  SipConfig? _config;
  bool _initialized = false;

  /// The currently active call, if any.
  Call? get activeCall => _activeCall;

  /// Whether the SIP UA is registered.
  bool get isRegistered => _helper.registered;

  /// Whether the SIP UA is connected to the server.
  bool get isConnected => _helper.connected;

  /// Whether the service has been initialized.
  bool get isInitialized => _initialized;

  /// Current registration state.
  RegistrationState get registrationState => _helper.registerState;

  /// Initialize and start the SIP UA with the given config.
  Future<void> initialize(SipConfig config) async {
    if (_initialized) {
      debugPrint('SipService: Already initialized, stopping previous UA...');
      _helper.stop();
    }

    _config = config;

    final settings = UaSettings();
    settings.webSocketUrl = config.wssUrl;
    settings.uri = config.sipUri;
    settings.authorizationUser = config.authorizationUser;
    settings.password = config.password;
    settings.displayName = config.displayName;
    settings.userAgent = 'FiribLock/1.0';
    settings.transportType = TransportType.WS;
    settings.iceServers = config.iceServers;

    if (config.realm != null) {
      settings.realm = config.realm;
    }

    _helper.addSipUaHelperListener(this);

    try {
      await _helper.start(settings);
      _initialized = true;
      debugPrint('SipService: Started successfully');
    } catch (e) {
      debugPrint('SipService: Failed to start: $e');
      rethrow;
    }
  }

  /// Register with the SIP server.
  void register() {
    if (!_initialized) {
      debugPrint('SipService: Cannot register, not initialized');
      return;
    }
    _helper.register();
  }

  /// Unregister from the SIP server.
  void unregister() {
    if (_initialized && _helper.registered) {
      _helper.unregister();
    }
  }

  /// Make an outgoing voice call.
  /// [target] can be a SIP URI or a phone number.
  /// Phone numbers are formatted as sip:number@domain.
  Future<bool> makeCall(String target) async {
    if (!_initialized || !_helper.connected) {
      debugPrint('SipService: Cannot make call, not connected');
      return false;
    }

    // Format PSTN numbers as SIP URIs if needed
    final sipTarget = _formatTarget(target);
    debugPrint('SipService: Calling $sipTarget');
    return _helper.call(sipTarget, voiceOnly: true);
  }

  /// Answer an incoming call.
  void answerCall() {
    if (_activeCall == null) {
      debugPrint('SipService: No active call to answer');
      return;
    }
    _activeCall!.answer(_helper.buildCallOptions(true));
  }

  /// Hang up the active call.
  void hangUp() {
    if (_activeCall == null) {
      debugPrint('SipService: No active call to hang up');
      return;
    }
    _activeCall!.hangup();
    _activeCall = null;
  }

  /// Reject an incoming call.
  void rejectCall() {
    if (_activeCall == null) return;
    _activeCall!.hangup({'status_code': 603});
    _activeCall = null;
  }

  /// Toggle mute on the active call.
  void toggleMute() {
    if (_activeCall == null) return;
    if (_activeCall!.state == CallStateEnum.MUTED) {
      _activeCall!.unmute(true, false);
    } else {
      _activeCall!.mute(true, false);
    }
  }

  /// Set mute state explicitly.
  void setMute(bool muted) {
    if (_activeCall == null) return;
    if (muted) {
      _activeCall!.mute(true, false);
    } else {
      _activeCall!.unmute(true, false);
    }
  }

  /// Toggle hold on the active call.
  void toggleHold() {
    if (_activeCall == null) return;
    if (_activeCall!.state == CallStateEnum.HOLD) {
      _activeCall!.unhold();
    } else {
      _activeCall!.hold();
    }
  }

  /// Set hold state explicitly.
  void setHold(bool held) {
    if (_activeCall == null) return;
    if (held) {
      _activeCall!.hold();
    } else {
      _activeCall!.unhold();
    }
  }

  /// Send DTMF tones during an active call.
  void sendDTMF(String tones) {
    if (_activeCall == null) return;
    _activeCall!.sendDTMF(tones);
  }

  /// Format a phone number or SIP URI for calling.
  String _formatTarget(String target) {
    // Already a SIP URI
    if (target.startsWith('sip:') || target.startsWith('sips:')) {
      return target;
    }

    // Extract domain from our SIP URI
    final domain = _extractDomain();

    // Clean the number (remove spaces, dashes)
    final cleanNumber = target.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    return 'sip:$cleanNumber@$domain';
  }

  /// Extract domain from the configured SIP URI.
  String _extractDomain() {
    if (_config?.sipUri != null) {
      final uri = _config!.sipUri;
      final atIndex = uri.indexOf('@');
      if (atIndex != -1) {
        return uri.substring(atIndex + 1);
      }
    }
    return 'localhost';
  }

  /// Stop the SIP UA and clean up.
  void dispose() {
    _helper.removeSipUaHelperListener(this);
    if (_initialized) {
      _helper.stop();
    }
    _callEventController.close();
    _registrationController.close();
    _transportController.close();
    _initialized = false;
  }

  // --- SipUaHelperListener implementation ---

  @override
  void callStateChanged(Call call, CallState state) {
    debugPrint(
        'SipService: callStateChanged: ${state.state} direction=${call.direction} remote=${call.remote_identity}');

    _activeCall = call;

    // Clean up active call reference when call ends
    if (state.state == CallStateEnum.ENDED ||
        state.state == CallStateEnum.FAILED) {
      _activeCall = null;
    }

    _callEventController.add(SipCallEvent(call: call, callState: state));
  }

  @override
  void registrationStateChanged(RegistrationState state) {
    debugPrint('SipService: registrationStateChanged: ${state.state}');
    _registrationController.add(SipRegistrationEvent(state: state));
  }

  @override
  void transportStateChanged(TransportState state) {
    debugPrint('SipService: transportStateChanged: ${state.state}');
    _transportController.add(SipTransportEvent(state: state));
  }

  @override
  void onNewMessage(SIPMessageRequest msg) {
    debugPrint('SipService: onNewMessage from ${msg.originator}');
  }

  @override
  void onNewNotify(Notify ntf) {
    debugPrint('SipService: onNewNotify');
  }

  @override
  void onNewReinvite(ReInvite event) {
    debugPrint(
        'SipService: onNewReinvite hasAudio=${event.hasAudio} hasVideo=${event.hasVideo}');
    // Auto-accept re-invites for audio-only calls
    event.accept?.call(_helper.buildCallOptions(true));
  }
}
