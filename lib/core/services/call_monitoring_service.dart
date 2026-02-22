import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../features/fraud_detection/data/datasources/local_data_source.dart';
import '../services/call_analyzer.dart';
import '../services/fraud_detector.dart';
import '../services/sip_service.dart';
import '../services/threat_overlay_service.dart';
import '../services/sound_alert_service.dart';
import '../services/call_history_service.dart';
import '../services/audio_recording_service.dart';
import '../services/audio_analysis_service.dart';

/// Callback for fraud detection results — used by CallBloc to update UI.
typedef FraudDetectedCallback = void Function(FraudResult result);

/// Service that monitors phone calls and triggers fraud detection.
/// In VoIP mode: called by SipService events, updates CallBloc via callback.
/// In fallback mode: uses overlay for fraud display.
class CallMonitoringService {
  final CallAnalyzer _callAnalyzer = CallAnalyzer();
  final SoundAlertService _soundService = SoundAlertService();
  final AudioRecordingService _audioRecorder = AudioRecordingService();
  String? _currentPhoneNumber;
  bool _isMonitoring = false;
  bool _hasAutoEndedCall = false;
  FraudResult? _lastFraudResult;
  DateTime? _callStartTime;
  String? _recordingFilePath;
  String _callDirection = 'outgoing';
  String? _contactName;

  /// External callback for fraud results (set by CallBloc).
  FraudDetectedCallback? onFraudDetected;

  /// Whether to use the overlay (fallback when not default dialer).
  bool useOverlay = false;

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

    // Flush any API saves that failed in previous sessions
    CallHistoryService.retryPendingSaves();
    debugPrint('CallMonitoringService: Initialization complete');
  }

  /// Start monitoring a phone call (VoIP or Simulated)
  Future<void> startMonitoringCall(
    String phoneNumber, {
    String direction = 'outgoing',
    String? contactName,
  }) async {
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
    _recordingFilePath = null;
    _callDirection = direction;
    _contactName = contactName;
    debugPrint('Started monitoring call for: $phoneNumber');

    // Start audio recording
    final recordingPath = await _audioRecorder.startRecording(phoneNumber);
    if (recordingPath != null) {
      _recordingFilePath = recordingPath;
      debugPrint('Recording started: $recordingPath');
    } else {
      debugPrint('WARNING: Audio recording could not be started');
    }

    // Show overlay as fallback (when not using in-call UI)
    if (useOverlay) {
      await _showInitialOverlay(phoneNumber);
    }

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
      _notifyFraudResult(warningResult, phoneNumber);
    }

    // Start analytics (with or without audio)
    await _callAnalyzer.startListening(
      onFraudDetected: (FraudResult fraudResult) async {
        debugPrint('Fraud Analysis: Score: ${fraudResult.score}');

        // Track the highest fraud result for saving to history
        if (_lastFraudResult == null || fraudResult.score > _lastFraudResult!.score) {
          _lastFraudResult = fraudResult;
        }

        // Notify listeners (CallBloc or overlay)
        _notifyFraudResult(fraudResult, phoneNumber);

        // Play sound alert based on threat score
        if (fraudResult.score >= 30) {
          await _soundService.playFraudAlert(fraudResult.score);
        }

        // Auto-end call if score reaches 95%
        if (fraudResult.score >= 95 && !_hasAutoEndedCall) {
          _hasAutoEndedCall = true;
          debugPrint('DANGER! Auto-ending call due to high fraud score: ${fraudResult.score}');
          await _autoEndCall(fraudResult);
        }
      },
      onTextRecognized: (String text) {
        debugPrint('Recognized text: $text');
      },
      phoneNumber: phoneNumber,
    );
  }

  /// Notify fraud result to CallBloc callback and/or overlay.
  void _notifyFraudResult(FraudResult fraudResult, String phoneNumber) {
    // Notify CallBloc (VoIP in-call UI)
    onFraudDetected?.call(fraudResult);

    // Update overlay if in fallback mode
    if (useOverlay) {
      _updateOverlay(fraudResult, phoneNumber);
    }
  }

  /// Show initial overlay when call starts (fallback mode)
  Future<void> _showInitialOverlay(String phoneNumber) async {
    final initialResult = FraudResult(
      score: 0,
      mlScore: 0,
      isFraud: false,
      riskLevel: 'SAFE',
      keywordsFound: {},
      totalKeywords: 0,
      warningMessage: "Qo'ng'iroq tahlil qilinmoqda...",
    );

    try {
      await ThreatOverlayService.showThreatOverlay(
        fraudResult: initialResult,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('Error showing overlay: $e');
    }
  }

  /// Update overlay with new fraud result (fallback mode)
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

    // Show final warning
    final warningResult = FraudResult(
      score: fraudResult.score,
      mlScore: fraudResult.mlScore,
      isFraud: true,
      riskLevel: 'DANGER',
      keywordsFound: fraudResult.keywordsFound,
      totalKeywords: fraudResult.totalKeywords,
      warningMessage: "XAVFLI! Qo'ng'iroq avtomatik tugatilmoqda!",
    );

    _notifyFraudResult(warningResult, _currentPhoneNumber ?? 'Unknown');

    // Wait a moment for user to see the warning
    await Future.delayed(const Duration(seconds: 2));

    // End the call via SIP
    SipService().hangUp();
    debugPrint('Call auto-ended via SIP');
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
      debugPrint('Not observing any call. Start monitoring first.');
    }
  }

  /// Stop monitoring the current call and save detection to history
  Future<void> stopMonitoringCall() async {
    if (!_isMonitoring) return;

    try {
      _callAnalyzer.stopListening();
      _callAnalyzer.reset();

      if (useOverlay) {
        await ThreatOverlayService.hideThreatOverlay();
      }

      // Stop audio recording
      final recordingPath = await _audioRecorder.stopRecording();
      if (recordingPath != null) {
        _recordingFilePath = recordingPath;
        debugPrint('Recording saved: $recordingPath');
      }

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
      _recordingFilePath = null;
      _callDirection = 'outgoing';
      _contactName = null;
      onFraudDetected = null;
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
    final audioPath = _recordingFilePath;

    // Always save — even safe calls — so user sees full call history
    int? localId;
    try {
      final db = GetIt.instance<AppDatabase>();

      final score = fraudResult?.score ?? 0;
      final reason = fraudResult != null
          ? _buildReason(fraudResult)
          : "Qo'ng'iroq tahlil qilindi, xavf aniqlanmadi";

      localId = await db.insertDetection(
        DetectionTablesCompanion(
          number: Value(phoneNumber),
          score: Value(score),
          reason: Value(reason),
          timestamp: Value(DateTime.now()),
          reported: const Value(false),
          audioFilePath: Value(audioPath),
          durationSeconds: Value(durationSeconds),
          callDirection: Value(_callDirection),
          callType: const Value('voip'),
          contactName: Value(_contactName),
          wasAnswered: Value(durationSeconds > 0),
        ),
      );
      debugPrint('Detection saved to history: $phoneNumber, score: $score, id: $localId');
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

    // Fire-and-forget: upload audio for server analysis
    if (audioPath != null && localId != null) {
      _uploadAndAnalyzeAudio(audioPath, localId);
    }
  }

  /// Upload audio to server for analysis and update local DB with results.
  Future<void> _uploadAndAnalyzeAudio(String audioPath, int localId) async {
    try {
      debugPrint('Uploading audio for server analysis: $audioPath');
      final result = await AudioAnalysisService.analyzeAudio(audioPath);

      if (result is ServerAnalysisResult) {
        final db = GetIt.instance<AppDatabase>();
        await db.updateServerAnalysis(localId, result.toJsonString());
        debugPrint('Server analysis saved for detection #$localId');
      } else {
        debugPrint('Server analysis failed: $result');
      }
    } catch (e) {
      debugPrint('Error uploading audio for analysis: $e');
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
    _audioRecorder.dispose();
    _isMonitoring = false;
    _currentPhoneNumber = null;
  }
}
