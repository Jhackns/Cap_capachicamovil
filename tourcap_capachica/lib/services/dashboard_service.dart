import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class DashboardService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      // Obtener estadísticas del dashboard
      final response = await http.get(
        Uri.parse(ApiConfig.getDashboardSummaryUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Obtener roles
      final rolesResponse = await http.get(
        Uri.parse(ApiConfig.getRolesUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Obtener permisos
      final permissionsResponse = await http.get(
        Uri.parse(ApiConfig.getPermissionsUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getRolesUrl()),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['data'] ?? []);
        }
      }

      return [];
    } catch (e) {
      print('Error al obtener roles: $e');
      return [];
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['data'] ?? []);
        }
      }

      return [];
    } catch (e) {
      print('Error al obtener permisos: $e');
      return [];
    }
  }
} 