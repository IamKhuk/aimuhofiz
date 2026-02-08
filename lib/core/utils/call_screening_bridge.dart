import 'package:flutter/services.dart';

class CallScreeningBridge {
  static const _channel = MethodChannel('call_screening');

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onIncomingCall') {
        final number = call.arguments['number'];
        print('Incoming call from $number');

        // Show overlay / warning UI
      }
    });
  }
}