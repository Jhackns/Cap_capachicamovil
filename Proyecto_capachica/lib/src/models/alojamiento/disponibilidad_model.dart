import 'package:equatable/equatable.dart';

class Disponibilidad extends Equatable {
  final String id;
  final String alojamientoId; // Foreign key to Alojamiento
  final DateTime fecha; // A specific date the accommodation is available
  // Or:
  // final DateTime fechaInicio;
  // final DateTime fechaFin;
  // final bool estaDisponible; // if representing a block/range

  const Disponibilidad({
    required this.id,
    required this.alojamientoId,
    required this.fecha,
  });

  @override
  List<Object?> get props => [id, alojamientoId, fecha];
}

// More complex availability might involve a list of date ranges
class PeriodoDisponibilidad extends Equatable {
  final String id;
  final String alojamientoId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool estaDisponible; // True if available, false if blocked for this period

  const PeriodoDisponibilidad({
    required this.id,
    required this.alojamientoId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estaDisponible,
  });

  @override
  List<Object?> get props => [id, alojamientoId, fechaInicio, fechaFin, estaDisponible];
}
