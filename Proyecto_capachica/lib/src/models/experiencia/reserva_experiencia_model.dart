import 'package:equatable/equatable.dart';
// Re-use EstadoReserva from Reserva module if applicable or define specific states
import '../reserva/reserva_model.dart' show EstadoReserva;


class ReservaExperiencia extends Equatable {
  final String id;
  final String experienciaId;
  final String usuarioId;
  final DateTime fechaHoraExperiencia; // Specific date and time for the experience
  final int numeroPersonas;
  final double costoTotalReserva;
  final EstadoReserva estado; // Reuse EstadoReserva or define EstadoReservaExperiencia
  final DateTime fechaCreacionReserva;
  final String? notasAdicionales;

  const ReservaExperiencia({
    required this.id,
    required this.experienciaId,
    required this.usuarioId,
    required this.fechaHoraExperiencia,
    required this.numeroPersonas,
    required this.costoTotalReserva,
    required this.estado,
    required this.fechaCreacionReserva,
    this.notasAdicionales,
  });

  @override
  List<Object?> get props => [
        id,
        experienciaId,
        usuarioId,
        fechaHoraExperiencia,
        numeroPersonas,
        costoTotalReserva,
        estado,
        fechaCreacionReserva,
        notasAdicionales,
      ];
}
