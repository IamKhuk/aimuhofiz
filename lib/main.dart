import 'package:flutter/material.dart';
import 'features/fraud_detection/presentation/pages/main_navigation.dart';
import 'features/fraud_detection/presentation/pages/ongoing_threat_page.dart';
import 'core/services/threat_overlay_service.dart';
import 'core/services/call_monitoring_service.dart';
import 'core/services/sound_alert_service.dart';
import 'core/theme/fraud_detection_theme.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  // Initialize sound alert service
  await SoundAlertService().initialize();
  
  // Initialize overlay service
  await ThreatOverlayService.initialize();
  
  // Initialize call monitoring service
  await CallMonitoringService().initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkForStoredThreat();
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
