import 'package:flutter/material.dart';

/// A T9 keypad button widget for the VoIP dialer.
///
/// Displays a digit prominently with optional letter labels below (e.g., "ABC"
/// for the "2" key). Supports tap and long-press callbacks.
class DialButton extends StatelessWidget {
  /// The digit character to display ("0"-"9", "*", "#").
  final String digit;

  /// The letter label shown below the digit (e.g., "ABC"). Pass an empty
  /// string for keys that have no letters (like "1", "*", "#").
  final String letters;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// Called when the button is long-pressed (e.g., long-press "0" to enter "+").
  final VoidCallback? onLongPress;

  const DialButton({
    super.key,
    required this.digit,
    this.letters = '',
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: const Color(0xFF1E2D3D),
        shape: const CircleBorder(
          side: BorderSide(
            color: Color(0xFF2A3A4A),
            width: 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: const Color(0xFF3B82F6).withValues(alpha: 0.3),
          highlightColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
          customBorder: const CircleBorder(),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Digit
                Text(
                  digit,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                // Letter label (only shown when letters is non-empty)
                if (letters.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      letters,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.5,
                        height: 1.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard T9 keypad layout data.
///
/// Each entry is a record of (digit, letters). Use this with [DialButton] to
/// build a full keypad grid.
const List<(String, String)> t9KeypadLayout = [
  ('1', ''),
  ('2', 'ABC'),
  ('3', 'DEF'),
  ('4', 'GHI'),
  ('5', 'JKL'),
  ('6', 'MNO'),
  ('7', 'PQRS'),
  ('8', 'TUV'),
  ('9', 'WXYZ'),
  ('*', ''),
  ('0', '+'),
  ('#', ''),
];
