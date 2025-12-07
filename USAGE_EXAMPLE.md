# Usage Example: Fraud Detection Overlay

## Quick Start

### 1. Initialize Services (Already done in main.dart)

```dart
// Services are automatically initialized in main()
await ThreatOverlayService.initialize();
await CallMonitoringService().initialize();
```

### 2. Start Monitoring a Call

```dart
import 'package:firib_lock/core/services/call_monitoring_service.dart';

// Get the monitoring service instance
final monitoringService = CallMonitoringService();

// Start monitoring when a call begins
await monitoringService.startMonitoringCall('+998901234567');
```

### 3. Automatic Overlay Display

When fraud is detected during the call:
- ✅ Floating overlay widget appears automatically
- ✅ Notification is shown as fallback
- ✅ User can tap to view details

### 4. Stop Monitoring When Call Ends

```dart
// Stop monitoring when call ends
await monitoringService.stopMonitoringCall();
```

## Manual Overlay Display (For Testing)

You can manually trigger the overlay for testing:

```dart
import 'package:firib_lock/core/services/threat_overlay_service.dart';
import 'package:firib_lock/core/services/fraud_detector.dart';

// Create a test fraud result
final fraudResult = FraudResult(
  score: 85.0,
  mlScore: 80.0,
  isFraud: true,
  riskLevel: 'DANGER',
  keywordsFound: {
    'high_risk': ['card', 'money'],
    'urgency': ['urgent', 'now'],
  },
  totalKeywords: 4,
  warningMessage: '🔴 XAVF! Bu qo\'ng\'iroqda firibgarlik belgilari aniqlandi!',
);

// Show the overlay
await ThreatOverlayService.showThreatOverlay(
  fraudResult: fraudResult,
  phoneNumber: '+998901234567',
);
```

## Testing in HomePage

You can add a test button to your HomePage:

```dart
ElevatedButton(
  onPressed: () async {
    // Test fraud detection overlay
    final fraudResult = FraudResult(
      score: 85.0,
      mlScore: 80.0,
      isFraud: true,
      riskLevel: 'DANGER',
      keywordsFound: {
        'high_risk': ['card', 'money'],
      },
      totalKeywords: 2,
      warningMessage: '🔴 XAVF! Bu qo\'ng\'iroqda firibgarlik belgilari aniqlandi!',
    );
    
    await ThreatOverlayService.showThreatOverlay(
      fraudResult: fraudResult,
      phoneNumber: '+998901234567',
    );
  },
  child: const Text('Test Overlay'),
)
```

## Android Permissions

### First Time Setup:
1. Install and run the app
2. When overlay is first shown, Android will prompt for permission
3. Grant "Display over other apps" permission
4. Alternative: Go to Settings > Apps > FiribLock > Display over other apps

## Integration with Existing Call Flow

The overlay integrates automatically with your existing `CallAnalyzer`:

```dart
// Your existing CallAnalyzer code
final analyzer = CallAnalyzer();
await analyzer.startListening(
  onFraudDetected: (FraudResult result) {
    // Overlay will be shown automatically by CallMonitoringService
  },
  onTextRecognized: (String text) {
    // Handle text recognition
  },
);
```

## Navigation to Threat Page

When user taps the overlay:
1. Overlay closes
2. App opens (if in background)
3. Automatically navigates to `OngoingThreatPage`
4. Shows all threat details

## Customization

### Overlay Appearance
Edit `lib/features/fraud_detection/presentation/pages/threat_overlay_widget.dart`

### Threat Page Layout
Edit `lib/features/fraud_detection/presentation/pages/ongoing_threat_page.dart`

### Notification Content
Edit `ThreatOverlayService._showNotification()` method

