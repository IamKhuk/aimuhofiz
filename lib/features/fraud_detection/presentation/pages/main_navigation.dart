import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_page.dart';
import 'history_page.dart';
import '../bloc/detection_bloc.dart';
import '../bloc/call_history_bloc.dart';
import '../../../../injection_container.dart';
import '../../../../core/services/sip_service.dart';
import '../../../../core/services/telecom_bridge_service.dart';
import '../../../dialer/presentation/pages/keypad_page.dart';
import '../../../dialer/presentation/pages/contacts_page.dart';
import '../../../dialer/presentation/pages/incoming_call_page.dart';
import '../../../dialer/presentation/bloc/call_bloc.dart';
import '../../../dialer/presentation/bloc/sip_registration_bloc.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import 'package:sip_ua/sip_ua.dart' show CallStateEnum;

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late final CallBloc _callBloc;
  late final SipRegistrationBloc _sipRegBloc;

  @override
  void initState() {
    super.initState();
    _callBloc = CallBloc(sipService: SipService());
    _sipRegBloc = SipRegistrationBloc(sipService: SipService());

    // Listen for incoming calls to show incoming call UI
    SipService().callEventStream.listen((event) {
      if (event.state == CallStateEnum.CALL_INITIATION &&
          event.direction == 'INCOMING') {
        _showIncomingCallPage(event.remoteNumber);
      }
    });

    // Listen for dial intents from the system
    TelecomBridgeService.onDialRequest((number) {
      setState(() => _currentIndex = 0);
    });
  }

  @override
  void dispose() {
    _callBloc.close();
    _sipRegBloc.close();
    super.dispose();
  }

  void _showIncomingCallPage(String callerNumber) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _callBloc),
            BlocProvider.value(value: _sipRegBloc),
          ],
          child: IncomingCallPage(callerNumber: callerNumber),
        ),
      ),
    );
  }

  void _navigateToChat() {
    setState(() {
      _currentIndex = 3;
    });
  }

  Widget _buildAIMuhofizCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                const Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'AI Muhofiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Haqiqiy vaqtda qo'ng'iroqlarni himoya qilish",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _navigateToChat,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF007AFF),
                radius: 20,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return const Text('Telefon');
      case 1:
        return const Text("Qo'ng'iroqlar Tarixi");
      case 2:
        return const Text('Kontaktlar');
      case 3:
        return _buildAIMuhofizCard();
      default:
        return const Text('AI Muhofiz');
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: _callBloc),
            BlocProvider.value(value: _sipRegBloc),
          ],
          child: const KeypadPage(),
        );
      case 1:
        return BlocProvider(
          create: (_) =>
              sl<CallHistoryBloc>()..add(const LoadCallHistoryEvent()),
          child: const HistoryPageContent(),
        );
      case 2:
        return BlocProvider.value(
          value: _callBloc,
          child: const ContactsPage(),
        );
      case 3:
        return BlocProvider(
          create: (_) => sl<DetectionBloc>(),
          child: const HomePageContent(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? null
          : AppBar(
              title: _getAppBarTitle(),
              backgroundColor: const Color(0xFF0F1720),
              elevation: 0,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(value: _sipRegBloc),
                          ],
                          child: const SettingsPage(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
      body: _getBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color(0xFF131d2b),
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dialpad_outlined),
            selectedIcon: Icon(Icons.dialpad),
            label: 'Telefon',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Tarix',
          ),
          NavigationDestination(
            icon: Icon(Icons.contacts_outlined),
            selectedIcon: Icon(Icons.contacts),
            label: 'Kontaktlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'AI Muhofiz',
          ),
        ],
      ),
    );
  }
}
