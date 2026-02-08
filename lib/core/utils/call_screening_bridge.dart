import 'package:flutter/services.dart';
import '../services/call_monitoring_service.dart';

class CallScreeningBridge {
  static const _channel = MethodChannel('call_screening');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onIncomingCall') {
        final number = call.arguments['number'] as String? ?? 'unknown';
        await CallMonitoringService().startMonitoringCall(number);
      }
    });
  }
}
