# Fraud Detection Services

This directory contains the core fraud detection services for the FiribLock app.

## Files

- **fraud_detector.dart**: Offline fraud detection using TFLite model
- **call_analyzer.dart**: Real-time call analysis using speech-to-text and fraud detection

## Usage

### Basic Fraud Detection

```dart
import 'package:firib_lock/core/services/fraud_detector.dart';

final detector = FraudDetector();
await detector.initialize();

final result = await detector.analyze("Karta raqamingizni ayting");
print(result.warningMessage); // "🔴 XAVF! Bu qo'ng'iroqda firibgarlik belgilari aniqlandi!"
```

### Real-time Call Analysis

```dart
import 'package:firib_lock/core/services/call_analyzer.dart';
import 'package:firib_lock/core/widgets/fraud_alert_widget.dart';

final analyzer = CallAnalyzer();
await analyzer.initialize();

await analyzer.startListening(
  onTextRecognized: (text) {
    print('Recognized: $text');
  },
  onFraudDetected: (result) {
    // Show alert widget
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: FraudAlertWidget(result: result),
      ),
    );
  },
);
```

## Integration

The services are integrated into the app's dependency injection system. See `lib/injection_container.dart` for registration.

