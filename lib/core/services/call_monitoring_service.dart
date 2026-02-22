import 'dart:async';

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
import '../services/websocket_streaming_service.dart';

/// Callback for fraud detection results — used by CallBloc to update UI.
typedef FraudDetectedCallback = void Function(FraudResult result);

/// Callback for server stream results — used by CallBloc to show server risk.
typedef ServerStreamCallback = void Function(ServerStreamResult result);

/// Service that monitors phone calls and triggers fraud detection.
/// In VoIP mode: called by SipService events, updates CallBloc via callback.
/// In fallback mode: uses overlay for fraud display.
///
/// Runs two parallel fraud detection pipelines:
/// 1. **Local**: SpeechToText → CallAnalyzer → FraudDetector (TFLite ML)
/// 2. **Server**: WebSocket streaming → server-side analysis → ServerStreamResult
///
/// The final reported score is the **higher** of the two pipelines.
class CallMonitoringService {
  final CallAnalyzer _callAnalyzer = CallAnalyzer();
  final SoundAlertService _soundService = SoundAlertService();
  final AudioRecordingService _audioRecorder = AudioRecordingService();
  final WebSocketStreamingService _wsService = WebSocketStreamingService();
  StreamSubscription<ServerStreamResult>? _wsResultSubscription;
  double _lastServerRiskScore = 0;
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

  /// External callback for server stream results (set by CallBloc).
  ServerStreamCallback? onServerStreamResult;

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

    // Start server-side real-time streaming (non-fatal if it fails)
    _startWebSocketStreaming();

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
  /// Merges with server risk score — takes the higher of the two.
  void _notifyFraudResult(FraudResult fraudResult, String phoneNumber) {
    final mergedResult = _mergeWithServerScore(fraudResult);

    // Notify CallBloc (VoIP in-call UI)
    onFraudDetected?.call(mergedResult);

    // Update overlay if in fallback mode
    if (useOverlay) {
      _updateOverlay(mergedResult, phoneNumber);
    }
  }

  /// Merge local fraud result with server risk score — take the higher score.
  FraudResult _mergeWithServerScore(FraudResult localResult) {
    if (_lastServerRiskScore <= localResult.score) return localResult;

    // Server has a higher score — elevate the local result
    final serverScore = _lastServerRiskScore;
    return FraudResult(
      score: serverScore,
      mlScore: localResult.mlScore,
      isFraud: serverScore >= 70,
      riskLevel: _serverRiskLevel(serverScore),
      keywordsFound: localResult.keywordsFound,
      totalKeywords: localResult.totalKeywords,
      warningMessage: localResult.warningMessage,
    );
  }

  String _serverRiskLevel(double score) {
    if (score >= 80) return 'DANGER';
    if (score >= 70) return 'HIGH';
    if (score >= 50) return 'MEDIUM';
    if (score >= 30) return 'LOW';
    return 'SAFE';
  }

  /// Start WebSocket streaming for server-side real-time analysis.
  /// Non-fatal: if it fails, local pipeline continues unaffected.
  void _startWebSocketStreaming() {
    _lastServerRiskScore = 0;
    try {
      _wsService.startStreaming();
      _wsResultSubscription = _wsService.resultStream.listen(
        _onServerStreamResult,
        onError: (e) {
          debugPrint('WebSocket stream error (non-fatal): $e');
        },
      );
    } catch (e) {
      debugPrint('Failed to start WebSocket streaming (non-fatal): $e');
    }
  }

  /// Handle a result from the server's real-time streaming endpoint.
  void _onServerStreamResult(ServerStreamResult result) {
    debugPrint(
      'Server stream: chunk=${result.chunkId} risk=${result.currentRiskScore} '
      'action=${result.action} terminate=${result.shouldTerminate}',
    );

    _lastServerRiskScore = result.currentRiskScore;

    // Forward raw server result to CallBloc for UI display
    onServerStreamResult?.call(result);

    // Feed server transcription into local analyzer for boosted detection
    if (result.partialTranscription != null &&
        result.partialTranscription!.isNotEmpty) {
      _callAnalyzer.processText(result.partialTranscription!);
    }

    // Handle server-initiated call termination
    if (result.shouldTerminate && !_hasAutoEndedCall) {
      _hasAutoEndedCall = true;
      debugPrint('Server requested call termination (risk=${result.currentRiskScore})');
      _autoEndCall(FraudResult(
        score: result.currentRiskScore,
        mlScore: 0,
        isFraud: true,
        riskLevel: result.riskLevel.toUpperCase(),
        keywordsFound: {},
        totalKeywords: 0,
        warningMessage: "XAVFLI! Server tahlili asosida qo'ng'iroq tugatilmoqda!",
      ));
    }

    // If server score is higher than local, re-notify with merged score
    if (_lastFraudResult != null &&
        result.currentRiskScore > _lastFraudResult!.score) {
      final merged = _mergeWithServerScore(_lastFraudResult!);
      onFraudDetected?.call(merged);

      // Check auto-end threshold with merged score
      if (merged.score >= 95 && !_hasAutoEndedCall) {
        _hasAutoEndedCall = true;
        debugPrint('DANGER! Auto-ending call due to merged server score: ${merged.score}');
        _autoEndCall(merged);
      }
    }
  }

  /// Stop WebSocket streaming.
  Future<void> _stopWebSocketStreaming() async {
    await _wsResultSubscription?.cancel();
    _wsResultSubscription = null;
    await _wsService.stopStreaming();
    _lastServerRiskScore = 0;
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

      // Stop server-side streaming
      await _stopWebSocketStreaming();

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
      _lastServerRiskScore = 0;
      onFraudDetected = null;
      onServerStreamResult = null;
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
    _wsService.dispose();
    _wsResultSubscription?.cancel();
    _isMonitoring = false;
    _currentPhoneNumber = null;
  }
}
