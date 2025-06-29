import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';
import '../config/api_config.dart';

class ApiService {
  final AuthService _authService = AuthService();
  
  // Obtener cabeceras con autenticación
  Future<Map<String, String>> getAuthHeaders() async {
    return await _authService.getAuthHeader();
  }
  
  // Petición GET
  Future<dynamic> get(String url, {bool requiresAuth = false}) async {
    try {
      final headers = requiresAuth ? await getAuthHeaders() : {'Content-Type': 'application/json'};
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      // Si recibimos Forbidden (403) y no estábamos usando autenticación, intentamos con token
      if (response.statusCode == 403 && !requiresAuth) {
        return await get(url, requiresAuth: true);
      }
      
      return _processResponse(response);
    } catch (e) {
      print('Error en GET $url: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Petición POST
  Future<dynamic> post(String url, dynamic body, {bool requiresAuth = true}) async {
    try {
      final headers = requiresAuth ? await getAuthHeaders() : {'Content-Type': 'application/json'};
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      
      return _processResponse(response);
    } catch (e) {
      print('Error en POST $url: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Petición PUT
  Future<dynamic> put(String url, dynamic body, {bool requiresAuth = true}) async {
    try {
      final headers = requiresAuth ? await getAuthHeaders() : {'Content-Type': 'application/json'};
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );
      
      return _processResponse(response);
    } catch (e) {
      print('Error en PUT $url: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Petición DELETE
  Future<dynamic> delete(String url, {bool requiresAuth = true}) async {
    try {
      final headers = requiresAuth ? await getAuthHeaders() : {'Content-Type': 'application/json'};
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );
      
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Error al eliminar: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en DELETE $url: $e');
      throw Exception('Error de conexión: $e');
    }
  }
  
  // Procesar respuesta HTTP
  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      final error = response.body.isNotEmpty ? json.decode(response.body) : null;
      final message = error != null && error['message'] != null 
          ? error['message'] 
          : 'Error en la petición: ${response.statusCode}';
      
      throw Exception(message);
    }
  }
}