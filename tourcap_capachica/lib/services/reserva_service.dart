import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/backend_routes.dart';
import '../utils/error_handler.dart';

class ReservaService {
  final String _baseUrl = ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    return await ApiConfig.token;
  }

  Future<List<Map<String, dynamic>>> getReservas({Map<String, dynamic>? filters}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final queryParams = <String, String>{};
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            queryParams[key] = value.toString();
          }
        });
      }

      final uri = Uri.parse('$_baseUrl${BackendRoutes.reservas}').replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['data'] ?? data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener reservas');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> getReserva(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl${BackendRoutes.reservas}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener reserva');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> createReserva(Map<String, dynamic> reservaData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl${BackendRoutes.reservas}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(reservaData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al crear reserva');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateReserva(int id, Map<String, dynamic> reservaData) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl${BackendRoutes.reservas}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(reservaData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al actualizar reserva');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<void> deleteReserva(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.delete(
        Uri.parse('$_baseUrl${BackendRoutes.reservas}/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Error al eliminar reserva');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<Map<String, dynamic>> changeEstado(int id, String estado) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.put(
        Uri.parse('$_baseUrl${BackendRoutes.reservas}/$id/estado'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'estado': estado}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Map<String, dynamic>.from(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Error al cambiar estado');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getReservasByEmprendedor(int emprendedorId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl${BackendRoutes.reservas}/emprendedor/$emprendedorId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['data'] ?? data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener reservas del emprendedor');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getReservasByServicio(int servicioId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl${BackendRoutes.reservas}/servicio/$servicioId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']['data'] ?? data['data'] ?? []);
        } else {
          throw Exception(data['message'] ?? 'Error al obtener reservas del servicio');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  Future<bool> verificarDisponibilidad({
    required int servicioId,
    required String fechaInicio,
    String? fechaFin,
    required String horaInicio,
    required String horaFin,
    int? reservaServicioId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final queryParams = <String, String>{
        'servicio_id': servicioId.toString(),
        'fecha_inicio': fechaInicio,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
      };

      if (fechaFin != null) {
        queryParams['fecha_fin'] = fechaFin;
      }

      if (reservaServicioId != null) {
        queryParams['reserva_servicio_id'] = reservaServicioId.toString();
      }

      final uri = Uri.parse('$_baseUrl/api/reserva-servicios/verificar-disponibilidad')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['disponible'] ?? false;
        } else {
          throw Exception(data['message'] ?? 'Error al verificar disponibilidad');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }
} 