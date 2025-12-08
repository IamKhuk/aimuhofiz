import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/chatbot_data.dart';
import '../../data/gemini_service.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = false;
  bool _isGeminiAvailable = false;
  
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _initializeGemini();
  }

  Future<void> _initializeGemini() async {
    await _geminiService.initialize();
    if (mounted) {
      setState(() {
        _isGeminiAvailable = _geminiService.isAvailable;

        // Load previous chat history
        final savedHistory = _geminiService.chatHistory;
        if (savedHistory.isNotEmpty) {
          // Restore previous messages
          for (final msg in savedHistory) {
            _messages.add(ChatMessage(
              text: msg['text'] ?? '',
              isUser: msg['role'] == 'user',
            ));
          }
          // Add separator for new session
          _messages.add(ChatMessage(
            text: "── Yangi sessiya ──",
            isUser: false,
            isSystem: true,
          ));
        } else {
          // Add welcome message for first time users
          _messages.add(ChatMessage(
            text: "Assalomu alaykum! Men AI Muhofiz loyihasi bo'yicha yordamchiman. Loyiha haqida istalgan savolingizni bering.",
            isUser: false,
          ));
        }
      });

      // Add status message
      if (_isGeminiAvailable) {
        _addSystemMessage("✓ AI rejimi: Onlayn");
      } else {
        _addSystemMessage("⚠ AI rejimi: Offline (kalit so'zlar)");
      }

      _scrollToBottom();
    }
  }

  void _addSystemMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        isSystem: true,
      ));
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
      // Add a temporary loading message
      _messages.add(const ChatMessage(
        text: "",
        isUser: false,
        isLoading: true,
      ));
    });

    _scrollToBottom();

    String answer;
    
    // Try Gemini first, fallback to keyword matching
    if (_isGeminiAvailable) {
      final geminiResponse = await _geminiService.generateResponse(text);
      if (geminiResponse != null && geminiResponse.isNotEmpty && !geminiResponse.startsWith("ERROR:")) {
        answer = geminiResponse;
      } else {
        // Gemini failed, use fallback
        answer = ChatbotData.getAnswer(text);
        String errorMsg = geminiResponse?.startsWith("ERROR:") == true 
            ? geminiResponse!.substring(7) // Remove "ERROR: " prefix
            : "Unknown error";
        // Convert to system message later, but for now just prepare answer logic
        if (mounted) {
           _addSystemMessage("⚠ Error: $errorMsg\nOffline rejimga o'tdim");
        }
      }
    } else {
      // Use keyword matching directly
      answer = ChatbotData.getAnswer(text);
    }

    if (mounted) {
      setState(() {
        // Remove the loading message
        _messages.removeWhere((msg) => msg.isLoading && !msg.isUser);
        
        _messages.add(ChatMessage(text: answer, isUser: false));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _showClearHistoryDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C2C3E),
        title: const Text(
          'Tarixni tozalash',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Barcha suhbat tarixini o\'chirmoqchimisiz?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Bekor qilish'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'O\'chirish',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _geminiService.clearHistory();
      setState(() {
        _messages.clear();
        _messages.add(ChatMessage(
          text: "Assalomu alaykum! Men AI Muhofiz loyihasi bo'yicha yordamchiman. Loyiha haqida istalgan savolingizni bering.",
          isUser: false,
        ));
      });
      _addSystemMessage("✓ Tarix tozalandi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1720),
      appBar: AppBar(
        title: const Text('AI Chatbox'),
        backgroundColor: const Color(0xFF0F1720),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: "Tarixni tozalash",
            onPressed: () => _showClearHistoryDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF131d2b),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !_isLoading,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: _isLoading ? 'Javob kutilmoqda...' : 'Savol bering...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: _isLoading ? null : _handleSubmitted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF007AFF),
                      shape: BoxShape.circle,
                    ),
                    child: _isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: () => _handleSubmitted(_controller.text),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isSystem;
  final bool isLoading;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
    this.isSystem = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // System messages (centered, italic)
    if (isSystem) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF007AFF),
                radius: 16,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SvgPicture.asset(
                    'assets/icons/logo.svg', // Assuming this exists from previous files
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? const Color(0xFF007AFF)
                    : const Color(0xFF1C2C3E),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 40,
                      height: 24,
                      child: Center(
                        child: ThreeDotsLoading(),
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
            ),
          ),
          if (isUser) ...[
             const SizedBox(width: 8),
             // Optional: User avatar placeholder
             const CircleAvatar(
               backgroundColor: Color(0xFF5AC8FA),
               radius: 16,
               child: Icon(Icons.person, size: 20, color: Colors.white),
             ),
          ],
        ],
      ),
    );
  }
}

class ThreeDotsLoading extends StatefulWidget {
  const ThreeDotsLoading({super.key});

  @override
  State<ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<ThreeDotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat();
      
    _controller.addListener(() {
      setState(() {
        _currentIndex = (_controller.value * 3).floor();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? Colors.white
                : Colors.white.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}

