import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  // Obtener estadísticas del dashboard
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final headers = await _authService.getAuthHeader();
      
      final response = await http.get(
        Uri.parse(ApiConfig.getDashboardSummaryUrl()),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Error al obtener estadísticas');
        }
      } else {
        throw Exception('Error al obtener estadísticas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getDashboardStats: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener usuarios recientes (usando la ruta de usuarios del backend)
  Future<List<Map<String, dynamic>>> getRecentUsers() async {
    try {
      final headers = await _authService.getAuthHeader();
      
      final response = await http.get(
        Uri.parse('${ApiConfig.getUsersUrl()}?per_page=5'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener usuarios recientes');
        }
      } else {
        throw Exception('Error al obtener usuarios recientes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getRecentUsers: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  // Obtener estadísticas por rol (usando la ruta de roles del backend)
  Future<List<Map<String, dynamic>>> getUsersByRole() async {
    try {
      final headers = await _authService.getAuthHeader();
      
      final response = await http.get(
        Uri.parse('${ApiConfig.getRolesUrl()}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Transformar los datos de roles para el formato esperado
          final roles = List<Map<String, dynamic>>.from(data['data'] ?? []);
          return roles.map((role) => {
            'role': role['name'],
            'count': role['users_count'] ?? 0,
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Error al obtener estadísticas por rol');
        }
      } else {
        throw Exception('Error al obtener estadísticas por rol: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getUsersByRole: $e');
      throw Exception('Error de conexión: $e');
    }
  }
} 