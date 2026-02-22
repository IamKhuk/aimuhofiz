import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class CallHistoryService {
  static const String _baseUrl = ApiConfig.baseUrl;
  static const String _retryQueueKey = 'pending_api_saves';
  static bool _isFlushingQueue = false;

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Save a call record to the API. Returns null on success, or error message.
  /// On failure, the record is queued for retry.
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
    final payload = {
      'risk_score': riskScore,
      'risk_level': riskLevel,
      'warning_message': warningMessage,
      'keywords_found_count': keywordsFoundCount,
      'language': language,
      'duration_seconds': durationSeconds,
      'analysis_type': analysisType,
      if (clientId != null) 'client_id': clientId,
    };

    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/history'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success — also try to flush any previously queued records
        _flushRetryQueue();
        return null;
      }

      final body = jsonDecode(response.body);
      return body['detail']?.toString() ??
          body['message']?.toString() ??
          'Saqlashda xatolik (${response.statusCode})';
    } catch (e) {
      // Network error — queue for retry
      await _enqueueForRetry(payload);
      return "Serverga ulanib bo'lmadi: $e";
    }
  }

  /// Queue a failed payload for later retry
  static Future<void> _enqueueForRetry(Map<String, dynamic> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList(_retryQueueKey) ?? [];
      queue.add(jsonEncode(payload));
      // Cap the queue to prevent unbounded growth
      if (queue.length > 50) {
        queue.removeRange(0, queue.length - 50);
      }
      await prefs.setStringList(_retryQueueKey, queue);
      debugPrint('CallHistoryService: Queued record for retry (${queue.length} pending)');
    } catch (e) {
      debugPrint('CallHistoryService: Failed to enqueue for retry: $e');
    }
  }

  /// Flush queued records to the API. Called on successful saves and on app init.
  static Future<void> _flushRetryQueue() async {
    if (_isFlushingQueue) return;
    _isFlushingQueue = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList(_retryQueueKey) ?? [];
      if (queue.isEmpty) return;

      debugPrint('CallHistoryService: Flushing ${queue.length} queued records...');
      final remaining = <String>[];

      for (final item in queue) {
        try {
          final headers = await _authHeaders();
          final response = await http.post(
            Uri.parse('$_baseUrl/api/v1/history'),
            headers: headers,
            body: item,
          );
          if (response.statusCode != 200 && response.statusCode != 201) {
            remaining.add(item);
          }
        } catch (_) {
          remaining.add(item);
          // Stop flushing on network error — no point retrying the rest
          remaining.addAll(queue.sublist(queue.indexOf(item) + 1));
          break;
        }
      }

      await prefs.setStringList(_retryQueueKey, remaining);
      debugPrint('CallHistoryService: Flush done, ${remaining.length} still pending');
    } catch (e) {
      debugPrint('CallHistoryService: Error flushing retry queue: $e');
    } finally {
      _isFlushingQueue = false;
    }
  }

  /// Try to flush any pending saves. Call this on app startup.
  static Future<void> retryPendingSaves() async {
    await _flushRetryQueue();
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
