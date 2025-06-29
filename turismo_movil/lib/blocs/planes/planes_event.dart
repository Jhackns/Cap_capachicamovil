import 'package:equatable/equatable.dart';

abstract class PlanesEvent extends Equatable {
  const PlanesEvent();

  @override
  List<Object?> get props => [];
}

// Eventos de carga
class LoadPlanes extends PlanesEvent {}

class LoadPlan extends PlanesEvent {
  final int planId;

  const LoadPlan(this.planId);

  @override
  List<Object> get props => [planId];
}

// Eventos CRUD
class CreatePlan extends PlanesEvent {
  final Map<String, dynamic> planData;

  const CreatePlan(this.planData);

  @override
  List<Object> get props => [planData];
}

class UpdatePlan extends PlanesEvent {
  final int planId;
  final Map<String, dynamic> planData;

  const UpdatePlan(this.planId, this.planData);

  @override
  List<Object> get props => [planId, planData];
}

class DeletePlan extends PlanesEvent {
  final int planId;

  const DeletePlan(this.planId);

  @override
  List<Object> get props => [planId];
}

class TogglePlanEstado extends PlanesEvent {
  final int planId;
  final String nuevoEstado;

  const TogglePlanEstado(this.planId, this.nuevoEstado);

  @override
  List<Object> get props => [planId, nuevoEstado];
}

// Eventos de filtrado
class FilterPlanes extends PlanesEvent {
  final String searchQuery;
  final String estado;
  final String dificultad;
  final String publico;

  const FilterPlanes({
    this.searchQuery = '',
    this.estado = 'Todos',
    this.dificultad = 'Todas',
    this.publico = 'Todos',
  });

  @override
  List<Object?> get props => [searchQuery, estado, dificultad, publico];
}

// Eventos de carga de datos relacionados
class LoadEmprendedores extends PlanesEvent {}

class LoadCategorias extends PlanesEvent {} 