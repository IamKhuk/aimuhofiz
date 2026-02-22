import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/call_bloc.dart';
import 'in_call_page.dart';

/// Full-screen incoming call UI with accept/reject.
class IncomingCallPage extends StatefulWidget {
  final String callerNumber;

  const IncomingCallPage({super.key, required this.callerNumber});

  @override
  State<IncomingCallPage> createState() => _IncomingCallPageState();
}

class _IncomingCallPageState extends State<IncomingCallPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1720),
        body: SafeArea(
          child: BlocListener<CallBloc, CallBlocState>(
            listener: (context, state) {
              if (state is CallConnectedState) {
                // Replace with in-call page when answered
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<CallBloc>(),
                      child: const InCallPage(),
                    ),
                  ),
                );
              } else if (state is CallIdleState || state is CallEndedState) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Pulsing phone icon
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale =
                        1.0 + (_pulseController.value * 0.1);
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Color(0xFF2ECC71),
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Caller info
                const Text(
                  'Kiruvchi qo\'ng\'iroq',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.callerNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(flex: 3),
                // Accept / Reject buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Reject
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<CallBloc>()
                                  .add(const RejectCallEvent());
                            },
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD32F2F),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Rad etish',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Accept
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<CallBloc>()
                                  .add(const AnswerCallEvent());
                            },
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2ECC71),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Qabul qilish',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
