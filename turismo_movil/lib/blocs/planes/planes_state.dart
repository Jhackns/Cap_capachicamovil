import 'package:equatable/equatable.dart';

abstract class PlanesState extends Equatable {
  const PlanesState();

  @override
  List<Object?> get props => [];
}

// Estados iniciales
class PlanesInitial extends PlanesState {}

class PlanesLoading extends PlanesState {}

// Estados de éxito
class PlanesLoaded extends PlanesState {
  final List<Map<String, dynamic>> planes;
  final List<Map<String, dynamic>> filteredPlanes;
  final List<Map<String, dynamic>>? emprendedores;
  final List<Map<String, dynamic>>? categorias;

  const PlanesLoaded({
    required this.planes,
    required this.filteredPlanes,
    this.emprendedores,
    this.categorias,
  });

  @override
  List<Object?> get props => [planes, filteredPlanes, emprendedores, categorias];

  PlanesLoaded copyWith({
    List<Map<String, dynamic>>? planes,
    List<Map<String, dynamic>>? filteredPlanes,
    List<Map<String, dynamic>>? emprendedores,
    List<Map<String, dynamic>>? categorias,
  }) {
    return PlanesLoaded(
      planes: planes ?? this.planes,
      filteredPlanes: filteredPlanes ?? this.filteredPlanes,
      emprendedores: emprendedores ?? this.emprendedores,
      categorias: categorias ?? this.categorias,
    );
  }
}

// Estados para datos relacionados
class EmprendedoresLoaded extends PlanesState {
  final List<Map<String, dynamic>> emprendedores;

  const EmprendedoresLoaded(this.emprendedores);

  @override
  List<Object> get props => [emprendedores];
}

class CategoriasLoaded extends PlanesState {
  final List<Map<String, dynamic>> categorias;

  const CategoriasLoaded(this.categorias);

  @override
  List<Object> get props => [categorias];
}

// Estados de operaciones CRUD
class PlanCreated extends PlanesState {
  final Map<String, dynamic> plan;

  const PlanCreated(this.plan);

  @override
  List<Object> get props => [plan];
}

class PlanUpdated extends PlanesState {
  final Map<String, dynamic> plan;

  const PlanUpdated(this.plan);

  @override
  List<Object> get props => [plan];
}

class PlanDeleted extends PlanesState {
  final int id;

  const PlanDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class PlanEstadoChanged extends PlanesState {
  final int id;
  final String nuevoEstado;

  const PlanEstadoChanged(this.id, this.nuevoEstado);

  @override
  List<Object> get props => [id, nuevoEstado];
}

// Estados de error
class PlanesError extends PlanesState {
  final String message;
  final String? details;

  const PlanesError(this.message, {this.details});

  @override
  List<Object?> get props => [message, details];
}

class PlanesEmpty extends PlanesState {
  final String message;

  const PlanesEmpty(this.message);

  @override
  List<Object> get props => [message];
}

// Estados de operaciones en progreso
class PlanCreating extends PlanesState {}

class PlanUpdating extends PlanesState {}

class PlanDeleting extends PlanesState {}

class PlanEstadoChanging extends PlanesState {}

class PlanLoaded extends PlanesState {
  final Map<String, dynamic> plan;

  const PlanLoaded(this.plan);

  @override
  List<Object> get props => [plan];
} 