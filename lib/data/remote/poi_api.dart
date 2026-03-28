import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:ans_mobile/core/services/locale_provider.dart';
import 'api_client.dart';
import 'http_client.dart';

class PoiApi {
  PoiApi._private();
  static final PoiApi instance = PoiApi._private();

  static const _timeout = Duration(seconds: 60);

  Uri _uri(String path) => Uri.parse('${ApiClient.instance.baseUrl}$path');

  Future<http.Response> _getReq(
    String path, {
    Map<String, String>? headers,
  }) async {
    final defaultLocale =
        LocaleProvider.instance.locale?.languageCode ??
        (PlatformDispatcher.instance.locale.languageCode);
    final mergedHeaders = {
      'Accept-Language': defaultLocale,
      if (headers != null) ...headers,
    };
    // Use HttpClientWithTokenRefresh for auto-refresh on 401
    return await HttpClientWithTokenRefresh.instance.get(
      _uri(path),
      headers: mergedHeaders,
      timeout: _timeout,
    );
  }

  Future<List<Map<String, dynamic>>> listStalls(
    String accessToken, {
    String? search,
    double? latitude,
    double? longitude,
    int limit = 20,
    int offset = 0,
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (latitude != null && longitude != null) {
      queryParams['latitude'] = latitude.toString();
      queryParams['longitude'] = longitude.toString();
    }

    final path = '/mobile/stalls/';
    final uri = _uri(path).replace(queryParameters: queryParams);

    final res = await HttpClientWithTokenRefresh.instance.get(
      uri,
      headers: {
        'Accept-Language':
            LocaleProvider.instance.locale?.languageCode ??
            (PlatformDispatcher.instance.locale.languageCode),
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
      timeout: _timeout,
    );

    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['data'] is List) {
        return List<Map<String, dynamic>>.from(body['data'] as List);
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      throw Exception('Invalid response from server during listStalls');
    }
  }

  Future<List<Map<String, dynamic>>> getStallContents(
    String stallId,
    String accessToken,
  ) async {
    final res = await _getReq(
      '/mobile/stall-contents/$stallId',
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['data'] is List) {
        return List<Map<String, dynamic>>.from(body['data'] as List);
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      throw Exception('Invalid response from server during getStallContents');
    }
  }

  Future<Map<String, dynamic>?> getStall(
    String stallId,
    String accessToken,
  ) async {
    final res = await _getReq(
      '/mobile/stalls/$stallId',
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      },
    );
    if (res.statusCode == 404) {
      return null;
    }
    if (res.statusCode >= 400) {
      throw Exception(_parseError(res));
    }
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['data'] != null) {
        return body['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      throw Exception('Invalid response from server during getStall');
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
      if (body is Map && body['detail'] != null)
        return _fixMojibake(body['detail'].toString());
      return 'HTTP ${res.statusCode}: ${_fixMojibake(raw)}';
    } catch (_) {
      return 'HTTP ${res.statusCode}';
    }
  }
}
