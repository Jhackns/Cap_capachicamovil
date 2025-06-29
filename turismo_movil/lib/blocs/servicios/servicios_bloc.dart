import 'package:flutter_bloc/flutter_bloc.dart';
import 'servicios_event.dart';
import 'servicios_state.dart';
import '../../services/servicio_service.dart';

class ServiciosBloc extends Bloc<ServiciosEvent, ServiciosState> {
  final ServicioService _servicioService = ServicioService();
  List<Map<String, dynamic>> _servicios = [];
  List<Map<String, dynamic>> _filteredServicios = [];

  ServiciosBloc() : super(ServiciosInitial()) {
    on<LoadServicios>(_onLoadServicios);
    on<FilterServicios>(_onFilterServicios);
  }

  Future<void> _onLoadServicios(LoadServicios event, Emitter<ServiciosState> emit) async {
    emit(ServiciosLoading());
    try {
      final servicios = await _servicioService.getServicios();
      _servicios = servicios;
      _filteredServicios = servicios;
      emit(ServiciosLoaded(servicios: servicios, filteredServicios: servicios));
    } catch (e) {
      emit(ServiciosError(e.toString()));
    }
  }

  void _onFilterServicios(FilterServicios event, Emitter<ServiciosState> emit) {
    _filteredServicios = _servicios.where((servicio) {
      final nombre = (servicio['nombre'] ?? '').toString().toLowerCase();
      final descripcion = (servicio['descripcion'] ?? '').toString().toLowerCase();
      final emprendedor = (servicio['emprendedor']?['nombre'] ?? servicio['emprendedor_nombre'] ?? '').toString().toLowerCase();
      final categorias = (servicio['categorias'] as List?)?.map((c) => c['nombre']?.toString().toLowerCase() ?? '').toList() ?? [];
      final estado = (servicio['estado'] == true || servicio['estado'] == 1) ? 'Activo' : 'Inactivo';

      final matchesQuery = event.searchQuery.isEmpty ||
        nombre.contains(event.searchQuery.toLowerCase()) ||
        descripcion.contains(event.searchQuery.toLowerCase());
      final matchesEmprendedor = event.emprendedor == 'Todos' || emprendedor == event.emprendedor.toLowerCase();
      final matchesCategoria = event.categoria == 'Todos' || categorias.contains(event.categoria.toLowerCase());
      final matchesEstado = event.estado == 'Todos' || estado == event.estado;

      return matchesQuery && matchesEmprendedor && matchesCategoria && matchesEstado;
    }).toList();
    emit(ServiciosLoaded(servicios: _servicios, filteredServicios: _filteredServicios));
  }
} 