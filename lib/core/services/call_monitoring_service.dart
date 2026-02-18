import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../features/fraud_detection/data/datasources/local_data_source.dart';
import '../services/call_analyzer.dart';
import '../services/call_state_listener.dart';
import '../services/fraud_detector.dart';
import '../services/threat_overlay_service.dart';
import '../services/sound_alert_service.dart';
import '../services/call_history_service.dart';

/// Service that monitors phone calls and triggers fraud detection overlay
class CallMonitoringService {
  final CallAnalyzer _callAnalyzer = CallAnalyzer();
  final SoundAlertService _soundService = SoundAlertService();
  String? _currentPhoneNumber;
  bool _isMonitoring = false;
  bool _hasAutoEndedCall = false;
  FraudResult? _lastFraudResult;
  DateTime? _callStartTime;

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

    // Flush any API saves that failed in previous sessions
    CallHistoryService.retryPendingSaves();
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
    _lastFraudResult = null;
    _callStartTime = DateTime.now();
    debugPrint('Started monitoring call for: $phoneNumber');

    // Show initial overlay with 0% score (safe)
    debugPrint('Showing initial overlay...');
    await _showInitialOverlay(phoneNumber);
    debugPrint('Initial overlay shown');

    // Warn user if microphone / speech recognition is not available
    if (!_callAnalyzer.isSpeechAvailable) {
      debugPrint('WARNING: Speech recognition not available — audio analysis disabled');
      final warningResult = FraudResult(
        score: 0,
        mlScore: 0,
        isFraud: false,
        riskLevel: 'SAFE',
        keywordsFound: {},
        totalKeywords: 0,
        warningMessage: "Mikrofon ruxsati berilmagan! Ovozli tahlil ishlamaydi.",
      );
      await _updateOverlay(warningResult, phoneNumber);
    }

    // Start analytics (with or without audio)
    await _callAnalyzer.startListening(
      onFraudDetected: (FraudResult fraudResult) async {
        print('Fraud Analysis: Score: ${fraudResult.score}');

        // Track the highest fraud result for saving to history
        if (_lastFraudResult == null || fraudResult.score > _lastFraudResult!.score) {
          _lastFraudResult = fraudResult;
        }

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

  /// Update overlay with new fraud result (no close/reopen, just sends data)
  Future<void> _updateOverlay(
      FraudResult fraudResult, String phoneNumber) async {
    await ThreatOverlayService.updateThreatOverlay(
      fraudResult: fraudResult,
      phoneNumber: phoneNumber,
    );
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

  /// Stop monitoring the current call and save detection to history
  Future<void> stopMonitoringCall() async {
    if (!_isMonitoring) return;

    try {
      _callAnalyzer.stopListening();
      _callAnalyzer.reset();
      await ThreatOverlayService.hideThreatOverlay();

      // Save the call detection to database for history
      await _saveDetectionToHistory();
    } catch (e) {
      debugPrint('Error during stopMonitoringCall: $e');
    } finally {
      // Always reset state so the service can handle future calls
      _isMonitoring = false;
      _currentPhoneNumber = null;
      _hasAutoEndedCall = false;
      _lastFraudResult = null;
      _callStartTime = null;
      debugPrint('Stopped monitoring call');
    }
  }

  /// Persist the detection result to the local database
  Future<void> _saveDetectionToHistory() async {
    final phoneNumber = _currentPhoneNumber ?? 'Unknown';
    final fraudResult = _lastFraudResult;
    final durationSeconds = _callStartTime != null
        ? DateTime.now().difference(_callStartTime!).inSeconds
        : 0;

    // Always save — even safe calls — so user sees full call history
    try {
      final db = GetIt.instance<AppDatabase>();

      final score = fraudResult?.score ?? 0;
      final reason = fraudResult != null
          ? _buildReason(fraudResult)
          : "Qo'ng'iroq tahlil qilindi, xavf aniqlanmadi";

      await db.insertDetection(
        DetectionTablesCompanion(
          number: Value(phoneNumber),
          score: Value(score),
          reason: Value(reason),
          timestamp: Value(DateTime.now()),
          reported: const Value(false),
        ),
      );
      debugPrint('Detection saved to history: $phoneNumber, score: $score');
    } catch (e) {
      debugPrint('Error saving detection to history: $e');
    }

    // Also save to remote API
    try {
      final apiError = await CallHistoryService.saveCallRecord(
        riskScore: fraudResult?.score ?? 0,
        riskLevel: fraudResult?.riskLevel ?? 'SAFE',
        warningMessage: fraudResult?.warningMessage ?? "Qo'ng'iroq tahlil qilindi",
        keywordsFoundCount: fraudResult?.totalKeywords ?? 0,
        durationSeconds: durationSeconds,
        clientId: phoneNumber,
      );
      if (apiError != null) {
        debugPrint('API save error: $apiError');
      } else {
        debugPrint('Detection saved to API: $phoneNumber');
      }
    } catch (e) {
      debugPrint('Error saving detection to API: $e');
    }
  }

  /// Build a human-readable reason string from the FraudResult
  String _buildReason(FraudResult result) {
    if (result.score < 30) {
      return "Oddiy qo'ng'iroq, xavf aniqlanmadi";
    }

    final parts = <String>[];
    parts.add(result.warningMessage);

    if (result.keywordsFound.isNotEmpty) {
      final categories = result.keywordsFound.keys.join(', ');
      parts.add('Aniqlangan toifalar: $categories');
    }

    return parts.join('. ');
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
