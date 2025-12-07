import 'package:flutter/material.dart';
import '../services/fraud_detector.dart';

/// Widget to display fraud detection alerts
class FraudAlertWidget extends StatelessWidget {
  final FraudResult result;

  const FraudAlertWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    IconData icon;
    
    switch (result.riskLevel) {
      case 'DANGER':
        bgColor = Colors.red;
        icon = Icons.warning;
        break;
      case 'HIGH':
        bgColor = Colors.orange;
        icon = Icons.error_outline;
        break;
      case 'MEDIUM':
        bgColor = Colors.yellow;
        icon = Icons.info_outline;
        break;
      case 'LOW':
        bgColor = Colors.blue;
        icon = Icons.info;
        break;
      default:
        bgColor = Colors.green;
        icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.warningMessage,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Xavf darajasi: ${result.score.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (result.totalKeywords > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Topilgan kalit so\'zlar: ${result.totalKeywords}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
          if (result.keywordsFound.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: result.keywordsFound.entries
                  .expand((entry) => entry.value.map((keyword) => Chip(
                        label: Text(
                          keyword,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.white.withOpacity(0.3),
                        padding: EdgeInsets.zero,
                      )))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

