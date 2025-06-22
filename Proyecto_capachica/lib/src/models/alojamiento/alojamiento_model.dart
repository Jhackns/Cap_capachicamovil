import 'package:equatable/equatable.dart';
import './categoria_alojamiento_model.dart'; // Assuming in the same directory
import './direccion_model.dart';
import './foto_alojamiento_model.dart';
import './disponibilidad_model.dart'; // For a list of available dates/periods
// import '../servicio/servicio_model.dart'; // Will be needed when showing details

class Alojamiento extends Equatable {
  final String id;
  final String nombre;
  final String descripcion;
  final double precioPorNoche;
  final String anfitrionId; // Foreign Key to User model (host)

  final CategoriaAlojamiento categoria; // Embedded or ID then fetch
  final Direccion direccion; // Embedded or ID then fetch

  final List<FotoAlojamiento> fotos; // List of photos
  final List<String> idServicios; // List of service IDs offered
  final List<PeriodoDisponibilidad> periodosDisponibilidad; // List of availability periods
  final double? calificacionPromedio; // Average rating

  const Alojamiento({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precioPorNoche,
    required this.anfitrionId,
    required this.categoria,
    required this.direccion,
    this.fotos = const [],
    this.idServicios = const [],
    this.periodosDisponibilidad = const [],
    this.calificacionPromedio,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        precioPorNoche,
        anfitrionId,
        categoria,
        direccion,
        fotos,
        idServicios,
        periodosDisponibilidad,
        calificacionPromedio,
      ];
}
