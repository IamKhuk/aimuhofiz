import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/services/telecom_bridge_service.dart';
import '../../../dialer/presentation/bloc/sip_registration_bloc.dart';

/// Settings page: SIP status, default dialer toggle, logout.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDefaultDialer = false;

  @override
  void initState() {
    super.initState();
    _checkDefaultDialer();
  }

  Future<void> _checkDefaultDialer() async {
    final result = await TelecomBridgeService.isDefaultDialer();
    if (mounted) {
      setState(() => _isDefaultDialer = result);
    }
  }

  Future<void> _requestDefaultDialer() async {
    await TelecomBridgeService.requestDefaultDialer();
    await _checkDefaultDialer();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2D3D),
        title: const Text(
          'Chiqish',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Hisobdan chiqishni xohlaysizmi?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Yo'q"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Ha',
              style: TextStyle(color: Color(0xFFD32F2F)),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1720),
      appBar: AppBar(
        title: const Text('Sozlamalar'),
        backgroundColor: const Color(0xFF0F1720),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // SIP Registration Status
          _buildSectionHeader('SIP Holati'),
          BlocBuilder<SipRegistrationBloc, SipRegistrationState>(
            builder: (context, state) {
              final Color statusColor;
              final String statusText;
              final IconData statusIcon;

              if (state is SipRegistered) {
                statusColor = const Color(0xFF2ECC71);
                statusText = 'Ulangan';
                statusIcon = Icons.check_circle;
              } else if (state is SipRegistering) {
                statusColor = const Color(0xFFFFC107);
                statusText = 'Ulanmoqda...';
                statusIcon = Icons.sync;
              } else if (state is SipRegistrationFailed) {
                statusColor = const Color(0xFFD32F2F);
                statusText = 'Xatolik: ${state.reason ?? "noma'lum"}';
                statusIcon = Icons.error;
              } else {
                statusColor = Colors.grey;
                statusText = 'Ulanmagan';
                statusIcon = Icons.circle_outlined;
              }

              return _buildTile(
                icon: statusIcon,
                iconColor: statusColor,
                title: "VoIP holati",
                subtitle: statusText,
                trailing: state is SipRegistered
                    ? null
                    : TextButton(
                        onPressed: () {
                          context
                              .read<SipRegistrationBloc>()
                              .add(const RegisterEvent());
                        },
                        child: const Text('Ulash'),
                      ),
              );
            },
          ),

          const Divider(color: Colors.white12),

          // Default Dialer
          _buildSectionHeader("Standart Dastur"),
          _buildTile(
            icon: _isDefaultDialer ? Icons.check_circle : Icons.phone,
            iconColor:
                _isDefaultDialer ? const Color(0xFF2ECC71) : Colors.white54,
            title: "Standart telefon ilovasi",
            subtitle: _isDefaultDialer
                ? "FiribLock standart telefon ilovasi"
                : "FiribLock standart qilib o'rnating",
            trailing: _isDefaultDialer
                ? null
                : TextButton(
                    onPressed: _requestDefaultDialer,
                    child: const Text("O'rnatish"),
                  ),
          ),

          const Divider(color: Colors.white12),

          // Account
          _buildSectionHeader("Hisob"),
          FutureBuilder<String?>(
            future: AuthService.getUsername(),
            builder: (context, snapshot) {
              return _buildTile(
                icon: Icons.person,
                iconColor: const Color(0xFF3B82F6),
                title: snapshot.data ?? 'Foydalanuvchi',
                subtitle: "Hisob nomi",
              );
            },
          ),
          _buildTile(
            icon: Icons.logout,
            iconColor: const Color(0xFFD32F2F),
            title: 'Chiqish',
            subtitle: "Hisobdan chiqish",
            onTap: _logout,
          ),

          const SizedBox(height: 32),

          // App version
          Center(
            child: Text(
              'FiribLock v1.0.0',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF3B82F6),
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
