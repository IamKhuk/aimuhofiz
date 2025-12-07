import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'chat_page.dart';
import '../bloc/detection_bloc.dart';
import '../../../../injection_container.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _navigateToChat() {
    setState(() {
      _currentIndex = 2; // Index of AIChatPage
    });
  }

  Widget _buildAIMuhofizCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed to spaceBetween
        children: [
          // Logo and Texts
          Expanded(
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/logo.svg',
                  width: 40,
                  height: 40,
                ),
                const SizedBox(width: 12),
                const Flexible( // Added Flexible to prevent overflow
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
          // Chat Avatar Entry Point
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
        return _buildAIMuhofizCard();
      case 1:
        return const Text("Qo'ng'iroqlar Tarixi");
      case 2:
        return _buildAIMuhofizCard(); // Show card on Chat page too? Or just title? User asked to change Profile to Chat.
        // Actually, usually chat pages have a title "AI Chat".
        // But user said "Put ciricle avatart widget on the right side of ... and make it navigate to profile page".
        // Which implies the card is on home page.
        // On the chat page itself, standard title is better.
        // Let's keep specific titles for other pages.
        // REVISION: The User asked to replace Profile Page with AI Chatbox Page.
      default:
        return const Text('AI Muhofiz');
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return BlocProvider(
          create: (_) => sl<DetectionBloc>(),
          child: const HomePageContent(),
        );
      case 1:
        return BlocProvider(
          create: (_) => sl<DetectionBloc>()..add(const LoadDetectionsHistoryEvent()),
          child: const HistoryPageContent(),
        );
      case 2:
        return const AIChatPage();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 2
          ? null
          : AppBar(
              title: _currentIndex == 0 ? _buildAIMuhofizCard() : _getAppBarTitle(),
              backgroundColor: const Color(0xFF0F1720),
              elevation: 0,
              centerTitle: true,
            ),
      body: _getBody(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: const Color(0xFF131d2b), // Fixed const
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline), // Changed icon to chat
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'AI Chat', // Changed label to AI Chat
          ),
        ],
      ),
    );
  }
}

