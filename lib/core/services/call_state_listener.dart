import 'package:flutter/services.dart';
import 'call_monitoring_service.dart';

/// Service to listen to system phone state changes
class CallStateListener {
  static const MethodChannel _channel = MethodChannel('com.firiblock.app/call_state');
  final CallMonitoringService _monitoringService = CallMonitoringService();
  
  static final CallStateListener _instance = CallStateListener._internal();
  factory CallStateListener() => _instance;
  CallStateListener._internal();

  /// Initialize the listener
  Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Handle incoming method calls from native side
  Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCallStateChanged':
        final String state = call.arguments['state'];
        final String? number = call.arguments['number'];
        _handleStateChange(state, number);
        break;
    }
  }

  void _handleStateChange(String state, String? number) {
    print('Call State Changed: $state, Number: $number');
    
    // OFFHOOK = Active Call / Dialing
    // RINGING = Incoming Call
    // IDLE = No Call
    
    if (state == 'OFFHOOK' || state == 'RINGING') {
      if (number != null) {
        _monitoringService.startMonitoringCall(number);
      }
    } else if (state == 'IDLE') {
      _monitoringService.stopMonitoringCall();
    }
  }
}
