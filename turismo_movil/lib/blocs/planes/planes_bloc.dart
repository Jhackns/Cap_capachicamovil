import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../../services/dashboard_service.dart';
import 'planes_event.dart';
import 'planes_state.dart';

class PlanesBloc extends Bloc<PlanesEvent, PlanesState> {
  final DashboardService _dashboardService = DashboardService();
  List<Map<String, dynamic>> _planes = [];
  List<Map<String, dynamic>> _filteredPlanes = [];

  PlanesBloc() : super(PlanesInitial()) {
    on<LoadPlanes>(_onLoadPlanes);
    on<LoadPlan>(_onLoadPlan);
    on<CreatePlan>(_onCreatePlan);
    on<UpdatePlan>(_onUpdatePlan);
    on<DeletePlan>(_onDeletePlan);
    on<TogglePlanEstado>(_onTogglePlanEstado);
    on<FilterPlanes>(_onFilterPlanes);
    on<LoadEmprendedores>(_onLoadEmprendedores);
    on<LoadCategorias>(_onLoadCategorias);
  }

  Future<void> _onLoadPlanes(LoadPlanes event, Emitter<PlanesState> emit) async {
    emit(PlanesLoading());
    try {
      final planes = await _dashboardService.getPlanes();
      _planes = planes;
      _filteredPlanes = planes;
      emit(PlanesLoaded(planes: planes, filteredPlanes: planes));
    } catch (e) {
      emit(PlanesError(e.toString()));
    }
  }

  Future<void> _onLoadPlan(LoadPlan event, Emitter<PlanesState> emit) async {
    emit(PlanesLoading());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(PlanesError('Token no disponible'));
        return;
      }

      final response = await http.get(
        Uri.parse(ApiConfig.getPlanByIdUrl(event.planId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          emit(PlanLoaded(data['data']));
        } else {
          emit(PlanesError(data['message'] ?? 'Error al cargar el plan'));
        }
      } else {
        emit(PlanesError('Error ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      emit(PlanesError(e.toString()));
    }
  }

  Future<void> _onCreatePlan(CreatePlan event, Emitter<PlanesState> emit) async {
    emit(PlanCreating());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(PlanesError('Token no disponible'));
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConfig.getPlanesUrl()),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(event.planData),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          emit(PlanCreated(data['data']));
          add(LoadPlanes());
        } else {
          emit(PlanesError(data['message'] ?? 'Error al crear el plan'));
        }
      } else {
        emit(PlanesError('Error ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      emit(PlanesError(e.toString()));
    }
  }

  Future<void> _onUpdatePlan(UpdatePlan event, Emitter<PlanesState> emit) async {
    emit(PlanUpdating());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(PlanesError('Token no disponible'));
        return;
      }

      final response = await http.put(
        Uri.parse(ApiConfig.getPlanByIdUrl(event.planId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(event.planData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          emit(PlanUpdated(data['data']));
          add(LoadPlanes());
        } else {
          emit(PlanesError(data['message'] ?? 'Error al actualizar el plan'));
        }
      } else {
        emit(PlanesError('Error ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      emit(PlanesError(e.toString()));
    }
  }

  Future<void> _onDeletePlan(DeletePlan event, Emitter<PlanesState> emit) async {
    emit(PlanDeleting());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(PlanesError('Token no disponible'));
        return;
      }

      final response = await http.delete(
        Uri.parse(ApiConfig.getPlanByIdUrl(event.planId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        emit(PlanDeleted(event.planId));
        add(LoadPlanes());
      } else {
        emit(PlanesError('Error ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      emit(PlanesError(e.toString()));
    }
  }

  Future<void> _onTogglePlanEstado(TogglePlanEstado event, Emitter<PlanesState> emit) async {
    emit(PlanEstadoChanging());
    try {
      final authService = AuthService();
      String? token = await authService.getToken();
      if (token == null) {
        emit(PlanesError('Token no disponible'));
        return;
      }

      final response = await http.patch(
        Uri.parse('${ApiConfig.getPlanByIdUrl(event.planId)}/estado'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'estado': event.nuevoEstado}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          emit(PlanEstadoChanged(event.planId, event.nuevoEstado));
          add(LoadPlanes());
        } else {
          emit(PlanesError(data['message'] ?? 'Error al cambiar el estado'));
        }
      } else {
        emit(PlanesError('Error ${response.statusCode}: ${response.body}'));
      }
    } catch (e) {
      emit(PlanesError(e.toString()));
    }
  }

  Future<void> _onLoadEmprendedores(LoadEmprendedores event, Emitter<PlanesState> emit) async {
    try {
      final emprendedores = await _dashboardService.getEmprendedores();
      emit(EmprendedoresLoaded(emprendedores));
    } catch (e) {
      emit(PlanesError(e.toString()));
    }
  }

  Future<void> _onLoadCategorias(LoadCategorias event, Emitter<PlanesState> emit) async {
    try {
      final categorias = await _dashboardService.getCategorias();
      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(PlanesError(e.toString()));
    }
  }

  void _onFilterPlanes(FilterPlanes event, Emitter<PlanesState> emit) {
    print('🔍 Aplicando filtros en BLoC:');
    print('  - Búsqueda: "${event.searchQuery}"');
    print('  - Estado: ${event.estado}');
    print('  - Dificultad: ${event.dificultad}');
    print('  - Público: ${event.publico}');
    print('  - Total planes antes de filtrar: ${_planes.length}');
    
    _filteredPlanes = _planes.where((plan) {
      // Filtro por búsqueda
      final nombre = (plan['nombre'] ?? '').toString().toLowerCase();
      final descripcion = (plan['descripcion'] ?? '').toString().toLowerCase();
      final matchesQuery = event.searchQuery.isEmpty ||
          nombre.contains(event.searchQuery.toLowerCase()) ||
          descripcion.contains(event.searchQuery.toLowerCase());

      // Filtro por estado
      final estado = (plan['estado'] ?? '').toString();
      bool matchesEstado;
      if (event.estado == 'Todos') {
        matchesEstado = true;
      } else if (event.estado == 'Activos') {
        matchesEstado = estado == 'activo';
      } else if (event.estado == 'Inactivos') {
        matchesEstado = estado == 'inactivo';
      } else {
        matchesEstado = estado == event.estado.toLowerCase();
      }

      // Filtro por dificultad
      final dificultad = (plan['dificultad'] ?? '').toString();
      bool matchesDificultad;
      if (event.dificultad == 'Todas') {
        matchesDificultad = true;
      } else if (event.dificultad == 'Fácil') {
        matchesDificultad = dificultad == 'facil' || dificultad == 'fácil';
      } else if (event.dificultad == 'Moderado') {
        matchesDificultad = dificultad == 'moderado';
      } else if (event.dificultad == 'Difícil') {
        matchesDificultad = dificultad == 'dificil' || dificultad == 'difícil';
      } else {
        matchesDificultad = dificultad == event.dificultad.toLowerCase();
      }

      // Filtro por público
      final esPublico = plan['es_publico'] ?? false;
      bool matchesPublico;
      if (event.publico == 'Todos') {
        matchesPublico = true;
      } else if (event.publico == 'Públicos') {
        matchesPublico = esPublico == true;
      } else if (event.publico == 'Privados') {
        matchesPublico = esPublico == false;
      } else {
        matchesPublico = true;
      }

      final matches = matchesQuery && matchesEstado && matchesDificultad && matchesPublico;
      
      if (matches) {
        print('✅ Plan "${plan['nombre']}" pasa todos los filtros');
      } else {
        print('❌ Plan "${plan['nombre']}" no pasa filtros:');
        print('   - Query: $matchesQuery (${event.searchQuery.isEmpty ? "vacío" : "no coincide"})');
        print('   - Estado: $matchesEstado (plan: $estado, filtro: ${event.estado})');
        print('   - Dificultad: $matchesDificultad (plan: $dificultad, filtro: ${event.dificultad})');
        print('   - Público: $matchesPublico (plan: $esPublico, filtro: ${event.publico})');
      }
      
      return matches;
    }).toList();

    print('📊 Planes después de filtrar: ${_filteredPlanes.length}');

    emit(PlanesLoaded(
      planes: _planes,
      filteredPlanes: _filteredPlanes,
    ));
  }
} 