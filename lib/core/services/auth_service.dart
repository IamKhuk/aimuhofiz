import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'sip_config_service.dart';
import 'sip_service.dart';

class AuthService {
  static const String _baseUrl = 'https://abulqosim0227.jprq.live';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _usernameKey = 'auth_username';

  /// Register a new user. Returns null on success, or an error message.
  static Future<String?> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        await _saveTokens(
          body['access_token'] as String,
          body['refresh_token'] as String,
          username,
        );

        // Provision SIP account for new user
        SipConfigService.provisionSipAccount().then((success) {
          debugPrint('SIP provisioning: ${success ? "success" : "failed"}');
        });

        return null;
      }

      return body['detail']?.toString() ??
          body['message']?.toString() ??
          "Ro'yxatdan o'tishda xatolik (${response.statusCode})";
    } catch (e) {
      return "Serverga ulanib bo'lmadi: $e";
    }
  }

  /// Login. Returns null on success, or an error message.
  static Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveTokens(
          body['access_token'] as String,
          body['refresh_token'] as String,
          username,
        );
        return null;
      }

      return body['detail']?.toString() ??
          body['message']?.toString() ??
          'Login xatolik (${response.statusCode})';
    } catch (e) {
      return "Serverga ulanib bo'lmadi: $e";
    }
  }

  /// Refresh the access token using the stored refresh token.
  static Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/user/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        await prefs.setString(_accessTokenKey, body['access_token'] as String);
        await prefs.setString(_refreshTokenKey, body['refresh_token'] as String);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Get the stored access token.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Check if the user is logged in (has a stored access token).
  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Get stored username.
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  /// Log out — clear all stored tokens and SIP config.
  static Future<void> logout() async {
    // Unregister SIP before clearing credentials
    try {
      final SipService sipService = SipService();
      sipService.unregister();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_usernameKey);
    await SipConfigService.clearCache();
  }

  static Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
    String username,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_usernameKey, username);
  }
}
