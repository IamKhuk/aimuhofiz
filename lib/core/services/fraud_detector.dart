import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// FraudGuard AI - Offline Fraud Detector for Flutter
/// Works without internet during phone calls
class FraudDetector {
  Interpreter? _interpreter;
  Map<String, int>? _wordIndex;
  Map<String, List<String>>? _keywords;

  static const int maxLen = 50;
  static const int maxWords = 2000;

  bool _isInitialized = false;

  /// Initialize the fraud detector
  /// Call this once when app starts
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset('assets/models/fraud_model.tflite');

      // Load vocabulary
      final vocabJson = await rootBundle.loadString('assets/models/vocabulary.json');
      final vocabData = jsonDecode(vocabJson);
      _wordIndex = Map<String, int>.from(vocabData['word_index']);

      // Load keywords
      final keywordsJson = await rootBundle.loadString('assets/models/fraud_keywords.json');
      _keywords = Map<String, List<String>>.from(
        (jsonDecode(keywordsJson) as Map).map(
          (key, value) => MapEntry(key, List<String>.from(value))
        )
      );

      _isInitialized = true;
      print('FraudDetector initialized successfully');
    } catch (e) {
      print('Error initializing FraudDetector: $e');
      rethrow;
    }
  }

  /// Convert text to sequence of integers
  List<int> _textToSequence(String text) {
    final words = text.toLowerCase()
        .replaceAll(',', ' ')
        .replaceAll('.', ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    return words.map((word) {
      return _wordIndex?[word] ?? 1; // 1 = unknown token
    }).toList();
  }

  /// Pad sequence to fixed length (int32 for Embedding layer input)
  List<int> _padSequence(List<int> sequence) {
    final padded = List<int>.filled(maxLen, 0);
    final len = sequence.length > maxLen ? maxLen : sequence.length;

    for (int i = 0; i < len; i++) {
      padded[i] = sequence[i];
    }

    return padded;
  }

  /// Detect fraud keywords in text
  Map<String, List<String>> _detectKeywords(String text) {
    final lowerText = text.toLowerCase();
    final found = <String, List<String>>{};

    _keywords?.forEach((category, words) {
      final matches = words.where((w) => lowerText.contains(w)).toList();
      if (matches.isNotEmpty) {
        found[category] = matches;
      }
    });

    return found;
  }

  /// Analyze text for fraud
  /// Returns FraudResult with score and details
  Future<FraudResult> analyze(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 1. ML Model prediction
    double mlScore = 0.0;
    try {
      final sequence = _textToSequence(text);
      final padded = _padSequence(sequence); // List<int> for Embedding lookup

      try {
        _interpreter!.resizeInputTensor(0, [1, maxLen]);
        _interpreter!.allocateTensors();
        // Embedding layer expects int32 input (word indices)
        final input = [padded]; // List<List<int>>
        final output = [<double>[0.0]];
        _interpreter!.run(input, output);
        mlScore = output[0][0];
      } catch (e) {
        print('ML inference primary error: $e');
        // Fall back to batch 16 if model requires it
        try {
          final input = List.generate(16, (_) => padded);
          final output = List.generate(16, (_) => [0.0]);
          _interpreter?.run(input, output);
          mlScore = output[0][0];
        } catch (e2) {
          print('ML inference fallback error: $e2');
        }
      }
      print('ML raw score: $mlScore');
    } catch (e) {
      print('ML inference error: $e');
    }

    // 2. Keyword detection
    final keywordMatches = _detectKeywords(text);

    // 3. Calculate combined score
    double keywordScore = 0.0;
    int totalKeywords = 0;

    keywordMatches.forEach((category, words) {
      totalKeywords += words.length;
      switch (category) {
        case 'high_risk':
          keywordScore += words.length * 15;
          break;
        case 'urgency':
          keywordScore += words.length * 12;
          break;
        case 'threat':
          keywordScore += words.length * 15;
          break;
        case 'prize':
          keywordScore += words.length * 10;
          break;
        case 'secrecy':
          keywordScore += words.length * 12;
          break;
      }
    });

    // Combine ML and keyword scores
    // Use whichever signal is stronger — ML or keywords — to avoid one capping the other
    final mlContribution = mlScore * 100; // ML alone can reach 100
    final kwContribution = keywordScore.clamp(0, 100).toDouble(); // Keywords alone can reach 100
    // Weighted blend: if both are active use blend, otherwise let the stronger one dominate
    double combinedScore;
    if (mlContribution > 10 && kwContribution > 10) {
      // Both signals present: 50/50 blend
      combinedScore = (mlContribution * 0.5) + (kwContribution * 0.5);
    } else {
      // One signal dominant: use the max
      combinedScore = mlContribution > kwContribution ? mlContribution : kwContribution;
    }
    final finalScore = combinedScore.clamp(0, 100).toDouble();

    return FraudResult(
      score: finalScore,
      mlScore: mlScore * 100,
      isFraud: finalScore >= 70,
      riskLevel: _getRiskLevel(finalScore),
      keywordsFound: keywordMatches,
      totalKeywords: totalKeywords,
      warningMessage: _getWarningMessage(finalScore, keywordMatches),
    );
  }

  String _getRiskLevel(double score) {
    if (score >= 80) return 'DANGER';
    if (score >= 70) return 'HIGH';
    if (score >= 50) return 'MEDIUM';
    if (score >= 30) return 'LOW';
    return 'SAFE';
  }

  String _getWarningMessage(double score, Map<String, List<String>> keywords) {
    if (score >= 80) {
      return '🔴 XAVF! Bu qo\'ng\'iroqda firibgarlik belgilari aniqlandi!';
    } else if (score >= 70) {
      return '🟠 EHTIYOT BO\'LING! Shubhali belgilar aniqlandi.';
    } else if (score >= 50) {
      return '🟡 DIQQAT: Ba\'zi shubhali belgilar mavjud.';
    } else {
      return '🟢 Xavfsiz: Shubhali belgilar aniqlanmadi.';
    }
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _isInitialized = false;
  }
}

/// Result of fraud analysis
class FraudResult {
  final double score;
  final double mlScore;
  final bool isFraud;
  final String riskLevel;
  final Map<String, List<String>> keywordsFound;
  final int totalKeywords;
  final String warningMessage;

  FraudResult({
    required this.score,
    required this.mlScore,
    required this.isFraud,
    required this.riskLevel,
    required this.keywordsFound,
    required this.totalKeywords,
    required this.warningMessage,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'mlScore': mlScore,
    'isFraud': isFraud,
    'riskLevel': riskLevel,
    'keywordsFound': keywordsFound,
    'totalKeywords': totalKeywords,
    'warningMessage': warningMessage,
  };

  factory FraudResult.fromJson(Map<String, dynamic> json) {
    return FraudResult(
      score: (json['score'] as num).toDouble(),
      mlScore: (json['mlScore'] as num).toDouble(),
      isFraud: json['isFraud'] as bool,
      riskLevel: json['riskLevel'] as String,
      keywordsFound: Map<String, List<String>>.from(
        (json['keywordsFound'] as Map).map(
          (key, value) => MapEntry(
            key as String,
            List<String>.from(value as List),
          ),
        ),
      ),
      totalKeywords: json['totalKeywords'] as int,
      warningMessage: json['warningMessage'] as String,
    );
  }

  @override
  String toString() => 'FraudResult(score: $score, riskLevel: $riskLevel, isFraud: $isFraud)';
}

