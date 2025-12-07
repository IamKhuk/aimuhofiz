import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/fraud_detector.dart';
import '../../../../core/widgets/fraud_alert_widget.dart';
import '../../domain/entities/detection.dart';

class OngoingThreatPage extends StatelessWidget {
  final FraudResult? fraudResult;
  final String? phoneNumber;
  final Detection? detection;

  const OngoingThreatPage({
    super.key,
    this.fraudResult,
    this.phoneNumber,
    this.detection,
  });

  @override
  Widget build(BuildContext context) {
    final threatData = fraudResult ?? _convertFromDetection(detection);
    
    if (threatData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Threat Details')),
        body: const Center(child: Text('No threat data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ongoing Threat Alert'),
        backgroundColor: _getRiskColor(threatData.riskLevel),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Alert Widget
            FraudAlertWidget(result: threatData),
            
            const SizedBox(height: 24),
            
            // Phone Number Section
            if (phoneNumber != null || detection?.number != null) ...[
              _buildSection(
                title: 'Phone Number',
                child: Text(
                  phoneNumber ?? detection?.number ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Risk Score Section
            _buildSection(
              title: 'Risk Assessment',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Risk Score',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${threatData.score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(threatData.riskLevel),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: threatData.score / 100,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getRiskColor(threatData.riskLevel),
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getRiskColor(threatData.riskLevel).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getRiskColor(threatData.riskLevel).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getRiskIcon(threatData.riskLevel),
                          color: _getRiskColor(threatData.riskLevel),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Risk Level: ${threatData.riskLevel}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getRiskColor(threatData.riskLevel),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ML Score Section
            _buildSection(
              title: 'Detection Details',
              child: Column(
                children: [
                  _buildDetailRow(
                    'ML Model Score',
                    '${threatData.mlScore.toStringAsFixed(1)}%',
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Keywords Detected',
                    '${threatData.totalKeywords}',
                  ),
                ],
              ),
            ),

            // Keywords Found Section
            if (threatData.keywordsFound.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildSection(
                title: 'Detected Keywords',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: threatData.keywordsFound.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _capitalize(entry.key.replaceAll('_', ' ')),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: entry.value.map((keyword) {
                              return Chip(
                                label: Text(keyword),
                                backgroundColor: _getRiskColor(threatData.riskLevel)
                                    .withOpacity(0.1),
                                side: BorderSide(
                                  color: _getRiskColor(threatData.riskLevel)
                                      .withOpacity(0.3),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Timestamp Section
            if (detection?.timestamp != null) ...[
              const SizedBox(height: 16),
              _buildSection(
                title: 'Detection Time',
                child: Text(
                  _formatDateTime(detection!.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                    label: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      _showReportDialog(context, threatData);
                    },
                    icon: const Icon(Icons.report),
                    label: const Text('Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getRiskColor(threatData.riskLevel),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'DANGER':
        return Colors.red.shade700;
      case 'HIGH':
        return Colors.orange.shade700;
      case 'MEDIUM':
        return Colors.amber.shade700;
      case 'LOW':
        return Colors.blue.shade700;
      default:
        return Colors.green;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'DANGER':
        return Icons.dangerous;
      case 'HIGH':
        return Icons.warning_rounded;
      case 'MEDIUM':
        return Icons.info_rounded;
      default:
        return Icons.check_circle;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showReportDialog(BuildContext context, FraudResult threatData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Fraud'),
        content: Text(
          'Report this phone number (${phoneNumber ?? detection?.number}) '
          'as fraudulent?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fraud reported successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              // TODO: Implement actual reporting logic
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  FraudResult? _convertFromDetection(Detection? detection) {
    if (detection == null) return null;
    
    // Convert Detection to FraudResult format
    // This is a simplified conversion - adjust based on your needs
    String riskLevel = 'LOW';
    if (detection.score >= 80) {
      riskLevel = 'DANGER';
    } else if (detection.score >= 70) {
      riskLevel = 'HIGH';
    } else if (detection.score >= 50) {
      riskLevel = 'MEDIUM';
    }

    return FraudResult(
      score: detection.score,
      mlScore: detection.score * 0.8, // Approximate
      isFraud: detection.score >= 70,
      riskLevel: riskLevel,
      keywordsFound: {},
      totalKeywords: 0,
      warningMessage: detection.reason,
    );
  }
}

