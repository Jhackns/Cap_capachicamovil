import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class MunicipalidadService {
  final AuthService _authService = AuthService();

  Future<List<Map<String, dynamic>>> getMunicipalidades() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getMunicipalidadesUrl()),
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
          throw Exception(data['message'] ?? 'Error al cargar municipalidades');
        }
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al obtener municipalidades: $e');
    }
  }
} 