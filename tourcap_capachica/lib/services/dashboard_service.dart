import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../models/municipalidad.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Obtener estadísticas del dashboard
      final response = await http.get(
        Uri.parse(ApiConfig.getDashboardSummaryUrl()),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] ?? {};
        }
      }

      // Si no hay datos del dashboard, obtener datos básicos
      return await _getBasicStats(token);
    } catch (e) {
      print('Error al obtener estadísticas del dashboard: $e');
      return await _getBasicStats(null);
    }
  }

  Future<Map<String, dynamic>> _getBasicStats(String? token) async {
    try {
      if (token == null) {
        return _getDefaultStats();
      }

      // Obtener usuarios
      final usersResponse = await http.get(
        Uri.parse(ApiConfig.getUsersUrl()),
        headers: _getAuthHeaders(token),
      );

      // Obtener roles
      final rolesResponse = await http.get(
        Uri.parse(ApiConfig.getRolesUrl()),
        headers: _getAuthHeaders(token),
      );

      // Obtener permisos
      final permissionsResponse = await http.get(
        Uri.parse(ApiConfig.getPermissionsUrl()),
        headers: _getAuthHeaders(token),
      );

      int totalUsers = 0;
      int activeUsers = 0;
      List<Map<String, dynamic>> recentUsers = [];
      List<Map<String, dynamic>> usersByRole = [];

      if (usersResponse.statusCode == 200) {
        final usersData = json.decode(usersResponse.body);
        if (usersData['success'] == true) {
          final users = usersData['data']['data'] ?? [];
          totalUsers = users.length;
          activeUsers = users.where((user) => user['active'] == true).length;
          
          // Usuarios recientes (últimos 5)
          recentUsers = users.take(5).map((user) => {
            'name': user['name'] ?? 'Usuario',
            'email': user['email'] ?? '',
            'roles': user['roles'] ?? [],
            'active': user['active'] ?? false,
          }).toList();
        }
      }

      int totalRoles = 0;
      if (rolesResponse.statusCode == 200) {
        final rolesData = json.decode(rolesResponse.body);
        if (rolesData['success'] == true) {
          final roles = rolesData['data']['data'] ?? [];
          totalRoles = roles.length;
          
          // Usuarios por rol
          usersByRole = roles.map((role) => {
            'role': role['name'] ?? '',
            'count': role['users_count'] ?? 0,
            'color': _getRoleColor(role['name']),
          }).toList();
        }
      }

      int totalPermissions = 0;
      if (permissionsResponse.statusCode == 200) {
        final permissionsData = json.decode(permissionsResponse.body);
        if (permissionsData['success'] == true) {
          final permissions = permissionsData['data']['data'] ?? [];
          totalPermissions = permissions.length;
        }
      }

      return {
        'total_users': totalUsers,
        'active_users': activeUsers,
        'total_roles': totalRoles,
        'total_permissions': totalPermissions,
        'recent_users': recentUsers,
        'users_by_role': usersByRole,
      };
    } catch (e) {
      print('Error al obtener estadísticas básicas: $e');
      return _getDefaultStats();
    }
  }

  Map<String, dynamic> _getDefaultStats() {
    return {
      'total_users': 0,
      'active_users': 0,
      'total_roles': 0,
      'total_permissions': 0,
      'recent_users': [],
      'users_by_role': [],
    };
  }

  Color _getRoleColor(String roleName) {
    switch (roleName.toLowerCase()) {
      case 'admin':
        return const Color(0xFFE53E3E); // Red
      case 'user':
        return const Color(0xFF3182CE); // Blue
      case 'emprendedor':
        return const Color(0xFF38A169); // Green
      case 'moderador':
        return const Color(0xFFD69E2E); // Yellow
      default:
        return const Color(0xFF718096); // Gray
    }
  }

  // Obtener lista completa de usuarios
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getUsersUrl()),
        headers: _getAuthHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['data'] ?? []);
        }
      }

      return [];
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  // Obtener lista completa de roles
  Future<List<Map<String, dynamic>>> getRoles() async {
    try {
      final token = await _authService.getToken();
      print('--- GET ROLES ---');
      print('Token: ${token != null ? "Presente" : "NULO"}');

      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getRolesUrl()),
        headers: _getAuthHeaders(token),
      );

      print('Get Roles Status Code: ${response.statusCode}');
      print('Get Roles Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Soporte para respuestas paginadas (data: { data: [] }) y no paginadas (data: [])
          if (data['data'] is Map && data['data'].containsKey('data')) {
            return List<Map<String, dynamic>>.from(data['data']['data']);
          }
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Error al obtener roles: ${data['message']}');
        }
      } else {
        throw Exception('Error del servidor al obtener roles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudieron cargar los roles. $e');
    }
  }

  // Obtener lista completa de permisos
  Future<List<Map<String, dynamic>>> getPermissions() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      final response = await http.get(
        Uri.parse(ApiConfig.getPermissionsUrl()),
        headers: _getAuthHeaders(token),
      );

      print('Get Permissions Status Code: ${response.statusCode}');
      print('Get Permissions Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        } else {
          throw Exception('Error al obtener permisos: ${data['message'] ?? 'Respuesta inesperada'}');
        }
      } else {
        throw Exception('Error del servidor al obtener permisos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('No se pudieron cargar los permisos: $e');
    }
  }

  // Crear un nuevo rol
  Future<Map<String, dynamic>> createRole(String name, List<String> permissionNames) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      final response = await http.post(
        Uri.parse(ApiConfig.getRolesUrl()),
        headers: _getAuthHeaders(token),
        body: json.encode({
          'name': name,
          'permissions': permissionNames,
        }),
      );
      
      print('Create Role Status Code: ${response.statusCode}');
      print('Create Role Response Body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 201 || (response.statusCode == 200 && data['success'] == true)) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error al crear el rol');
      }
    } catch (e) {
      throw Exception('No se pudo crear el rol: $e');
    }
  }

  // Actualizar un rol existente
  Future<Map<String, dynamic>> updateRole(int id, String name, List<String> permissionNames) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      final response = await http.put(
        Uri.parse(ApiConfig.getRoleUrl(id)),
        headers: _getAuthHeaders(token),
        body: json.encode({
          'name': name,
          'permissions': permissionNames,
        }),
      );

      print('Update Role Status Code: ${response.statusCode}');
      print('Update Role Response Body: ${response.body}');

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error al actualizar el rol');
      }
    } catch (e) {
      throw Exception('No se pudo actualizar el rol: $e');
    }
  }

  // ===== MUNICIPALIDAD =====

  Future<List<Municipalidad>> getMunicipalidades() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');

    final response = await http.get(
      Uri.parse(ApiConfig.getMunicipalidadesUrl()),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data'] is List) {
        final List municipalidadesJson = data['data'];
        return municipalidadesJson
            .map((json) => Municipalidad.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Fallo al cargar municipalidades: ${data['message']}');
      }
    } else {
      throw Exception(
          'Error al cargar municipalidades: ${response.statusCode}');
    }
  }

  Future<Municipalidad> createMunicipalidad(
      Map<String, dynamic> municipalidadData) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');

    final response = await http.post(
      Uri.parse(ApiConfig.getMunicipalidadesUrl()),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(municipalidadData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return Municipalidad.fromJson(data['data']);
    } else {
      throw Exception('Error al crear municipalidad: ${response.body}');
    }
  }

  Future<Municipalidad> updateMunicipalidad(
      int id, Map<String, dynamic> municipalidadData) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');

    final response = await http.put(
      Uri.parse(ApiConfig.getMunicipalidadUrl(id)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode(municipalidadData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Municipalidad.fromJson(data['data']);
    } else {
      throw Exception('Error al actualizar municipalidad: ${response.body}');
    }
  }

  Future<void> deleteMunicipalidad(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('No autenticado');

    final response = await http.delete(
      Uri.parse(ApiConfig.getMunicipalidadUrl(id)),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json'
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al eliminar municipalidad: ${response.body}');
    }
  }

  // Obtener lista completa de reservas
  Future<List<Map<String, dynamic>>> getReservas() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      final response = await http.get(
        Uri.parse(ApiConfig.getReservasUrl()),
        headers: _getAuthHeaders(token),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Soporte para paginación (data: { data: [] }) y no paginada (data: [])
          if (data['data'] is Map && data['data'].containsKey('data')) {
            return List<Map<String, dynamic>>.from(data['data']['data']);
          }
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return [];
    } catch (e) {
      print('Error al obtener reservas: $e');
      return [];
    }
  }
} 