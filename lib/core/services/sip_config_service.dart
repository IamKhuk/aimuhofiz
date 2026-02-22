import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/sip_config.dart';
import 'auth_service.dart';

/// Fetches and caches SIP configuration from the backend API.
class SipConfigService {
  static const String _baseUrl = 'https://abulqosim0227.jprq.live';
  static const String _cachedConfigKey = 'cached_sip_config';

  /// Fetch SIP config from the server, falling back to cached config.
  static Future<SipConfig?> fetchConfig() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        debugPrint('SipConfigService: No auth token, cannot fetch config');
        return _getCachedConfig();
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/v1/sip/config'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final config = SipConfig.fromJson(json);
        await _cacheConfig(config);
        return config;
      }

      // If 401, try to refresh token and retry
      if (response.statusCode == 401) {
        final refreshed = await AuthService.refreshToken();
        if (refreshed) {
          return fetchConfig();
        }
      }

      debugPrint(
          'SipConfigService: Server returned ${response.statusCode}, falling back to cache');
      return _getCachedConfig();
    } catch (e) {
      debugPrint(
          'SipConfigService: Failed to fetch config: $e, falling back to cache');
      return _getCachedConfig();
    }
  }

  /// Provision SIP credentials for a newly registered user.
  static Future<bool> provisionSipAccount() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/sip/provision'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('SipConfigService: Failed to provision SIP account: $e');
      return false;
    }
  }

  static Future<void> _cacheConfig(SipConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedConfigKey, jsonEncode(config.toJson()));
  }

  static Future<SipConfig?> _getCachedConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cachedConfigKey);
    if (cached != null) {
      try {
        return SipConfig.fromJson(jsonDecode(cached) as Map<String, dynamic>);
      } catch (_) {}
    }
    return null;
  }

  /// Clear cached SIP config (e.g., on logout).
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cachedConfigKey);
  }
}
