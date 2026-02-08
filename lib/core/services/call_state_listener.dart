import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'call_monitoring_service.dart';

/// Service to listen to system phone state changes
class CallStateListener {
  static const MethodChannel _channel = MethodChannel('uz.aisurface.firiblock/call_state');
  final CallMonitoringService _monitoringService = CallMonitoringService();
  static bool _isInitialized = false;
  static String? _lastState;

  static final CallStateListener _instance = CallStateListener._internal();
  factory CallStateListener() => _instance;
  CallStateListener._internal();

  /// Initialize the listener
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('CallStateListener already initialized');
      return;
    }
    _isInitialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);
    debugPrint('CallStateListener initialized and listening for call state changes');
  }

  /// Handle incoming method calls from native side
  Future<void> _handleMethodCall(MethodCall call) async {
    debugPrint('CallStateListener received method: ${call.method}');
    switch (call.method) {
      case 'onCallStateChanged':
        final String state = call.arguments['state'] ?? 'UNKNOWN';
        final String? number = call.arguments['number'];
        debugPrint('CallStateListener: state=$state, number=$number');
        await _handleStateChange(state, number);
        break;
      default:
        debugPrint('CallStateListener: Unknown method ${call.method}');
    }
  }

  Future<void> _handleStateChange(String state, String? number) async {
    debugPrint('===== CALL STATE CHANGED =====');
    debugPrint('State: $state');
    debugPrint('Number: $number');
    debugPrint('Last State: $_lastState');
    debugPrint('==============================');

    // Avoid duplicate state handling
    if (state == _lastState && state != 'IDLE') {
      debugPrint('Duplicate state, skipping');
      return;
    }
    _lastState = state;

    // OFFHOOK = Active Call / Dialing (call answered)
    // RINGING = Incoming Call (ringing)
    // IDLE = No Call

    if (state == 'OFFHOOK') {
      // Call has been picked up - start monitoring immediately
      final phoneNumber = number ?? 'Unknown';
      debugPrint('CALL PICKED UP - Starting monitoring for: $phoneNumber');
      await _monitoringService.startMonitoringCall(phoneNumber);
    } else if (state == 'RINGING') {
      // Incoming call - can show preview but don't start full monitoring yet
      final phoneNumber = number ?? 'Unknown';
      debugPrint('INCOMING CALL from: $phoneNumber');
      // Optionally start monitoring on ring if desired
      // await _monitoringService.startMonitoringCall(phoneNumber);
    } else if (state == 'IDLE') {
      // Call ended
      debugPrint('CALL ENDED - Stopping monitoring');
      await _monitoringService.stopMonitoringCall();
      _lastState = null;
    }
  }

  /// End the current call programmatically
  /// Returns true if successful, false otherwise
  static Future<bool> endCall() async {
    try {
      final result = await _channel.invokeMethod<bool>('endCall');
      return result ?? false;
    } catch (e) {
      print('Error ending call: $e');
      return false;
    }
  }

  /// Check if a call is currently active
  static Future<bool> isCallActive() async {
    try {
      final result = await _channel.invokeMethod<bool>('isCallActive');
      return result ?? false;
    } catch (e) {
      print('Error checking call state: $e');
      return false;
    }
  }
}
