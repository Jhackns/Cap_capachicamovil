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

  Future<Map<String, dynamic>> getServicioById(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.get(
      Uri.parse('${ApiConfig.getServiciosUrl()}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Error al cargar servicio');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createServicio(Map<String, dynamic> servicioData) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    
    final response = await http.post(
      Uri.parse(ApiConfig.getServiciosUrl()),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(servicioData),
    );
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Error al crear servicio');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateServicio(int id, Map<String, dynamic> servicioData) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    
    final response = await http.put(
      Uri.parse('${ApiConfig.getServiciosUrl()}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(servicioData),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Error al actualizar servicio');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error: ${response.statusCode}');
    }
  }

  Future<bool> deleteServicio(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    
    final response = await http.delete(
      Uri.parse('${ApiConfig.getServiciosUrl()}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] ?? false;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error: ${response.statusCode}');
    }
  }

  Future<bool> toggleEstadoServicio(int id, bool estado) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    
    final response = await http.put(
      Uri.parse('${ApiConfig.getServiciosUrl()}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'estado': estado}),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] ?? false;
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error: ${response.statusCode}');
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