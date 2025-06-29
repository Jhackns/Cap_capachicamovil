import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class ServicioService {
  final AuthService _authService = AuthService();

  Future<List<Map<String, dynamic>>> getServicios() async {
    try {
      final url = ApiConfig.getServiciosUrl();
      print('🔍 Intentando cargar servicios desde: $url');
      print('🔑 Sin autenticación (ruta pública)');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 Data decoded: $data');
        
        if (data['success'] == true) {
          List<Map<String, dynamic>> servicios;
          if (data['data'] is Map && data['data'].containsKey('data')) {
            servicios = List<Map<String, dynamic>>.from(data['data']['data']);
          } else {
            servicios = List<Map<String, dynamic>>.from(data['data']);
          }
          print('✅ Servicios cargados: ${servicios.length}');
          return servicios;
        } else {
          print('❌ Error en respuesta: ${data['message']}');
          throw Exception(data['message'] ?? 'Error al cargar servicios');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en getServicios: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getServicioById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.getServiciosUrl()}/$id'),
      headers: {
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
    
    print('🔄 Actualizando servicio $id con datos: $servicioData');
    
    final response = await http.put(
      Uri.parse('${ApiConfig.getServiciosUrl()}/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode(servicioData),
    );
    
    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Error al actualizar servicio');
      }
    } else {
      final errorData = json.decode(response.body);
      print('❌ Error data: $errorData');
      
      // Manejar errores de validación específicamente
      if (response.statusCode == 422 && errorData['errors'] != null) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        final errorMessages = errors.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('; ');
        throw Exception('Error de validación: $errorMessages');
      }
      
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
    
    print('🔄 Cambiando estado del servicio $id a: $estado');
    
    final response = await http.patch(
      Uri.parse('${ApiConfig.getServiciosUrl()}/$id/toggle-estado'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({'estado': estado}),
    );
    
    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] ?? false;
    } else {
      final errorData = json.decode(response.body);
      print('❌ Error data: $errorData');
      
      // Manejar errores de validación específicamente
      if (response.statusCode == 422 && errorData['errors'] != null) {
        final errors = errorData['errors'] as Map<String, dynamic>;
        final errorMessages = errors.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('; ');
        throw Exception('Error de validación: $errorMessages');
      }
      
      throw Exception(errorData['message'] ?? 'Error: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getEmprendedores() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.get(
      Uri.parse(ApiConfig.getEmprendedoresUrl()),
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
    final response = await http.get(
      Uri.parse(ApiConfig.getCategoriasUrl()),
      headers: {
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

  // Método para obtener horarios de un servicio
  Future<List<Map<String, dynamic>>> getHorariosServicio(int servicioId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    
    final response = await http.get(
      Uri.parse('${ApiConfig.getServiciosUrl()}/$servicioId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        final servicio = data['data'];
        return List<Map<String, dynamic>>.from(servicio['horarios'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Error al cargar horarios');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  // Método para subir imágenes
  Future<List<Map<String, dynamic>>> uploadImages(int servicioId, List<String> imagePaths) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.getServiciosUrl()}/$servicioId/images'),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    
    for (int i = 0; i < imagePaths.length; i++) {
      final file = await http.MultipartFile.fromPath(
        'images[$i]',
        imagePaths[i],
      );
      request.files.add(file);
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Error al subir imágenes');
      }
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error: ${response.statusCode}');
    }
  }

  // Método para obtener servicios por emprendedor
  Future<List<Map<String, dynamic>>> getServiciosByEmprendedor(int emprendedorId) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    
    final response = await http.get(
      Uri.parse('${ApiConfig.getServiciosUrl()}/emprendedor/$emprendedorId'),
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
        throw Exception(data['message'] ?? 'Error al cargar servicios del emprendedor');
      }
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  // Método para verificar disponibilidad de un servicio
  Future<bool> verificarDisponibilidad(int servicioId, String fecha, String horaInicio, String horaFin) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getServiciosVerificarDisponibilidadUrl()}?servicio_id=$servicioId&fecha=$fecha&hora_inicio=$horaInicio&hora_fin=$horaFin'),
        headers: {
          'Accept': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['disponible'] ?? false;
      } else {
        print('❌ Error verificando disponibilidad: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error en verificarDisponibilidad: $e');
      return false;
    }
  }

  // Método para obtener servicios relacionados por categoría
  Future<List<Map<String, dynamic>>> getServiciosRelacionados(int servicioId, String categoria) async {
    try {
      // Primero obtener todos los servicios y filtrar localmente
      final serviciosData = await getServicios();
      final servicios = serviciosData.map((data) => data).toList();
      
      // Filtrar servicios relacionados (misma categoría, diferente servicio)
      final relacionados = servicios.where((s) {
        final categorias = s['categorias'] as List<dynamic>? ?? [];
        final tieneCategoria = categorias.any((cat) => 
          cat['nombre']?.toString().toLowerCase().contains(categoria.toLowerCase()) == true
        );
        return s['id'] != servicioId && tieneCategoria;
      }).take(3).toList();
      
      return relacionados;
    } catch (e) {
      print('❌ Error en getServiciosRelacionados: $e');
      return [];
    }
  }
} 