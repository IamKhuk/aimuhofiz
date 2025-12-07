import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'chatbot_data.dart';

class GeminiService {
  GenerativeModel? _model;
  bool _isInitialized = false;

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
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(_getSystemPrompt()),
      );
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Gemini Initialization Error: $e');
      _isInitialized = false;
    }
  }

  /// Check if Gemini API is available
  bool get isAvailable => _isInitialized && _model != null;

  /// Generate response using Gemini API
  Future<String?> generateResponse(String query) async {
    if (!isAvailable) return null;

    try {
      final content = [Content.text(query)];
      final response = await _model!.generateContent(content);
      return response.text;
    } catch (e) {
      debugPrint('Gemini API Error: $e');
      // Return the error message starting with "ERROR:" so UI can distinguish it
      return "ERROR: $e";
    }
  }

  /// System prompt with project documentation
  String _getSystemPrompt() {
    return '''
Sen AI Muhofiz loyihasi bo'yicha yordamchi sun'iy intellektsан. O'zbekistonda telefon firibgarligini aniqlash tizimi haqida ma'lumot berasаn.

MUHIM QOIDALAR:
1. Faqat AI Muhofiz loyihasi haqida savollarga javob ber
2. O'zbek tilida javob ber (agar savol o'zbek tilida bo'lsa)
3. Qisqa, aniq va tushunarli javob ber
4. Texnik atamalarni oddiy tilda tushuntir

LOYIHA HAQIDA MA'LUMOT:
${ChatbotData.getDocumentation()}

Agar savol loyiha bilan bog'liq bo'lmasa, "Men faqat AI Muhofiz loyihasi haqida savollarga javob bera olaman" deb javob ber.
''';
  }
}
