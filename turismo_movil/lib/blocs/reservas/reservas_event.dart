import 'package:equatable/equatable.dart';

abstract class ReservasEvent extends Equatable {
  const ReservasEvent();

  @override
  List<Object?> get props => [];
}

// Eventos para cargar reservas
class LoadReservas extends ReservasEvent {
  final Map<String, dynamic>? filters;

  const LoadReservas({this.filters});

  @override
  List<Object?> get props => [filters];
}

class LoadReserva extends ReservasEvent {
  final int id;

  const LoadReserva(this.id);

  @override
  List<Object> get props => [id];
}

class RefreshReservas extends ReservasEvent {}

// Eventos para filtros
class FilterReservas extends ReservasEvent {
  final Map<String, dynamic> filters;

  const FilterReservas(this.filters);

  @override
  List<Object> get props => [filters];
}

class ClearFilters extends ReservasEvent {}

// Eventos para CRUD
class CreateReserva extends ReservasEvent {
  final Map<String, dynamic> reservaData;

  const CreateReserva(this.reservaData);

  @override
  List<Object> get props => [reservaData];
}

class UpdateReserva extends ReservasEvent {
  final int id;
  final Map<String, dynamic> reservaData;

  const UpdateReserva(this.id, this.reservaData);

  @override
  List<Object> get props => [id, reservaData];
}

class DeleteReserva extends ReservasEvent {
  final int id;

  const DeleteReserva(this.id);

  @override
  List<Object> get props => [id];
}

class ChangeReservaEstado extends ReservasEvent {
  final int id;
  final String estado;

  const ChangeReservaEstado(this.id, this.estado);

  @override
  List<Object> get props => [id, estado];
}

// Eventos para obtener datos relacionados
class LoadEmprendedores extends ReservasEvent {}

class LoadServicios extends ReservasEvent {}

class LoadServiciosByEmprendedor extends ReservasEvent {
  final int emprendedorId;

  LoadServiciosByEmprendedor(this.emprendedorId);

  @override
  List<Object> get props => [emprendedorId];
}

class LoadUsuarios extends ReservasEvent {} 