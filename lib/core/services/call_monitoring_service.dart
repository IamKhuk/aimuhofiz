import '../services/call_analyzer.dart';
import '../services/fraud_detector.dart';
import '../services/threat_overlay_service.dart';

/// Service that monitors phone calls and triggers fraud detection overlay
class CallMonitoringService {
  final CallAnalyzer _callAnalyzer = CallAnalyzer();
  String? _currentPhoneNumber;
  bool _isMonitoring = false;
  
  static final CallMonitoringService _instance = CallMonitoringService._internal();
  factory CallMonitoringService() => _instance;
  CallMonitoringService._internal();

  /// Initialize the monitoring service
  Future<void> initialize() async {
    await _callAnalyzer.initialize();
    await ThreatOverlayService.initialize();
  }

  /// Start monitoring a phone call (Simulated or Real)
  Future<void> startMonitoringCall(String phoneNumber) async {
    if (_isMonitoring) {
      await stopMonitoringCall();
    }

    _currentPhoneNumber = phoneNumber;
    _isMonitoring = true;
    print('Started monitoring call for: $phoneNumber');

    // Start analytics (with or without audio)
    await _callAnalyzer.startListening(
      onFraudDetected: (FraudResult fraudResult) async {
        print('Fraud Detected! Score: ${fraudResult.score}');
        // Show overlay when fraud is detected
        await ThreatOverlayService.showThreatOverlay(
          fraudResult: fraudResult,
          phoneNumber: phoneNumber,
        );
      },
      onTextRecognized: (String text) {
        // Optional: Handle text recognition updates
        print('Recognized text: $text');
      },
      phoneNumber: phoneNumber,
    );
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

