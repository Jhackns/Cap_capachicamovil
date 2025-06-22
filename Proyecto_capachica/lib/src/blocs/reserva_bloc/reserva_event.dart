part of 'reserva_bloc.dart';

abstract class ReservaEvent extends Equatable {
  const ReservaEvent();
  @override
  List<Object?> get props => [];
}

class CreateReserva extends ReservaEvent {
  final String alojamientoId;
  final String usuarioId;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final int numeroHuespedes;
  final double costoTotal; // Should be calculated and confirmed by backend ideally
  final String? notasEspeciales;

  const CreateReserva({
    required this.alojamientoId,
    required this.usuarioId,
    required this.fechaInicio,
    required this.fechaFin,
    required this.numeroHuespedes,
    required this.costoTotal,
    this.notasEspeciales,
  });

  @override
  List<Object?> get props => [alojamientoId, usuarioId, fechaInicio, fechaFin, numeroHuespedes, costoTotal, notasEspeciales];
}

class LoadUserReservas extends ReservaEvent {
  final String usuarioId;
  const LoadUserReservas({required this.usuarioId});
  @override
  List<Object> get props => [usuarioId];
}

class CancelReserva extends ReservaEvent {
  final String reservaId;
  final String usuarioId; // For validation
  const CancelReserva({required this.reservaId, required this.usuarioId});
  @override
  List<Object> get props => [reservaId, usuarioId];
}

// For Admin/Host to see bookings for their properties
class LoadReservasForAlojamiento extends ReservaEvent {
  final String alojamientoId;
  const LoadReservasForAlojamiento({required this.alojamientoId});
  @override
  List<Object> get props => [alojamientoId];
}
