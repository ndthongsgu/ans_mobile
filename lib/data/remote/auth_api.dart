import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:ans_mobile/core/services/locale_provider.dart';
import 'api_client.dart';

class AuthApi {
  AuthApi._private();
  static final AuthApi instance = AuthApi._private();

  static const _timeout = Duration(seconds: 10);

  Uri _uri(String path) => Uri.parse('${ApiClient.instance.baseUrl}$path');

  Future<http.Response> _postReq(String path, {Map<String, String>? headers, Object? body}) async {
    // Prefer user-selected locale, otherwise fall back to device locale and finally 'en'
    final defaultLocale = LocaleProvider.instance.locale?.languageCode ?? (PlatformDispatcher.instance.locale.languageCode) ?? 'en';
    final mergedHeaders = {
      'Accept-Language': defaultLocale,
      if (headers != null) ...headers,
    };
    try {
      final res = await http.post(_uri(path), headers: mergedHeaders, body: body).timeout(_timeout);
      return res;
    } on TimeoutException {
      throw Exception('Request timed out. Please check network or server.');
    }
  }

  Future<http.Response> _getReq(String path, {Map<String, String>? headers}) async {
    final defaultLocale = LocaleProvider.instance.locale?.languageCode ?? (PlatformDispatcher.instance.locale.languageCode) ?? 'en';
    final mergedHeaders = {
      'Accept-Language': defaultLocale,
      if (headers != null) ...headers,
    };
    try {
      final res = await http.get(_uri(path), headers: mergedHeaders).timeout(_timeout);
      return res;
    } on TimeoutException {
      throw Exception('Request timed out. Please check network or server.');
    }
  }

  Future<Map<String, dynamic>> login({required String email, required String password}) async {
    final res = await _postReq(
      '/customer/auth/login',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (e) {
      throw Exception('Invalid response from server during login');
    }
  }

  Future<Map<String, dynamic>> register({String? username, required String email, required String password, required String full_name}) async {
    final payload = <String, dynamic>{'username': username, 'email': email, 'password': password, 'full_name': full_name};
    final res = await _postReq(
      '/customer/auth/register',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (e) {
      // The register endpoint now returns a simple message (not tokens). Normalize to a map.
      return {'message': 'OTP sent to email'};
    }
  }

  Future<Map<String, dynamic>> verify({required String email, required String otp}) async {
    final res = await _postReq(
      '/customer/auth/verify',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (e) {
      throw Exception('Invalid response from server during verify');
    }
  }

  Future<Map<String, dynamic>> me(String accessToken) async {
    final res = await _getReq(
      '/customer/auth/me',
      headers: {'Authorization': 'Bearer $accessToken', 'Accept': 'application/json'},
    );
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (e) {
      throw Exception('Invalid response from server during me');
    }
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final res = await _postReq(
      '/customer/auth/refresh',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (e) {
      throw Exception('Invalid response from server during refresh');
    }
  }

  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    final res = await _postReq(
      '/customer/auth/forgot-password',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (e) {
      // endpoint returns message; normalize
      return {'message': 'Password reset email sent'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({required String email, required String otp, required String newPassword}) async {
    final res = await _postReq(
      '/customer/auth/reset-password',
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp, 'new_password': newPassword}),
    );
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(res.body) as Map);
    } catch (e) {
      return {'message': 'Password reset successful'};
    }
  }

  String _parseError(http.Response res) {
    String raw;
    try {
      raw = utf8.decode(res.bodyBytes);
    } catch (_) {
      try {
        raw = latin1.decode(res.bodyBytes);
      } catch (_) {
        raw = res.body;
      }
    }

    String _fixMojibake(String s) {
      if (s.contains('Ã') || s.contains('Â') || s.contains('\uFFFD')) {
        try {
          final bytes = latin1.encode(s);
          return utf8.decode(bytes);
        } catch (_) {
          return s;
        }
      }
      return s;
    }

    try {
      final body = jsonDecode(raw);
      if (body is Map && body['detail'] != null) return _fixMojibake(body['detail'].toString());
      return 'HTTP ${res.statusCode}: ${_fixMojibake(raw)}';
    } catch (_) {
      return 'HTTP ${res.statusCode}';
    }
  }
}
