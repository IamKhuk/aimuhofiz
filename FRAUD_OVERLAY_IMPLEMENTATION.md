# Fraud Detection Overlay Implementation

## Overview

This implementation adds a floating overlay widget that appears on the device screen when potential fraud is detected during a phone call. The overlay shows a threat message and risk score, and when tapped, opens the app and navigates to a detailed threat page.

## Components Created

### 1. **ThreatOverlayService** (`lib/core/services/threat_overlay_service.dart`)
   - Manages the floating overlay display
   - Handles notifications as a fallback
   - Stores threat data for navigation
   - Singleton service for app-wide access

### 2. **ThreatOverlayWidget** (`lib/features/fraud_detection/presentation/pages/threat_overlay_widget.dart`)
   - Floating widget displayed on screen
   - Shows fraud alert with risk score
   - Pulsing animation for attention
   - Tap to open app and view details

### 3. **OngoingThreatPage** (`lib/features/fraud_detection/presentation/pages/ongoing_threat_page.dart`)
   - Detailed threat information page
   - Shows risk assessment, keywords, ML scores
   - Action buttons for dismiss/report
   - Comprehensive fraud details display

### 4. **CallMonitoringService** (`lib/core/services/call_monitoring_service.dart`)
   - Integrates CallAnalyzer with overlay system
   - Monitors calls and triggers alerts
   - Manages call state and fraud detection

### 5. **Overlay Entry Point** (`lib/overlay_entry_point.dart`)
   - Entry point for the overlay window
   - Required by flutter_overlay_window package

## Dependencies Added

```yaml
flutter_overlay_window: ^0.5.0
flutter_local_notifications: ^16.3.0
wakelock_plus: ^1.1.3
shared_preferences: ^2.2.2
```

## Android Permissions

Added to `android/app/src/main/AndroidManifest.xml`:
- `SYSTEM_ALERT_WINDOW` - For floating overlay
- `FOREGROUND_SERVICE` - For overlay service
- `FOREGROUND_SERVICE_SPECIAL_USE` - For special use case
- `POST_NOTIFICATIONS` - For notifications

## How It Works

### Flow:
1. **Call Detection**: When a phone call is active, `CallMonitoringService` starts monitoring
2. **Fraud Detection**: `CallAnalyzer` analyzes speech in real-time
3. **Alert Triggered**: When fraud is detected (score ≥ 70), `ThreatOverlayService.showThreatOverlay()` is called
4. **Overlay Displayed**: Floating widget appears on screen with threat message and risk score
5. **User Interaction**: User taps overlay to view details
6. **App Navigation**: App opens and navigates to `OngoingThreatPage` with full details

### Usage Example:

```dart
// Start monitoring a call
final monitoringService = CallMonitoringService();
await monitoringService.startMonitoringCall('+998901234567');

// When fraud is detected, overlay is automatically shown
// To manually show overlay:
await ThreatOverlayService.showThreatOverlay(
  fraudResult: fraudResult,
  phoneNumber: phoneNumber,
);

// Stop monitoring when call ends
await monitoringService.stopMonitoringCall();
```

## Features

✅ **Floating Overlay Widget**
   - Appears over any app during calls
   - Pulsing animation for attention
   - Draggable and dismissible
   - Shows risk score and threat message

✅ **Notification Fallback**
   - High-priority notification
   - Works when overlay permission not granted
   - Tap to open app

✅ **Detailed Threat Page**
   - Comprehensive fraud information
   - Risk assessment breakdown
   - Keywords detected
   - ML model scores
   - Action buttons (Dismiss/Report)

✅ **Automatic Integration**
   - Works with existing CallAnalyzer
   - No changes needed to existing code
   - Seamless navigation

## Setup Instructions

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Grant Permissions** (Android):
   - System Alert Window permission must be granted
   - User will be prompted on first use
   - Can also be granted in Settings > Apps > FiribLock > Display over other apps

3. **Test the Feature**:
   - Start a call monitoring session
   - Trigger fraud detection (or simulate)
   - Overlay should appear automatically

## Notes

- Overlay works best on Android
- iOS has limitations on system overlays (notification is primary method)
- Overlay requires user permission (granted automatically on first use)
- Threat data is stored in SharedPreferences for navigation

## Future Enhancements

- Background call monitoring service
- Integration with phone call state detection
- Enhanced notification actions
- Multi-language support for threat messages

