import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import '../../../../core/services/fraud_detector.dart';
import '../../../../core/services/threat_overlay_service.dart';

/// Floating widget that appears on screen when fraud is detected
/// This is used as the overlay entry point
@pragma("vm:entry-point")
void threatOverlayMain() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ThreatOverlayWidget(),
    ),
  );
}

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
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadThreatData() async {
    final data = await ThreatOverlayService.getStoredThreatData();
    if (data != null && mounted) {
      setState(() {
        _fraudResult = FraudResult.fromJson(data['fraud_result'] as Map<String, dynamic>);
        _phoneNumber = data['phone_number'] as String?;
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getRiskColor() {
    if (_fraudResult == null) return Colors.red.shade700;
    switch (_fraudResult!.riskLevel) {
      case 'DANGER':
        return Colors.red.shade700;
      case 'HIGH':
        return Colors.orange.shade700;
      case 'MEDIUM':
        return Colors.amber.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  IconData _getRiskIcon() {
    if (_fraudResult == null) return Icons.warning;
    switch (_fraudResult!.riskLevel) {
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
    if (_fraudResult == null) {
      return const Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final riskColor = _getRiskColor();
    final riskIcon = _getRiskIcon();

    return Material(
      color: Colors.transparent,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: GestureDetector(
          onTap: _onTap,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: riskColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: riskColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(riskIcon, color: Colors.white, size: 24),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Fraud Alert',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await ThreatOverlayService.hideThreatOverlay();
                          await FlutterOverlayWindow.closeOverlay();
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fraudResult!.warningMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Risk Score',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            '${_fraudResult!.score.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _fraudResult!.riskLevel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to view details',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
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

