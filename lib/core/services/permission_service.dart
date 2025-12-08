import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to handle all app permissions
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  static const String _permissionRequestedKey = 'permissions_requested';
  static const String _rationaleShownKey = 'rationale_shown';

  /// Check if permissions have already been requested
  Future<bool> hasPermissionsBeenRequested() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionRequestedKey) ?? false;
  }

  /// Mark permissions as requested
  Future<void> markPermissionsRequested() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionRequestedKey, true);
  }

  /// Check if rationale has been shown
  Future<bool> hasRationaleBeenShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_rationaleShownKey) ?? false;
  }

  /// Mark rationale as shown
  Future<void> markRationaleShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rationaleShownKey, true);
  }

  /// Check and request all required permissions
  /// Returns true if all critical permissions are granted
  Future<bool> requestAllPermissions(BuildContext context) async {
    debugPrint('PermissionService: requestAllPermissions called');

    // Check if all permissions are already granted
    final alreadyGranted = await areAllPermissionsGranted();
    if (alreadyGranted) {
      debugPrint('PermissionService: All permissions already granted');
      await markPermissionsRequested();
      return true;
    }

    bool allGranted = true;

    // 1. Phone permission (READ_PHONE_STATE)
    final phoneStatus = await Permission.phone.request();
    if (!phoneStatus.isGranted) {
      allGranted = false;
      debugPrint('PermissionService: Phone permission not granted');
    } else {
      debugPrint('PermissionService: Phone permission granted');
    }

    // 2. Microphone permission (RECORD_AUDIO)
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      allGranted = false;
      debugPrint('PermissionService: Microphone permission not granted');
    } else {
      debugPrint('PermissionService: Microphone permission granted');
    }

    // 3. Overlay permission (SYSTEM_ALERT_WINDOW)
    final overlayGranted = await requestOverlayPermission();
    if (!overlayGranted) {
      allGranted = false;
      debugPrint('PermissionService: Overlay permission not granted');
    } else {
      debugPrint('PermissionService: Overlay permission granted');
    }

    // 4. Notification permission
    final notifStatus = await Permission.notification.request();
    if (!notifStatus.isGranted) {
      debugPrint('PermissionService: Notification permission not granted');
    } else {
      debugPrint('PermissionService: Notification permission granted');
    }

    await markPermissionsRequested();
    debugPrint('PermissionService: All permissions requested, allGranted=$allGranted');
    return allGranted;
  }

  /// Request overlay permission specifically
  Future<bool> requestOverlayPermission() async {
    try {
      bool hasPermission = await FlutterOverlayWindow.isPermissionGranted();
      debugPrint('PermissionService: Overlay permission check = $hasPermission');

      if (!hasPermission) {
        debugPrint('PermissionService: Requesting overlay permission...');
        await FlutterOverlayWindow.requestPermission();

        // Wait for user to return from Settings (up to 30 seconds)
        for (int i = 0; i < 30; i++) {
          await Future.delayed(const Duration(seconds: 1));
          hasPermission = await FlutterOverlayWindow.isPermissionGranted();
          if (hasPermission) {
            debugPrint('PermissionService: Overlay permission granted after ${i + 1} seconds');
            return true;
          }
        }
        debugPrint('PermissionService: Overlay permission timeout');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('PermissionService: Error requesting overlay permission: $e');
      return false;
    }
  }

  /// Check if overlay permission is granted
  Future<bool> isOverlayPermissionGranted() async {
    try {
      final granted = await FlutterOverlayWindow.isPermissionGranted();
      debugPrint('PermissionService: isOverlayPermissionGranted = $granted');
      return granted;
    } catch (e) {
      debugPrint('PermissionService: Error checking overlay permission: $e');
      return false;
    }
  }

  /// Check if all critical permissions are granted
  Future<bool> areAllPermissionsGranted() async {
    final phone = await Permission.phone.isGranted;
    final mic = await Permission.microphone.isGranted;
    final overlay = await isOverlayPermissionGranted();

    debugPrint('PermissionService: phone=$phone, mic=$mic, overlay=$overlay');
    return phone && mic && overlay;
  }

  /// Show permission rationale dialog - only if not already shown
  Future<void> showPermissionRationale(BuildContext context) async {
    // Check if already shown
    final alreadyShown = await hasRationaleBeenShown();
    if (alreadyShown) {
      debugPrint('PermissionService: Rationale already shown, skipping');
      return;
    }

    // Check if all permissions already granted
    final allGranted = await areAllPermissionsGranted();
    if (allGranted) {
      debugPrint('PermissionService: All permissions granted, skipping rationale');
      await markRationaleShown();
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Ruxsatlar kerak',
          style: TextStyle(color: Colors.white),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Muhofiz quyidagi ruxsatlarni talab qiladi:',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 16),
            _PermissionItem(
              icon: Icons.phone,
              title: 'Telefon',
              description: 'Qo\'ng\'iroqlarni aniqlash uchun',
            ),
            SizedBox(height: 8),
            _PermissionItem(
              icon: Icons.mic,
              title: 'Mikrofon',
              description: 'Ovozni tahlil qilish uchun',
            ),
            SizedBox(height: 8),
            _PermissionItem(
              icon: Icons.layers,
              title: 'Overlay',
              description: 'Qo\'ng\'iroq paytida ogohlantirish ko\'rsatish',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tushundim'),
          ),
        ],
      ),
    );

    await markRationaleShown();
  }
}

class _PermissionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PermissionItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
