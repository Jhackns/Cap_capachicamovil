import 'package:equatable/equatable.dart';

enum EstadoReserva {
  pendiente, // Waiting for confirmation or payment
  confirmada, // Confirmed by host/system
  canceladaPorUsuario,
  canceladaPorAnfitrion,
  completada, // Stay finished
  noPresentado // User didn't show up
}

class Reserva extends Equatable {
  final String id;
  final String alojamientoId;
  final String usuarioId; // Turista ID
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int numeroHuespedes;
  final double costoTotal;
  final EstadoReserva estado;
  final DateTime fechaCreacion; // When the booking was made

  // Optional fields
  final String? notasEspeciales; // Special requests from user

  const Reserva({
    required this.id,
    required this.alojamientoId,
    required this.usuarioId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.numeroHuespedes,
    required this.costoTotal,
    required this.estado,
    required this.fechaCreacion,
    this.notasEspeciales,
  });

  @override
  List<Object?> get props => [
        id,
        alojamientoId,
        usuarioId,
        fechaInicio,
        fechaFin,
        numeroHuespedes,
        costoTotal,
        estado,
        fechaCreacion,
        notasEspeciales,
      ];

  // Helper to calculate duration of stay
  int get duracionEnNoches => fechaFin.difference(fechaInicio).inDays;
}
