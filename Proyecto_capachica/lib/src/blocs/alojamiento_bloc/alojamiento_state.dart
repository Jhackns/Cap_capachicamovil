part of 'alojamiento_bloc.dart';

abstract class AlojamientoState extends Equatable {
  const AlojamientoState();

  @override
  List<Object?> get props => [];
}

class AlojamientosInitial extends AlojamientoState {}

class AlojamientosLoading extends AlojamientoState {}

class AlojamientosLoaded extends AlojamientoState {
  final List<Alojamiento> alojamientos;

  const AlojamientosLoaded({required this.alojamientos});

  @override
  List<Object> get props => [alojamientos];
}

class AlojamientoDetailsLoading extends AlojamientoState {
   final String alojamientoId;
   const AlojamientoDetailsLoading({required this.alojamientoId});
    @override
  List<Object> get props => [alojamientoId];
}

class AlojamientoDetailsLoaded extends AlojamientoState {
  final Alojamiento alojamiento;
  // Potentially include related data like reviews, full service details here
  // final List<Servicio> serviciosDetallados;
  // final List<Resena> resenas;


  const AlojamientoDetailsLoaded({
    required this.alojamiento,
    // this.serviciosDetallados = const [],
    // this.resenas = const [],
  });

  @override
  List<Object> get props => [alojamiento];
}

class AlojamientosError extends AlojamientoState {
  final String message;

  const AlojamientosError({required this.message});

  @override
  List<Object> get props => [message];
}

// States for Admin Operations
class AlojamientoOperationLoading extends AlojamientoState {
  final String message;
  const AlojamientoOperationLoading({this.message = 'Processing...'});
   @override
  List<Object> get props => [message];
}

class AlojamientoOperationSuccess extends AlojamientoState {
  final String message;
  final Alojamiento? alojamiento; // Optional: return the created/updated alojamiento

  const AlojamientoOperationSuccess({required this.message, this.alojamiento});

  @override
  List<Object?> get props => [message, alojamiento];
}

class AlojamientoOperationFailure extends AlojamientoState {
  final String message;

  const AlojamientoOperationFailure({required this.message});

  @override
  List<Object> get props => [message];
}
