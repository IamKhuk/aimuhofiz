import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:firib_lock/core/services/fraud_detector.dart';

/// A circular gauge widget that visualizes a fraud score from 0 to 100.
///
/// Color transitions smoothly from green (safe) through yellow (caution) to
/// red (danger) based on the score. When [fraudResult] is null the widget shows
/// an "Analyzing..." state with a pulsing animation.
class FraudGaugeWidget extends StatefulWidget {
  /// The fraud analysis result. Pass `null` while analysis is in progress.
  final FraudResult? fraudResult;

  /// Overall diameter of the gauge. Defaults to 120 logical pixels.
  final double size;

  const FraudGaugeWidget({
    super.key,
    this.fraudResult,
    this.size = 120,
  });

  @override
  State<FraudGaugeWidget> createState() => _FraudGaugeWidgetState();
}

class _FraudGaugeWidgetState extends State<FraudGaugeWidget>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  double _previousScore = 0;

  // Color constants matching theme palette.
  static const Color _safeGreen = Color(0xFF2ECC71);
  static const Color _warningOrange = Color(0xFFFFC107);
  static const Color _dangerRed = Color(0xFFD32F2F);
  static const Color _trackColor = Color(0xFF1E2D3D);

  @override
  void initState() {
    super.initState();

    // Score arc animation
    _scoreController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scoreAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
    );

    // Pulse animation for the "Analyzing..." state
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant FraudGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldScore = oldWidget.fraudResult?.score ?? 0;
    final newScore = widget.fraudResult?.score ?? 0;

    if (oldScore != newScore ||
        (oldWidget.fraudResult == null) != (widget.fraudResult == null)) {
      _syncAnimation();
    }
  }

  void _syncAnimation() {
    if (widget.fraudResult != null) {
      _pulseController.stop();

      final targetScore = widget.fraudResult!.score.clamp(0, 100).toDouble();
      _scoreAnimation = Tween<double>(
        begin: _previousScore,
        end: targetScore,
      ).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.easeOutCubic),
      );

      _scoreController.forward(from: 0).then((_) {
        _previousScore = targetScore;
      });
    } else {
      _previousScore = 0;
      _scoreAnimation = Tween<double>(begin: 0, end: 0).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.linear),
      );
      _scoreController.reset();

      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Linearly interpolate a color based on the current score.
  static Color _colorForScore(double score) {
    if (score < 30) {
      // Green to yellow
      final t = score / 30;
      return Color.lerp(_safeGreen, _warningOrange, t)!;
    } else if (score < 70) {
      // Yellow to red
      final t = (score - 30) / 40;
      return Color.lerp(_warningOrange, _dangerRed, t)!;
    } else {
      return _dangerRed;
    }
  }

  /// Human-readable risk label derived from the score.
  static String _riskLabel(double score) {
    if (score >= 80) return 'DANGER';
    if (score >= 70) return 'HIGH';
    if (score >= 50) return 'MEDIUM';
    if (score >= 30) return 'LOW';
    return 'SAFE';
  }

  @override
  Widget build(BuildContext context) {
    final isAnalyzing = widget.fraudResult == null;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scoreAnimation, _pulseAnimation]),
        builder: (context, _) {
          final score = _scoreAnimation.value;
          final pulseOpacity = _pulseAnimation.value;
          final arcColor = isAnalyzing
              ? Colors.white.withValues(alpha: pulseOpacity * 0.6)
              : _colorForScore(score);

          return CustomPaint(
            painter: _GaugeArcPainter(
              score: isAnalyzing ? 0 : score,
              arcColor: arcColor,
              trackColor: _trackColor,
              strokeWidth: widget.size * 0.08,
              isAnalyzing: isAnalyzing,
              pulseOpacity: pulseOpacity,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAnalyzing) ...[
                    Icon(
                      Icons.query_stats_rounded,
                      color: Colors.white.withValues(alpha: pulseOpacity),
                      size: widget.size * 0.22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analyzing...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: pulseOpacity),
                        fontSize: widget.size * 0.1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Text(
                      '${score.round()}%',
                      style: TextStyle(
                        color: arcColor,
                        fontSize: widget.size * 0.24,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.fraudResult?.riskLevel ?? _riskLabel(score),
                      style: TextStyle(
                        color: arcColor.withValues(alpha: 0.85),
                        fontSize: widget.size * 0.1,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom painter that draws the background track and the colored score arc.
class _GaugeArcPainter extends CustomPainter {
  final double score;
  final Color arcColor;
  final Color trackColor;
  final double strokeWidth;
  final bool isAnalyzing;
  final double pulseOpacity;

  _GaugeArcPainter({
    required this.score,
    required this.arcColor,
    required this.trackColor,
    required this.strokeWidth,
    required this.isAnalyzing,
    required this.pulseOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;

    // The arc spans 270 degrees (from 135 deg to 405 deg, i.e., starting at
    // bottom-left and sweeping clockwise to bottom-right).
    const startAngle = math.pi * 0.75; // 135 degrees
    const totalSweep = math.pi * 1.5; // 270 degrees

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, totalSweep, false, trackPaint);

    // Score arc
    if (!isAnalyzing && score > 0) {
      final sweepAngle = totalSweep * (score / 100);
      final arcPaint = Paint()
        ..color = arcColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
    }

    // Pulsing track effect while analyzing
    if (isAnalyzing) {
      final pulsePaint = Paint()
        ..color = Colors.white.withValues(alpha: pulseOpacity * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, totalSweep, false, pulsePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GaugeArcPainter oldDelegate) {
    return oldDelegate.score != score ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.isAnalyzing != isAnalyzing ||
        oldDelegate.pulseOpacity != pulseOpacity;
  }
}
