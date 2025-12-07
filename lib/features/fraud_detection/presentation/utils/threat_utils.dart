import '../../../../core/theme/fraud_detection_theme.dart';

/// Utility class for threat-related calculations and helpers
class ThreatUtils {
  /// Determines the risk level based on the threat score
  /// - Score 0-30: Safe
  /// - Score 31-70: Suspicious
  /// - Score 71-100: Fraud
  static FraudAlertLevel getRiskLevel(double score) {
    if (score <= 30) {
      return FraudAlertLevel.safe;
    } else if (score <= 70) {
      return FraudAlertLevel.suspicious;
    } else {
      return FraudAlertLevel.fraud;
    }
  }

  /// Detects the language based on phone number patterns
  /// This is a simplified implementation - in production, you'd use
  /// a proper language detection service or phone number library
  static String detectLanguage(String phoneNumber) {
    final code = detectLanguageCode(phoneNumber);
    return getLanguageName(code);
  }

  /// Detects language code from phone number
  static String detectLanguageCode(String phoneNumber) {
    // Remove common phone number characters
    final cleaned = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    // Simple heuristics based on country codes
    if (cleaned.startsWith('998')) {
      return 'uz'; // Uzbekistan
    } else if (cleaned.startsWith('1')) {
      return 'en';
    } else if (cleaned.startsWith('44')) {
      return 'en';
    } else if (cleaned.startsWith('33')) {
      return 'fr';
    } else if (cleaned.startsWith('49')) {
      return 'de';
    } else if (cleaned.startsWith('34')) {
      return 'es';
    } else if (cleaned.startsWith('39')) {
      return 'it';
    } else if (cleaned.startsWith('81')) {
      return 'ja';
    } else if (cleaned.startsWith('86')) {
      return 'zh';
    } else if (cleaned.startsWith('91')) {
      return 'hi';
    } else if (cleaned.startsWith('7')) {
      return 'ru';
    } else {
      return 'unknown';
    }
  }

  /// Gets language name from language code
  static String getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'uz':
        return 'O\'zbek';
      case 'en':
        return 'Ingliz';
      case 'fr':
        return 'Fransuz';
      case 'de':
        return 'Nemis';
      case 'es':
        return 'Ispan';
      case 'it':
        return 'Italyan';
      case 'ja':
        return 'Yapon';
      case 'zh':
        return 'Xitoy';
      case 'hi':
        return 'Hind';
      case 'ru':
        return 'Rus';
      case 'ar':
        return 'Arab';
      case 'tr':
        return 'Turk';
      case 'fa':
        return 'Fors';
      default:
        return 'Noma\'lum';
    }
  }

  /// Formats the date for display
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Hozirgina';
        }
        return '${difference.inMinutes} daqiqa oldin';
      }
      return '${difference.inHours} soat oldin';
    } else if (difference.inDays == 1) {
      return 'Kecha';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kun oldin';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

