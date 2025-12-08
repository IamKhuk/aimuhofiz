import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'chatbot_data.dart';

class GeminiService {
  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isInitialized = false;
  final List<Map<String, String>> _chatHistory = [];

  static const String _historyKey = 'chat_history';

  /// Initialize Gemini API with API key from environment
  Future<void> initialize() async {
    try {
      await dotenv.load(fileName: ".env");
      var apiKey = dotenv.env['GEMINI_API_KEY'];

      if (apiKey == null || apiKey.isEmpty || apiKey == 'your_api_key_here') {
        _isInitialized = false;
        return;
      }

      // Sanitize key (remove quotes if user added them)
      apiKey = apiKey.replaceAll('"', '').replaceAll("'", '').trim();

      debugPrint('Gemini API Key loaded: ${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)} (Length: ${apiKey.length})');

      _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(_getSystemPrompt()),
      );

      // Load previous chat history
      await _loadChatHistory();

      // Start chat session with history
      _startChatWithHistory();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Gemini Initialization Error: $e');
      _isInitialized = false;
    }
  }

  /// Start or restart chat session with existing history
  void _startChatWithHistory() {
    if (_model == null) return;

    // Convert stored history to Gemini Content format
    final history = _chatHistory.map((msg) {
      if (msg['role'] == 'user') {
        return Content.text(msg['text']!);
      } else {
        return Content.model([TextPart(msg['text']!)]);
      }
    }).toList();

    _chat = _model!.startChat(history: history);
  }

  /// Load chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson != null) {
        final List<dynamic> decoded = json.decode(historyJson);
        _chatHistory.clear();
        _chatHistory.addAll(decoded.map((item) => Map<String, String>.from(item)));
        debugPrint('Loaded ${_chatHistory.length} messages from history');
      }
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  /// Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep only last 50 messages to save space
      final historyToSave = _chatHistory.length > 50
          ? _chatHistory.sublist(_chatHistory.length - 50)
          : _chatHistory;
      await prefs.setString(_historyKey, json.encode(historyToSave));
    } catch (e) {
      debugPrint('Error saving chat history: $e');
    }
  }

  /// Get chat history for UI
  List<Map<String, String>> get chatHistory => List.unmodifiable(_chatHistory);

  /// Check if Gemini API is available
  bool get isAvailable => _isInitialized && _model != null;

  /// Generate response using Gemini API with chat history
  Future<String?> generateResponse(String query) async {
    if (!isAvailable || _chat == null) return null;

    try {
      // Add user message to history
      _chatHistory.add({'role': 'user', 'text': query});

      // Send message with full context
      final response = await _chat!.sendMessage(Content.text(query));
      final responseText = response.text ?? '';

      // Add assistant response to history
      _chatHistory.add({'role': 'assistant', 'text': responseText});

      // Save history
      await _saveChatHistory();

      return responseText;
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      // Remove the user message since it failed
      if (_chatHistory.isNotEmpty && _chatHistory.last['role'] == 'user') {
        _chatHistory.removeLast();
      }
      // Return the error message starting with "ERROR:" so UI can distinguish it
      return "ERROR: $e";
    }
  }

  /// Clear chat history
  Future<void> clearHistory() async {
    _chatHistory.clear();
    await _saveChatHistory();
    _startChatWithHistory();
  }

  /// System prompt with project documentation
  String _getSystemPrompt() {
    return '''
Sen AI Muhofiz loyihasi bo'yicha yordamchi sun'iy intellektsan. O'zbekistonda telefon firibgarligini aniqlash tizimi haqida ma'lumot berasan.

MUHIM QOIDALAR:
1. Faqat AI Muhofiz loyihasi haqida savollarga javob ber
2. O'zbek tilida javob ber (agar savol o'zbek tilida bo'lsa)
3. Qisqa, aniq va tushunarli javob ber
4. Texnik atamalarni oddiy tilda tushuntir
5. Oldingi suhbatni eslab qol va davom ettir

LOYIHA HAQIDA MA'LUMOT:
${ChatbotData.getDocumentation()}

Agar savol loyiha bilan bog'liq bo'lmasa, "Men faqat AI Muhofiz loyihasi haqida savollarga javob bera olaman" deb javob ber.
''';
  }
}
