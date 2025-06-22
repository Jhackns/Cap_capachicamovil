import 'package:equatable/equatable.dart';

class Resena extends Equatable {
  final String id;
  final String reservaId; // Link to the specific booking
  final String alojamientoId; // Denormalized for easier fetching for an alojamiento
  final String usuarioId; // Turista ID (author of the review)
  final double calificacion; // e.g., 1.0 to 5.0
  final String? comentario;
  final DateTime fechaResena;
  final String? nombreUsuario; // Denormalized for display
  final String? fotoUsuarioUrl; // Denormalized for display


  const Resena({
    required this.id,
    required this.reservaId,
    required this.alojamientoId,
    required this.usuarioId,
    required this.calificacion,
    this.comentario,
    required this.fechaResena,
    this.nombreUsuario, // Should be fetched or populated
    this.fotoUsuarioUrl, // Should be fetched or populated
  });

  @override
  List<Object?> get props => [
        id,
        reservaId,
        alojamientoId,
        usuarioId,
        calificacion,
        comentario,
        fechaResena,
        nombreUsuario,
        fotoUsuarioUrl,
      ];
}
