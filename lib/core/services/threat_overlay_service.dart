import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart' as overlay;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/fraud_detection/presentation/pages/threat_overlay_widget.dart';
import '../services/fraud_detector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sound_alert_service.dart';

/// Service to manage floating threat overlay during calls
class ThreatOverlayService {
  static bool _isOverlayActive = false;
  static FraudResult? _currentThreat;
  static String? _currentPhoneNumber;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool get isOverlayActive => _isOverlayActive;
  static FraudResult? get currentThreat => _currentThreat;
  static String? get currentPhoneNumber => _currentPhoneNumber;

  /// Initialize the overlay service
  static Future<void> initialize() async {
    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    // When notification is tapped, the app will open
    // Navigation will be handled by the main app checking for stored threat data
    if (response.payload != null) {
      try {
        final payload = jsonDecode(response.payload!);
        if (payload['type'] == 'fraud_alert') {
          // The threat data is already stored, so the main app will pick it up
          print('Notification tapped - fraud alert');
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  /// Show the threat overlay when fraud is detected
  static Future<void> showThreatOverlay({
    required FraudResult fraudResult,
    required String phoneNumber,
  }) async {
    _currentThreat = fraudResult;
    _currentPhoneNumber = phoneNumber;

    // Store threat data for navigation
    await _storeThreatData(fraudResult, phoneNumber);

    // Play sound alert based on threat score
    // Only play if score indicates a threat (>= 30)
    if (fraudResult.score >= 30) {
      final soundService = SoundAlertService();
      await soundService.playFraudAlert(fraudResult.score);
    }

    // Try to show system overlay (Android)
    await _showSystemOverlay(fraudResult);

    // Also show notification as fallback
    await _showNotification(fraudResult, phoneNumber);
  }

  /// Store threat data for navigation
  static Future<void> _storeThreatData(
    FraudResult fraudResult,
    String phoneNumber,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_threat_data', jsonEncode({
      'fraud_result': fraudResult.toJson(),
      'phone_number': phoneNumber,
      'timestamp': DateTime.now().toIso8601String(),
    }));
  }

  /// Show system overlay (Android only)
  static Future<void> _showSystemOverlay(FraudResult fraudResult) async {
    try {
      // Check if overlay permission is granted
      final hasPermission = await overlay.FlutterOverlayWindow.isPermissionGranted();

      if (!hasPermission) {
        // Request permission
        await overlay.FlutterOverlayWindow.requestPermission();
        return;
      }

      // Show overlay
      await overlay.FlutterOverlayWindow.showOverlay(
        height: 180,
        width: 300,
        alignment: overlay.OverlayAlignment.topRight,
        overlayTitle: "Fraud Alert",
        flag: overlay.OverlayFlag.flagNotFocusable,
        visibility: overlay.NotificationVisibility.visibilityPublic,
        enableDrag: true,
        positionGravity: overlay.PositionGravity.auto,
      );

      _isOverlayActive = true;
    } catch (e) {
      print('Error showing system overlay: $e');
      // Fallback to notification if overlay fails
    }
  }

  /// Show notification
  static Future<void> _showNotification(
    FraudResult fraudResult,
    String phoneNumber,
  ) async {
    final androidDetails = AndroidNotificationDetails(
      'fraud_detection_channel',
      'Fraud Detection Alerts',
      channelDescription: 'Notifications for detected fraud during calls',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(
        '${fraudResult.warningMessage}\nRisk Score: ${fraudResult.score.toStringAsFixed(0)}%',
      ),
      ongoing: true,
      autoCancel: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      1001, // Unique ID for fraud alert
      '🔴 Fraud Alert',
      '${fraudResult.warningMessage}\nRisk: ${fraudResult.score.toStringAsFixed(0)}%',
      notificationDetails,
      payload: jsonEncode({
        'type': 'fraud_alert',
        'phone_number': phoneNumber,
      }),
    );
  }

  /// Hide the threat overlay
  static Future<void> hideThreatOverlay() async {
    if (_isOverlayActive) {
      try {
        await overlay.FlutterOverlayWindow.closeOverlay();
        _isOverlayActive = false;
      } catch (e) {
        print('Error hiding threat overlay: $e');
      }
    }

    // Cancel notification
    await _notificationsPlugin.cancel(1001);

    // Clear stored threat data after a delay (to allow navigation)
    // Don't clear immediately in case app needs to read it
  }

  /// Get stored threat data
  static Future<Map<String, dynamic>?> getStoredThreatData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('last_threat_data');
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear stored threat data
  static Future<void> clearStoredThreatData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_threat_data');
  }
}

