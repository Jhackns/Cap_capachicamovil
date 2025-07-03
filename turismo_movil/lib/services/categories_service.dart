import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/categoria.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class CategoriesService {
  final AuthService _authService = AuthService();

  Future<List<Categoria>> getAllCategories() async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/categorias'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final list = data['data'] as List;
        return list.map((e) => Categoria.fromJson(e)).toList();
      } else {
        throw Exception(data['message'] ?? 'Error al obtener categorías');
      }
    } else {
      throw Exception('Error HTTP: ${response.statusCode}');
    }
  }

  Future<void> crearCategoria(String nombre, String descripcion, String iconoUrl, String imagenUrl) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/categorias'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nombre': nombre,
        'descripcion': descripcion,
        'icono_url': iconoUrl,
        'imagen_url': imagenUrl,
      }),
    );
    if (response.statusCode != 201) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Error al crear categoría');
    }
  }

  Future<void> editarCategoria(int id, String nombre, String descripcion, String iconoUrl, String imagenUrl) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/api/categorias/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'nombre': nombre,
        'descripcion': descripcion,
        'icono_url': iconoUrl,
        'imagen_url': imagenUrl,
      }),
    );
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Error al editar categoría');
    }
  }

  Future<void> eliminarCategoria(int id) async {
    final token = await _authService.getToken();
    if (token == null) throw Exception('Token no disponible');
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/api/categorias/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Error al eliminar categoría');
    }
  }
} 