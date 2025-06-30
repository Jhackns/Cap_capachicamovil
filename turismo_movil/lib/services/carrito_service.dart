import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../models/carrito_item.dart';

class CarritoService {
  final AuthService _authService = AuthService();

  // Obtener el carrito del usuario desde el backend
  Future<Map<String, dynamic>?> obtenerCarrito() async {
    try {
      print('🛒 CarritoService.obtenerCarrito iniciado');
      final token = await _authService.getToken();
      if (token == null) {
        print('❌ Token no disponible en obtenerCarrito');
        throw Exception('Token no disponible');
      }
      print('✅ Token obtenido en obtenerCarrito: ${token.substring(0, 20)}...');

      final url = '${ApiConfig.baseUrl}/api/reservas/carrito';
      print('🌐 URL obtenerCarrito: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('📡 Response status obtenerCarrito: ${response.statusCode}');
      print('📡 Response body obtenerCarrito: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          print('✅ Carrito obtenido exitosamente');
          return data['data'];
        }
      }
      print('❌ No se pudo obtener el carrito');
      return null;
    } catch (e) {
      print('❌ Error obteniendo carrito: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  // Agregar servicio al carrito en el backend
  Future<bool> agregarAlCarrito({
    required int servicioId,
    required int emprendedorId,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required String horaInicio,
    required String horaFin,
    required int duracionMinutos,
    int cantidad = 1,
    String? notasCliente,
  }) async {
    try {
      print('🛒 Iniciando agregarAlCarrito...');
      print('📋 Parámetros recibidos:');
      print('   - servicioId: $servicioId');
      print('   - emprendedorId: $emprendedorId');
      print('   - fechaInicio: $fechaInicio');
      print('   - fechaFin: $fechaFin');
      print('   - horaInicio: $horaInicio');
      print('   - horaFin: $horaFin');
      print('   - duracionMinutos: $duracionMinutos');
      print('   - cantidad: $cantidad');
      print('   - notasCliente: $notasCliente');

      final token = await _authService.getToken();
      print('🔐 Token obtenido: ${token != null ? 'SÍ' : 'NO'}');
      if (token != null) {
        print('🔐 Token (primeros 20 chars): ${token.substring(0, 20)}...');
        print('🔐 Token (últimos 20 chars): ...${token.substring(token.length - 20)}');
        print('🔐 Token completo: $token');
      }
      
      if (token == null) {
        print('❌ Token no disponible');
        throw Exception('Token no disponible');
      }
      print('✅ Token obtenido: ${token.substring(0, 20)}...');

      final url = '${ApiConfig.baseUrl}/api/reservas/carrito/agregar';
      print('🌐 URL: $url');

      final body = {
        'servicio_id': servicioId,
        'emprendedor_id': emprendedorId,
        'fecha_inicio': fechaInicio.toIso8601String().split('T')[0],
        'fecha_fin': fechaFin.toIso8601String().split('T')[0],
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'duracion_minutos': duracionMinutos,
        'cantidad': cantidad,
        'notas_cliente': notasCliente,
      };

      print('📦 Body a enviar: ${json.encode(body)}');
      print('🔐 Headers a enviar:');
      print('   - Authorization: Bearer ${token.substring(0, 20)}...');
      print('   - Accept: application/json');
      print('   - Content-Type: application/json');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response headers: ${response.headers}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final success = data['success'] ?? false;
        print('✅ Respuesta exitosa: $success');
        return success;
      } else {
        print('❌ Error HTTP: ${response.statusCode}');
        print('❌ Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Error en agregarAlCarrito: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return false;
    }
  }

  // Eliminar servicio del carrito en el backend
  Future<bool> eliminarDelCarrito(int servicioCarritoId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token no disponible');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/reservas/carrito/servicio/$servicioCarritoId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Error eliminando del carrito: $e');
      return false;
    }
  }

  // Confirmar carrito (convertir en reserva)
  Future<Map<String, dynamic>?> confirmarCarrito({String? notas}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token no disponible');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/reservas/carrito/confirmar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'notas': notas,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Error confirmando carrito: $e');
      return null;
    }
  }

  // Vaciar carrito
  Future<bool> vaciarCarrito() async {
    try {
      final token = await _authService.getToken();
      if (token == null) throw Exception('Token no disponible');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/reservas/carrito/vaciar'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ Error vaciando carrito: $e');
      return false;
    }
  }

  // Convertir datos del backend a CarritoItem
  List<CarritoItem> convertirServiciosACarritoItems(Map<String, dynamic> carritoData) {
    final List<CarritoItem> items = [];
    
    if (carritoData['servicios'] != null) {
      for (final servicioData in carritoData['servicios']) {
        try {
          final item = CarritoItem(
            id: servicioData['id'],
            servicioId: servicioData['servicio_id'],
            nombreServicio: servicioData['servicio']['nombre'] ?? 'Servicio',
            nombreEmprendedor: servicioData['emprendedor']['nombre'] ?? 'Emprendedor',
            fecha: DateTime.parse(servicioData['fecha_inicio']),
            horaInicio: servicioData['hora_inicio'],
            horaFin: servicioData['hora_fin'],
            precio: double.tryParse(servicioData['precio'].toString()) ?? 0.0,
            cantidad: servicioData['cantidad'] ?? 1,
          );
          items.add(item);
        } catch (e) {
          print('❌ Error convirtiendo servicio a item: $e');
        }
      }
    }
    
    return items;
  }

  // Sincronizar carrito local con el backend
  Future<List<CarritoItem>> sincronizarCarrito() async {
    try {
      print('🔄 CarritoService.sincronizarCarrito iniciado');
      final carritoData = await obtenerCarrito();
      print('📦 Datos del carrito obtenidos: ${carritoData != null ? 'SÍ' : 'NO'}');
      
      if (carritoData != null) {
        print('📋 Estructura del carrito: ${carritoData.keys}');
        if (carritoData['servicios'] != null) {
          print('📦 Servicios en carrito: ${(carritoData['servicios'] as List).length}');
        }
        
        final items = convertirServiciosACarritoItems(carritoData);
        print('✅ Items convertidos: ${items.length}');
        return items;
      }
      print('⚠️ No hay datos del carrito, retornando lista vacía');
      return [];
    } catch (e) {
      print('❌ Error en sincronizarCarrito: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Método para probar la autenticación
  Future<bool> probarAutenticacion() async {
    try {
      print('🔍 Probando autenticación...');
      final token = await _authService.getToken();
      
      if (token == null) {
        print('❌ No hay token disponible');
        return false;
      }
      
      print('🔐 Token encontrado: ${token.substring(0, 20)}...');
      
      // Probar con el endpoint de test-auth
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/test-auth'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      print('🔍 Test auth status: ${response.statusCode}');
      print('🔍 Test auth body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error probando autenticación: $e');
      return false;
    }
  }
} 