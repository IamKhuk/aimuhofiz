class ChatbotData {
  static const String defaultAnswer =
      "Uzr, men bu savolga javob bera olmayman. Men faqat AI Muhofiz loyihasi bo'yicha savollarga javob bera olaman.";

  /// Get answer using keyword matching (fallback method)
  static String getAnswer(String query) {
    final lowerQuery = query.toLowerCase();

    for (var item in _qaList) {
      for (var keyword in item.keywords) {
        if (lowerQuery.contains(keyword)) {
          return item.answer;
        }
      }
    }

    return defaultAnswer;
  }

  /// Get full documentation for Gemini context
  static String getDocumentation() {
    final buffer = StringBuffer();
    
    buffer.writeln('=== AI MUHOFIZ - LOYIHA HUJJATLARI ===\n');
    
    for (var item in _qaList) {
      buffer.writeln('MAVZU: ${item.keywords.first}');
      buffer.writeln(item.answer);
      buffer.writeln('\n---\n');
    }
    
    return buffer.toString();
  }


  static final List<_QAItem> _qaList = [
    _QAItem(
      keywords: ["loyiha", "muhofiz", "nima bu", "qanaqa"],
      answer: """AI Muhofiz - bu sun'iy intellektga asoslangan telefon firibgarligini aniqlash tizimi. 
      
Asosiy maqsadi - O'zbekiston fuqarolarini telefon firibgarlaridan himoya qilish.
      
Qo'ng'iroq vaqtida:
1. Ovozni matnga aylantiradi
2. Firibgarlik belgilariga tekshiradi
3. Xavf darajasini hisoblaydi
4. Real vaqtda ogohlantiradi""",
    ),
    _QAItem(
      keywords: ["texnologiya", "backend", "python", "fastapi"],
      answer: """Backend: Python 3.10+, FastAPI, Uvicorn.
      
AI/ML: Scikit-learn, TensorFlow Lite, TF-IDF.
      
Speech: Vosk (offline), OpenAI Whisper (optional).
      
Security: Rate Limiting, Data Masking.""",
    ),
    _QAItem(
      keywords: ["arxitektura", "qurilish", "fayl", "tuzilishi"],
      answer: """Loyiha fraudguard/ papkasida joylashgan.
      
app/: Asosiy ilova (main.py, config.py)
services/: ML va tahlil xizmatlari (fraud_detector.py, risk_scorer.py)
models/: AI modellari (.pkl, .tflite) va Pydantic sxemalar
flutter_integration/: Mobil ilova kodlari""",
    ),
    _QAItem(
      keywords: ["xavf daraja", "low", "medium", "high", "danger", "ball"],
      answer: """Xavf darajalari (0-100 ball):
      
LOW (0-30): Xavfsiz
MEDIUM (31-50): Ehtiyot bo'ling
HIGH (51-70): Xavfli
DANGER (71-100): Juda xavfli""",
    ),
    _QAItem(
      keywords: ["hisoblash", "score", "vazn"],
      answer: """Ball 5 ta komponentdan yig'iladi:
1. Keywords (30%)
2. Sentiment (20%)
3. Voice Features (10%)
4. Fraud Patterns (20%)
5. ML Model (20%)""",
    ),
    _QAItem(
      keywords: ["kalit so'z", "keywords", "kategoriya"],
      answer: """10 ta firibgarlik kategoriyasi mavjud, masalan:
- Bank ma'lumotlari so'rash (0.95)
- Pul so'rash (0.90)
- Tahdid qilish (0.85)
- Soxta yutuq (0.80)
- Shoshilinchlik (0.70)""",
    ),
    _QAItem(
      keywords: ["sentiment", "kayfiyat", "urgency", "manipulation", "threat"],
      answer: """Sentiment 3 qismdan iborat:
1. Urgency (Shoshilinchlik): "tezda", "hoziroq"
2. Manipulation: "ishoning", "sir saqlang"
3. Threat (Tahdid): "bloklash", "sudga berish" """,
    ),
    _QAItem(
      keywords: ["ml model", "machine learning", "sklearn", "tfidf"],
      answer: """Model TF-IDF Vectorizer va Gradient Boosting Classifier ishlatadi.
      
400+ namunada o'rgatilgan (Firibgarlik va Xavfsiz misollar).
Aniqlik: ~95%""",
    ),
    _QAItem(
      keywords: ["offline", "internet", "vosk"],
      answer: """Offline rejim maxfiylik va tezlik uchun kerak.
Vosk kutubxonasi yordamida nutq qurilmaning o'zida matnga aylantiriladi.
Barcha tahlillar internetisiz ishlaydi.""",
    ),
    _QAItem(
      keywords: ["sms", "otp", "xabar"],
      answer: """SMS tahlili:
- OTP kodlarni (4-8 xonali) aniqlaydi
- Bank SMSlarini taniydi
- Agar qo'ng'iroq vaqtida OTP kelsa -> DANGER ogohlantirish beradi.""",
    ),
    _QAItem(
      keywords: ["maxfiylik", "privacy", "himoya", "masking"],
      answer: """Ma'lumotlar himoyasi:
1. Data Masking: Karta raqam (8600 **** **** 1234) va telefonlarni yashiradi
2. Secure Deletion: Fayllarni o'chirishdan oldin ustidan yozib tashlaydi
3. Logs: Maxfiy ma'lumotlar loglarda saqlanmaydi.""",
    ),
    _QAItem(
      keywords: ["api", "endpoint", "server"],
      answer: """Asosiy APIlar:
/api/v1/analyze/text (Matn tahlili)
/api/v1/analyze/file (Audio fayl)
/api/v1/stream (Real-time WebSocket)
/api/v1/offline/sms (Offline SMS)""",
    ),
    _QAItem(
      keywords: ["flutter", "mobil", "tflite"],
      answer: """Flutter ilovasi TFLite modeldan foydalanadi.
Model hajmi juda kichik (~300 KB).
Android (CallScreeningService) va iOS (CallKit) bilan integratsiya qilingan.""",
    ),
    _QAItem(
      keywords: ["ovoz", "voice", "pitch", "stress"],
      answer: """Ovoz tahlili parametrlari:
- Gapirish tezligi (WPM)
- Ovoz balandligi (Pitch)
- Ovoz o'zgaruvchanligi (Stress)
- Pauzalar nisbati
Agar stress yuqori bo'lsa, xavf balli oshiriladi.""",
    ),
     _QAItem(
      keywords: ["false positive", "xato"],
      answer: """False Positive - xavfsiz narsani xavfli deb o'ylash.
Buni kamaytirish uchun kontekst va bir nechta belgilar (kombinatsiya) tekshiriladi.""",
    ),
     _QAItem(
      keywords: ["docker", "deploy", "container"],
      answer: """Docker orqali oson ishga tushiriladi:
`docker-compose up -d`
Python 3.10-slim image ishlatiladi.""",
    ),
  ];
}

class _QAItem {
  final List<String> keywords;
  final String answer;

  _QAItem({required this.keywords, required this.answer});
}
