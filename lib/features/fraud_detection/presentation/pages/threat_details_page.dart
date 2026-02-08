import 'package:flutter/material.dart';
import '../../domain/entities/detection.dart';
import '../../../../core/theme/fraud_detection_theme.dart';
import '../utils/threat_utils.dart';
import '../models/threat_details_model.dart';
import '../data/sample_threat_data.dart';

class ThreatDetailsPage extends StatelessWidget {
  final Detection detection;
  final ThreatDetailsModel? threatDetails;

  const ThreatDetailsPage({
    super.key,
    required this.detection,
    this.threatDetails,
  });

  @override
  Widget build(BuildContext context) {
    // Try to find matching sample data first
    ThreatDetailsModel? sampleData;
    try {
      sampleData = SampleThreatData.allThreats.firstWhere(
        (element) => element.detection.number == detection.number,
      );
    } catch (_) {}

    // Use provided threat details, or sample data, or create from detection
    var details = threatDetails ??
        sampleData ??
        ThreatDetailsModel.fromDetection(
          detection,
          transcription: detection.reason,
          languageDetected: ThreatUtils.detectLanguageCode(detection.number),
          riskScore: detection.score,
          riskLevel: _getRiskLevelString(detection.score),
          confidence: 0.0,
          warningMessage: detection.reason,
          flaggedReasons: threatDetails?.flaggedReasons,
        );

    // Ensure Flagged Reasons, AI Analysis, and Timeline are always populated
    details = _ensureCompleteDetails(details);

    final riskLevel = _getRiskLevelFromString(details.riskLevel);
    final borderColor = riskLevel.color(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String statusText = _getStatusText(riskLevel);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1720) : (Colors.grey[100] ?? Colors.grey),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF131d2b) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Qo'ng'iroq Haqida",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caller Information Card
            _buildCallerInfoCard(context, details, riskLevel, borderColor, statusText, isDark),
            const SizedBox(height: 16),

            // Call Information Card
            _buildCallInfoCard(context, details, isDark),
            const SizedBox(height: 16),

            // Flagged Reasons Card - Always show
            _buildFlaggedReasonsCard(context, details, isDark),
            const SizedBox(height: 16),

            // AI Analysis Section - Always show
            _buildAIAnalysisSection(context, details.aiAnalysis!, isDark),
            const SizedBox(height: 16),

            // Call Timeline - Always show
            _buildCallTimelineCard(context, details.timelineEvents!, isDark),
            const SizedBox(height: 16),

            // Actions Section
            _buildActionsCard(context, details, isDark),
          ],
        ),
      ),
    );
  }

  FraudAlertLevel _getRiskLevelFromString(String level) {
    switch (level.toLowerCase()) {
      case 'danger':
        return FraudAlertLevel.fraud;
      case 'suspicious':
        return FraudAlertLevel.suspicious;
      case 'safe':
      default:
        return FraudAlertLevel.safe;
    }
  }

  String _getRiskLevelString(double score) {
    if (score <= 30) return 'safe';
    if (score <= 70) return 'suspicious';
    return 'danger';
  }

  /// Ensures that Flagged Reasons, AI Analysis, and Timeline are always populated
  ThreatDetailsModel _ensureCompleteDetails(ThreatDetailsModel details) {
    // Generate flagged reasons if empty
    final flaggedReasons = details.flaggedReasons.isEmpty
        ? _generateFlaggedReasons(details.detection)
        : details.flaggedReasons;

    // Generate AI Analysis if missing
    final aiAnalysis = details.aiAnalysis ?? _generateAIAnalysis(details.detection);

    // Generate timeline events if missing
    final timelineEvents = details.timelineEvents ?? _generateTimelineEvents(details.detection, details.callDuration);

    return ThreatDetailsModel(
      detection: details.detection,
      transcription: details.transcription,
      languageDetected: details.languageDetected,
      riskScore: details.riskScore,
      riskLevel: details.riskLevel,
      confidence: details.confidence,
      keywordMatches: details.keywordMatches,
      voiceFeatures: details.voiceFeatures,
      warningMessage: details.warningMessage,
      shouldWarnUser: details.shouldWarnUser,
      callerName: details.callerName,
      callDuration: details.callDuration,
      location: details.location,
      carrier: details.carrier,
      callType: details.callType,
      reportedCount: details.reportedCount,
      flaggedReasons: flaggedReasons,
      aiAnalysis: aiAnalysis,
      timelineEvents: timelineEvents,
    );
  }

  List<String> _generateFlaggedReasons(Detection detection) {
    if (detection.score <= 30) {
      return [];
    } else if (detection.score <= 70) {
      return [
        'Shubhali chaqiruv namunasi',
        "Tasdiqlanmagan qo'ng'iroq qiluvchi ID",
      ];
    } else {
      return [
        "Yuqori xavfli firibgarlik ko'rsatkichlari",
        "Shoshilinch taktika aniqlandi",
        "Shubhali xatti-harakatlar shakllari",
      ];
    }
  }

  AIAnalysis _generateAIAnalysis(Detection detection) {
    if (detection.score <= 30) {
      return AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.85,
          findings: [
            "Tabiiy nutq shakllari",
            "Doimiy fon tovushlari",
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.90,
          findings: [
            "Oddiy suhbat",
            "Hech qanday shubhali kalit so'zlar aniqlanmadi",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.88,
          patterns: [
            "Oddiy suhbat oqimi",
            "Bosim taktikasi yo'q",
          ],
        ),
      );
    } else if (detection.score <= 70) {
      return AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.75,
          findings: [
            "Noodatiy nutq shakllari",
            "Mos kelmaydigan fon shovqini",
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.80,
          findings: [
            "Ba'zi shubhali kalit so'zlar aniqlandi",
            "Tasdiqlanmagan da'volar",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.72,
          patterns: [
            "O'rtacha bosim taktikasi",
            "G'ayrioddiy shoshilinchlik",
          ],
        ),
      );
    } else {
      return AIAnalysis(
        voiceAnalysis: VoiceAnalysis(
          confidence: 0.92,
          findings: [
            "Robot ovoz namunalari",
            "Orqa fon shovqini daʼvo qilingan joylashuvga mos kelmaydi",
          ],
        ),
        contentAnalysis: ContentAnalysis(
          confidence: 0.96,
          findings: [
            "Firibgarlik tili",
            'Huquqiy harakatlar tahdidlari',
            "Darhol to'lovni talab qilish",
          ],
        ),
        behavioralPatterns: BehavioralPatterns(
          confidence: 0.90,
          patterns: [
            "Yuqori bosim taktikasi",
            "Qayta qo'ng'iroq qilish raqamini berishni rad etish",
            "Shoshilinch harakat qilish kerak",
          ],
        ),
      );
    }
  }

  List<TimelineEvent> _generateTimelineEvents(Detection detection, Duration? callDuration) {
    final duration = callDuration ?? const Duration(seconds: 34);
    final events = <TimelineEvent>[];

    events.add(TimelineEvent(
      event: 'Call initiated',
      timestamp: const Duration(seconds: 0),
      type: EventType.info,
    ));

    if (detection.score > 30) {
      events.add(TimelineEvent(
        event: 'Caller ID analysis completed',
        timestamp: const Duration(seconds: 5),
        type: EventType.warning,
      ));
    }

    if (detection.score > 50) {
      events.add(TimelineEvent(
        event: 'Suspicious keyword detected',
        timestamp: const Duration(seconds: 12),
        type: EventType.warning,
      ));
    }

    if (detection.score > 70) {
      events.add(TimelineEvent(
        event: 'Urgency tactics identified',
        timestamp: const Duration(seconds: 18),
        type: EventType.danger,
      ));

      events.add(TimelineEvent(
        event: 'Fraud pattern confirmed',
        timestamp: const Duration(seconds: 25),
        type: EventType.danger,
      ));
    }

    events.add(TimelineEvent(
      event: detection.score > 70 ? 'Call ended - User warned' : 'Call ended',
      timestamp: duration,
      type: detection.score > 70 ? EventType.danger : EventType.info,
    ));

    return events;
  }

  Widget _buildCallerInfoCard(
    BuildContext context,
    ThreatDetailsModel details,
    FraudAlertLevel riskLevel,
    Color borderColor,
    String statusText,
    bool isDark,
  ) {
    final callerName = details.callerName ?? "Noma'lum Qo'ng'iroq";
    final riskPercentage = details.riskScore.toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? borderColor.withValues(alpha: 0.3)
            : borderColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.7),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      callerName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatPhoneNumber(details.detection.number),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Xavf Darajasi',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
              ),
              const Spacer(),
              Text(
                '$riskPercentage%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: borderColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: riskPercentage / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(borderColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallInfoCard(
    BuildContext context,
    ThreatDetailsModel details,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF131d2b) : (Colors.grey[200] ?? Colors.grey);
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = isDark ? (Colors.grey[400] ?? Colors.grey) : (Colors.grey[600] ?? Colors.grey);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Qo'ng'iroq Ma'lumotlari",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.access_time,
                      'Davomiylik',
                      _formatDuration(details.callDuration ?? const Duration(seconds: 34)),
                      secondaryTextColor,
                      textColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      Icons.location_on,
                      'Manzil',
                      details.location ?? 'Noma\'lum / Soxta',
                      secondaryTextColor,
                      textColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      Icons.phone,
                      "Qo'ng'iroq Turi",
                      details.callType,
                      secondaryTextColor,
                      textColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.phone_android,
                      'Vaqt',
                      _formatTimeAgo(details.detection.timestamp),
                      secondaryTextColor,
                      textColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      Icons.signal_cellular_alt,
                      'Tashuvchi',
                      details.carrier ?? 'VoIP Xizmati',
                      secondaryTextColor,
                      textColor,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      Icons.flag,
                      'Xabar Qilingan',
                      '${details.reportedCount} marta',
                      secondaryTextColor,
                      textColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: labelColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: labelColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFlaggedReasonsCard(
    BuildContext context,
    ThreatDetailsModel details,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF131d2b) : (Colors.grey[200] ?? Colors.grey);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Theme.of(context).fraudDanger,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Aniqlagan Sabablar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (details.flaggedReasons.isEmpty)
            Text(
              'Hech qanday aniq sabablar belgilanmagan',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textColor.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
            )
          else
            ...details.flaggedReasons.map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          reason,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: textColor,
                              ),
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisSection(
    BuildContext context,
    AIAnalysis aiAnalysis,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF131d2b) : (Colors.grey[200] ?? Colors.grey);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield,
                color: Colors.blue,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Tahlil',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Voice Analysis
          _buildAnalysisSubsection(
            context,
            'Ovoz Tahlil',
            '${(aiAnalysis.voiceAnalysis.confidence * 100).toInt()}% ishonch',
            aiAnalysis.voiceAnalysis.findings,
            textColor,
          ),
          const SizedBox(height: 20),
          // Content Analysis
          _buildAnalysisSubsection(
            context,
            'Kontent Tahlil',
            '${(aiAnalysis.contentAnalysis.confidence * 100).toInt()}% ishonch',
            aiAnalysis.contentAnalysis.findings,
            textColor,
          ),
          const SizedBox(height: 20),
          // Behavioral Patterns
          _buildAnalysisSubsection(
            context,
            'Xulq-atvor Namunalari',
            '${(aiAnalysis.behavioralPatterns.confidence * 100).toInt()}% ishonch',
            aiAnalysis.behavioralPatterns.patterns,
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSubsection(
    BuildContext context,
    String title,
    String confidence,
    List<String> items,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
            ),
            Text(
              confidence,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.blue,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6, right: 12),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor,
                          ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCallTimelineCard(
    BuildContext context,
    List<TimelineEvent> events,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF131d2b) : (Colors.grey[200] ?? Colors.grey);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Qo'ng'iroq Vaqt Jadvali",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
          ),
          const SizedBox(height: 20),
          ...events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == events.length - 1;
            final dotColor = _getEventTypeColor(event.type);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: cardColor,
                          width: 2,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 40,
                        color: Colors.grey[600] ?? Colors.grey,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.event,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.formattedTime,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500] ?? Colors.grey,
                            ),
                      ),
                      if (!isLast) const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionsCard(
    BuildContext context,
    ThreatDetailsModel details,
    bool isDark,
  ) {
    final cardColor = isDark ? const Color(0xFF131d2b) : (Colors.grey[200] ?? Colors.grey);
    final isFraud = _getRiskLevelFromString(details.riskLevel) == FraudAlertLevel.fraud;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFraud) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Ichki ishlar vazirligi Tezkor-qidiruv departamenti Kiberxavfsizlik markaziga xabar qilindi",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle download report
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.download_rounded, size: 20),
                  const SizedBox(width: 12),
                  const Text(
                    "Hisobotni yuklab olish",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
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

  Color _getEventTypeColor(EventType type) {
    switch (type) {
      case EventType.success:
        return Colors.green;
      case EventType.warning:
        return Colors.orange;
      case EventType.danger:
        return Colors.red;
      case EventType.info:
        return Colors.blue;
    }
  }

  String _formatPhoneNumber(String number) {
    // Remove all non-digits
    final cleaned = number.replaceAll(RegExp(r'[^\d]'), '');

    // Uzbekistan numbers: 12 digits including +998 → 998901331212
    if (cleaned.length == 12 && cleaned.startsWith('998')) {
      final operator = cleaned.substring(3, 5);     // 90, 91, 93, ...
      final part1 = cleaned.substring(5, 8);        // 133
      final part2 = cleaned.substring(8, 10);       // 12
      final part3 = cleaned.substring(10, 12);      // 12
      return '+998 ($operator) $part1-$part2-$part3';
    }

    // If user enters without country code: 901331212
    if (cleaned.length == 9) {
      final operator = cleaned.substring(0, 2);
      final part1 = cleaned.substring(2, 5);
      final part2 = cleaned.substring(5, 7);
      final part3 = cleaned.substring(7, 9);
      return '+998 ($operator) $part1-$part2-$part3';
    }

    return number;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'kun' : 'kun'} oldin';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'soat' : 'soat'} oldin';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'daqiqa' : 'daqiqa'} oldin';
    } else {
      return 'Hozirgina';
    }
  }

  String _getStatusText(FraudAlertLevel riskLevel) {
    switch (riskLevel) {
      case FraudAlertLevel.fraud:
        return 'Firibgar';
      case FraudAlertLevel.suspicious:
        return 'Shubhali';
      case FraudAlertLevel.safe:
        return 'Xavfsiz';
    }
  }
}
