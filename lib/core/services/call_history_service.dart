import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CallHistoryService {
  static const String _baseUrl = 'https://abulqosim0227.jprq.live';

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Save a call record to the API. Returns null on success, or error message.
  static Future<String?> saveCallRecord({
    required double riskScore,
    required String riskLevel,
    required String warningMessage,
    required int keywordsFoundCount,
    String language = 'uz',
    int durationSeconds = 0,
    String analysisType = 'realtime',
    String? clientId,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/history'),
        headers: headers,
        body: jsonEncode({
          'risk_score': riskScore,
          'risk_level': riskLevel,
          'warning_message': warningMessage,
          'keywords_found_count': keywordsFoundCount,
          'language': language,
          'duration_seconds': durationSeconds,
          'analysis_type': analysisType,
          if (clientId != null) 'client_id': clientId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }

      final body = jsonDecode(response.body);
      return body['detail']?.toString() ??
          body['message']?.toString() ??
          'Saqlashda xatolik (${response.statusCode})';
    } catch (e) {
      return "Serverga ulanib bo'lmadi: $e";
    }
  }

  /// Get paginated call history. Returns map with 'items' and 'total', or error string.
  static Future<Object> getCallHistory({int page = 1, int pageSize = 20}) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/history?page=$page&page_size=$pageSize'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body as Map<String, dynamic>;
      }

      final body = jsonDecode(response.body);
      return body['detail']?.toString() ??
          body['message']?.toString() ??
          'Tarixni yuklashda xatolik (${response.statusCode})';
    } catch (e) {
      return "Serverga ulanib bo'lmadi: $e";
    }
  }

  /// Delete a single record. Returns null on success, or error message.
  static Future<String?> deleteRecord(String recordId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/history/$recordId'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      }

      final body = jsonDecode(response.body);
      return body['detail']?.toString() ??
          body['message']?.toString() ??
          "O'chirishda xatolik (${response.statusCode})";
    } catch (e) {
      return "Serverga ulanib bo'lmadi: $e";
    }
  }

  /// Delete all history. Returns null on success, or error message.
  static Future<String?> deleteAllHistory() async {
    try {
      final headers = await _authHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/v1/history'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return null;
      }

      final body = jsonDecode(response.body);
      return body['detail']?.toString() ??
          body['message']?.toString() ??
          "Barchasini o'chirishda xatolik (${response.statusCode})";
    } catch (e) {
      return "Serverga ulanib bo'lmadi: $e";
    }
  }
}
