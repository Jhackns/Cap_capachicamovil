import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/reserva_service.dart';
import '../../../services/servicio_service.dart';
import '../../../services/dashboard_service.dart';
import '../../../services/user_service.dart';
import 'reservas_event.dart';
import 'reservas_state.dart';

class ReservasBloc extends Bloc<ReservasEvent, ReservasState> {
  final ReservaService _reservaService;
  final ServicioService _servicioService;
  final DashboardService _dashboardService;
  final UserService _userService;

  // Variables para filtros
  String? _codigoFilter;
  String? _estadoFilter;
  DateTime? _fechaInicioFilter;

  ReservasBloc({
    required ReservaService reservaService,
    required ServicioService servicioService,
    required DashboardService dashboardService,
    required UserService userService,
  })  : _reservaService = reservaService,
        _servicioService = servicioService,
        _dashboardService = dashboardService,
        _userService = userService,
        super(ReservasInitial()) {
    
    on<LoadReservas>(_onLoadReservas);
    on<LoadReserva>(_onLoadReserva);
    on<CreateReserva>(_onCreateReserva);
    on<UpdateReserva>(_onUpdateReserva);
    on<DeleteReserva>(_onDeleteReserva);
    on<ChangeReservaEstado>(_onChangeReservaEstado);
    on<LoadEmprendedores>(_onLoadEmprendedores);
    on<LoadServicios>(_onLoadServicios);
    on<LoadUsuarios>(_onLoadUsuarios);
    on<FilterReservas>(_onFilterReservas);
  }

  Future<void> _onLoadReservas(LoadReservas event, Emitter<ReservasState> emit) async {
    emit(ReservasLoading());
    try {
      final reservas = await _reservaService.getReservas(filters: event.filters);
      emit(ReservasLoaded(reservas: reservas));
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onLoadReserva(LoadReserva event, Emitter<ReservasState> emit) async {
    emit(ReservasLoading());
    try {
      final reserva = await _reservaService.getReserva(event.id);
      emit(ReservaLoaded(reserva));
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onCreateReserva(CreateReserva event, Emitter<ReservasState> emit) async {
    emit(ReservasLoading());
    try {
      final reserva = await _reservaService.createReserva(event.reservaData);
      emit(ReservaCreated(reserva));
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onUpdateReserva(UpdateReserva event, Emitter<ReservasState> emit) async {
    emit(ReservasLoading());
    try {
      final reserva = await _reservaService.updateReserva(event.id, event.reservaData);
      emit(ReservaUpdated(reserva));
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onDeleteReserva(DeleteReserva event, Emitter<ReservasState> emit) async {
    emit(ReservasLoading());
    try {
      await _reservaService.deleteReserva(event.id);
      emit(ReservaDeleted(event.id));
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onChangeReservaEstado(ChangeReservaEstado event, Emitter<ReservasState> emit) async {
    emit(ReservasLoading());
    try {
      final reserva = await _reservaService.changeEstado(event.id, event.estado);
      emit(ReservaUpdated(reserva));
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onLoadEmprendedores(LoadEmprendedores event, Emitter<ReservasState> emit) async {
    try {
      final emprendedores = await _servicioService.getEmprendedores();
      
      // Actualizar estado actual si ya tenemos datos
      if (state is ReservasLoaded) {
        final currentState = state as ReservasLoaded;
        emit(currentState.copyWith(emprendedores: emprendedores));
      } else {
        emit(ReservasLoaded(reservas: [], emprendedores: emprendedores));
      }
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onLoadServicios(LoadServicios event, Emitter<ReservasState> emit) async {
    try {
      final servicios = await _servicioService.getServicios();
      
      // Actualizar estado actual si ya tenemos datos
      if (state is ReservasLoaded) {
        final currentState = state as ReservasLoaded;
        emit(currentState.copyWith(servicios: servicios));
      } else {
        emit(ReservasLoaded(reservas: [], servicios: servicios));
      }
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onLoadUsuarios(LoadUsuarios event, Emitter<ReservasState> emit) async {
    try {
      final usuarios = await _userService.getUsers();
      
      // Actualizar estado actual si ya tenemos datos
      if (state is ReservasLoaded) {
        final currentState = state as ReservasLoaded;
        emit(currentState.copyWith(usuarios: usuarios));
      } else {
        emit(ReservasLoaded(reservas: [], usuarios: usuarios));
      }
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  Future<void> _onFilterReservas(FilterReservas event, Emitter<ReservasState> emit) async {
    emit(ReservasLoading());
    try {
      final reservas = await _reservaService.getReservas(filters: event.filters);
      emit(ReservasLoaded(reservas: reservas));
    } catch (e) {
      emit(ReservasError(e.toString()));
    }
  }

  // Métodos auxiliares
  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> reservas) {
    return reservas.where((reserva) {
      // Filtro por código
      if (_codigoFilter != null && _codigoFilter!.isNotEmpty) {
        final codigo = (reserva['codigo_reserva'] ?? reserva['codigo'] ?? '').toString().toLowerCase();
        if (!codigo.contains(_codigoFilter!.toLowerCase())) {
          return false;
        }
      }

      // Filtro por estado
      if (_estadoFilter != null && _estadoFilter != 'Todos') {
        final estado = (reserva['estado'] ?? '').toString();
        if (estado != _estadoFilter) {
          return false;
        }
      }

      // Filtro por fecha
      if (_fechaInicioFilter != null) {
        final fechaReserva = _parseFecha(reserva['created_at'] ?? reserva['fecha']);
        if (fechaReserva == null || fechaReserva.isBefore(_fechaInicioFilter!)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Map<String, int> _calculateResumen(List<Map<String, dynamic>> reservas) {
    final resumen = {
      'Total': reservas.length,
      'Pendientes': 0,
      'Confirmadas': 0,
      'Completadas': 0,
      'Canceladas': 0,
    };

    for (final reserva in reservas) {
      final estado = (reserva['estado'] ?? '').toString().toLowerCase();
      switch (estado) {
        case 'pendiente':
          resumen['Pendientes'] = resumen['Pendientes']! + 1;
          break;
        case 'confirmada':
          resumen['Confirmadas'] = resumen['Confirmadas']! + 1;
          break;
        case 'completada':
          resumen['Completadas'] = resumen['Completadas']! + 1;
          break;
        case 'cancelada':
          resumen['Canceladas'] = resumen['Canceladas']! + 1;
          break;
      }
    }

    return resumen;
  }

  bool _hasActiveFilters() {
    return _codigoFilter != null && _codigoFilter!.isNotEmpty ||
           _estadoFilter != null && _estadoFilter != 'Todos' ||
           _fechaInicioFilter != null;
  }

  DateTime? _parseFecha(dynamic fecha) {
    if (fecha == null) return null;
    if (fecha is DateTime) return fecha;
    if (fecha is String) {
      try {
        return DateTime.parse(fecha);
      } catch (_) {}
    }
    return null;
  }
} 