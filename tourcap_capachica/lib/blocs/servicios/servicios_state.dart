abstract class ServiciosState {}

class ServiciosInitial extends ServiciosState {}
class ServiciosLoading extends ServiciosState {}
class ServiciosLoaded extends ServiciosState {
  final List<Map<String, dynamic>> servicios;
  final List<Map<String, dynamic>> filteredServicios;
  ServiciosLoaded({required this.servicios, required this.filteredServicios});
}
class ServiciosError extends ServiciosState {
  final String message;
  ServiciosError(this.message);
} 