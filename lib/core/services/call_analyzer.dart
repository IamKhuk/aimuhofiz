import 'package:speech_to_text/speech_to_text.dart';
import 'fraud_detector.dart';

/// Analyzes phone calls in real-time using speech-to-text and fraud detection
class CallAnalyzer {
  final FraudDetector _fraudDetector = FraudDetector();
  final SpeechToText _speech = SpeechToText();

  String _accumulatedText = '';
  bool _isInitialized = false;
  bool _isListening = false;

  /// Initialize the call analyzer
  /// Call this once when app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _fraudDetector.initialize();
      final available = await _speech.initialize();
      
      if (!available) {
        throw Exception('Speech recognition not available');
      }

      _isInitialized = true;
      print('CallAnalyzer initialized successfully');
    } catch (e) {
      print('Error initializing CallAnalyzer: $e');
      rethrow;
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
      print('Already listening');
      return;
    }

    _isListening = true;
    _accumulatedText = '';

    // Store callbacks for simulation usage
    this.onFraudDetected = onFraudDetected;
    this.onTextRecognized = onTextRecognized;

    try {
      await _speech.listen(
        onResult: (result) async {
          final text = result.recognizedWords;
          await processText(text);
        },
        localeId: localeId,
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      );
    } catch (e) {
      print('Speech recognition error (might be simulator): $e');
      // Continue successfully even if speech fails, to allow simulation
    }
  }

  // Callbacks for simulation
  Function(FraudResult)? onFraudDetected;
  Function(String)? onTextRecognized;

  /// Process text (either from SpeechToText or Simulation)
  Future<void> processText(String text) async {
    if (!_isListening) return;
    
    // Only update if text is new or longer (basic check)
    // For simulation, we might append. For live speech, 'result.recognizedWords' is the full session text mostly.
    // We'll trust the input 'text' is what we want to analyze.
    
    if (onTextRecognized != null) {
      onTextRecognized!(text);
    }
    
    // Simple logic: if text is shorter than accumulated, it might be a new sentence or reset
    // For now, let's just append for simulation if it seems discrete, or replace if continuous.
    // To support the prompt's requirement "Simulate Fraud", we'll just analyze the incoming text chunk directly appended
    // or as is. 
    // Let's assume input text is the *latest* update.
    
    _accumulatedText = text; // SpeechToText gives full history usually. For simulation we might need to handle differently but this is safe for now.

    // Analyze for fraud
    final fraudResult = await _fraudDetector.analyze(_accumulatedText);

    if (fraudResult.isFraud) {
       if (onFraudDetected != null) {
         onFraudDetected!(fraudResult);
       }
    }
  }

  /// Stop listening
  void stopListening() {
    if (_isListening) {
      _speech.stop();
      _isListening = false;
    }
  }

  /// Reset accumulated text
  void reset() {
    _accumulatedText = '';
  }

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Get accumulated text
  String get accumulatedText => _accumulatedText;

  /// Dispose resources
  void dispose() {
    stopListening();
    _fraudDetector.dispose();
    _isInitialized = false;
  }
}

