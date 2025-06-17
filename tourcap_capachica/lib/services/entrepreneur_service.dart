import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/entrepreneur.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class EntrepreneurService {
  final AuthService _authService = AuthService();

  Future<List<Entrepreneur>> getAllEntrepreneurs() async {
    try {
      // Intentar primero sin token (endpoint público)
      final response = await http.get(
        Uri.parse(ApiConfig.getEntrepreneursUrl()),
        headers: {'Content-Type': 'application/json'},
      );

      // Si recibimos Forbidden (403), intentamos con token
      if (response.statusCode == 403) {
        final token = await _authService.getToken();
        if (token != null) {
          final authResponse = await http.get(
            Uri.parse(ApiConfig.getEntrepreneursUrl()),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token'
            },
          );
          
          if (authResponse.statusCode == 200) {
            final List<dynamic> data = json.decode(authResponse.body);
            return data.map((json) => Entrepreneur.fromJson(json)).toList();
          } else {
            throw Exception('Error al cargar emprendedores con autenticación: ${authResponse.statusCode}');
          }
        }
      } else if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Entrepreneur.fromJson(json)).toList();
      }
      
      throw Exception('Error al cargar emprendedores: ${response.statusCode}');
    } catch (e) {
      print('Error en getAllEntrepreneurs: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Entrepreneur?> getEntrepreneurById(int id) async {
    try {
      final headers = await _authService.getAuthHeader();
      final response = await http.get(
        Uri.parse(ApiConfig.getEntrepreneurByIdUrl(id)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Entrepreneur.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Error al obtener emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getEntrepreneurById: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Entrepreneur> createEntrepreneur(Entrepreneur entrepreneur) async {
    try {
      final headers = await _authService.getAuthHeader();
      final response = await http.post(
        Uri.parse(ApiConfig.getEntrepreneursUrl()),
        headers: headers,
        body: json.encode(entrepreneur.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Entrepreneur.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en createEntrepreneur: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Entrepreneur> updateEntrepreneur(Entrepreneur entrepreneur) async {
    try {
      final headers = await _authService.getAuthHeader();
      final response = await http.put(
        Uri.parse(ApiConfig.getEntrepreneurByIdUrl(entrepreneur.id)),
        headers: headers,
        body: json.encode(entrepreneur.toJson()),
      );

      if (response.statusCode == 200) {
        return Entrepreneur.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al actualizar emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en updateEntrepreneur: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteEntrepreneur(int id) async {
    try {
      final headers = await _authService.getAuthHeader();
      final response = await http.delete(
        Uri.parse(ApiConfig.getEntrepreneurByIdUrl(id)),
        headers: headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Error al eliminar emprendedor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en deleteEntrepreneur: $e');
      throw Exception('Error de conexión: $e');
    }
  }
}
