part of 'resena_bloc.dart';

abstract class ResenaEvent extends Equatable {
  const ResenaEvent();
  @override
  List<Object?> get props => [];
}

class SubmitResena extends ResenaEvent {
  final String reservaId;
  final String alojamientoId;
  final String usuarioId;
  final double calificacion;
  final String? comentario;

  const SubmitResena({
    required this.reservaId,
    required this.alojamientoId,
    required this.usuarioId,
    required this.calificacion,
    this.comentario,
  });
  @override
  List<Object?> get props => [reservaId, alojamientoId, usuarioId, calificacion, comentario];
}

class LoadResenasForAlojamiento extends ResenaEvent {
  final String alojamientoId;
  const LoadResenasForAlojamiento({required this.alojamientoId});
  @override
  List<Object> get props => [alojamientoId];
}

class LoadUserResenas extends ResenaEvent { // If user wants to see their own reviews
  final String usuarioId;
  const LoadUserResenas({required this.usuarioId});
  @override
  List<Object> get props => [usuarioId];
}
