import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'fraud_detector.dart';

/// Analyzes phone calls in real-time using speech-to-text and fraud detection
class CallAnalyzer {
  final FraudDetector _fraudDetector = FraudDetector();
  final SpeechToText _speech = SpeechToText();

  String _accumulatedText = '';
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeechActive = false;
  bool _shouldKeepListening = false;
  bool _isSpeechAvailable = false;
  String _resolvedLocale = 'uz_UZ';

  // Preferred locales in priority order: Uzbek, Russian, English
  static const _preferredLocales = ['uz_UZ', 'ru_RU', 'en_US'];

  // Max characters to keep in accumulated text to prevent memory issues on long calls.
  // ~10000 chars covers roughly 15-20 minutes of continuous speech — enough context
  // for fraud detection while keeping memory bounded.
  static const int _maxAccumulatedLength = 10000;

  /// Initialize the call analyzer
  /// Call this once when app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _fraudDetector.initialize();
      final available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
      );

      if (!available) {
        debugPrint('CallAnalyzer: Speech recognition not available, simulation mode only');
        _isSpeechAvailable = false;
        _isInitialized = true;
        return;
      }

      _isSpeechAvailable = true;

      // Resolve the best available locale
      await _resolveLocale();

      _isInitialized = true;
      debugPrint('CallAnalyzer initialized successfully, locale: $_resolvedLocale');
    } catch (e) {
      debugPrint('Error initializing CallAnalyzer: $e');
      _isSpeechAvailable = false;
      _isInitialized = true;
    }
  }

  /// Find the best supported locale from our preference list
  Future<void> _resolveLocale() async {
    try {
      final locales = await _speech.locales();
      final localeIds = locales.map((l) => l.localeId).toSet();
      debugPrint('CallAnalyzer: Available locales: ${localeIds.take(10)}...');

      for (final preferred in _preferredLocales) {
        if (localeIds.contains(preferred)) {
          _resolvedLocale = preferred;
          debugPrint('CallAnalyzer: Using locale: $_resolvedLocale');
          return;
        }
        // Also try matching just the language code (e.g., "uz" matches "uz_UZ")
        final langCode = preferred.split('_').first;
        final match = localeIds.firstWhere(
          (id) => id.startsWith(langCode),
          orElse: () => '',
        );
        if (match.isNotEmpty) {
          _resolvedLocale = match;
          debugPrint('CallAnalyzer: Using locale (partial match): $_resolvedLocale');
          return;
        }
      }

      // Use system default as last resort
      final systemLocale = await _speech.systemLocale();
      if (systemLocale != null) {
        _resolvedLocale = systemLocale.localeId;
        debugPrint('CallAnalyzer: Falling back to system locale: $_resolvedLocale');
      }
    } catch (e) {
      debugPrint('CallAnalyzer: Error resolving locale: $e');
    }
  }

  /// Handle speech status changes — auto-restart when done
  void _onSpeechStatus(String status) {
    debugPrint('CallAnalyzer: Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _isSpeechActive = false;
      if (_shouldKeepListening) {
        // Auto-restart after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_shouldKeepListening) {
            debugPrint('CallAnalyzer: Auto-restarting speech recognition...');
            _startSpeechListener();
          }
        });
      }
    }
  }

  /// Handle speech errors — auto-restart on recoverable errors
  void _onSpeechError(dynamic error) {
    debugPrint('CallAnalyzer: Speech error: $error');
    _isSpeechActive = false;
    if (_shouldKeepListening) {
      // Restart after a longer delay on error
      Future.delayed(const Duration(seconds: 1), () {
        if (_shouldKeepListening) {
          debugPrint('CallAnalyzer: Restarting after error...');
          _startSpeechListener();
        }
      });
    }
  }

  /// Start listening during a call
  Future<void> startListening({
    required Function(FraudResult) onFraudDetected,
    required Function(String) onTextRecognized,
    String localeId = 'uz_UZ',
    String? phoneNumber,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isListening) {
      debugPrint('Already listening');
      return;
    }

    _isListening = true;
    _shouldKeepListening = true;
    _accumulatedText = '';

    // Store callbacks for simulation usage
    this.onFraudDetected = onFraudDetected;
    this.onTextRecognized = onTextRecognized;

    await _startSpeechListener();
  }

  /// Internal: start the speech listener (called on initial start and auto-restart)
  Future<void> _startSpeechListener() async {
    if (!_shouldKeepListening) return;

    try {
      await _speech.listen(
        onResult: (result) async {
          final text = result.recognizedWords;
          if (text.isNotEmpty) {
            await processText(text);
          }
        },
        localeId: _resolvedLocale,
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
      );
      _isSpeechActive = true;
      debugPrint('CallAnalyzer: Speech listener started (locale: $_resolvedLocale)');
    } catch (e) {
      _isSpeechActive = false;
      debugPrint('CallAnalyzer: Speech recognition error: $e');
      // Auto-restart will be handled by _onSpeechError
    }
  }

  // Callbacks for simulation
  Function(FraudResult)? onFraudDetected;
  Function(String)? onTextRecognized;

  /// Process text (either from SpeechToText or Simulation)
  Future<void> processText(String text) async {
    if (!_isListening) return;

    if (onTextRecognized != null) {
      onTextRecognized!(text);
    }

    // Append new text to accumulated if it's not a substring of existing text
    // SpeechToText gives full utterance per session; on restart we get new text
    if (_accumulatedText.isNotEmpty && !text.startsWith(_accumulatedText)) {
      // New listening session — append to accumulated text
      _accumulatedText = '$_accumulatedText $text';
    } else {
      // Same session — replace with latest (includes partial results)
      _accumulatedText = text;
    }

    // Trim to keep only the most recent portion if text grows too long
    if (_accumulatedText.length > _maxAccumulatedLength) {
      _accumulatedText = _accumulatedText.substring(
        _accumulatedText.length - _maxAccumulatedLength,
      );
    }

    // Analyze for fraud
    final fraudResult = await _fraudDetector.analyze(_accumulatedText);

    if (onFraudDetected != null) {
      onFraudDetected!(fraudResult);
    }
  }

  /// Stop listening
  void stopListening() {
    _shouldKeepListening = false;
    if (_isListening) {
      _speech.stop();
      _isListening = false;
      _isSpeechActive = false;
    }
  }

  /// Reset accumulated text
  void reset() {
    _accumulatedText = '';
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Check if speech recognition is actively working
  bool get isSpeechActive => _isSpeechActive;

  /// Whether real speech recognition is available (mic permission granted + engine present).
  /// When false, audio analysis is not running — only simulation mode works.
  bool get isSpeechAvailable => _isSpeechAvailable;

  /// Get accumulated text
  String get accumulatedText => _accumulatedText;

  /// Dispose resources
  void dispose() {
    stopListening();
    _fraudDetector.dispose();
    _isInitialized = false;
  }
}

