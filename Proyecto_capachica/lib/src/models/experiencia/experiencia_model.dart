import 'package:equatable/equatable.dart';
// import '../alojamiento/foto_alojamiento_model.dart'; // Re-use Foto model if structure is identical or create a FotoExperiencia model

// Example of a simple Foto model for experiences, can be shared or specific
class FotoExperiencia extends Equatable {
  final String id;
  final String url;
  final String? descripcion;

  const FotoExperiencia({required this.id, required this.url, this.descripcion});

  @override
  List<Object?> get props => [id, url, descripcion];
}

enum CategoriaExperiencia {
  tourGuiado,
  gastronomia,
  tallerCultural,
  aventura,
  agroturismo,
  otro
}

class Experiencia extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final String lugarEncuentro; // e.g., 'Plaza de Armas de Capachica' or specific coordinates
  final double duracionEstimadaHoras;
  final double precioPorPersona;
  final String anfitrionId; // ID of the User (host) or a community group entity
  final List<FotoExperiencia> fotos;
  final CategoriaExperiencia categoria;
  final int capacidadMaximaPersonas;
  final List<String> incluye; // e.g., ['Transporte', 'Almuerzo', 'Guía Bilingüe']
  final String? requisitos; // e.g., 'Buen estado físico', 'Llevar sombrero'
  final double? calificacionPromedio; // Similar to alojamientos

  const Experiencia({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.lugarEncuentro,
    required this.duracionEstimadaHoras,
    required this.precioPorPersona,
    required this.anfitrionId,
    this.fotos = const [],
    required this.categoria,
    required this.capacidadMaximaPersonas,
    this.incluye = const [],
    this.requisitos,
    this.calificacionPromedio,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        lugarEncuentro,
        duracionEstimadaHoras,
        precioPorPersona,
        anfitrionId,
        fotos,
        categoria,
        capacidadMaximaPersonas,
        incluye,
        requisitos,
        calificacionPromedio,
      ];
}
