import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Result of server-side audio analysis.
class ServerAnalysisResult {
  final double riskScore;
  final String riskLevel;
  final String warningMessage;
  final List<String> flaggedReasons;
  final Map<String, dynamic>? aiAnalysis;
  final List<Map<String, dynamic>>? timelineEvents;
  final String? transcription;
  final Map<String, dynamic> raw;

  const ServerAnalysisResult({
    required this.riskScore,
    required this.riskLevel,
    required this.warningMessage,
    required this.flaggedReasons,
    this.aiAnalysis,
    this.timelineEvents,
    this.transcription,
    required this.raw,
  });

  factory ServerAnalysisResult.fromJson(Map<String, dynamic> json) {
    return ServerAnalysisResult(
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] as String? ?? 'SAFE',
      warningMessage: json['warning_message'] as String? ?? '',
      flaggedReasons: (json['flagged_reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      aiAnalysis: json['ai_analysis'] as Map<String, dynamic>?,
      timelineEvents: (json['timeline_events'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList(),
      transcription: json['transcription'] as String?,
      raw: json,
    );
  }

  String toJsonString() => jsonEncode(raw);
}

/// Service for uploading audio files to the server for advanced analysis.
class AudioAnalysisService {
  static const String _baseUrl = ApiConfig.baseUrl;

  /// Upload an audio file for server-side analysis.
  /// Returns [ServerAnalysisResult] on success, or error string on failure.
  static Future<Object> analyzeAudio(String audioFilePath, {String language = 'uz'}) async {
    try {
      final file = File(audioFilePath);
      if (!await file.exists()) {
        return 'Audio fayl topilmadi';
      }

      final token = await AuthService.getAccessToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/v1/analyze/file'),
      );

      request.headers['X-API-Key'] = ApiConfig.apiKey;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.files.add(
        await http.MultipartFile.fromPath('file', audioFilePath),
      );
      request.fields['language'] = language;

      final streamedResponse = await request.send().timeout(
        const Duration(minutes: 5),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final result = ServerAnalysisResult.fromJson(body);
        debugPrint('AudioAnalysisService: Analysis complete — risk: ${result.riskLevel}');
        return result;
      }

      final body = jsonDecode(response.body);
      final errorMsg = body['detail']?.toString() ??
          body['message']?.toString() ??
          'Server tahlilida xatolik (${response.statusCode})';
      debugPrint('AudioAnalysisService: Server error — $errorMsg');
      return errorMsg;
    } catch (e) {
      debugPrint('AudioAnalysisService: Failed to analyze audio: $e');
      return "Server tahlilida xatolik: $e";
    }
  }
}
