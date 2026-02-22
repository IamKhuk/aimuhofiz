import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/api_config.dart';

/// Result received from the server's real-time streaming endpoint.
class ServerStreamResult {
  final int chunkId;
  final String? partialTranscription;
  final double currentRiskScore;
  final String riskLevel;
  final List<String> activeWarnings;
  final String action; // "monitor" | "warn" | "block"
  final bool shouldTerminate;
  final int dangerStreak;

  const ServerStreamResult({
    required this.chunkId,
    this.partialTranscription,
    required this.currentRiskScore,
    required this.riskLevel,
    required this.activeWarnings,
    required this.action,
    required this.shouldTerminate,
    required this.dangerStreak,
  });

  factory ServerStreamResult.fromJson(Map<String, dynamic> json) {
    return ServerStreamResult(
      chunkId: json['chunk_id'] as int? ?? 0,
      partialTranscription: json['partial_transcription'] as String?,
      currentRiskScore: (json['current_risk_score'] as num? ?? 0).toDouble(),
      riskLevel: json['risk_level'] as String? ?? 'safe',
      activeWarnings: List<String>.from(json['active_warnings'] as List? ?? []),
      action: json['action'] as String? ?? 'monitor',
      shouldTerminate: json['should_terminate'] as bool? ?? false,
      dangerStreak: json['danger_streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'chunk_id': chunkId,
        'partial_transcription': partialTranscription,
        'current_risk_score': currentRiskScore,
        'risk_level': riskLevel,
        'active_warnings': activeWarnings,
        'action': action,
        'should_terminate': shouldTerminate,
        'danger_streak': dangerStreak,
      };

  @override
  String toString() =>
      'ServerStreamResult(chunk=$chunkId, risk=$currentRiskScore, level=$riskLevel, action=$action)';
}

/// Service that streams live microphone audio to the server via WebSocket
/// for real-time server-side fraud detection, running in parallel with the
/// local SpeechToText + FraudDetector pipeline.
///
/// Uses its own [AudioRecorder] instance so the existing file recording
/// (AAC .m4a via [AudioRecordingService]) continues unaffected.
class WebSocketStreamingService {
  static const int _sampleRate = 16000;
  static const int _bytesPerSample = 2; // 16-bit PCM
  static const int _chunkDurationSeconds = 3;
  static const int _chunkSizeBytes =
      _sampleRate * _bytesPerSample * _chunkDurationSeconds; // 96,000 bytes
  static const int _maxRetries = 3;

  WebSocketChannel? _channel;
  AudioRecorder? _audioRecorder;
  StreamSubscription<List<int>>? _audioSubscription;
  StreamSubscription? _wsSubscription;

  final _resultController = StreamController<ServerStreamResult>.broadcast();
  final List<int> _pcmBuffer = [];

  bool _isStreaming = false;
  int _retryCount = 0;
  bool _shouldReconnect = false;

  /// Stream of results from the server.
  Stream<ServerStreamResult> get resultStream => _resultController.stream;

  /// Whether the service is currently streaming.
  bool get isStreaming => _isStreaming;

  /// Start streaming microphone audio to the WebSocket endpoint.
  Future<void> startStreaming() async {
    if (_isStreaming) return;

    _shouldReconnect = true;
    _retryCount = 0;
    await _connect();
  }

  Future<void> _connect() async {
    try {
      final wsUri = Uri.parse(
        '${ApiConfig.wsUrl}/api/v1/stream?api_key=${ApiConfig.apiKey}',
      );
      debugPrint('WebSocketStreaming: Connecting to $wsUri');

      _channel = WebSocketChannel.connect(wsUri);
      await _channel!.ready;
      debugPrint('WebSocketStreaming: Connected');

      _retryCount = 0;
      _isStreaming = true;

      // Listen for server responses
      _wsSubscription = _channel!.stream.listen(
        _onServerMessage,
        onError: _onWsError,
        onDone: _onWsDone,
      );

      // Start capturing microphone audio as a PCM stream
      await _startAudioCapture();
    } catch (e) {
      debugPrint('WebSocketStreaming: Connection failed: $e');
      _isStreaming = false;
      await _tryReconnect();
    }
  }

  Future<void> _startAudioCapture() async {
    _audioRecorder ??= AudioRecorder();

    final hasPermission = await _audioRecorder!.hasPermission();
    if (!hasPermission) {
      debugPrint('WebSocketStreaming: Microphone permission not granted');
      return;
    }

    final stream = await _audioRecorder!.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
        autoGain: true,
        echoCancel: true,
        noiseSuppress: true,
      ),
    );

    _pcmBuffer.clear();
    _audioSubscription = stream.listen(_onAudioData);
    debugPrint('WebSocketStreaming: Audio capture started (PCM 16kHz mono)');
  }

  void _onAudioData(List<int> data) {
    if (!_isStreaming || _channel == null) return;

    _pcmBuffer.addAll(data);

    // Send chunks when we have enough buffered (~3 seconds)
    while (_pcmBuffer.length >= _chunkSizeBytes) {
      final chunk = Uint8List.fromList(
        _pcmBuffer.sublist(0, _chunkSizeBytes),
      );
      _pcmBuffer.removeRange(0, _chunkSizeBytes);

      try {
        _channel!.sink.add(chunk);
      } catch (e) {
        debugPrint('WebSocketStreaming: Error sending chunk: $e');
      }
    }
  }

  void _onServerMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      final result = ServerStreamResult.fromJson(json);
      debugPrint('WebSocketStreaming: $result');
      _resultController.add(result);
    } catch (e) {
      debugPrint('WebSocketStreaming: Error parsing server message: $e');
    }
  }

  void _onWsError(dynamic error) {
    debugPrint('WebSocketStreaming: WebSocket error: $error');
    _isStreaming = false;
    _tryReconnect();
  }

  void _onWsDone() {
    debugPrint('WebSocketStreaming: WebSocket closed');
    _isStreaming = false;
    _tryReconnect();
  }

  Future<void> _tryReconnect() async {
    if (!_shouldReconnect) return;

    _retryCount++;
    if (_retryCount > _maxRetries) {
      debugPrint(
        'WebSocketStreaming: Max retries ($_maxRetries) reached, giving up',
      );
      _shouldReconnect = false;
      return;
    }

    final delay = Duration(seconds: _retryCount * 2); // 2s, 4s, 6s
    debugPrint(
      'WebSocketStreaming: Reconnecting in ${delay.inSeconds}s '
      '(attempt $_retryCount/$_maxRetries)',
    );

    await _cleanupConnection();
    await Future.delayed(delay);

    if (_shouldReconnect) {
      await _connect();
    }
  }

  /// Stop streaming and close all resources.
  Future<void> stopStreaming() async {
    debugPrint('WebSocketStreaming: Stopping...');
    _shouldReconnect = false;
    _isStreaming = false;

    // Send remaining buffered audio before closing
    if (_pcmBuffer.isNotEmpty && _channel != null) {
      try {
        _channel!.sink.add(Uint8List.fromList(_pcmBuffer));
        _pcmBuffer.clear();
      } catch (_) {}
    }

    await _cleanupConnection();
    await _stopAudioCapture();
    debugPrint('WebSocketStreaming: Stopped');
  }

  Future<void> _cleanupConnection() async {
    await _wsSubscription?.cancel();
    _wsSubscription = null;

    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  Future<void> _stopAudioCapture() async {
    await _audioSubscription?.cancel();
    _audioSubscription = null;

    try {
      await _audioRecorder?.stop();
    } catch (_) {}

    _pcmBuffer.clear();
  }

  /// Dispose all resources permanently.
  void dispose() {
    _shouldReconnect = false;
    _isStreaming = false;
    _wsSubscription?.cancel();
    _audioSubscription?.cancel();
    try {
      _channel?.sink.close();
    } catch (_) {}
    _audioRecorder?.dispose();
    _audioRecorder = null;
    _channel = null;
    _pcmBuffer.clear();
    _resultController.close();
  }
}
