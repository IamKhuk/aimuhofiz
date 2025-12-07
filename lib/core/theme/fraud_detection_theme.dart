// fraud_detection_theme.dart
// Flutter Theme configuration for "Palette #4 + alert colors"
// Palette:
// - Slate Blue: #34495E
// - Amber: #FFC107
// - Red (Alert): #D32F2F
// - Green (Verified): #2ECC71
// - White: #FFFFFF

import 'package:flutter/material.dart';

// Publicly exposed theme getter
ThemeData buildFraudDetectionTheme({bool isDark = false}) {
  return isDark ? _FraudTheme._darkTheme : _FraudTheme._lightTheme;
}

// Alert levels used across the app
enum FraudAlertLevel { safe, suspicious, fraud }

extension FraudAlertLevelExtension on FraudAlertLevel {
  Color color(BuildContext context) {
    switch (this) {
      case FraudAlertLevel.safe:
        return _FraudTheme.verified;
      case FraudAlertLevel.suspicious:
        return _FraudTheme.amber;
      case FraudAlertLevel.fraud:
        return _FraudTheme.danger;
    }
  }

  String label() {
    switch (this) {
      case FraudAlertLevel.safe:
        return 'Safe';
      case FraudAlertLevel.suspicious:
        return 'Suspicious';
      case FraudAlertLevel.fraud:
        return 'Fraud';
    }
  }
}

class _FraudTheme {
  // Core palette
  static const Color slateBlue = Color(0xFF34495E);
  static const Color amber = Color(0xFFFFC107);
  static const Color danger = Color(0xFFD32F2F);
  static const Color verified = Color(0xFF2ECC71);
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color neutral100 = Color(0xFFF8F9FA);
  static const Color neutral700 = Color(0xFF6B7280);

  // Accent & semantic
  static const Color surface = whiteColor;
  static const Color surfaceDark = Color(0xFF0F1720);

  // Light Theme
  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: slateBlue,
    scaffoldBackgroundColor: neutral100,
    canvasColor: surface,
    cardColor: surface,
    dividerColor: Color(0xFFE6E9EE),
    colorScheme: ColorScheme.light(
      primary: slateBlue,
      secondary: amber,
      surface: surface,
      error: danger,
      onPrimary: whiteColor,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      onError: whiteColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: slateBlue,
      elevation: 2,
      iconTheme: IconThemeData(color: whiteColor),
      titleTextStyle: _textTheme.titleLarge?.copyWith(color: whiteColor),
      toolbarTextStyle: _textTheme.bodyMedium?.copyWith(color: whiteColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: slateBlue,
        foregroundColor: whiteColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: slateBlue,
        side: BorderSide(color: slateBlue.withValues(alpha: 0.16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: slateBlue,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: slateBlue,
      contentTextStyle: TextStyle(color: whiteColor),
      actionTextColor: amber,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: amber,
      foregroundColor: Colors.black,
    ),
    iconTheme: IconThemeData(color: slateBlue),
    primaryIconTheme: IconThemeData(color: whiteColor),
    textTheme: _textTheme,
    // Custom extensions
    extensions: <ThemeExtension<dynamic>>[
      _AlertColors(
        danger: danger,
        warning: amber,
        verified: verified,
        slateBlue: slateBlue,
      )
    ],
  );

  // Dark Theme
  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: slateBlue,
    scaffoldBackgroundColor: surfaceDark,
    canvasColor: Color(0xFF071027),
    cardColor: Color(0xFF071827),
    dividerColor: Color(0xFF1F2937),
    colorScheme: ColorScheme.dark(
      primary: slateBlue,
      secondary: amber,
      surface: Color(0xFF071827),
      error: danger,
      onPrimary: whiteColor,
      onSecondary: Colors.black,
      onSurface: whiteColor,
      onError: whiteColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: slateBlue,
      elevation: 0,
      iconTheme: IconThemeData(color: whiteColor),
      titleTextStyle: _textTheme.titleLarge?.copyWith(color: whiteColor),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: slateBlue,
        foregroundColor: whiteColor,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: whiteColor,
        side: BorderSide(color: whiteColor.withValues(alpha: 0.08)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: whiteColor),
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF071827),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: slateBlue,
      contentTextStyle: TextStyle(color: whiteColor),
      actionTextColor: amber,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xFF071827),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: amber,
      foregroundColor: Colors.black,
    ),
    iconTheme: IconThemeData(color: whiteColor),
    primaryIconTheme: IconThemeData(color: whiteColor),
    textTheme: _textTheme.apply(bodyColor: whiteColor, displayColor: whiteColor),
    extensions: <ThemeExtension<dynamic>>[
      _AlertColors(
        danger: danger,
        warning: amber,
        verified: verified,
        slateBlue: slateBlue,
      )
    ],
  );

  // Core text theme
  static final TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
    displaySmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
    titleMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    bodySmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w400, color: neutral700),
  );
}

// Theme extension to expose alert colors easily
@immutable
class _AlertColors extends ThemeExtension<_AlertColors> {
  final Color? danger;
  final Color? warning;
  final Color? verified;
  final Color? slateBlue;

  const _AlertColors({this.danger, this.warning, this.verified, this.slateBlue});

  @override
  _AlertColors copyWith({Color? danger, Color? warning, Color? verified, Color? slateBlue}) {
    return _AlertColors(
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
      verified: verified ?? this.verified,
      slateBlue: slateBlue ?? this.slateBlue,
    );
  }

  @override
  _AlertColors lerp(ThemeExtension<_AlertColors>? other, double t) {
    if (other is! _AlertColors) return this;
    return _AlertColors(
      danger: Color.lerp(danger, other.danger, t),
      warning: Color.lerp(warning, other.warning, t),
      verified: Color.lerp(verified, other.verified, t),
      slateBlue: Color.lerp(slateBlue, other.slateBlue, t),
    );
  }
}

// Helper widgets & utilities

/// Small badge to represent alert level
class AlertBadge extends StatelessWidget {
  final FraudAlertLevel level;
  final String? label;

  const AlertBadge({super.key, required this.level, this.label});

  @override
  Widget build(BuildContext context) {
    final color = level.color(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Text(
            label ?? level.label(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Use this to show inline alert rows in lists or detail pages
class AlertRow extends StatelessWidget {
  final FraudAlertLevel level;
  final String title;
  final String? subtitle;

  const AlertRow({super.key, required this.level, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final color = level.color(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(
          Icons.security,
          color: color,
        ),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall) : null,
      trailing: Text(level.label(), style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }
}

// Example usage for snackbars and dialogs
void showFraudSnackBar(BuildContext context, FraudAlertLevel level, String message) {
  final color = level.color(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      content: Text(message, style: TextStyle(color: Colors.white)),
      action: SnackBarAction(label: 'Dismiss', onPressed: () {}, textColor: Colors.white),
    ),
  );
}

Future<T?> showFraudDialog<T>(BuildContext context, FraudAlertLevel level, String title, String content) {
  final color = level.color(context);
  return showDialog<T>(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning, color: color),
          SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: Text('Take Action')),
      ],
    ),
  );
}

// Small helpers to access palette quickly
extension FraudThemeColors on ThemeData {
  Color get fraudDanger => (extension<_AlertColors>()?.danger) ?? _FraudTheme.danger;
  Color get fraudWarning => (extension<_AlertColors>()?.warning) ?? _FraudTheme.amber;
  Color get fraudVerified => (extension<_AlertColors>()?.verified) ?? _FraudTheme.verified;
  Color get fraudPrimary => (extension<_AlertColors>()?.slateBlue) ?? _FraudTheme.slateBlue;
}

// End of file
