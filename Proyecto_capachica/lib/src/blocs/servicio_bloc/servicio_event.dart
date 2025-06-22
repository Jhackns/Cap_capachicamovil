part of 'servicio_bloc.dart';

abstract class ServicioEvent extends Equatable {
  const ServicioEvent();

  @override
  List<Object?> get props => [];
}

// Event to load the master list of all available service types
class LoadMasterServicios extends ServicioEvent {}

// Event to load the services specifically linked to an accommodation
class LoadServiciosForAlojamiento extends ServicioEvent {
  final String alojamientoId;
  const LoadServiciosForAlojamiento({required this.alojamientoId});
  @override
  List<Object> get props => [alojamientoId];
}

// Admin events for managing master services
class CreateMasterServicio extends ServicioEvent {
  final String nombre;
  final String? descripcion;
  final String? iconoUrlOrCode;
  const CreateMasterServicio({required this.nombre, this.descripcion, this.iconoUrlOrCode});
  @override
  List<Object?> get props => [nombre, descripcion, iconoUrlOrCode];
}

class UpdateMasterServicio extends ServicioEvent {
  final String servicioId;
  final String nombre;
  final String? descripcion;
  final String? iconoUrlOrCode;
  const UpdateMasterServicio({required this.servicioId, required this.nombre, this.descripcion, this.iconoUrlOrCode});
  @override
  List<Object?> get props => [servicioId, nombre, descripcion, iconoUrlOrCode];
}

class DeleteMasterServicio extends ServicioEvent {
  final String servicioId;
  const DeleteMasterServicio({required this.servicioId});
  @override
  List<Object> get props => [servicioId];
}

// Admin events for linking/unlinking services to/from accommodations
class LinkServicioToAlojamiento extends ServicioEvent {
  final String alojamientoId;
  final String servicioId;
  final String? detallesAdicionales;
  final double? costoExtra;
  const LinkServicioToAlojamiento({
    required this.alojamientoId,
    required this.servicioId,
    this.detallesAdicionales,
    this.costoExtra,
  });
  @override
  List<Object?> get props => [alojamientoId, servicioId, detallesAdicionales, costoExtra];
}

class UnlinkServicioFromAlojamiento extends ServicioEvent {
  final String alojamientoServicioId; // The ID of the AlojamientoServicio link instance
  const UnlinkServicioFromAlojamiento({required this.alojamientoServicioId});
  @override
  List<Object> get props => [alojamientoServicioId];
}
