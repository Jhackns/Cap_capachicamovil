part of 'servicio_bloc.dart';

abstract class ServicioState extends Equatable {
  const ServicioState();

  @override
  List<Object?> get props => [];
}

class ServiciosInitial extends ServicioState {}

class ServiciosLoading extends ServicioState {}

class MasterServiciosLoaded extends ServicioState {
  final List<Servicio> servicios;
  const MasterServiciosLoaded({required this.servicios});
  @override
  List<Object> get props => [servicios];
}

// Could also have a state for AlojamientoServicio objects if more detail is needed
class AlojamientoServiciosLoaded extends ServicioState {
  final List<Servicio> servicios; // List of detailed Servicio objects
  // Or: final List<AlojamientoServicio> alojamientoServicios;
  // Or: final Map<Servicio, AlojamientoServicioDetalles> serviciosConDetalles;
  const AlojamientoServiciosLoaded({required this.servicios});
  @override
  List<Object> get props => [servicios];
}

class ServicioOperationSuccess extends ServicioState {
  final String message;
  final dynamic data; // Could be the created/updated object or true
  const ServicioOperationSuccess({required this.message, this.data});
   @override
  List<Object?> get props => [message, data];
}

class ServicioOperationFailure extends ServicioState {
  final String message;
  const ServicioOperationFailure({required this.message});
  @override
  List<Object> get props => [message];
}

class ServiciosError extends ServicioState {
  final String message;
  const ServiciosError({required this.message});
  @override
  List<Object> get props => [message];
}
