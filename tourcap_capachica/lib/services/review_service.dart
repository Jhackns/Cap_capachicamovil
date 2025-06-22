import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import '../utils/api_config.dart';

class ReviewService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<Review>> getReviewsByEntrepreneur(int entrepreneurId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/emprendedores/$entrepreneurId/resenas'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar las reseñas');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<Review> createReview(Review review, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/emprendedores/${review.emprendedorId}/resenas'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(review.toJson()),
      );

      if (response.statusCode == 200) {
        return Review.fromJson(json.decode(response.body));
      } else {
        throw Exception('Error al crear la reseña');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<void> deleteReview(int entrepreneurId, int reviewId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/emprendedores/$entrepreneurId/resenas/$reviewId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la reseña');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
} 