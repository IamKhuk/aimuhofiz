import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridge to Android Telecom framework via platform channels.
/// Handles default dialer registration, PhoneAccount management,
/// and reporting VoIP calls to the system.
class TelecomBridgeService {
  static const _telecomChannel =
      MethodChannel('uz.aisurface.firiblock/telecom');
  static const _dialerChannel =
      MethodChannel('uz.aisurface.firiblock/dialer');
  static const _inCallChannel =
      MethodChannel('uz.aisurface.firiblock/incall');

  static Function(String number)? _onDialRequest;
  static Function(String number, String direction)? _onNativeCallAdded;
  static Function()? _onNativeCallRemoved;
  static Function(String state, String number)? _onNativeCallStateChanged;

  /// Initialize the bridge and set up method call handlers.
  static void initialize() {
    if (!Platform.isAndroid) return;

    // Listen for dial intents from the system
    _dialerChannel.setMethodCallHandler((call) async {
      if (call.method == 'onDialRequest') {
        final number = call.arguments['number'] as String?;
        if (number != null) {
          debugPrint('TelecomBridge: Dial request for $number');
          _onDialRequest?.call(number);
        }
      }
    });

    // Listen for native call events from InCallService
    _inCallChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onNativeCallAdded':
          final args = call.arguments as Map;
          final number = args['number'] as String? ?? 'Unknown';
          final direction = args['direction'] as String? ?? 'unknown';
          debugPrint('TelecomBridge: Native call added: $number ($direction)');
          _onNativeCallAdded?.call(number, direction);
          break;
        case 'onNativeCallRemoved':
          debugPrint('TelecomBridge: Native call removed');
          _onNativeCallRemoved?.call();
          break;
        case 'onNativeCallStateChanged':
          final args = call.arguments as Map;
          final state = args['state'] as String? ?? 'UNKNOWN';
          final number = args['number'] as String? ?? 'Unknown';
          debugPrint('TelecomBridge: Native call state: $state');
          _onNativeCallStateChanged?.call(state, number);
          break;
      }
    });
  }

  /// Register a listener for incoming dial intents (ACTION_DIAL).
  static void onDialRequest(Function(String number) callback) {
    _onDialRequest = callback;
  }

  /// Register a listener for native calls added via InCallService.
  static void onNativeCallAdded(
      Function(String number, String direction) callback) {
    _onNativeCallAdded = callback;
  }

  /// Register a listener for native calls removed.
  static void onNativeCallRemoved(Function() callback) {
    _onNativeCallRemoved = callback;
  }

  /// Register a listener for native call state changes.
  static void onNativeCallStateChanged(
      Function(String state, String number) callback) {
    _onNativeCallStateChanged = callback;
  }

  /// Register the self-managed PhoneAccount with TelecomManager.
  static Future<bool> registerPhoneAccount() async {
    if (!Platform.isAndroid) return false;
    try {
      final result =
          await _telecomChannel.invokeMethod('registerPhoneAccount');
      return result == true;
    } catch (e) {
      debugPrint('TelecomBridge: Failed to register PhoneAccount: $e');
      return false;
    }
  }

  /// Request the user to set this app as the default dialer.
  static Future<bool> requestDefaultDialer() async {
    if (!Platform.isAndroid) return false;
    try {
      final result =
          await _telecomChannel.invokeMethod('requestDefaultDialer');
      return result == true;
    } catch (e) {
      debugPrint('TelecomBridge: Failed to request default dialer: $e');
      return false;
    }
  }

  /// Check if this app is the default dialer.
  static Future<bool> isDefaultDialer() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _telecomChannel.invokeMethod('isDefaultDialer');
      return result == true;
    } catch (e) {
      debugPrint('TelecomBridge: Failed to check default dialer: $e');
      return false;
    }
  }

  /// Report an outgoing VoIP call to the Telecom framework.
  static Future<void> reportOutgoingCall(String number) async {
    if (!Platform.isAndroid) return;
    try {
      await _telecomChannel
          .invokeMethod('reportOutgoingCall', {'number': number});
    } catch (e) {
      debugPrint('TelecomBridge: Failed to report outgoing call: $e');
    }
  }

  /// Report an incoming VoIP call to the Telecom framework.
  static Future<void> reportIncomingCall(String number) async {
    if (!Platform.isAndroid) return;
    try {
      await _telecomChannel
          .invokeMethod('reportIncomingCall', {'number': number});
    } catch (e) {
      debugPrint('TelecomBridge: Failed to report incoming call: $e');
    }
  }

  /// End the active Telecom connection.
  static Future<void> endTelecomCall() async {
    if (!Platform.isAndroid) return;
    try {
      await _telecomChannel.invokeMethod('endTelecomCall');
    } catch (e) {
      debugPrint('TelecomBridge: Failed to end telecom call: $e');
    }
  }
}
