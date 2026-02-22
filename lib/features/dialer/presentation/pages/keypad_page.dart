import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/call_bloc.dart';
import '../bloc/sip_registration_bloc.dart';
import '../widgets/dial_button.dart';
import 'in_call_page.dart';

class KeypadPage extends StatefulWidget {
  const KeypadPage({super.key});

  @override
  State<KeypadPage> createState() => _KeypadPageState();
}

class _KeypadPageState extends State<KeypadPage> {
  String _phoneNumber = '';

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    setState(() {
      _phoneNumber += digit;
    });
  }

  void _onBackspace() {
    if (_phoneNumber.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }

  void _onLongPressBackspace() {
    if (_phoneNumber.isNotEmpty) {
      HapticFeedback.mediumImpact();
      setState(() {
        _phoneNumber = '';
      });
    }
  }

  void _onLongPressZero() {
    HapticFeedback.lightImpact();
    setState(() {
      _phoneNumber += '+';
    });
  }

  void _onCall() {
    if (_phoneNumber.isEmpty) return;

    HapticFeedback.mediumImpact();
    context.read<CallBloc>().add(InitiateCallEvent(_phoneNumber));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<CallBloc>(),
          child: const InCallPage(),
        ),
      ),
    );
  }

  /// Pre-fill number from dial intent.
  void prefillNumber(String number) {
    setState(() {
      _phoneNumber = number;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1720),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // SIP Registration status
            BlocBuilder<SipRegistrationBloc, SipRegistrationState>(
              builder: (context, state) {
                final Color color;
                final String text;
                if (state is SipRegistered) {
                  color = const Color(0xFF2ECC71);
                  text = 'Ulangan';
                } else if (state is SipRegistering) {
                  color = const Color(0xFFFFC107);
                  text = 'Ulanmoqda...';
                } else if (state is SipRegistrationFailed) {
                  color = const Color(0xFFD32F2F);
                  text = 'Ulanmadi';
                } else {
                  color = Colors.grey;
                  text = 'Ulanmagan';
                }
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      text,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                );
              },
            ),
            // Phone number display
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          _phoneNumber.isEmpty ? '' : _phoneNumber,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _phoneNumber.length > 12 ? 28 : 36,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (_phoneNumber.isNotEmpty)
                        GestureDetector(
                          onTap: _onBackspace,
                          onLongPress: _onLongPressBackspace,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.backspace_outlined,
                              color: Colors.white54,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            // Keypad grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
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
                                onTap: () => _onDigitPressed(entry.$1),
                                onLongPress: entry.$1 == '0'
                                    ? _onLongPressZero
                                    : null,
                              );
                            }(),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Call button
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: GestureDetector(
                onTap: _onCall,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2ECC71),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
