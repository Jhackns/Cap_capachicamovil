import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpHelper {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';

  // Get the JWT token from secure storage
  static Future<String?> _getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Add authorization header if token exists
  static Future<Map<String, String>> _getHeaders({
    bool requiresAuth = false,
    Map<String, String>? additionalHeaders,
  }) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      ...?additionalHeaders,
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // GET request
  static Future<dynamic> get(
    String url, {
    bool requiresAuth = false,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // POST request
  static Future<dynamic> post(
    String url, {
    required dynamic body,
    bool requiresAuth = false,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  static Future<dynamic> put(
    String url, {
    required dynamic body,
    bool requiresAuth = false,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // DELETE request
  static Future<dynamic> delete(
    String url, {
    bool requiresAuth = false,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      final headers = await _getHeaders(
        requiresAuth: requiresAuth,
        additionalHeaders: additionalHeaders,
      );

      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle HTTP response
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Please login again');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden: You do not have permission to access this resource');
    } else if (response.statusCode == 404) {
      throw Exception('Not found: The requested resource was not found');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
