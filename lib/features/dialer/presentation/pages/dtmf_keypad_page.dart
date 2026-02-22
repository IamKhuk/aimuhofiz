import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/call_bloc.dart';
import '../widgets/dial_button.dart';

/// In-call DTMF keypad shown as a bottom sheet.
class DtmfKeypadPage extends StatelessWidget {
  const DtmfKeypadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF131D2B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Keypad grid
          for (int row = 0; row < 4; row++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int col = 0; col < 3; col++)
                    () {
                      final index = row * 3 + col;
                      if (index >= t9KeypadLayout.length) {
                        return const SizedBox(width: 72);
                      }
                      final entry = t9KeypadLayout[index];
                      return DialButton(
                        digit: entry.$1,
                        letters: entry.$2,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          context
                              .read<CallBloc>()
                              .add(SendDtmfEvent(entry.$1));
                        },
                      );
                    }(),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
