import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as overlay;
import '../services/call_analyzer.dart';
import '../services/call_state_listener.dart';
import '../services/fraud_detector.dart';
import '../services/threat_overlay_service.dart';
import '../services/sound_alert_service.dart';

/// Service that monitors phone calls and triggers fraud detection overlay
class CallMonitoringService {
  final CallAnalyzer _callAnalyzer = CallAnalyzer();
  final SoundAlertService _soundService = SoundAlertService();
  String? _currentPhoneNumber;
  bool _isMonitoring = false;
  bool _hasAutoEndedCall = false;

  static final CallMonitoringService _instance =
      CallMonitoringService._internal();
  factory CallMonitoringService() => _instance;
  CallMonitoringService._internal();

  /// Initialize the monitoring service
  Future<void> initialize() async {
    debugPrint('CallMonitoringService: Initializing...');
    await _callAnalyzer.initialize();
    await ThreatOverlayService.initialize();
    await _soundService.initialize();

    // Initialize call state listener
    await CallStateListener().initialize();
    debugPrint('CallMonitoringService: Initialization complete');
  }

  /// Start monitoring a phone call (Simulated or Real)
  Future<void> startMonitoringCall(String phoneNumber) async {
    debugPrint('===== START MONITORING CALL =====');
    debugPrint('Phone number: $phoneNumber');
    debugPrint('Already monitoring: $_isMonitoring');

    if (_isMonitoring) {
      debugPrint('Stopping previous monitoring...');
      await stopMonitoringCall();
    }

    _currentPhoneNumber = phoneNumber;
    _isMonitoring = true;
    _hasAutoEndedCall = false;
    debugPrint('Started monitoring call for: $phoneNumber');

    // Show initial overlay with 0% score (safe)
    debugPrint('Showing initial overlay...');
    await _showInitialOverlay(phoneNumber);
    debugPrint('Initial overlay shown');

    // Start analytics (with or without audio)
    await _callAnalyzer.startListening(
      onFraudDetected: (FraudResult fraudResult) async {
        print('Fraud Analysis: Score: ${fraudResult.score}');

        // Update overlay with new score
        await _updateOverlay(fraudResult, phoneNumber);

        // Play sound alert based on threat score
        if (fraudResult.score >= 30) {
          await _soundService.playFraudAlert(fraudResult.score);
        }

        // Auto-end call if score reaches 95%
        if (fraudResult.score >= 95 && !_hasAutoEndedCall) {
          _hasAutoEndedCall = true;
          print('DANGER! Auto-ending call due to high fraud score: ${fraudResult.score}');
          await _autoEndCall(fraudResult);
        }
      },
      onTextRecognized: (String text) {
        // Optional: Handle text recognition updates
        print('Recognized text: $text');
      },
      phoneNumber: phoneNumber,
    );
  }

  /// Show initial overlay when call starts
  Future<void> _showInitialOverlay(String phoneNumber) async {
    debugPrint('_showInitialOverlay: Creating initial FraudResult');
    final initialResult = FraudResult(
      score: 0,
      mlScore: 0,
      isFraud: false,
      riskLevel: 'SAFE',
      keywordsFound: {},
      totalKeywords: 0,
      warningMessage: "Qo'ng'iroq tahlil qilinmoqda...",
    );

    debugPrint('_showInitialOverlay: Calling ThreatOverlayService.showThreatOverlay');
    try {
      await ThreatOverlayService.showThreatOverlay(
        fraudResult: initialResult,
        phoneNumber: phoneNumber,
      );
      debugPrint('_showInitialOverlay: Overlay shown successfully');
    } catch (e) {
      debugPrint('_showInitialOverlay: Error showing overlay: $e');
    }
  }

  /// Update overlay with new fraud result
  Future<void> _updateOverlay(
      FraudResult fraudResult, String phoneNumber) async {
    // Store the updated threat data
    await ThreatOverlayService.showThreatOverlay(
      fraudResult: fraudResult,
      phoneNumber: phoneNumber,
    );

    // Send real-time update to overlay window
    try {
      final data = jsonEncode({
        'fraud_result': fraudResult.toJson(),
        'phone_number': phoneNumber,
      });
      await overlay.FlutterOverlayWindow.shareData(data);
    } catch (e) {
      print('Error sending data to overlay: $e');
    }
  }

  /// Auto-end call when fraud score reaches 95%
  Future<void> _autoEndCall(FraudResult fraudResult) async {
    // Play danger alert
    await _soundService.playDangerAlert();

    // Show final warning in overlay
    final warningResult = FraudResult(
      score: fraudResult.score,
      mlScore: fraudResult.mlScore,
      isFraud: true,
      riskLevel: 'DANGER',
      keywordsFound: fraudResult.keywordsFound,
      totalKeywords: fraudResult.totalKeywords,
      warningMessage: "XAVFLI! Qo'ng'iroq avtomatik tugatilmoqda!",
    );

    await _updateOverlay(warningResult, _currentPhoneNumber ?? 'Unknown');

    // Wait a moment for user to see the warning
    await Future.delayed(const Duration(seconds: 2));

    // End the call
    final success = await CallStateListener.endCall();
    if (success) {
      print('Call ended successfully');
    } else {
      print('Failed to end call automatically');
    }
  }

  /// Simulate incoming call for testing
  Future<void> simulateIncomingCall(String phoneNumber) async {
    await startMonitoringCall(phoneNumber);
  }

  /// Simulate recognized text (e.g. for testing fraud detection)
  Future<void> simulateText(String text) async {
    if (_isMonitoring) {
      await _callAnalyzer.processText(text);
    } else {
      print('Not observing any call. Start monitoring first.');
    }
  }

  /// Stop monitoring the current call
  Future<void> stopMonitoringCall() async {
    if (_isMonitoring) {
      _callAnalyzer.stopListening();
      _callAnalyzer.reset();
      await ThreatOverlayService.hideThreatOverlay();
      _isMonitoring = false;
      _currentPhoneNumber = null;
      _hasAutoEndedCall = false;
      print('Stopped monitoring call');
    }
  }

  /// Check if currently monitoring a call
  bool get isMonitoring => _isMonitoring;

  /// Get current phone number being monitored
  String? get currentPhoneNumber => _currentPhoneNumber;

  /// Dispose resources
  void dispose() {
    _callAnalyzer.dispose();
    _isMonitoring = false;
    _currentPhoneNumber = null;
  }
}
