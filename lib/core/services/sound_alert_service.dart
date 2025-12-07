import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

/// Service to play alert sounds based on threat level
/// Uses a single sound file with volume and intensity adjustments
class SoundAlertService {
  static final SoundAlertService _instance = SoundAlertService._internal();
  factory SoundAlertService() => _instance;
  SoundAlertService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  /// Play alert sound based on threat score
  /// Score range: 0-100
  /// Volume range: 0.3-1.0 (maps to score: minimum 30% to maximum 100%)
  /// Also triggers haptic feedback for intensity
  Future<void> playThreatAlert(double score) async {
    try {
      // Only play sound if score indicates a threat (>= 30)
      if (score < 30) return;

      // Calculate volume based on score
      final volume = _calculateVolume(score);
      
      // Stop any currently playing sound
      await _audioPlayer.stop();

      // Play the alert sound with calculated volume
      await _audioPlayer.play(
        AssetSource('sounds/alert.wav'),
        volume: volume,
      );

      // Add haptic feedback for intensity (higher score = stronger haptic)
      _playHapticFeedback(score);
    } catch (e) {
      print('Error playing threat alert: $e');
      // Fallback: Use haptic feedback only if audio fails
      _playHapticFeedback(score);
    }
  }

  /// Calculate volume based on score (0.3 to 1.0 range)
  /// Higher scores = louder volume
  /// Score mapping:
  /// - 30-49: 0.3-0.5 (low threat)
  /// - 50-69: 0.5-0.7 (medium threat)
  /// - 70-79: 0.7-0.85 (high threat)
  /// - 80-100: 0.85-1.0 (danger/critical threat)
  double _calculateVolume(double score) {
    // Clamp score to 30-100 (only play for threats)
    final clampedScore = score.clamp(30.0, 100.0);
    
    // Map score to volume: 30-100 -> 0.3-1.0
    // Minimum volume is 0.3 (30%) for low threats
    // Maximum volume is 1.0 (100%) for critical threats
    final normalizedScore = (clampedScore - 30.0) / 70.0; // Normalize to 0-1
    final volume = 0.3 + (normalizedScore * 0.7); // Map to 0.3-1.0 range
    
    return volume.clamp(0.3, 1.0);
  }

  /// Play haptic feedback based on threat level for additional intensity
  void _playHapticFeedback(double score) {
    if (score >= 80) {
      // Critical threat - heavy impact
      HapticFeedback.heavyImpact();
    } else if (score >= 70) {
      // High threat - medium impact
      HapticFeedback.mediumImpact();
    } else if (score >= 50) {
      // Medium threat - light impact
      HapticFeedback.lightImpact();
    } else if (score >= 30) {
      // Low threat - selection feedback
      HapticFeedback.selectionClick();
    }
  }

  /// Play alert for FraudResult (used in overlay service)
  Future<void> playFraudAlert(double score) async {
    await playThreatAlert(score);
  }

  /// Stop any currently playing alert
  Future<void> stopAlert() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping alert: $e');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stopAlert();
    await _audioPlayer.dispose();
    _isInitialized = false;
  }
}

