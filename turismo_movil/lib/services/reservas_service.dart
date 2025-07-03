import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reserva.dart';
import '../models/reserva_servicio.dart';
import '../services/auth_service.dart';
import '../config/api_config.dart';

class ReservasService {
  final AuthService _authService = AuthService();

  // Obtener mis reservas
  Future<List<Reserva>> obtenerMisReservas() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/reservas/mis-reservas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final reservasData = data['data'] as List;
          return reservasData.map((json) => Reserva.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Error al obtener reservas');
        }
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Error obteniendo mis reservas: $e');
      rethrow;
    }
  }

  // Actualizar notas de una reserva
  Future<bool> actualizarNotasReserva(int reservaId, String notas) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/reservas/$reservaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'notas': notas,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error actualizando notas de reserva: $e');
      return false;
    }
  }

  // Cambiar estado de un servicio reservado
  Future<bool> cambiarEstadoServicio(int servicioId, String nuevoEstado) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/reserva-servicios/$servicioId/estado'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'estado': nuevoEstado,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error cambiando estado de servicio: $e');
      return false;
    }
  }

  // Cancelar una reserva
  Future<bool> cancelarReserva(int reservaId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/reservas/$reservaId/estado'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'estado': 'cancelada',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error cancelando reserva: $e');
      return false;
    }
  }

  // Confirmar una reserva
  Future<bool> confirmarReserva(int reservaId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/reservas/$reservaId/estado'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'estado': 'confirmada',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error confirmando reserva: $e');
      return false;
    }
  }

  // Obtener detalles de una reserva específica
  Future<Reserva?> obtenerDetalleReserva(int reservaId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/reservas/$reservaId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Reserva.fromJson(data['data']);
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      print('Error obteniendo detalle de reserva: $e');
      return null;
    }
  }

  // Actualizar fecha y hora de un servicio reservado
  Future<bool> updateReservaServicio({
    required int reservaServicioId,
    required String fechaInicio,
    required String fechaFin,
    required String horaInicio,
    required String horaFin,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Token no disponible');
      }
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/reserva-servicios/$reservaServicioId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'fecha_inicio': fechaInicio,
          'fecha_fin': fechaFin,
          'hora_inicio': horaInicio,
          'hora_fin': horaFin,
        }),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error actualizando horario de reserva-servicio: $e');
      return false;
    }
  }
} 