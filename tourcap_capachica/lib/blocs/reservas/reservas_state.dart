import 'package:equatable/equatable.dart';

abstract class ReservasState extends Equatable {
  const ReservasState();

  @override
  List<Object?> get props => [];
}

// Estados iniciales
class ReservasInitial extends ReservasState {}

class ReservasLoading extends ReservasState {}

// Estados de éxito
class ReservasLoaded extends ReservasState {
  final List<Map<String, dynamic>> reservas;
  final List<Map<String, dynamic>>? emprendedores;
  final List<Map<String, dynamic>>? servicios;
  final List<Map<String, dynamic>>? usuarios;

  const ReservasLoaded({
    required this.reservas,
    this.emprendedores,
    this.servicios,
    this.usuarios,
  });

  @override
  List<Object?> get props => [reservas, emprendedores, servicios, usuarios];

  ReservasLoaded copyWith({
    List<Map<String, dynamic>>? reservas,
    List<Map<String, dynamic>>? emprendedores,
    List<Map<String, dynamic>>? servicios,
    List<Map<String, dynamic>>? usuarios,
  }) {
    return ReservasLoaded(
      reservas: reservas ?? this.reservas,
      emprendedores: emprendedores ?? this.emprendedores,
      servicios: servicios ?? this.servicios,
      usuarios: usuarios ?? this.usuarios,
    );
  }
}

class ReservasRefreshed extends ReservasState {
  final List<Map<String, dynamic>> reservas;
  final List<Map<String, dynamic>> filteredReservas;
  final Map<String, int> resumen;

  ReservasRefreshed({
    required this.reservas,
    required this.filteredReservas,
    required this.resumen,
  });

  @override
  List<Object?> get props => [reservas, filteredReservas, resumen];
}

// Estados para datos relacionados
class EmprendedoresLoaded extends ReservasState {
  final List<Map<String, dynamic>> emprendedores;

  EmprendedoresLoaded(this.emprendedores);

  @override
  List<Object?> get props => [emprendedores];
}

class ServiciosLoaded extends ReservasState {
  final List<Map<String, dynamic>> servicios;

  ServiciosLoaded(this.servicios);

  @override
  List<Object?> get props => [servicios];
}

class ServiciosByEmprendedorLoaded extends ReservasState {
  final List<Map<String, dynamic>> servicios;

  ServiciosByEmprendedorLoaded(this.servicios);

  @override
  List<Object?> get props => [servicios];
}

// Estados de operaciones CRUD
class ReservaCreated extends ReservasState {
  final Map<String, dynamic> reserva;

  const ReservaCreated(this.reserva);

  @override
  List<Object> get props => [reserva];
}

class ReservaUpdated extends ReservasState {
  final Map<String, dynamic> reserva;

  const ReservaUpdated(this.reserva);

  @override
  List<Object> get props => [reserva];
}

class ReservaDeleted extends ReservasState {
  final int id;

  const ReservaDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class ReservaEstadoChanged extends ReservasState {
  final int id;
  final String nuevoEstado;

  ReservaEstadoChanged(this.id, this.nuevoEstado);

  @override
  List<Object?> get props => [id, nuevoEstado];
}

// Estados de error
class ReservasError extends ReservasState {
  final String message;
  final String? details;

  const ReservasError(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

class ReservasEmpty extends ReservasState {
  final String message;

  const ReservasEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

// Estados de operaciones en progreso
class ReservaCreating extends ReservasState {}

class ReservaUpdating extends ReservasState {}

class ReservaDeleting extends ReservasState {}

class ReservaEstadoChanging extends ReservasState {}

class ReservaLoaded extends ReservasState {
  final Map<String, dynamic> reserva;

  const ReservaLoaded(this.reserva);

  @override
  List<Object> get props => [reserva];
} 