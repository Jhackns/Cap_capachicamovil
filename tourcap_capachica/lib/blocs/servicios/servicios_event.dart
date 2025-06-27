abstract class ServiciosEvent {}

class LoadServicios extends ServiciosEvent {}
class FilterServicios extends ServiciosEvent {
  final String searchQuery;
  final String emprendedor;
  final String categoria;
  final String estado;
  FilterServicios({required this.searchQuery, required this.emprendedor, required this.categoria, required this.estado});
}
// Otros eventos como Create, Update, Delete se agregarán después 