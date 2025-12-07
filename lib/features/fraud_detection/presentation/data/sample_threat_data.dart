import '../../domain/entities/detection.dart';
import '../models/threat_details_model.dart';

/// Sinov va namoyish uchun namuna xavf ma'lumotlari
class SampleThreatData {
  /// Soliq xizmati o'rniga o'tish - Yuqori xavf
  static ThreatDetailsModel get irsImpersonationScam {
    final detection = Detection(
      number: '+998970011505',
      score: 95.0,
      reason: "Shoshilinch taktikalar bilan soliq xizmati o'rniga o'tish aniqlandi",
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      reported: false,
    );

    return ThreatDetailsModel.fromDetection(
      detection,
      callerName: "Noma'lum qo'ng'iroqchi",
      callDuration: const Duration(seconds: 34),
      location: "Noma'lum / Soxtalashtirilgan",
      carrier: 'VoIP Xizmati',
      callType: 'Kiruvchi',
      reportedCount: 127,
      riskScore: 95.0,
      riskLevel: 'danger',
      confidence: 0.96,
      flaggedReasons: [
        "Soliq xizmati o'rniga o'tish",
        'Shoshilinch taktikalar',
        "Ijtimoiy sug'urta raqami so'rovi",
      ],
      aiAnalysis: AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.94,
          findings: [
            'Robot ovoz naqshlari',
            "Da'vo qilingan joy bilan mos kelmaydigan fon shovqini",
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.98,
          findings: [
            "Soliq xizmati o'rniga o'tish tili",
            'Qonuniy harakatlar bilan tahdid',
            "Darhol to'lov so'rovi",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.92,
          patterns: [
            'Yuqori bosim taktikasi',
            "Qayta qo'ng'iroq raqamini berishdan bosh tortish",
            'Hozir harakat qilish shoshilinchligi',
          ],
        ),
      ),
      timelineEvents: [
        TimelineEvent(
          event: "Qo'ng'iroq boshlandi",
          timestamp: const Duration(seconds: 0),
          type: EventType.info,
        ),
        TimelineEvent(
          event: "Qo'ng'iroqchi ID tahlili yakunlandi",
          timestamp: const Duration(seconds: 5),
          type: EventType.warning,
        ),
        TimelineEvent(
          event: "Shubhali kalit so'z aniqlandi",
          timestamp: const Duration(seconds: 12),
          type: EventType.warning,
        ),
        TimelineEvent(
          event: 'Shoshilinch taktikalar aniqlandi',
          timestamp: const Duration(seconds: 18),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: 'Firibgarlik naqshi tasdiqlandi',
          timestamp: const Duration(seconds: 25),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "Qo'ng'iroq tugadi - Foydalanuvchi ogohlantirildi",
          timestamp: const Duration(seconds: 34),
          type: EventType.danger,
        ),
      ],
      transcription:
          "Bu Ichki Soliq Xizmati. Siz qarz soliqlarini to'lashingiz kerak va darhol to'lashingiz yoki hibsga olinishingiz kerak. Iltimos, shaxsingizni tasdiqlash uchun Ijtimoiy Sug'urta raqamingizni kiriting.",
      keywordMatches: [
        KeywordMatch(
          keyword: 'Soliq xizmati',
          category: 'government_impersonation',
          weight: 0.95,
        ),
        KeywordMatch(
          keyword: 'hibsga olish',
          category: 'threat_intimidation',
          weight: 0.90,
        ),
        KeywordMatch(
          keyword: "Ijtimoiy Sug'urta raqami",
          category: 'personal_info_request',
          weight: 0.98,
        ),
      ],
      voiceFeatures: const VoiceFeatures(
        speakingRate: 180.0,
        pitchMean: 250.0,
        stressLevel: 85.0,
      ),
      warningMessage: "Yuqori xavfli firibgarlik aniqlandi: soliq xizmati o'rniga o'tish firibgarligi",
      shouldWarnUser: true,
    );
  }

  /// Texnik yordam firibgarligi - O'rtacha-Yuqori xavf
  static ThreatDetailsModel get techSupportScam {
    final detection = Detection(
      number: '+998915673403',
      score: 78.0,
      reason: "Masofaviy kirish so'rovi bilan texnik yordam firibgarligi",
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      reported: false,
    );

    return ThreatDetailsModel.fromDetection(
      detection,
      callerName: 'Microsoft Yordam',
      callDuration: const Duration(minutes: 3, seconds: 45),
      location: "Noma'lum / Soxtalashtirilgan",
      carrier: 'VoIP Xizmati',
      callType: 'Kiruvchi',
      reportedCount: 45,
      riskScore: 78.0,
      riskLevel: 'suspicious',
      confidence: 0.85,
      flaggedReasons: [
        "Texnik yordam o'rniga o'tish",
        "Masofaviy kirish so'rovi",
        "Shoshilinch kompyuter muammosi da'vosi",
      ],
      aiAnalysis: AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.82,
          findings: [
            "Da'vo qilingan kompaniya bilan mos kelmaydigan aksent",
            "G'ayrioddiy nutq naqshlari",
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.88,
          findings: [
            "Texnik yordam o'rniga o'tish tili",
            "Masofaviy kirish so'rovi",
            "Shoshilinch kompyuter muammolari da'vosi",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.80,
          patterns: [
            'Darhol harakat qilishga bosim',
            "To'lov ma'lumotlarini so'raydi",
          ],
        ),
      ),
      timelineEvents: [
        TimelineEvent(
          event: "Qo'ng'iroq boshlandi",
          timestamp: const Duration(seconds: 0),
          type: EventType.info,
        ),
        TimelineEvent(
          event: "Qo'ng'iroqchi Microsoft ekanligini da'vo qiladi",
          timestamp: const Duration(seconds: 8),
          type: EventType.warning,
        ),
        TimelineEvent(
          event: "Masofaviy kirish so'rovi aniqlandi",
          timestamp: const Duration(seconds: 45),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "To'lov so'rovi aniqlandi",
          timestamp: const Duration(seconds: 120),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "Qo'ng'iroq tugadi",
          timestamp: const Duration(seconds: 225),
          type: EventType.warning,
        ),
      ],
      transcription:
          'Salom, bu Microsoft Texnik Yordami. Biz kompyuteringizda jiddiy virus aniqladik. Uni darhol tuzatish uchun bizga masofaviy kirish kerak. Bu \$299.99 turadi.',
      keywordMatches: [
        KeywordMatch(
          keyword: 'Microsoft',
          category: 'tech_support_scam',
          weight: 0.85,
        ),
        KeywordMatch(
          keyword: 'masofaviy kirish',
          category: 'suspicious_request',
          weight: 0.90,
        ),
        KeywordMatch(
          keyword: 'virus',
          category: 'urgency_tactic',
          weight: 0.75,
        ),
      ],
      voiceFeatures: const VoiceFeatures(
        speakingRate: 165.0,
        pitchMean: 220.0,
        stressLevel: 70.0,
      ),
      warningMessage: "Shubhali texnik yordam qo'ng'irog'i aniqlandi",
      shouldWarnUser: true,
    );
  }

  /// Lotereya/O'yin-kulgi firibgarligi - O'rtacha xavf
  static ThreatDetailsModel get lotteryScam {
    final detection = Detection(
      number: '+998934478229',
      score: 65.0,
      reason: "To'lov so'rovi bilan lotereya firibgarligi",
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      reported: false,
    );

    return ThreatDetailsModel.fromDetection(
      detection,
      callerName: 'Mukofot bildirishnomasi',
      callDuration: const Duration(minutes: 2, seconds: 15),
      location: "Noma'lum / Soxtalashtirilgan",
      carrier: 'VoIP Xizmati',
      callType: 'Kiruvchi',
      reportedCount: 23,
      riskScore: 65.0,
      riskLevel: 'suspicious',
      confidence: 0.72,
      flaggedReasons: [
        "Lotereya/o'yin-kulgi da'vosi",
        "Mukofotni olish uchun to'lov talab qilinadi",
      ],
      aiAnalysis: AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.68,
          findings: [
            'Haddan tashqari hayajonlangan ohang',
            'Mos kelmaydigan fon tovushlari',
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.75,
          findings: [
            "So'ralmagan mukofot bildirishnomasi",
            "Olish uchun to'lov so'rovi",
            "Haqiqatdan ham yaxshi bo'lishi mumkin bo'lmagan da'volar",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.70,
          patterns: [
            'Mukofotni olish shoshilinchligi',
            "Shaxsiy ma'lumot so'rovi",
          ],
        ),
      ),
      timelineEvents: [
        TimelineEvent(
          event: "Qo'ng'iroq boshlandi",
          timestamp: const Duration(seconds: 0),
          type: EventType.info,
        ),
        TimelineEvent(
          event: "Mukofot da'vosi eslatib o'tildi",
          timestamp: const Duration(seconds: 10),
          type: EventType.warning,
        ),
        TimelineEvent(
          event: "To'lov so'rovi aniqlandi",
          timestamp: const Duration(seconds: 60),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "Qo'ng'iroq tugadi",
          timestamp: const Duration(seconds: 135),
          type: EventType.warning,
        ),
      ],
      transcription:
          "Tabriklaymiz! Siz bizning o'yin-kulgimizda \$1,000,000 yutdingiz! Mukofotingizni olish uchun, iltimos, qayta ishlash to'lovi uchun \$500 ni sim orqali o'tkazing.",
      keywordMatches: [
        KeywordMatch(
          keyword: 'yutdi',
          category: 'lottery_scam',
          weight: 0.70,
        ),
        KeywordMatch(
          keyword: "qayta ishlash to'lovi",
          category: 'payment_request',
          weight: 0.85,
        ),
      ],
      voiceFeatures: const VoiceFeatures(
        speakingRate: 190.0,
        pitchMean: 280.0,
        stressLevel: 60.0,
      ),
      warningMessage: "Shubhali lotereya/o'yin-kulgi qo'ng'irog'i",
      shouldWarnUser: true,
    );
  }

  /// Bank hisobi firibgarligi - Yuqori xavf
  static ThreatDetailsModel get bankAccountScam {
    final detection = Detection(
      number: '+998882253202',
      score: 88.0,
      reason: "Hisobni tasdiqlash so'rovi bilan bank o'rniga o'tish",
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      reported: false,
    );

    return ThreatDetailsModel.fromDetection(
      detection,
      callerName: 'Bank Xavfsizligi',
      callDuration: const Duration(minutes: 4, seconds: 30),
      location: "Noma'lum / Soxtalashtirilgan",
      carrier: 'VoIP Xizmati',
      callType: 'Kiruvchi',
      reportedCount: 89,
      riskScore: 88.0,
      riskLevel: 'danger',
      confidence: 0.91,
      flaggedReasons: [
        "Bank o'rniga o'tish",
        "Hisobni tasdiqlash so'rovi",
        "Shubhali faollik da'vosi",
      ],
      aiAnalysis: AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.89,
          findings: [
            'Avtomatlashtirilgan ovoz tizimi',
            'Robot nutq naqshlari',
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.93,
          findings: [
            "Bank o'rniga o'tish tili",
            'Hisob raqami so\'rovi',
            "Shubhali faollik da'vosi",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.87,
          patterns: [
            'Shoshilinch xavfsizlik ogohlantirishi',
            "Sezgir ma'lumot so'rovi",
            'Hisobni yopish bilan tahdid',
          ],
        ),
      ),
      timelineEvents: [
        TimelineEvent(
          event: "Qo'ng'iroq boshlandi",
          timestamp: const Duration(seconds: 0),
          type: EventType.info,
        ),
        TimelineEvent(
          event: 'Avtomatlashtirilgan tizim aniqlandi',
          timestamp: const Duration(seconds: 3),
          type: EventType.warning,
        ),
        TimelineEvent(
          event: "Bank o'rniga o'tish aniqlandi",
          timestamp: const Duration(seconds: 15),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "Hisobni tasdiqlash so'rovi",
          timestamp: const Duration(seconds: 45),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: 'Firibgarlik tasdiqlandi',
          timestamp: const Duration(seconds: 120),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "Qo'ng'iroq tugadi",
          timestamp: const Duration(seconds: 270),
          type: EventType.danger,
        ),
      ],
      transcription:
          'Bu bankingizdan avtomatik xabar. Biz hisobingizda shubhali faollik aniqladik. Iltimos, hisobingizni himoya qilish uchun hisob raqamingizni va marshrut raqamingizni tasdiqlang.',
      keywordMatches: [
        KeywordMatch(
          keyword: 'shubhali faollik',
          category: 'bank_information_request',
          weight: 0.92,
        ),
        KeywordMatch(
          keyword: 'hisob raqami',
          category: 'personal_info_request',
          weight: 0.95,
        ),
        KeywordMatch(
          keyword: 'tasdiqlash',
          category: 'urgent_action_required',
          weight: 0.88,
        ),
      ],
      voiceFeatures: const VoiceFeatures(
        speakingRate: 150.0,
        pitchMean: 200.0,
        stressLevel: 80.0,
      ),
      warningMessage: "Yuqori xavfli firibgarlik: Bank o'rniga o'tish firibgarligi",
      shouldWarnUser: true,
    );
  }

  /// Romantika firibgarligi - O'rtacha xavf
  static ThreatDetailsModel get romanceScam {
    final detection = Detection(
      number: '+998931671449',
      score: 55.0,
      reason: "Moliyaviy so'rov bilan romantika firibgarligi",
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      reported: false,
    );

    return ThreatDetailsModel.fromDetection(
      detection,
      callerName: "Noma'lum qo'ng'iroqchi",
      callDuration: const Duration(minutes: 15, seconds: 30),
      location: "Noma'lum / Soxtalashtirilgan",
      carrier: 'VoIP Xizmati',
      callType: 'Kiruvchi',
      reportedCount: 12,
      riskScore: 55.0,
      riskLevel: 'suspicious',
      confidence: 0.65,
      flaggedReasons: [
        'Romantika firibgarligi naqshi',
        "Moliyaviy yordam so'rovi",
      ],
      aiAnalysis: AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.60,
          findings: [
            'Emotsional manipulyatsiya taktikasi',
            'Mos kelmaydigan hikoya',
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.68,
          findings: [
            'Romantika firibgarligi tili',
            "Pul so'rovi",
            'Shoshilinch moliyaviy ehtiyoj',
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.62,
          patterns: [
            "Tez emotsional aloqani o'rnatadi",
            "Moliyaviy yordam so'raydi",
            'Shaxsan uchrashishdan qochadi',
          ],
        ),
      ),
      timelineEvents: [
        TimelineEvent(
          event: "Qo'ng'iroq boshlandi",
          timestamp: const Duration(seconds: 0),
          type: EventType.info,
        ),
        TimelineEvent(
          event: 'Shaxsiy aloqa urinishi',
          timestamp: const Duration(seconds: 30),
          type: EventType.warning,
        ),
        TimelineEvent(
          event: "Moliyaviy so'rov aniqlandi",
          timestamp: const Duration(seconds: 300),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "Qo'ng'iroq tugadi",
          timestamp: const Duration(seconds: 930),
          type: EventType.warning,
        ),
      ],
      transcription:
          "Men haqiqatan ham sizning yordamingizga muhtojman. Men chet elda qolib ketdim va favqulodda vaziyat uchun pul kerak. Menga \$2,000 ni sim orqali yuborishingiz mumkinmi? Uyga qaytganimdan so'ng darhol qaytaraman.",
      keywordMatches: [
        KeywordMatch(
          keyword: "sim orqali o\'tkazma",
          category: 'payment_request',
          weight: 0.75,
        ),
        KeywordMatch(
          keyword: 'favqulodda vaziyat',
          category: 'urgency_tactic',
          weight: 0.70,
        ),
      ],
      voiceFeatures: const VoiceFeatures(
        speakingRate: 140.0,
        pitchMean: 210.0,
        stressLevel: 55.0,
      ),
      warningMessage: 'Shubhali romantika firibgarligi naqshi aniqlandi',
      shouldWarnUser: true,
    );
  }

  /// Xavfsiz qo'ng'iroq - Past xavf
  static ThreatDetailsModel get safeCall {
    final detection = Detection(
      number: '+998901131707',
      score: 15.0,
      reason: "Oddiy qo'ng'iroq naqshi",
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      reported: false,
    );

    return ThreatDetailsModel.fromDetection(
      detection,
      callerName: 'Jon Smith',
      callDuration: const Duration(minutes: 5, seconds: 20),
      location: 'New York, NY',
      carrier: 'Verizon',
      callType: 'Kiruvchi',
      reportedCount: 0,
      riskScore: 15.0,
      riskLevel: 'safe',
      confidence: 0.95,
      flaggedReasons: [],
      aiAnalysis: AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.92,
          findings: [
            'Tabiiy nutq naqshlari',
            'Mos keladigan fon tovushlari',
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.94,
          findings: [
            'Oddiy suhbat',
            "Shubhali kalit so'zlar yo'q",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.90,
          patterns: [
            "Oddiy suhbat oqimi",
            "Bosim taktikasi yo\'q",
          ],
        ),
      ),
      timelineEvents: [
        TimelineEvent(
          event: "Qo'ng'iroq boshlandi",
          timestamp: const Duration(seconds: 0),
          type: EventType.success,
        ),
        TimelineEvent(
          event: "Qo'ng'iroqchi tasdiqlandi",
          timestamp: const Duration(seconds: 2),
          type: EventType.success,
        ),
        TimelineEvent(
          event: 'Oddiy suhbat',
          timestamp: const Duration(seconds: 10),
          type: EventType.success,
        ),
        TimelineEvent(
          event: "Qo'ng'iroq odatdagidek tugadi",
          timestamp: const Duration(seconds: 320),
          type: EventType.success,
        ),
      ],
      transcription: "Salom, bu Jon. Faqat sizni tekshirish va qanday yurganingizni bilish uchun qo'ng'iroq qilyapman.",
      keywordMatches: [],
      voiceFeatures: const VoiceFeatures(
        speakingRate: 150.0,
        pitchMean: 180.0,
        stressLevel: 20.0,
      ),
      warningMessage: '',
      shouldWarnUser: false,
    );
  }

  /// Bank SMS firibgarligi - O'ta Yuqori xavf
  static ThreatDetailsModel get bankingSmsScam {
    final detection = Detection(
      number: '+998909664777',
      score: 94.0,
      reason: "SMS kodini so'rash orqali pul o'g'irlash urinishi",
      timestamp: DateTime.now(),
      reported: false,
    );

    return ThreatDetailsModel.fromDetection(
      detection,
      callDuration: const Duration(minutes: 1, seconds: 45),
      location: "Toshkent, O'zbekiston",
      carrier: 'Uzmobile',
      callType: 'Kiruvchi',
      reportedCount: 210,
      riskScore: 99.0,
      riskLevel: 'danger',
      confidence: 0.99,
      flaggedReasons: [
        "Bank xodimi o'rniga o'tish",
        "SMS kodini so'rash",
        "Ruxsatsiz kirish haqida yolg'on xabar",
      ],
      aiAnalysis: AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.97,
          findings: [
            'Professional, lekin shoshilinch ohang',
            'Call-markaz shovqini (yozib olingan bo\'lishi mumkin)',
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.99,
          findings: [
            "SMS kodni talab qilish",
            "Hisobni bloklash bilan tahdid",
            "Shaxsiy ma'lumotlarni tasdiqlash so'rovi",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.98,
          patterns: [
            'Zudlik bilan harakat qilishga undash',
            "O'ylashga vaqt bermaslik",
            'Ishonchga kirishga urinish',
          ],
        ),
      ),
      timelineEvents: [
        TimelineEvent(
          event: "Qo'ng'iroq boshlandi",
          timestamp: const Duration(seconds: 0),
          type: EventType.info,
        ),
        TimelineEvent(
          event: "Bank xodimi sifatida tanishtirish",
          timestamp: const Duration(seconds: 5),
          type: EventType.warning,
        ),
        TimelineEvent(
          event: "Hisobdan pul yechilayotgani haqida xabar",
          timestamp: const Duration(seconds: 15),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "SMS kodni so'rash",
          timestamp: const Duration(seconds: 30),
          type: EventType.danger,
        ),
        TimelineEvent(
          event: "Qo'ng'iroq tugadi",
          timestamp: const Duration(seconds: 105),
          type: EventType.danger,
        ),
      ],
      transcription:
          "Assalomu alaykum. Bu bank xavfsizlik bo'limidan. Hozirgina kartangizdan katta miqdorda pul yechishga urinish bo'ldi. Operatsiyani bekor qilish uchun telefoningizga kelgan 4 xonali SMS kodni ayting. Kodni aytmasangiz, kartangiz bloklanadi.",
      keywordMatches: [
        KeywordMatch(
          keyword: 'SMS kod',
          category: 'security_code_request',
          weight: 0.99,
        ),
        KeywordMatch(
          keyword: 'kartangiz bloklanadi',
          category: 'threat_intimidation',
          weight: 0.95,
        ),
        KeywordMatch(
          keyword: 'pul yechish',
          category: 'financial_threat',
          weight: 0.90,
        ),
      ],
      voiceFeatures: const VoiceFeatures(
        speakingRate: 170.0,
        pitchMean: 230.0,
        stressLevel: 85.0,
      ),
      warningMessage: "DIQQAT: Bank xodimlari HECH QACHON SMS kodingizni so'ramaydi! Bu firibgarlik.",
      shouldWarnUser: true,
    );
  }

  /// Barcha namuna xavflarni olish
  static List<ThreatDetailsModel> get allThreats => [
        irsImpersonationScam,
        bankingSmsScam,
        techSupportScam,
        lotteryScam,
        bankAccountScam,
        romanceScam,
        safeCall,
      ];

  /// Xavf darajasi bo'yicha xavflarni olish
  static List<ThreatDetailsModel> getHighRiskThreats() {
    return allThreats.where((t) => t.riskLevel == 'danger').toList();
  }

  static List<ThreatDetailsModel> getSuspiciousThreats() {
    return allThreats.where((t) => t.riskLevel == 'suspicious').toList();
  }

  static List<ThreatDetailsModel> getSafeCalls() {
    return allThreats.where((t) => t.riskLevel == 'safe').toList();
  }
}

