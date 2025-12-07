import 'package:flutter/material.dart';
import '../../domain/entities/detection.dart';
import '../../../../core/theme/fraud_detection_theme.dart';
import '../utils/threat_utils.dart';

/// A card widget that displays threat information
/// with a colored background that changes based on the risk level
class ThreatCardWidget extends StatelessWidget {
  final Detection detection;
  final VoidCallback onTap;

  const ThreatCardWidget({
    super.key,
    required this.detection,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final riskLevel = ThreatUtils.getRiskLevel(detection.score);
    final cardColor = riskLevel.color(context);
    final formattedTime = _formatTimeWithDuration(detection.timestamp);
    final formattedNumber = _formatPhoneNumber(detection.number);
    final callerName = _getCallerName(riskLevel);
    final flaggedReasons = _parseReasons(detection.reason);
    final statusText = _getStatusText(riskLevel);
    final isHighRisk = riskLevel == FraudAlertLevel.fraud;
    final textColor = Colors.white;
    final secondaryTextColor = Colors.white.withValues(alpha: 0.8);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Phone icon, Caller name/number, Risk badge
                Row(
                  children: [
                    // Phone icon in square container
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.phone,
                        color: textColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Caller name and number
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            callerName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                              fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formattedNumber,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 16,
                                  color: secondaryTextColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Risk badge with icon
                    _buildRiskBadge(context, riskLevel, cardColor, textColor),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Time and duration
                Text(
                  formattedTime,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: secondaryTextColor,
                    fontSize: 14,
                      ),
                ),
                const SizedBox(height: 12),
                
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: detection.score / 100,
                    backgroundColor: cardColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                    minHeight: 6,
                  ),
                ),
                
                // Flagged reasons (only for high risk)
                if (isHighRisk && flaggedReasons.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: textColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Anidlangan sabablar:",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...flaggedReasons.map((reason) => Padding(
                        padding: const EdgeInsets.only(left: 24, bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: textColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reason,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: textColor,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
                
                const SizedBox(height: 16),
                
                // Footer: Status and View Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Text(
                        'Batafsil',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.lightBlue[300],
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRiskBadge(
    BuildContext context,
    FraudAlertLevel riskLevel,
    Color cardColor,
    Color textColor,
  ) {
    final isHighRisk = riskLevel == FraudAlertLevel.fraud;
    final isSafe = riskLevel == FraudAlertLevel.safe;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: cardColor.withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isHighRisk ? Icons.close : (isSafe ? Icons.check : Icons.warning),
            color: textColor,
            size: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${detection.score.toStringAsFixed(0)}% xavf',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cardColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
        ),
      ],
    );
  }

  String _formatPhoneNumber(String number) {
    // Remove all non-digits
    final cleaned = number.replaceAll(RegExp(r'[^\d]'), '');

    // Uzbekistan numbers: 12 digits including +998 → 998901331212
    if (cleaned.length == 12 && cleaned.startsWith('998')) {
      final operator = cleaned.substring(3, 5);     // 90, 91, 93, ...
      final part1 = cleaned.substring(5, 8);        // 133
      final part2 = cleaned.substring(8, 10);       // 12
      final part3 = cleaned.substring(10, 12);      // 12
      return '+998 ($operator) $part1-$part2-$part3';
    }

    // If user enters without country code: 901331212
    if (cleaned.length == 9) {
      final operator = cleaned.substring(0, 2);
      final part1 = cleaned.substring(2, 5);
      final part2 = cleaned.substring(5, 7);
      final part3 = cleaned.substring(7, 9);
      return '+998 ($operator) $part1-$part2-$part3';
    }

    return number;
  }

  String _getCallerName(FraudAlertLevel riskLevel) {
    if (riskLevel == FraudAlertLevel.fraud) {
      return "Noma'lum Qo'ng'iroq";
    } else if (riskLevel == FraudAlertLevel.safe) {
      // For safe calls, try to extract a name or use a generic name
      // In a real app, this would come from contacts
      return "Tasdiqlandan Qo'ng'iroq";
    } else {
      return "Noma'lum Qo'ng'iroq";
    }
  }

  String _formatTimeWithDuration(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    String timeAgo;
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        timeAgo = '${difference.inMinutes}m oldin';
      } else {
        timeAgo = '${difference.inHours} ${difference.inHours == 1 ? 'soat' : 'soat'} oldin';
      }
    } else if (difference.inDays == 1) {
      timeAgo = 'Kecha';
    } else {
      timeAgo = '${difference.inDays}kun oldin';
    }
    
    // Format time in 12-hour format without AM/PM (e.g., "12:45")
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : (timestamp.hour == 0 ? 12 : timestamp.hour);
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final timeString = '$hour:$minute';
    
    // For duration, we'll use a placeholder since it's not in Detection
    // In a real app, this would come from call logs
    final duration = '0:34'; // Placeholder
    
    return '$timeAgo • $timeString';
  }

  List<String> _parseReasons(String reason) {
    // Try to parse multiple reasons from the reason string
    // Common patterns: "reason1, reason2, reason3" or "reason1 with reason2"
    final lowerReason = reason.toLowerCase();
    final reasons = <String>[];
    
    // Check for common fraud indicators
    if (lowerReason.contains('irs') || lowerReason.contains('impersonation')) {
      reasons.add('IRS impersonation');
    }
    if (lowerReason.contains('urgency') || lowerReason.contains('urgent')) {
      reasons.add('Urgency tactics');
    }
    if (lowerReason.contains('ssn') || lowerReason.contains('social security')) {
      reasons.add('Request for SSN');
    }
    if (lowerReason.contains('payment') || lowerReason.contains('pay')) {
      reasons.add('Payment request');
    }
    if (lowerReason.contains('account') || lowerReason.contains('verify')) {
      reasons.add('Account verification request');
    }
    if (lowerReason.contains('tech support') || lowerReason.contains('microsoft')) {
      reasons.add('Tech support impersonation');
    }
    if (lowerReason.contains('remote access')) {
      reasons.add('Remote access request');
    }
    
    // If no specific reasons found, use the original reason
    if (reasons.isEmpty) {
      reasons.add(reason);
    }
    
    return reasons;
  }

  String _getStatusText(FraudAlertLevel riskLevel) {
    switch (riskLevel) {
      case FraudAlertLevel.fraud:
        return 'Status: Firibgarlik Aniqlandi';
      case FraudAlertLevel.suspicious:
        return 'Status: Shubhali';
      case FraudAlertLevel.safe:
        return 'Status: Xavfsiz';
    }
  }
}

