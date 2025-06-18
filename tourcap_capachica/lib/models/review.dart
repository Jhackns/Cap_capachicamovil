import 'package:intl/intl.dart';

class Review {
  final int id;
  final String nombreAutor;
  final String comentario;
  final int puntuacion;
  final String? imagenes;
  final int emprendedorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.nombreAutor,
    required this.comentario,
    required this.puntuacion,
    this.imagenes,
    required this.emprendedorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      nombreAutor: json['nombreAutor'],
      comentario: json['comentario'],
      puntuacion: json['puntuacion'],
      imagenes: json['imagenes'],
      emprendedorId: json['emprendedorId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreAutor': nombreAutor,
      'comentario': comentario,
      'puntuacion': puntuacion,
      'imagenes': imagenes,
      'emprendedorId': emprendedorId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  String get formattedDate {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }

  // Datos de ejemplo para el diseño
  static List<Review> getDummyReviews() {
    return [
      Review(
        id: 1,
        nombreAutor: 'María García',
        comentario: 'Excelente servicio, muy atentos y el lugar es hermoso. Definitivamente volveré.',
        puntuacion: 5,
        imagenes: 'https://randomuser.me/api/portraits/women/1.jpg',
        emprendedorId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: 2,
        nombreAutor: 'Juan Pérez',
        comentario: 'Buen lugar, la comida es deliciosa y el ambiente es muy agradable.',
        puntuacion: 4,
        imagenes: 'https://randomuser.me/api/portraits/men/1.jpg',
        emprendedorId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: 3,
        nombreAutor: 'Ana Martínez',
        comentario: 'Muy buena atención y precios accesibles. Lo recomiendo.',
        puntuacion: 4,
        imagenes: 'https://randomuser.me/api/portraits/women/2.jpg',
        emprendedorId: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ];
  }
} 