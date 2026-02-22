import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/call_bloc.dart';
import '../widgets/call_control_button.dart';
import '../widgets/fraud_gauge_widget.dart';
import 'dtmf_keypad_page.dart';

/// Full-screen in-call UI with live fraud detection gauge.
class InCallPage extends StatelessWidget {
  const InCallPage({super.key});

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1720),
        body: SafeArea(
          child: BlocConsumer<CallBloc, CallBlocState>(
            listener: (context, state) {
              // Pop the page when call ends and returns to idle
              if (state is CallIdleState) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            builder: (context, state) {
              final String remoteNumber;
              final String statusText;
              final bool isMuted;
              final bool isSpeakerOn;
              final bool isOnHold;
              final bool isConnected;

              if (state is CallConnectedState) {
                remoteNumber = state.remoteNumber;
                isOnHold = state.isOnHold;
                statusText = state.isOnHold
                    ? 'Kutishda'
                    : _formatDuration(state.duration);
                isMuted = state.isMuted;
                isSpeakerOn = state.isSpeakerOn;
                isConnected = true;
              } else if (state is CallOutgoingState) {
                remoteNumber = state.number;
                statusText = 'Qo\'ng\'iroq qilinmoqda...';

                isMuted = false;
                isSpeakerOn = false;
                isOnHold = false;
                isConnected = false;
              } else if (state is CallIncomingState) {
                remoteNumber = state.callerNumber;
                statusText = 'Kiruvchi qo\'ng\'iroq';

                isMuted = false;
                isSpeakerOn = false;
                isOnHold = false;
                isConnected = false;
              } else if (state is CallEndedState) {
                remoteNumber = '';
                statusText = state.reason ?? 'Qo\'ng\'iroq tugadi';

                isMuted = false;
                isSpeakerOn = false;
                isOnHold = false;
                isConnected = false;
              } else {
                remoteNumber = '';
                statusText = '';

                isMuted = false;
                isSpeakerOn = false;
                isOnHold = false;
                isConnected = false;
              }

              // Get fraud result if connected
              final fraudResult = state is CallConnectedState
                  ? state.fraudResult
                  : null;

              return Column(
                children: [
                  const SizedBox(height: 40),
                  // Remote party info
                  Text(
                    remoteNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusText,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  // Fraud detection gauge (shown when connected)
                  if (isConnected || state is CallOutgoingState)
                    FraudGaugeWidget(
                      fraudResult: fraudResult,
                      size: 160,
                    ),
                  if (isConnected && fraudResult != null) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        fraudResult.warningMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: fraudResult.score >= 70
                              ? const Color(0xFFD32F2F)
                              : fraudResult.score >= 30
                                  ? const Color(0xFFFFC107)
                                  : Colors.white54,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Call controls
                  if (isConnected) _buildConnectedControls(context, isMuted, isSpeakerOn, isOnHold),
                  if (state is CallIncomingState)
                    _buildIncomingControls(context),
                  if (state is CallOutgoingState)
                    _buildOutgoingControls(context),
                  const SizedBox(height: 48),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedControls(
      BuildContext context, bool isMuted, bool isSpeakerOn, bool isOnHold) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CallControlButton(
                icon: isMuted ? Icons.mic_off : Icons.mic,
                label: 'Ovoz',
                isActive: isMuted,
                onPressed: () =>
                    context.read<CallBloc>().add(const ToggleMuteEvent()),
              ),
              CallControlButton(
                icon: Icons.dialpad,
                label: 'Klaviatura',
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (_) => BlocProvider.value(
                      value: context.read<CallBloc>(),
                      child: const DtmfKeypadPage(),
                    ),
                  );
                },
              ),
              CallControlButton(
                icon: isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                label: 'Dinamik',
                isActive: isSpeakerOn,
                onPressed: () =>
                    context.read<CallBloc>().add(const ToggleSpeakerEvent()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CallControlButton(
                icon: isOnHold ? Icons.play_arrow : Icons.pause,
                label: 'Kutish',
                isActive: isOnHold,
                onPressed: () =>
                    context.read<CallBloc>().add(const ToggleHoldEvent()),
              ),
              CallControlButton(
                icon: Icons.call_end,
                label: 'Tugatish',
                isEndCall: true,
                onPressed: () =>
                    context.read<CallBloc>().add(const HangUpCallEvent()),
              ),
              const SizedBox(width: 56), // Placeholder for alignment
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Reject
          GestureDetector(
            onTap: () =>
                context.read<CallBloc>().add(const RejectCallEvent()),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFD32F2F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call_end, color: Colors.white, size: 32),
            ),
          ),
          // Accept
          GestureDetector(
            onTap: () =>
                context.read<CallBloc>().add(const AnswerCallEvent()),
            child: Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFF2ECC71),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.call, color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutgoingControls(BuildContext context) {
    return CallControlButton(
      icon: Icons.call_end,
      label: 'Bekor qilish',
      isEndCall: true,
      onPressed: () =>
          context.read<CallBloc>().add(const HangUpCallEvent()),
    );
  }
}
