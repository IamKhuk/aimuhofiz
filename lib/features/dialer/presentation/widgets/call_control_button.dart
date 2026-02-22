import 'package:flutter/material.dart';

/// A circular button used for in-call controls (mute, speaker, hold, end call,
/// keypad toggle, etc.).
///
/// When [isEndCall] is true the button renders as a wider oblong pill shape
/// with a red background. Otherwise it renders as a circle that toggles between
/// an inactive and active color.
class CallControlButton extends StatelessWidget {
  /// The icon displayed in the center of the button.
  final IconData icon;

  /// Label text shown below the button.
  final String label;

  /// Whether the control is currently active (e.g., mute is on).
  final bool isActive;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// When true the button uses the "end call" style: red background and wider
  /// oblong shape.
  final bool isEndCall;

  /// Diameter of the circular button (or height of the oblong variant).
  /// Defaults to 56 logical pixels.
  final double size;

  const CallControlButton({
    super.key,
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onPressed,
    this.isEndCall = false,
    this.size = 56,
  });

  // Theme colors
  static const Color _inactiveBackground = Color(0xFF1E2D3D);
  static const Color _activeBackground = Color(0xFF3B82F6);
  static const Color _endCallBackground = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color iconColor;

    if (isEndCall) {
      backgroundColor = _endCallBackground;
      iconColor = Colors.white;
    } else if (isActive) {
      backgroundColor = _activeBackground;
      iconColor = Colors.white;
    } else {
      backgroundColor = _inactiveBackground;
      iconColor = Colors.white.withValues(alpha: 0.85);
    }

    // End-call variant is wider (oblong pill shape).
    final double buttonWidth = isEndCall ? size * 1.6 : size;
    final double buttonHeight = size;
    final BorderRadius borderRadius = isEndCall
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(size / 2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Button
        SizedBox(
          width: buttonWidth,
          height: buttonHeight,
          child: Material(
            color: backgroundColor,
            borderRadius: borderRadius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              borderRadius: borderRadius,
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: size * 0.43,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Label
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
