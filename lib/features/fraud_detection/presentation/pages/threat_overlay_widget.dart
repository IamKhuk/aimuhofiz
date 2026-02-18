import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../../../../core/services/fraud_detector.dart';
import '../../../../core/services/threat_overlay_service.dart';

class ThreatOverlayWidget extends StatefulWidget {
  const ThreatOverlayWidget({super.key});

  @override
  State<ThreatOverlayWidget> createState() => _ThreatOverlayWidgetState();
}

class _ThreatOverlayWidgetState extends State<ThreatOverlayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  FraudResult? _fraudResult;
  String? _phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadThreatData();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Listen for data updates from main app
    FlutterOverlayWindow.overlayListener.listen((data) {
      if (data != null && mounted) {
        try {
          final decoded = jsonDecode(data.toString());
          if (decoded['fraud_result'] != null) {
            setState(() {
              _fraudResult = FraudResult.fromJson(decoded['fraud_result']);
              _phoneNumber = decoded['phone_number'];
            });
          }
        } catch (e) {
          print('Error parsing overlay data: $e');
        }
      }
    });
  }

  Future<void> _loadThreatData() async {
    final data = await ThreatOverlayService.getStoredThreatData();
    if (data != null && mounted) {
      setState(() {
        _fraudResult =
            FraudResult.fromJson(data['fraud_result'] as Map<String, dynamic>);
        _phoneNumber = data['phone_number'] as String?;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Get color based on risk score
  /// Green: < 30%, Yellow: 30-70%, Red: > 70%
  Color _getRiskColor(double score) {
    if (score < 30) {
      return const Color(0xFF4CAF50); // Green
    } else if (score < 70) {
      return const Color(0xFFFFC107); // Yellow/Amber
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  /// Get border color based on risk score
  Color _getBorderColor(double score) {
    if (score < 30) {
      return const Color(0xFF81C784); // Light Green
    } else if (score < 70) {
      return const Color(0xFFFFD54F); // Light Yellow
    } else {
      return const Color(0xFFE57373); // Light Red
    }
  }

  /// Get warning message based on score
  String _getWarningMessage(double score) {
    if (score >= 95) {
      return "XAVFLI! Qo'ng'iroq tugatilmoqda...";
    } else if (score >= 70) {
      return "XAVF! Firibgarlik aniqlandi!";
    } else if (score >= 30) {
      return "DIQQAT! Shubhali belgilar";
    } else {
      return "Xavfsiz qo'ng'iroq";
    }
  }

  IconData _getRiskIcon(double score) {
    if (score >= 70) {
      return Icons.dangerous_rounded;
    } else if (score >= 30) {
      return Icons.warning_rounded;
    } else {
      return Icons.verified_user_rounded;
    }
  }

  Future<void> _onTap() async {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Close overlay
    await ThreatOverlayService.hideThreatOverlay();

    // Open the main app and navigate to threat page
    await FlutterOverlayWindow.closeOverlay();

    // Send intent to open app
    await FlutterOverlayWindow.shareData('open_threat_page');
  }

  @override
  Widget build(BuildContext context) {
    final score = _fraudResult?.score ?? 0.0;
    final riskColor = _getRiskColor(score);
    final borderColor = _getBorderColor(score);
    final icon = _getRiskIcon(score);
    final message = _getWarningMessage(score);

    return Material(
      color: Colors.transparent,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: GestureDetector(
          onTap: _onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: riskColor.withOpacity(0.4),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, color: riskColor, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Muhofiz',
                              style: TextStyle(
                                color: riskColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _phoneNumber ?? 'Noma\'lum',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await ThreatOverlayService.hideThreatOverlay();
                          await FlutterOverlayWindow.closeOverlay();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white54,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Warning message
                  Text(
                    message,
                    style: TextStyle(
                      color: riskColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // Progress bar with score
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Xavf darajasi',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  '${score.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: riskColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Progress bar — uses LayoutBuilder to adapt
                            // to the actual available width on any device.
                            LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        width: constraints.maxWidth *
                                            (score / 100),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              riskColor.withOpacity(0.7),
                                              riskColor,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  riskColor.withOpacity(0.5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Tap hint
                  Center(
                    child: Text(
                      'Bosib batafsil ko\'ring',
                      style: TextStyle(
                        color: riskColor.withOpacity(0.7),
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
