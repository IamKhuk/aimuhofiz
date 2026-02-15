import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/utils/call_screening_bridge.dart';
import 'features/fraud_detection/presentation/pages/main_navigation.dart';
import 'features/fraud_detection/presentation/pages/ongoing_threat_page.dart';
import 'core/services/threat_overlay_service.dart';
import 'core/services/call_monitoring_service.dart';
import 'core/services/sound_alert_service.dart';
import 'core/services/permission_service.dart';
import 'core/theme/fraud_detection_theme.dart';
import 'injection_container.dart' as di;
import 'features/fraud_detection/presentation/pages/threat_overlay_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CallScreeningBridge.init();
  await di.init();

  // Initialize sound alert service
  await SoundAlertService().initialize();

  // Initialize overlay service
  await ThreatOverlayService.initialize();

  // Initialize call monitoring service
  await CallMonitoringService().initialize();

  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ThreatOverlayWidget(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final PermissionService _permissionService = PermissionService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Request permissions after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissions();
      await _checkForStoredThreat();
      await requestEnable();
    });
  }

  static const _channel = MethodChannel('call_screening_permission');

  static Future<void> requestEnable() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('request_call_screening');
    } catch (e) {
      print('Failed to request call screening: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    // Check if all permissions are already granted
    final alreadyGranted = await _permissionService.areAllPermissionsGranted();
    if (alreadyGranted) {
      debugPrint('All permissions already granted, skipping request');
      return;
    }

    // Check if permissions have already been requested before
    final alreadyRequested = await _permissionService.hasPermissionsBeenRequested();
    if (alreadyRequested) {
      debugPrint('Permissions already requested before, skipping');
      return;
    }

    // Show permission rationale first (only on first launch)
    await _permissionService.showPermissionRationale(context);

    // Request all permissions
    final allGranted = await _permissionService.requestAllPermissions(context);

    if (!allGranted) {
      debugPrint('Not all permissions were granted');
    }
  }

  Future<void> _checkForStoredThreat() async {
    // Check if app was opened from threat overlay/notification
    final threatData = await ThreatOverlayService.getStoredThreatData();
    if (threatData != null && navigatorKey.currentContext != null) {
      // Navigate to threat page after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (navigatorKey.currentContext != null) {
          Navigator.of(navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (context) => OngoingThreatPage(
                fraudResult: ThreatOverlayService.currentThreat,
                phoneNumber: ThreatOverlayService.currentPhoneNumber,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Muhofiz',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: buildFraudDetectionTheme(isDark: true),
      themeMode: ThemeMode.dark,
      home: const MainNavigation(),
      routes: {
        '/threat': (context) {
          return OngoingThreatPage(
            fraudResult: ThreatOverlayService.currentThreat,
            phoneNumber: ThreatOverlayService.currentPhoneNumber,
          );
        },
      },
    );
  }
}
