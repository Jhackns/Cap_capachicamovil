import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class ServicioService {
  final AuthService _authService = AuthService();

  Future<List<Map<String, dynamic>>> getServicios() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.get(
      Uri.parse(ApiConfig.getServiciosUrl()),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        if (data['data'] is Map && data['data'].containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']['data']);
        }
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Error al cargar servicios');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getEmprendedores() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.get(
      Uri.parse(ApiConfig.getEntrepreneursUrl()),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        if (data['data'] is Map && data['data'].containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']['data']);
        }
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Error al cargar emprendedores');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getCategorias() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.get(
      Uri.parse(ApiConfig.getCategoriasUrl()),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        if (data['data'] is Map && data['data'].containsKey('data')) {
          return List<Map<String, dynamic>>.from(data['data']['data']);
        }
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Error al cargar categorías');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }
} 